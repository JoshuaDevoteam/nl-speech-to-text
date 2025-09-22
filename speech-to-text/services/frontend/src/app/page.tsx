'use client'

import { useState, useCallback } from 'react'
import { CloudArrowUpIcon, SpeakerWaveIcon, DocumentTextIcon } from '@heroicons/react/24/outline'
import FileUpload from '@/components/FileUpload'
import ProgressBar from '@/components/ProgressBar'
import TranscriptionResult from '@/components/TranscriptionResult'
import { useTranscription } from '@/hooks/useTranscription'
import toast from 'react-hot-toast'

export default function HomePage() {
  const {
    uploadFile,
    startTranscription,
    transcriptionState,
    uploadProgress,
    isUploading,
    isTranscribing,
    reset
  } = useTranscription()

  const [uploadedFile, setUploadedFile] = useState<File | null>(null)

  const handleFileUpload = useCallback(async (file: File) => {
    try {
      setUploadedFile(file)
      const result = await uploadFile(file)
      
      if (result.success) {
        toast.success('File uploaded successfully!')
        // Automatically start transcription
        await startTranscription(result.data.gcs_uri, {
          extract_audio: file.type.startsWith('video/'),
          enable_punctuation: true,
          enable_diarization: false
        })
      } else {
        toast.error(result.error || 'Failed to upload file')
      }
    } catch (error) {
      console.error('Upload error:', error)
      toast.error('An unexpected error occurred during upload')
    }
  }, [uploadFile, startTranscription])

  const handleNewUpload = useCallback(() => {
    reset()
    setUploadedFile(null)
  }, [reset])

  const features = [
    {
      name: 'Fast Upload',
      description: 'Upload audio and video files up to 500MB in size with progress tracking.',
      icon: CloudArrowUpIcon,
    },
    {
      name: 'Audio Extraction',
      description: 'Automatically extract audio from video files for transcription.',
      icon: SpeakerWaveIcon,
    },
    {
      name: 'Dutch Transcription',
      description: 'High-quality Dutch speech transcription using Google Cloud AI.',
      icon: DocumentTextIcon,
    },
  ]

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

        {/* Upload section */}
        <div className="mt-16">
          <div className="mx-auto max-w-3xl">
            {!transcriptionState.jobId && !isUploading && !isTranscribing && (
              <div className="card">
                <FileUpload onFileSelect={handleFileUpload} />
              </div>
            )}

            {/* Upload progress */}
            {isUploading && (
              <div className="card">
                <div className="text-center">
                  <h3 className="text-lg font-medium text-gray-900 mb-4">
                    Uploading {uploadedFile?.name}...
                  </h3>
                  <ProgressBar 
                    progress={uploadProgress} 
                    className="mb-4"
                  />
                  <p className="text-sm text-gray-500">
                    {uploadProgress}% complete
                  </p>
                </div>
              </div>
            )}

            {/* Transcription progress */}
            {(isTranscribing || transcriptionState.jobId) && (
              <div className="space-y-6">
                <div className="card">
                  <ProgressBar 
                    transcriptionState={transcriptionState}
                    className="mb-4"
                  />
                </div>

                {/* Transcription result */}
                {transcriptionState.transcript && (
                  <TranscriptionResult 
                    transcriptionState={transcriptionState}
                    onNewUpload={handleNewUpload}
                  />
                )}

                {/* New upload button for completed/failed states */}
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