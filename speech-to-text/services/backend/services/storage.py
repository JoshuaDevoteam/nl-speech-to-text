"""Storage service for Google Cloud Storage operations."""

import os
import asyncio
import tempfile
import subprocess
from datetime import datetime, timedelta
from typing import Optional, BinaryIO
from google.cloud import storage
from google.cloud.storage import Blob


class StorageService:
    """Service for handling Google Cloud Storage operations."""
    
    def __init__(self, settings):
        """Initialize the storage service.
        
        Args:
            settings: Application settings
        """
        self.settings = settings
        self.bucket_name = settings.gcs_bucket_name
        self.transcript_bucket = settings.gcs_transcript_bucket
        self.storage_client = storage.Client(project=settings.gcp_project_id)
        self.bucket = self.storage_client.bucket(self.bucket_name)
        self.transcript_bucket_obj = self.storage_client.bucket(self.transcript_bucket)
    
    async def upload_file(
        self,
        file_content: bytes,
        filename: str,
        content_type: Optional[str] = None
    ) -> str:
        """Upload a file to Google Cloud Storage.
        
        Args:
            file_content: File content as bytes
            filename: Name for the file in GCS
            content_type: MIME type of the file
            
        Returns:
            GCS URI of the uploaded file
        """
        blob = self.bucket.blob(filename)
        
        if content_type:
            blob.content_type = content_type
        
        # Upload in executor to avoid blocking
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(
            None,
            blob.upload_from_string,
            file_content,
            content_type
        )
        
        return f"gs://{self.bucket_name}/{filename}"
    
    async def download_file(self, gcs_uri: str) -> bytes:
        """Download a file from Google Cloud Storage.
        
        Args:
            gcs_uri: GCS URI of the file
            
        Returns:
            File content as bytes
        """
        # Parse GCS URI
        if not gcs_uri.startswith("gs://"):
            raise ValueError("Invalid GCS URI format")
        
        parts = gcs_uri[5:].split("/", 1)
        if len(parts) != 2:
            raise ValueError("Invalid GCS URI format")
        
        bucket_name, blob_name = parts
        bucket = self.storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        
        # Download in executor to avoid blocking
        loop = asyncio.get_event_loop()
        content = await loop.run_in_executor(
            None,
            blob.download_as_bytes
        )
        
        return content
    
    async def delete_file(self, gcs_uri: str):
        """Delete a file from Google Cloud Storage.
        
        Args:
            gcs_uri: GCS URI of the file to delete
        """
        # Parse GCS URI
        if not gcs_uri.startswith("gs://"):
            raise ValueError("Invalid GCS URI format")
        
        parts = gcs_uri[5:].split("/", 1)
        if len(parts) != 2:
            raise ValueError("Invalid GCS URI format")
        
        bucket_name, blob_name = parts
        bucket = self.storage_client.bucket(bucket_name)
        blob = bucket.blob(blob_name)
        
        # Delete in executor to avoid blocking
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, blob.delete)
    
    async def generate_signed_url(
        self,
        filename: str,
        expiration_hours: Optional[int] = None
    ) -> str:
        """Generate a signed URL for direct file upload.
        
        Args:
            filename: Name for the file in GCS
            expiration_hours: URL expiration time in hours
            
        Returns:
            Signed URL for upload
        """
        if expiration_hours is None:
            expiration_hours = self.settings.signed_url_expiration_hours
        
        blob = self.bucket.blob(filename)
        
        # Generate signed URL in executor
        loop = asyncio.get_event_loop()
        signed_url = await loop.run_in_executor(
            None,
            blob.generate_signed_url,
            version="v4",
            expiration=timedelta(hours=expiration_hours),
            method="PUT"
        )
        
        return signed_url
    
    async def save_transcript(self, transcript: str, job_id: str) -> str:
        """Save transcript to GCS.
        
        Args:
            transcript: Transcript text to save
            job_id: Job ID for filename
            
        Returns:
            GCS URI of saved transcript
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"transcripts/{timestamp}_{job_id}.txt"
        
        blob = self.transcript_bucket_obj.blob(filename)
        
        # Upload in executor to avoid blocking
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(
            None,
            blob.upload_from_string,
            transcript,
            "text/plain"
        )
        
        return f"gs://{self.transcript_bucket}/{filename}"
    
    async def extract_and_upload_audio(self, video_gcs_uri: str) -> str:
        """Extract audio from video file and upload to GCS.
        
        Args:
            video_gcs_uri: GCS URI of the video file
            
        Returns:
            GCS URI of extracted audio file
        """
        # Download video file to temp location
        video_content = await self.download_file(video_gcs_uri)
        
        with tempfile.NamedTemporaryFile(suffix=".mp4", delete=False) as video_file:
            video_file.write(video_content)
            video_path = video_file.name
        
        try:
            # Extract audio using FFmpeg
            audio_path = await self._extract_audio_ffmpeg(video_path)
            
            # Read extracted audio
            with open(audio_path, "rb") as audio_file:
                audio_content = audio_file.read()
            
            # Generate filename for audio
            video_filename = video_gcs_uri.split("/")[-1]
            audio_filename = os.path.splitext(video_filename)[0] + "_audio.wav"
            
            # Upload audio to GCS
            audio_gcs_uri = await self.upload_file(
                audio_content,
                audio_filename,
                "audio/wav"
            )
            
            # Clean up temp files
            os.unlink(audio_path)
            
            return audio_gcs_uri
            
        finally:
            # Always clean up video temp file
            os.unlink(video_path)
    
    async def _extract_audio_ffmpeg(self, video_path: str) -> str:
        """Extract audio from video using FFmpeg.
        
        Args:
            video_path: Path to video file
            
        Returns:
            Path to extracted audio file
        """
        # Create output filename
        audio_path = os.path.splitext(video_path)[0] + ".wav"
        
        # Construct FFmpeg command
        command = [
            self.settings.ffmpeg_path,
            "-i", video_path,
            "-vn",  # No video
            "-acodec", self.settings.ffmpeg_audio_codec,
            "-ar", str(self.settings.ffmpeg_sample_rate),
            "-ac", str(self.settings.ffmpeg_channels),
            "-y",  # Overwrite output
            audio_path
        ]
        
        # Run FFmpeg in executor
        loop = asyncio.get_event_loop()
        process = await loop.run_in_executor(
            None,
            lambda: subprocess.run(command, capture_output=True, text=True)
        )
        
        if process.returncode != 0:
            raise RuntimeError(f"FFmpeg error: {process.stderr}")
        
        return audio_path
    
    async def list_files(self, prefix: Optional[str] = None) -> list:
        """List files in the bucket.
        
        Args:
            prefix: Optional prefix to filter files
            
        Returns:
            List of file names
        """
        loop = asyncio.get_event_loop()
        blobs = await loop.run_in_executor(
            None,
            list,
            self.bucket.list_blobs(prefix=prefix)
        )
        
        return [blob.name for blob in blobs]
    
    async def file_exists(self, filename: str) -> bool:
        """Check if a file exists in GCS.
        
        Args:
            filename: Name of the file to check
            
        Returns:
            True if file exists, False otherwise
        """
        blob = self.bucket.blob(filename)
        
        loop = asyncio.get_event_loop()
        exists = await loop.run_in_executor(None, blob.exists)
        
        return exists
    
    async def get_file_metadata(self, filename: str) -> dict:
        """Get metadata for a file in GCS.
        
        Args:
            filename: Name of the file
            
        Returns:
            File metadata dictionary
        """
        blob = self.bucket.blob(filename)
        
        loop = asyncio.get_event_loop()
        await loop.run_in_executor(None, blob.reload)
        
        return {
            "name": blob.name,
            "size": blob.size,
            "content_type": blob.content_type,
            "created": blob.time_created.isoformat() if blob.time_created else None,
            "updated": blob.updated.isoformat() if blob.updated else None,
            "md5_hash": blob.md5_hash,
            "etag": blob.etag,
        }