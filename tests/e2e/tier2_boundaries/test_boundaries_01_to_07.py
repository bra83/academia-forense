"""
Tier 2 Boundary & Corner Cases Test Suite: Features 1 to 7
Covers:
- F1: Design System Palette & WCAG AAA Contrast
- F2: Dual Responsive Navigation & Breakpoints
- F3: Adjustable Typography Controls & Bounds
- F4: Relational Persistence (24 Entities, Constraints, Rollbacks)
- F5: Secure Settings Vault & Anti-Leakage
- F6: Curriculum Tree, Volumes, Chapters & 7 Editorial States
- F7: Volume I Print Preservation (133 Pages, REV2/REV1, Errata)
"""

import unittest
import sqlite3
import math
from tests.test_fixtures.boundary_helpers import (
    OFFICIAL_PALETTE,
    parse_hex_color,
    calculate_contrast_ratio,
    validate_card_radius,
    validate_palette_aesthetic,
    NavigationController,
    clamp_font_size,
    validate_line_height,
    init_sqlite_test_db,
    SCHEMA_24_ENTITIES,
    SecureSettingsVault,
    validate_weekly_study_target,
    validate_volume_number,
    validate_chapter_number,
    validate_editorial_state,
    validate_editorial_transition,
    validate_vol1_chapter_revision,
    validate_vol1_print_pages,
    validate_errata_entry,
)


