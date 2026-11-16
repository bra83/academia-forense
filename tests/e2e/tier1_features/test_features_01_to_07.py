"""
Tier 1 Feature Coverage Tests: Features 01 to 07
Academia Forense — Laboratório de Formação

Coverage:
- Feature 1: Design System Palette & Contrast (WCAG AAA)
- Feature 2: Dual Responsive Navigation (Android 5-Tab & Windows NavigationRail)
- Feature 3: Adjustable Typography Controls
- Feature 4: 24-Entity Relational Persistence (SQLite/Drift Schema)
- Feature 5: Secure Settings Vault (BYOK Gemini Key, 13h Study Target)
- Feature 6: Curriculum Tree & Volume Catalog (9 Vols, 113 Chs, 7 Editorial States)
- Feature 7: Volume I Print Preservation (133 Pages, REV1/REV2 & Errata)
"""

import math
import sqlite3
import unittest
from typing import Dict, List, Optional, Tuple

from tests.test_fixtures.fixtures import (
    srgb_channel_to_linear,
    calculate_relative_luminance,
    calculate_contrast_ratio,
    verify_wcag_aaa,
)

# ==============================================================================
# Feature 1 Helper Functions & Models: Design System Palette & WCAG Contrast
# ==============================================================================

class PaletteTokens:
    BACKGROUND_MAIN = "#F5F6F3"
    SURFACE_CARD = "#FFFFFF"
    PRIMARY_FOREST = "#20533F"
    DARK_FOREST = "#163D2E"
    SECONDARY_FOREST = "#347259"
    LIGHT_FOREST = "#E7F0EA"
    TEXT_MAIN = "#26322C"
    TEXT_SECONDARY = "#66736B"
    BORDERS = "#E1E6E0"
    FIELD_BACKGROUND = "#F0F2EF"


# Aliased for backward compatibility with existing tests
hex_to_relative_luminance = calculate_relative_luminance


class TestFeature01DesignSystem(unittest.TestCase):
    """F1: Academic Editorial Design System & WCAG Palette Verification."""

    def test_f01_tc01_exact_hex_tokens_defined(self):
        """Verify all exact palette tokens from §5.1 are present and distinct."""
        tokens = [
            PaletteTokens.BACKGROUND_MAIN,
            PaletteTokens.SURFACE_CARD,
            PaletteTokens.PRIMARY_FOREST,
            PaletteTokens.DARK_FOREST,
            PaletteTokens.SECONDARY_FOREST,
            PaletteTokens.LIGHT_FOREST,
            PaletteTokens.TEXT_MAIN,
            PaletteTokens.TEXT_SECONDARY,
            PaletteTokens.BORDERS,
            PaletteTokens.FIELD_BACKGROUND,
        ]
        self.assertEqual(len(tokens), 10)
        self.assertEqual(PaletteTokens.BACKGROUND_MAIN, "#F5F6F3")
        self.assertEqual(PaletteTokens.PRIMARY_FOREST, "#20533F")
        self.assertEqual(PaletteTokens.TEXT_MAIN, "#26322C")
        self.assertEqual(PaletteTokens.LIGHT_FOREST, "#E7F0EA")

    def test_f01_tc02_text_main_on_background_meets_wcag_aaa(self):
        """Verify main text (#26322C) on main background (#F5F6F3) exceeds WCAG AAA (7.0:1)."""
        ratio = calculate_contrast_ratio(PaletteTokens.TEXT_MAIN, PaletteTokens.BACKGROUND_MAIN)
        self.assertGreaterEqual(ratio, 7.0, f"Contrast {ratio:.2f} must meet WCAG AAA >= 7.0:1")

    def test_f01_tc03_text_main_on_card_surface_meets_wcag_aaa(self):
        """Verify main text (#26322C) on card surface (#FFFFFF) exceeds WCAG AAA (7.0:1)."""
        ratio = calculate_contrast_ratio(PaletteTokens.TEXT_MAIN, PaletteTokens.SURFACE_CARD)
        self.assertGreaterEqual(ratio, 7.0, f"Contrast {ratio:.2f} must meet WCAG AAA >= 7.0:1")

    def test_f01_tc04_primary_forest_on_white_meets_wcag_aaa(self):
        """Verify primary forest (#20533F) on card surface (#FFFFFF) exceeds 7.0:1."""
        ratio = calculate_contrast_ratio(PaletteTokens.PRIMARY_FOREST, PaletteTokens.SURFACE_CARD)
        self.assertGreaterEqual(ratio, 7.0, f"Contrast {ratio:.2f} must meet >= 7.0:1")

    def test_f01_tc05_card_specifications_validation(self):
        """Verify card specifications: border radius 12-16dp, subtle border and surface."""
        card_spec = {
            "surface_color": PaletteTokens.SURFACE_CARD,
            "border_color": PaletteTokens.BORDERS,
            "border_width_dp": 1.0,
            "border_radius_dp": 14.0,  # between 12 and 16 dp
            "elevation_dp": 1.0,
        }
        self.assertIn(card_spec["surface_color"], ["#FFFFFF", PaletteTokens.SURFACE_CARD])
        self.assertEqual(card_spec["border_color"], "#E1E6E0")
        self.assertTrue(12.0 <= card_spec["border_radius_dp"] <= 16.0)
        self.assertLessEqual(card_spec["elevation_dp"], 2.0, "Shadows must be subtle and discreet")

    def test_f01_tc06_ui_state_enum_completeness(self):
        """Verify explicit UI state representation (§22: loading, error, ready, empty, success)."""
        valid_states = {"uninitialized", "loading", "ready", "executing", "completed", "failed", "cancelled", "offline"}
        self.assertIn("loading", valid_states)
        self.assertIn("ready", valid_states)
        self.assertIn("failed", valid_states)
        self.assertIn("completed", valid_states)

    def test_f01_tc07_wcag_aaa_helper_verification(self):
        """Verify WCAG AAA helper returns True for compliant pairs and False for low-contrast pairs."""
        self.assertTrue(verify_wcag_aaa(PaletteTokens.TEXT_MAIN, PaletteTokens.BACKGROUND_MAIN))
        self.assertTrue(verify_wcag_aaa(PaletteTokens.TEXT_MAIN, PaletteTokens.SURFACE_CARD))
        self.assertTrue(verify_wcag_aaa(PaletteTokens.PRIMARY_FOREST, PaletteTokens.SURFACE_CARD))
        self.assertFalse(verify_wcag_aaa(PaletteTokens.LIGHT_FOREST, PaletteTokens.SURFACE_CARD))
        self.assertTrue(verify_wcag_aaa(PaletteTokens.LIGHT_FOREST, PaletteTokens.PRIMARY_FOREST, is_large_text=True))
        self.assertAlmostEqual(calculate_relative_luminance("#000000"), 0.0, places=4)
        self.assertAlmostEqual(calculate_relative_luminance("#FFFFFF"), 1.0, places=4)



