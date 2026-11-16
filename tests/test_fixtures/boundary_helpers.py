"""
Boundary Test Helpers and Domain Models for Academia Forense E2E Test Suite.
Implements authentic domain logic, schema validation, WCAG calculations,
WAV header parsing, SQLite schema enforcement, and anti-cheating checks.
"""

import math
import re
import json
import sqlite3
import hashlib
from typing import Dict, Any, List, Optional, Tuple


# ============================================================================
# F1: DESIGN SYSTEM PALETTE & WCAG AAA
# ============================================================================

OFFICIAL_PALETTE = {
    "background": "#F5F6F3",
    "surface": "#FFFFFF",
    "forest_green": "#20533F",
    "forest_dark": "#163D2E",
    "forest_secondary": "#347259",
    "forest_light": "#E7F0EA",
    "text_primary": "#26322C",
    "text_secondary": "#66736B",
    "border": "#E1E6E0",
    "field_soft": "#F0F2EF",
}

FORBIDDEN_PALETTE_KEYWORDS = ["neon", "cyber", "blood", "skull", "matrix", "game"]


def parse_hex_color(hex_str: str) -> Tuple[int, int, int]:
    if not isinstance(hex_str, str):
        raise ValueError("Color must be a string")
    hex_str = hex_str.strip()
    if not hex_str.startswith("#"):
        raise ValueError(f"Hex color must start with '#': '{hex_str}'")
    hex_digits = hex_str[1:]
    if len(hex_digits) != 6:
        raise ValueError(f"Hex color must be exactly 6 hex digits (#RRGGBB): '{hex_str}'")
    try:
        r = int(hex_digits[0:2], 16)
        g = int(hex_digits[2:4], 16)
        b = int(hex_digits[4:6], 16)
        return (r, g, b)
    except ValueError as e:
        raise ValueError(f"Invalid hex characters in color '{hex_str}': {e}")


def srgb_channel_to_linear(c_byte: int) -> float:
    c = c_byte / 255.0
    if c <= 0.04045:
        return c / 12.92
    else:
        return math.pow((c + 0.055) / 1.055, 2.4)


def relative_luminance(hex_str: str) -> float:
    r, g, b = parse_hex_color(hex_str)
    r_lin = srgb_channel_to_linear(r)
    g_lin = srgb_channel_to_linear(g)
    b_lin = srgb_channel_to_linear(b)
    return 0.2126 * r_lin + 0.7152 * g_lin + 0.0722 * b_lin


def calculate_contrast_ratio(fg_hex: str, bg_hex: str) -> float:
    l1 = relative_luminance(fg_hex)
    l2 = relative_luminance(bg_hex)
    lighter = max(l1, l2)
    darker = min(l1, l2)
    return (lighter + 0.05) / (darker + 0.05)


def validate_card_radius(radius_dp: float) -> float:
    if not isinstance(radius_dp, (int, float)):
        raise ValueError("Radius must be numeric")
    if radius_dp < 0:
        raise ValueError(f"Card radius cannot be negative: {radius_dp}")
    if radius_dp < 12.0 or radius_dp > 16.0:
        raise ValueError(f"Card radius {radius_dp}dp out of editorial range [12.0dp, 16.0dp]")
    return float(radius_dp)


def validate_palette_aesthetic(token_name: str, hex_color: str) -> bool:
    parse_hex_color(hex_color)
    lower_token = token_name.lower()
    for kw in FORBIDDEN_PALETTE_KEYWORDS:
        if kw in lower_token:
            raise ValueError(f"Forbidden aesthetic detected: '{kw}' in '{token_name}'")
    # Check for extreme cyber-neon (e.g. pure #00FF00 or #FF00FF)
    r, g, b = parse_hex_color(hex_color)
    if (r == 0 and g == 255 and b == 0) or (r == 255 and g == 0 and b == 255):
        raise ValueError(f"Forbidden neon aesthetic color: {hex_color}")
    return True


# ============================================================================
# F2: DUAL RESPONSIVE NAVIGATION
# ============================================================================

ANDROID_DESTINATIONS = [
    "Início",
    "Estudar",
    "Biblioteca",
    "Laboratório",
    "Meu Espaço"
]

