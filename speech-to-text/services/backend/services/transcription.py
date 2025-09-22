"""Transcription service using Google Cloud Speech-to-Text API."""

import asyncio
from typing import Optional, List
from google.cloud import speech
from google.cloud import storage
from google.api_core import client_options
from google.cloud.speech_v2 import SpeechClient
from google.cloud.speech_v2.types import cloud_speech


class TranscriptionService:
    """Service for handling speech transcription operations."""
    
    def __init__(self, settings):
        """Initialize the transcription service.
        
        Args:
            settings: Application settings
        """
        self.settings = settings
        self.project_id = settings.gcp_project_id
        self.location = settings.recognizer_location
        
        # Initialize Speech clients
        self._init_clients()
    
    def _init_clients(self):
        """Initialize Google Cloud Speech clients."""
        # Configure client to use regional endpoint for v2
        client_options_var = client_options.ClientOptions(
            api_endpoint=f"{self.location}-speech.googleapis.com"
        )
        self.speech_client_v2 = SpeechClient(client_options=client_options_var)
        
        # V1 client for fallback operations
        self.speech_client_v1 = speech.SpeechClient()
    
    async def check_recognizer_exists(self, recognizer_id: str) -> bool:
        """Check if a recognizer already exists.
        
        Args:
            recognizer_id: ID of the recognizer to check
            
        Returns:
            True if recognizer exists, False otherwise
        """
        recognizer_name = (
            f"projects/{self.project_id}/locations/{self.location}/"
            f"recognizers/{recognizer_id}"
        )
        
        try:
            # Run in executor to avoid blocking
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(
                None,
                self.speech_client_v2.get_recognizer,
                {"name": recognizer_name}
            )
            return True
        except Exception:
            return False
    
    async def create_recognizer(
        self,
        recognizer_id: str,
        language_codes: List[str] = None,
        model: str = "chirp_3"
    ):
        """Create a new speech recognizer.
        
        Args:
            recognizer_id: ID for the new recognizer
            language_codes: List of supported language codes
            model: Speech recognition model to use
            
        Returns:
            Created recognizer object
        """
        if language_codes is None:
            language_codes = ["nl-NL"]
        
        parent = f"projects/{self.project_id}/locations/{self.location}"
        
        request = cloud_speech.CreateRecognizerRequest(
            parent=parent,
            recognizer_id=recognizer_id,
            recognizer=cloud_speech.Recognizer(
                default_recognition_config=cloud_speech.RecognitionConfig(
                    model=model,
                    language_codes=language_codes,
                    features=cloud_speech.RecognitionFeatures(
                        enable_automatic_punctuation=True
                    ),
                ),
            ),
        )
        
        # Run in executor to avoid blocking
        loop = asyncio.get_event_loop()
        operation = await loop.run_in_executor(
            None,
            self.speech_client_v2.create_recognizer,
            request
        )
        
        # Wait for operation to complete
        result = await loop.run_in_executor(None, operation.result)
        return result
    
    async def transcribe_audio(
        self,
        gcs_uri: str,
        language_code: str = "nl-NL",
        recognizer_id: Optional[str] = None,
        enable_diarization: bool = False,
        min_speaker_count: int = 2,
        max_speaker_count: int = 10
    ) -> str:
        """Transcribe audio from Google Cloud Storage.
        
        Args:
            gcs_uri: GCS URI of the audio file
            language_code: Language code for transcription
            recognizer_id: Optional recognizer ID to use
            enable_diarization: Enable speaker diarization
            min_speaker_count: Minimum number of speakers
            max_speaker_count: Maximum number of speakers
            
        Returns:
            Transcribed text
        """
        # Use v2 API with recognizer if available
        if recognizer_id and self.location == "us":
            return await self._transcribe_v2(gcs_uri, recognizer_id)
        else:
            return await self._transcribe_v1(
                gcs_uri,
                language_code,
                enable_diarization,
                min_speaker_count,
                max_speaker_count
            )
    
    async def _transcribe_v2(
        self,
        gcs_uri: str,
        recognizer_id: str
    ) -> str:
        """Transcribe using Speech-to-Text v2 API with recognizer.
        
        Args:
            gcs_uri: GCS URI of the audio file
            recognizer_id: Recognizer ID to use
            
        Returns:
            Transcribed text
        """
        recognizer_name = (
            f"projects/{self.project_id}/locations/{self.location}/"
            f"recognizers/{recognizer_id}"
        )
        
        # Configure recognition
        config = cloud_speech.RecognitionConfig(
            auto_decoding_config=cloud_speech.AutoDetectDecodingConfig(),
        )
        
        # Create file metadata
        file_metadata = cloud_speech.BatchRecognizeFileMetadata(uri=gcs_uri)
        
        # Create batch recognize request
        request = cloud_speech.BatchRecognizeRequest(
            recognizer=recognizer_name,
            config=config,
            files=[file_metadata],
            recognition_output_config=cloud_speech.RecognitionOutputConfig(
                inline_response_config=cloud_speech.InlineOutputConfig(),
            ),
        )
        
        # Run in executor to avoid blocking
        loop = asyncio.get_event_loop()
        operation = await loop.run_in_executor(
            None,
            self.speech_client_v2.batch_recognize,
            request
        )
        
        # Wait for operation with timeout
        response = await loop.run_in_executor(
            None,
            operation.result,
            self.settings.transcription_timeout_minutes * 60
        )
        
        # Parse the transcript
        return self._parse_v2_transcript(response, gcs_uri)
    
    async def _transcribe_v1(
        self,
        gcs_uri: str,
        language_code: str,
        enable_diarization: bool,
        min_speaker_count: int,
        max_speaker_count: int
    ) -> str:
        """Transcribe using Speech-to-Text v1 API.
        
        Args:
            gcs_uri: GCS URI of the audio file
            language_code: Language code for transcription
            enable_diarization: Enable speaker diarization
            min_speaker_count: Minimum number of speakers
            max_speaker_count: Maximum number of speakers
            
        Returns:
            Transcribed text
        """
        audio = speech.RecognitionAudio(uri=gcs_uri)
        
        config_dict = {
            "encoding": speech.RecognitionConfig.AudioEncoding.ENCODING_UNSPECIFIED,
            "language_code": language_code,
            "enable_automatic_punctuation": True,
        }
        
        # Add diarization if enabled
        if enable_diarization:
            config_dict["diarization_config"] = speech.SpeakerDiarizationConfig(
                enable_speaker_diarization=True,
                min_speaker_count=min_speaker_count,
                max_speaker_count=max_speaker_count,
            )
        
        config = speech.RecognitionConfig(**config_dict)
        
        # Run in executor to avoid blocking
        loop = asyncio.get_event_loop()
        operation = await loop.run_in_executor(
            None,
            lambda: self.speech_client_v1.long_running_recognize(
                config=config,
                audio=audio
            )
        )
        
        # Wait for operation with timeout
        response = await loop.run_in_executor(
            None,
            operation.result,
            self.settings.transcription_timeout_minutes * 60
        )
        
        # Format the transcript
        if enable_diarization:
            return self._format_diarized_transcript(response)
        else:
            return self._format_simple_transcript(response)
    
    def _parse_v2_transcript(self, response, gcs_uri: str) -> str:
        """Parse transcript from v2 API response.
        
        Args:
            response: Batch recognize response
            gcs_uri: GCS URI to match in results
            
        Returns:
            Parsed transcript text
        """
        if not response.results or gcs_uri not in response.results:
            return "Transcription finished, but no speech was detected."
        
        file_result = response.results[gcs_uri]
        
        if not file_result.transcript or not file_result.transcript.results:
            return "Transcription finished, but no speech was detected."
        
        transcript_parts = []
        for segment in file_result.transcript.results:
            if segment.alternatives:
                transcript_parts.append(segment.alternatives[0].transcript)
        
        return " ".join(transcript_parts).strip()
    
    def _format_simple_transcript(self, response) -> str:
        """Format transcript from v1 API response without diarization.
        
        Args:
            response: Long running recognize response
            
        Returns:
            Formatted transcript text
        """
        transcript_parts = []
        
        for result in response.results:
            if result.alternatives:
                transcript_parts.append(result.alternatives[0].transcript)
        
        return " ".join(transcript_parts).strip()
    
    def _format_diarized_transcript(self, response) -> str:
        """Format transcript from v1 API response with speaker diarization.
        
        Args:
            response: Long running recognize response
            
        Returns:
            Formatted transcript with speaker tags
        """
        full_transcript = []
        
        for result in response.results:
            try:
                # Reconstruct transcript from words with speaker tags
                if result.alternatives and result.alternatives[0].words:
                    current_speaker = None
                    current_text = []
                    
                    for word in result.alternatives[0].words:
                        if word.speaker_tag != current_speaker:
                            # New speaker, save previous speaker's text
                            if current_text:
                                full_transcript.append(
                                    f"Speaker {current_speaker}: {' '.join(current_text)}"
                                )
                            current_speaker = word.speaker_tag
                            current_text = [word.word]
                        else:
                            current_text.append(word.word)
                    
                    # Add last speaker's text
                    if current_text:
                        full_transcript.append(
                            f"Speaker {current_speaker}: {' '.join(current_text)}"
                        )
            except (IndexError, AttributeError):
                continue
        
        return "\n".join(full_transcript)