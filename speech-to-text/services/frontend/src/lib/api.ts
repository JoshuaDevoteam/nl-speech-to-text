import axios, { AxiosResponse } from 'axios'
import type {
  UploadResult,
  TranscriptionRequest,
  TranscriptionResponse,
  TranscriptionStatusResponse,
  RecognizerRequest,
  RecognizerResponse,
  SignedUrlResponse,
  EnhancedSignedUrlResponse,
  UploadProgress
} from '@/types/transcription'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

// Create axios instance with default configuration
const api = axios.create({
  baseURL: API_BASE_URL,
  timeout: 30 * 60 * 1000, // 30 minutes
  maxBodyLength: Infinity,
  maxContentLength: Infinity,
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor for logging
api.interceptors.request.use(
  (config) => {
    console.log(`API Request: ${config.method?.toUpperCase()} ${config.url}`)
    return config
  },
  (error) => {
    console.error('API Request Error:', error)
    return Promise.reject(error)
  }
)

// Response interceptor for error handling
api.interceptors.response.use(
  (response) => {
    return response
  },
  (error) => {
    console.error('API Response Error:', error)
    
    // Handle common error cases
    if (error.response?.status === 413) {
      throw new Error('File too large for direct upload. Try using the resumable upload option or ensure your file is under 5GB.')
    } else if (error.response?.status === 400) {
      const detail = error.response?.data?.detail || error.message
      if (detail.includes('too large')) {
        throw new Error('File exceeds the 5GB maximum size limit.')
      } else if (detail.includes('not supported')) {
        throw new Error('File type not supported. Please use MP3, MP4, WAV, M4A, FLAC, OGG, WEBM, or MOV files.')
      } else {
        throw new Error(detail || 'Invalid file or request. Please check your file and try again.')
      }
    } else if (error.response?.status === 429) {
      throw new Error('Too many requests. Please try again later.')
    } else if (error.response?.status >= 500) {
      throw new Error('Server error. Please try again later.')
    } else if (error.code === 'ECONNABORTED') {
      throw new Error('Request timeout. Please try again with a smaller file or check your connection.')
    } else if (error.code === 'ERR_NETWORK') {
      throw new Error('Network error. Please check your internet connection and try again.')
    }
    
    throw error
  }
)

export class ApiClient {
  /**
   * Upload a file to the backend
   */
  static async uploadFile(
    file: File,
    onProgress?: (progress: { percent: number; loaded: number; total?: number }) => void
  ): Promise<UploadResult> {
    try {
      const formData = new FormData()
      formData.append('file', file)

      const response: AxiosResponse = await api.post('/api/v1/upload', formData, {
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        onUploadProgress: (progressEvent) => {
          const total = progressEvent.total ?? file.size ?? undefined
          const loaded = progressEvent.loaded
          let percentCompleted: number

          if (total && total > 0) {
            percentCompleted = Math.round((loaded * 100) / total)
          } else if (file.size) {
            percentCompleted = Math.round((loaded * 100) / file.size)
          } else {
            percentCompleted = 0
          }

          percentCompleted = Math.min(percentCompleted, 100)
          console.log(`Upload progress: ${percentCompleted}%`)
          onProgress?.({ percent: percentCompleted, loaded, total })
        },
      })

      return {
        success: true,
        data: response.data,
      }
    } catch (error: any) {
      console.error('Upload error:', error)
      return {
        success: false,
        error: error.response?.data?.detail || error.message || 'Upload failed',
      }
    }
  }

  /**
   * Start a transcription job
   */
  static async startTranscription(
    request: TranscriptionRequest
  ): Promise<TranscriptionResponse> {
    const response: AxiosResponse<TranscriptionResponse> = await api.post(
      '/api/v1/transcribe',
      request
    )
    return response.data
  }

  /**
   * Get transcription status and results
   */
  static async getTranscriptionStatus(
    jobId: string
  ): Promise<TranscriptionStatusResponse> {
    const response: AxiosResponse<TranscriptionStatusResponse> = await api.get(
      `/api/v1/transcription/${jobId}`
    )
    return response.data
  }

  /**
   * Delete a transcription job
   */
  static async deleteTranscription(jobId: string): Promise<void> {
    await api.delete(`/api/v1/transcription/${jobId}`)
  }

  /**
   * Create or get a recognizer
   */
  static async createRecognizer(
    request: RecognizerRequest
  ): Promise<RecognizerResponse> {
    const response: AxiosResponse<RecognizerResponse> = await api.post(
      '/api/v1/recognizer',
      request
    )
    return response.data
  }

  /**
   * Get a signed URL for direct file upload
   */
  static async getSignedUploadUrl(
    filename: string
  ): Promise<SignedUrlResponse> {
    const response: AxiosResponse<SignedUrlResponse> = await api.get(
      `/api/v1/signed-url?filename=${encodeURIComponent(filename)}`
    )
    return response.data
  }

  /**
   * Get enhanced upload options with both signed URL and resumable upload
   */
  static async getUploadOptions(
    filename: string,
    fileSize?: number,
    contentType?: string,
    forceResumable = false
  ): Promise<EnhancedSignedUrlResponse> {
    const params = new URLSearchParams({
      filename: filename,
      ...(fileSize && { file_size: fileSize.toString() }),
      ...(contentType && { content_type: contentType }),
      ...(forceResumable && { resumable: 'true' })
    })

    const response: AxiosResponse<EnhancedSignedUrlResponse> = await api.get(
      `/api/v1/signed-url?${params}`
    )
    return response.data
  }

  /**
   * Upload file directly to GCS using signed URL
   */
  static async uploadToSignedUrl(
    signedUrl: string,
    file: File,
    onProgress?: (progress: number) => void
  ): Promise<void> {
    await axios.put(signedUrl, file, {
      headers: {
        'Content-Type': file.type,
      },
      onUploadProgress: (progressEvent) => {
        if (progressEvent.total && onProgress) {
          const percentCompleted = Math.round(
            (progressEvent.loaded * 100) / progressEvent.total
          )
          onProgress(percentCompleted)
        }
      },
    })
  }

  /**
   * Upload file using resumable upload for large files
   */
  static async uploadResumable(
    resumableUrl: string,
    file: File,
    headers: Record<string, string>,
    chunkSize = 8 * 1024 * 1024, // 8MB default
    onProgress?: (progress: UploadProgress) => void
  ): Promise<string> {
    // Initiate resumable upload session
    onProgress?.({ percent: 0, loaded: 0, total: file.size, stage: 'preparing' })
    
    const initResponse = await axios.post(resumableUrl, null, {
      headers: {
        ...headers
      }
    })

    const sessionUrl = initResponse.headers['location']
    if (!sessionUrl) {
      throw new Error('Failed to get resumable upload session URL')
    }

    // Upload file in chunks
    onProgress?.({ percent: 0, loaded: 0, total: file.size, stage: 'uploading' })
    
    const totalSize = file.size
    let uploaded = 0

    while (uploaded < totalSize) {
      const chunk = file.slice(uploaded, Math.min(uploaded + chunkSize, totalSize))
      const chunkEnd = uploaded + chunk.size - 1

      const response = await axios.put(sessionUrl, chunk, {
        headers: {
          'Content-Range': `bytes ${uploaded}-${chunkEnd}/${totalSize}`,
          'Content-Type': file.type,
        },
        // GCS returns 308 for intermediate chunks; treat that as success
        validateStatus: (status) => {
          if (!status) return false
          return (status >= 200 && status < 300) || status === 308
        },
        onUploadProgress: (progressEvent) => {
          const chunkProgress = progressEvent.loaded
          const totalProgress = uploaded + chunkProgress
          const percentCompleted = Math.round((totalProgress * 100) / totalSize)
          
          onProgress?.({
            percent: percentCompleted,
            loaded: totalProgress,
            total: totalSize,
            stage: 'uploading'
          })
        },
      })

      if (response.status === 308) {
        const range = response.headers['range'] || response.headers['Range']
        if (range) {
          const match = /bytes=0-(\d+)/.exec(range)
          if (match) {
            uploaded = parseInt(match[1], 10) + 1
          } else {
            uploaded += chunk.size
          }
        } else {
          uploaded += chunk.size
        }
      } else {
        uploaded = Math.min(totalSize, uploaded + chunk.size)
      }
    }

    onProgress?.({ percent: 100, loaded: totalSize, total: totalSize, stage: 'completing' })
    return sessionUrl
  }

  /**
   * Smart file upload that automatically chooses the best upload method
   */
  static async uploadFileSmart(
    file: File,
    onProgress?: (progress: UploadProgress) => void
  ): Promise<{ gcs_uri: string; filename: string }> {
    try {
      onProgress?.({ percent: 0, loaded: 0, total: file.size, stage: 'preparing' })

      // Get upload options from backend
      const uploadOptions = await this.getUploadOptions(
        file.name,
        file.size,
        file.type
      )

      const useResumable = uploadOptions.recommended_method === 'resumable_upload' ||
                          file.size >= 100 * 1024 * 1024 // 100MB threshold

      if (useResumable && uploadOptions.upload_options.resumable_upload) {
        // Use resumable upload for large files
        const resumableInfo = uploadOptions.upload_options.resumable_upload
        await this.uploadResumable(
          resumableInfo.resumable_url,
          file,
          resumableInfo.headers,
          resumableInfo.chunk_size,
          onProgress
        )
      } else if (uploadOptions.upload_options.signed_url) {
        // Use regular signed URL for smaller files
        const signedUrlInfo = uploadOptions.upload_options.signed_url
        await axios.put(signedUrlInfo.url, file, {
          headers: signedUrlInfo.headers,
          onUploadProgress: (progressEvent) => {
            if (progressEvent.total) {
              const percentCompleted = Math.round(
                (progressEvent.loaded * 100) / progressEvent.total
              )
              onProgress?.({
                percent: percentCompleted,
                loaded: progressEvent.loaded,
                total: progressEvent.total,
                stage: 'uploading'
              })
            }
          },
        })
      } else {
        throw new Error('No upload method available')
      }

      onProgress?.({ percent: 100, loaded: file.size, total: file.size, stage: 'completing' })

      return {
        gcs_uri: uploadOptions.gcs_uri,
        filename: uploadOptions.filename
      }
    } catch (error: any) {
      console.error('Smart upload error:', error)
      throw new Error(error.response?.data?.detail || error.message || 'Upload failed')
    }
  }

  /**
   * Health check
   */
  static async healthCheck(): Promise<{ status: string }> {
    const response: AxiosResponse<{ status: string }> = await api.get('/')
    return response.data
  }
}

/**
 * WebSocket connection for real-time updates
 */
export class WebSocketClient {
  private ws: WebSocket | null = null
  private jobId: string
  private onMessage: (data: any) => void
  private onError: (error: Event) => void
  private onClose: () => void
  private reconnectAttempts = 0
  private maxReconnectAttempts = 5
  private reconnectDelay = 1000
  private shouldReconnect = true

  constructor(
    jobId: string,
    onMessage: (data: any) => void,
    onError: (error: Event) => void = () => {},
    onClose: () => void = () => {}
  ) {
    this.jobId = jobId
    this.onMessage = onMessage
    this.onError = onError
    this.onClose = onClose
  }

  connect() {
    this.shouldReconnect = true
    const wsUrl = (process.env.NEXT_PUBLIC_WS_URL || 'ws://localhost:8000')
      .replace('http', 'ws')

    this.ws = new WebSocket(`${wsUrl}/ws/${this.jobId}`)

    this.ws.onopen = () => {
      console.log(`WebSocket connected for job ${this.jobId}`)
      this.reconnectAttempts = 0
    }

    this.ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data)
        this.onMessage(data)
      } catch (error) {
        console.error('Failed to parse WebSocket message:', error)
      }
    }

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error)
      this.onError(error)
    }

    this.ws.onclose = () => {
      console.log(`WebSocket closed for job ${this.jobId}`)
      this.onClose()
      if (this.shouldReconnect) {
        this.attemptReconnect()
      }
    }
  }

  private attemptReconnect() {
    if (this.reconnectAttempts < this.maxReconnectAttempts) {
      this.reconnectAttempts++
      console.log(
        `Attempting to reconnect WebSocket (${this.reconnectAttempts}/${this.maxReconnectAttempts})`
      )
      
      setTimeout(() => {
        this.connect()
      }, this.reconnectDelay * this.reconnectAttempts)
    } else {
      console.error('Max reconnection attempts reached')
    }
  }

  disconnect() {
    this.shouldReconnect = false
    if (this.ws) {
      this.ws.close()
      this.ws = null
    }
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN
  }

  markComplete() {
    this.shouldReconnect = false
  }
}

export default ApiClient
