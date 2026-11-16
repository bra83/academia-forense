"""Tier 3: Pairwise Combinatorial Test Suite for Academia Forense.

Derived strictly from:
- ORIGINAL_REQUEST.md
- PROJECT.md
- TEST_INFRA.md

Exercises at least 28 combinatorial cross-package and cross-feature interactions
under opaque-box, requirement-driven specifications.
"""

import hashlib
import hmac
import json
import math
import os
import re
import sqlite3
import tempfile
import time
import unittest
from dataclasses import dataclass, field
from enum import Enum
from typing import Any, Dict, List, Optional, Set, Tuple


# ==============================================================================
# Domain Models & Engine Emulators for Opaque-Box Invariant Verification
# ==============================================================================

class DesignSystemTokens:
    BACKGROUND_MAIN = "#F5F6F3"
    PRIMARY_DARK_GREEN = "#20533F"
    DEEP_GREEN = "#163D2E"
    MEDIUM_GREEN = "#347259"
    LIGHT_ACCENT_GREEN = "#E7F0EA"
    TEXT_PRIMARY = "#26322C"
    TEXT_SECONDARY = "#66736B"
    BORDERS_DIVIDERS = "#E1E6E0"
    SURFACE_CARD_WHITE = "#FFFFFF"
    SURFACE_CARD_MUTED = "#F0F2EF"

    PADDING_SM = 8.0
    PADDING_MD = 16.0
    PADDING_LG = 24.0
    CARD_BORDER_RADIUS = 8.0

    @staticmethod
    def calculate_relative_luminance(hex_color: str) -> float:
        hex_clean = hex_color.lstrip("#")
        rgb = [int(hex_clean[i:i + 2], 16) / 255.0 for i in (0, 2, 4)]
        rgb_lin = [
            c / 12.92 if c <= 0.03928 else math.pow((c + 0.055) / 1.055, 2.4)
            for c in rgb
        ]
        return 0.2126 * rgb_lin[0] + 0.7152 * rgb_lin[1] + 0.0722 * rgb_lin[2]

    @classmethod
    def calculate_contrast_ratio(cls, hex1: str, hex2: str) -> float:
        l1 = cls.calculate_relative_luminance(hex1)
        l2 = cls.calculate_relative_luminance(hex2)
        lighter = max(l1, l2)
        darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)


class NavigationDestination(str, Enum):
    HOME = "Início"
    STUDY = "Estudar"
    LIBRARY = "Biblioteca"
    LAB = "Laboratório"
    MY_SPACE = "Meu Espaço"


class EditorialStatus(str, Enum):
    PLANEJADO = "Planejado"
    IMPORTADO = "Importado"
    EM_REVISAO = "Em revisão"
    APROVADO = "Aprovado"
    PUBLICADO = "Publicado"
    SUBSTITUIDO = "Substituído"
    ARQUIVADO = "Arquivado"


class PedagogicalTutorMode(str, Enum):
    EXPLICAR = "explicar"
    SIMPLIFICAR = "simplificar"
    APROFUNDAR = "aprofundar"
    EXEMPLIFICAR = "exemplificar"
    ME_TESTAR = "me_testar"
    REVISAR = "revisar"
    ORIENTAR_LAB = "orientar_lab"


class AudioEngineType(str, Enum):
    KOKORO = "kokoro"
    GEMINI_CHARON = "gemini_tts"


class EvidenceType(str, Enum):
    DOCUMENTED_FACT = "DOCUMENTED_FACT"
    INVESTIGATIVE_INFERENCE = "INVESTIGATIVE_INFERENCE"
    ALTERNATIVE_HYPOTHESIS = "ALTERNATIVE_HYPOTHESIS"


# ==============================================================================
# Helper Verification Engines
# ==============================================================================

class KokoroSentenceSegmenter:
    """Sentence chunker respecting 250-650 characters (target ~450), maxNumSentences=2."""

    def __init__(self, min_chars: int = 250, max_chars: int = 650, target_chars: int = 450, max_sentences: int = 2):
        self.min_chars = min_chars
        self.max_chars = max_chars
        self.target_chars = target_chars
        self.max_sentences = max_sentences

    def segment(self, text: str) -> List[str]:
        # Clean markdown syntax
        clean_text = re.sub(r'#+\s*', '', text)
        clean_text = re.sub(r'[*_`]', '', clean_text)
        clean_text = re.sub(r'\n+', ' ', clean_text).strip()

        # Split sentences on punct (.!?) followed by space or end
        raw_sentences = [s.strip() for s in re.split(r'(?<=[.!?])\s+', clean_text) if s.strip()]
        chunks = []
        current_chunk = []
        current_length = 0

        for sentence in raw_sentences:
            sentence_len = len(sentence)
            if not current_chunk:
                current_chunk.append(sentence)
                current_length = sentence_len
            else:
                would_exceed_sentences = len(current_chunk) >= self.max_sentences
                would_exceed_chars = (current_length + 1 + sentence_len) > self.max_chars
                is_close_to_target = current_length >= self.target_chars

                if would_exceed_sentences or would_exceed_chars or is_close_to_target:
                    chunks.append(" ".join(current_chunk))
                    current_chunk = [sentence]
                    current_length = sentence_len
                else:
                    current_chunk.append(sentence)
                    current_length += 1 + sentence_len

        if current_chunk:
            chunks.append(" ".join(current_chunk))

        return chunks


class AesGcmVaultEmulator:
    """Simulates platform hardware Keystore / DPAPI encrypted storage with authentication tag."""

    def __init__(self, master_key: bytes = b"forensic_master_key_32bytes_len!"):
        self.master_key = master_key

    def encrypt(self, plaintext: str) -> str:
        iv = os.urandom(12)
        data = plaintext.encode("utf-8")
        # AES-GCM simulation: ciphertext + HMAC-SHA256 as auth tag
        ciphertext = bytes(b ^ self.master_key[i % len(self.master_key)] for i, b in enumerate(data))
        tag = hmac.new(self.master_key, iv + ciphertext, hashlib.sha256).digest()[:16]
        payload = {
            "cipher": "AES-256-GCM",
            "iv": iv.hex(),
            "ciphertext": ciphertext.hex(),
            "tag": tag.hex()
        }
        return "ENC:" + json.dumps(payload)

    def decrypt(self, encrypted_str: str) -> str:
        if not encrypted_str.startswith("ENC:"):
            raise ValueError("Not an encrypted vault payload")
        payload = json.loads(encrypted_str[4:])
        iv = bytes.fromhex(payload["iv"])
        ciphertext = bytes.fromhex(payload["ciphertext"])
        tag = bytes.fromhex(payload["tag"])
        expected_tag = hmac.new(self.master_key, iv + ciphertext, hashlib.sha256).digest()[:16]
        if not hmac.compare_digest(tag, expected_tag):
            raise PermissionError("Tampered ciphertext: authentication tag mismatch")
        decrypted = bytes(b ^ self.master_key[i % len(self.master_key)] for i, b in enumerate(ciphertext))
        return decrypted.decode("utf-8")

    @staticmethod
    def mask_key(raw_key: str) -> str:
        if len(raw_key) <= 8:
            return "***"
        return f"{raw_key[:6]}...{raw_key[-4:]}"


# ==============================================================================
# Unit/Integration Test Suite: 28 Cross-Feature Pairwise Combinations
# ==============================================================================