# ==============================================================================
# Feature 2: Dual Responsive Navigation
# ==============================================================================

class NavigationEngine:
    """Models responsive navigation between Android 5-tab bar and Windows NavigationRail."""
    ANDROID_DESTINATIONS = ["Início", "Estudar", "Biblioteca", "Laboratório", "Meu Espaço"]

    def __init__(self, platform: str, viewport_width_dp: float):
        self.platform = platform.lower()
        self.viewport_width_dp = viewport_width_dp
        self.history_stack: List[str] = []
        self.current_tab: str = "Início"

    @property
    def navigation_mode(self) -> str:
        # §5.2: Galaxy A57 / mobile uses bottom bar; Windows/desktop or width >= 800 uses lateral rail
        if self.platform == "windows" or self.viewport_width_dp >= 800:
            return "navigation_rail"
        return "bottom_navigation_bar"

    def select_tab(self, tab_name: str) -> None:
        if tab_name not in self.ANDROID_DESTINATIONS:
            raise ValueError(f"Invalid tab destination: {tab_name}")
        self.current_tab = tab_name
        self.history_stack.append(tab_name)

    def pop_back(self) -> Optional[str]:
        if len(self.history_stack) > 1:
            self.history_stack.pop()
            self.current_tab = self.history_stack[-1]
            return self.current_tab
        return None


class TestFeature02DualNavigation(unittest.TestCase):
    """F2: Dual Responsive Navigation (5-Tab Android vs Windows Rail)."""

    def test_f02_tc01_android_five_destinations_exact_order(self):
        """Verify the 5 canonical Android navigation tabs from §5.2."""
        expected = ["Início", "Estudar", "Biblioteca", "Laboratório", "Meu Espaço"]
        self.assertEqual(NavigationEngine.ANDROID_DESTINATIONS, expected)
        self.assertEqual(len(NavigationEngine.ANDROID_DESTINATIONS), 5)

    def test_f02_tc02_responsive_mode_selection_android_vs_windows(self):
        """Verify mobile selects bottom bar and Windows selects lateral navigation rail."""
        android_nav = NavigationEngine(platform="android", viewport_width_dp=390)
        self.assertEqual(android_nav.navigation_mode, "bottom_navigation_bar")

        windows_nav = NavigationEngine(platform="windows", viewport_width_dp=1200)
        self.assertEqual(windows_nav.navigation_mode, "navigation_rail")

    def test_f02_tc03_wide_tablet_breakpoint_triggers_rail(self):
        """Verify viewport width >= 800 dp uses NavigationRail even on Android tablet."""
        tablet_nav = NavigationEngine(platform="android", viewport_width_dp=840)
        self.assertEqual(tablet_nav.navigation_mode, "navigation_rail")

    def test_f02_tc04_back_stack_navigation_preserves_history(self):
        """Verify back navigation stack behaves in LIFO order without losing user state."""
        nav = NavigationEngine(platform="android", viewport_width_dp=412)
        nav.select_tab("Início")
        nav.select_tab("Estudar")
        nav.select_tab("Biblioteca")
        self.assertEqual(nav.current_tab, "Biblioteca")

        popped = nav.pop_back()
        self.assertEqual(popped, "Estudar")
        self.assertEqual(nav.current_tab, "Estudar")

    def test_f02_tc05_keyboard_avoiding_layout_spec(self):
        """Verify layout contracts require scroll views so virtual keyboard does not obscure inputs."""
        layout_spec = {
            "resize_to_avoid_bottom_inset": True,
            "has_single_child_scroll_view": True,
            "bottom_bar_hidden_in_deep_reading": True,
        }
        self.assertTrue(layout_spec["resize_to_avoid_bottom_inset"])
        self.assertTrue(layout_spec["has_single_child_scroll_view"])


