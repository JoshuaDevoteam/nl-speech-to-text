'use client'

import { useState, useEffect } from 'react'
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

  const { 
    transcript, 
    transcriptSegments,
    speakerIdentifiedTranscript,
    speakerIdentificationSummary,
    refinedTranscript,
    jobId, 
    createdAt, 
    completedAt, 
    gcsUri 
  } = transcriptionState

  if (!transcript) {
    return null
  }

  const baseTranscript = transcript || ''
  const hasRefinedTranscript = !!refinedTranscript && refinedTranscript.trim() && refinedTranscript.trim() !== baseTranscript.trim()
  const [transcriptView, setTranscriptView] = useState<'original' | 'refined'>('original')
  const segments = transcriptSegments || []

  useEffect(() => {
    if (!hasRefinedTranscript) {
      setTranscriptView('original')
    }
  }, [hasRefinedTranscript])

  useEffect(() => {
    setCopied(false)
  }, [transcriptView, transcript])

  const isRefinedView = transcriptView === 'refined' && hasRefinedTranscript
  const displayTranscript = isRefinedView ? refinedTranscript! : baseTranscript
  const hasSpeakerIdentification = !!speakerIdentifiedTranscript
  const wordCount = displayTranscript ? displayTranscript.trim().split(/\s+/).filter(Boolean).length : 0

  const formatTimecode = (seconds?: number | null) => {
    if (seconds == null || Number.isNaN(seconds)) return '—'
    const totalSeconds = Math.max(0, seconds)
    const hours = Math.floor(totalSeconds / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const secs = totalSeconds % 60
    const secondsWhole = Math.floor(secs)
    const decimals = Math.round((secs - secondsWhole) * 10)
    const secondsPart = `${secondsWhole.toString().padStart(2, '0')}.${decimals}`

    if (hours > 0) {
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${secondsPart}`
    }

    return `${minutes.toString().padStart(2, '0')}:${secondsPart}`
  }

  const formatTimeRange = (start?: number | null, end?: number | null) => {
    if (start == null && end == null) return '—'
    const safeStart = start ?? end ?? 0
    const safeEnd = end ?? start ?? safeStart
    return `${formatTimecode(safeStart)} – ${formatTimecode(safeEnd)}`
  }

  const copyToClipboard = async (textOverride?: string) => {
    try {
      const content = textOverride ?? displayTranscript
      if (!content) {
        toast.error('Nothing to copy yet')
        return
      }

      await navigator.clipboard.writeText(content)
      setCopied(true)
      toast.success('Transcript copied to clipboard!')
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      toast.error('Failed to copy to clipboard')
    }
  }

  const downloadTranscript = (options?: { text?: string; suffix?: string }) => {
    const content = options?.text ?? displayTranscript
    if (!content) {
      toast.error('Nothing to download yet')
      return
    }

    const blob = new Blob([content], { type: 'text/plain' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    const suffix = options?.suffix ?? (isRefinedView ? '-refined' : '')
    a.download = `transcript-${jobId}${suffix}.txt`
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

  const truncatedTranscript = displayTranscript.length > 300 
    ? displayTranscript.substring(0, 300) + '...'
    : displayTranscript

  const shouldShowExpand = displayTranscript.length > 300

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
                <span>{wordCount} words</span>
              </div>
            </div>
          </div>
        </div>

        {/* Action buttons */}
        <div className="flex items-center space-x-2">
          {hasRefinedTranscript && (
            <div className="flex items-center rounded-full bg-gray-100 p-0.5 mr-1">
              <button
                type="button"
                onClick={() => setTranscriptView('original')}
                className={clsx(
                  'px-2 py-1 text-xs font-medium rounded-full transition-colors duration-200',
                  transcriptView === 'original'
                    ? 'bg-white text-gray-900 shadow'
                    : 'text-gray-600 hover:text-gray-900'
                )}
              >
                Original
              </button>
              <button
                type="button"
                onClick={() => setTranscriptView('refined')}
                className={clsx(
                  'px-2 py-1 text-xs font-medium rounded-full transition-colors duration-200',
                  transcriptView === 'refined'
                    ? 'bg-white text-primary-600 shadow'
                    : 'text-gray-600 hover:text-gray-900'
                )}
              >
                Refined
              </button>
            </div>
          )}
          <motion.button
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            onClick={() => copyToClipboard()}
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
            onClick={() => downloadTranscript()}
            className="inline-flex items-center px-3 py-2 bg-primary-100 text-primary-700 rounded-lg text-sm font-medium hover:bg-primary-200 transition-colors duration-200"
          >
            <ArrowDownTrayIcon className="h-4 w-4 mr-1" />
            Download
          </motion.button>
        </div>
      </div>

      {/* Transcript segments */}
      {segments.length > 0 ? (
        <div className="mt-6">
          <h4 className="text-sm font-medium text-gray-900 mb-3">Transcript Segments</h4>
          <div className="overflow-x-auto rounded-lg border border-gray-200">
            <table className="min-w-full divide-y divide-gray-200 text-sm">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="px-4 py-2 font-medium text-gray-600">Time</th>
                  <th scope="col" className="px-4 py-2 font-medium text-gray-600">Confidence</th>
                  <th scope="col" className="px-4 py-2 font-medium text-gray-600">Text</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {segments.map((segment, index) => (
                  <tr key={`${segment.start_seconds ?? 0}-${index}`} className="hover:bg-gray-50">
                    <td className="whitespace-nowrap px-4 py-3 text-gray-700 font-mono text-xs">
                      {formatTimeRange(segment.start_seconds, segment.end_seconds)}
                    </td>
                    <td className="whitespace-nowrap px-4 py-3 text-gray-700">
                      {segment.confidence != null ? segment.confidence.toFixed(2) : '—'}
                    </td>
                    <td className="px-4 py-3 text-gray-800">
                      {segment.text}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      ) : (
        <p className="mt-6 text-sm text-gray-500">
          Timing and confidence data were not provided for this transcript.
        </p>
      )}

      {/* Transcript content */}
      <div className="relative mt-6">
        <div className="bg-gray-50 rounded-lg p-4 border">
          {hasRefinedTranscript && (
            <p className="mb-3 text-xs text-gray-500">
              {isRefinedView
                ? 'Viewing refined transcript with light LLM cleanup.'
                : 'Viewing the original transcript returned by the Speech API.'}
            </p>
          )}
          <div className="prose prose-sm max-w-none">
            <p className="text-gray-800 leading-relaxed whitespace-pre-wrap">
              {isExpanded ? displayTranscript : truncatedTranscript}
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

      {/* Speaker Identification Summary */}
      {hasSpeakerIdentification && speakerIdentificationSummary && (
        <div className="mt-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
          <div className="flex items-center space-x-2 mb-3">
            <SpeakerWaveIcon className="h-5 w-5 text-blue-600" />
            <h4 className="text-sm font-medium text-blue-900">Speaker Identification</h4>
          </div>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 text-sm">
            <div>
              <span className="font-medium text-blue-700">Speakers Detected:</span>
              <span className="ml-2 text-blue-900">{speakerIdentificationSummary.total_speakers}</span>
            </div>
            <div>
              <span className="font-medium text-blue-700">Confidence:</span>
              <span className={`ml-2 ${
                speakerIdentificationSummary.confidence === 'high' 
                  ? 'text-green-700' 
                  : speakerIdentificationSummary.confidence === 'medium'
                    ? 'text-yellow-700'
                    : 'text-red-700'
              }`}>
                {speakerIdentificationSummary.confidence}
              </span>
            </div>
            <div>
              <span className="font-medium text-blue-700">Speakers:</span>
              <span className="ml-2 text-blue-900">
                {speakerIdentificationSummary.speakers.join(', ')}
              </span>
            </div>
          </div>
          {speakerIdentificationSummary.notes && (
            <div className="mt-3 text-xs text-blue-600">
              <strong>Note:</strong> {speakerIdentificationSummary.notes}
            </div>
          )}

          {speakerIdentifiedTranscript && (
            <div className="mt-4 flex flex-wrap gap-2">
              <motion.button
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
                onClick={() => copyToClipboard(speakerIdentifiedTranscript)}
                className="inline-flex items-center px-3 py-2 rounded-lg bg-blue-100 text-blue-800 text-xs font-medium hover:bg-blue-200 transition-colors duration-200"
              >
                <ClipboardDocumentIcon className="h-4 w-4 mr-1" />
                Copy speaker transcript
              </motion.button>
              <motion.button
                whileHover={{ scale: 1.03 }}
                whileTap={{ scale: 0.97 }}
                onClick={() => downloadTranscript({ text: speakerIdentifiedTranscript, suffix: '-speakers' })}
                className="inline-flex items-center px-3 py-2 rounded-lg bg-blue-600 text-white text-xs font-medium hover:bg-blue-700 transition-colors duration-200"
              >
                <ArrowDownTrayIcon className="h-4 w-4 mr-1" />
                Download speaker transcript
              </motion.button>
            </div>
          )}
        </div>
      )}

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