class NavigationController:
    def __init__(self, viewport_width: float, viewport_height: float):
        if viewport_width <= 0 or viewport_height <= 0:
            raise ValueError("Invalid viewport dimensions: width and height must be positive")
        self.width = viewport_width
        self.height = viewport_height
        self.destinations = list(ANDROID_DESTINATIONS)
        self.current_tab_index = 0
        self.back_stack: List[str] = []

    @property
    def navigation_mode(self) -> str:
        # <= 600dp is Android Bottom Navigation Bar; > 600dp is Windows NavigationRail
        if self.width <= 600.0:
            return "BOTTOM_BAR"
        else:
            return "NAVIGATION_RAIL"

    def select_tab(self, index: int) -> str:
        if index < 0 or index >= len(self.destinations):
            raise IndexError(f"Tab index {index} out of range [0, {len(self.destinations) - 1}]")
        self.back_stack.append(self.destinations[self.current_tab_index])
        self.current_tab_index = index
        return self.destinations[index]

    def add_destination(self, name: str):
        if self.navigation_mode == "BOTTOM_BAR" and len(self.destinations) >= 5:
            raise OverflowError("Cannot add more than 5 destinations to Android bottom bar")
        self.destinations.append(name)

    def pop_back(self) -> Optional[str]:
        if not self.back_stack:
            return None
        return self.back_stack.pop()


# ============================================================================
# F3: ADJUSTABLE TYPOGRAPHY CONTROLS
# ============================================================================

def clamp_font_size(size_sp: float) -> float:
    if not isinstance(size_sp, (int, float)):
        raise ValueError("Font size must be numeric")
    if size_sp < 14.0 or size_sp > 22.0:
        raise ValueError(f"Font size {size_sp}sp is out of bounds [14.0sp, 22.0sp]")
    return float(size_sp)


def validate_line_height(lh: float) -> float:
    if not isinstance(lh, (int, float)):
        raise ValueError("Line height must be numeric")
    if lh <= 0:
        raise ValueError("Line height must be positive")
    if lh < 1.0 or lh > 3.0:
        raise ValueError(f"Line height {lh} out of acceptable range [1.0, 3.0]")
    return float(lh)


# ============================================================================
# F4: RELATIONAL PERSISTENCE (24 ENTITIES)
# ============================================================================

SCHEMA_24_ENTITIES = [
    "curricula", "volumes", "chapters", "lessons",
    "learning_objectives", "competencies", "exercises", "assessments",
    "assessment_attempts", "laboratories", "laboratory_runs", "case_studies",
    "case_submissions", "study_sessions", "reading_positions", "bookmarks",
    "annotations", "review_schedules", "content_revisions", "source_documents",
    "user_settings", "sync_journals", "ai_interactions", "audio_settings"
]

def init_sqlite_test_db(db_path: str = ":memory:") -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA foreign_keys = ON;")
    cur = conn.cursor()

    cur.execute("""
    CREATE TABLE volumes (
        volume_id TEXT PRIMARY KEY,
        volume_number INTEGER NOT NULL UNIQUE,
        title TEXT NOT NULL,
        area TEXT NOT NULL
    );
    """)

    cur.execute("""
    CREATE TABLE chapters (
        chapter_id TEXT PRIMARY KEY,
        volume_id TEXT NOT NULL,
        chapter_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        editorial_status TEXT NOT NULL,
        edition TEXT NOT NULL,
        FOREIGN KEY (volume_id) REFERENCES volumes(volume_id)
    );
    """)

    conn.executescript("""
    CREATE TABLE curricula (id TEXT PRIMARY KEY, version TEXT NOT NULL);
    CREATE TABLE lessons (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, title TEXT NOT NULL);
    CREATE TABLE learning_objectives (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, description TEXT NOT NULL);
    CREATE TABLE competencies (id TEXT PRIMARY KEY, code TEXT NOT NULL, name TEXT NOT NULL);
    CREATE TABLE exercises (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, question TEXT NOT NULL);
    CREATE TABLE assessments (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, passing_score REAL NOT NULL);
    CREATE TABLE assessment_attempts (
        id TEXT PRIMARY KEY,
        assessment_id TEXT NOT NULL,
        student_id TEXT NOT NULL,
        score REAL NOT NULL,
        passed INTEGER NOT NULL,
        attempted_at TEXT NOT NULL
    );
    CREATE TABLE laboratories (id TEXT PRIMARY KEY, domain TEXT NOT NULL, title TEXT NOT NULL);
    CREATE TABLE laboratory_runs (id TEXT PRIMARY KEY, lab_id TEXT NOT NULL, status TEXT NOT NULL);
    CREATE TABLE case_studies (id TEXT PRIMARY KEY, title TEXT NOT NULL);
    CREATE TABLE case_submissions (id TEXT PRIMARY KEY, case_id TEXT NOT NULL, student_id TEXT NOT NULL);
    CREATE TABLE study_sessions (id TEXT PRIMARY KEY, duration_minutes INTEGER NOT NULL, logged_at TEXT NOT NULL);
    CREATE TABLE reading_positions (
        chapter_id TEXT PRIMARY KEY,
        page INTEGER NOT NULL,
        scroll_ratio REAL NOT NULL,
        updated_at TEXT NOT NULL
    );
    CREATE TABLE bookmarks (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, section_id TEXT NOT NULL);
    CREATE TABLE annotations (
        id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        anchor_text TEXT,
        note_content TEXT NOT NULL,
        revision TEXT NOT NULL,
        drift_warning INTEGER DEFAULT 0
    );
    CREATE TABLE review_schedules (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, next_review_at TEXT NOT NULL);
    CREATE TABLE content_revisions (id TEXT PRIMARY KEY, chapter_id TEXT NOT NULL, revision_tag TEXT NOT NULL);
    CREATE TABLE source_documents (id TEXT PRIMARY KEY, file_id TEXT, sha256 TEXT NOT NULL);
    CREATE TABLE user_settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);
    CREATE TABLE sync_journals (id TEXT PRIMARY KEY, sync_status TEXT NOT NULL, timestamp TEXT NOT NULL);
    CREATE TABLE ai_interactions (id TEXT PRIMARY KEY, mode TEXT NOT NULL, prompt TEXT NOT NULL);
    CREATE TABLE audio_settings (id TEXT PRIMARY KEY, engine TEXT NOT NULL, speed REAL NOT NULL, voice TEXT NOT NULL);
    """)
    conn.commit()
    return conn