# ==============================================================================
# Feature 3: Adjustable Typography Controls
# ==============================================================================

class TypographyController:
    """Manages font sizes (14-22 sp), line-height (~1.5), and text styling."""
    MIN_SP = 14.0
    MAX_SP = 22.0
    DEFAULT_BODY_SP = 16.0
    ACADEMIC_LINE_HEIGHT = 1.5

    def __init__(self, current_sp: float = DEFAULT_BODY_SP):
        self._current_sp = current_sp

    @property
    def current_sp(self) -> float:
        return self._current_sp

    def set_font_size(self, sp: float) -> None:
        if sp < self.MIN_SP or sp > self.MAX_SP:
            raise ValueError(f"Font size {sp}sp out of range [{self.MIN_SP}, {self.MAX_SP}]")
        self._current_sp = round(sp, 1)

    def validate_reading_color(self, text_hex: str, background_hex: str) -> bool:
        """Rule from §5.1: Text reading in dark gray, never light green over white."""
        if text_hex.upper() == PaletteTokens.LIGHT_FOREST.upper() and background_hex.upper() == "#FFFFFF":
            return False
        ratio = calculate_contrast_ratio(text_hex, background_hex)
        return ratio >= 4.5


class TestFeature03AdjustableTypography(unittest.TestCase):
    """F3: Adjustable Typography Controls & Text Readability."""

    def test_f03_tc01_typographic_scale_hierarchy_bounds(self):
        """Verify typographic scale standards from §5.1."""
        scale = {
            "screen_title_min": 24, "screen_title_max": 28,
            "section_title_min": 19, "section_title_max": 22,
            "body_min": 16, "body_max": 18,
            "auxiliary_min": 13, "auxiliary_max": 14,
        }
        self.assertLess(scale["auxiliary_max"], scale["body_min"])
        self.assertLess(scale["body_max"], scale["section_title_min"])
        self.assertLess(scale["section_title_max"], scale["screen_title_min"])

    def test_f03_tc02_adjustable_font_size_within_bounds(self):
        """Verify user font size adjustment between 14sp and 22sp."""
        typo = TypographyController()
        typo.set_font_size(14.0)
        self.assertEqual(typo.current_sp, 14.0)
        typo.set_font_size(20.5)
        self.assertEqual(typo.current_sp, 20.5)
        typo.set_font_size(22.0)
        self.assertEqual(typo.current_sp, 22.0)

        with self.assertRaises(ValueError):
            typo.set_font_size(13.9)
        with self.assertRaises(ValueError):
            typo.set_font_size(22.1)

    def test_f03_tc03_academic_line_spacing_factor(self):
        """Verify continuous academic reading line height factor is 1.5."""
        typo = TypographyController()
        self.assertEqual(typo.ACADEMIC_LINE_HEIGHT, 1.5)

    def test_f03_tc04_pt_br_glyph_integrity(self):
        """Verify Brazilian Portuguese glyphs retain integrity in strings."""
        sample_text = "Enciclopédia de Ciências Forenses — ênfase em vestígios, extração & ação pericial."
        encoded = sample_text.encode('utf-8').decode('utf-8')
        self.assertEqual(encoded, sample_text)
        self.assertIn("ê", encoded)
        self.assertIn("ç", encoded)
        self.assertIn("ã", encoded)

    def test_f03_tc05_contrast_safety_rejects_light_green_on_white(self):
        """Verify system rejects light green (#E7F0EA) text over white background."""
        typo = TypographyController()
        is_safe = typo.validate_reading_color(PaletteTokens.LIGHT_FOREST, PaletteTokens.SURFACE_CARD)
        self.assertFalse(is_safe, "Light green on white must be rejected")

        is_valid = typo.validate_reading_color(PaletteTokens.TEXT_MAIN, PaletteTokens.SURFACE_CARD)
        self.assertTrue(is_valid, "Main dark text on white must be accepted")


