'use client'

import { motion } from 'framer-motion'
import clsx from 'clsx'
import { CheckCircleIcon, ExclamationCircleIcon } from '@heroicons/react/24/solid'
import type { TranscriptionState } from '@/types/transcription'

interface ProgressBarProps {
  progress?: number
  transcriptionState?: TranscriptionState
  className?: string
  showDetails?: boolean
}

export default function ProgressBar({ 
  progress, 
  transcriptionState,
  className,
  showDetails = true
}: ProgressBarProps) {
  // Determine progress from transcriptionState if not provided directly
  const currentProgress = progress ?? transcriptionState?.progress ?? 0
  const status = transcriptionState?.status
  const message = transcriptionState?.message

  const getStatusColor = () => {
    switch (status) {
      case 'completed':
        return 'bg-success-500'
      case 'failed':
        return 'bg-error-500'
      case 'processing':
      case 'extracting_audio':
      case 'transcribing':
        return 'bg-primary-500'
      default:
        return 'bg-secondary-400'
    }
  }

  const getStatusIcon = () => {
    switch (status) {
      case 'completed':
        return <CheckCircleIcon className="h-5 w-5 text-success-500" />
      case 'failed':
        return <ExclamationCircleIcon className="h-5 w-5 text-error-500" />
      default:
        return null
    }
  }

  const getStatusMessage = () => {
    if (message) return message
    
    switch (status) {
      case 'pending':
        return 'Preparing transcription...'
      case 'extracting_audio':
        return 'Extracting audio from video...'
      case 'processing':
        return 'Processing file...'
      case 'transcribing':
        return 'Transcribing speech...'
      case 'completed':
        return 'Transcription completed successfully!'
      case 'failed':
        return 'Transcription failed. Please try again.'
      default:
        return 'Uploading file...'
    }
  }

  const isCompleted = status === 'completed'
  const isFailed = status === 'failed'
  const isProcessing = status && ['processing', 'extracting_audio', 'transcribing'].includes(status)

  return (
    <div className={clsx('w-full', className)}>
      {/* Progress bar container */}
      <div className="progress-bar">
        <motion.div
          className={clsx(
            'progress-bar-fill',
            getStatusColor()
          )}
          initial={{ width: 0 }}
          animate={{ width: `${currentProgress}%` }}
          transition={{ 
            duration: 0.5, 
            ease: 'easeOut',
            type: 'spring',
            stiffness: 100,
            damping: 15
          }}
        />
        
        {/* Animated shimmer effect for active progress */}
        {isProcessing && currentProgress < 100 && (
          <motion.div
            className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent"
            animate={{ x: [-100, 300] }}
            transition={{
              duration: 1.5,
              repeat: Infinity,
              ease: 'linear'
            }}
          />
        )}
      </div>

      {/* Progress details */}
      {showDetails && (
        <div className="mt-3 flex items-center justify-between">
          <div className="flex items-center space-x-2">
            {getStatusIcon()}
            <span className={clsx(
              'text-sm font-medium',
              {
                'text-success-600': isCompleted,
                'text-error-600': isFailed,
                'text-primary-600': isProcessing,
                'text-gray-600': !status
              }
            )}>
              {getStatusMessage()}
            </span>
          </div>
          
          <span className="text-sm font-medium text-gray-500">
            {currentProgress}%
          </span>
        </div>
      )}

      {/* Status-specific animations */}
      {isProcessing && (
        <div className="mt-2 flex justify-center">
          <div className="flex space-x-1">
            <motion.div
              className="w-2 h-2 bg-primary-500 rounded-full animate-wave"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 1, repeat: Infinity, delay: 0 }}
            />
            <motion.div
              className="w-2 h-2 bg-primary-500 rounded-full animate-wave"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 1, repeat: Infinity, delay: 0.2 }}
            />
            <motion.div
              className="w-2 h-2 bg-primary-500 rounded-full animate-wave"
              animate={{ scale: [1, 1.2, 1] }}
              transition={{ duration: 1, repeat: Infinity, delay: 0.4 }}
            />
          </div>
        </div>
      )}

      {/* Completion celebration */}
      {isCompleted && (
        <motion.div
          initial={{ scale: 0, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ delay: 0.2, type: 'spring', stiffness: 200 }}
          className="mt-2 text-center"
        >
          <motion.div
            animate={{ rotate: [0, 10, -10, 0] }}
            transition={{ duration: 0.5, delay: 0.5 }}
          >
            🎉
          </motion.div>
        </motion.div>
      )}

      {/* Error state */}
      {isFailed && transcriptionState?.error && (
        <motion.div
          initial={{ opacity: 0, height: 0 }}
          animate={{ opacity: 1, height: 'auto' }}
          className="mt-3 p-3 bg-error-50 border border-error-200 rounded-lg"
        >
          <p className="text-sm text-error-600">
            <strong>Error:</strong> {transcriptionState.error}
          </p>
        </motion.div>
      )}
    </div>
  )
}