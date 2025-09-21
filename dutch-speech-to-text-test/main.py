import os
import subprocess
from google.cloud import speech
from google.cloud import storage

from google.api_core import client_options
from google.cloud.speech_v2 import SpeechClient
from google.cloud.speech_v2.types import cloud_speech

# --- Configuration ---
GCS_BUCKET_NAME = "gcs-audio-transcripts" # 👈 Replace with your bucket name
RECOGNIZER_ID = "dutch-recognizer-1" # 👈 Replace with your recognizer ID
GCP_PROJECT_ID = "pj-dutch-speech-to-text" # 👈 Replace with your GCP project ID

def check_recognizer_exists(project_id: str, location: str, recognizer_id: str) -> bool:
    """Check if a recognizer already exists."""
    # Configure client to use regional endpoint
    client_options_var = client_options.ClientOptions(
        api_endpoint=f"{location}-speech.googleapis.com"
    )
    client = SpeechClient(client_options=client_options_var)
    recognizer_name = f"projects/{project_id}/locations/{location}/recognizers/{recognizer_id}"
    
    try:
        client.get_recognizer(name=recognizer_name)
        return True
    except Exception:
        return False

def create_chirp_recognizer(project_id: str, location: str, recognizer_id: str):
    """Creates a v2 recognizer with the Chirp 3 model for Dutch meeting transcription."""
    # Configure client to use regional endpoint
    client_options_var = client_options.ClientOptions(
        api_endpoint=f"{location}-speech.googleapis.com"
    )
    client = SpeechClient(client_options=client_options_var)

    # The full resource name of the recognizer parent
    parent = f"projects/{project_id}/locations/{location}"
    
    # Create the recognizer request with correct structure
    request = cloud_speech.CreateRecognizerRequest(
        parent=parent,
        recognizer_id=recognizer_id,
        recognizer=cloud_speech.Recognizer(
            default_recognition_config=cloud_speech.RecognitionConfig(
                # Use Chirp model for transcription
                model="chirp_3",
                language_codes=["nl-NL"],  # Dutch as requested
                features=cloud_speech.RecognitionFeatures(
                    # Enable automatic punctuation for readability
                    enable_automatic_punctuation=True
                ),
            ),
        ),
    )
    
    operation = client.create_recognizer(request=request)
    
    print(f"Waiting for recognizer '{recognizer_id}' to be created...")
    result = operation.result()
    print(f"✅ Recognizer created: {result.name}")
    return result



def transcribe_gcs_audio_v2(project_id: str, location: str, gcs_uri: str, recognizer_id: str) -> cloud_speech.BatchRecognizeResponse:
    """Transcribes Dutch audio from GCS using a v2 Recognizer with Chirp 3."""
    # Configure client to use regional endpoint
    client_options_var = client_options.ClientOptions(
        api_endpoint=f"{location}-speech.googleapis.com"
    )
    client = SpeechClient(client_options=client_options_var)

    # Use the actual recognizer_id parameter instead of hardcoded name
    recognizer_name = f"projects/{project_id}/locations/{location}/recognizers/{recognizer_id}"
    
    # Configure recognition - auto_decoding_config for automatic audio format detection
    config = cloud_speech.RecognitionConfig(
        auto_decoding_config=cloud_speech.AutoDetectDecodingConfig(),
        # Features are already configured in the recognizer
    )
    
    # Create file metadata for the GCS audio file
    file_metadata = cloud_speech.BatchRecognizeFileMetadata(uri=gcs_uri)

    # Create the batch recognize request
    request = cloud_speech.BatchRecognizeRequest(
        recognizer=recognizer_name,
        config=config,
        files=[file_metadata],
        recognition_output_config=cloud_speech.RecognitionOutputConfig(
            inline_response_config=cloud_speech.InlineOutputConfig(),
        ),
    )

    print(f"Sending v2 transcription request using recognizer '{recognizer_id}'...")
    operation = client.batch_recognize(request=request)
    response = operation.result(timeout=3600)  # 1 hour timeout for long meetings
    
    print("✅ Transcription complete.")
    
    return response

def extract_audio(video_file_path: str) -> str:
    """Extracts audio from a video file into a WAV format using FFmpeg."""
    
    # Create an output filename for the audio
    filename, _ = os.path.splitext(video_file_path)
    audio_file_path = f"{filename}.wav"
    
    print(f"Extracting audio from '{video_file_path}'...")
    
    # Construct and run the FFmpeg command
    command = [
        "ffmpeg",
        "-i", video_file_path, # Input file
        "-vn",                # No video
        "-acodec", "pcm_s16le",# Audio codec for WAV
        "-ar", "16000",       # Sample rate
        "-ac", "1",           # Mono channel
        "-y",                 # Overwrite output file if it exists
        audio_file_path
    ]
    
    # Using subprocess.run to execute the command
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode != 0:
        print("FFmpeg Error:", result.stderr)
        raise RuntimeError("Failed to extract audio with FFmpeg.")
        
    print(f"✅ Audio extracted successfully to '{audio_file_path}'")
    return audio_file_path