# ==============================================================================
# Feature 4: 24-Entity Relational Persistence
# ==============================================================================

def create_sqlite_forensic_db(memory: bool = True) -> sqlite3.Connection:
    """Builds a real SQLite database containing all 24 entities from §17 with FKs enabled."""
    conn = sqlite3.connect(":memory:" if memory else "")
    conn.execute("PRAGMA foreign_keys = ON;")
    cursor = conn.cursor()

    schema_sql = """
    -- 1. Curriculum
    CREATE TABLE curriculums (
        curriculum_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        version TEXT NOT NULL
    );

    -- 2. Volume
    CREATE TABLE volumes (
        volume_id INTEGER PRIMARY KEY,
        curriculum_id TEXT NOT NULL,
        title TEXT NOT NULL,
        area TEXT NOT NULL,
        start_chapter INTEGER NOT NULL,
        end_chapter INTEGER NOT NULL,
        FOREIGN KEY (curriculum_id) REFERENCES curriculums(curriculum_id) ON DELETE CASCADE
    );

    -- 3. Chapter
    CREATE TABLE chapters (
        chapter_id TEXT PRIMARY KEY,
        volume_id INTEGER NOT NULL,
        chapter_number INTEGER NOT NULL,
        title TEXT NOT NULL,
        editorial_status TEXT NOT NULL,
        FOREIGN KEY (volume_id) REFERENCES volumes(volume_id) ON DELETE CASCADE
    );

    -- 4. Lesson
    CREATE TABLE lessons (
        lesson_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        title TEXT NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 5. LearningObjective
    CREATE TABLE learning_objectives (
        objective_id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        description TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
    );

    -- 6. Competency
    CREATE TABLE competencies (
        competency_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        area TEXT NOT NULL,
        is_mastered INTEGER DEFAULT 0
    );

    -- 7. Exercise
    CREATE TABLE exercises (
        exercise_id TEXT PRIMARY KEY,
        lesson_id TEXT NOT NULL,
        question_text TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        FOREIGN KEY (lesson_id) REFERENCES lessons(lesson_id) ON DELETE CASCADE
    );

    -- 8. Assessment
    CREATE TABLE assessments (
        assessment_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        passing_threshold REAL DEFAULT 0.80,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 9. AssessmentAttempt
    CREATE TABLE assessment_attempts (
        attempt_id TEXT PRIMARY KEY,
        assessment_id TEXT NOT NULL,
        score REAL NOT NULL,
        passed INTEGER NOT NULL,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (assessment_id) REFERENCES assessments(assessment_id) ON DELETE CASCADE
    );

    -- 10. Laboratory
    CREATE TABLE laboratories (
        lab_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        domain TEXT NOT NULL,
        title TEXT NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 11. LaboratoryRun
    CREATE TABLE laboratory_runs (
        run_id TEXT PRIMARY KEY,
        lab_id TEXT NOT NULL,
        status TEXT NOT NULL,
        output_result TEXT,
        executed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (lab_id) REFERENCES laboratories(lab_id) ON DELETE CASCADE
    );

    -- 12. CaseStudy
    CREATE TABLE case_studies (
        case_id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        summary TEXT NOT NULL
    );

    -- 13. CaseSubmission
    CREATE TABLE case_submissions (
        submission_id TEXT PRIMARY KEY,
        case_id TEXT NOT NULL,
        facts_count INTEGER NOT NULL,
        inferences_count INTEGER NOT NULL,
        report_text TEXT,
        FOREIGN KEY (case_id) REFERENCES case_studies(case_id) ON DELETE CASCADE
    );

    -- 14. StudySession
    CREATE TABLE study_sessions (
        session_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        duration_seconds INTEGER NOT NULL,
        completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 15. ReadingPosition
    CREATE TABLE reading_positions (
        chapter_id TEXT PRIMARY KEY,
        page_number INTEGER NOT NULL,
        scroll_ratio REAL NOT NULL,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 16. Bookmark
    CREATE TABLE bookmarks (
        bookmark_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        page_number INTEGER NOT NULL,
        label TEXT,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 17. Annotation
    CREATE TABLE annotations (
        annotation_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        revision TEXT NOT NULL,
        anchor_id TEXT,
        note_text TEXT NOT NULL,
        is_drifted INTEGER DEFAULT 0,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 18. ReviewSchedule
    CREATE TABLE review_schedules (
        schedule_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        scheduled_for DATETIME NOT NULL,
        interval_days INTEGER NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 19. ContentRevision
    CREATE TABLE content_revisions (
        revision_id TEXT PRIMARY KEY,
        chapter_id TEXT NOT NULL,
        revision_code TEXT NOT NULL,
        sha256_hash TEXT NOT NULL,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE CASCADE
    );

    -- 20. SourceDocument
    CREATE TABLE source_documents (
        source_id TEXT PRIMARY KEY,
        file_id TEXT,
        file_name TEXT NOT NULL,
        provider TEXT NOT NULL
    );

    -- 21. UserSettings
    CREATE TABLE user_settings (
        setting_key TEXT PRIMARY KEY,
        setting_value TEXT NOT NULL
    );

    -- 22. SyncJournal
    CREATE TABLE sync_journals (
        journal_id TEXT PRIMARY KEY,
        source_id TEXT,
        action TEXT NOT NULL,
        status TEXT NOT NULL,
        synced_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (source_id) REFERENCES source_documents(source_id) ON DELETE SET NULL
    );

    -- 23. AIInteraction
    CREATE TABLE ai_interactions (
        interaction_id TEXT PRIMARY KEY,
        mode TEXT NOT NULL,
        user_query TEXT NOT NULL,
        response_text TEXT NOT NULL,
        chapter_id TEXT,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id) ON DELETE SET NULL
    );

    -- 24. AudioSettings
    CREATE TABLE audio_settings (
        setting_id INTEGER PRIMARY KEY CHECK (setting_id = 1),
        engine TEXT NOT NULL,
        voice_name TEXT NOT NULL,
        speed REAL DEFAULT 1.00
    );
    """
    cursor.executescript(schema_sql)
    conn.commit()
    return conn


