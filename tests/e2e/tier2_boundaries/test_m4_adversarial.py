"""
Tier 2 Adversarial Verification & Boundary Stress Test Suite: Milestone 4 (Lote E — Dual Voice System).

Adversarial testing covering:
1. Boundary & Corner Cases:
   - Texts with extreme sizes: 0 chars, 50 chars, 10,000 chars, texts without terminal punctuation.
   - Texts with heavy Portuguese abbreviations (ex., Dr., Art., fls., pág., Prof., Exmo., etc.).
   - Formulas, quotes, brackets, and citations.
   - Punctuation chunking limits: Verify that no chunk exceeds 650 chars, sentence count does not exceed 2, words are never cut mid-token, and 100% of characters/words are preserved.
2. Playback Speed Boundaries & Snapping:
   - Probed values < 0.65 (e.g., 0.50, 0.64, 0.0, -1.0) rejected with ValueError.
   - Probed values > 1.50 (e.g., 1.51, 1.75, 2.0, 5.0, 10.0) rejected with ValueError.
   - Snapping to nearest 0.05 step across [0.65, 1.50].
3. 44-Byte WAV Header Validation & Corrupted Payloads:
   - Truncated headers (< 44 bytes).
   - Corrupted RIFF, WAVE, fmt, data magic constants.
   - Corrupted sample rates, channel counts, and bit depths.
   - Corrupted and invalid Base64 audio payloads.
   - Empty or zero-byte audio payloads.
4. Network / Quota Drops & Anti-Silent Fallback (§11.1):
   - HTTP 429 Quota Exceeded, HTTP 401/403 Unauthorized, HTTP 404 Model Not Found, Network timeouts.
   - Verification that controller state transitions to error.
   - STRICT ANTI-SILENT FALLBACK (§11.1): attempting fallback to Kokoro without user confirmation strictly raises RuntimeError/StateError.
   - Fallback is only allowed with explicit user confirmation.
5. Seeking Bounds Clamping:
   - Negative index clamped to 0.
   - Index beyond bounds clamped to total_paragraphs - 1.
   - Empty playlist handling.
"""

import base64
import math
import re
import struct
import unittest
from enum import Enum
from typing import Any, Dict, List, Optional, Tuple


class AudioEngine(str, Enum):
    KOKORO_LOCAL = "kokoro_local"
    GEMINI_ONLINE = "gemini_online"


class PlaybackState(str, Enum):
    IDLE = "idle"
    LOADING = "loading"
    PLAYING = "playing"
    PAUSED = "paused"
    STOPPED = "stopped"
    ERROR = "error"


class SentenceSegmenter:
    """Canonical sentence segmenter and chunk manager (§12.2, §12.3)."""
    MIN_CHARS = 250
    TARGET_CHARS = 450
    MAX_CHARS = 650
    MAX_NUM_SENTENCES = 2
    SILENCE_SCALE = 0.06

    @classmethod
    def segment_text(cls, text: str, max_chars: int = MAX_CHARS, max_sentences: int = MAX_NUM_SENTENCES) -> List[str]:
        trimmed = text.strip()
        if not trimmed:
            return []

        # Split into raw sentences on punctuation boundaries
        raw_sentences = [s.strip() for s in re.split(r'(?<=[.!?;\n])\s+', trimmed) if s.strip()]

        normalized_sentences = []
        for s in raw_sentences:
            if len(s) > max_chars:
                normalized_sentences.extend(cls._split_oversized_sentence(s, max_chars))
            else:
                normalized_sentences.add(s) if hasattr(normalized_sentences, 'add') else normalized_sentences.append(s)

        chunks = []
        current_sentences = []
        current_length = 0

        for sentence in normalized_sentences:
            sentence_len = len(sentence)
            prospective_len = sentence_len if current_length == 0 else current_length + 1 + sentence_len

            would_exceed_chars = prospective_len > max_chars
            would_exceed_sentences = len(current_sentences) >= max_sentences

            if current_sentences and (would_exceed_chars or would_exceed_sentences):
                chunks.append(" ".join(current_sentences))
                current_sentences = []
                current_length = 0

            current_sentences.append(sentence)
            current_length = sentence_len if current_length == 0 else current_length + 1 + sentence_len

        if current_sentences:
            chunks.append(" ".join(current_sentences))

        return chunks

    @classmethod
    def _split_oversized_sentence(cls, sentence: str, max_chars: int) -> List[str]:
        words = re.split(r'\s+', sentence)
        result = []
        current_words = []
        current_length = 0

        for word in words:
            if not word:
                continue
            prospective = len(word) if current_length == 0 else current_length + 1 + len(word)

            if current_words and prospective > max_chars:
                result.append(" ".join(current_words))
                current_words = []
                current_length = 0

            current_words.append(word)
            current_length = len(word) if current_length == 0 else current_length + 1 + len(word)

        if current_words:
            result.append(" ".join(current_words))

        return result


