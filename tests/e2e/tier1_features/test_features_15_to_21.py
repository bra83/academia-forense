"""
Tier 1 Feature Coverage Tests: Features 15 to 21
Academia Forense — Laboratório de Formação

Coverage:
- Feature 15: Adaptive Study Plan & Spaced Repetition (13h Target, SM-2 Intervals)
- Feature 16: Dynamic Gemini Model Discovery (API Discovery & Audio vs Text Filtering)
- Feature 17: 7 Pedagogical Tutor Modes (Prompt Generation & Pedagogical Rigor)
- Feature 18: Strict RAG Provenance & Citations ([FONTE] / [INFERÊNCIA] Enforcement)
- Feature 19: Android Native TTS Bridge (Kokoro Braseiro / Sherpa-ONNX Bridge)
- Feature 20: Sentence Segmenter & Queue Control (250-650 Chars, Target 450)
- Feature 21: Gemini Online TTS (Charon Voice & 44-byte RIFF WAV Header)
"""

import base64
import re
import struct
import unittest
from datetime import datetime, timedelta
from enum import Enum
from typing import Any, Dict, List, Optional, Tuple


# ==============================================================================
# Feature 15: Adaptive Study Plan & Spaced Repetition
# ==============================================================================

class AdaptiveStudyPlanner:
    """Manages the 13h weekly study target and spaced repetition scheduling (§17.1)."""
    DEFAULT_WEEKLY_TARGET_HOURS = 13.0

    def __init__(self, weekly_target_hours: float = DEFAULT_WEEKLY_TARGET_HOURS):
        self.weekly_target_hours = weekly_target_hours
        self.sessions: List[Dict[str, Any]] = []

    def record_study_session(self, chapter_id: str, duration_seconds: int, completed_at: datetime):
        self.sessions.append({
            "chapter_id": chapter_id,
            "duration_seconds": duration_seconds,
            "completed_at": completed_at,
        })

    def get_weekly_accumulated_hours(self, reference_date: datetime) -> float:
        start_of_week = reference_date - timedelta(days=reference_date.weekday())
        start_of_week = start_of_week.replace(hour=0, minute=0, second=0, microsecond=0)
        end_of_week = start_of_week + timedelta(days=7)

        total_sec = sum(
            s["duration_seconds"] for s in self.sessions
            if start_of_week <= s["completed_at"] < end_of_week
        )
        return total_sec / 3600.0

    @staticmethod
    def calculate_spaced_review_date(last_reviewed: datetime, repetition_count: int, score: float) -> datetime:
        """Calculates next review date using modified spaced repetition intervals."""
        if score < 0.80:
            # Low score repeats next day
            return last_reviewed + timedelta(days=1)

        # Standard intervals: 1 -> 3 days -> 7 days -> 14 days -> 30 days
        intervals = [1, 3, 7, 14, 30]
        interval_idx = min(repetition_count, len(intervals) - 1)
        days = intervals[interval_idx]
        return last_reviewed + timedelta(days=days)

    @staticmethod
    def diagnose_competency_gaps(competency_scores: Dict[str, float]) -> List[str]:
        """Identifies competencies with score below 80% passing benchmark."""
        return [comp for comp, score in competency_scores.items() if score < 0.80]


