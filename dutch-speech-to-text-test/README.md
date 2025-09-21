# Google Cloud Speech-to-Text v2 with Chirp 3 for Meeting Transcription

This project uses Google Cloud Speech-to-Text API v2 with the Chirp 3 model to transcribe meeting recordings with speaker diarization.

## Features

- **Chirp 3 Model**: Uses Google's latest and most accurate speech recognition model
- **Speaker Diarization**: Identifies and labels different speakers in the meeting (up to 10 speakers)
- **Automatic Punctuation**: Adds punctuation for better readability
- **British English Support**: Configured for en-GB language code
- **Audio Extraction**: Automatically extracts audio from video files
- **GCS Integration**: Uploads audio to Google Cloud Storage for processing

## Prerequisites

1. **Google Cloud Project** with Speech-to-Text API enabled
2. **Google Cloud Storage Bucket** for audio file storage
3. **Authentication** configured (gcloud auth or service account)
4. **FFmpeg** installed for audio extraction
5. **Python 3.8+** with required packages

## Setup

1. Install dependencies:
```bash
pip install google-cloud-speech google-cloud-storage
```

2. Configure Google Cloud authentication:
```bash
gcloud auth application-default login
```

3. Update configuration in `main.py`:
```python
GCS_BUCKET_NAME = "your-bucket-name"
RECOGNIZER_ID = "your-recognizer-id"
GCP_PROJECT_ID = "your-project-id"
```

## Usage

### Run the test suite first:
```bash
python test_chirp.py
```

### Transcribe a meeting recording:
```bash
python main.py
```

The script will:
1. Create a Chirp 3 recognizer (if it doesn't exist)
2. Extract audio from your video file
3. Upload audio to Google Cloud Storage
4. Transcribe with speaker diarization
5. Save the transcript to `meeting_transcript.txt`

## Key Improvements Made

### 1. Fixed Recognizer Structure
- Corrected from `Recognizer.Features` to `cloud_speech.RecognitionFeatures`
- Properly structured recognizer creation with `CreateRecognizerRequest`

### 2. Enhanced Transcription Configuration
- Uses Chirp 3 model (`chirp_3`) - the best model for meeting transcription
- Enabled speaker diarization with 1-10 speaker support
- Added automatic punctuation for readability
- Configured for British English (en-GB)

### 3. Improved Error Handling
- Checks if recognizer exists before creating
- Handles transcription timeouts for long meetings (up to 1 hour)
- Better parsing of results with speaker information

## Model Comparison

| Feature | Chirp | Chirp 2 | Chirp 3 |
|---------|-------|---------|---------|
| Speaker Diarization |  | L |  |
| Automatic Punctuation |  |  |  |
| Meeting Transcription | Good | Limited | **Best** |
| Language Support | Good | Better | Best |

## Troubleshooting

1. **AttributeError: 'Recognizer' has no attribute 'Features'**
   - Fixed: Now uses `cloud_speech.RecognitionFeatures`

2. **Recognizer not found**
   - The script now creates the recognizer automatically if it doesn't exist

3. **Location not supported**
   - Uses `us-central1` which fully supports Chirp 3

## Output Format

The transcript includes speaker labels:
```
[Speaker 1]: Hello everyone, welcome to today's meeting.
[Speaker 2]: Thank you for joining us today.
[Speaker 1]: Let's begin with the agenda...
```

## API Reference

- [Chirp 3 Documentation](https://cloud.google.com/speech-to-text/v2/docs/chirp_3-model)
- [Recognizers Guide](https://cloud.google.com/speech-to-text/v2/docs/recognizers)
- [Speech-to-Text v2 API](https://cloud.google.com/speech-to-text/v2/docs)