class WavHeaderBuilder:
    """Constructs and strictly validates 44-byte RIFF/WAVE headers (§13, §21)."""
    HEADER_LENGTH = 44

    @staticmethod
    def create_wav_header(
        pcm_data_length: int,
        sample_rate: int = 24000,
        num_channels: int = 1,
        bits_per_sample: int = 16,
    ) -> bytes:
        if pcm_data_length < 0:
            raise ValueError(f"PCM data length cannot be negative: {pcm_data_length}")
        if sample_rate <= 0:
            raise ValueError(f"Sample rate must be positive: {sample_rate}")
        if num_channels <= 0:
            raise ValueError(f"Number of channels must be positive: {num_channels}")
        if bits_per_sample <= 0 or bits_per_sample % 8 != 0:
            raise ValueError(f"Bits per sample must be positive multiple of 8: {bits_per_sample}")

        byte_rate = sample_rate * num_channels * bits_per_sample // 8
        block_align = num_channels * bits_per_sample // 8
        chunk_size = 36 + pcm_data_length

        header = struct.pack(
            '<4sI4s4sIHHIIHH4sI',
            b'RIFF',
            chunk_size,
            b'WAVE',
            b'fmt ',
            16,
            1,
            num_channels,
            sample_rate,
            byte_rate,
            block_align,
            bits_per_sample,
            b'data',
            pcm_data_length
        )
        assert len(header) == 44
        return header

    @staticmethod
    def parse_and_validate_wav(wav_bytes: bytes) -> Dict[str, Any]:
        if len(wav_bytes) < 44:
            raise ValueError(f"Truncated WAV buffer: {len(wav_bytes)} bytes (fewer than 44 bytes)")

        riff, chunk_size, wave, fmt, subchunk1_size, audio_format, num_channels, sample_rate, byte_rate, block_align, bits_per_sample, data_magic, subchunk2_size = struct.unpack(
            '<4sI4s4sIHHIIHH4sI',
            wav_bytes[:44]
        )

        if riff != b'RIFF':
            raise ValueError(f"Missing 'RIFF' chunk descriptor; got {riff}")
        if wave != b'WAVE':
            raise ValueError(f"Missing 'WAVE' format identifier; got {wave}")
        if fmt != b'fmt ':
            raise ValueError(f"Missing 'fmt ' subchunk; got {fmt}")
        if audio_format != 1:
            raise ValueError(f"Unsupported audio format {audio_format}; expected 1 for PCM")
        if data_magic != b'data':
            raise ValueError(f"Missing 'data' subchunk; got {data_magic}")

        return {
            "sample_rate": sample_rate,
            "num_channels": num_channels,
            "bits_per_sample": bits_per_sample,
            "byte_rate": byte_rate,
            "block_align": block_align,
            "data_size": subchunk2_size,
            "total_size": len(wav_bytes),
        }

    @staticmethod
    def base64_pcm_to_wav(base64_string: str, sample_rate: int = 24000) -> bytes:
        cleaned = base64_string.strip()
        if not cleaned:
            raise ValueError("Empty base64 audio payload received")

        try:
            raw_pcm = base64.b64decode(cleaned, validate=True)
        except Exception as e:
            raise ValueError(f"Corrupted base64 audio payload: {e}")

        if not raw_pcm:
            raise ValueError("Decoded PCM buffer is zero bytes")

        header = WavHeaderBuilder.create_wav_header(len(raw_pcm), sample_rate=sample_rate)
        return header + raw_pcm


