"""Transcription service using Google Cloud Speech-to-Text API."""

import asyncio
import os
from typing import Optional, List, Tuple, Dict, Any
from google.cloud import speech
from google.api_core import client_options
from google.cloud.speech_v2 import SpeechClient
from google.cloud.speech_v2.types import cloud_speech
from .speaker_identification import SpeakerIdentificationService


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
        
        # Initialize Speaker Identification service
        self.speaker_identification = SpeakerIdentificationService(settings)
    
    def _init_clients(self):
        """Initialize Google Cloud Speech clients."""
        # Configure client to use regional endpoint for v2
        client_options_var = client_options.ClientOptions(
            api_endpoint=f"{self.location}-speech.googleapis.com"
        )
        self.speech_client_v2 = SpeechClient(client_options=client_options_var)
        
        # V1 client for fallback operations
        self.speech_client_v1 = speech.SpeechClient()

    @staticmethod
    def _duration_to_seconds(duration: Any) -> Optional[float]:
        """Convert a protobuf duration/offset into floating-point seconds."""
        if duration is None:
            return None

        seconds = getattr(duration, "seconds", None)
        nanos = getattr(duration, "nanos", None)

        if seconds is None and hasattr(duration, "total_seconds"):
            try:
                return float(duration.total_seconds())
            except Exception:
                return None

        seconds = float(seconds or 0)
        nanos = float(nanos or 0)
        return seconds + nanos / 1_000_000_000

    def _extract_word_times(self, word) -> Tuple[Optional[float], Optional[float]]:
        """Get start and end times (seconds) for a word regardless of API version."""
        start_attr = getattr(word, "start_offset", None) or getattr(word, "start_time", None)
        end_attr = getattr(word, "end_offset", None) or getattr(word, "end_time", None)
        return self._duration_to_seconds(start_attr), self._duration_to_seconds(end_attr)

    def _build_segments_from_results(self, results) -> Tuple[str, List[Dict[str, Any]]]:
        """Convert recognition results into combined text and rich segments."""
        segments: List[Dict[str, Any]] = []
        transcript_parts: List[str] = []

        segment_index = 0

        for result in results:
            if not getattr(result, "alternatives", None):
                continue

            alternative = result.alternatives[0]
            text = (alternative.transcript or "").strip()
            if not text:
                continue

            words = list(getattr(alternative, "words", []) or [])

            start_seconds = None
            end_seconds = None
            word_payload: List[Dict[str, Any]] = []

            if words:
                start_seconds, _ = self._extract_word_times(words[0])
                _, end_seconds = self._extract_word_times(words[-1])

                for word in words:
                    word_start, word_end = self._extract_word_times(word)
                    confidence = getattr(word, "confidence", None)
                    try:
                        confidence_value = float(confidence) if confidence is not None else None
                    except (TypeError, ValueError):
                        confidence_value = None

                    word_payload.append({
                        "word": word.word,
                        "start_seconds": word_start,
                        "end_seconds": word_end,
                        "confidence": confidence_value,
                    })

            alt_confidence = getattr(alternative, "confidence", None)
            try:
                confidence_value = float(alt_confidence) if alt_confidence is not None else None
            except (TypeError, ValueError):
                confidence_value = None

            segment_index += 1

            segments.append({
                "start_seconds": start_seconds,
                "end_seconds": end_seconds,
                "confidence": confidence_value,
                "text": text,
                "words": word_payload or None,
                "refined_text": None,
                "segment_id": segment_index,
            })

            transcript_parts.append(text)

        combined_text = " ".join(transcript_parts).strip()
        return combined_text, segments
    
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
                        enable_automatic_punctuation=True,
                        enable_word_confidence=True,
                        enable_word_time_offsets=True,
                    ),
                    auto_decoding_config=cloud_speech.AutoDetectDecodingConfig(),
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
        enable_speaker_identification: bool = False,
        min_speaker_count: int = 2,
        max_speaker_count: int = 10
    ) -> Tuple[str, List[Dict[str, Any]], Optional[str], Optional[Dict[str, Any]], Optional[str]]:
        """Transcribe audio from Google Cloud Storage.
        
        Args:
            gcs_uri: GCS URI of the audio file
            language_code: Language code for transcription
            recognizer_id: Optional recognizer ID to use
            enable_diarization: Enable speaker diarization
            enable_speaker_identification: Enable LLM-based speaker identification
            min_speaker_count: Minimum number of speakers
            max_speaker_count: Maximum number of speakers
            
        Returns:
            Tuple of (
                original transcript text,
                transcript segments,
                speaker-identified transcript,
                speaker summary,
                refined transcript text
            )
        """
        # Get base transcript - disable diarization if speaker identification is enabled
        use_diarization = enable_diarization and not enable_speaker_identification
        
        # Use v2 API with recognizer if available
        recognizer_to_use = recognizer_id or self.settings.default_recognizer_id
        print(
            "Transcription configuration:",
            {
                "recognizer_id": recognizer_id,
                "recognizer_to_use": recognizer_to_use,
                "location": self.location,
                "speech_model": self.settings.speech_model,
                "using_v2": bool(recognizer_to_use and self.location in ["us", "europe-west4"]),
                "language_code": language_code,
            }
        )

        if recognizer_to_use and self.location in ["us", "europe-west4"]:
            transcript, transcript_segments = await self._transcribe_v2(
                gcs_uri,
                recognizer_to_use,
                language_code or self.settings.default_language_code
            )
        else:
            transcript, transcript_segments = await self._transcribe_v1(
                gcs_uri,
                language_code,
                use_diarization,
                min_speaker_count,
                max_speaker_count
            )

        speaker_transcript: Optional[str] = None
        speaker_summary: Optional[Dict[str, Any]] = None
        refined_transcript: Optional[str] = None
        llm_segments: List[Dict[str, Any]] = []

        # Apply speaker identification if enabled
        if enable_speaker_identification:
            try:
                identification_result = await self.speaker_identification.identify_speakers(transcript)
                speaker_transcript = self.speaker_identification.format_transcript_with_speakers(identification_result)
                speaker_summary = self.speaker_identification.get_speaker_summary(identification_result)
                refined_transcript = self.speaker_identification.get_refined_transcript(identification_result)
                llm_segments = identification_result.get("segments", []) or []
            except Exception as e:
                print(f"Speaker identification failed: {e}")

        if llm_segments:
            refined_values = [
                (segment.get("refined_text") or segment.get("text") or "").strip()
                for segment in llm_segments
                if (segment.get("refined_text") or segment.get("text"))
            ]

            if refined_values:
                refined_assignments = self._align_refined_segments(refined_values, transcript_segments)
                for segment, refined_value in zip(transcript_segments, refined_assignments):
                    if refined_value:
                        segment["refined_text"] = refined_value

        return transcript, transcript_segments, speaker_transcript, speaker_summary, refined_transcript

    def _align_refined_segments(
        self,
        refined_segments: List[str],
        base_segments: List[Dict[str, Any]]
    ) -> List[Optional[str]]:
        """Distribute refined text segments over base transcript segments."""

        if not base_segments:
            return []

        if not refined_segments:
            return [None] * len(base_segments)

        # Calculate reference lengths using original text
        base_lengths = [len((segment.get("text") or "").strip()) or 1 for segment in base_segments]
        total_base = sum(base_lengths) or 1
        total_refined = sum(len(value) for value in refined_segments) or 1

        refined_assignments: List[Optional[str]] = []
        refined_index = 0

        for i, base_len in enumerate(base_lengths):
            if refined_index >= len(refined_segments):
                refined_assignments.append(None)
                continue

            target_chars = (base_len / total_base) * total_refined
            collected: List[str] = []
            collected_chars = 0

            while refined_index < len(refined_segments):
                segment_text = refined_segments[refined_index]
                segment_len = len(segment_text)

                # Always take at least one segment per base slot
                if not collected:
                    collected.append(segment_text)
                    collected_chars += segment_len
                    refined_index += 1
                    continue

                # Decide whether to add another refined piece based on relative length
                if collected_chars >= target_chars or i == len(base_lengths) - 1:
                    break

                collected.append(segment_text)
                collected_chars += segment_len
                refined_index += 1

            if i == len(base_lengths) - 1 and refined_index < len(refined_segments):
                remaining = " ".join(refined_segments[refined_index:]).strip()
                if remaining:
                    collected.append(remaining)
                refined_index = len(refined_segments)

            refined_assignments.append(" ".join(collected).strip())

        return refined_assignments
    
    async def _transcribe_v2(
        self,
        gcs_uri: str,
        recognizer_id: str,
        language_code: str
    ) -> Tuple[str, List[Dict[str, Any]]]:
        """Transcribe using Speech-to-Text v2 API with recognizer.
        
        Args:
            gcs_uri: GCS URI of the audio file
            recognizer_id: Recognizer ID to use
            
        Returns:
            Tuple containing transcript text and segment metadata
        """
        recognizer_name = (
            f"projects/{self.project_id}/locations/{self.location}/"
            f"recognizers/{recognizer_id}"
        )
        
        # Configure recognition
        features = cloud_speech.RecognitionFeatures(
            enable_automatic_punctuation=True,
            enable_word_confidence=True,
            enable_word_time_offsets=True,
        )

        config = cloud_speech.RecognitionConfig(
            auto_decoding_config=cloud_speech.AutoDetectDecodingConfig(),
            language_codes=[language_code or self.settings.default_language_code],
            model=self.settings.speech_model,
            features=features,
        )
        print(
            "V2 recognition request:",
            {
                "recognizer": recognizer_name,
                "language_codes": config.language_codes,
                "model": config.model,
            }
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
    ) -> Tuple[str, List[Dict[str, Any]]]:
        """Transcribe using Speech-to-Text v1 API.
        
        Args:
            gcs_uri: GCS URI of the audio file
            language_code: Language code for transcription
            enable_diarization: Enable speaker diarization
            min_speaker_count: Minimum number of speakers
            max_speaker_count: Maximum number of speakers
            
        Returns:
            Tuple containing transcript text and segment metadata
        """
        audio = speech.RecognitionAudio(uri=gcs_uri)

        config_dict: Dict[str, Any] = {
            "language_code": language_code,
            "enable_automatic_punctuation": True,
            "enable_word_time_offsets": True,
            "enable_word_confidence": True,
            "max_alternatives": 1,
        }
        print(
            "Using v1 transcription:",
            {
                "location": self.location,
                "language_code": language_code,
                "config": config_dict,
            }
        )

        encoding = self._determine_audio_encoding(gcs_uri)
        if encoding is not None:
            config_dict["encoding"] = encoding

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

    def _determine_audio_encoding(
        self,
        gcs_uri: str
    ) -> Optional[speech.RecognitionConfig.AudioEncoding]:
        """Infer the most suitable audio encoding from the GCS URI."""

        filename = gcs_uri.rsplit('/', 1)[-1].lower()
        _, ext = os.path.splitext(filename)

        encoding_map = {
            ".wav": speech.RecognitionConfig.AudioEncoding.LINEAR16,
            ".flac": speech.RecognitionConfig.AudioEncoding.FLAC,
            ".ogg": speech.RecognitionConfig.AudioEncoding.OGG_OPUS,
            ".opus": speech.RecognitionConfig.AudioEncoding.OGG_OPUS,
            ".webm": getattr(speech.RecognitionConfig.AudioEncoding, "WEBM_OPUS", None),
            ".mp3": getattr(speech.RecognitionConfig.AudioEncoding, "MP3", None),
            ".m4a": getattr(speech.RecognitionConfig.AudioEncoding, "MP4", None),
        }

        encoding = encoding_map.get(ext)

        if isinstance(encoding, int):
            return encoding

        return None
    
    def _parse_v2_transcript(self, response, gcs_uri: str) -> Tuple[str, List[Dict[str, Any]]]:
        """Parse transcript from v2 API response.
        
        Args:
            response: Batch recognize response
            gcs_uri: GCS URI to match in results
            
        Returns:
            Parsed transcript text
        """
        if not response.results or gcs_uri not in response.results:
            return "", []

        file_result = response.results[gcs_uri]

        if not file_result.transcript or not file_result.transcript.results:
            return "", []

        return self._build_segments_from_results(file_result.transcript.results)

    def _format_simple_transcript(self, response) -> Tuple[str, List[Dict[str, Any]]]:
        """Format transcript from v1 API response without diarization."""

        results = getattr(response, "results", [])
        return self._build_segments_from_results(results)

    def _format_diarized_transcript(self, response) -> Tuple[str, List[Dict[str, Any]]]:
        """Format transcript from v1 API response with speaker diarization.
        
        Args:
            response: Long running recognize response
            
        Returns:
            Formatted transcript with speaker tags
        """
        base_text, segments = self._build_segments_from_results(getattr(response, "results", []))
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

        diarized_text = "\n".join(full_transcript).strip()
        return (diarized_text or base_text, segments)