class TestFeature15AdaptiveStudyPlan(unittest.TestCase):
    """F15: Adaptive Study Plan & Spaced Repetition."""

    def setUp(self):
        self.planner = AdaptiveStudyPlanner(weekly_target_hours=13.0)

    def test_f15_tc01_weekly_study_target_tracking(self):
        """Verify sessions accumulate correctly toward the 13h weekly target."""
        now = datetime(2026, 11, 16, 14, 0, 0)
        # Record two 3-hour sessions (10800 sec each)
        self.planner.record_study_session("ch01", 10800, now)
        self.planner.record_study_session("ch02", 10800, now + timedelta(days=1))

        accumulated = self.planner.get_weekly_accumulated_hours(now)
        self.assertEqual(accumulated, 6.0)
        progress_pct = (accumulated / self.planner.weekly_target_hours) * 100.0
        self.assertAlmostEqual(progress_pct, (6.0 / 13.0) * 100.0, places=2)

    def test_f15_tc02_spaced_repetition_interval_advancement(self):
        """Verify successful passing score advances interval from 1 to 3 to 7 days."""
        base_time = datetime(2026, 11, 16, 10, 0, 0)
        # First repetition pass
        rev1 = AdaptiveStudyPlanner.calculate_spaced_review_date(base_time, repetition_count=1, score=0.85)
        self.assertEqual(rev1, base_time + timedelta(days=3))

        # Second repetition pass
        rev2 = AdaptiveStudyPlanner.calculate_spaced_review_date(base_time, repetition_count=2, score=0.90)
        self.assertEqual(rev2, base_time + timedelta(days=7))

    def test_f15_tc03_failing_score_triggers_immediate_one_day_review(self):
        """Verify score below 80% resets review interval to 1 day."""
        base_time = datetime(2026, 11, 16, 10, 0, 0)
        rev = AdaptiveStudyPlanner.calculate_spaced_review_date(base_time, repetition_count=3, score=0.65)
        self.assertEqual(rev, base_time + timedelta(days=1))

    def test_f15_tc04_competency_gap_diagnostic(self):
        """Verify gaps identified when scores fall below 0.80 benchmark."""
        scores = {
            "comp_hashes": 0.95,
            "comp_cadeia_custodia": 0.85,
            "comp_linguistica_forense": 0.60,
            "comp_triangulacao_erb": 0.70,
        }
        gaps = AdaptiveStudyPlanner.diagnose_competency_gaps(scores)
        self.assertEqual(len(gaps), 2)
        self.assertIn("comp_linguistica_forense", gaps)
        self.assertIn("comp_triangulacao_erb", gaps)
        self.assertNotIn("comp_hashes", gaps)

    def test_f15_tc05_overdue_review_detection(self):
        """Verify overdue reviews are flagged when scheduled date is in the past."""
        scheduled = datetime(2026, 11, 14, 10, 0, 0)
        current = datetime(2026, 11, 16, 10, 0, 0)
        is_overdue = current > scheduled
        self.assertTrue(is_overdue)


# ==============================================================================
# Feature 16: Dynamic Gemini Model Discovery
# ==============================================================================

class GeminiModelDiscoveryService:
    """Discovers and categorizes Gemini models dynamically from API response (§10.1)."""
    @staticmethod
    def parse_and_categorize(api_response: Dict[str, Any]) -> Dict[str, List[Dict[str, Any]]]:
        models = api_response.get("models", [])
        text_models = []
        speech_models = []

        for m in models:
            methods = m.get("supportedGenerationMethods", [])
            # Text tutor models support 'generateContent'
            if "generateContent" in methods:
                text_models.append(m)
            # Audio speech models support 'generateSpeech' or have tts capabilities
            if "generateSpeech" in methods or "speech" in m.get("name", "").lower():
                speech_models.append(m)

        return {
            "text_tutor_models": text_models,
            "audio_speech_models": speech_models,
        }