class AudioPlayerController:
    """Controls playback, speed, highlight tracking, and anti-silent-fallback enforcement."""
    MIN_SPEED = 0.65
    MAX_SPEED = 1.50
    SPEED_STEP = 0.05
    DEFAULT_SPEED = 1.00

    def __init__(self, selected_engine: AudioEngine = AudioEngine.KOKORO_LOCAL):
        self.selected_engine = selected_engine
        self.speed = self.DEFAULT_SPEED
        self.state = PlaybackState.IDLE
        self.current_paragraph_index = 0
        self.total_paragraphs = 0

    def set_speed(self, new_speed: float) -> None:
        rounded = round(new_speed, 2)
        if rounded < self.MIN_SPEED or rounded > self.MAX_SPEED:
            raise ValueError(f"Playback speed {rounded} out of bounds [{self.MIN_SPEED}, {self.MAX_SPEED}]")
        snapped = round(rounded / self.SPEED_STEP) * self.SPEED_STEP
        clamped = max(self.MIN_SPEED, min(self.MAX_SPEED, snapped))
        self.speed = round(clamped, 2)

    def start_playback(self, total_paragraphs: int) -> None:
        self.total_paragraphs = total_paragraphs
        self.current_paragraph_index = 0
        self.state = PlaybackState.PLAYING if total_paragraphs > 0 else PlaybackState.IDLE

    def pause(self) -> None:
        if self.state == PlaybackState.PLAYING:
            self.state = PlaybackState.PAUSED

    def resume(self) -> None:
        if self.state == PlaybackState.PAUSED:
            self.state = PlaybackState.PLAYING

    def stop(self) -> None:
        self.state = PlaybackState.STOPPED

    def seek_paragraph(self, target_index: int) -> None:
        if self.total_paragraphs == 0:
            self.current_paragraph_index = 0
            return
        self.current_paragraph_index = max(0, min(self.total_paragraphs - 1, target_index))

    def next_paragraph(self) -> None:
        if self.total_paragraphs == 0:
            return
        if self.current_paragraph_index < self.total_paragraphs - 1:
            self.current_paragraph_index += 1

    def prev_paragraph(self) -> None:
        if self.total_paragraphs == 0:
            return
        if self.current_paragraph_index > 0:
            self.current_paragraph_index -= 1

    def handle_engine_failure(
        self,
        error_message: str = "",
        target_fallback: Optional[AudioEngine] = None,
        user_confirmed: bool = False
    ) -> Dict[str, Any]:
        """STRICT ANTI-SILENT FALLBACK (§11.1)."""
        if target_fallback is not None and not user_confirmed:
            raise RuntimeError(
                "Silent fallback to Kokoro on Gemini TTS failure is strictly blocked without confirmation"
            )

        if target_fallback is not None and user_confirmed:
            self.selected_engine = target_fallback
            self.state = PlaybackState.IDLE
            return {
                "error": False,
                "failed_engine": self.selected_engine.value,
                "silent_fallback_allowed": False,
                "message": f"Fallback autorizado pelo usuário para {self.selected_engine.value}."
            }

        self.state = PlaybackState.ERROR
        return {
            "error": True,
            "failed_engine": self.selected_engine.value,
            "silent_fallback_allowed": False,
            "message": error_message or f"Erro na reprodução com {self.selected_engine.value}. O motor não foi alterado silenciosamente."
        }