# ============================================================================
# F5: SECURE SETTINGS & VAULT
# ============================================================================

class SecureSettingsVault:
    def __init__(self):
        self._encrypted_store: Dict[str, bytes] = {}

    def set_gemini_api_key(self, api_key: str):
        if not api_key or not isinstance(api_key, str) or not api_key.strip():
            raise ValueError("API key cannot be empty or whitespace-only")
        if any(c in api_key for c in ['\n', '\r', '\0', '\t']):
            raise ValueError("API key contains invalid control characters")
        # Encrypt with pseudo-cipher
        raw = api_key.encode('utf-8')
        encrypted = bytes([b ^ 0x5A for b in raw])
        self._encrypted_store["GEMINI_API_KEY"] = encrypted

    def get_masked_api_key(self) -> str:
        key = self.get_gemini_api_key()
        if len(key) <= 8:
            return "****"
        return key[:4] + "****" + key[-4:]

    def get_gemini_api_key(self) -> str:
        if "GEMINI_API_KEY" not in self._encrypted_store:
            raise KeyError("No Gemini API key stored")
        encrypted = self._encrypted_store["GEMINI_API_KEY"]
        decrypted = bytes([b ^ 0x5A for b in encrypted]).decode('utf-8')
        return decrypted

    def tamper_vault_key(self):
        if "GEMINI_API_KEY" in self._encrypted_store:
            self._encrypted_store["GEMINI_API_KEY"] = b"corrupted_garbage_bytes\xff\xfe"


def validate_weekly_study_target(hours: float) -> float:
    if not isinstance(hours, (int, float)):
        raise ValueError("Target hours must be numeric")
    if hours <= 0:
        raise ValueError("Weekly study target must be positive")
    if hours > 168.0:
        raise ValueError(f"Weekly target {hours}h exceeds 168h total hours in a week")
    return float(hours)


# ============================================================================
# F6: CURRICULUM TREE & EDITORIAL STATES
# ============================================================================

EDITORIAL_STATES = (
    "Planejado",
    "Importado",
    "Em revisão",
    "Aprovado",
    "Publicado",
    "Substituído",
    "Arquivado"
)

def validate_volume_number(vol: int) -> int:
    if not isinstance(vol, int) or vol < 1 or vol > 9:
        raise ValueError(f"Volume {vol} out of range [1, 9]")
    return vol


def validate_chapter_number(ch: int) -> int:
    if not isinstance(ch, int) or ch < 1 or ch > 113:
        raise ValueError(f"Chapter {ch} out of range [1, 113]")
    return ch


def validate_editorial_state(state: str) -> str:
    if state not in EDITORIAL_STATES:
        raise ValueError(f"Invalid editorial state '{state}'. Must be one of {EDITORIAL_STATES}")
    return state


def validate_editorial_transition(current_state: str, new_state: str):
    validate_editorial_state(current_state)
    validate_editorial_state(new_state)
    if current_state == "Planejado" and new_state == "Publicado":
        raise ValueError("Cannot transition directly from 'Planejado' to 'Publicado' without import and approval")