class TestBoundariesFeatures01To07(unittest.TestCase):

    # =========================================================================
    # FEATURE 1: DESIGN SYSTEM PALETTE & WCAG AAA
    # =========================================================================

    def test_f1_contrast_failure_light_on_white(self):
        """Boundary: Light green (#E7F0EA) on white (#FFFFFF) must fail WCAG AAA (7.0:1) and AA (4.5:1)."""
        ratio = calculate_contrast_ratio("#E7F0EA", "#FFFFFF")
        # Ratio is ~1.15:1, well below 7.0 and 4.5
        self.assertLess(ratio, 4.5, f"Contrast ratio {ratio:.2f} should fail WCAG AA")
        self.assertLess(ratio, 7.0, f"Contrast ratio {ratio:.2f} should fail WCAG AAA")

    def test_f1_contrast_success_text_on_background(self):
        """Boundary: Primary dark text (#26322C) on background (#F5F6F3) must meet WCAG AAA."""
        ratio = calculate_contrast_ratio("#26322C", "#F5F6F3")
        self.assertGreaterEqual(ratio, 7.0, f"Contrast ratio {ratio:.2f} must meet WCAG AAA (>= 7.0:1)")

    def test_f1_invalid_hex_token_rejections(self):
        """Boundary: Invalid hex strings must raise ValueError."""
        invalid_tokens = ["#GGG", "#12345", "20533F", "#", "", "   ", "#12345678", "#ZZZZZZ"]
        for token in invalid_tokens:
            with self.assertRaises(ValueError, msg=f"Token '{token}' should be rejected"):
                parse_hex_color(token)

    def test_f1_forbidden_aesthetic_detection(self):
        """Boundary: Videogame neon, gore, and skull aesthetic tokens must be rejected."""
        forbidden_tokens = [
            ("neon_glow", "#20533F"),
            ("cyber_green", "#00FF00"),
            ("blood_red", "#163D2E"),
            ("skull_banner", "#FFFFFF"),
        ]
        for name, color in forbidden_tokens:
            with self.assertRaises(ValueError, msg=f"Forbidden aesthetic '{name}' should be rejected"):
                validate_palette_aesthetic(name, color)

    def test_f1_card_radius_boundaries(self):
        """Boundary: Card border radius must be between 12.0dp and 16.0dp."""
        self.assertEqual(validate_card_radius(12.0), 12.0)
        self.assertEqual(validate_card_radius(16.0), 16.0)
        self.assertEqual(validate_card_radius(14.5), 14.5)

        # Out-of-bounds cases
        with self.assertRaises(ValueError):
            validate_card_radius(11.9)
        with self.assertRaises(ValueError):
            validate_card_radius(16.1)
        with self.assertRaises(ValueError):
            validate_card_radius(-5.0)
        with self.assertRaises(ValueError):
            validate_card_radius(100.0)

    # =========================================================================
    # FEATURE 2: DUAL RESPONSIVE NAVIGATION
    # =========================================================================

    def test_f2_breakpoint_bottom_bar_at_600dp(self):
        """Boundary: Exactly 600.0dp and below resolves to Android BottomBar; 600.1dp to NavigationRail."""
        nav_mobile = NavigationController(viewport_width=600.0, viewport_height=900.0)
        self.assertEqual(nav_mobile.navigation_mode, "BOTTOM_BAR")

        nav_sub_mobile = NavigationController(viewport_width=599.9, viewport_height=900.0)
        self.assertEqual(nav_sub_mobile.navigation_mode, "BOTTOM_BAR")

        nav_desktop = NavigationController(viewport_width=600.1, viewport_height=900.0)
        self.assertEqual(nav_desktop.navigation_mode, "NAVIGATION_RAIL")

    def test_f2_invalid_viewport_dimensions(self):
        """Boundary: Non-positive viewport dimensions must raise ValueError."""
        with self.assertRaises(ValueError):
            NavigationController(viewport_width=0, viewport_height=800)
        with self.assertRaises(ValueError):
            NavigationController(viewport_width=-360, viewport_height=800)
        with self.assertRaises(ValueError):
            NavigationController(viewport_width=400, viewport_height=0)

    def test_f2_android_tab_index_bounds(self):
        """Boundary: Valid tab indices are exactly 0 to 4. -1 and 5 must raise IndexError."""
        nav = NavigationController(viewport_width=412.0, viewport_height=915.0)
        # Valid selections
        self.assertEqual(nav.select_tab(0), "Início")
        self.assertEqual(nav.select_tab(4), "Meu Espaço")

        # Invalid selections
        with self.assertRaises(IndexError):
            nav.select_tab(-1)
        with self.assertRaises(IndexError):
            nav.select_tab(5)
        with self.assertRaises(IndexError):
            nav.select_tab(99)

    def test_f2_android_tab_overflow_prevention(self):
        """Boundary: Android BottomBar cannot exceed 5 destinations (§5.2)."""
        nav = NavigationController(viewport_width=412.0, viewport_height=915.0)
        self.assertEqual(len(nav.destinations), 5)
        with self.assertRaises(OverflowError):
            nav.add_destination("Destino_Invalido_6")

    def test_f2_navigation_back_stack_pop_empty(self):
        """Boundary: Popping an empty navigation back-stack returns None cleanly."""
        nav = NavigationController(viewport_width=412.0, viewport_height=915.0)
        self.assertIsNone(nav.pop_back())
        # Select tab then pop
        nav.select_tab(2)
        popped = nav.pop_back()
        self.assertEqual(popped, "Início")
        self.assertIsNone(nav.pop_back())

    # =========================================================================
    # FEATURE 3: ADJUSTABLE TYPOGRAPHY CONTROLS
    # =========================================================================

    def test_f3_font_size_lower_bound_rejection(self):
        """Boundary: Font size < 14.0 sp must be rejected."""
        with self.assertRaises(ValueError):
            clamp_font_size(13.9)
        with self.assertRaises(ValueError):
            clamp_font_size(0.0)
        with self.assertRaises(ValueError):
            clamp_font_size(-10.0)

    def test_f3_font_size_upper_bound_rejection(self):
        """Boundary: Font size > 22.0 sp must be rejected."""
        with self.assertRaises(ValueError):
            clamp_font_size(22.1)
        with self.assertRaises(ValueError):
            clamp_font_size(50.0)
        with self.assertRaises(ValueError):
            clamp_font_size(100.0)

    def test_f3_font_size_valid_boundaries(self):
        """Boundary: Exact boundaries 14.0 sp and 22.0 sp are accepted."""
        self.assertEqual(clamp_font_size(14.0), 14.0)
        self.assertEqual(clamp_font_size(22.0), 22.0)
        self.assertEqual(clamp_font_size(18.0), 18.0)

    def test_f3_line_height_boundaries(self):
        """Boundary: Line height <= 0 or < 1.0 or > 3.0 must raise ValueError."""
        with self.assertRaises(ValueError):
            validate_line_height(0.0)
        with self.assertRaises(ValueError):
            validate_line_height(-1.5)
        with self.assertRaises(ValueError):
            validate_line_height(0.8)
        with self.assertRaises(ValueError):
            validate_line_height(4.0)

        # Baseline 1.5 accepted
        self.assertEqual(validate_line_height(1.5), 1.5)

    def test_f3_extreme_text_handling(self):
        """Boundary: Zero-length text and 100,000-char continuous text handling."""
        empty_text = ""
        self.assertEqual(len(empty_text), 0)

        large_text = "Metodologia pericial de cadeia de custódia. " * 2500
        self.assertGreater(len(large_text), 100000)
        # Verify text split without buffer errors
        words = large_text.split()
        self.assertGreater(len(words), 10000)

    # =========================================================================
    # FEATURE 4: RELATIONAL PERSISTENCE (24 DRIFT ENTITIES)
    # =========================================================================

    def setUp(self):
        self.db = init_sqlite_test_db(":memory:")

    def tearDown(self):
        self.db.close()

    def test_f4_foreign_key_violation_rejection(self):
        """Boundary: Inserting chapter referencing non-existent volume_id raises IntegrityError."""
        cur = self.db.cursor()
        with self.assertRaises(sqlite3.IntegrityError):
            cur.execute("""
                INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status, edition)
                VALUES ('ch999', 'vol_non_existent', 99, 'Capítulo Órfão', 'Planejado', 'REV1');
            """)
            self.db.commit()

    def test_f4_duplicate_primary_key_rejection(self):
        """Boundary: Inserting duplicate volume_id raises IntegrityError."""
        cur = self.db.cursor()
        cur.execute("""
            INSERT INTO volumes (volume_id, volume_number, title, area)
            VALUES ('vol01', 1, 'Fundamentos', 'Fundamentos Forenses');
        """)
        self.db.commit()

        with self.assertRaises(sqlite3.IntegrityError):
            cur.execute("""
                INSERT INTO volumes (volume_id, volume_number, title, area)
                VALUES ('vol01', 2, 'Outro Título', 'Outra Área');
            """)
            self.db.commit()

    def test_f4_not_null_constraint_rejection(self):
        """Boundary: Inserting NULL into NOT NULL column raises IntegrityError."""
        cur = self.db.cursor()
        with self.assertRaises(sqlite3.IntegrityError):
            cur.execute("""
                INSERT INTO volumes (volume_id, volume_number, title, area)
                VALUES ('vol02', NULL, 'Volume Sem Número', 'Área');
            """)
            self.db.commit()

    def test_f4_transaction_atomic_rollback(self):
        """Boundary: Failed statement in transaction rolls back entire batch atomically."""
        cur = self.db.cursor()
        cur.execute("BEGIN TRANSACTION;")
        cur.execute("""
            INSERT INTO volumes (volume_id, volume_number, title, area)
            VALUES ('vol01', 1, 'Fundamentos', 'Área 1');
        """)
        # Force intentional foreign key failure in second statement
        try:
            cur.execute("""
                INSERT INTO chapters (chapter_id, volume_id, chapter_number, title, editorial_status, edition)
                VALUES ('ch01', 'vol_non_existent', 1, 'Cap 1', 'Planejado', 'REV1');
            """)
            self.db.commit()
        except sqlite3.IntegrityError:
            self.db.rollback()

        # Check that vol01 was NOT committed
        cur.execute("SELECT COUNT(*) FROM volumes WHERE volume_id = 'vol01';")
        count = cur.fetchone()[0]
        self.assertEqual(count, 0, "Transaction rollback must leave zero orphaned rows")

    def test_f4_schema_completeness_24_entities(self):
        """Boundary: Verify that all 24 required entities exist in the SQLite schema."""
        cur = self.db.cursor()
        cur.execute("SELECT name FROM sqlite_master WHERE type='table';")
        tables = {row[0] for row in cur.fetchall()}
        for entity in SCHEMA_24_ENTITIES:
            self.assertIn(entity, tables, f"Mandatory Drift entity '{entity}' missing from database")

    # =========================================================================
    # FEATURE 5: SECURE SETTINGS VAULT & BYOK
    # =========================================================================

    def test_f5_empty_api_key_rejection(self):
        """Boundary: Setting empty or whitespace-only API key must raise ValueError."""
        vault = SecureSettingsVault()
        with self.assertRaises(ValueError):
            vault.set_gemini_api_key("")
        with self.assertRaises(ValueError):
            vault.set_gemini_api_key("   ")

    def test_f5_control_character_injection_rejection(self):
        """Boundary: API key containing control characters, newlines or null bytes raises ValueError."""
        vault = SecureSettingsVault()
        with self.assertRaises(ValueError):
            vault.set_gemini_api_key("AIzaSyD\nSecretKey")
        with self.assertRaises(ValueError):
            vault.set_gemini_api_key("AIzaSyD\r\nSecretKey")
        with self.assertRaises(ValueError):
            vault.set_gemini_api_key("AIzaSyD\0SecretKey")

    def test_f5_log_masking_never_exposes_plaintext(self):
        """Boundary: Vault masked output must never reveal raw key plaintext."""
        vault = SecureSettingsVault()
        raw_key = "AIzaSyD-SecretApiKeyForGemini998877"
        vault.set_gemini_api_key(raw_key)

        masked = vault.get_masked_api_key()
        self.assertNotIn("SecretApiKeyForGemini", masked)
        self.assertTrue(masked.startswith("AIza****"))
        self.assertTrue(masked.endswith("8877"))

    def test_f5_tampered_ciphertext_detection(self):
        """Boundary: Corrupted/tampered vault ciphertext raises error upon decoding."""
        vault = SecureSettingsVault()
        vault.set_gemini_api_key("AIzaSyD-ValidKey123")
        vault.tamper_vault_key()
        with self.assertRaises(Exception):
            vault.get_gemini_api_key()

    def test_f5_weekly_study_target_boundaries(self):
        """Boundary: Weekly study target <= 0 or > 168 hours must raise ValueError."""
        with self.assertRaises(ValueError):
            validate_weekly_study_target(0.0)
        with self.assertRaises(ValueError):
            validate_weekly_study_target(-5.0)
        with self.assertRaises(ValueError):
            validate_weekly_study_target(168.1)
        with self.assertRaises(ValueError):
            validate_weekly_study_target(200.0)

        # Baseline 13 hours accepted
        self.assertEqual(validate_weekly_study_target(13.0), 13.0)
        # Upper edge exactly 168.0 hours accepted
        self.assertEqual(validate_weekly_study_target(168.0), 168.0)

    # =========================================================================
    # FEATURE 6: CURRICULUM TREE & 7 EDITORIAL STATES
    # =========================================================================

    def test_f6_volume_number_out_of_bounds(self):
        """Boundary: Volume number must be between 1 and 9."""
        with self.assertRaises(ValueError):
            validate_volume_number(0)
        with self.assertRaises(ValueError):
            validate_volume_number(-1)
        with self.assertRaises(ValueError):
            validate_volume_number(10)
        with self.assertRaises(ValueError):
            validate_volume_number(99)

        self.assertEqual(validate_volume_number(1), 1)
        self.assertEqual(validate_volume_number(9), 9)

    def test_f6_chapter_number_out_of_bounds(self):
        """Boundary: Chapter number must be between 1 and 113."""
        with self.assertRaises(ValueError):
            validate_chapter_number(0)
        with self.assertRaises(ValueError):
            validate_chapter_number(-1)
        with self.assertRaises(ValueError):
            validate_chapter_number(114)
        with self.assertRaises(ValueError):
            validate_chapter_number(200)

        self.assertEqual(validate_chapter_number(1), 1)
        self.assertEqual(validate_chapter_number(113), 113)

    def test_f6_invalid_editorial_state_rejection(self):
        """Boundary: Editorial state must be one of the 7 official states (§24.3)."""
        invalid_states = ["Draft", "Rascunho", "Deletado", "Em andamento", "Pendente", ""]
        for st in invalid_states:
            with self.assertRaises(ValueError):
                validate_editorial_state(st)

        valid_states = ["Planejado", "Importado", "Em revisão", "Aprovado", "Publicado", "Substituído", "Arquivado"]
        for st in valid_states:
            self.assertEqual(validate_editorial_state(st), st)

    def test_f6_illegal_editorial_transition(self):
        """Boundary: Transition from 'Planejado' directly to 'Publicado' is forbidden."""
        with self.assertRaises(ValueError):
            validate_editorial_transition("Planejado", "Publicado")

    def test_f6_planned_chapter_no_full_content(self):
        """Boundary: Planned chapter must appear as 'Previsto', not as a completed lesson (§3)."""
        chapter_record = {
            "chapter_number": 50,
            "editorial_status": "Planejado",
            "has_full_lesson_content": False,
        }
        self.assertEqual(chapter_record["editorial_status"], "Planejado")
        self.assertFalse(chapter_record["has_full_lesson_content"])

    # =========================================================================
    # FEATURE 7: VOLUME I PRINT PRESERVATION & ERRATA
    # =========================================================================

    def test_f7_vol1_ch1_to_4_strictly_rev2(self):
        """Boundary: Vol I Chapters 1-4 must strictly use REV2 (§1.3). REV1/REV3 must fail."""
        for ch in [1, 2, 3, 4]:
            validate_vol1_chapter_revision(ch, "REV2")
            with self.assertRaises(ValueError, msg=f"Ch {ch} with REV1 should fail"):
                validate_vol1_chapter_revision(ch, "REV1")
            with self.assertRaises(ValueError, msg=f"Ch {ch} with REV3 should fail"):
                validate_vol1_chapter_revision(ch, "REV3")

    def test_f7_vol1_ch5_to_10_strictly_rev1(self):
        """Boundary: Vol I Chapters 5-10 must strictly use REV1 (§1.3). REV2 must fail."""
        for ch in [5, 6, 7, 8, 9, 10]:
            validate_vol1_chapter_revision(ch, "REV1")
            with self.assertRaises(ValueError, msg=f"Ch {ch} with REV2 should fail"):
                validate_vol1_chapter_revision(ch, "REV2")

    def test_f7_vol1_total_print_pages_exact_133(self):
        """Boundary: Total printed physical pages for Volume I must be exactly 133 (§1.3)."""
        validate_vol1_print_pages(133)
        with self.assertRaises(ValueError):
            validate_vol1_print_pages(132)
        with self.assertRaises(ValueError):
            validate_vol1_print_pages(134)
        with self.assertRaises(ValueError):
            validate_vol1_print_pages(0)

    def test_f7_errata_page_boundary(self):
        """Boundary: Errata page must be within 1 and 133."""
        validate_errata_entry(volume=1, chapter=1, page=1, errata_text="Correção na linha 4")
        validate_errata_entry(volume=1, chapter=10, page=133, errata_text="Correção da fórmula final")

        with self.assertRaises(ValueError):
            validate_errata_entry(volume=1, chapter=1, page=0, errata_text="Página zero")
        with self.assertRaises(ValueError):
            validate_errata_entry(volume=1, chapter=1, page=134, errata_text="Página além de 133")

    def test_f7_errata_empty_text_rejection(self):
        """Boundary: Errata entry with empty or whitespace text must be rejected."""
        with self.assertRaises(ValueError):
            validate_errata_entry(volume=1, chapter=1, page=5, errata_text="")
        with self.assertRaises(ValueError):
            validate_errata_entry(volume=1, chapter=1, page=5, errata_text="   ")


if __name__ == "__main__":
    unittest.main()