def upload_to_gcs(file_path: str, bucket_name: str) -> str:
    """Uploads a local file to a GCS bucket."""
    
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    
    # The name of the object in the bucket will be the basename of the file
    blob_name = os.path.basename(file_path)
    blob = bucket.blob(blob_name)
    
    print(f"Uploading '{blob_name}' to GCS bucket '{bucket_name}'...")
    blob.upload_from_filename(file_path)
    
    gcs_uri = f"gs://{bucket_name}/{blob_name}"
    print(f"✅ File uploaded successfully. GCS URI: {gcs_uri}")
    return gcs_uri


def transcribe_gcs_audio(gcs_uri: str) -> str:
    """Transcribes audio from GCS with Dutch speaker diarization."""
    
    client = speech.SpeechClient()
    audio = speech.RecognitionAudio(uri=gcs_uri)

    diarization_config = speech.SpeakerDiarizationConfig(
        enable_speaker_diarization=True,
        min_speaker_count=2,
        max_speaker_count=10,
    )

    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="nl-NL",
        diarization_config=diarization_config,
    )

    print("Sending transcription request to Google Cloud Speech-to-Text...")
    operation = client.long_running_recognize(config=config, audio=audio)
    response = operation.result(timeout=1800) # 30 min timeout

    # Format the transcript with speaker tags
    full_transcript = []
    for result in response.results:
        try:
            # Reconstruct transcript from words which include speaker tags
            transcript_segment = " ".join([
                f"(Speaker {word.speaker_tag}): {word.word}" 
                for word in result.alternatives[0].words
            ])
            full_transcript.append(transcript_segment)
        except IndexError:
            # Handle cases where a segment might be empty
            continue
            
    print("✅ Transcription complete.")
    return "\n".join(full_transcript)

def parse_v2_transcript(file_result) -> str:
    """
    Parses the detailed transcript from a BatchRecognizeFileResult.
    """
    # Check if a transcript and results within it exist
    if not file_result.transcript or not file_result.transcript.results:
        return "Transcription finished, but no speech was detected."

    full_transcript_parts = []
    
    # Loop through each segment in the transcript's results list
    for segment in file_result.transcript.results:
        # Check if there are any alternatives and get the first one
        if segment.alternatives:
            full_transcript_parts.append(segment.alternatives[0].transcript)

    # Join all the parts together
    return " ".join(full_transcript_parts).strip()


# --- Main execution block ---
if __name__ == "__main__":
    # 1. Define the input video file
    input_video = r"/Users/joshuavink/Devoteam/dutch-speech-to-text/Voorbeeld video van een vergadering.publer.com.mp4" # 👈 Replace with your video file path
    
    # Location for the recognizer (us supports Chirp 3)
    LOCATION = "us"

    try:
        # 2. Create or get the recognizer (only needs to be done once)
        if not check_recognizer_exists(GCP_PROJECT_ID, LOCATION, RECOGNIZER_ID):
            print(f"Creating new recognizer '{RECOGNIZER_ID}'...")
            create_chirp_recognizer(
                project_id=GCP_PROJECT_ID,
                location=LOCATION,
                recognizer_id=RECOGNIZER_ID
            )
        else:
            print(f"Using existing recognizer '{RECOGNIZER_ID}'")
        
        # 3. Extract audio from the video
        audio_file = extract_audio(input_video)
        
        # 4. Upload the audio file to GCS
        audio_gcs_uri = upload_to_gcs(audio_file, GCS_BUCKET_NAME)
        
        # 5. Transcribe the Dutch audio from GCS using Chirp 3
        response = transcribe_gcs_audio_v2(
            project_id=GCP_PROJECT_ID,
            location=LOCATION,
            gcs_uri=audio_gcs_uri, 
            recognizer_id=RECOGNIZER_ID
        )
        
        # 6. Parse the transcript
        if response.results and audio_gcs_uri in response.results:
            transcript_text = parse_v2_transcript(response.results[audio_gcs_uri])
            
            # 7. Print the final result
            print("\n--- FINAL TRANSCRIPT ---\n")
            print(transcript_text)
            
            # Optionally save to file
            output_file = "meeting_transcript.txt"
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(transcript_text)
            print(f"\n✅ Transcript saved to {output_file}")
        else:
            print("No transcription results found.")

    except (RuntimeError, FileNotFoundError) as e:
        print(f"An error occurred: {e}")
