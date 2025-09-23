"""Speech-to-Text Backend Service

FastAPI application providing speech transcription services using Google Cloud Speech-to-Text API.
"""

import os
import uuid
from typing import Optional, Dict, Any
from datetime import datetime
import asyncio

from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import uvicorn

from models import (
    TranscriptionRequest,
    TranscriptionResponse,
    TranscriptionStatus,
    RecognizerRequest,
    RecognizerResponse,
    UploadResponse,
    JobStatus,
    TranscriptSegment
)
from services.transcription import TranscriptionService
from services.storage import StorageService
from config import Settings

# Initialize settings
settings = Settings()

# Initialize services
transcription_service = TranscriptionService(settings)
storage_service = StorageService(settings)

# Create FastAPI app
app = FastAPI(
    title="Speech-to-Text API",
    description="Backend service for Dutch speech transcription using Google Cloud Speech-to-Text",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=settings.cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory job storage (consider using Redis in production)
jobs: Dict[str, JobStatus] = {}

# WebSocket connections storage
websocket_connections: Dict[str, WebSocket] = {}


@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "speech-to-text-backend",
        "version": "1.0.0"
    }


@app.post("/api/v1/upload", response_model=UploadResponse)
async def upload_file(
    file: UploadFile = File(...),
    background_tasks: BackgroundTasks = BackgroundTasks()
):
    """
    Upload an audio or video file to Google Cloud Storage.
    
    Args:
        file: The uploaded file (audio or video)
        
    Returns:
        Upload response with GCS URI and file metadata
    """
    # This endpoint is now limited to small uploads (e.g., testing) and will
    # reject large files. Production uploads should use the signed-URL flow.
    max_inline_size = 25 * 1024 * 1024  # 25 MB safety limit

    try:
        file.file.seek(0, os.SEEK_END)
        file_size = file.file.tell()
        file.file.seek(0)
    except Exception:
        file_size = None

    if file_size and file_size > max_inline_size:
        raise HTTPException(
            status_code=413,
            detail="Inline uploads are limited to 25MB. Please use the direct upload flow."
        )

    if file_size and file_size > settings.get_max_file_size_bytes():
        max_gb = settings.max_file_size_mb / 1024
        raise HTTPException(
            status_code=400,
            detail=(
                f"File too large. Maximum size is {max_gb:.0f}GB "
                f"({settings.max_file_size_mb}MB)."
            )
        )

    try:
        contents = await file.read()
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_filename = f"{timestamp}_{uuid.uuid4().hex[:8]}_{file.filename}"
        gcs_uri = await storage_service.upload_file(
            file_content=contents,
            filename=unique_filename,
            content_type=file.content_type
        )

        return UploadResponse(
            gcs_uri=gcs_uri,
            filename=unique_filename,
            original_filename=file.filename,
            size=file_size,
            content_type=file.content_type
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/transcribe", response_model=TranscriptionResponse)
async def start_transcription(
    request: TranscriptionRequest,
    background_tasks: BackgroundTasks
):
    """
    Start a transcription job for a file in GCS.
    
    Args:
        request: Transcription request with GCS URI and options
        
    Returns:
        Transcription response with job ID
    """
    try:
        # Generate job ID
        job_id = str(uuid.uuid4())
        
        # Initialize job status
        jobs[job_id] = JobStatus(
            job_id=job_id,
            status="pending",
            created_at=datetime.now(),
            gcs_uri=request.gcs_uri
        )
        
        # Start transcription in background
        background_tasks.add_task(
            process_transcription,
            job_id,
            request
        )
        
        return TranscriptionResponse(
            job_id=job_id,
            status="pending",
            message="Transcription job started successfully"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


async def process_transcription(job_id: str, request: TranscriptionRequest):
    """
    Process transcription job asynchronously.
    
    Args:
        job_id: Unique job identifier
        request: Transcription request parameters
    """
    try:
        # Update job status
        jobs[job_id].status = "processing"
        jobs[job_id].started_at = datetime.now()
        
        # Notify via WebSocket if connected
        await notify_websocket(job_id, {"status": "processing", "message": "Transcription started"})
        
        # Extract audio if video file
        if request.extract_audio:
            jobs[job_id].status = "extracting_audio"
            await notify_websocket(job_id, {"status": "extracting_audio", "message": "Extracting audio from video"})
            
            audio_gcs_uri = await storage_service.extract_and_upload_audio(request.gcs_uri)
        else:
            audio_gcs_uri = request.gcs_uri
        
        # Perform transcription
        jobs[job_id].status = "transcribing"
        await notify_websocket(job_id, {"status": "transcribing", "message": "Transcribing audio"})
        
        transcript, transcript_segments, speaker_transcript, speaker_summary, refined_transcript = await transcription_service.transcribe_audio(
            gcs_uri=audio_gcs_uri,
            language_code=request.language_code or "nl-NL",
            recognizer_id=request.recognizer_id,
            enable_diarization=request.enable_diarization,
            enable_speaker_identification=request.enable_speaker_identification,
            min_speaker_count=request.min_speaker_count,
            max_speaker_count=request.max_speaker_count
        )
        
        # Apply speaker identification if enabled
        if request.enable_speaker_identification and speaker_transcript:
            jobs[job_id].status = "identifying_speakers"
            await notify_websocket(job_id, {"status": "identifying_speakers", "message": "Identifying speakers"})
        
        # Update job with results
        jobs[job_id].status = "completed"
        jobs[job_id].completed_at = datetime.now()
        jobs[job_id].transcript = transcript
        jobs[job_id].transcript_segments = [TranscriptSegment(**segment) for segment in transcript_segments] if transcript_segments else None
        jobs[job_id].speaker_identified_transcript = speaker_transcript
        jobs[job_id].speaker_identification_summary = speaker_summary
        jobs[job_id].refined_transcript = refined_transcript

        # Save transcript to GCS
        transcript_uri = await storage_service.save_transcript(transcript, job_id)
        jobs[job_id].transcript_uri = transcript_uri

        # Notify completion
        await notify_websocket(job_id, {
            "status": "completed",
            "message": "Transcription completed successfully",
            "data": {
                "transcript": transcript[:500],
                "transcript_segments": transcript_segments[:5] if transcript_segments else None,
                "refined_transcript": refined_transcript,
                "speaker_identified_transcript": speaker_transcript,
                "speaker_identification_summary": speaker_summary,
            }
        })
        
    except Exception as e:
        jobs[job_id].status = "failed"
        jobs[job_id].error = str(e)
        jobs[job_id].completed_at = datetime.now()
        
        await notify_websocket(job_id, {
            "status": "failed",
            "message": f"Transcription failed: {str(e)}"
        })


@app.get("/api/v1/transcription/{job_id}")
async def get_transcription_status(job_id: str):
    """
    Get the status and results of a transcription job.
    
    Args:
        job_id: Unique job identifier
        
    Returns:
        Job status and transcript if completed
    """
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    
    job = jobs[job_id]
    
    response = {
        "job_id": job_id,
        "status": job.status,
        "created_at": job.created_at.isoformat(),
        "started_at": job.started_at.isoformat() if job.started_at else None,
        "completed_at": job.completed_at.isoformat() if job.completed_at else None,
        "gcs_uri": job.gcs_uri
    }
    
    if job.status == "completed":
        response["transcript"] = job.transcript
        response["transcript_uri"] = job.transcript_uri
        response["transcript_segments"] = [segment.model_dump() if hasattr(segment, "model_dump") else segment for segment in job.transcript_segments] if job.transcript_segments else None
        response["speaker_identified_transcript"] = job.speaker_identified_transcript
        response["speaker_identification_summary"] = job.speaker_identification_summary
        response["refined_transcript"] = job.refined_transcript
    elif job.status == "failed":
        response["error"] = job.error
    
    # Calculate progress percentage
    if job.status == "pending":
        response["progress"] = 0
    elif job.status == "extracting_audio":
        response["progress"] = 20
    elif job.status == "transcribing":
        response["progress"] = 50
    elif job.status == "identifying_speakers":
        response["progress"] = 80
    elif job.status == "completed":
        response["progress"] = 100
    else:
        response["progress"] = 0
    
    return response


@app.post("/api/v1/recognizer", response_model=RecognizerResponse)
async def create_or_get_recognizer(request: RecognizerRequest):
    """
    Create a new recognizer or get an existing one.
    
    Args:
        request: Recognizer configuration request
        
    Returns:
        Recognizer response with ID and status
    """
    try:
        recognizer_id = request.recognizer_id or f"recognizer-{uuid.uuid4().hex[:8]}"
        
        # Check if recognizer exists
        exists = await transcription_service.check_recognizer_exists(recognizer_id)
        
        if exists:
            return RecognizerResponse(
                recognizer_id=recognizer_id,
                created=False,
                message=f"Using existing recognizer: {recognizer_id}"
            )
        
        # Create new recognizer
        await transcription_service.create_recognizer(
            recognizer_id=recognizer_id,
            language_codes=request.language_codes,
            model=request.model
        )
        
        return RecognizerResponse(
            recognizer_id=recognizer_id,
            created=True,
            message=f"Created new recognizer: {recognizer_id}"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.websocket("/ws/{job_id}")
async def websocket_endpoint(websocket: WebSocket, job_id: str):
    """
    WebSocket endpoint for real-time transcription updates.
    
    Args:
        websocket: WebSocket connection
        job_id: Job ID to monitor
    """
    await websocket.accept()
    websocket_connections[job_id] = websocket
    
    try:
        # Send initial status
        if job_id in jobs:
            await websocket.send_json({
                "status": jobs[job_id].status,
                "message": "Connected to transcription updates"
            })
        
        # Keep connection alive
        while True:
            await asyncio.sleep(1)
            
            # Check if job is completed
            if job_id in jobs and jobs[job_id].status in ["completed", "failed"]:
                await asyncio.sleep(5)  # Give client time to receive final update
                break
                
    except Exception as e:
        print(f"WebSocket error: {e}")
    finally:
        if job_id in websocket_connections:
            del websocket_connections[job_id]
        await websocket.close()


async def notify_websocket(job_id: str, data: Dict[str, Any]):
    """
    Send notification to WebSocket client if connected.
    
    Args:
        job_id: Job ID
        data: Data to send
    """
    if job_id in websocket_connections:
        try:
            await websocket_connections[job_id].send_json(data)
        except Exception as e:
            print(f"Failed to send WebSocket notification: {e}")


@app.get("/api/v1/signed-url")
async def get_signed_upload_url(
    filename: str,
    file_size: Optional[int] = None,
    content_type: Optional[str] = None,
    resumable: bool = False
):
    """
    Get signed URL(s) for direct file upload to GCS.
    
    Supports both regular signed URLs and resumable upload sessions for large files.
    
    Args:
        filename: Name of the file to upload
        file_size: Size of the file in bytes (optional, used for upload method selection)
        content_type: MIME type of the file (optional)
        resumable: Force resumable upload regardless of file size
        
    Returns:
        Upload options including signed URLs and resumable upload info
    """
    try:
        # Generate unique filename
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_filename = f"{timestamp}_{uuid.uuid4().hex[:8]}_{filename}"
        
        print(f"DEBUG: Generating upload options - filename: {unique_filename}, size: {file_size}, type: {content_type}, resumable: {resumable}")
        
        # Validate file type if provided
        if filename:
            allowed_extensions = ['.mp3', '.mp4', '.wav', '.m4a', '.flac', '.ogg', '.webm', '.mov']
            file_extension = os.path.splitext(filename)[1].lower()
            
            if file_extension not in allowed_extensions:
                raise HTTPException(
                    status_code=400,
                    detail=f"File type {file_extension} not supported. Allowed types: {allowed_extensions}"
                )
        
        # Check file size limits
        if file_size and file_size > settings.get_max_file_size_bytes():
            max_gb = settings.max_file_size_mb / 1024
            raise HTTPException(
                status_code=400,
                detail=(
                    f"File too large. Maximum size is {max_gb:.0f}GB "
                    f"({settings.max_file_size_mb}MB)."
                )
            )
        
        # Get upload options from storage service
        upload_options = await storage_service.generate_upload_options(
            filename=unique_filename,
            file_size=file_size,
            content_type=content_type,
            expiration_hours=settings.signed_url_expiration_hours
        )
        
        # If resumable is forced, only return resumable option
        if resumable and "resumable_upload" in upload_options:
            return {
                "resumable_upload": upload_options["resumable_upload"],
                "filename": unique_filename,
                "gcs_uri": upload_options["gcs_uri"],
                "upload_method": "resumable"
            }
        
        # Return comprehensive upload options
        response = {
            "filename": unique_filename,
            "gcs_uri": upload_options["gcs_uri"],
            "file_size": file_size,
            "content_type": content_type,
            "expires_in": settings.signed_url_expiration_hours * 3600,
            "upload_options": {}
        }
        
        # Add signed URL option
        if "signed_url" in upload_options:
            response["upload_options"]["signed_url"] = upload_options["signed_url"]
        
        # Add resumable upload option if available
        if "resumable_upload" in upload_options:
            response["upload_options"]["resumable_upload"] = upload_options["resumable_upload"]
        
        # Recommend best upload method based on file size
        if file_size:
            if file_size < 100 * 1024 * 1024:  # < 100MB
                response["recommended_method"] = "signed_url"
            else:
                response["recommended_method"] = "resumable_upload"
        else:
            response["recommended_method"] = "resumable_upload"  # Default for unknown size
        
        print(f"DEBUG: Generated upload options successfully")
        return response
        
    except Exception as e:
        print(f"ERROR: Failed to generate upload options - {type(e).__name__}: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@app.delete("/api/v1/transcription/{job_id}")
async def delete_transcription(job_id: str):
    """
    Delete a transcription job and its associated files.
    
    Args:
        job_id: Job ID to delete
        
    Returns:
        Deletion status
    """
    if job_id not in jobs:
        raise HTTPException(status_code=404, detail="Job not found")
    
    job = jobs[job_id]
    
    try:
        # Delete files from GCS if they exist
        if job.transcript_uri:
            await storage_service.delete_file(job.transcript_uri)
        
        # Remove from jobs
        del jobs[job_id]
        
        return {"message": "Job deleted successfully", "job_id": job_id}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=int(os.environ.get("PORT", 8000)),
        reload=True
    )
