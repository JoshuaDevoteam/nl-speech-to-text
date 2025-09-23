export interface TranscriptWord {
  word: string
  start_seconds?: number | null
  end_seconds?: number | null
  confidence?: number | null
}

export interface TranscriptSegment {
  segment_id?: number
  start_seconds?: number | null
  end_seconds?: number | null
  confidence?: number | null
  text: string
  words?: TranscriptWord[] | null
  refined_text?: string | null
}

export interface TranscriptionState {
  jobId?: string
  status?: 'pending' | 'processing' | 'extracting_audio' | 'transcribing' | 'identifying_speakers' | 'completed' | 'failed'
  progress?: number
  transcript?: string
  transcriptUri?: string
  transcriptSegments?: TranscriptSegment[]
  speakerIdentifiedTranscript?: string
  speakerIdentificationSummary?: SpeakerIdentificationSummary
  refinedTranscript?: string
  error?: string
  message?: string
  createdAt?: string
  startedAt?: string
  completedAt?: string
  gcsUri?: string
  fileSizeBytes?: number
}

export interface SpeakerIdentificationSummary {
  total_speakers: number
  confidence: 'high' | 'medium' | 'low'
  speakers: string[]
  notes?: string
}

export interface UploadedFileData {
  gcs_uri: string
  filename: string
  original_filename: string
  size?: number
  content_type?: string
}

export type UploadResult =
  | { success: true; data: UploadedFileData }
  | { success: false; error: string }

export interface TranscriptionOptions {
  language_code?: string
  recognizer_id?: string
  extract_audio?: boolean
  enable_punctuation?: boolean
  enable_diarization?: boolean
  enable_speaker_identification?: boolean
  min_speaker_count?: number
  max_speaker_count?: number
}

export interface TranscriptionRequest {
  gcs_uri: string
  language_code?: string
  recognizer_id?: string
  extract_audio?: boolean
  enable_punctuation?: boolean
  enable_diarization?: boolean
  enable_speaker_identification?: boolean
  min_speaker_count?: number
  max_speaker_count?: number
}

export interface TranscriptionResponse {
  job_id: string
  status: string
  message: string
}

export interface TranscriptionStatusResponse {
  job_id: string
  status: string
  progress: number
  created_at: string
  started_at?: string
  completed_at?: string
  gcs_uri: string
  transcript?: string
  transcript_uri?: string
  transcript_segments?: TranscriptSegment[]
  speaker_identified_transcript?: string
  speaker_identification_summary?: SpeakerIdentificationSummary
  refined_transcript?: string
  error?: string
}

export interface WebSocketMessage {
  type: string
  job_id?: string
  status?: string
  progress?: number
  message?: string
  transcript?: string
  data?: Record<string, any>
}

export interface RecognizerRequest {
  recognizer_id?: string
  language_codes?: string[]
  model?: string
  enable_automatic_punctuation?: boolean
}

export interface RecognizerResponse {
  recognizer_id: string
  created: boolean
  message: string
}

export interface SignedUrlResponse {
  signed_url: string
  filename: string
  expires_in: number
  gcs_uri: string
}