# ============================================================================
# F7: VOLUME I PRINT PRESERVATION & ERRATA
# ============================================================================

def validate_vol1_chapter_revision(chapter: int, revision: str):
    if not (1 <= chapter <= 10):
        raise ValueError(f"Chapter {chapter} is not in Volume I (1-10)")
    if 1 <= chapter <= 4:
        if revision != "REV2":
            raise ValueError(f"Print preservation violation: Vol I Chapter {chapter} must be REV2, got '{revision}'")
    else:
        if revision != "REV1":
            raise ValueError(f"Print preservation violation: Vol I Chapter {chapter} must be REV1, got '{revision}'")


def validate_vol1_print_pages(total_pages: int):
    if total_pages != 133:
        raise ValueError(f"Volume I print preservation error: expected exactly 133 printed pages, got {total_pages}")


def validate_errata_entry(volume: int, chapter: int, page: int, errata_text: str):
    if volume != 1:
        raise ValueError("Currently errata table only applies to Volume I")
    if not (1 <= chapter <= 10):
        raise ValueError(f"Invalid chapter {chapter} for Volume I errata")
    if not (1 <= page <= 133):
        raise ValueError(f"Errata page {page} out of bounds [1, 133] for Volume I")
    if not errata_text or not errata_text.strip():
        raise ValueError("Errata text cannot be empty")


# ============================================================================
# F8: SECTION 19 JSON SCHEMA
# ============================================================================

SECTION_19_SCHEMA = {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "required": [
        "schemaVersion", "contentId", "type", "volume", "chapter",
        "title", "language", "edition", "editorialStatus", "source"
    ],
    "properties": {
        "schemaVersion": {"type": "string", "const": "1.0"},
        "contentId": {"type": "string", "pattern": "^forense\\.vol\\d{2}\\.ch\\d{2}$"},
        "type": {"type": "string", "enum": ["chapter"]},
        "volume": {"type": "integer", "minimum": 1, "maximum": 9},
        "chapter": {"type": "integer", "minimum": 1, "maximum": 113},
        "title": {"type": "string", "minLength": 1},
        "language": {"type": "string", "const": "pt-BR"},
        "edition": {"type": "string", "enum": ["REV1", "REV2", "REV3"]},
        "editorialStatus": {
            "type": "string",
            "enum": ["Planejado", "Importado", "Em revisão", "Aprovado", "Publicado", "Substituído", "Arquivado"]
        },
        "source": {
            "type": "object",
            "required": ["provider"],
            "properties": {
                "provider": {"type": "string"},
                "fileId": {"type": ["string", "null"]},
                "revision": {"type": ["string", "null"]},
                "sha256": {"type": ["string", "null"]}
            }
        },
        "sections": {"type": "array"},
        "learningObjectives": {"type": "array"},
        "prerequisites": {"type": "array"},
        "exercises": {"type": "array"},
        "laboratories": {"type": "array"},
        "assessment": {"type": ["object", "null"]}
    }
}


# ============================================================================
# F11: FTS5 SEARCH ESCAPING
# ============================================================================

def sanitize_fts_query(query: str) -> str:
    if not query or not query.strip():
        return ""
    # Strip dangerous injection characters including dashes, slashes, comments
    clean = re.sub(r'["\'*;()^\-/]', ' ', query)
    tokens = clean.strip().split()
    if not tokens:
        return ""
    # Enclose tokens in double quotes for safe FTS5 term matching
    safe_terms = [f'"{tok}"' for tok in tokens if tok]
    return " ".join(safe_terms)


# ============================================================================
# F14: 80% ASSESSMENT PROGRESSION BENCHMARK
# ============================================================================

def evaluate_assessment_result(score_percentage: float) -> Tuple[bool, str]:
    if not isinstance(score_percentage, (int, float)):
        raise ValueError("Score must be numeric")
    if score_percentage < 0.0 or score_percentage > 100.0:
        raise ValueError(f"Score {score_percentage}% out of valid range [0.0, 100.0]")
    passed = score_percentage >= 80.0
    status = "APROVADO" if passed else "REPROVADO"
    return (passed, status)


# ============================================================================
# F20: SENTENCE SEGMENTER (250-650 CHARS)
# ============================================================================

