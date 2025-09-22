'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { 
  DocumentTextIcon, 
  ClipboardDocumentIcon, 
  ArrowDownTrayIcon,
  SpeakerWaveIcon,
  ClockIcon
} from '@heroicons/react/24/outline'
import { CheckIcon } from '@heroicons/react/24/solid'
import clsx from 'clsx'
import toast from 'react-hot-toast'
import type { TranscriptionState } from '@/types/transcription'

interface TranscriptionResultProps {
  transcriptionState: TranscriptionState
  onNewUpload?: () => void
  className?: string
}

export default function TranscriptionResult({ 
  transcriptionState, 
  onNewUpload,
  className 
}: TranscriptionResultProps) {
  const [copied, setCopied] = useState(false)
  const [isExpanded, setIsExpanded] = useState(false)

  const { transcript, jobId, createdAt, completedAt, gcsUri } = transcriptionState

  if (!transcript) {
    return null
  }

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(transcript)
      setCopied(true)
      toast.success('Transcript copied to clipboard!')
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      toast.error('Failed to copy to clipboard')
    }
  }

  const downloadTranscript = () => {
    const blob = new Blob([transcript], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `transcript-${jobId}.txt`
    document.body.appendChild(a)
    a.click()
    document.body.removeChild(a)
    URL.revokeObjectURL(url)
    toast.success('Transcript downloaded!')
  }

  const formatDuration = () => {
    if (!createdAt || !completedAt) return null
    const duration = new Date(completedAt).getTime() - new Date(createdAt).getTime()
    const seconds = Math.floor(duration / 1000)
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    
    if (minutes > 0) {
      return `${minutes}m ${remainingSeconds}s`
    }
    return `${remainingSeconds}s`
  }

  const truncatedTranscript = transcript.length > 300 
    ? transcript.substring(0, 300) + '...'
    : transcript

  const shouldShowExpand = transcript.length > 300

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5 }}
      className={clsx('card', className)}
    >
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center space-x-3">
          <div className="flex-shrink-0">
            <DocumentTextIcon className="h-6 w-6 text-primary-600" />
          </div>
          <div>
            <h3 className="text-lg font-medium text-gray-900">
              Transcription Complete
            </h3>
            <div className="flex items-center space-x-4 text-sm text-gray-500 mt-1">
              {formatDuration() && (
                <div className="flex items-center space-x-1">
                  <ClockIcon className="h-4 w-4" />
                  <span>Completed in {formatDuration()}</span>
                </div>
              )}
              <div className="flex items-center space-x-1">
                <SpeakerWaveIcon className="h-4 w-4" />
                <span>{transcript.split(' ').length} words</span>
              </div>
            </div>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex items-center space-x-2">
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={copyToClipboard}
            className={clsx(
              'inline-flex items-center px-3 py-2 rounded-lg text-sm font-medium transition-colors duration-200',
              copied
                ? 'bg-success-100 text-success-700'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
            )}
          >
            {copied ? (
              <>
                <CheckIcon className="h-4 w-4 mr-1" />
                Copied
              </>
            ) : (
              <>
                <ClipboardDocumentIcon className="h-4 w-4 mr-1" />
                Copy
              </>
            )}
          </motion.button>

          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={downloadTranscript}
            className="inline-flex items-center px-3 py-2 bg-primary-100 text-primary-700 rounded-lg text-sm font-medium hover:bg-primary-200 transition-colors duration-200"
          >
            <ArrowDownTrayIcon className="h-4 w-4 mr-1" />
            Download
          </motion.button>
        </div>
      </div>

      {/* Transcript content */}
      <div className="relative">
        <div className="bg-gray-50 rounded-lg p-4 border">
          <div className="prose prose-sm max-w-none">
            <p className="text-gray-800 leading-relaxed whitespace-pre-wrap">
              {isExpanded ? transcript : truncatedTranscript}
            </p>
          </div>
          
          {/* Expand/Collapse button */}
          {shouldShowExpand && (
            <motion.button
              whileHover={{ scale: 1.02 }}
              whileTap={{ scale: 0.98 }}
              onClick={() => setIsExpanded(!isExpanded)}
              className="mt-3 text-sm font-medium text-primary-600 hover:text-primary-500 transition-colors duration-200"
            >
              {isExpanded ? 'Show less' : 'Show more'}
            </motion.button>
          )}
        </div>

        {/* Gradient overlay for truncated text */}
        {shouldShowExpand && !isExpanded && (
          <div className="absolute bottom-0 left-0 right-0 h-8 bg-gradient-to-t from-gray-50 to-transparent pointer-events-none" />
        )}
      </div>

      {/* Metadata */}
      <div className="mt-6 pt-4 border-t border-gray-200">
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 text-sm">
          <div>
            <span className="font-medium text-gray-500">Job ID:</span>
            <span className="ml-2 font-mono text-gray-700">{jobId}</span>
          </div>
          
          {createdAt && (
            <div>
              <span className="font-medium text-gray-500">Created:</span>
              <span className="ml-2 text-gray-700">
                {new Date(createdAt).toLocaleString()}
              </span>
            </div>
          )}
          
          {completedAt && (
            <div>
              <span className="font-medium text-gray-500">Completed:</span>
              <span className="ml-2 text-gray-700">
                {new Date(completedAt).toLocaleString()}
              </span>
            </div>
          )}
          
          <div>
            <span className="font-medium text-gray-500">Language:</span>
            <span className="ml-2 text-gray-700">Dutch (nl-NL)</span>
          </div>
        </div>
      </div>

      {/* New upload button */}
      {onNewUpload && (
        <div className="mt-6 pt-4 border-t border-gray-200 text-center">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            onClick={onNewUpload}
            className="btn-outline"
          >
            Transcribe Another File
          </motion.button>
        </div>
      )}
    </motion.div>
  )
}