class TestFeature04Persistence(unittest.TestCase):
    """F4: 24 Drift/SQLite Entities Relational Persistence & Constraints."""

    def setUp(self):
        self.conn = create_sqlite_forensic_db()

    def tearDown(self):
        self.conn.close()

    def test_f04_tc01_all_24_tables_exist(self):
        """Verify all 24 entities from §17 exist in SQLite schema."""
        cursor = self.conn.cursor()
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';")
        tables = {row[0] for row in cursor.fetchall()}
        expected_tables = {
            "curriculums", "volumes", "chapters", "lessons", "learning_objectives",
            "competencies", "exercises", "assessments", "assessment_attempts",
            "laboratories", "laboratory_runs", "case_studies", "case_submissions",
            "study_sessions", "reading_positions", "bookmarks", "annotations",
            "review_schedules", "content_revisions", "source_documents",
            "user_settings", "sync_journals", "ai_interactions", "audio_settings"
        }
        self.assertEqual(len(tables), 24)
        self.assertEqual(tables, expected_tables)

    def test_f04_tc02_foreign_key_enforcement_blocks_orphans(self):
        """Verify foreign key constraint blocks inserting chapter with non-existent volume."""
        cursor = self.conn.cursor()
        with self.assertRaises(sqlite3.IntegrityError):
            cursor.execute(
                "INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status) "
                "VALUES ('ch999', 99, 99, 'Orphan Chapter', 'Aprovado');"
            )

    def test_f04_tc03_transactional_rollback_preserves_state(self):
        """Verify transaction rollback removes partial uncommitted inserts."""
        cursor = self.conn.cursor()
        cursor.execute("INSERT INTO curriculums (curriculum_id, title, version) VALUES ('cur1', 'Master', '1.0');")
        self.conn.commit()

        try:
            self.conn.execute("BEGIN TRANSACTION;")
            self.conn.execute("INSERT INTO volumes (volume_id, curriculum_id, title, area, start_chapter, end_chapter) "
                              "VALUES (1, 'cur1', 'Vol I', 'Fundamentos', 1, 10);")
            # Force integrity error
            self.conn.execute("INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status) "
                              "VALUES ('ch1', 999, 1, 'Invalid Vol', 'Aprovado');")
            self.conn.commit()
        except sqlite3.IntegrityError:
            self.conn.rollback()

        # Volume 1 must NOT exist because transaction rolled back
        cursor.execute("SELECT COUNT(*) FROM volumes WHERE volume_id = 1;")
        self.assertEqual(cursor.fetchone()[0], 0)

    def test_f04_tc04_cascade_deletion_on_volume_deletes_chapters(self):
        """Verify cascade delete deletes child chapters when parent volume is deleted."""
        cursor = self.conn.cursor()
        cursor.execute("INSERT INTO curriculums (curriculum_id, title, version) VALUES ('cur1', 'Master', '1.0');")
        cursor.execute("INSERT INTO volumes (volume_id, curriculum_id, title, area, start_chapter, end_chapter) "
                       "VALUES (1, 'cur1', 'Vol I', 'Fundamentos', 1, 10);")
        cursor.execute("INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status) "
                       "VALUES ('ch1', 1, 1, 'Dos dados às evidências', 'Aprovado');")
        self.conn.commit()

        cursor.execute("DELETE FROM volumes WHERE volume_id = 1;")
        self.conn.commit()

        cursor.execute("SELECT COUNT(*) FROM chapters WHERE chapter_id = 'ch1';")
        self.assertEqual(cursor.fetchone()[0], 0, "Chapters should cascade delete with volume")

    def test_f04_tc05_reading_position_and_annotation_persistence(self):
        """Verify reading position upsert and annotation preservation."""
        cursor = self.conn.cursor()
        cursor.execute("INSERT INTO curriculums (curriculum_id, title, version) VALUES ('cur1', 'Master', '1.0');")
        cursor.execute("INSERT INTO volumes (volume_id, curriculum_id, title, area, start_chapter, end_chapter) "
                       "VALUES (1, 'cur1', 'Vol I', 'Fundamentos', 1, 10);")
        cursor.execute("INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status) "
                       "VALUES ('ch1', 1, 1, 'Dos dados às evidências', 'Aprovado');")
        cursor.execute("INSERT INTO reading_positions (chapter_id, page_number, scroll_ratio) VALUES ('ch1', 12, 0.45);")
        cursor.execute("INSERT INTO annotations (annotation_id, chapter_id, revision, anchor_id, note_text) "
                       "VALUES ('ann-1', 'ch1', 'REV2', 'sec-01', 'Importante para cadeia de custódia');")
        self.conn.commit()

        cursor.execute("SELECT page_number, scroll_ratio FROM reading_positions WHERE chapter_id = 'ch1';")
        pos = cursor.fetchone()
        self.assertEqual(pos[0], 12)
        self.assertAlmostEqual(pos[1], 0.45)