def segment_text_for_tts(text: str, min_chars: int = 250, max_chars: int = 650, max_sentences: int = 2) -> List[str]:
    if not text or not text.strip():
        return []
    # Split text into sentences by punctuation (.!?)
    raw_sentences = re.split(r'(?<=[.!?])\s+', text.strip())
    sentences = [s.strip() for s in raw_sentences if s.strip()]

    chunks = []
    current_chunk = ""
    current_sentence_count = 0

    for sentence in sentences:
        candidate = (current_chunk + " " + sentence).strip() if current_chunk else sentence
        # If candidate fits within max_chars and max_sentences
        if len(candidate) <= max_chars and (current_sentence_count + 1) <= max_sentences:
            current_chunk = candidate
            current_sentence_count += 1
        else:
            if current_chunk:
                chunks.append(current_chunk)
            # If single sentence is larger than max_chars, split by clauses or words
            if len(sentence) > max_chars:
                words = sentence.split()
                sub_chunk = ""
                for word in words:
                    cand_sub = (sub_chunk + " " + word).strip() if sub_chunk else word
                    if len(cand_sub) <= max_chars:
                        sub_chunk = cand_sub
                    else:
                        if sub_chunk:
                            chunks.append(sub_chunk)
                        sub_chunk = word
                if sub_chunk:
                    chunks.append(sub_chunk)
                current_chunk = ""
                current_sentence_count = 0
            else:
                current_chunk = sentence
                current_sentence_count = 1

    if current_chunk:
        chunks.append(current_chunk)

    return chunks


# ============================================================================
# F21: 44-BYTE WAV HEADER PARSER
# ============================================================================

def parse_and_validate_wav_header(wav_bytes: bytes) -> Dict[str, Any]:
    if len(wav_bytes) < 44:
        raise ValueError(f"Truncated WAV data: size {len(wav_bytes)} bytes < 44 bytes minimum")
    if wav_bytes[0:4] != b'RIFF':
        raise ValueError("Invalid WAV: Missing 'RIFF' header marker")
    if wav_bytes[8:12] != b'WAVE':
        raise ValueError("Invalid WAV: Missing 'WAVE' format marker")
    if wav_bytes[12:16] != b'fmt ':
        raise ValueError("Invalid WAV: Missing 'fmt ' subchunk")

    audio_format = int.from_bytes(wav_bytes[20:22], 'little')
    channels = int.from_bytes(wav_bytes[22:24], 'little')
    sample_rate = int.from_bytes(wav_bytes[24:28], 'little')
    bits_per_sample = int.from_bytes(wav_bytes[34:36], 'little')

    if sample_rate <= 0:
        raise ValueError(f"Invalid sample rate {sample_rate}Hz in WAV header")
    if channels <= 0:
        raise ValueError(f"Invalid channel count {channels} in WAV header")

    return {
        "format": audio_format,
        "channels": channels,
        "sample_rate": sample_rate,
        "bits_per_sample": bits_per_sample
    }


def generate_dummy_wav_44byte(sample_rate: int = 24000, channels: int = 1) -> bytes:
    header = bytearray(44)
    header[0:4] = b'RIFF'
    header[4:8] = (36).to_bytes(4, 'little')
    header[8:12] = b'WAVE'
    header[12:16] = b'fmt '
    header[16:20] = (16).to_bytes(4, 'little')  # Subchunk1Size (16 for PCM)
    header[20:22] = (1).to_bytes(2, 'little')   # AudioFormat (1 = PCM)
    header[22:24] = channels.to_bytes(2, 'little')
    header[24:28] = sample_rate.to_bytes(4, 'little')
    byte_rate = sample_rate * channels * 2
    header[28:32] = byte_rate.to_bytes(4, 'little')
    block_align = channels * 2
    header[32:34] = block_align.to_bytes(2, 'little')
    header[34:36] = (16).to_bytes(2, 'little')  # 16 bits per sample
    header[36:40] = b'data'
    header[40:44] = (0).to_bytes(4, 'little')
    return bytes(header)


# ============================================================================
# F22: SPEED SLIDER AND NO SILENT FALLBACK
# ============================================================================

def validate_and_snap_speed(speed: float) -> float:
    if not isinstance(speed, (int, float)):
        raise ValueError("Speed must be numeric")
    if speed < 0.65 or speed > 1.50:
        raise ValueError(f"Playback speed {speed}x out of bounds [0.65x, 1.50x]")
    # Snap to nearest 0.05x step
    snapped = round(round(speed / 0.05) * 0.05, 2)
    return snapped


class AudioEngineManager:
    def __init__(self, primary_engine: str = "kokoro"):
        self.active_engine = primary_engine
        self.playback_speed = 1.00

    def trigger_playback_failure_with_fallback_attempt(self, target_fallback: str, user_confirmed: bool):
        if not user_confirmed:
            raise PermissionError(
                f"Silent fallback to '{target_fallback}' is strictly forbidden by Section 11.1. "
                "User confirmation must be obtained."
            )
        self.active_engine = target_fallback
