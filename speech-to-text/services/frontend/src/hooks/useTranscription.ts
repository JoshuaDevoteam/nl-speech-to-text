'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import { ApiClient, WebSocketClient } from '@/lib/api'
import type {
  TranscriptionState,
  UploadResult,
  TranscriptionOptions,
  WebSocketMessage,
  UploadProgress
} from '@/types/transcription'
import toast from 'react-hot-toast'

export function useTranscription() {
  const [transcriptionState, setTranscriptionState] = useState<TranscriptionState>({})
  const [uploadProgress, setUploadProgress] = useState(0)
  const [uploadStats, setUploadStats] = useState<{
    loaded: number
    total?: number
    speedBps?: number
    etaSeconds?: number
  } | null>(null)
  const [isUploading, setIsUploading] = useState(false)
  const [isTranscribing, setIsTranscribing] = useState(false)
  const [transcriptionEta, setTranscriptionEta] = useState<number | null>(null)
  const [transcriptionProgressHint, setTranscriptionProgressHint] = useState<number | null>(null)
  const [currentFileSizeBytes, setCurrentFileSizeBytes] = useState<number | undefined>(undefined)
  
  const wsClient = useRef<WebSocketClient | null>(null)
  const pollingInterval = useRef<NodeJS.Timeout | null>(null)
  const uploadStartTime = useRef<number | null>(null)
  const uploadSmoothedSpeed = useRef<number | null>(null)
  const uploadLastEvent = useRef<{ loaded: number; timestamp: number } | null>(null)
  const uploadTicker = useRef<NodeJS.Timeout | null>(null)
  const uploadRawProgress = useRef<number>(0)
  const uploadDisplayedProgress = useRef<number>(0)
  const uploadEtaRef = useRef<number | null>(null)
  const uploadTotalBytesRef = useRef<number | undefined>(undefined)
  const uploadExpectedDuration = useRef<number | null>(null)
  const uploadCompletedRef = useRef<boolean>(false)
  const uploadLoadedRef = useRef<number>(0)
  const currentFileNameRef = useRef<string | undefined>(undefined)

  const transcriptionStageStart = useRef<number | null>(null)
  const transcriptionStageExpected = useRef<number | null>(null)
  const transcriptionLastStatus = useRef<string | undefined>(undefined)
  const transcriptionEtaTimer = useRef<NodeJS.Timeout | null>(null)
  const transcriptionProgressRef = useRef<number | undefined>(undefined)

  const estimateUploadDuration = useCallback((sizeBytes?: number) => {
    if (!sizeBytes) return null
    const sizeMB = sizeBytes / (1024 * 1024)

    // Assume slower speeds for larger files to avoid overly optimistic ETAs
    const assumedRateMbPerSec = sizeMB >= 8192
      ? 0.35
      : sizeMB >= 4096
        ? 0.45
        : sizeMB >= 2048
          ? 0.55
          : sizeMB >= 1024
            ? 0.75
            : 1.1

    const estimatedSeconds = (sizeMB / Math.max(assumedRateMbPerSec, 0.1)) * 1.35
    return Math.max(estimatedSeconds, 60)
  }, [])

  const stopUploadTicker = useCallback(() => {
    if (uploadTicker.current) {
      clearInterval(uploadTicker.current)
      uploadTicker.current = null
    }
  }, [])

  const updateUploadUi = useCallback(() => {
    const totalBytes = uploadTotalBytesRef.current
    const now = performance.now()
    const elapsedSeconds = uploadStartTime.current
      ? (now - uploadStartTime.current) / 1000
      : 0

    if (!uploadExpectedDuration.current && totalBytes) {
      uploadExpectedDuration.current = estimateUploadDuration(totalBytes)
    }

    const expectedDuration = uploadExpectedDuration.current ?? null
    const currentDisplay = uploadDisplayedProgress.current

    let targetPercent: number

    if (uploadCompletedRef.current) {
      targetPercent = Math.max(uploadRawProgress.current, currentDisplay)
    } else {
      const cappedActual = Math.min(uploadRawProgress.current, 98)
      const timeDriven = expectedDuration
        ? Math.min((elapsedSeconds / expectedDuration) * 100, 92)
        : cappedActual
      let baseTarget = Math.min(cappedActual, timeDriven)
      if (baseTarget <= currentDisplay && timeDriven > currentDisplay) {
        baseTarget = Math.min(timeDriven, 92)
      }
      targetPercent = Math.max(currentDisplay, baseTarget)
    }

    const diff = targetPercent - currentDisplay
    let nextDisplay = currentDisplay

    if (diff > 0.1) {
      const maxStep = uploadCompletedRef.current ? 12 : Math.max(0.35, diff * 0.08)
      nextDisplay = Math.min(targetPercent, currentDisplay + maxStep)
    } else if (diff < -0.1) {
      nextDisplay = targetPercent
    }

    uploadDisplayedProgress.current = nextDisplay

    const percentRounded = Math.floor(Math.max(0, Math.min(100, nextDisplay)))
    setUploadProgress(percentRounded)

    const displayedLoaded = totalBytes
      ? Math.min((nextDisplay / 100) * totalBytes, totalBytes)
      : uploadLoadedRef.current

    const theoreticalSpeed = expectedDuration && totalBytes
      ? totalBytes / Math.max(expectedDuration, elapsedSeconds > 0 ? elapsedSeconds : 1)
      : undefined

    let speed: number | undefined
    if (uploadSmoothedSpeed.current != null) {
      speed = theoreticalSpeed != null
        ? Math.min(uploadSmoothedSpeed.current, theoreticalSpeed)
        : uploadSmoothedSpeed.current
    } else if (theoreticalSpeed != null) {
      speed = theoreticalSpeed
    }

    const etaFromExpected = expectedDuration != null
      ? Math.max(expectedDuration - elapsedSeconds, 0)
      : undefined

    let etaSeconds: number | undefined
    if (uploadCompletedRef.current) {
      etaSeconds = 0
    } else {
      const storedEta = uploadEtaRef.current ?? undefined
      if (etaFromExpected != null && storedEta != null) {
        etaSeconds = Math.max(Math.min(storedEta, etaFromExpected), 0)
      } else {
        etaSeconds = etaFromExpected ?? storedEta
      }

      if (etaSeconds != null) {
        uploadEtaRef.current = etaSeconds
      }
    }

    setUploadStats({
      loaded: Number.isFinite(displayedLoaded) ? displayedLoaded : uploadLoadedRef.current ?? 0,
      total: totalBytes,
      speedBps: speed,
      etaSeconds,
    })
  }, [estimateUploadDuration])

  const startUploadTicker = useCallback((totalBytes?: number) => {
    uploadTotalBytesRef.current = totalBytes
    uploadDisplayedProgress.current = 0
    uploadRawProgress.current = 0
    uploadLoadedRef.current = 0
    const initialEstimate = totalBytes ? estimateUploadDuration(totalBytes) : null
    uploadEtaRef.current = null
    uploadExpectedDuration.current = initialEstimate
    uploadCompletedRef.current = false

    stopUploadTicker()
    updateUploadUi()
    uploadTicker.current = setInterval(updateUploadUi, 400)
  }, [estimateUploadDuration, stopUploadTicker, updateUploadUi])

  const getEstimatedStageDuration = useCallback((status?: string) => {
    if (!status) return null
    const sizeBytes = transcriptionState.fileSizeBytes ?? currentFileSizeBytes
    const sizeMB = sizeBytes ? sizeBytes / (1024 * 1024) : undefined

    switch (status) {
      case 'pending':
        return 45
      case 'processing':
        if (sizeMB) {
          return Math.min(Math.max(90 + sizeMB * 0.35, 120), 20 * 60)
        }
        return 180
      case 'extracting_audio':
        if (sizeMB) {
          return Math.min(Math.max(120 + sizeMB * 0.5, 180), 25 * 60)
        }
        return 300
      case 'transcribing':
        if (sizeMB) {
          return Math.min(Math.max(600 + sizeMB * 1.1, 15 * 60), 60 * 60)
        }
        return 30 * 60
      default:
        return null
    }
  }, [transcriptionState.fileSizeBytes, currentFileSizeBytes])

  // WebSocket message handler
  const handleWebSocketMessage = useCallback((data: WebSocketMessage) => {
    console.log('WebSocket message:', data)
    
    setTranscriptionState(prev => ({
      ...prev,
      status: data.status as any,
      progress: data.progress || prev.progress,
      message: data.message,
      transcript: data.data?.transcript || prev.transcript,
      transcriptSegments: data.data?.transcript_segments || data.data?.segments_preview || prev.transcriptSegments,
      speakerIdentifiedTranscript: data.data?.speaker_identified_transcript || prev.speakerIdentifiedTranscript,
      speakerIdentificationSummary: data.data?.speaker_identification_summary || prev.speakerIdentificationSummary,
      refinedTranscript: data.data?.refined_transcript ?? prev.refinedTranscript,
      fileName: prev.fileName ?? currentFileNameRef.current
    }))

    // Handle completion
    if (data.status === 'completed' || data.status === 'failed') {
      if (wsClient.current) {
        wsClient.current.markComplete()
      }
      setIsTranscribing(false)
      
      // Fetch final results
      if (data.job_id) {
        fetchTranscriptionStatus(data.job_id)
      }
    }
  }, [])

  // Fetch transcription status via polling (fallback)
  const fetchTranscriptionStatus = useCallback(async (jobId: string) => {
    try {
      const status = await ApiClient.getTranscriptionStatus(jobId)
      
      setTranscriptionState(prev => ({
        ...prev,
        jobId: status.job_id,
        status: status.status as any,
        progress: status.progress,
        transcript: status.transcript,
        transcriptUri: status.transcript_uri,
        transcriptSegments: status.transcript_segments,
        speakerIdentifiedTranscript: status.speaker_identified_transcript,
        speakerIdentificationSummary: status.speaker_identification_summary,
        refinedTranscript: status.refined_transcript,
        error: status.error,
        createdAt: status.created_at,
        startedAt: status.started_at,
        completedAt: status.completed_at,
        gcsUri: status.gcs_uri,
        fileName: prev.fileName ?? currentFileNameRef.current
      }))

      // Stop polling if completed or failed
      if (status.status === 'completed' || status.status === 'failed') {
        setIsTranscribing(false)
        if (pollingInterval.current) {
          clearInterval(pollingInterval.current)
          pollingInterval.current = null
        }
      }
    } catch (error) {
      console.error('Failed to fetch transcription status:', error)
      toast.error('Failed to get transcription status')
    }
  }, [])

  // Start polling for transcription status
  const startPolling = useCallback((jobId: string) => {
    if (pollingInterval.current) {
      clearInterval(pollingInterval.current)
    }

    pollingInterval.current = setInterval(() => {
      fetchTranscriptionStatus(jobId)
    }, 2000) // Poll every 2 seconds
  }, [fetchTranscriptionStatus])

  // Upload file using smart upload (direct-to-GCS with resumable support)
  const uploadFile = useCallback(async (file: File): Promise<UploadResult> => {
    setIsUploading(true)
    setUploadProgress(0)
    setUploadStats({ loaded: 0, total: file.size })
    setCurrentFileSizeBytes(file.size)
    currentFileNameRef.current = file.name

    const start = performance.now()
    uploadStartTime.current = start
    uploadLastEvent.current = { loaded: 0, timestamp: start }
    uploadSmoothedSpeed.current = null
    uploadCompletedRef.current = false
    uploadLoadedRef.current = 0
    uploadRawProgress.current = 0

    startUploadTicker(file.size)

    try {
      // Use the new smart upload that bypasses Cloud Run's 32MB limit
      const result = await ApiClient.uploadFileSmart(file, (progress: UploadProgress) => {
        const { percent, loaded, total = file.size, stage } = progress
        const totalBytes = total
        const clampedLoaded = totalBytes ? Math.min(loaded, totalBytes) : loaded
        const now = performance.now()
        const last = uploadLastEvent.current

        // Show stage information in the UI
        if (stage === 'preparing') {
          // Show preparing stage for large files
          toast.loading(`Preparing ${file.size >= 100 * 1024 * 1024 ? 'resumable ' : ''}upload...`, { id: 'upload-stage' })
        } else if (stage === 'uploading') {
          toast.dismiss('upload-stage')
        } else if (stage === 'completing') {
          toast.loading('Finalizing upload...', { id: 'upload-stage' })
        }

        let smoothedSpeed = uploadSmoothedSpeed.current ?? null

        if (last && stage === 'uploading') {
          const deltaBytes = Math.max(0, clampedLoaded - last.loaded)
          const deltaTimeSeconds = (now - last.timestamp) / 1000

          if (deltaBytes > 0 && deltaTimeSeconds > 0.05) {
            const instantaneousSpeed = deltaBytes / deltaTimeSeconds
            const alpha = 0.25
            smoothedSpeed = smoothedSpeed
              ? smoothedSpeed + alpha * (instantaneousSpeed - smoothedSpeed)
              : instantaneousSpeed
            uploadSmoothedSpeed.current = smoothedSpeed
          }
        }

        if (!smoothedSpeed && uploadStartTime.current && stage === 'uploading') {
          const elapsedSeconds = (now - uploadStartTime.current) / 1000
          if (elapsedSeconds > 0.1 && clampedLoaded > 0) {
            smoothedSpeed = clampedLoaded / elapsedSeconds
            uploadSmoothedSpeed.current = smoothedSpeed
          }
        }

        uploadLastEvent.current = { loaded: clampedLoaded, timestamp: now }
        uploadTotalBytesRef.current = totalBytes
        uploadLoadedRef.current = clampedLoaded

        const safePercent = Number.isFinite(percent)
          ? Math.min(100, Math.max(0, percent))
          : totalBytes > 0
            ? Math.min(100, Math.max(0, (clampedLoaded / totalBytes) * 100))
            : 0

        const cappedForDisplay = uploadCompletedRef.current || stage === 'completing'
          ? safePercent
          : Math.min(safePercent, 98)

        uploadRawProgress.current = cappedForDisplay

        const elapsedSeconds = uploadStartTime.current ? (now - uploadStartTime.current) / 1000 : 0

        if (smoothedSpeed && totalBytes && stage === 'uploading') {
          const remainingSeconds = Math.max((totalBytes - clampedLoaded) / Math.max(smoothedSpeed, 1), 0)
          const proposedDuration = Math.max(elapsedSeconds + remainingSeconds, 60)
          const previous = uploadExpectedDuration.current ?? proposedDuration
          const nextExpected = Math.max(previous, proposedDuration)
          uploadExpectedDuration.current = nextExpected
          const longTailEta = Math.max(nextExpected - elapsedSeconds, 0)
          uploadEtaRef.current = Math.max(remainingSeconds, longTailEta)
        } else if (totalBytes) {
          const estimate = uploadExpectedDuration.current ?? estimateUploadDuration(totalBytes)
          uploadExpectedDuration.current = estimate ?? null
          uploadEtaRef.current = estimate ? Math.max(estimate - elapsedSeconds, 0) : null
        }

        updateUploadUi()
      })

      toast.dismiss('upload-stage')
      uploadCompletedRef.current = true
      uploadRawProgress.current = 100
      uploadLoadedRef.current = file.size
      uploadEtaRef.current = 0
      updateUploadUi()

      // Convert to the expected UploadResult format
      const uploadResult: UploadResult = {
        success: true,
        data: {
          gcs_uri: result.gcs_uri,
          filename: result.filename,
          original_filename: file.name,
          size: file.size,
          content_type: file.type
        }
      }

      setCurrentFileSizeBytes(file.size)
      setTranscriptionState(prev => ({
        ...prev,
        fileName: file.name
      }))
      toast.success('File uploaded successfully!')
      setTimeout(() => {
        stopUploadTicker()
        setIsUploading(false)
        setUploadProgress(0)
        setUploadStats(null)
        uploadTotalBytesRef.current = undefined
        uploadExpectedDuration.current = null
        uploadEtaRef.current = null
        uploadDisplayedProgress.current = 0
        uploadRawProgress.current = 0
        uploadLoadedRef.current = 0
      }, 750)

      uploadStartTime.current = null
      uploadLastEvent.current = null
      uploadSmoothedSpeed.current = null

      return uploadResult
    } catch (error) {
      toast.dismiss('upload-stage')
      stopUploadTicker()
      setIsUploading(false)
      setUploadProgress(0)
      setUploadStats(null)
      uploadStartTime.current = null
      uploadLastEvent.current = null
      uploadSmoothedSpeed.current = null
      setCurrentFileSizeBytes(undefined)
      uploadTotalBytesRef.current = undefined
      uploadExpectedDuration.current = null
      uploadEtaRef.current = null
      uploadDisplayedProgress.current = 0
      uploadRawProgress.current = 0
      uploadLoadedRef.current = 0
      uploadCompletedRef.current = true
      
      // Return error result instead of throwing to match expected interface
      return {
        success: false,
        error: error instanceof Error ? error.message : 'Upload failed'
      }
    }
  }, [estimateUploadDuration, startUploadTicker, stopUploadTicker, updateUploadUi])

  // Start transcription
  const startTranscription = useCallback(async (
    gcsUri: string, 
    options: TranscriptionOptions = {}
  ) => {
    setIsTranscribing(true)
    setTranscriptionState(prev => ({
      ...prev,
      status: 'pending',
      progress: 0,
      gcsUri,
      fileSizeBytes: currentFileSizeBytes ?? prev.fileSizeBytes,
      transcriptSegments: undefined,
      refinedTranscript: undefined,
      fileName: prev.fileName ?? currentFileNameRef.current
    }))

    try {
      const request = {
        gcs_uri: gcsUri,
        language_code: options.language_code || 'nl-NL',
        recognizer_id: options.recognizer_id,
        extract_audio: options.extract_audio || false,
        enable_punctuation: options.enable_punctuation !== false,
        enable_diarization: options.enable_diarization || false,
        enable_speaker_identification: options.enable_speaker_identification || false,
        min_speaker_count: options.min_speaker_count || 2,
        max_speaker_count: options.max_speaker_count || 10
      }

      const response = await ApiClient.startTranscription(request)
      
      setTranscriptionState(prev => ({
        ...prev,
        jobId: response.job_id,
        status: response.status as any,
        message: response.message,
        createdAt: new Date().toISOString(),
        fileSizeBytes: currentFileSizeBytes ?? prev.fileSizeBytes,
        fileName: prev.fileName ?? currentFileNameRef.current
      }))

      // Set up WebSocket connection for real-time updates
      wsClient.current = new WebSocketClient(
        response.job_id,
        handleWebSocketMessage,
        (error) => {
          console.error('WebSocket error:', error)
          // Fall back to polling if WebSocket fails
          startPolling(response.job_id)
        },
        () => {
          console.log('WebSocket connection closed')
        }
      )

      wsClient.current.connect()

      // Start polling as fallback
      startPolling(response.job_id)

      toast.success('Transcription started!')
    } catch (error: any) {
      setIsTranscribing(false)
      setTranscriptionState(prev => ({
        ...prev,
        status: 'failed',
        error: error.response?.data?.detail || error.message || 'Failed to start transcription'
      }))
      toast.error('Failed to start transcription')
      throw error
    }
  }, [handleWebSocketMessage, startPolling, currentFileSizeBytes])

  // Heuristic ETA for transcription stages when backend progress is limited
  useEffect(() => {
    const status = transcriptionState.status

    transcriptionProgressRef.current = transcriptionState.progress ?? undefined

    if (transcriptionState.progress != null) {
      setTranscriptionProgressHint(null)
    }

    const expectedSeconds = getEstimatedStageDuration(status)

    if (status && expectedSeconds) {

      if (transcriptionStageStart.current === null || transcriptionLastStatus.current !== status) {
        transcriptionStageStart.current = Date.now()
        transcriptionStageExpected.current = expectedSeconds
        setTranscriptionEta(expectedSeconds)
        setTranscriptionProgressHint(null)
        if (transcriptionEtaTimer.current) {
          clearInterval(transcriptionEtaTimer.current)
          transcriptionEtaTimer.current = null
        }
      }

      if (!transcriptionEtaTimer.current) {
        transcriptionEtaTimer.current = setInterval(() => {
          if (!transcriptionStageStart.current || !transcriptionStageExpected.current) return
          const elapsed = (Date.now() - transcriptionStageStart.current) / 1000
          const remaining = Math.max(transcriptionStageExpected.current - elapsed, 0)
          setTranscriptionEta(remaining)

          if (transcriptionProgressRef.current == null) {
            const pseudoProgress = Math.min((elapsed / transcriptionStageExpected.current) * 100, 99)
            setTranscriptionProgressHint(pseudoProgress)
          }
        }, 1000)
      }
    } else {
      transcriptionStageStart.current = null
      transcriptionStageExpected.current = null
      transcriptionProgressRef.current = undefined
      setTranscriptionEta(null)
      setTranscriptionProgressHint(null)
      if (transcriptionEtaTimer.current) {
        clearInterval(transcriptionEtaTimer.current)
        transcriptionEtaTimer.current = null
      }
    }

    if (status === 'completed') {
      setTranscriptionEta(0)
      setTranscriptionProgressHint(100)
    }

    transcriptionLastStatus.current = status

    return () => {
      if (transcriptionEtaTimer.current) {
        clearInterval(transcriptionEtaTimer.current)
        transcriptionEtaTimer.current = null
      }
    }
  }, [transcriptionState.status, transcriptionState.progress, getEstimatedStageDuration])

  // Delete transcription
  const deleteTranscription = useCallback(async (jobId: string) => {
    try {
      await ApiClient.deleteTranscription(jobId)
      toast.success('Transcription deleted')
    } catch (error) {
      toast.error('Failed to delete transcription')
      throw error
    }
  }, [])

  // Reset state
  const reset = useCallback(() => {
    // Clean up WebSocket
    if (wsClient.current) {
      wsClient.current.disconnect()
      wsClient.current = null
    }

    // Clean up polling
    if (pollingInterval.current) {
      clearInterval(pollingInterval.current)
      pollingInterval.current = null
    }

    stopUploadTicker()
    // Reset state
    setTranscriptionState({})
    currentFileNameRef.current = undefined
    setUploadProgress(0)
    setUploadStats(null)
    setIsUploading(false)
    setIsTranscribing(false)
    uploadStartTime.current = null
    uploadSmoothedSpeed.current = null
    uploadLastEvent.current = null
    uploadTotalBytesRef.current = undefined
    uploadExpectedDuration.current = null
    uploadEtaRef.current = null
    uploadCompletedRef.current = false
    uploadDisplayedProgress.current = 0
    uploadRawProgress.current = 0
    uploadLoadedRef.current = 0
    transcriptionStageStart.current = null
    transcriptionStageExpected.current = null
    transcriptionLastStatus.current = undefined
    transcriptionProgressRef.current = undefined
    setTranscriptionEta(null)
    setTranscriptionProgressHint(null)
    setCurrentFileSizeBytes(undefined)
    if (transcriptionEtaTimer.current) {
      clearInterval(transcriptionEtaTimer.current)
      transcriptionEtaTimer.current = null
    }
  }, [stopUploadTicker])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (wsClient.current) {
        wsClient.current.disconnect()
      }
      if (pollingInterval.current) {
        clearInterval(pollingInterval.current)
      }
      stopUploadTicker()
      if (transcriptionEtaTimer.current) {
        clearInterval(transcriptionEtaTimer.current)
      }
    }
  }, [stopUploadTicker])

  return {
    transcriptionState,
    uploadProgress,
    uploadStats,
    isUploading,
    isTranscribing,
    uploadFile,
    startTranscription,
    deleteTranscription,
    fetchTranscriptionStatus,
    reset,
    transcriptionEta,
    transcriptionProgressHint,
  }
}