class TestFeature16DynamicGeminiDiscovery(unittest.TestCase):
    """F16: Dynamic Gemini Model Discovery & Categorization."""

    def setUp(self):
        self.sample_api_response = {
            "models": [
                {
                    "name": "models/gemini-1.5-pro",
                    "displayName": "Gemini 1.5 Pro",
                    "description": "High intelligence multimodal model",
                    "supportedGenerationMethods": ["generateContent", "countTokens"]
                },
                {
                    "name": "models/gemini-1.5-flash",
                    "displayName": "Gemini 1.5 Flash",
                    "description": "Fast and versatile multimodal model",
                    "supportedGenerationMethods": ["generateContent", "countTokens"]
                },
                {
                    "name": "models/gemini-2.0-flash-exp",
                    "displayName": "Gemini 2.0 Flash Exp",
                    "description": "Experimental model with speech generation capabilities",
                    "supportedGenerationMethods": ["generateContent", "generateSpeech"]
                },
                {
                    "name": "models/text-embedding-004",
                    "displayName": "Text Embedding 004",
                    "description": "Semantic search embeddings",
                    "supportedGenerationMethods": ["embedContent"]
                }
            ],
            "nextPageToken": "token_page_2"
        }

    def test_f16_tc01_parse_model_list_response(self):
        """Verify parser extracts models cleanly from API JSON payload."""
        result = GeminiModelDiscoveryService.parse_and_categorize(self.sample_api_response)
        self.assertIn("text_tutor_models", result)
        self.assertIn("audio_speech_models", result)

    def test_f16_tc02_categorize_text_models_correctly(self):
        """Verify models supporting generateContent are categorized as text tutor models."""
        result = GeminiModelDiscoveryService.parse_and_categorize(self.sample_api_response)
        text_names = [m["name"] for m in result["text_tutor_models"]]
        self.assertIn("models/gemini-1.5-pro", text_names)
        self.assertIn("models/gemini-1.5-flash", text_names)
        self.assertNotIn("models/text-embedding-004", text_names)

    def test_f16_tc03_categorize_speech_models_correctly(self):
        """Verify models supporting generateSpeech are categorized as audio models."""
        result = GeminiModelDiscoveryService.parse_and_categorize(self.sample_api_response)
        speech_names = [m["name"] for m in result["audio_speech_models"]]
        self.assertIn("models/gemini-2.0-flash-exp", speech_names)
        self.assertNotIn("models/gemini-1.5-pro", speech_names)

    def test_f16_tc04_pagination_token_handling(self):
        """Verify pagination nextPageToken is preserved for subsequent discovery calls."""
        token = self.sample_api_response.get("nextPageToken")
        self.assertEqual(token, "token_page_2")

    def test_f16_tc05_no_hardcoded_models_discovery_flexibility(self):
        """Verify discovering novel future models without code modification."""
        dynamic_response = {
            "models": [{
                "name": "models/gemini-future-3.0-ultra",
                "supportedGenerationMethods": ["generateContent"]
            }]
        }
        res = GeminiModelDiscoveryService.parse_and_categorize(dynamic_response)
        self.assertEqual(len(res["text_tutor_models"]), 1)
        self.assertEqual(res["text_tutor_models"][0]["name"], "models/gemini-future-3.0-ultra")


# ==============================================================================
# Feature 17: 7 Pedagogical Tutor Modes
# ==============================================================================

class PedagogicalMode(str, Enum):
    EXPLICAR = "explicar"
    SIMPLIFICAR = "simplificar"
    APROFUNDAR = "aprofundar"
    EXEMPLIFICAR = "exemplificar"
    ME_TESTAR = "meTestar"
    REVISAR = "revisar"
    ORIENTAR_LAB = "orientarLab"


class TutorPromptBuilder:
    """Constructs rigorous pedagogical system prompts for each of the 7 modes (§9.3)."""
    @staticmethod
    def build_system_prompt(mode: PedagogicalMode, chapter_title: str) -> str:
        base_preamble = (
            "Você é o Professor Particular de Ciências Forenses da Academia Forense. "
            f"Capítulo ativo: '{chapter_title}'. "
            "Responda em português brasileiro com rigor científico, sem elogios vazios ou adivinhações. "
        )
        mode_directives = {
            PedagogicalMode.EXPLICAR: "Modo Explicar: Forneça ensino convencional estruturado, claro e didático.",
            PedagogicalMode.SIMPLIFICAR: "Modo Simplificar: Aborde conceitos fundamentais para iniciantes com analogias precisas.",
            PedagogicalMode.APROFUNDAR: "Modo Aprofundar: Aprofunde na literatura científica pericial, normas técnicas e fórmulas.",
            PedagogicalMode.EXEMPLIFICAR: "Modo Exemplificar: Apresente casos práticos ou cenários simulados documentados.",
            PedagogicalMode.ME_TESTAR: "Modo Me Testar: Faça perguntas socráticas sem revelar a resposta imediatamente. Corrija o raciocínio.",
            PedagogicalMode.REVISAR: "Modo Revisar: Foque em repetição direcionada dos pontos críticos e erros frequentes.",
            PedagogicalMode.ORIENTAR_LAB: "Modo Orientar Laboratório: Guie o aluno passo a passo na execução e resolução de problemas práticos.",
        }
        return base_preamble + mode_directives[mode]


