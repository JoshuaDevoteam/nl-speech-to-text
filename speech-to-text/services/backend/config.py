"""Configuration management for the backend service."""

import os
import json
from typing import List, Optional
from pydantic import field_validator
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""
    
    # Google Cloud Settings
    gcp_project_id: str = os.getenv("GCP_PROJECT_ID", "pj-speech-text-dev")
    gcp_location: str = os.getenv("GCP_LOCATION", "europe-west1")
    gcs_bucket_name: str = os.getenv("GCS_BUCKET_NAME", "pj-speech-text-dev-audio-uploads")
    gcs_transcript_bucket: str = os.getenv("GCS_TRANSCRIPT_BUCKET", "pj-speech-text-dev-transcripts")
    
    # Speech-to-Text Settings
    recognizer_location: str = os.getenv("RECOGNIZER_LOCATION", "europe-west4")
    default_recognizer_id: str = os.getenv("DEFAULT_RECOGNIZER_ID", "dutch-recognizer-3")
    default_language_code: str = os.getenv("DEFAULT_LANGUAGE_CODE", "nl-NL")
    speech_model: str = os.getenv("SPEECH_MODEL", "chirp_2")
    
    # Application Settings
    app_name: str = "speech-to-text-backend"
    app_version: str = "1.0.0"
    debug: bool = os.getenv("DEBUG", "false").lower() == "true"
    port: int = int(os.getenv("PORT", "8000"))
    
    # CORS Settings - Use explicit environment variable handling
    _cors_origins_env: Optional[str] = os.getenv("CORS_ORIGINS")
    _cors_origin_regex_env: Optional[str] = os.getenv("CORS_ORIGIN_REGEX")
    
    @property
    def cors_origins(self) -> List[str]:
        """Get CORS origins from environment or default."""
        if self._cors_origins_env:
            raw_origins = [origin.strip() for origin in self._cors_origins_env.split(';') if origin.strip()]
            # Filter out wildcard patterns; these are handled by regex matching instead
            explicit_origins = [origin for origin in raw_origins if '*' not in origin]
            return explicit_origins
        # Default fallback
        defaults = ["http://localhost:3000", "http://localhost:3001"]
        defaults.append(f"https://speech-frontend-{self.gcp_project_id}.{self.gcp_location}.run.app")
        return defaults

    @property
    def cors_origin_regex(self) -> Optional[str]:
        if self._cors_origin_regex_env:
            return self._cors_origin_regex_env
        return rf"https://speech-frontend-[a-z0-9-]+\.{self.gcp_location}\.run\.app"
    
    # Authentication Settings (optional)
    service_account_path: Optional[str] = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    
    # Redis Settings (for production job storage)
    redis_host: Optional[str] = os.getenv("REDIS_HOST")
    redis_port: int = int(os.getenv("REDIS_PORT", "6379"))
    redis_db: int = int(os.getenv("REDIS_DB", "0"))
    use_redis: bool = os.getenv("USE_REDIS", "false").lower() == "true"
    
    # File Processing Settings
    max_file_size_mb: int = int(os.getenv("MAX_FILE_SIZE_MB", "5120"))
    allowed_audio_formats: List[str] = [".mp3", ".wav", ".m4a", ".flac", ".ogg", ".webm"]
    allowed_video_formats: List[str] = [".mp4", ".mov", ".avi", ".mkv", ".webm"]
    
    # Signed URL Settings
    signed_url_expiration_hours: int = int(os.getenv("SIGNED_URL_EXPIRATION_HOURS", "1"))
    
    # FFmpeg Settings
    ffmpeg_path: str = os.getenv("FFMPEG_PATH", "ffmpeg")
    ffmpeg_audio_codec: str = os.getenv("FFMPEG_AUDIO_CODEC", "pcm_s16le")
    ffmpeg_sample_rate: int = int(os.getenv("FFMPEG_SAMPLE_RATE", "16000"))
    ffmpeg_channels: int = int(os.getenv("FFMPEG_CHANNELS", "1"))
    
    # Transcription Settings
    transcription_timeout_minutes: int = int(os.getenv("TRANSCRIPTION_TIMEOUT_MINUTES", "30"))
    enable_word_time_offsets: bool = os.getenv("ENABLE_WORD_TIME_OFFSETS", "false").lower() == "true"
    enable_word_confidence: bool = os.getenv("ENABLE_WORD_CONFIDENCE", "false").lower() == "true"
    
    # Logging Settings
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    log_format: str = os.getenv("LOG_FORMAT", "json")
    
    class Config:
        """Pydantic config."""
        
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False
        
    def get_allowed_extensions(self) -> List[str]:
        """Get all allowed file extensions."""
        return self.allowed_audio_formats + self.allowed_video_formats
    
    def is_video_file(self, filename: str) -> bool:
        """Check if a file is a video based on extension."""
        ext = os.path.splitext(filename)[1].lower()
        return ext in self.allowed_video_formats
    
    def is_audio_file(self, filename: str) -> bool:
        """Check if a file is audio based on extension."""
        ext = os.path.splitext(filename)[1].lower()
        return ext in self.allowed_audio_formats
    
    def get_max_file_size_bytes(self) -> int:
        """Get maximum file size in bytes."""
        return self.max_file_size_mb * 1024 * 1024