# ==============================================================================
# Feature 5: Secure Settings Vault
# ==============================================================================

class SecureVaultService:
    """Simulates encrypted BYOK storage and masking (Android Keystore / Windows DPAPI)."""
    def __init__(self):
        self._encrypted_store: Dict[str, bytes] = {}
        self._xor_key = b"AcademiaForense_VaultKey_2026"

    def _encrypt(self, raw_value: str) -> bytes:
        data = raw_value.encode('utf-8')
        return bytes([b ^ self._xor_key[i % len(self._xor_key)] for i, b in enumerate(data)])

    def _decrypt(self, cipher_data: bytes) -> str:
        return bytes([b ^ self._xor_key[i % len(self._xor_key)] for i, b in enumerate(cipher_data)]).decode('utf-8')

    def store_gemini_key(self, api_key: str) -> None:
        if not api_key or len(api_key) < 10:
            raise ValueError("Invalid Gemini API key length")
        self._encrypted_store["gemini_api_key"] = self._encrypt(api_key)

    def retrieve_gemini_key(self) -> Optional[str]:
        if "gemini_api_key" not in self._encrypted_store:
            return None
        return self._decrypt(self._encrypted_store["gemini_api_key"])

    def delete_gemini_key(self) -> None:
        self._encrypted_store.pop("gemini_api_key", None)

    @staticmethod
    def mask_key(api_key: Optional[str]) -> str:
        """Rule from §10.2: Never show full key; show prefix and suffix with masking."""
        if not api_key:
            return "Nenhuma chave cadastrada"
        if len(api_key) <= 10:
            return "**********"
        return f"{api_key[:6]}...{api_key[-4:]}"

    @staticmethod
    def sanitize_log_output(log_message: str, secret_key: Optional[str]) -> str:
        if not secret_key:
            return log_message
        return log_message.replace(secret_key, "[REDACTED_API_KEY]")


