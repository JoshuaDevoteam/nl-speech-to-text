# Speech-to-Text Backend Service

A FastAPI backend service for Dutch speech transcription using Google Cloud Speech-to-Text API. This service handles audio/video file uploads, transcription processing, and real-time status updates via WebSocket.

## Architecture Overview

The backend service is built with:
- **FastAPI** - Modern, fast web framework for building APIs
- **UV** - Ultra-fast Python package manager written in Rust
- **Google Cloud Speech-to-Text API** - For speech transcription
- **Google Cloud Storage** - For file storage
- **WebSocket** - For real-time transcription updates

## Features

- 🎤 Audio/video file upload to Google Cloud Storage
- 🔄 Automatic audio extraction from video files
- 🗣️ Dutch speech transcription using Chirp 3 model
- 📊 Real-time progress updates via WebSocket
- 🔗 Signed URL generation for direct GCS uploads
- 📝 Transcript storage and retrieval
- 🎛️ RESTful API with automatic documentation

## API Endpoints

### Core Endpoints

- `POST /api/v1/upload` - Upload audio/video file
- `POST /api/v1/transcribe` - Start transcription job
- `GET /api/v1/transcription/{job_id}` - Get transcription status/results
- `POST /api/v1/recognizer` - Create/get speech recognizer
- `GET /api/v1/signed-url` - Get signed URL for direct upload
- `DELETE /api/v1/transcription/{job_id}` - Delete transcription job
- `WS /ws/{job_id}` - WebSocket for real-time updates

### Health Check

- `GET /` - Service health check

## Prerequisites

- Python 3.11+
- Google Cloud SDK (`gcloud`)
- FFmpeg (for audio extraction)
- Google Cloud Project with enabled APIs:
  - Cloud Speech-to-Text API
  - Cloud Storage API

## Local Development Setup

### 1. Install UV Package Manager

```bash
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows
powershell -c "irm https://astral.sh/uv/install.ps1 | iex"

# Or via pip
pip install uv
```

### 2. Create Virtual Environment

```bash
uv venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
```

### 3. Install Dependencies

```bash
# Install all dependencies from pyproject.toml
uv pip sync pyproject.toml

# Or install with dev dependencies
uv pip install -e ".[dev]"
```

### 4. Configure Google Cloud Authentication

```bash
# Authenticate with Google Cloud
gcloud auth application-default login

# Set your project
gcloud config set project pj-speech-text-dev
```

### 5. Environment Variables

Create a `.env` file in the backend directory:

```env
# Google Cloud Settings
GCP_PROJECT_ID=pj-speech-text-dev
GCP_LOCATION=europe-west1
GCS_BUCKET_NAME=pj-speech-text-dev-audio-uploads
GCS_TRANSCRIPT_BUCKET=pj-speech-text-dev-transcripts

# Speech-to-Text Settings
RECOGNIZER_LOCATION=us  # Chirp 3 requires 'us' location
DEFAULT_RECOGNIZER_ID=dutch-recognizer-1
DEFAULT_LANGUAGE_CODE=nl-NL
SPEECH_MODEL=chirp_3

# Application Settings
DEBUG=true
PORT=8000

# CORS Settings (comma-separated)
CORS_ORIGINS=http://localhost:3000,http://localhost:3001

# Optional: Service Account Path
# GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json

# Optional: Redis for production job storage
# USE_REDIS=false
# REDIS_HOST=localhost
# REDIS_PORT=6379
```

### 6. Create GCS Buckets (if not exists)

```bash
# Create audio upload bucket
gsutil mb -p pj-speech-text-dev -l europe-west1 gs://pj-speech-text-dev-audio-uploads

# Create transcript bucket
gsutil mb -p pj-speech-text-dev -l europe-west1 gs://pj-speech-text-dev-transcripts
```

### 7. Run the Application

```bash
# Development mode with auto-reload
uv run uvicorn main:app --reload --port 8000

# Or directly
python main.py

# Production mode
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

### 8. Access the API

- API Documentation: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc
- Health Check: http://localhost:8000/

## Testing

### Run Unit Tests

```bash
# Run all tests
uv run pytest

# Run with coverage
uv run pytest --cov=. --cov-report=html

# Run specific test file
uv run pytest tests/test_transcription.py
```

### Test API Endpoints

```bash
# Upload a file
curl -X POST "http://localhost:8000/api/v1/upload" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@/path/to/audio.mp3"

# Start transcription
curl -X POST "http://localhost:8000/api/v1/transcribe" \
  -H "Content-Type: application/json" \
  -d '{
    "gcs_uri": "gs://bucket/audio.mp3",
    "language_code": "nl-NL"
  }'

