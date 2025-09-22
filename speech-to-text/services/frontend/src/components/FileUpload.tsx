'use client'

import { forwardRef, useCallback, useState } from 'react'
import type { HTMLAttributes } from 'react'
import { useDropzone } from 'react-dropzone'
import { CloudArrowUpIcon, DocumentIcon, FilmIcon } from '@heroicons/react/24/outline'
import { motion } from 'framer-motion'
import clsx from 'clsx'

const MotionDropzone = motion(
  forwardRef<HTMLDivElement, HTMLAttributes<HTMLDivElement>>(
    function MotionDropzone(props, ref) {
      return <div ref={ref} {...props} />
    }
  )
)

interface FileUploadProps {
  onFileSelect: (file: File) => void
  className?: string
  disabled?: boolean
}

export default function FileUpload({ 
  onFileSelect, 
  className,
  disabled = false 
}: FileUploadProps) {
  const [isDragActive, setIsDragActive] = useState(false)

  const onDrop = useCallback((acceptedFiles: File[]) => {
    if (acceptedFiles.length > 0) {
      onFileSelect(acceptedFiles[0])
    }
  }, [onFileSelect])

  const {
    getRootProps,
    getInputProps,
    isDragAccept,
    isDragReject,
    acceptedFiles
  } = useDropzone({
    onDrop,
    accept: {
      'audio/*': ['.mp3', '.wav', '.m4a', '.flac', '.ogg', '.webm'],
      'video/*': ['.mp4', '.mov', '.avi', '.mkv', '.webm']
    },
    maxFiles: 1,
    maxSize: 5 * 1024 * 1024 * 1024, // 5GB
    disabled,
    onDragEnter: () => setIsDragActive(true),
    onDragLeave: () => setIsDragActive(false),
    onDropAccepted: () => setIsDragActive(false),
    onDropRejected: () => setIsDragActive(false),
  })

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  const getFileIcon = (file: File) => {
    if (file.type.startsWith('video/')) {
      return <FilmIcon className="h-8 w-8 text-primary-500" />
    }
    return <DocumentIcon className="h-8 w-8 text-primary-500" />
  }

  const {
    onAnimationStart: _onAnimationStart,
    onAnimationEnd: _onAnimationEnd,
    onDrag: _onDrag,
    onDragStart: _onDragStart,
    onDragEnd: _onDragEnd,
    ...rootProps
  } = getRootProps()

  return (
    <div className={clsx('w-full', className)}>
      <MotionDropzone
        {...rootProps}
        className={clsx(
          'dropzone',
          {
            'drag-active': isDragActive || isDragAccept,
            'drag-reject': isDragReject,
            'opacity-50 cursor-not-allowed': disabled,
          }
        )}
        whileHover={!disabled ? { scale: 1.02 } : undefined}
        whileTap={!disabled ? { scale: 0.98 } : undefined}
        transition={{ type: 'spring', stiffness: 300, damping: 20 }}
      >
        <input {...getInputProps()} />
        
        <div className="flex flex-col items-center justify-center space-y-4">
          <motion.div
            animate={isDragActive ? { scale: 1.1 } : { scale: 1 }}
            transition={{ type: 'spring', stiffness: 300, damping: 20 }}
          >
            <CloudArrowUpIcon className="h-12 w-12 text-primary-500" />
          </motion.div>
          
          <div className="text-center">
            <h3 className="text-lg font-medium text-gray-900">
              {isDragActive ? 'Drop your file here' : 'Upload audio or video file'}
            </h3>
            <p className="text-sm text-gray-500 mt-1">
              Drag and drop your file here, or{' '}
              <span className="text-primary-600 font-medium">browse</span>
            </p>
          </div>
          
          <div className="text-xs text-gray-400 space-y-1">
            <p>Supported formats: MP3, MP4, WAV, M4A, FLAC, OGG, WEBM, MOV</p>
            <p>Maximum file size: 5GB</p>
          </div>
        </div>
      </MotionDropzone>

      {/* File preview */}
      {acceptedFiles.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mt-4 p-4 bg-gray-50 rounded-lg border"
        >
          <h4 className="text-sm font-medium text-gray-900 mb-2">
            Selected File
          </h4>
          <div className="flex items-center space-x-3">
            {getFileIcon(acceptedFiles[0])}
            <div className="flex-1 min-w-0">
              <p className="text-sm font-medium text-gray-900 truncate">
                {acceptedFiles[0].name}
              </p>
              <p className="text-sm text-gray-500">
                {formatFileSize(acceptedFiles[0].size)} • {acceptedFiles[0].type}
              </p>
            </div>
          </div>
        </motion.div>
      )}

      {/* Error handling */}
      {isDragReject && (
        <motion.div
          initial={{ opacity: 0, y: 10 }}
          animate={{ opacity: 1, y: 0 }}
          className="mt-2 p-3 bg-error-50 border border-error-200 rounded-lg"
        >
          <p className="text-sm text-error-600">
            File type not supported or file is too large (max 5GB)
          </p>
        </motion.div>
      )}
    </div>
  )
}