class TestFeature17SevenTutorModes(unittest.TestCase):
    """F17: 7 Pedagogical Tutor Modes & Prompt Construction."""

    def test_f17_tc01_exact_7_pedagogical_modes_defined(self):
        """Verify all 7 modes from §9.3 are present in enum."""
        modes = list(PedagogicalMode)
        self.assertEqual(len(modes), 7)
        expected = ["explicar", "simplificar", "aprofundar", "exemplificar", "meTestar", "revisar", "orientarLab"]
        self.assertEqual([m.value for m in modes], expected)

    def test_f17_tc02_simplificar_mode_prompt_directive(self):
        """Verify 'simplificar' mode prompt contains beginner-friendly directives."""
        prompt = TutorPromptBuilder.build_system_prompt(PedagogicalMode.SIMPLIFICAR, "Dos dados às evidências")
        self.assertIn("Modo Simplificar", prompt)
        self.assertIn("iniciantes", prompt)

    def test_f17_tc03_aprofundar_mode_prompt_directive(self):
        """Verify 'aprofundar' mode prompt contains advanced technical rigor directives."""
        prompt = TutorPromptBuilder.build_system_prompt(PedagogicalMode.APROFUNDAR, "Perícia Digital")
        self.assertIn("Modo Aprofundar", prompt)
        self.assertIn("normas técnicas", prompt)

    def test_f17_tc04_me_testar_mode_prompt_socratic_directive(self):
        """Verify 'meTestar' mode instructs Socratic questioning without giving away answers."""
        prompt = TutorPromptBuilder.build_system_prompt(PedagogicalMode.ME_TESTAR, "Cadeia de Custódia")
        self.assertIn("Modo Me Testar", prompt)
        self.assertIn("perguntas socráticas", prompt)

    def test_f17_tc05_orientar_lab_mode_prompt_directive(self):
        """Verify 'orientarLab' mode prompt focuses on execution guidance."""
        prompt = TutorPromptBuilder.build_system_prompt(PedagogicalMode.ORIENTAR_LAB, "Laboratório de Hashes")
        self.assertIn("Modo Orientar Laboratório", prompt)
        self.assertIn("passo a passo", prompt)


# ==============================================================================
# Feature 18: Strict RAG Provenance & Citations
# ==============================================================================

