'use client'

import { useState, useCallback } from 'react'
import { CloudArrowUpIcon, SpeakerWaveIcon, DocumentTextIcon, Cog6ToothIcon } from '@heroicons/react/24/outline'
import FileUpload from '@/components/FileUpload'
import ProgressBar from '@/components/ProgressBar'
import TranscriptionResult from '@/components/TranscriptionResult'
import { useTranscription } from '@/hooks/useTranscription'
import type { TranscriptionOptions } from '@/types/transcription'
import toast from 'react-hot-toast'

const DEFAULT_OPTIONS: TranscriptionOptions = {
  extract_audio: false,
  enable_punctuation: true,
  enable_speaker_identification: true,
  min_speaker_count: 2,
  max_speaker_count: 6,
}

export default function HomePage() {
  const formatBytes = (bytes: number | undefined) => {
    if (!bytes && bytes !== 0) return null
    if (bytes === 0) return '0 B'
    const units = ['B', 'KB', 'MB', 'GB', 'TB']
    const i = Math.floor(Math.log(bytes) / Math.log(1024))
    const value = bytes / Math.pow(1024, i)
    return `${value.toFixed(value >= 10 || i === 0 ? 0 : 1)} ${units[i]}`
  }

  const formatDuration = (seconds?: number | null) => {
    if (seconds == null || Number.isNaN(seconds)) return null
    const clamped = Math.max(0, seconds)
    if (clamped >= 3600) {
      const hours = Math.floor(clamped / 3600)
      const minutes = Math.floor((clamped % 3600) / 60)
      return `${hours}h${minutes > 0 ? ` ${minutes}m` : ''}`
    }
    if (clamped >= 60) {
      const minutes = Math.floor(clamped / 60)
      const secs = Math.floor(clamped % 60)
      return `${minutes}m${secs > 0 ? ` ${secs}s` : ''}`
    }
    return `${Math.ceil(clamped)}s`
  }

  const {
    uploadFile,
    startTranscription,
    transcriptionState,
    uploadProgress,
    uploadStats,
    transcriptionEta,
    transcriptionProgressHint,
    isUploading,
    isTranscribing,
    reset
  } = useTranscription()

  const [uploadedFile, setUploadedFile] = useState<File | null>(null)
  const [transcriptionOptions, setTranscriptionOptions] = useState<TranscriptionOptions>({ ...DEFAULT_OPTIONS })

  const handleFileUpload = useCallback(async (file: File) => {
    try {
      reset()
      setUploadedFile(file)

      const isVideoFile = file.type.startsWith('video/')
      if (isVideoFile && !transcriptionOptions.extract_audio) {
        setTranscriptionOptions(prev => ({
          ...prev,
          extract_audio: true,
        }))
      }

      const result = await uploadFile(file)

      if (!result.success) {
        toast.error(result.error || 'Failed to upload file')
        return
      }

      toast.success('File uploaded successfully!')

      const shouldExtractAudio = isVideoFile ? true : transcriptionOptions.extract_audio

      try {
        await startTranscription(result.data.gcs_uri, {
          ...transcriptionOptions,
          extract_audio: shouldExtractAudio,
        })
      } catch (startError) {
        console.error('Transcription start error:', startError)
        toast.error('Failed to start transcription')
      }
    } catch (error) {
      console.error('Upload error:', error)
      toast.error('An unexpected error occurred during upload')
    }
  }, [uploadFile, startTranscription, transcriptionOptions, reset])

  const handleNewUpload = useCallback(() => {
    reset()
    setUploadedFile(null)
    setTranscriptionOptions({ ...DEFAULT_OPTIONS })
  }, [reset])

  const features = [
    {
      name: 'Fast Upload',
      description: 'Upload audio and video files up to 5GB in size with progress tracking.',
      icon: CloudArrowUpIcon,
    },
    {
      name: 'Speaker Identification',
      description: 'AI-powered speaker identification for Dutch conversations using Gemini.',
      icon: SpeakerWaveIcon,
    },
    {
      name: 'Dutch Transcription',
      description: 'High-quality Dutch speech transcription using Google Cloud AI.',
      icon: DocumentTextIcon,
    },
  ]

  const isVideoUpload = !!uploadedFile?.type.startsWith('video/')

  return (
    <div className="py-12">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        {/* Hero section */}
        <div className="text-center">
          <h1 className="text-4xl font-bold tracking-tight text-gray-900 sm:text-6xl">
            Dutch Speech to Text
          </h1>
          <p className="mt-6 text-lg leading-8 text-gray-600">
            Upload your audio or video files and get accurate Dutch transcriptions 
            in minutes using advanced AI technology.
          </p>
        </div>

        {/* Configuration & upload */}
        <div className="mt-16 space-y-10">
          <div className="mx-auto max-w-4xl">
            <div className="card">
              <div className="flex items-center space-x-2 mb-6">
                <Cog6ToothIcon className="h-5 w-5 text-primary-600" />
                <h3 className="text-lg font-medium text-gray-900">Transcription Configuration</h3>
              </div>
              <p className="text-sm text-gray-600 mb-6">
                Configure the run before you upload. These settings apply to the next transcription automatically after the upload finishes.
              </p>

              <div className="space-y-6">
                <div className="rounded-lg border border-primary-100 bg-primary-50 p-4">
                  <div className="flex items-start space-x-3">
                    <div className="flex h-10 w-10 items-center justify-center rounded-full bg-white shadow-sm">
                      <SpeakerWaveIcon className="h-5 w-5 text-primary-600" />
                    </div>
                    <div>
                      <h4 className="text-sm font-medium text-primary-900">Gemini speaker identification</h4>
                      <p className="mt-1 text-xs text-primary-700">
                        Keep speaker labels consistent throughout the full transcript using our LLM-based analysis.
                      </p>
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">Automatic punctuation</label>
                    <p className="text-xs text-gray-500">Add punctuation and casing automatically.</p>
                  </div>
                  <input
                    type="checkbox"
                    checked={transcriptionOptions.enable_punctuation}
                    onChange={(e) => setTranscriptionOptions(prev => ({
                      ...prev,
                      enable_punctuation: e.target.checked
                    }))}
                    disabled={isUploading || isTranscribing}
                    className="h-4 w-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500 disabled:opacity-50"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">LLM speaker identification</label>
                    <p className="text-xs text-gray-500">Use Gemini to detect speaker changes automatically.</p>
                  </div>
                  <input
                    type="checkbox"
                    checked={transcriptionOptions.enable_speaker_identification}
                    onChange={(e) => setTranscriptionOptions(prev => ({
                      ...prev,
                      enable_speaker_identification: e.target.checked
                    }))}
                    disabled={isUploading || isTranscribing}
                    className="h-4 w-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500 disabled:opacity-50"
                  />
                </div>

                <div className="flex items-center justify-between">
                  <div>
                    <label className="text-sm font-medium text-gray-700">Extract audio</label>
                    <p className="text-xs text-gray-500">
                      {isVideoUpload
                        ? 'Convert this video to audio automatically before transcribing.'
                        : transcriptionOptions.extract_audio
                          ? 'Will extract audio when you upload a video file.'
                          : 'Toggle on to extract audio on the next video upload.'}
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={transcriptionOptions.extract_audio}
                    onChange={(e) => setTranscriptionOptions(prev => ({
                      ...prev,
                      extract_audio: e.target.checked
                    }))}
                    disabled={isUploading || isTranscribing}
                    className="h-4 w-4 rounded border-gray-300 text-primary-600 focus:ring-primary-500 disabled:opacity-50"
                  />
                </div>
              </div>
            </div>
          </div>

          <div className="mx-auto max-w-3xl space-y-8">
            {!transcriptionState.jobId && !isUploading && !isTranscribing && (
              <div className="card">
                <FileUpload 
                  onFileSelect={handleFileUpload}
                  disabled={isUploading || isTranscribing}
                />
              </div>
            )}

            {isUploading && (
              <div className="card">
                <div className="text-center">
                  <h3 className="mb-4 text-lg font-medium text-gray-900">
                    Uploading {uploadedFile?.name}...
                  </h3>
                  <ProgressBar 
                    progress={uploadProgress} 
                    className="mb-4"
                    etaSeconds={uploadStats?.etaSeconds ?? undefined}
                    speedBytesPerSecond={uploadStats?.speedBps ?? undefined}
                  />
                  <p className="text-sm text-gray-500">
                    {uploadProgress}% complete
                    {uploadStats?.loaded !== undefined && (
                      <>
                        {' '}
                        ({formatBytes(uploadStats.loaded)}
                        {uploadStats?.total ? ` of ${formatBytes(uploadStats.total)}` : ''})
                      </>
                    )}
                  </p>
                  {uploadStats?.etaSeconds != null && uploadStats.etaSeconds > 0 && (
                    <p className="mt-1 text-xs text-gray-400">
                      ~{formatDuration(uploadStats.etaSeconds)} remaining
                      {uploadStats.speedBps && uploadStats.speedBps > 0 && (
                        <> · {formatBytes(uploadStats.speedBps)}/s</>
                      )}
                    </p>
                  )}
                </div>
              </div>
            )}

            {(isTranscribing || transcriptionState.jobId) && (
              <div className="space-y-6">
                <div className="card">
                  <ProgressBar 
                    transcriptionState={transcriptionState}
                    className="mb-4"
                    etaSeconds={transcriptionEta ?? undefined}
                    fallbackProgress={transcriptionProgressHint ?? undefined}
                  />
                  {transcriptionEta && transcriptionEta > 0 && (
                    <p className="text-center text-xs text-gray-400">
                      Estimated remaining time ~{formatDuration(transcriptionEta)}
                    </p>
                  )}
                </div>

                {transcriptionState.transcript && (
                  <TranscriptionResult 
                    transcriptionState={transcriptionState}
                    onNewUpload={handleNewUpload}
                  />
                )}

                {(transcriptionState.status === 'completed' || transcriptionState.status === 'failed') && (
                  <div className="text-center">
                    <button
                      onClick={handleNewUpload}
                      className="btn-primary"
                    >
                      Upload Another File
                    </button>
                  </div>
                )}
              </div>
            )}
          </div>
        </div>

        {/* Features section */}
        {!transcriptionState.jobId && !isUploading && !isTranscribing && (
          <div className="mt-24">
            <div className="mx-auto max-w-5xl">
              <div className="text-center">
                <h2 className="text-3xl font-bold tracking-tight text-gray-900">
                  How it works
                </h2>
                <p className="mt-4 text-lg leading-8 text-gray-600">
                  Simple, fast, and accurate transcription in three easy steps.
                </p>
              </div>

              <div className="mt-16 grid grid-cols-1 gap-8 sm:grid-cols-2 lg:grid-cols-3">
                {features.map((feature) => (
                  <div key={feature.name} className="card text-center">
                    <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-primary-100">
                      <feature.icon className="h-6 w-6 text-primary-600" aria-hidden="true" />
                    </div>
                    <h3 className="mt-6 text-lg font-medium text-gray-900">
                      {feature.name}
                    </h3>
                    <p className="mt-2 text-base text-gray-500">
                      {feature.description}
                    </p>
                  </div>
                ))}
              </div>
            </div>
          </div>
        )}

        {/* Supported formats */}
        {!transcriptionState.jobId && !isUploading && !isTranscribing && (
          <div className="mt-16">
            <div className="text-center">
              <h3 className="text-lg font-medium text-gray-900 mb-4">
                Supported File Formats
              </h3>
              <div className="flex flex-wrap justify-center gap-2">
                {['MP3', 'MP4', 'WAV', 'M4A', 'FLAC', 'OGG', 'WEBM', 'MOV'].map((format) => (
                  <span 
                    key={format}
                    className="inline-flex items-center px-3 py-1 rounded-full text-sm font-medium bg-gray-100 text-gray-800"
                  >
                    {format}
                  </span>
                ))}
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
