'use client'

import { useState, useCallback, useRef, useEffect } from 'react'
import { ApiClient, WebSocketClient } from '@/lib/api'
import type {
  TranscriptionState,
  UploadResult,
  TranscriptionOptions,
  WebSocketMessage
} from '@/types/transcription'
import toast from 'react-hot-toast'

export function useTranscription() {
  const [transcriptionState, setTranscriptionState] = useState<TranscriptionState>({})
  const [uploadProgress, setUploadProgress] = useState(0)
  const [isUploading, setIsUploading] = useState(false)
  const [isTranscribing, setIsTranscribing] = useState(false)
  
  const wsClient = useRef<WebSocketClient | null>(null)
  const pollingInterval = useRef<NodeJS.Timeout | null>(null)

  // WebSocket message handler
  const handleWebSocketMessage = useCallback((data: WebSocketMessage) => {
    console.log('WebSocket message:', data)
    
    setTranscriptionState(prev => ({
      ...prev,
      status: data.status as any,
      progress: data.progress || prev.progress,
      message: data.message,
      transcript: data.data?.transcript || prev.transcript
    }))

    // Handle completion
    if (data.status === 'completed' || data.status === 'failed') {
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
        error: status.error,
        createdAt: status.created_at,
        startedAt: status.started_at,
        completedAt: status.completed_at,
        gcsUri: status.gcs_uri
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

  // Upload file
  const uploadFile = useCallback(async (file: File): Promise<UploadResult> => {
    setIsUploading(true)
    setUploadProgress(0)

    try {
      // Simulate upload progress for better UX
      const progressInterval = setInterval(() => {
        setUploadProgress(prev => {
          if (prev < 90) {
            return prev + Math.random() * 10
          }
          return prev
        })
      }, 200)

      const result = await ApiClient.uploadFile(file)

      clearInterval(progressInterval)
      setUploadProgress(100)

      if (result.success) {
        toast.success('File uploaded successfully!')
        setTimeout(() => {
          setIsUploading(false)
          setUploadProgress(0)
        }, 500)
      } else {
        setIsUploading(false)
        setUploadProgress(0)
      }

      return result
    } catch (error) {
      setIsUploading(false)
      setUploadProgress(0)
      throw error
    }
  }, [])

  // Start transcription
  const startTranscription = useCallback(async (
    gcsUri: string, 
    options: TranscriptionOptions = {}
  ) => {
    setIsTranscribing(true)
    setTranscriptionState({
      status: 'pending',
      progress: 0,
      gcsUri
    })

    try {
      const request = {
        gcs_uri: gcsUri,
        language_code: options.language_code || 'nl-NL',
        recognizer_id: options.recognizer_id,
        extract_audio: options.extract_audio || false,
        enable_punctuation: options.enable_punctuation !== false,
        enable_diarization: options.enable_diarization || false,
        min_speaker_count: options.min_speaker_count || 2,
        max_speaker_count: options.max_speaker_count || 10
      }

      const response = await ApiClient.startTranscription(request)
      
      setTranscriptionState(prev => ({
        ...prev,
        jobId: response.job_id,
        status: response.status as any,
        message: response.message,
        createdAt: new Date().toISOString()
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
  }, [handleWebSocketMessage, startPolling])

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

    // Reset state
    setTranscriptionState({})
    setUploadProgress(0)
    setIsUploading(false)
    setIsTranscribing(false)
  }, [])

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      if (wsClient.current) {
        wsClient.current.disconnect()
      }
      if (pollingInterval.current) {
        clearInterval(pollingInterval.current)
      }
    }
  }, [])

  return {
    transcriptionState,
    uploadProgress,
    isUploading,
    isTranscribing,
    uploadFile,
    startTranscription,
    deleteTranscription,
    fetchTranscriptionStatus,
    reset
  }
}