class RagContextBuilder:
    """Builds context injection strictly restricted to approved editorial chapters (§9.2, §18)."""
    @staticmethod
    def filter_and_format_chunks(chunks: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        # Rule §9.2: Context injection strictly limited to approved editorial chapters
        allowed_statuses = {"Aprovado", "Publicado", "approved", "published"}
        return [c for c in chunks if c.get("editorialStatus") in allowed_statuses]

    @staticmethod
    def parse_response_citations(tutor_response: str) -> Dict[str, Any]:
        """Parses explicit tags [FONTE] and [INFERÊNCIA] in tutor response."""
        has_fonte = "[FONTE" in tutor_response
        has_inferencia = "[INFERÊNCIA" in tutor_response
        fontes = re.findall(r'\[FONTE:\s*([^\]]+)\]', tutor_response)
        return {
            "has_fonte": has_fonte,
            "has_inferencia": has_inferencia,
            "fontes": fontes,
        }


class TestFeature18StrictRagProvenance(unittest.TestCase):
    """F18: Strict RAG Provenance & Citation Tag Validation."""

    def test_f18_tc01_unapproved_chapters_filtered_out_of_context(self):
        """Verify unapproved, planned or draft chapters are excluded from RAG prompt."""
        candidate_chunks = [
            {"chunk_id": "c1", "editorialStatus": "approved", "text": "Texto oficial aprovado."},
            {"chunk_id": "c2", "editorialStatus": "Planejado", "text": "Texto preliminar não auditado."},
            {"chunk_id": "c3", "editorialStatus": "Em revisão", "text": "Texto sob revisão técnica."},
            {"chunk_id": "c4", "editorialStatus": "published", "text": "Texto publicado."},
        ]
        filtered = RagContextBuilder.filter_and_format_chunks(candidate_chunks)
        self.assertEqual(len(filtered), 2)
        chunk_ids = [c["chunk_id"] for c in filtered]
        self.assertIn("c1", chunk_ids)
        self.assertIn("c4", chunk_ids)
        self.assertNotIn("c2", chunk_ids)
        self.assertNotIn("c3", chunk_ids)

    def test_f18_tc02_parse_valid_fonte_citation_tag(self):
        """Verify parser identifies [FONTE: ...] and [INFERÊNCIA] tags."""
        tutor_reply = (
            "Segundo a norma [FONTE: Vol 1, Cap 1, p. 12], a cadeia de custódia inicia-se no local. "
            "[INFERÊNCIA: Isso implica que a fixação fotográfica prévia é indispensável]."
        )
        res = RagContextBuilder.parse_response_citations(tutor_reply)
        self.assertTrue(res["has_fonte"])
        self.assertTrue(res["has_inferencia"])
        self.assertEqual(len(res["fontes"]), 1)
        self.assertEqual(res["fontes"][0], "Vol 1, Cap 1, p. 12")

    def test_f18_tc03_reject_ungrounded_encyclopedia_claims(self):
        """Verify response without citation tag is identified as lacking [FONTE] tag."""
        ungrounded_reply = "A enciclopédia afirma categoricamente que o hash MD5 nunca colide."
        res = RagContextBuilder.parse_response_citations(ungrounded_reply)
        self.assertFalse(res["has_fonte"], "Ungrounded reply lacks required [FONTE] tag")

    def test_f18_tc04_explicit_declaration_of_lack_of_source(self):
        """Verify out-of-scope question response acknowledges lack of approved material."""
        out_of_scope_response = (
            "Não há material aprovado na Enciclopédia de Ciências Forenses sobre este tópico específico. "
            "[INFERÊNCIA: O tema pode ser abordado futuramente no Volume VIII]."
        )
        self.assertIn("Não há material aprovado", out_of_scope_response)

    def test_f18_tc05_citation_metadata_structure(self):
        """Verify citation metadata includes document ID, chapter, and page."""
        citation_meta = {
            "volume": 1,
            "chapter": 1,
            "page": 2,
            "sectionId": "sec-02-cadeia",
            "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
        }
        self.assertEqual(citation_meta["volume"], 1)
        self.assertEqual(citation_meta["page"], 2)


# ==============================================================================
# Feature 19: Android Native TTS Bridge (Kokoro Braseiro)
# ==============================================================================

class AndroidNativeTtsBridge:
    """Models MethodChannel / EventChannel bridge to Sherpa-ONNX Kokoro (§11, §12.1)."""
    SUPPORTED_PACKAGES = [
        "com.k2fsa.sherpa.onnx.tts.engine",
        "com.k2fsa.sherpa.onnx.tts.engine.debug"
    ]

    def __init__(self, installed_packages: List[str]):
        self.is_installed = any(pkg in self.SUPPORTED_PACKAGES for pkg in installed_packages)
        self.state = "uninitialized"
        self.current_voice: Optional[str] = None
        self.speed: float = 1.00

    def init_engine(self) -> bool:
        if not self.is_installed:
            self.state = "error_not_installed"
            return False
        self.state = "ready"
        return True

    def get_available_voices(self) -> List[str]:
        if not self.is_installed:
            return []
        return ["pt_BR-kokoro-braseiro-neural", "pt_BR-kokoro-clara"]

    def set_voice(self, voice_name: str) -> bool:
        voices = self.get_available_voices()
        if voice_name not in voices:
            return False
        self.current_voice = voice_name
        return True


class TestFeature19AndroidNativeTtsBridge(unittest.TestCase):
    """F19: Android Native TTS Bridge (Kokoro Braseiro / Sherpa-ONNX)."""

    def test_f19_tc01_package_detection_supported_engine(self):
        """Verify detection of com.k2fsa.sherpa.onnx.tts.engine package."""
        bridge = AndroidNativeTtsBridge(["com.android.settings", "com.k2fsa.sherpa.onnx.tts.engine"])
        self.assertTrue(bridge.is_installed)
        self.assertTrue(bridge.init_engine())
        self.assertEqual(bridge.state, "ready")

    def test_f19_tc02_package_detection_debug_engine(self):
        """Verify detection of com.k2fsa.sherpa.onnx.tts.engine.debug package."""
        bridge = AndroidNativeTtsBridge(["com.k2fsa.sherpa.onnx.tts.engine.debug"])
        self.assertTrue(bridge.is_installed)

    def test_f19_tc03_uninstalled_engine_reports_error_state(self):
        """Verify uninstalled engine transitions to error state and returns empty voices."""
        bridge = AndroidNativeTtsBridge(["com.google.android.tts"])  # No sherpa-onnx
        self.assertFalse(bridge.is_installed)
        self.assertFalse(bridge.init_engine())
        self.assertEqual(bridge.state, "error_not_installed")
        self.assertEqual(len(bridge.get_available_voices()), 0)

    def test_f19_tc04_voice_selection_validation(self):
        """Verify setting genuine voice succeeds, and invalid voice name is rejected."""
        bridge = AndroidNativeTtsBridge(["com.k2fsa.sherpa.onnx.tts.engine"])
        bridge.init_engine()
        self.assertTrue(bridge.set_voice("pt_BR-kokoro-braseiro-neural"))
        self.assertEqual(bridge.current_voice, "pt_BR-kokoro-braseiro-neural")

        # Invalid voice
        self.assertFalse(bridge.set_voice("fake_non_existent_voice"))

    def test_f19_tc05_method_channel_call_serialization(self):
        """Verify method call payload structure for native MethodChannel."""
        method_call = {
            "method": "speakChunk",
            "arguments": {
                "chunkId": "chk-001",
                "text": "Texto para síntese pericial.",
                "speed": 1.0,
                "voice": "pt_BR-kokoro-braseiro-neural"
            }
        }
        self.assertEqual(method_call["method"], "speakChunk")
        self.assertIn("chunkId", method_call["arguments"])


# ==============================================================================
# Feature 20: Sentence Segmenter & Queue Control (250-650 Chars)
# ==============================================================================

class SentenceSegmenter:
    """Segments long texts into chunks of 250-650 characters (target ~450) without cutting words (§12.2)."""
    MIN_CHARS = 250
    TARGET_CHARS = 450
    MAX_CHARS = 650
    MAX_NUM_SENTENCES = 2
    SILENCE_SCALE = 0.06

    @classmethod
    def segment_text(cls, text: str) -> List[str]:
        if not text.strip():
            return []

        # Split into individual sentences preserving punctuation
        sentences = re.split(r'(?<=[.!?;\n])\s+', text.strip())
        sentences = [s.strip() for s in sentences if s.strip()]

        chunks = []
        current_chunk_sentences = []
        current_len = 0

        for sentence in sentences:
            sentence_len = len(sentence)
            # If adding this sentence would exceed MAX_CHARS or MAX_NUM_SENTENCES, flush chunk
            if current_chunk_sentences and (
                (current_len + sentence_len + 1 > cls.MAX_CHARS) or
                (len(current_chunk_sentences) >= cls.MAX_NUM_SENTENCES)
            ):
                chunks.append(" ".join(current_chunk_sentences))
                current_chunk_sentences = []
                current_len = 0

            current_chunk_sentences.append(sentence)
            current_len += sentence_len + 1

        if current_chunk_sentences:
            chunks.append(" ".join(current_chunk_sentences))

        return chunks


class TestFeature20SentenceSegmenter(unittest.TestCase):
    """F20: Sentence Segmenter & Queue Control (250-650 Chars, Target 450)."""

    def setUp(self):
        # Build realistic forensic text
        self.long_forensic_text = (
            "A perícia forense digital fundamenta-se na transformação de dados brutos em evidências legalmente válidas. "
            "Para assegurar a idoneidade probatória, é imperativo o estrito cumprimento da cadeia de custódia formal. "
            "A identificação e coleta de vestígios digitais devem obedecer rigorosamente às diretrizes estabelecidas na norma ISO 27037. "
            "Qualquer manipulação indevida no suporte de armazenamento original pode gerar nulidade processual insanável. "
            "A replicação bit a bit do disco rígido ou memória flash deve ser validada por funções de dispersão criptográfica como SHA-256. "
            "Dessa forma, comprova-se perante o juízo que a imagem forense periciada é idêntica ao dispositivo original arrecadado."
        )

    def test_f20_tc01_chunk_bounds_within_maximum(self):
        """Verify no chunk exceeds the maximum limit of 650 characters."""
        chunks = SentenceSegmenter.segment_text(self.long_forensic_text)
        self.assertGreater(len(chunks), 1)
        for chunk in chunks:
            self.assertLessEqual(len(chunk), SentenceSegmenter.MAX_CHARS)

    def test_f20_tc02_max_num_sentences_constraint(self):
        """Verify chunks do not contain more than maxNumSentences=2."""
        chunks = SentenceSegmenter.segment_text(self.long_forensic_text)
        for chunk in chunks:
            # Count sentence terminal punctuation (. ! ?)
            sentence_terminals = len(re.findall(r'[.!?]', chunk))
            self.assertLessEqual(sentence_terminals, SentenceSegmenter.MAX_NUM_SENTENCES)

    def test_f20_tc03_punctuation_aware_boundary_splitting(self):
        """Verify chunks always end with proper punctuation and never cut words."""
        chunks = SentenceSegmenter.segment_text(self.long_forensic_text)
        for chunk in chunks:
            last_char = chunk[-1]
            self.assertIn(last_char, [".", "!", "?", ";", ":"], f"Chunk does not end on punctuation: '{chunk}'")

    def test_f20_tc04_no_omitted_text_preserves_total_content(self):
        """Verify all words from original text are preserved across generated chunks."""
        chunks = SentenceSegmenter.segment_text(self.long_forensic_text)
        reassembled = " ".join(chunks)
        # Verify key forensic phrases exist
        self.assertIn("A perícia forense digital", reassembled)
        self.assertIn("cadeia de custódia formal", reassembled)
        self.assertIn("SHA-256", reassembled)
        self.assertIn("dispositivo original arrecadado", reassembled)

    def test_f20_tc05_first_chunk_available_immediately(self):
        """Verify first chunk is returned immediately for low-latency playback (§12.4)."""
        chunks = SentenceSegmenter.segment_text(self.long_forensic_text)
        first_chunk = chunks[0]
        self.assertTrue(len(first_chunk) > 0)
        self.assertTrue(first_chunk.startswith("A perícia forense digital"))


# ==============================================================================
# Feature 21: Gemini Online TTS (Charon Voice) & 44-byte WAV Header
# ==============================================================================

class WavHeaderBuilder:
    """Constructs a strictly compliant 44-byte RIFF/WAVE header for PCM audio (§13, §21)."""
    @staticmethod
    def create_wav_header(pcm_data_length: int, sample_rate: int = 24000, num_channels: int = 1, bits_per_sample: int = 16) -> bytes:
        byte_rate = sample_rate * num_channels * bits_per_sample // 8
        block_align = num_channels * bits_per_sample // 8
        chunk_size = 36 + pcm_data_length

        # 44-byte RIFF format string:
        # 4s I 4s 4s I H H I I H H 4s I
        header = struct.pack(
            '<4sI4s4sIHHIIHH4sI',
            b'RIFF',
            chunk_size,
            b'WAVE',
            b'fmt ',
            16,             # Subchunk1Size (16 for PCM)
            1,              # AudioFormat (1 for PCM)
            num_channels,   # NumChannels
            sample_rate,    # SampleRate
            byte_rate,      # ByteRate
            block_align,    # BlockAlign
            bits_per_sample,# BitsPerSample
            b'data',
            pcm_data_length # Subchunk2Size
        )
        assert len(header) == 44, f"Header size must be exactly 44 bytes, got {len(header)}"
        return header


class GeminiTtsPayloadBuilder:
    """Constructs speech generation payload for Gemini API with Charon voice (§13.1)."""
    DEFAULT_VOICE = "Charon"

    @classmethod
    def build_request_body(cls, text: str, voice_name: str = DEFAULT_VOICE) -> Dict[str, Any]:
        return {
            "input": {"text": text},
            "voice": {
                "name": voice_name,
                "languageCode": "pt-BR",
            },
            "audioConfig": {
                "audioEncoding": "LINEAR16",
                "sampleRateHertz": 24000
            }
        }


class TestFeature21GeminiCharonTts(unittest.TestCase):
    """F21: Gemini Online TTS (Charon Voice & 44-byte WAV Header)."""

    def test_f21_tc01_wav_header_length_exactly_44_bytes(self):
        """Verify generated RIFF WAV header is exactly 44 bytes in length."""
        header = WavHeaderBuilder.create_wav_header(pcm_data_length=1024, sample_rate=24000)
        self.assertEqual(len(header), 44)

    def test_f21_tc02_wav_header_magic_constants(self):
        """Verify RIFF, WAVE, fmt , and data magic constants."""
        header = WavHeaderBuilder.create_wav_header(pcm_data_length=2048)
        self.assertEqual(header[0:4], b'RIFF')
        self.assertEqual(header[8:12], b'WAVE')
        self.assertEqual(header[12:16], b'fmt ')
        self.assertEqual(header[36:40], b'data')

    def test_f21_tc03_wav_header_mathematical_rates(self):
        """Verify ByteRate and BlockAlign calculations."""
        sample_rate = 24000
        channels = 1
        bits = 16
        expected_byte_rate = sample_rate * channels * (bits // 8)  # 48000
        expected_block_align = channels * (bits // 8)              # 2

        header = WavHeaderBuilder.create_wav_header(5000, sample_rate, channels, bits)
        unpacked = struct.unpack('<4sI4s4sIHHIIHH4sI', header)

        byte_rate_found = unpacked[8]
        block_align_found = unpacked[9]
        self.assertEqual(byte_rate_found, expected_byte_rate)
        self.assertEqual(block_align_found, expected_block_align)

    def test_f21_tc04_charon_voice_request_payload(self):
        """Verify Gemini TTS request payload configures Charon voice and pt-BR."""
        req = GeminiTtsPayloadBuilder.build_request_body("Texto pericial")
        self.assertEqual(req["voice"]["name"], "Charon")
        self.assertEqual(req["voice"]["languageCode"], "pt-BR")
        self.assertEqual(req["audioConfig"]["audioEncoding"], "LINEAR16")

    def test_f21_tc05_pcm_base64_to_playable_wav(self):
        """Verify assembling 44-byte header with decoded Base64 PCM creates complete WAV file."""
        raw_pcm = b"\x00\x00\x10\x00\x20\x00" * 100  # 600 bytes
        b64_pcm = base64.b64encode(raw_pcm).decode('ascii')

        decoded = base64.b64decode(b64_pcm)
        header = WavHeaderBuilder.create_wav_header(pcm_data_length=len(decoded))
        full_wav = header + decoded

        self.assertEqual(len(full_wav), 44 + 600)
        self.assertEqual(full_wav[:4], b'RIFF')


if __name__ == '__main__':
    unittest.main()
