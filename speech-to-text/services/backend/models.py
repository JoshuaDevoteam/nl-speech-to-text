"""Pydantic models for API requests and responses."""

from typing import Optional, List, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field


class TranscriptWord(BaseModel):
    """Word-level detail for a transcript segment."""

    word: str
    start_seconds: Optional[float] = None
    end_seconds: Optional[float] = None
    confidence: Optional[float] = None


class TranscriptSegment(BaseModel):
    """Segment-level transcription data with timing and confidence."""

    segment_id: Optional[int] = Field(None, description="Sequential segment index")
    start_seconds: Optional[float] = Field(None, description="Segment start time in seconds")
    end_seconds: Optional[float] = Field(None, description="Segment end time in seconds")
    confidence: Optional[float] = Field(None, description="Confidence score (0-1)")
    text: str = Field(..., description="Transcript text for the segment")
    words: Optional[List[TranscriptWord]] = Field(None, description="Word-level details")
    refined_text: Optional[str] = Field(None, description="Refined text variant for this segment")


class TranscriptionRequest(BaseModel):
    """Request model for starting a transcription job."""
    
    gcs_uri: str = Field(..., description="GCS URI of the audio/video file")
    language_code: Optional[str] = Field("nl-NL", description="Language code for transcription")
    recognizer_id: Optional[str] = Field(None, description="Existing recognizer ID to use")
    extract_audio: bool = Field(False, description="Extract audio from video file")
    enable_punctuation: bool = Field(True, description="Enable automatic punctuation")
    enable_diarization: bool = Field(False, description="Enable speaker diarization")
    enable_speaker_identification: bool = Field(False, description="Enable LLM-based speaker identification")
    min_speaker_count: Optional[int] = Field(2, description="Minimum number of speakers")
    max_speaker_count: Optional[int] = Field(10, description="Maximum number of speakers")


class TranscriptionResponse(BaseModel):
    """Response model for transcription job creation."""
    
    job_id: str = Field(..., description="Unique job identifier")
    status: str = Field(..., description="Job status")
    message: str = Field(..., description="Status message")


class TranscriptionStatus(BaseModel):
    """Model for transcription job status."""
    
    job_id: str = Field(..., description="Unique job identifier")
    status: str = Field(..., description="Current job status")
    progress: int = Field(0, description="Progress percentage")
    created_at: datetime = Field(..., description="Job creation timestamp")
    started_at: Optional[datetime] = Field(None, description="Job start timestamp")
    completed_at: Optional[datetime] = Field(None, description="Job completion timestamp")
    transcript: Optional[str] = Field(None, description="Transcription result")
    transcript_uri: Optional[str] = Field(None, description="GCS URI of saved transcript")
    transcript_segments: Optional[List[TranscriptSegment]] = Field(None, description="Segmented transcript with timing and confidence")
    speaker_identified_transcript: Optional[str] = Field(None, description="Transcript with speaker identification")
    speaker_identification_summary: Optional[Dict[str, Any]] = Field(None, description="Speaker identification summary")
    refined_transcript: Optional[str] = Field(None, description="Lightly improved transcript text")
    error: Optional[str] = Field(None, description="Error message if failed")


class RecognizerRequest(BaseModel):
    """Request model for creating or getting a recognizer."""
    
    recognizer_id: Optional[str] = Field(None, description="Recognizer ID (auto-generated if not provided)")
    language_codes: List[str] = Field(["nl-NL"], description="Supported language codes")
    model: str = Field("chirp_3", description="Speech recognition model to use")
    enable_automatic_punctuation: bool = Field(True, description="Enable automatic punctuation")


class RecognizerResponse(BaseModel):
    """Response model for recognizer creation/retrieval."""
    
    recognizer_id: str = Field(..., description="Recognizer ID")
    created: bool = Field(..., description="Whether a new recognizer was created")
    message: str = Field(..., description="Status message")


class UploadResponse(BaseModel):
    """Response model for file upload."""
    
    gcs_uri: str = Field(..., description="GCS URI of uploaded file")
    filename: str = Field(..., description="Unique filename in GCS")
    original_filename: str = Field(..., description="Original uploaded filename")
    size: Optional[int] = Field(None, description="File size in bytes")
    content_type: Optional[str] = Field(None, description="MIME type of the file")


class JobStatus(BaseModel):
    """Internal model for tracking job status."""
    
    job_id: str
    status: str  # pending, processing, extracting_audio, transcribing, identifying_speakers, completed, failed
    created_at: datetime
    started_at: Optional[datetime] = None
    completed_at: Optional[datetime] = None
    gcs_uri: str
    transcript: Optional[str] = None
    transcript_uri: Optional[str] = None
    transcript_segments: Optional[List[TranscriptSegment]] = None
    speaker_identified_transcript: Optional[str] = None
    speaker_identification_summary: Optional[Dict[str, Any]] = None
    refined_transcript: Optional[str] = None
    error: Optional[str] = None


class SignedUrlResponse(BaseModel):
    """Response model for signed URL generation."""
    
    signed_url: str = Field(..., description="Signed URL for direct upload")
    filename: str = Field(..., description="Unique filename to use")
    expires_in: int = Field(..., description="URL expiration time in seconds")
    gcs_uri: str = Field(..., description="Final GCS URI after upload")


class WebSocketMessage(BaseModel):
    """WebSocket message format."""
    
    type: str = Field(..., description="Message type")
    job_id: Optional[str] = Field(None, description="Associated job ID")
    status: Optional[str] = Field(None, description="Job status")
    progress: Optional[int] = Field(None, description="Progress percentage")
    message: Optional[str] = Field(None, description="Status message")
    data: Optional[Dict[str, Any]] = Field(None, description="Additional data")


class ErrorResponse(BaseModel):
    """Error response model."""
    
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error information")
    status_code: int = Field(..., description="HTTP status code")