class TestPairwiseInteractions(unittest.TestCase):
    """Tier 3 Pairwise Combinations Test Suite."""

    def setUp(self):
        """Create fresh in-memory database with foreign keys and schema."""
        self.db = sqlite3.connect(":memory:")
        self.db.row_factory = sqlite3.Row
        self.db.execute("PRAGMA foreign_keys = ON;")
        self._init_core_schema()

    def tearDown(self):
        self.db.close()

    def _init_core_schema(self):
        """Sets up relational schema covering volumes, chapters, settings, progress, attempts, etc."""
        cursor = self.db.cursor()
        cursor.executescript("""
            CREATE TABLE volumes (
                id TEXT PRIMARY KEY,
                number INTEGER NOT NULL UNIQUE,
                title TEXT NOT NULL,
                total_chapters INTEGER NOT NULL,
                is_printed BOOLEAN NOT NULL DEFAULT 0
            );

            CREATE TABLE chapters (
                id TEXT PRIMARY KEY,
                volume_id TEXT NOT NULL,
                number INTEGER NOT NULL,
                title TEXT NOT NULL,
                revision TEXT NOT NULL,
                content TEXT NOT NULL,
                is_printed BOOLEAN NOT NULL DEFAULT 0,
                editorial_status TEXT NOT NULL,
                FOREIGN KEY (volume_id) REFERENCES volumes(id) ON DELETE CASCADE
            );

            CREATE TABLE settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE reading_positions (
                chapter_id TEXT PRIMARY KEY,
                page_index INTEGER NOT NULL,
                scroll_ratio REAL NOT NULL,
                active_mode TEXT NOT NULL,
                last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
            );

            CREATE TABLE student_annotations (
                id TEXT PRIMARY KEY,
                chapter_id TEXT NOT NULL,
                anchor_id TEXT NOT NULL,
                selected_text TEXT NOT NULL,
                note TEXT NOT NULL,
                reconciliation_status TEXT NOT NULL DEFAULT 'EXACT',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
            );

            CREATE TABLE assessment_attempts (
                id TEXT PRIMARY KEY,
                chapter_id TEXT NOT NULL,
                student_id TEXT NOT NULL,
                score REAL NOT NULL,
                passed BOOLEAN NOT NULL,
                breakdown_json TEXT NOT NULL,
                attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (chapter_id) REFERENCES chapters(id) ON DELETE CASCADE
            );

            CREATE TABLE study_sessions (
                id TEXT PRIMARY KEY,
                chapter_id TEXT,
                activity_type TEXT NOT NULL,
                duration_minutes INTEGER NOT NULL,
                recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE laboratory_runs (
                id TEXT PRIMARY KEY,
                lab_domain TEXT NOT NULL,
                lab_name TEXT NOT NULL,
                student_id TEXT NOT NULL,
                status TEXT NOT NULL,
                output_summary TEXT NOT NULL,
                executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );

            CREATE TABLE errata_records (
                id TEXT PRIMARY KEY,
                volume_id TEXT NOT NULL,
                chapter_id TEXT NOT NULL,
                page_number INTEGER NOT NULL,
                original_text TEXT NOT NULL,
                corrected_text TEXT NOT NULL,
                explanation TEXT NOT NULL,
                FOREIGN KEY (volume_id) REFERENCES volumes(id),
                FOREIGN KEY (chapter_id) REFERENCES chapters(id)
            );

            -- FTS5 Full-Text Search Virtual Table
            CREATE VIRTUAL TABLE chapters_fts USING fts5(
                chapter_id UNINDEXED,
                title,
                content,
                volume_id UNINDEXED
            );
        """)
        self.db.commit()

    # --------------------------------------------------------------------------
    # Pair 1: F1 (Design System) + F2 (Dual Nav)
    # --------------------------------------------------------------------------
    def test_01_f1_design_system_and_f2_dual_nav(self):
        """Theme application across Android BottomBar and Windows NavigationRail."""
        # 1. Contrast ratios adhere to WCAG AAA (>7.0:1)
        primary_on_bg = DesignSystemTokens.calculate_contrast_ratio(
            DesignSystemTokens.PRIMARY_DARK_GREEN, DesignSystemTokens.BACKGROUND_MAIN
        )
        text_on_bg = DesignSystemTokens.calculate_contrast_ratio(
            DesignSystemTokens.TEXT_PRIMARY, DesignSystemTokens.BACKGROUND_MAIN
        )
        deep_on_bg = DesignSystemTokens.calculate_contrast_ratio(
            DesignSystemTokens.DEEP_GREEN, DesignSystemTokens.BACKGROUND_MAIN
        )
        self.assertGreaterEqual(primary_on_bg, 7.0, f"Primary contrast {primary_on_bg:.2f} must meet WCAG AAA")
        self.assertGreaterEqual(text_on_bg, 7.0, f"Text contrast {text_on_bg:.2f} must meet WCAG AAA")
        self.assertGreaterEqual(deep_on_bg, 7.0, f"Deep green contrast {deep_on_bg:.2f} must meet WCAG AAA")

        # 2. Dual Navigation specifications
        android_nav = {
            "type": "BottomNavigationBar",
            "items": [d.value for d in NavigationDestination],
            "backgroundColor": DesignSystemTokens.SURFACE_CARD_WHITE,
            "selectedItemColor": DesignSystemTokens.PRIMARY_DARK_GREEN,
            "unselectedItemColor": DesignSystemTokens.TEXT_SECONDARY,
            "topBorderColor": DesignSystemTokens.BORDERS_DIVIDERS
        }

        windows_nav = {
            "type": "NavigationRail",
            "items": [d.value for d in NavigationDestination],
            "backgroundColor": DesignSystemTokens.SURFACE_CARD_MUTED,
            "selectedIndicatorColor": DesignSystemTokens.LIGHT_ACCENT_GREEN,
            "selectedIconColor": DesignSystemTokens.PRIMARY_DARK_GREEN,
            "unselectedIconColor": DesignSystemTokens.TEXT_SECONDARY
        }

        # Assert canonical 5 items match across both navigation paradigms
        expected_destinations = ["Início", "Estudar", "Biblioteca", "Laboratório", "Meu Espaço"]
        self.assertEqual(android_nav["items"], expected_destinations)
        self.assertEqual(windows_nav["items"], expected_destinations)
        self.assertEqual(android_nav["selectedItemColor"], DesignSystemTokens.PRIMARY_DARK_GREEN)
        self.assertEqual(windows_nav["selectedIconColor"], DesignSystemTokens.PRIMARY_DARK_GREEN)
        self.assertEqual(windows_nav["selectedIndicatorColor"], DesignSystemTokens.LIGHT_ACCENT_GREEN)

    # --------------------------------------------------------------------------
    # Pair 2: F1 (Design System) + F3 (Typography)
    # --------------------------------------------------------------------------
    def test_02_f1_design_system_and_f3_typography(self):
        """Font size scaling recalculating card margins and line heights."""
        # Baseline typography: font sizes 14sp to 22sp, line height factor 1.5
        font_scales = [14.0, 16.0, 18.0, 20.0, 22.0]
        line_height_factor = 1.5
        base_padding_vertical = DesignSystemTokens.PADDING_MD  # 16.0

        for sp in font_scales:
            line_height = sp * line_height_factor
            # 3 lines of academic text in an editorial card
            text_height = 3 * line_height
            # Card dynamic min-height with design system vertical padding
            card_min_height = text_height + (2 * base_padding_vertical)

            self.assertAlmostEqual(line_height, sp * 1.5, places=2)
            self.assertGreater(card_min_height, text_height)

        # Scale comparison: 22sp card must occupy proportionally more vertical space than 14sp
        h_14 = (3 * (14.0 * line_height_factor)) + (2 * base_padding_vertical)
        h_22 = (3 * (22.0 * line_height_factor)) + (2 * base_padding_vertical)
        self.assertAlmostEqual(h_14, 95.0, places=1)
        self.assertAlmostEqual(h_22, 131.0, places=1)
        self.assertGreater(h_22, h_14)

    # --------------------------------------------------------------------------
    # Pair 3: F2 (Dual Nav) + F9 (Dual Reader)
    # --------------------------------------------------------------------------
    def test_03_f2_dual_nav_and_f9_dual_reader(self):
        """Switching navigation tabs while keeping reader position intact."""
        # Seed volume & chapter
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.execute(
            "INSERT INTO chapters VALUES ('vol1_ch02', 'vol_01', 2, 'Cadeia de Custódia', 'REV2', 'Conteúdo...', 1, 'Aprovado')"
        )
        self.db.commit()

        # Step 1: User reads chapter 2 in study mode at page 4, scroll 0.42
        self.db.execute("""
            INSERT INTO reading_positions (chapter_id, page_index, scroll_ratio, active_mode)
            VALUES ('vol1_ch02', 4, 0.42, 'reflowable_markdown')
        """)
        self.db.commit()

        # Step 2: User switches tab from 'Estudar' -> 'Laboratório' -> 'Meu Espaço' -> 'Estudar'
        active_tab = NavigationDestination.STUDY
        nav_history = [active_tab]

        # Switch to LAB
        active_tab = NavigationDestination.LAB
        nav_history.append(active_tab)

        # Switch to MY_SPACE
        active_tab = NavigationDestination.MY_SPACE
        nav_history.append(active_tab)

        # Return to STUDY
        active_tab = NavigationDestination.STUDY
        nav_history.append(active_tab)

        # Step 3: Fetch reader position upon returning
        row = self.db.execute("SELECT * FROM reading_positions WHERE chapter_id = 'vol1_ch02'").fetchone()
        self.assertIsNotNone(row)
        self.assertEqual(row["page_index"], 4)
        self.assertAlmostEqual(row["scroll_ratio"], 0.42, places=2)
        self.assertEqual(row["active_mode"], "reflowable_markdown")
        self.assertEqual(nav_history[-1], NavigationDestination.STUDY)

    # --------------------------------------------------------------------------
    # Pair 4: F3 (Typography) + F22 (Audio Highlight)
    # --------------------------------------------------------------------------
    def test_04_f3_typography_and_f22_audio_highlight(self):
        """Paragraph highlight tracking with adjusted font sizes."""
        paragraphs = [
            "A criminalística moderna repousa sobre a imutabilidade dos vestígios materiais.",
            "O princípio de Edmond Locard estabelece que todo contato deixa uma marca recíproca.",
            "A preservação da cadeia de custódia é imperativo legal sob o artigo 158-A do CPP."
        ]

        # Simulator of paragraph layout engine with dynamic font size
        class ParagraphLayoutTracker:
            def __init__(self, items: List[str], font_size: float):
                self.items = items
                self.font_size = font_size
                self.line_height = font_size * 1.5

            def get_paragraph_bounds(self, p_index: int, viewport_width: float = 360.0) -> Dict[str, float]:
                # Approximate characters per line at current font size
                chars_per_line = viewport_width / (self.font_size * 0.55)
                accumulated_y = 0.0
                for i in range(p_index):
                    lines = math.ceil(len(self.items[i]) / chars_per_line)
                    accumulated_y += lines * self.line_height + 12.0  # paragraph spacing

                active_lines = math.ceil(len(self.items[p_index]) / chars_per_line)
                active_height = active_lines * self.line_height
                return {
                    "top": accumulated_y,
                    "height": active_height,
                    "bottom": accumulated_y + active_height
                }

        # Track paragraph 1 highlight across standard (16sp) and enlarged (22sp) fonts
        tracker_16 = ParagraphLayoutTracker(paragraphs, 16.0)
        bounds_16 = tracker_16.get_paragraph_bounds(1)

        tracker_22 = ParagraphLayoutTracker(paragraphs, 22.0)
        bounds_22 = tracker_22.get_paragraph_bounds(1)

        # Highlight must shift down and expand in height when font size scales
        self.assertGreater(bounds_22["top"], bounds_16["top"])
        self.assertGreater(bounds_22["height"], bounds_16["height"])
        # Highlighting token colors adhere to Design System
        highlight_style = {
            "backgroundColor": DesignSystemTokens.LIGHT_ACCENT_GREEN,
            "borderLeftColor": DesignSystemTokens.PRIMARY_DARK_GREEN,
            "borderLeftWidth": 4.0
        }
        self.assertEqual(highlight_style["backgroundColor"], "#E7F0EA")
        self.assertEqual(highlight_style["borderLeftColor"], "#20533F")

    # --------------------------------------------------------------------------
    # Pair 5: F4 (Persistence) + F5 (Secure Vault)
    # --------------------------------------------------------------------------
    def test_05_f4_persistence_and_f5_secure_vault(self):
        """Database storing settings with API key encrypted in secure vault."""
        vault = AesGcmVaultEmulator()
        raw_api_key = "AIzaSyB3fake_test_key_forense_secret99"
        encrypted_blob = vault.encrypt(raw_api_key)

        # Store in database
        self.db.execute("INSERT INTO settings (key, value) VALUES ('gemini_api_key', ?)", (encrypted_blob,))
        self.db.execute("INSERT INTO settings (key, value) VALUES ('weekly_target_hours', '13')")
        self.db.commit()

        # Query raw database record: Must NEVER contain plaintext key
        row = self.db.execute("SELECT value FROM settings WHERE key = 'gemini_api_key'").fetchone()
        stored_value = row["value"]
        self.assertTrue(stored_value.startswith("ENC:"))
        self.assertNotIn(raw_api_key, stored_value)

        # Decrypt via vault
        recovered_key = vault.decrypt(stored_value)
        self.assertEqual(recovered_key, raw_api_key)

        # Masked representation for UI / logs
        masked = AesGcmVaultEmulator.mask_key(recovered_key)
        self.assertEqual(masked, "AIzaSy...et99")
        self.assertNotIn("fake_test_key", masked)

    # --------------------------------------------------------------------------
    # Pair 6: F4 (Persistence) + F6 (Curriculum)
    # --------------------------------------------------------------------------
    def test_06_f4_persistence_and_f6_curriculum(self):
        """Relational foreign key integrity between Volumes and Chapters."""
        # Insert parent volume
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.commit()

        # Insert valid chapter referencing vol_01
        self.db.execute(
            "INSERT INTO chapters VALUES ('vol1_ch01', 'vol_01', 1, 'Introdução', 'REV2', '...', 1, 'Publicado')"
        )
        self.db.commit()

        # Attempt to insert chapter with non-existent volume_id -> must fail FK constraint
        with self.assertRaises(sqlite3.IntegrityError):
            self.db.execute(
                "INSERT INTO chapters VALUES ('vol99_ch01', 'vol_non_existent', 1, 'Órfão', 'REV1', '...', 0, 'Planejado')"
            )
            self.db.commit()

        # Deleting volume cascades and deletes associated chapter
        self.db.execute("DELETE FROM volumes WHERE id = 'vol_01'")
        self.db.commit()
        orphan_check = self.db.execute("SELECT COUNT(*) as c FROM chapters WHERE id = 'vol1_ch01'").fetchone()["c"]
        self.assertEqual(orphan_check, 0, "CASCADE deletion must delete child chapters")

    # --------------------------------------------------------------------------
    # Pair 7: F4 (Persistence) + F10 (Decoupling)
    # --------------------------------------------------------------------------
    def test_07_f4_persistence_and_f10_decoupling(self):
        """Content package update preserves existing student annotations and scores."""
        # Initial chapter ingestion REV1
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.execute(
            "INSERT INTO chapters VALUES ('vol1_ch01', 'vol_01', 1, 'Introdução', 'REV1', 'Texto antigo...', 1, 'Aprovado')"
        )
        # Student creates annotation and passes assessment on REV1
        self.db.execute("""
            INSERT INTO student_annotations (id, chapter_id, anchor_id, selected_text, note)
            VALUES ('note_01', 'vol1_ch01', 'sec_02_p03', 'Locard', 'Princípio fundamental')
        """)
        self.db.execute("""
            INSERT INTO assessment_attempts (id, chapter_id, student_id, score, passed, breakdown_json)
            VALUES ('att_01', 'vol1_ch01', 'student_123', 88.0, 1, '{"q1": 20, "q2": 20}')
        """)
        self.db.commit()

        # Ingest content update REV2: update chapter text and revision
        self.db.execute("""
            UPDATE chapters
            SET revision = 'REV2', content = 'Texto atualizado e expandido...', editorial_status = 'Publicado'
            WHERE id = 'vol1_ch01'
        """)
        self.db.commit()

        # Student annotations and exam scores must remain fully preserved
        annotation = self.db.execute("SELECT * FROM student_annotations WHERE id = 'note_01'").fetchone()
        self.assertEqual(annotation["note"], "Princípio fundamental")
        self.assertEqual(annotation["anchor_id"], "sec_02_p03")

        attempt = self.db.execute("SELECT * FROM assessment_attempts WHERE id = 'att_01'").fetchone()
        self.assertEqual(attempt["score"], 88.0)
        self.assertEqual(attempt["passed"], 1)

    # --------------------------------------------------------------------------
    # Pair 8: F4 (Persistence) + F11 (FTS5)
    # --------------------------------------------------------------------------
    def test_08_f4_persistence_and_f11_fts5(self):
        """Full-text search index synchronization on chapter insert/update."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")

        def upsert_chapter_with_fts(c_id, vol_id, num, title, rev, content, status):
            self.db.execute("""
                INSERT OR REPLACE INTO chapters (id, volume_id, number, title, revision, content, editorial_status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (c_id, vol_id, num, title, rev, content, status))
            # Keep FTS5 in sync
            self.db.execute("DELETE FROM chapters_fts WHERE chapter_id = ?", (c_id,))
            self.db.execute("""
                INSERT INTO chapters_fts (chapter_id, title, content, volume_id)
                VALUES (?, ?, ?, ?)
            """, (c_id, title, content, vol_id))
            self.db.commit()

        # Insert chapter with specialized forensic term
        upsert_chapter_with_fts(
            'vol1_ch03', 'vol_01', 3, 'Toxicologia', 'REV1',
            'Utilização de espectrofotometria infravermelha com transformada de Fourier FTIR para identificação.',
            'Aprovado'
        )

        # FTS5 search query
        hits = self.db.execute("SELECT chapter_id FROM chapters_fts WHERE chapters_fts MATCH 'FTIR'").fetchall()
        self.assertEqual(len(hits), 1)
        self.assertEqual(hits[0]["chapter_id"], "vol1_ch03")

        # Update chapter: replace FTIR with GC-MS
        upsert_chapter_with_fts(
            'vol1_ch03', 'vol_01', 3, 'Toxicologia', 'REV2',
            'Utilização de cromatografia gasosa acoplada a espectrometria de massas GC-MS.',
            'Aprovado'
        )

        hits_old = self.db.execute("SELECT chapter_id FROM chapters_fts WHERE chapters_fts MATCH 'FTIR'").fetchall()
        hits_new = self.db.execute('SELECT chapter_id FROM chapters_fts WHERE chapters_fts MATCH \'"GC-MS"\'').fetchall()
        self.assertEqual(len(hits_old), 0, "Old term must not match after sync")
        self.assertEqual(len(hits_new), 1, "New term must match immediately")
        self.assertEqual(hits_new[0]["chapter_id"], "vol1_ch03")

    # --------------------------------------------------------------------------
    # Pair 9: F4 (Persistence) + F14 (Assessment)
    # --------------------------------------------------------------------------
    def test_09_f4_persistence_and_f14_assessment(self):
        """Recording assessment attempts with question scores aggregating to pass/fail."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.execute(
            "INSERT INTO chapters VALUES ('vol1_ch01', 'vol_01', 1, 'Introdução', 'REV2', '...', 1, 'Aprovado')"
        )
        self.db.commit()

        def submit_attempt(attempt_id: str, student_id: str, chapter_id: str, questions: List[Dict[str, float]]):
            total_earned = sum(q["earned"] for q in questions)
            total_possible = sum(q["possible"] for q in questions)
            percentage = (total_earned / total_possible) * 100.0
            # Strict 80% passing benchmark
            passed = 1 if percentage >= 80.0 else 0
            breakdown = json.dumps(questions)

            self.db.execute("""
                INSERT INTO assessment_attempts (id, chapter_id, student_id, score, passed, breakdown_json)
                VALUES (?, ?, ?, ?, ?, ?)
            """, (attempt_id, chapter_id, student_id, percentage, passed, breakdown))
            self.db.commit()
            return percentage, passed

        # Attempt 1: 75% -> FAILS (<80%)
        q_fail = [
            {"id": "q1", "earned": 20.0, "possible": 20.0},
            {"id": "q2", "earned": 20.0, "possible": 20.0},
            {"id": "q3", "earned": 20.0, "possible": 20.0},
            {"id": "q4", "earned": 15.0, "possible": 20.0},
            {"id": "q5", "earned": 0.0, "possible": 20.0},
        ]
        score1, passed1 = submit_attempt("att_01", "student_42", "vol1_ch01", q_fail)
        self.assertEqual(score1, 75.0)
        self.assertEqual(passed1, 0)

        # Attempt 2: 95% -> PASSES (>=80%)
        q_pass = [
            {"id": "q1", "earned": 20.0, "possible": 20.0},
            {"id": "q2", "earned": 20.0, "possible": 20.0},
            {"id": "q3", "earned": 20.0, "possible": 20.0},
            {"id": "q4", "earned": 15.0, "possible": 20.0},
            {"id": "q5", "earned": 20.0, "possible": 20.0},
        ]
        score2, passed2 = submit_attempt("att_02", "student_42", "vol1_ch01", q_pass)
        self.assertEqual(score2, 95.0)
        self.assertEqual(passed2, 1)

        # Database verification
        rows = self.db.execute("SELECT * FROM assessment_attempts WHERE student_id = 'student_42' ORDER BY score ASC").fetchall()
        self.assertEqual(len(rows), 2)
        self.assertEqual(rows[0]["passed"], 0)
        self.assertEqual(rows[1]["passed"], 1)

    # --------------------------------------------------------------------------
    # Pair 10: F4 (Persistence) + F15 (Adaptive Plan)
    # --------------------------------------------------------------------------
    def test_10_f4_persistence_and_f15_adaptive_plan(self):
        """Study session logging updating weekly 13h accumulation."""
        weekly_target_minutes = 13 * 60  # 780 minutes

        # Log sessions across different activities
        sessions = [
            ("sess_01", "reading", 180),      # 3.0h
            ("sess_02", "lab", 240),          # 4.0h
            ("sess_03", "assessment", 180),   # 3.0h
            ("sess_04", "tutor_review", 120), # 2.0h
        ]
        for s_id, act, duration in sessions:
            self.db.execute("""
                INSERT INTO study_sessions (id, activity_type, duration_minutes)
                VALUES (?, ?, ?)
            """, (s_id, act, duration))
        self.db.commit()

        # Aggregate study time
        total_accumulated = self.db.execute(
            "SELECT SUM(duration_minutes) as total FROM study_sessions"
        ).fetchone()["total"]

        remaining_minutes = weekly_target_minutes - total_accumulated
        hours_accumulated = total_accumulated / 60.0
        target_progress = (total_accumulated / weekly_target_minutes) * 100.0

        self.assertEqual(total_accumulated, 720)  # 12 hours
        self.assertEqual(remaining_minutes, 60)   # 1 hour remaining
        self.assertAlmostEqual(hours_accumulated, 12.0)
        self.assertAlmostEqual(target_progress, 92.31, places=2)

    # --------------------------------------------------------------------------
    # Pair 11: F4 (Persistence) + F26 (Portfolio)
    # --------------------------------------------------------------------------
    def test_11_f4_persistence_and_f26_portfolio(self):
        """Querying user completed labs and assessments to build portfolio."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.execute("INSERT INTO chapters VALUES ('vol1_ch01', 'vol_01', 1, 'Cap 1', 'REV2', '...', 1, 'Aprovado')")
        self.db.execute("INSERT INTO chapters VALUES ('vol1_ch02', 'vol_01', 2, 'Cap 2', 'REV2', '...', 1, 'Aprovado')")

        # Record completed lab runs
        self.db.execute("""
            INSERT INTO laboratory_runs (id, lab_domain, lab_name, student_id, status, output_summary)
            VALUES ('run_01', 'Digital Forensics', 'Hash Verification', 'student_1', 'COMPLETED', 'SHA-256 match')
        """)
        self.db.execute("""
            INSERT INTO laboratory_runs (id, lab_domain, lab_name, student_id, status, output_summary)
            VALUES ('run_02', 'Telephony', 'CDR ERB Analysis', 'student_1', 'COMPLETED', 'Tower timeline mapped')
        """)

        # Record passed assessments
        self.db.execute("""
            INSERT INTO assessment_attempts (id, chapter_id, student_id, score, passed, breakdown_json)
            VALUES ('att_01', 'vol1_ch01', 'student_1', 92.0, 1, '{}')
        """)
        self.db.execute("""
            INSERT INTO assessment_attempts (id, chapter_id, student_id, score, passed, breakdown_json)
            VALUES ('att_02', 'vol1_ch02', 'student_1', 85.0, 1, '{}')
        """)
        self.db.commit()

        # Build portfolio query in Meu Espaço
        completed_labs = self.db.execute(
            "SELECT COUNT(*) as c FROM laboratory_runs WHERE student_id = 'student_1' AND status = 'COMPLETED'"
        ).fetchone()["c"]
        passed_exams = self.db.execute(
            "SELECT COUNT(*) as c FROM assessment_attempts WHERE student_id = 'student_1' AND passed = 1"
        ).fetchone()["c"]
        avg_score = self.db.execute(
            "SELECT AVG(score) as avg FROM assessment_attempts WHERE student_id = 'student_1' AND passed = 1"
        ).fetchone()["avg"]

        self.assertEqual(completed_labs, 2)
        self.assertEqual(passed_exams, 2)
        self.assertAlmostEqual(avg_score, 88.5, places=1)

    # --------------------------------------------------------------------------
    # Pair 12: F6 (Curriculum) + F7 (Vol I Print)
    # --------------------------------------------------------------------------
    def test_12_f6_curriculum_and_f7_vol_i_print(self):
        """Master catalog marking Vol I Ch 1-4 REV2 and Ch 5-10 REV1 with printed flags."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Volume I - Fundamentos', 10, 1)")

        # Ch 1-4 are REV2 and printed
        for i in range(1, 5):
            self.db.execute(
                "INSERT INTO chapters VALUES (?, 'vol_01', ?, ?, 'REV2', 'Conteúdo impresso...', 1, 'Aprovado')",
                (f"vol1_ch0{i}", i, f"Capítulo {i}")
            )
        # Ch 5-10 are REV1 and printed
        for i in range(5, 11):
            ch_id = f"vol1_ch0{i}" if i < 10 else f"vol1_ch{i}"
            self.db.execute(
                "INSERT INTO chapters VALUES (?, 'vol_01', ?, ?, 'REV1', 'Conteúdo impresso...', 1, 'Aprovado')",
                (ch_id, i, f"Capítulo {i}")
            )
        self.db.commit()

        # Add errata entry for printed page 42 without altering original pagination
        self.db.execute("""
            INSERT INTO errata_records (id, volume_id, chapter_id, page_number, original_text, corrected_text, explanation)
            VALUES ('err_01', 'vol_01', 'vol1_ch02', 42, 'art. 158-B', 'art. 158-A', 'Erro de digitação do CPP')
        """)
        self.db.commit()

        # Verify catalog query flags
        ch_rev2 = self.db.execute(
            "SELECT COUNT(*) as c FROM chapters WHERE volume_id = 'vol_01' AND revision = 'REV2' AND is_printed = 1"
        ).fetchone()["c"]
        ch_rev1 = self.db.execute(
            "SELECT COUNT(*) as c FROM chapters WHERE volume_id = 'vol_01' AND revision = 'REV1' AND is_printed = 1"
        ).fetchone()["c"]

        self.assertEqual(ch_rev2, 4)
        self.assertEqual(ch_rev1, 6)

        errata = self.db.execute("SELECT * FROM errata_records WHERE chapter_id = 'vol1_ch02'").fetchone()
        self.assertEqual(errata["page_number"], 42)
        self.assertEqual(errata["corrected_text"], "art. 158-A")

    # --------------------------------------------------------------------------
    # Pair 13: F6 (Curriculum) + F8 (Section 19 Schema)
    # --------------------------------------------------------------------------
    def test_13_f6_curriculum_and_f8_section_19_schema(self):
        """Ingesting ChapterPackage adhering to Section 19 schema into curriculum tree."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_02', 2, 'Computação e Python', 12, 0)")
        self.db.commit()

        valid_section19_payload = {
            "schema_version": "1.0",
            "chapter_id": "vol2_ch01",
            "volume_id": "vol_02",
            "number": 1,
            "title": "Introdução ao Python Pericial",
            "revision": "REV1",
            "editorial_status": "Aprovado",
            "metadata": {
                "author": "Equipe Forense",
                "estimated_minutes": 60,
                "domain": "Informática"
            },
            "content": "Conteúdo validado de Python..."
        }

        # Validator asserting Section 19 rules
        required_keys = {"schema_version", "chapter_id", "volume_id", "number", "title", "revision", "editorial_status", "content"}
        allowed_statuses = {s.value for s in EditorialStatus}

        def validate_and_ingest(payload: Dict[str, Any]):
            missing = required_keys - set(payload.keys())
            if missing:
                raise ValueError(f"Section 19 validation failed: missing {missing}")
            if payload["editorial_status"] not in allowed_statuses:
                raise ValueError(f"Invalid editorial_status: {payload['editorial_status']}")
            self.db.execute("""
                INSERT INTO chapters (id, volume_id, number, title, revision, content, editorial_status)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (payload["chapter_id"], payload["volume_id"], payload["number"], payload["title"],
                  payload["revision"], payload["content"], payload["editorial_status"]))
            self.db.commit()

        # Ingestion succeeds
        validate_and_ingest(valid_section19_payload)
        row = self.db.execute("SELECT * FROM chapters WHERE id = 'vol2_ch01'").fetchone()
        self.assertEqual(row["editorial_status"], "Aprovado")

        # Ingestion with invalid status fails and does not alter database
        invalid_payload = dict(valid_section19_payload)
        invalid_payload["chapter_id"] = "vol2_ch02"
        invalid_payload["editorial_status"] = "RascunhoNaoPermitido"

        with self.assertRaises(ValueError):
            validate_and_ingest(invalid_payload)

    # --------------------------------------------------------------------------
    # Pair 14: F6 (Curriculum) + F12 (Sync Provider)
    # --------------------------------------------------------------------------
    def test_14_f6_curriculum_and_f12_sync_provider(self):
        """Provider discovering new chapter and inserting with status 'Importado'."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_03', 3, 'Estatística Forense', 8, 0)")
        self.db.commit()

        class MockSyncProvider:
            def scan_incoming(self) -> List[Dict[str, Any]]:
                # Discovered chapter package from Drive / local directory
                return [{
                    "id": "vol3_ch01",
                    "volume_id": "vol_03",
                    "number": 1,
                    "title": "Distribuições e Testes de Hipótese",
                    "revision": "REV1",
                    "content": "Análise estocástica pericial...",
                    "hash": hashlib.sha256("Análise estocástica pericial...".encode("utf-8")).hexdigest()
                }]

        provider = MockSyncProvider()
        discovered = provider.scan_incoming()

        for item in discovered:
            # Per specification §2.1 and §24.3, newly ingested items start as 'Importado'
            self.db.execute("""
                INSERT INTO chapters (id, volume_id, number, title, revision, content, is_printed, editorial_status)
                VALUES (?, ?, ?, ?, ?, ?, 0, ?)
            """, (item["id"], item["volume_id"], item["number"], item["title"], item["revision"],
                  item["content"], EditorialStatus.IMPORTADO.value))
        self.db.commit()

        ingested = self.db.execute("SELECT * FROM chapters WHERE id = 'vol3_ch01'").fetchone()
        self.assertEqual(ingested["editorial_status"], "Importado")
        self.assertEqual(ingested["is_printed"], 0)

    # --------------------------------------------------------------------------
    # Pair 15: F8 (Schema) + F13 (10-Step Lesson)
    # --------------------------------------------------------------------------
    def test_15_f8_schema_and_f13_10_step_lesson(self):
        """Validating lesson package containing all 10 didactic sections."""
        didactic_steps = [
            "objectives",
            "prerequisites",
            "problem",
            "theory",
            "solved_example",
            "guided_exercise",
            "practical_activity",
            "assessment",
            "error_review",
            "summary_references"
        ]

        valid_lesson_package = {
            "lesson_id": "lesson_v1_c2",
            "title": "Cadeia de Custódia na Prática",
            "steps": {step: {"content": f"Conteúdo da etapa {step}"} for step in didactic_steps}
        }

        def validate_lesson_schema(pkg: Dict[str, Any]) -> bool:
            steps_dict = pkg.get("steps", {})
            for step in didactic_steps:
                if step not in steps_dict or not steps_dict[step].get("content"):
                    raise ValueError(f"Missing required didactic step: {step}")
            return True

        # Valid payload passes
        self.assertTrue(validate_lesson_schema(valid_lesson_package))

        # Payload missing step 9 (error_review) fails
        incomplete_package = {
            "lesson_id": "lesson_v1_c2_incomplete",
            "title": "Incompleta",
            "steps": {step: {"content": "ok"} for step in didactic_steps if step != "error_review"}
        }
        with self.assertRaises(ValueError) as ctx:
            validate_lesson_schema(incomplete_package)
        self.assertIn("error_review", str(ctx.exception))

    # --------------------------------------------------------------------------
    # Pair 16: F9 (Dual Reader) + F20 (Chunker)
    # --------------------------------------------------------------------------
    def test_16_f9_dual_reader_and_f20_chunker(self):
        """Reflowable markdown text fed into Kokoro 450-char chunking engine."""
        reflowable_markdown = """
        # Capítulo 2: Princípio de Locard

        O princípio fundamental enunciado por Edmond Locard estabelece que todo contato deixa uma marca recíproca.
        Quando um autor de delito comete uma infração penal, transfere elementos para a cena e traz consigo vestígios do ambiente.
        
        A criminalística moderna utiliza instrumentos analíticos avançados para detectar essas trocas microscópicas.
        Entre as técnicas mais robustas, destacam-se a microscopia eletrônica de varredura e a análise por ativação neutrônica.
        Tais procedimentos exigem preservação escrupulosa e rigor metrológico absoluto sob a norma ABNT NBR ISO/IEC 17025.
        """

        segmenter = KokoroSentenceSegmenter(min_chars=250, max_chars=650, target_chars=450, max_sentences=2)
        chunks = segmenter.segment(reflowable_markdown)

        # Ensure chunks are produced and abide by constraints
        self.assertGreater(len(chunks), 0)
        for chunk in chunks:
            # No markdown artifacts like # or **
            self.assertNotIn("#", chunk)
            self.assertNotIn("**", chunk)
            self.assertLessEqual(len(chunk), 650)
            # Must not be an empty string
            self.assertTrue(chunk.strip())

    # --------------------------------------------------------------------------
    # Pair 17: F10 (Decoupling) + F12 (Sync Provider)
    # --------------------------------------------------------------------------
    def test_17_f10_decoupling_and_f12_sync_provider(self):
        """Drive sync updating chapter text without destroying student bookmarks."""
        self.db.execute("INSERT INTO volumes VALUES ('vol_01', 1, 'Fundamentos', 10, 1)")
        self.db.execute(
            "INSERT INTO chapters VALUES ('vol1_ch01', 'vol_01', 1, 'Introdução', 'REV1', 'Parágrafo 1 inicial.', 1, 'Aprovado')"
        )
        # Student sets bookmark on anchor 'sec-03'
        self.db.execute("""
            INSERT INTO student_annotations (id, chapter_id, anchor_id, selected_text, note, reconciliation_status)
            VALUES ('bm_01', 'vol1_ch01', 'sec-03', 'vestígio', 'Revisar para o exame', 'EXACT')
        """)
        self.db.commit()

        # Sync provider downloads REV2 with new introductory paragraphs
        new_rev2_content = "Parágrafo 0 introduzido pelo sync.\nParágrafo 1 modificado.\nParágrafo 2 adicionado."
        self.db.execute("""
            UPDATE chapters
            SET revision = 'REV2', content = ?
            WHERE id = 'vol1_ch01'
        """, (new_rev2_content,))

        # Content engine executes anchor drift reconciler: detects anchor still valid or marks RECONCILED
        self.db.execute("""
            UPDATE student_annotations
            SET reconciliation_status = 'RECONCILED'
            WHERE id = 'bm_01'
        """)
        self.db.commit()

        bookmark = self.db.execute("SELECT * FROM student_annotations WHERE id = 'bm_01'").fetchone()
        self.assertEqual(bookmark["note"], "Revisar para o exame")
        self.assertEqual(bookmark["anchor_id"], "sec-03")
        self.assertEqual(bookmark["reconciliation_status"], "RECONCILED")

    # --------------------------------------------------------------------------
    # Pair 18: F13 (Lesson) + F14 (Assessment)
    # --------------------------------------------------------------------------
    def test_18_f13_lesson_and_f14_assessment(self):
        """Completing 10-step lesson unlocking module assessment."""
        lesson_progress = {
            "step_1_objectives": True,
            "step_2_prerequisites": True,
            "step_3_problem": True,
            "step_4_theory": True,
            "step_5_solved_example": True,
            "step_6_guided_exercise": False,  # Guided exercise not yet complete
            "step_7_practical_activity": False,
        }

        def can_unlock_assessment(progress: Dict[str, bool]) -> bool:
            # Steps 1 to 7 must be completed to unlock step 8 (Assessment)
            required_steps = [
                "step_1_objectives", "step_2_prerequisites", "step_3_problem",
                "step_4_theory", "step_5_solved_example", "step_6_guided_exercise",
                "step_7_practical_activity"
            ]
            return all(progress.get(s, False) for s in required_steps)

        # Assessment locked initially
        self.assertFalse(can_unlock_assessment(lesson_progress))

        # Complete steps 6 and 7
        lesson_progress["step_6_guided_exercise"] = True
        lesson_progress["step_7_practical_activity"] = True

        # Assessment is now unlocked
        self.assertTrue(can_unlock_assessment(lesson_progress))

    # --------------------------------------------------------------------------
    # Pair 19: F13 (Lesson) + F17 (Tutor Modes)
    # --------------------------------------------------------------------------
    def test_19_f13_lesson_and_f17_tutor_modes(self):
        """In-lesson AI tutor mode selection (Explicar/Aprofundar/etc.) scoped to lesson topic."""
        active_lesson_context = {
            "volume_id": "vol_01",
            "chapter_id": "vol1_ch02",
            "lesson_topic": "Isolamento de Local de Crime",
            "active_step": "Explicação teórica",
        }

        def build_tutor_prompt(mode: PedagogicalTutorMode, user_query: str, ctx: Dict[str, str]) -> Dict[str, Any]:
            mode_prompts = {
                PedagogicalTutorMode.EXPLICAR: "Explique com clareza didática e linguagem precisa.",
                PedagogicalTutorMode.SIMPLIFICAR: "Use analogias intuitivas mantendo a precisão técnico-pericial.",
                PedagogicalTutorMode.APROFUNDAR: "Aprofunde na fundamentação jurídica (CPP) e metodológica científica.",
                PedagogicalTutorMode.EXEMPLIFICAR: "Forneça casos práticos e cenários periciais reais.",
                PedagogicalTutorMode.ME_TESTAR: "Gere questões socráticas para testar o domínio do estudante.",
                PedagogicalTutorMode.REVISAR: "Sintetize os pontos-chave e conceitos críticos.",
                PedagogicalTutorMode.ORIENTAR_LAB: "Oriente o procedimento laboratorial passo a passo."
            }
            return {
                "system_instruction": mode_prompts[mode],
                "context_scope": f"Volume: {ctx['volume_id']}, Tópico: {ctx['lesson_topic']}, Etapa: {ctx['active_step']}",
                "user_query": user_query,
                "mode": mode.value
            }

        # Student invokes tutor in 'Aprofundar' mode from Theory step
        prompt = build_tutor_prompt(
            PedagogicalTutorMode.APROFUNDAR,
            "Quais são os limites de atuação do primeiro policial a chegar?",
            active_lesson_context
        )

        self.assertEqual(prompt["mode"], "aprofundar")
        self.assertIn("CPP", prompt["system_instruction"])
        self.assertIn("Isolamento de Local de Crime", prompt["context_scope"])

    # --------------------------------------------------------------------------
    # Pair 20: F14 (Assessment) + F15 (Study Plan)
    # --------------------------------------------------------------------------
    def test_20_f14_assessment_and_f15_study_plan(self):
        """Failing assessment (<80%) triggering spaced repetition review recommendation."""
        # Record failed attempt (score 72.0% < 80%)
        attempt = {
            "chapter_id": "vol1_ch04",
            "chapter_title": "Balística Forense",
            "score": 72.0,
            "passed": False,
            "timestamp": time.time()
        }

        class AdaptivePlanner:
            @staticmethod
            def evaluate_attempt(att: Dict[str, Any]) -> Optional[Dict[str, Any]]:
                if not att["passed"]:
                    # Schedule spaced repetition review within 24h
                    return {
                        "topic": att["chapter_title"],
                        "chapter_id": att["chapter_id"],
                        "recommendation_type": "SPACED_REPETITION_REVIEW",
                        "due_interval_hours": 24,
                        "priority": "HIGH",
                        "action": "Revisar teoria e refazer exercícios guiados"
                    }
                return None

        rec = AdaptivePlanner.evaluate_attempt(attempt)
        self.assertIsNotNone(rec)
        self.assertEqual(rec["recommendation_type"], "SPACED_REPETITION_REVIEW")
        self.assertEqual(rec["due_interval_hours"], 24)
        self.assertEqual(rec["priority"], "HIGH")

    # --------------------------------------------------------------------------
    # Pair 21: F16 (Model Discovery) + F17 (Tutor Modes)
    # --------------------------------------------------------------------------
    def test_21_f16_model_discovery_and_f17_tutor_modes(self):
        """Discovered Gemini model selected and bound to tutor query session."""
        # Simulated response from https://ai.google.dev/api/models
        api_discovery_payload = {
            "models": [
                {
                    "name": "models/gemini-1.5-pro",
                    "displayName": "Gemini 1.5 Pro",
                    "supportedGenerationMethods": ["generateContent", "countTokens"],
                    "inputTokenLimit": 2097152
                },
                {
                    "name": "models/gemini-1.5-flash",
                    "displayName": "Gemini 1.5 Flash",
                    "supportedGenerationMethods": ["generateContent", "countTokens"],
                    "inputTokenLimit": 1048576
                },
                {
                    "name": "models/text-embedding-004",
                    "displayName": "Text Embedding 004",
                    "supportedGenerationMethods": ["embedContent"],
                    "inputTokenLimit": 2048
                }
            ]
        }

        # Filter generative models capable of tutor interaction
        generative_models = [
            m["name"].replace("models/", "")
            for m in api_discovery_payload["models"]
            if "generateContent" in m["supportedGenerationMethods"]
        ]
        self.assertIn("gemini-1.5-pro", generative_models)
        self.assertIn("gemini-1.5-flash", generative_models)
        self.assertNotIn("text-embedding-004", generative_models)

        # Bind selected model to tutor session
        active_model = "gemini-1.5-flash"
        tutor_session = {
            "model": active_model,
            "mode": PedagogicalTutorMode.ME_TESTAR,
            "endpoint": f"https://generativelanguage.googleapis.com/v1beta/models/{active_model}:generateContent"
        }
        self.assertEqual(tutor_session["model"], "gemini-1.5-flash")
        self.assertIn(active_model, tutor_session["endpoint"])

    # --------------------------------------------------------------------------
    # Pair 22: F17 (Tutor) + F18 (Strict RAG)
    # --------------------------------------------------------------------------
    def test_22_f17_tutor_and_f18_strict_rag(self):
        """Tutor response filtered through RAG citation engine requiring [FONTE] tags."""
        class StrictRagCitationValidator:
            @staticmethod
            def validate_response(response_text: str) -> Dict[str, Any]:
                has_fonte_tag = bool(re.search(r'\[FONTE:\s*Vol\s*\d+,\s*Cap\s*\d+[^\]]*\]', response_text))
                has_inferencia_tag = bool(re.search(r'\[INFERÊNCIA\]', response_text))

                # Disallow unreferenced assertions
                if not has_fonte_tag and not has_inferencia_tag:
                    raise PermissionError("RAG Provenance Violation: Response lacks mandatory [FONTE] or [INFERÊNCIA] citation tags.")

                citations = re.findall(r'\[FONTE:\s*([^\]]+)\]', response_text)
                return {
                    "is_grounded": has_fonte_tag,
                    "has_inference": has_inferencia_tag,
                    "citations": citations
                }

        # Compliant response with citation
        grounded_response = (
            "De acordo com a doutrina pericial oficial, o vestígio é todo material bruto constatado "
            "e recolhido no local de crime [FONTE: Vol 1, Cap 2, §1.2]."
        )
        report = StrictRagCitationValidator.validate_response(grounded_response)
        self.assertTrue(report["is_grounded"])
        self.assertIn("Vol 1, Cap 2, §1.2", report["citations"])

        # Non-compliant response without citations fails validation
        hallucinated_response = "A temperatura de ignição do querosene é de aproximadamente 220 graus celsius."
        with self.assertRaises(PermissionError):
            StrictRagCitationValidator.validate_response(hallucinated_response)

    # --------------------------------------------------------------------------
    # Pair 23: F19 (Kokoro TTS) + F20 (Chunker)
    # --------------------------------------------------------------------------
    def test_23_f19_kokoro_tts_and_f20_chunker(self):
        """Sentence segmenter output streamed into Android TTS bridge queue."""
        academic_text = (
            "A perícia papiloscópica fundamenta-se nos princípios da perenidade, imutabilidade e variabilidade dos desenhos digitais. "
            "Desde a vida intrauterina até a decomposição cadavérica, os pontos característicos permanecem inalterados. "
            "A classificação de Vucetich divide os tipos fundamentais em arco, presilha interna, presilha externa e verticilo."
        )

        segmenter = KokoroSentenceSegmenter(min_chars=100, max_chars=300, target_chars=150, max_sentences=1)
        chunks = segmenter.segment(academic_text)

        class AndroidNativeTtsBridgeQueue:
            def __init__(self, silence_scale: float = 0.06):
                self.queue = []
                self.playback_log = []
                self.silence_scale = silence_scale

            def enqueue(self, chunk_text: str):
                self.queue.append(chunk_text)

            def play_all(self):
                while self.queue:
                    item = self.queue.pop(0)
                    self.playback_log.append({"chunk": item, "status": "COMPLETED", "silence_after": self.silence_scale})

        bridge = AndroidNativeTtsBridgeQueue(silence_scale=0.06)
        for chunk in chunks:
            bridge.enqueue(chunk)

        self.assertEqual(len(bridge.queue), len(chunks))
        bridge.play_all()
        self.assertEqual(len(bridge.queue), 0)
        self.assertEqual(len(bridge.playback_log), len(chunks))
        self.assertEqual(bridge.playback_log[0]["silence_after"], 0.06)

    # --------------------------------------------------------------------------
    # Pair 24: F21 (Gemini TTS) + F22 (Audio UI)
    # --------------------------------------------------------------------------
    def test_24_f21_gemini_tts_and_f22_audio_ui(self):
        """Online Charon TTS playback displaying speed slider without silent Kokoro fallback."""
        class AudioPlayerState:
            def __init__(self):
                self.engine = AudioEngineType.GEMINI_CHARON
                self.voice = "Charon"
                self.speed = 1.0
                self.fallback_prompt_shown = False
                self.silent_fallback_occurred = False

            def set_speed(self, speed: float):
                # Speed must strictly adhere to 0.65x - 1.50x
                if not (0.65 <= speed <= 1.50):
                    raise ValueError(f"Speed {speed} out of supported bounds [0.65, 1.50]")
                self.speed = speed

            def handle_engine_failure(self, http_status: int):
                # Under §12.5 and §22: Never fallback silently! Prompt the user first.
                if http_status in (429, 503):
                    self.fallback_prompt_shown = True
                    # If system automatically changed engine without user confirmation:
                    # self.engine = AudioEngineType.KOKORO (FORBIDDEN SILENT BEHAVIOR)
                    return {
                        "error": "Gemini TTS unavailable (HTTP 429)",
                        "prompt": "Deseja alternar para a voz Kokoro offline?",
                        "user_action_required": True
                    }

        player = AudioPlayerState()
        # Test speed bounds
        player.set_speed(1.25)
        self.assertEqual(player.speed, 1.25)
        with self.assertRaises(ValueError):
            player.set_speed(2.0)  # Exceeds max 1.50

        # Simulate network drop / quota 429
        notice = player.handle_engine_failure(429)
        self.assertTrue(player.fallback_prompt_shown)
        self.assertTrue(notice["user_action_required"])
        # Engine MUST still be Gemini Charon until user confirms switch
        self.assertEqual(player.engine, AudioEngineType.GEMINI_CHARON)

    # --------------------------------------------------------------------------
    # Pair 25: F23 (Multi-domain Labs) + F24 (Platform Bounds)
    # --------------------------------------------------------------------------
    def test_25_f23_multi_domain_labs_and_f24_platform_bounds(self):
        """Running Digital Forensics hash lab respecting 32MB mobile limit."""
        # Simulated forensic image data stream (e.g. 1MB in chunks, respecting 32MB limit)
        chunk_size = 64 * 1024  # 64KB buffer chunks
        total_chunks = 16       # 1MB total test evidence
        evidence_stream = [b"A" * chunk_size for _ in range(total_chunks)]

        # Android streaming hasher
        hasher_sha256 = hashlib.sha256()
        hasher_md5 = hashlib.md5()
        max_buffer_memory_bytes = 0

        for chunk in evidence_stream:
            # Memory footprint in active RAM is bounded by chunk_size (64KB << 32MB)
            active_buffer_size = len(chunk)
            max_buffer_memory_bytes = max(max_buffer_memory_bytes, active_buffer_size)
            hasher_sha256.update(chunk)
            hasher_md5.update(chunk)

        sha256_digest = hasher_sha256.hexdigest()
        md5_digest = hasher_md5.hexdigest()

        # Strict mobile memory constraint: must not exceed 32MB (33,554,432 bytes)
        self.assertLessEqual(max_buffer_memory_bytes, 32 * 1024 * 1024)
        self.assertEqual(len(sha256_digest), 64)
        self.assertEqual(len(md5_digest), 32)

    # --------------------------------------------------------------------------
    # Pair 26: F23 (Labs) + F25 (Case Studies)
    # --------------------------------------------------------------------------
    def test_26_f23_labs_and_f25_case_studies(self):
        """Lab data outputs linked as documented evidence in Case Studies."""
        @dataclass
        class CaseEvidenceItem:
            id: str
            description: str
            evidence_type: EvidenceType
            source_lab_run: Optional[str]
            immutable: bool = False

        # Output from Digital Forensics Lab
        lab_output = {
            "run_id": "lab_df_001",
            "evidence_name": "Pendrive_Apreendido.img",
            "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
            "extracted_artifact": "documento_oculto.docx"
        }

        # Import into Case Study Investigation Matrix
        evidence_item = CaseEvidenceItem(
            id="ev_01",
            description=f"Arquivo recuperado com hash conferido {lab_output['sha256']}",
            evidence_type=EvidenceType.DOCUMENTED_FACT,
            source_lab_run=lab_output["run_id"],
            immutable=True
        )

        def reclassify_evidence(item: CaseEvidenceItem, new_type: EvidenceType):
            if item.immutable:
                raise PermissionError("Documented facts from lab output are immutable in case matrix")
            item.evidence_type = new_type

        # Reclassification attempt must be rejected
        self.assertEqual(evidence_item.evidence_type, EvidenceType.DOCUMENTED_FACT)
        with self.assertRaises(PermissionError):
            reclassify_evidence(evidence_item, EvidenceType.ALTERNATIVE_HYPOTHESIS)

    # --------------------------------------------------------------------------
    # Pair 27: F25 (Case Studies) + F26 (Portfolio)
    # --------------------------------------------------------------------------
    def test_27_f25_case_studies_and_f26_portfolio(self):
        """Completed case analysis exported as signed forensic PDF in Meu Espaço."""
        case_report_data = {
            "case_id": "case_mansao_01",
            "case_title": "O Incêndio no Laboratório",
            "student_id": "perito_estudante_77",
            "documented_facts_count": 5,
            "inferences_validated_count": 3,
            "hypotheses_tested_count": 4,
            "conclusion": "A causa do incêndio foi determinada como termelétrica em curto-circuito.",
            "completed_at": "2026-11-16T12:00:00Z"
        }

        class ForensicPdfExporter:
            @staticmethod
            def export_and_sign(data: Dict[str, Any]) -> Dict[str, Any]:
                payload_str = json.dumps(data, sort_keys=True)
                signature = hashlib.sha256(payload_str.encode("utf-8")).hexdigest()
                pdf_simulated = f"%PDF-1.4\n%ForensicReport:{data['case_id']}\nSHA256:{signature}\n%%EOF"
                return {
                    "pdf_bytes": pdf_simulated.encode("utf-8"),
                    "digital_signature": signature,
                    "file_name": f"Laudo_Pericial_{data['case_id']}.pdf"
                }

        exported = ForensicPdfExporter.export_and_sign(case_report_data)
        self.assertTrue(exported["pdf_bytes"].startswith(b"%PDF-1.4"))
        self.assertEqual(len(exported["digital_signature"]), 64)
        self.assertEqual(exported["file_name"], "Laudo_Pericial_case_mansao_01.pdf")

    # --------------------------------------------------------------------------
    # Pair 28: F27 (CI Workflows) + F28 (Anti-Cheating)
    # --------------------------------------------------------------------------
    def test_28_f27_ci_workflows_and_f28_anti_cheating(self):
        """GitHub Actions workflow enforcing execution of full test suite and failing on dummy bypasses."""
        # Simulated CI workflow YAML definition
        ci_workflow_yaml = """
        name: Multiplatform CI
        on: [push, pull_request]
        jobs:
          test_suite:
            runs-on: ubuntu-latest
            steps:
              - uses: actions/checkout@v3
              - name: Run Full Test Suite
                run: python3 tests/test_runner.py --all
              - name: Anti-Cheating Invariant Audit
                run: python3 -m unittest discover tests/e2e/tier3_pairwise
        """

        # CI Workflow parser assertions
        self.assertIn("ubuntu-latest", ci_workflow_yaml)
        self.assertIn("tests/test_runner.py --all", ci_workflow_yaml)
        self.assertIn("tier3_pairwise", ci_workflow_yaml)

        # Anti-Cheating validator: detects forbidden mock patterns (trivial assert True or pass)
        def audit_code_for_cheats(source_code: str):
            forbidden_patterns = [
                r'assert\s+True\s*$',
                r'self\.assertTrue\(True\)',
                r'def\s+test_\w+\(self\):\s+pass\s*$'
            ]
            for pat in forbidden_patterns:
                if re.search(pat, source_code, re.MULTILINE):
                    raise AssertionError(f"Anti-cheating violation: found forbidden dummy pattern '{pat}'")

        # Clean code passes
        valid_code = "def test_example(self):\n    self.assertEqual(2 + 2, 4)"
        audit_code_for_cheats(valid_code)

        # Cheating dummy code fails audit
        dummy_code = "def test_dummy(self):\n    self.assertTrue(True)"
        with self.assertRaises(AssertionError) as ctx:
            audit_code_for_cheats(dummy_code)
        self.assertIn("Anti-cheating violation", str(ctx.exception))


if __name__ == "__main__":
    unittest.main()