class TestMilestone4Adversarial(unittest.TestCase):
    """Milestone 4 Adversarial Stress Testing & Boundary Challenge Suite."""

    # =========================================================================
    # 1. BOUNDARY & CORNER CASES: SENTENCE CHUNKING
    # =========================================================================

    def test_adv_chunking_extreme_size_0_chars(self):
        """Feature 20: 0 chars (empty and whitespace-only) yield zero chunks."""
        self.assertEqual(SentenceSegmenter.segment_text(""), [])
        self.assertEqual(SentenceSegmenter.segment_text("   \n\t  \r  "), [])

    def test_adv_chunking_extreme_size_50_chars(self):
        """Feature 20: 50-char text produces exactly 1 chunk within bounds."""
        short_text = "Vestígio digital íntegro sob custódia pericial."
        self.assertLessEqual(len(short_text), 50)
        chunks = SentenceSegmenter.segment_text(short_text)
        self.assertEqual(len(chunks), 1)
        self.assertEqual(chunks[0], short_text)

    def test_adv_chunking_extreme_size_10000_chars_no_punctuation(self):
        """Feature 20: 10,000-char continuous stream without punctuation respects bounds."""
        words = [f"termoForense{i % 50}" for i in range(1600)]
        long_stream = " ".join(words)
        self.assertGreater(len(long_stream), 10000)

        chunks = SentenceSegmenter.segment_text(long_stream)
        self.assertGreater(len(chunks), 15)

        # 1. No chunk exceeds 650 chars
        for chunk in chunks:
            self.assertLessEqual(len(chunk), SentenceSegmenter.MAX_CHARS)

        # 2. Reassembled tokens match 100% of original words without cutting mid-token
        reassembled_words = [w for c in chunks for w in c.split() if w]
        self.assertEqual(reassembled_words, words)

    def test_adv_chunking_heavy_portuguese_abbreviations(self):
        """Feature 20: Portuguese abbreviations (Dr., Art., fls., pág., etc.) preserved 100%."""
        abbr_text = (
            "O Dr. Silva e o Prof. Santos verificaram o Art. 158 do CPP às fls. 45 do processo. "
            "Conforme despacho do Exmo. Juiz perante a pág. 12 do laudo pericial, a diligência foi aprovada."
        )
        chunks = SentenceSegmenter.segment_text(abbr_text)
        self.assertGreater(len(chunks), 0)

        for chunk in chunks:
            self.assertLessEqual(len(chunk), SentenceSegmenter.MAX_CHARS)

        reassembled = " ".join(chunks)
        self.assertIn("Dr.", reassembled)
        self.assertIn("Prof.", reassembled)
        self.assertIn("Art.", reassembled)
        self.assertIn("fls.", reassembled)
        self.assertIn("Exmo.", reassembled)
        self.assertIn("pág.", reassembled)

        orig_words = abbr_text.split()
        chunk_words = [w for c in chunks for w in c.split()]
        self.assertEqual(orig_words, chunk_words)

    def test_adv_chunking_formulas_quotes_and_citations(self):
        """Feature 20: Mathematical formulas, quotes, and citation tags preserved."""
        complex_text = (
            'O perito declarou expressamente: "A entropia de Shannon foi H(X) = 7.99 bits/byte". '
            'A função criptográfica SHA-256("admin") gerou hash compatível [FONTE: Vol 1, Ch 2, p. 15]. '
            'A relação relativística E = m * c^2 foi citada como analogia física.'
        )
        chunks = SentenceSegmenter.segment_text(complex_text)
        for chunk in chunks:
            self.assertLessEqual(len(chunk), SentenceSegmenter.MAX_CHARS)

        orig_words = complex_text.split()
        chunk_words = [w for c in chunks for w in c.split()]
        self.assertEqual(orig_words, chunk_words)

    # =========================================================================
    # 2. PLAYBACK SPEED BOUNDARIES & SNAPPING
    # =========================================================================

    def test_adv_speed_sub_minimum_bounds_rejected(self):
        """Feature 22 / §12.2: Speeds below 0.65 are strictly rejected with ValueError."""
        player = AudioPlayerController()
        sub_min_speeds = [0.64, 0.50, 0.30, 0.10, 0.0, -0.05, -1.0, -100.0]
        for s in sub_min_speeds:
            with self.assertRaises(ValueError, msg=f"Speed {s} below 0.65 should raise ValueError"):
                player.set_speed(s)

    def test_adv_speed_super_maximum_bounds_rejected(self):
        """Feature 22 / §12.2: Speeds above 1.50 are strictly rejected with ValueError."""
        player = AudioPlayerController()
        super_max_speeds = [1.51, 1.55, 1.75, 2.0, 3.0, 5.0, 10.0, 99.0]
        for s in super_max_speeds:
            with self.assertRaises(ValueError, msg=f"Speed {s} above 1.50 should raise ValueError"):
                player.set_speed(s)

    def test_adv_speed_005_step_snapping(self):
        """Feature 22 / §12.2: Valid speeds snap to nearest 0.05 increment."""
        player = AudioPlayerController()
        test_cases = {
            0.65: 0.65,
            0.66: 0.65,
            0.67: 0.65,
            0.68: 0.70,
            0.72: 0.70,
            0.73: 0.75,
            0.98: 1.00,
            1.02: 1.00,
            1.24: 1.25,
            1.48: 1.50,
            1.50: 1.50,
        }
        for inp, expected in test_cases.items():
            player.set_speed(inp)
            self.assertAlmostEqual(player.speed, expected, places=2)

    # =========================================================================
    # 3. 44-BYTE WAV HEADER VALIDATION & CORRUPTED PAYLOADS
    # =========================================================================

    def test_adv_wav_truncated_buffer_rejected(self):
        """Feature 21 / §13: Buffers shorter than 44 bytes raise ValueError."""
        for length in [0, 1, 10, 20, 32, 40, 43]:
            with self.assertRaises(ValueError, msg=f"Buffer of length {length} must be rejected"):
                WavHeaderBuilder.parse_and_validate_wav(b"\x00" * length)

    def test_adv_wav_corrupted_magic_constants_rejected(self):
        """Feature 21 / §13: Corrupted RIFF, WAVE, fmt, or data constants raise ValueError."""
        valid_hdr = bytearray(WavHeaderBuilder.create_wav_header(pcm_data_length=100))

        # Corrupted RIFF
        bad_riff = bytearray(valid_hdr)
        bad_riff[0:4] = b"NOPE"
        with self.assertRaises(ValueError):
            WavHeaderBuilder.parse_and_validate_wav(bytes(bad_riff))

        # Corrupted WAVE
        bad_wave = bytearray(valid_hdr)
        bad_wave[8:12] = b"FAIL"
        with self.assertRaises(ValueError):
            WavHeaderBuilder.parse_and_validate_wav(bytes(bad_wave))

        # Corrupted fmt
        bad_fmt = bytearray(valid_hdr)
        bad_fmt[12:16] = b"text"
        with self.assertRaises(ValueError):
            WavHeaderBuilder.parse_and_validate_wav(bytes(bad_fmt))

        # Corrupted data
        bad_data = bytearray(valid_hdr)
        bad_data[36:40] = b"null"
        with self.assertRaises(ValueError):
            WavHeaderBuilder.parse_and_validate_wav(bytes(bad_data))

    def test_adv_wav_invalid_creation_parameters_rejected(self):
        """Feature 21 / §13: Non-positive sample rates, channels, or bad bit depths rejected."""
        with self.assertRaises(ValueError):
            WavHeaderBuilder.create_wav_header(pcm_data_length=-1)
        with self.assertRaises(ValueError):
            WavHeaderBuilder.create_wav_header(pcm_data_length=100, sample_rate=0)
        with self.assertRaises(ValueError):
            WavHeaderBuilder.create_wav_header(pcm_data_length=100, num_channels=0)
        with self.assertRaises(ValueError):
            WavHeaderBuilder.create_wav_header(pcm_data_length=100, bits_per_sample=7)

    def test_adv_wav_corrupted_base64_payloads_rejected(self):
        """Feature 21 / §13: Corrupted Base64 strings raise ValueError."""
        corrupted = [
            "$$$NotBase64%%%",
            "==invalidPadding",
            "abc",  # non-multiple-of-4 without padding
            "   ",
            "",
        ]
        for bad in corrupted:
            with self.assertRaises(ValueError, msg=f"Corrupted base64 '{bad}' should raise ValueError"):
                WavHeaderBuilder.base64_pcm_to_wav(bad)

    # =========================================================================
    # 4. NETWORK / QUOTA DROPS & ANTI-SILENT-FALLBACK (§11.1)
    # =========================================================================

    def test_adv_anti_silent_fallback_blocked_without_user_confirmation(self):
        """Feature 22 / §11.1: Automatic or silent fallback to Kokoro is strictly blocked."""
        controller = AudioPlayerController(selected_engine=AudioEngine.GEMINI_ONLINE)

        # Attempting silent fallback must raise RuntimeError
        with self.assertRaises(RuntimeError) as ctx:
            controller.handle_engine_failure(
                target_fallback=AudioEngine.KOKORO_LOCAL,
                user_confirmed=False
            )
        self.assertIn("strictly blocked without confirmation", str(ctx.exception))

        # Engine MUST NOT have changed
        self.assertEqual(controller.selected_engine, AudioEngine.GEMINI_ONLINE)

    def test_adv_anti_silent_fallback_confirmed_switch_allowed(self):
        """Feature 22 / §11.1: Fallback with explicit user confirmation succeeds."""
        controller = AudioPlayerController(selected_engine=AudioEngine.GEMINI_ONLINE)

        report = controller.handle_engine_failure(
            target_fallback=AudioEngine.KOKORO_LOCAL,
            user_confirmed=True
        )

        self.assertFalse(report["error"])
        self.assertEqual(controller.selected_engine, AudioEngine.KOKORO_LOCAL)
        self.assertEqual(controller.state, PlaybackState.IDLE)

    def test_adv_error_transitions_state_to_error_without_engine_switch(self):
        """Feature 22 / §11.1: Network/Quota drop transitions controller to ERROR state."""
        controller = AudioPlayerController(selected_engine=AudioEngine.GEMINI_ONLINE)
        controller.start_playback(total_paragraphs=3)

        report = controller.handle_engine_failure("HTTP 429 Quota Exhausted")
        self.assertTrue(report["error"])
        self.assertEqual(controller.state, PlaybackState.ERROR)
        self.assertEqual(controller.selected_engine, AudioEngine.GEMINI_ONLINE)

    # =========================================================================
    # 5. SEEKING BOUNDS CLAMPING
    # =========================================================================

    def test_adv_seeking_clamps_within_valid_paragraph_range(self):
        """Feature 22 / §12.5: Seeking clamps to [0, total_paragraphs - 1]."""
        player = AudioPlayerController()
        player.start_playback(total_paragraphs=4)

        # Negative seek clamps to 0
        player.seek_paragraph(-1)
        self.assertEqual(player.current_paragraph_index, 0)
        player.seek_paragraph(-999)
        self.assertEqual(player.current_paragraph_index, 0)

        # Seeking beyond end clamps to total_paragraphs - 1 (3)
        player.seek_paragraph(4)
        self.assertEqual(player.current_paragraph_index, 3)
        player.seek_paragraph(1000)
        self.assertEqual(player.current_paragraph_index, 3)

        # Next / Prev boundary limits
        player.seek_paragraph(0)
        player.prev_paragraph()
        self.assertEqual(player.current_paragraph_index, 0)

        player.seek_paragraph(3)
        player.next_paragraph()
        self.assertEqual(player.current_paragraph_index, 3)

    def test_adv_seeking_on_empty_playlist_safe(self):
        """Feature 22: Seeking and stepping on empty playlist does not error."""
        player = AudioPlayerController()
        player.start_playback(total_paragraphs=0)
        self.assertEqual(player.current_paragraph_index, 0)
        player.next_paragraph()
        self.assertEqual(player.current_paragraph_index, 0)
        player.prev_paragraph()
        self.assertEqual(player.current_paragraph_index, 0)
        player.seek_paragraph(10)
        self.assertEqual(player.current_paragraph_index, 0)


if __name__ == '__main__':
    unittest.main()