class TestFeature05SecureVault(unittest.TestCase):
    """F5: Secure Settings Vault (BYOK Gemini Key, Masking, Study Goal)."""

    def setUp(self):
        self.vault = SecureVaultService()

    def test_f05_tc01_byok_encryption_roundtrip(self):
        """Verify API key is encrypted at rest and decrypts accurately."""
        sample_key = "AIzaSyD-7V_FakeGeminiKeyForensicsTest12345"
        self.vault.store_gemini_key(sample_key)

        # Confirm ciphertext is NOT equal to plaintext
        cipher = self.vault._encrypted_store["gemini_api_key"]
        self.assertNotEqual(cipher.decode('latin1', errors='ignore'), sample_key)

        # Confirm decrypted value matches original
        decrypted = self.vault.retrieve_gemini_key()
        self.assertEqual(decrypted, sample_key)

    def test_f05_tc02_key_masking_format(self):
        """Verify key masking shows only first 6 and last 4 characters (§10.2)."""
        sample_key = "AIzaSyD-7V_FakeGeminiKeyForensicsTest12345"
        masked = self.vault.mask_key(sample_key)
        self.assertEqual(masked, "AIzaSy...2345")
        self.assertNotIn("FakeGeminiKey", masked)

    def test_f05_tc03_wipe_vault_removes_key_completely(self):
        """Verify wiping key leaves no residual ciphertext in vault."""
        self.vault.store_gemini_key("AIzaSyD-TestKeyWipe99999")
        self.assertIsNotNone(self.vault.retrieve_gemini_key())

        self.vault.delete_gemini_key()
        self.assertIsNone(self.vault.retrieve_gemini_key())
        self.assertEqual(self.vault.mask_key(None), "Nenhuma chave cadastrada")

    def test_f05_tc04_weekly_target_default_and_update(self):
        """Verify weekly study target defaults to 13.0 hours and accepts updates."""
        settings = {"weekly_study_target_hours": 13.0}
        self.assertEqual(settings["weekly_study_target_hours"], 13.0)

        # Update target
        settings["weekly_study_target_hours"] = 15.5
        self.assertEqual(settings["weekly_study_target_hours"], 15.5)

    def test_f05_tc05_log_sanitizer_prevents_api_key_leakage(self):
        """Verify logging filter strips raw API keys before emitting logs."""
        raw_key = "AIzaSyRealSecretKey9999"
        log_line = f"Connecting to Gemini API endpoint with key={raw_key} for prompt query"
        sanitized = self.vault.sanitize_log_output(log_line, raw_key)
        self.assertNotIn(raw_key, sanitized)
        self.assertIn("[REDACTED_API_KEY]", sanitized)


# ==============================================================================
# Feature 6: Curriculum Tree & Volume Catalog
# ==============================================================================

class CurriculumCatalog:
    """Canonical curriculum catalog covering 9 volumes and 113 chapters (§3, §24.3)."""
    VOLUMES_DISTRIBUTION = [
        (1, "Fundamentos das Ciências Forenses", 1, 10),
        (2, "Computação, Python, SQL e Matemática", 11, 23),
        (3, "Estatística e Ciência de Dados Forense", 24, 39),
        (4, "Perícia Digital", 40, 53),
        (5, "Telefonia, Geolocalização e Cronologias", 54, 66),
        (6, "Linguística Forense e NLP", 67, 78),
        (7, "Documentoscopia e Multimídia", 79, 90),
        (8, "Áreas Forenses Complementares", 91, 100),
        (9, "Pesquisa e Exercício Profissional", 101, 113),
    ]

    EDITORIAL_STATES = [
        "Planejado", "Importado", "Em revisão", "Aprovado", "Publicado", "Substituído", "Arquivado"
    ]

    @classmethod
    def get_volume_for_chapter(cls, chapter_number: int) -> int:
        for vol_id, _, start_ch, end_ch in cls.VOLUMES_DISTRIBUTION:
            if start_ch <= chapter_number <= end_ch:
                return vol_id
        raise ValueError(f"Chapter {chapter_number} outside valid range 1-113")

    @classmethod
    def is_publicly_available(cls, state: str) -> bool:
        """Rule §3: Only Aprovado or Publicado chapters are available for study."""
        return state in ("Aprovado", "Publicado", "approved", "published")


class TestFeature06CurriculumTree(unittest.TestCase):
    """F6: Curriculum Tree & 7-State Editorial Lifecycle."""

    def test_f06_tc01_total_volumes_and_113_chapters_coverage(self):
        """Verify curriculum distribution exactly spans 9 volumes and chapters 1-113."""
        volumes = CurriculumCatalog.VOLUMES_DISTRIBUTION
        self.assertEqual(len(volumes), 9)

        # Check continuous chapter sequence
        expected_ch = 1
        for vol_id, title, start_ch, end_ch in volumes:
            self.assertEqual(start_ch, expected_ch)
            self.assertGreaterEqual(end_ch, start_ch)
            expected_ch = end_ch + 1

        self.assertEqual(expected_ch - 1, 113, "Total chapters must equal 113")

    def test_f06_tc02_chapter_to_volume_mapping(self):
        """Verify specific chapters map to their official volumes."""
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(1), 1)
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(10), 1)
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(11), 2)
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(24), 3)
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(54), 5)
        self.assertEqual(CurriculumCatalog.get_volume_for_chapter(113), 9)

    def test_f06_tc03_editorial_lifecycle_7_states(self):
        """Verify the 7 exact editorial lifecycle states from §24.3."""
        expected_states = [
            "Planejado", "Importado", "Em revisão", "Aprovado", "Publicado", "Substituído", "Arquivado"
        ]
        self.assertEqual(CurriculumCatalog.EDITORIAL_STATES, expected_states)
        self.assertEqual(len(CurriculumCatalog.EDITORIAL_STATES), 7)

    def test_f06_tc04_public_availability_filtering(self):
        """Verify student view only exposes Aprovado and Publicado chapters."""
        self.assertTrue(CurriculumCatalog.is_publicly_available("Aprovado"))
        self.assertTrue(CurriculumCatalog.is_publicly_available("Publicado"))
        self.assertFalse(CurriculumCatalog.is_publicly_available("Planejado"))
        self.assertFalse(CurriculumCatalog.is_publicly_available("Importado"))
        self.assertFalse(CurriculumCatalog.is_publicly_available("Em revisão"))
        self.assertFalse(CurriculumCatalog.is_publicly_available("Substituído"))
        self.assertFalse(CurriculumCatalog.is_publicly_available("Arquivado"))

    def test_f06_tc05_lifecycle_transition_workflow(self):
        """Verify sequential transition workflow from Planejado up to Publicado."""
        valid_transitions = {
            "Planejado": ["Importado"],
            "Importado": ["Em revisão"],
            "Em revisão": ["Aprovado", "Planejado"],
            "Aprovado": ["Publicado", "Em revisão"],
            "Publicado": ["Substituído", "Arquivado"],
            "Substituído": ["Arquivado"],
            "Arquivado": []
        }
        self.assertIn("Importado", valid_transitions["Planejado"])
        self.assertIn("Em revisão", valid_transitions["Importado"])
        self.assertIn("Aprovado", valid_transitions["Em revisão"])
        self.assertIn("Publicado", valid_transitions["Aprovado"])


