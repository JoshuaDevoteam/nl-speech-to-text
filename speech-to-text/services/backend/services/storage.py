"""Storage service for Google Cloud Storage operations."""

import os
import asyncio
import tempfile
import subprocess
from datetime import datetime, timedelta
from typing import Optional, BinaryIO

from google.cloud import storage
from google.cloud.storage import Blob
from google.auth import default
from google.auth.credentials import Signing
from google.auth.impersonated_credentials import Credentials as ImpersonatedCredentials
from google.auth.transport.requests import Request


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

        base_credentials, detected_project = default()

        if hasattr(base_credentials, 'with_scopes'):
            base_credentials = base_credentials.with_scopes([
                'https://www.googleapis.com/auth/cloud-platform'
            ])

        self.project_id = settings.gcp_project_id or detected_project

        self.signing_credentials = base_credentials if isinstance(base_credentials, Signing) else None

        if self.signing_credentials is None:
            target_principal = settings.signing_service_account
            if not target_principal and hasattr(base_credentials, 'service_account_email'):
                target_principal = base_credentials.service_account_email

            if target_principal:
                try:
                    self.signing_credentials = ImpersonatedCredentials(
                        source_credentials=base_credentials,
                        target_principal=target_principal,
                        target_scopes=['https://www.googleapis.com/auth/cloud-platform'],
                        lifetime=3600
                    )
                except Exception as exc:
                    print(f"WARNING: Failed to create impersonated credentials for signing: {exc}")
                    self.signing_credentials = None

        self._request = Request()

        self.storage_client = storage.Client(
            project=self.project_id,
            credentials=base_credentials
        )
        self.bucket = self.storage_client.bucket(self.bucket_name)
        self.transcript_bucket_obj = self.storage_client.bucket(self.transcript_bucket)
    
    async def upload_file(
        self,
        file_content: bytes,
        filename: str,
        content_type: Optional[str] = None
    ) -> str:
        """Upload a file to Google Cloud Storage from bytes.

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

        loop = asyncio.get_event_loop()
        await loop.run_in_executor(
            None,
            blob.upload_from_string,
            file_content,
            content_type
        )

        return f"gs://{self.bucket_name}/{filename}"

    async def upload_file_stream(
        self,
        file_obj: BinaryIO,
        filename: str,
        content_type: Optional[str] = None
    ) -> str:
        """Upload a file-like object to Google Cloud Storage without loading it all into memory."""
        blob = self.bucket.blob(filename)

        if content_type:
            blob.content_type = content_type

        loop = asyncio.get_event_loop()

        def _upload():
            file_obj.seek(0)
            blob.upload_from_file(file_obj, rewind=True, content_type=content_type)

        await loop.run_in_executor(None, _upload)

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
        expiration_hours: Optional[int] = None,
        method: str = "PUT"
    ) -> str:
        """Generate a signed URL for direct file upload.
        
        Args:
            filename: Name for the file in GCS
            expiration_hours: URL expiration time in hours
            method: HTTP method for the signed URL
            
        Returns:
            Signed URL for upload
        """
        if expiration_hours is None:
            expiration_hours = self.settings.signed_url_expiration_hours
        
        blob = self.bucket.blob(filename)
        
        # Generate signed URL in executor
        loop = asyncio.get_event_loop()
        
        signing_credentials = self.signing_credentials
        if signing_credentials is None:
            raise RuntimeError(
                "No signing credentials available. Ensure the service account can sign blobs or set SIGNING_SERVICE_ACCOUNT."
            )

        def _generate_signed_url():
            signing_credentials.refresh(self._request)
            return blob.generate_signed_url(
                version="v4",
                expiration=timedelta(hours=expiration_hours),
                method=method,
                credentials=signing_credentials
            )
        
        signed_url = await loop.run_in_executor(None, _generate_signed_url)
        
        return signed_url
    
    async def generate_resumable_upload_url(
        self,
        filename: str,
        content_type: Optional[str] = None,
        expiration_hours: Optional[int] = None
    ) -> dict:
        """Generate a resumable upload URL for large file uploads.
        
        Args:
            filename: Name for the file in GCS
            content_type: MIME type of the file
            expiration_hours: URL expiration time in hours
            
        Returns:
            Dictionary containing resumable upload URL and session info
        """
        if expiration_hours is None:
            expiration_hours = self.settings.signed_url_expiration_hours
        
        blob = self.bucket.blob(filename)
        if content_type:
            blob.content_type = content_type
        
        # Generate resumable upload URL in executor
        loop = asyncio.get_event_loop()
        
        signing_credentials = self.signing_credentials
        if signing_credentials is None:
            raise RuntimeError(
                "No signing credentials available for resumable upload. Ensure the service account can sign blobs or set SIGNING_SERVICE_ACCOUNT."
            )

        def _create_resumable_session():
            expiration = datetime.utcnow() + timedelta(hours=expiration_hours)

            signing_credentials.refresh(self._request)
            signed_url = blob.generate_signed_url(
                version="v4",
                expiration=expiration,
                method="POST",
                headers={"x-goog-resumable": "start"},
                credentials=signing_credentials
            )
            
            return {
                "resumable_url": signed_url,
                "blob_name": filename,
                "bucket_name": self.bucket_name,
                "content_type": content_type,
                "expiration": expiration.isoformat(),
                "method": "POST",
                "headers": {
                    "x-goog-resumable": "start",
                    "Content-Type": content_type or "application/octet-stream"
                }
            }
        
        session_info = await loop.run_in_executor(None, _create_resumable_session)
        return session_info
    
    async def generate_upload_options(
        self,
        filename: str,
        file_size: Optional[int] = None,
        content_type: Optional[str] = None,
        expiration_hours: Optional[int] = None
    ) -> dict:
        """Generate upload options based on file size.
        
        Provides both regular signed URL and resumable upload URL options.
        
        Args:
            filename: Name for the file in GCS
            file_size: Size of the file in bytes
            content_type: MIME type of the file
            expiration_hours: URL expiration time in hours
            
        Returns:
            Dictionary with upload options
        """
        # Threshold for resumable uploads (100MB)
        resumable_threshold = 100 * 1024 * 1024
        
        options = {
            "filename": filename,
            "bucket_name": self.bucket_name,
            "gcs_uri": f"gs://{self.bucket_name}/{filename}",
            "file_size": file_size,
            "content_type": content_type
        }
        
        # Always provide regular signed URL for smaller uploads
        regular_url = await self.generate_signed_url(
            filename=filename,
            expiration_hours=expiration_hours,
            method="PUT"
        )
        
        options["signed_url"] = {
            "url": regular_url,
            "method": "PUT",
            "headers": {
                "Content-Type": content_type or "application/octet-stream"
            },
            "recommended_for": "files_under_100mb"
        }
        
        # Provide resumable upload for larger files
        if file_size is None or file_size >= resumable_threshold:
            resumable_info = await self.generate_resumable_upload_url(
                filename=filename,
                content_type=content_type,
                expiration_hours=expiration_hours
            )
            
            options["resumable_upload"] = {
                **resumable_info,
                "recommended_for": "files_over_100mb",
                "chunk_size": 8 * 1024 * 1024,  # 8MB chunks
                "supports_resume": True
            }
        
        return options
    
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
