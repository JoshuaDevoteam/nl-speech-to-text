"""Speaker identification service using LangChain and Google Vertex AI Gemini."""

import asyncio
import json
import re
from dataclasses import dataclass
from typing import Any, Dict, List, Optional, Sequence

from langchain_core.messages import HumanMessage, SystemMessage
from langchain_google_vertexai import ChatVertexAI


@dataclass
class TranscriptSegment:
    """Represents a transcript span that can be assigned to a speaker."""

    segment_id: int
    text: str
    prompt_text: str
    start_index: int
    end_index: int


class SpeakerIdentificationService:
    """Service for identifying speakers in transcripts using LLM analysis."""

    MIN_SEGMENT_CHARS = 35
    MAX_SEGMENT_CHARS = 320
    MAX_SEGMENTS_PER_REQUEST = 60

    def __init__(self, settings):
        """Initialize the speaker identification service.

        Args:
            settings: Application settings
        """

        self.settings = settings
        self.project_id = settings.gcp_project_id
        self.location = settings.gcp_location

        # Initialize Gemini model via LangChain
        self.llm = ChatVertexAI(
            model_name="gemini-2.5-pro",
            project=self.project_id,
            location=self.location,
            temperature=0.3,  # Low temperature for consistent analysis
        )

    async def identify_speakers(self, transcript: str) -> Dict:
        """Identify speakers in a transcript using LLM analysis.

        Args:
            transcript: Plain transcript text

        Returns:
            Dictionary containing speaker identification results
        """

        if not transcript or not transcript.strip():
            return self._create_fallback_response(transcript)

        try:
            segments = self._segment_transcript(transcript)
            if not segments:
                return self._create_fallback_response(transcript)

            known_speakers: Dict[str, Dict[str, Any]] = {}
            assignments: Dict[int, Dict[str, Any]] = {}
            collected_notes: List[str] = []
            confidence_values: List[str] = []

            loop = asyncio.get_event_loop()

            for chunk in self._chunk_segments(segments):
                messages = self._create_prompt_messages(chunk, known_speakers)

                response = await loop.run_in_executor(
                    None,
                    self.llm.invoke,
                    messages
                )

                chunk_result = self._parse_chunk_response(response.content, chunk)

                if chunk_result.get("notes"):
                    collected_notes.append(chunk_result["notes"])

                if chunk_result.get("overall_confidence"):
                    confidence_values.append(chunk_result["overall_confidence"])

                for speaker in chunk_result.get("speakers", []) or []:
                    label = speaker.get("label")
                    if not label:
                        continue
                    if label not in known_speakers:
                        known_speakers[label] = speaker
                    else:
                        for key, value in speaker.items():
                            if value:
                                known_speakers[label][key] = value

                for segment_id, assignment in chunk_result.get("assignments", {}).items():
                    assignments[segment_id] = assignment

            if not assignments:
                return self._create_fallback_response(transcript)

            final_segments = []
            unique_speakers = set()

            for segment in segments:
                assignment = assignments.get(segment.segment_id)

                if assignment:
                    speaker_label = assignment.get("speaker", "Spreker A")
                    confidence = assignment.get("confidence", "medium")
                    refined_text = assignment.get("refined_text")
                else:
                    speaker_label = "Spreker A"
                    confidence = "low"
                    refined_text = None

                unique_speakers.add(speaker_label)

                final_segments.append({
                    "speaker": speaker_label,
                    "text": segment.text,
                    "refined_text": refined_text,
                    "start_index": segment.start_index,
                    "end_index": segment.end_index,
                    "confidence": confidence,
                    "segment_id": segment.segment_id
                })

            total_speakers = max(len(unique_speakers), 1)
            overall_confidence = self._aggregate_confidence(confidence_values)
            notes = "\n".join(note.strip() for note in collected_notes if note and note.strip())

            result = {
                "speakers_identified": total_speakers > 1,
                "total_speakers": total_speakers,
                "segments": final_segments,
                "confidence": overall_confidence,
                "notes": notes,
            }

            if not self._validate_final_result(result):
                raise ValueError("Speaker identification result failed validation")

            return result

        except Exception as exc:  # pragma: no cover - safety net
            print(f"Error in speaker identification: {exc}")
            return self._create_fallback_response(transcript)

    def _segment_transcript(self, transcript: str) -> List[TranscriptSegment]:
        """Split transcript into manageable segments for LLM analysis."""

        normalized = transcript.replace("\r\n", "\n")
        if not normalized.strip():
            return []

        sentence_pattern = re.compile(r"[^.!?\n]+[.!?\n]*", re.MULTILINE)
        raw_segments: List[Dict[str, Any]] = []

        for match in sentence_pattern.finditer(normalized):
            raw_text = match.group()
            if not raw_text or not raw_text.strip():
                continue

            leading_ws = len(raw_text) - len(raw_text.lstrip())
            trailing_ws = len(raw_text) - len(raw_text.rstrip())

            start = match.start() + leading_ws
            end = match.end() - trailing_ws
            text = raw_text.strip()

            if text:
                raw_segments.append({
                    "text": text,
                    "start": start,
                    "end": end
                })

        if not raw_segments:
            stripped = normalized.strip()
            if not stripped:
                return []
            start = normalized.find(stripped)
            end = start + len(stripped)
            raw_segments.append({"text": stripped, "start": start, "end": end})

        merged: List[Dict[str, Any]] = []
        buffer: Optional[Dict[str, Any]] = None

        for segment in raw_segments:
            segment_text = segment["text"]

            if buffer is None:
                buffer = segment.copy()
                continue

            candidate_text = f"{buffer['text']} {segment_text}".strip()

            if len(buffer["text"]) < self.MIN_SEGMENT_CHARS or len(candidate_text) <= self.MAX_SEGMENT_CHARS:
                buffer["text"] = candidate_text
                buffer["end"] = segment["end"]
            else:
                merged.append(buffer)
                buffer = segment.copy()

        if buffer:
            merged.append(buffer)

        # Ensure trailing small segment is merged if very short
        if len(merged) >= 2 and len(merged[-1]["text"]) < self.MIN_SEGMENT_CHARS:
            tail = merged.pop()
            merged[-1]["text"] = f"{merged[-1]['text']} {tail['text']}".strip()
            merged[-1]["end"] = tail["end"]

        segments: List[TranscriptSegment] = []

        for idx, segment in enumerate(merged, start=1):
            prompt_text = re.sub(r"\s+", " ", segment["text"]).strip()
            segments.append(
                TranscriptSegment(
                    segment_id=idx,
                    text=segment["text"],
                    prompt_text=prompt_text,
                    start_index=segment["start"],
                    end_index=segment["end"]
                )
            )

        return segments

    def _chunk_segments(self, segments: Sequence[TranscriptSegment]) -> List[List[TranscriptSegment]]:
        """Chunk segments to respect token limits for the LLM."""

        return [
            list(segments[i:i + self.MAX_SEGMENTS_PER_REQUEST])
            for i in range(0, len(segments), self.MAX_SEGMENTS_PER_REQUEST)
        ]

    def _create_prompt_messages(
        self,
        chunk: Sequence[TranscriptSegment],
        known_speakers: Dict[str, Dict[str, Any]]
    ) -> List:
        """Create prompt messages for a chunk of transcript segments."""

        speaker_guidance = "Nog geen bekende sprekers. Introduceer nieuwe labels als Spreker A, Spreker B, etc."
        if known_speakers:
            formatted = []
            for label, info in known_speakers.items():
                description = info.get("description") or info.get("summary") or ""
                aliases = info.get("aliases") or info.get("alias")
                alias_text = ""
                if aliases:
                    if isinstance(aliases, str):
                        alias_text = f" (alias: {aliases})"
                    elif isinstance(aliases, list):
                        alias_text = f" (alias: {', '.join(aliases)})"
                formatted.append(f"{label}: {description}{alias_text}".strip())
            speaker_guidance = "Bekende sprekers – gebruik exact deze labels waar mogelijk:\n" + "\n".join(formatted)

        segment_lines = "\n".join(
            f"{segment.segment_id}. {segment.prompt_text}"
            for segment in chunk
        )

        system_prompt = (
            "Je bent een expert in het analyseren van Nederlandse gesprekken en het consistent "
            "labelen van sprekers. Gebruik alleen labels in de vorm \"Spreker A\", \"Spreker B\", enzovoort. "
            "Hergebruik bestaande labels wanneer dezelfde persoon spreekt. Je mag zinnen heel licht "
            "herformuleren voor duidelijkheid, maar behoud altijd exacte betekenis, intentie en chronologie."
        )

        human_prompt = f"""Analyseer de volgende transcriptsegmenten en wijs elke regel toe aan precies één spreker.

{speaker_guidance}

Segmenten:
{segment_lines}

Beantwoord uitsluitend met één JSON-object met exact de volgende structuur:
{{
  "overall_confidence": "high|medium|low",
  "speakers": [
    {{ "label": "Spreker A", "description": "korte beschrijving van deze spreker", "aliases": ["alias", "bijnaam"] }}
  ],
  "segments": [
    {{ "segment_id": 12, "speaker": "Spreker A", "confidence": "high|medium|low", "reason": "relevante aanwijzingen", "refined_text": "optioneel licht verbeterde zin" }}
  ],
  "notes": "eventuele observaties of onzekerheden"
}}

Richtlijnen:
1. Gebruik elk segment_id precies één keer en gebruik geen ids die niet in de lijst voorkomen.
2. Introduceer alleen nieuwe labels wanneer echt nodig en ga alfabetisch verder.
3. Als een segment meerdere stemmen bevat, kies de dominante stem en licht dit toe in de reason of notes.
4. Houd de beschrijvingen, redenen en eventuele refined_text beknopt en wijzig alleen een zin wanneer dit de leesbaarheid verbetert zonder nieuwe informatie toe te voegen.
5. Laat refined_text weg wanneer je niets hoeft te verbeteren.
"""

        return [
            SystemMessage(content=system_prompt),
            HumanMessage(content=human_prompt)
        ]

    def _parse_chunk_response(self, response_text: str, chunk: Sequence[TranscriptSegment]) -> Dict[str, Any]:
        """Parse and normalise the LLM response for a chunk."""

        json_payload = self._extract_json(response_text)

        if not json_payload or not isinstance(json_payload, dict):
            raise ValueError("LLM response could not be parsed as JSON")

        segments_field = json_payload.get("segments")
        if not isinstance(segments_field, list):
            raise ValueError("LLM response missing segments list")

        valid_ids = {segment.segment_id for segment in chunk}
        assignments: Dict[int, Dict[str, Any]] = {}

        for item in segments_field:
            if not isinstance(item, dict):
                continue
            segment_id = item.get("segment_id")
            speaker = item.get("speaker")
            if segment_id not in valid_ids or not isinstance(speaker, str):
                continue

            confidence = item.get("confidence")
            if not isinstance(confidence, str):
                confidence = json_payload.get("overall_confidence", "medium")

            refined_text = item.get("refined_text")
            if isinstance(refined_text, str):
                refined_text = refined_text.strip()
                if not refined_text:
                    refined_text = None
            else:
                refined_text = None

            assignments[int(segment_id)] = {
                "speaker": speaker.strip() or "Spreker A",
                "confidence": confidence.strip().lower() if confidence else "medium",
                "refined_text": refined_text
            }

        if not assignments:
            raise ValueError("LLM response did not contain any valid assignments")

        return {
            "assignments": assignments,
            "speakers": json_payload.get("speakers"),
            "notes": json_payload.get("notes"),
            "overall_confidence": json_payload.get("overall_confidence") or "medium"
        }

    def _extract_json(self, response_text: str) -> Optional[Dict[str, Any]]:
        """Extract a JSON payload from the raw LLM response."""

        if not response_text:
            return None

        stripped = response_text.strip()
        try:
            return json.loads(stripped)
        except json.JSONDecodeError:
            pass

        json_start = stripped.find('{')
        json_end = stripped.rfind('}') + 1

        if json_start >= 0 and json_end > json_start:
            candidate = stripped[json_start:json_end]
            try:
                return json.loads(candidate)
            except json.JSONDecodeError:
                return None

        return None

    def _aggregate_confidence(self, values: Sequence[str]) -> str:
        """Aggregate confidence values from multiple chunks."""

        if not values:
            return "medium"

        mapping = {"low": 1, "medium": 2, "high": 3}
        scores = [mapping.get(value.lower(), 2) for value in values if isinstance(value, str)]

        if not scores:
            return "medium"

        average = sum(scores) / len(scores)

        if average >= 2.5:
            return "high"
        if average <= 1.5:
            return "low"
        return "medium"

    def _validate_final_result(self, result: Dict[str, Any]) -> bool:
        """Validate the final combined speaker identification result."""

        required_keys = {"speakers_identified", "total_speakers", "segments", "confidence"}
        if not required_keys.issubset(result.keys()):
            return False

        segments = result.get("segments")
        if not isinstance(segments, list) or not segments:
            return False

        for item in segments:
            if not isinstance(item, dict):
                return False
            for key in ("speaker", "text", "start_index", "end_index"):
                if key not in item:
                    return False

        return True
    
    def _create_fallback_response(self, transcript: str) -> Dict:
        """Create a fallback response when speaker identification fails.
        
        Args:
            transcript: Original transcript text
            
        Returns:
            Fallback response dictionary
        """
        return {
            "speakers_identified": False,
            "total_speakers": 1,
            "segments": [
                {
                    "speaker": "Onbekende Spreker",
                    "text": transcript,
                    "refined_text": transcript,
                    "start_index": 0,
                    "end_index": len(transcript),
                    "segment_id": 1
                }
            ],
            "confidence": "low",
            "notes": "Automatische spreker-identificatie is mislukt. Originele transcript weergegeven."
        }
    
    def format_transcript_with_speakers(self, identification_result: Dict) -> str:
        """Format the identified speakers into a readable transcript.
        
        Args:
            identification_result: Result from identify_speakers()
            
        Returns:
            Formatted transcript with speaker labels
        """
        if not identification_result.get("speakers_identified", False):
            return identification_result["segments"][0]["text"]
        
        formatted_parts = []
        
        for segment in identification_result["segments"]:
            speaker = segment["speaker"]
            text_value = segment.get("refined_text") or segment.get("text") or ""
            text = text_value.strip()
            
            if text:
                formatted_parts.append(f"{speaker}: {text}")
        
        return "\n\n".join(formatted_parts)
    
    def get_speaker_summary(self, identification_result: Dict) -> Dict:
        """Get a summary of identified speakers.

        Args:
            identification_result: Result from identify_speakers()
            
        Returns:
            Summary dictionary with speaker statistics
        """
        if not identification_result.get("speakers_identified", False):
            return {
                "total_speakers": 1,
                "confidence": identification_result.get("confidence", "low"),
                "speakers": ["Onbekende Spreker"],
                "notes": identification_result.get("notes", "")
            }
        
        speakers = list(set(segment["speaker"] for segment in identification_result["segments"]))
        
        return {
            "total_speakers": len(speakers),
            "confidence": identification_result.get("confidence", "unknown"),
            "speakers": sorted(speakers),
            "notes": identification_result.get("notes", "")
        }

    def get_refined_transcript(self, identification_result: Dict) -> Optional[str]:
        """Build a lightly refined transcript without speaker labels."""

        segments = identification_result.get("segments") or []
        refined_parts: List[str] = []

        for segment in segments:
            text_source = segment.get("refined_text") or segment.get("text") or ""
            text = text_source.strip()
            if text:
                refined_parts.append(text)

        if not refined_parts:
            return None

        return "\n\n".join(refined_parts)
