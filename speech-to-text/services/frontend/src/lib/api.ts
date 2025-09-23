import axios, { AxiosResponse } from 'axios'
import type {
  UploadResult,
  TranscriptionRequest,
  TranscriptionResponse,
  TranscriptionStatusResponse,
  RecognizerRequest,
  RecognizerResponse,
  SignedUrlResponse
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
    if (error.response?.status === 413 || error.response?.status === 400) {
      throw new Error('File too large. Maximum size is 5GB.')
    } else if (error.response?.status === 429) {
      throw new Error('Too many requests. Please try again later.')
    } else if (error.response?.status >= 500) {
      throw new Error('Server error. Please try again later.')
    } else if (error.code === 'ECONNABORTED') {
      throw new Error('Request timeout. Please try again.')
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