# Check transcription status
curl "http://localhost:8000/api/v1/transcription/{job_id}"
```

### WebSocket Testing

```javascript
// Connect to WebSocket for real-time updates
const ws = new WebSocket('ws://localhost:8000/ws/{job_id}');

ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Status:', data.status, 'Progress:', data.progress);
};
```

## Docker Local Testing

### Build Docker Image

```bash
docker build -t speech-backend .
```

### Run Docker Container

```bash
# Run with environment variables
docker run -p 8000:8000 \
  -e GCP_PROJECT_ID=pj-speech-text-dev \
  -e GCP_LOCATION=europe-west1 \
  -v ~/.config/gcloud:/home/appuser/.config/gcloud:ro \
  speech-backend

# Run with .env file
docker run -p 8000:8000 --env-file .env speech-backend
```

### Docker Compose (optional)

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  backend:
    build: .
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - ~/.config/gcloud:/home/appuser/.config/gcloud:ro
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3
```

Run with: `docker-compose up`

## Code Quality

### Format Code

```bash
# Format with black
uv run black .

# Check without formatting
uv run black --check .
```

### Lint Code

```bash
# Run ruff linter
uv run ruff check .

# Auto-fix issues
uv run ruff check --fix .
```

### Type Checking

```bash
# Run mypy
uv run mypy .
```

## Debugging

### Enable Debug Logging

Set in `.env`:
```env
DEBUG=true
LOG_LEVEL=DEBUG
```

### Common Issues and Solutions

#### 1. Authentication Error

**Problem:** `google.auth.exceptions.DefaultCredentialsError`

**Solution:**
```bash
gcloud auth application-default login
# Or set service account
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
```

#### 2. FFmpeg Not Found

**Problem:** `FFmpeg error: ffmpeg: command not found`

**Solution:**
```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt-get install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html
```

#### 3. CORS Issues

**Problem:** Frontend cannot connect to backend

**Solution:** Update `CORS_ORIGINS` in `.env`:
```env
CORS_ORIGINS=http://localhost:3000,http://your-frontend-url
```

#### 4. Recognizer Location Error

**Problem:** `Recognizer creation failed in europe-west1`

**Solution:** Chirp 3 model requires `us` location:
```env
RECOGNIZER_LOCATION=us
```

## Performance Optimization

### 1. Use Redis for Job Storage

For production, enable Redis for persistent job storage:

```env
USE_REDIS=true
REDIS_HOST=localhost
REDIS_PORT=6379
```

### 2. Configure Workers

For production deployment:

```bash
uv run uvicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker
```

### 3. Enable Response Compression

Add to FastAPI app:

```python
from fastapi.middleware.gzip import GZipMiddleware
app.add_middleware(GZipMiddleware, minimum_size=1000)
```

## Deployment

### Cloud Run Deployment

The service is configured for automatic deployment via Cloud Build:

```bash
# Trigger Cloud Build
gcloud builds submit --config=cloudbuild.yaml

# Or manual deployment
gcloud run deploy speech-backend \
  --source . \
  --region=europe-west1 \
  --allow-unauthenticated
```

### Environment Variables for Production

Set these in Cloud Run:

- `GCP_PROJECT_ID`
- `GCP_LOCATION`
- `GCS_BUCKET_NAME`
- `GCS_TRANSCRIPT_BUCKET`
- `CORS_ORIGINS` (include your frontend URL)

## API Documentation Examples

### Upload File Example

```python
import requests

# Upload file
with open("audio.mp3", "rb") as f:
    response = requests.post(
        "http://localhost:8000/api/v1/upload",
        files={"file": f}
    )
    
upload_result = response.json()
print(f"GCS URI: {upload_result['gcs_uri']}")
```

### Start Transcription Example

```python
# Start transcription
response = requests.post(
    "http://localhost:8000/api/v1/transcribe",
    json={
        "gcs_uri": upload_result["gcs_uri"],
        "language_code": "nl-NL",
        "enable_punctuation": True
    }
)

job = response.json()
print(f"Job ID: {job['job_id']}")
```

### Monitor Progress Example

```python
import asyncio
import websockets
import json

async def monitor_transcription(job_id):
    uri = f"ws://localhost:8000/ws/{job_id}"
    async with websockets.connect(uri) as websocket:
        while True:
            message = await websocket.recv()
            data = json.loads(message)
            print(f"Status: {data['status']}, Progress: {data.get('progress', 0)}%")
            if data['status'] in ['completed', 'failed']:
                break

# Run monitoring
asyncio.run(monitor_transcription(job['job_id']))
```

## Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linters
4. Submit a pull request

## License

This project is proprietary to Devoteam.

## Support

For issues or questions, please contact the development team or create an issue in the repository.