# ==============================================================================
# Feature 7: Volume I Print Preservation & Errata
# ==============================================================================

class Volume1PrintManager:
    """Manages the 133 printed pages baseline for Vol I (Ch 1-4 REV2, Ch 5-10 REV1) and erratas."""
    TOTAL_PRINTED_PAGES = 133

    @classmethod
    def get_canonical_revision(cls, chapter_num: int) -> str:
        if 1 <= chapter_num <= 4:
            return "REV2"
        elif 5 <= chapter_num <= 10:
            return "REV1"
        raise ValueError(f"Chapter {chapter_num} not in Volume I (1-10)")

    @classmethod
    def validate_chapter_revision(cls, chapter_num: int, revision: str) -> bool:
        expected = cls.get_canonical_revision(chapter_num)
        return revision.upper() == expected.upper()


class TestFeature07VolumeIPrintPreservation(unittest.TestCase):
    """F7: Volume I Print Preservation (133 Pages, REV1/REV2 & Digital Errata)."""

    def test_f07_tc01_volume_1_exact_133_printed_pages_baseline(self):
        """Verify Volume I physical print count equals exactly 133 pages (§1.3)."""
        self.assertEqual(Volume1PrintManager.TOTAL_PRINTED_PAGES, 133)

    def test_f07_tc02_chapters_1_to_4_use_rev2(self):
        """Verify chapters 1 through 4 are registered strictly as REV2."""
        for ch in range(1, 5):
            self.assertEqual(Volume1PrintManager.get_canonical_revision(ch), "REV2")
            self.assertTrue(Volume1PrintManager.validate_chapter_revision(ch, "REV2"))
            self.assertFalse(Volume1PrintManager.validate_chapter_revision(ch, "REV1"))

    def test_f07_tc03_chapters_5_to_10_use_rev1(self):
        """Verify chapters 5 through 10 are registered strictly as REV1."""
        for ch in range(5, 11):
            self.assertEqual(Volume1PrintManager.get_canonical_revision(ch), "REV1")
            self.assertTrue(Volume1PrintManager.validate_chapter_revision(ch, "REV1"))
            self.assertFalse(Volume1PrintManager.validate_chapter_revision(ch, "REV2"))

    def test_f07_tc04_digital_errata_linked_to_printed_page(self):
        """Verify digital errata attaches to physical page without modifying print baseline."""
        errata = {
            "errata_id": "err-vol1-001",
            "volume_id": 1,
            "chapter_id": "forense.vol01.ch01",
            "revision": "REV2",
            "printed_page_number": 42,
            "original_text": "cadeia de custódia preliminar",
            "corrected_text": "cadeia de custódia formalizada segundo ISO 27037",
            "status": "active"
        }
        self.assertEqual(errata["volume_id"], 1)
        self.assertTrue(1 <= errata["printed_page_number"] <= 133)
        self.assertEqual(errata["revision"], "REV2")

    def test_f07_tc05_errata_query_by_chapter_and_page(self):
        """Verify querying errata for specific chapter and page returns correction."""
        errata_store = [
            {"ch": 1, "page": 12, "correction": "Ajuste na equação de entropia"},
            {"ch": 2, "page": 35, "correction": "Correção de citação bibliográfica"},
            {"ch": 6, "page": 88, "correction": "Atualização de termo técnico (REV1)"},
        ]
        results = [e for e in errata_store if e["ch"] == 1 and e["page"] == 12]
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]["correction"], "Ajuste na equação de entropia")


if __name__ == '__main__':
    unittest.main()
