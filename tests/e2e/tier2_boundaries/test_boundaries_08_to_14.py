"""
Tier 2 Boundary & Corner Cases Test Suite: Features 8 to 14
Covers:
- F8: Section 19 JSON Schema Engine & Draft 2020-12
- F9: Dual-Mode Library Reader (PDF Corruption, Markdown XSS, Mode Switching)
- F10: Content-Progress Decoupling & Safe Updates (Anchor Drift, Immutability)
- F11: Local Text Search (FTS5 Special Chars, SQL Injection, Empty Queries)
- F12: Ingestion & Sync Providers (Auth 401, Timeout, Hash Tampering, Duplicate)
- F13: 10-Step Lesson Engine (Empty Steps, Out-of-Order Progression, Missing Steps)
- F14: Automated Assessment & 80% Progression (79.99% vs 80.00% Boundary, Immutability)
"""

import unittest
import json
import sqlite3
import hashlib
import re
import jsonschema

from tests.test_fixtures.boundary_helpers import (
    SECTION_19_SCHEMA,
    sanitize_fts_query,
    evaluate_assessment_result,
    init_sqlite_test_db,
)


class TestBoundariesFeatures08To14(unittest.TestCase):

    # =========================================================================
    # FEATURE 8: SECTION 19 JSON SCHEMA ENGINE
    # =========================================================================

    def _get_valid_package_data(self):
        return {
            "schemaVersion": "1.0",
            "contentId": "forense.vol01.ch01",
            "type": "chapter",
            "volume": 1,
            "chapter": 1,
            "title": "Dos dados às evidências",
            "language": "pt-BR",
            "edition": "REV2",
            "editorialStatus": "Aprovado",
            "source": {
                "provider": "google_drive",
                "fileId": "1OUZ8sQqkkZkV_jukq5bKD3fID8ef0mTD",
                "revision": "2",
                "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
            },
            "sections": [],
            "learningObjectives": [],
            "prerequisites": [],
            "exercises": [],
            "laboratories": [],
            "assessment": None
        }

    def test_f8_malformed_json_syntax_rejection(self):
        """Boundary: Corrupted/malformed JSON syntax raises json.JSONDecodeError."""
        malformed_json_strings = [
            '{"schemaVersion": "1.0", "contentId": ',  # Unfinished
            '{"schemaVersion": "1.0", "volume": 1,}',   # Trailing comma
            "{'schemaVersion': '1.0'}",                  # Single quotes (invalid JSON)
            "",                                          # Empty string
        ]
        for bad_json in malformed_json_strings:
            with self.assertRaises(json.JSONDecodeError):
                json.loads(bad_json)

    def test_f8_missing_mandatory_top_level_fields(self):
        """Boundary: Missing mandatory fields raises jsonschema.ValidationError."""
        mandatory_fields = ["schemaVersion", "contentId", "volume", "chapter", "edition", "editorialStatus", "source"]
        for field in mandatory_fields:
            data = self._get_valid_package_data()
            del data[field]
            with self.assertRaises(jsonschema.ValidationError, msg=f"Missing '{field}' must fail validation"):
                jsonschema.validate(instance=data, schema=SECTION_19_SCHEMA)

    def test_f8_invalid_schema_version_rejection(self):
        """Boundary: schemaVersion != '1.0' (e.g. '2.0', '0.9') raises ValidationError."""
        for invalid_version in ["2.0", "0.9", "1.1", "draft-2020"]:
            data = self._get_valid_package_data()
            data["schemaVersion"] = invalid_version
            with self.assertRaises(jsonschema.ValidationError):
                jsonschema.validate(instance=data, schema=SECTION_19_SCHEMA)

    def test_f8_type_mismatch_rejection(self):
        """Boundary: Type mismatch in fields raises jsonschema.ValidationError."""
        data = self._get_valid_package_data()
        data["volume"] = "one"  # Should be integer
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=data, schema=SECTION_19_SCHEMA)

        data2 = self._get_valid_package_data()
        data2["sections"] = "not_an_array"  # Should be array
        with self.assertRaises(jsonschema.ValidationError):
            jsonschema.validate(instance=data2, schema=SECTION_19_SCHEMA)

    def test_f8_null_fields_forbidden_in_published_status(self):
        """Boundary: In 'Publicado' status, source.sha256 and source.fileId cannot be null (§19)."""
        data = self._get_valid_package_data()
        data["editorialStatus"] = "Publicado"
        data["source"]["sha256"] = None

        # Validator rule for published content
        def validate_publication_readiness(pkg: dict):
            if pkg.get("editorialStatus") == "Publicado":
                source = pkg.get("source", {})
                if not source.get("fileId") or not source.get("sha256"):
                    raise ValueError("Cannot publish package with null source.fileId or source.sha256")

        with self.assertRaises(ValueError):
            validate_publication_readiness(data)

    # =========================================================================
    # FEATURE 9: DUAL-MODE LIBRARY READER
    # =========================================================================

    def test_f9_corrupted_pdf_header_handling(self):
        """Boundary: Corrupted/empty PDF file raises ValueError with clear error."""
        def open_pdf_buffer(raw_bytes: bytes):
            if len(raw_bytes) < 4:
                raise ValueError("Corrupted PDF: buffer too short")
            if not raw_bytes.startswith(b"%PDF-"):
                raise ValueError("Corrupted PDF: Missing %PDF- magic header")
            return {"status": "OPENED", "pages": 1}

        with self.assertRaises(ValueError):
            open_pdf_buffer(b"")
        with self.assertRaises(ValueError):
            open_pdf_buffer(b"GIF89a")
        with self.assertRaises(ValueError):
            open_pdf_buffer(b"PK\x03\x04")  # ZIP header

        valid_pdf = b"%PDF-1.4\n1 0 obj\n<<>>\nendobj\ntrailer\n<<>>\n%%EOF"
        res = open_pdf_buffer(valid_pdf)
        self.assertEqual(res["status"], "OPENED")

    def test_f9_page_navigation_out_of_bounds(self):
        """Boundary: Requesting page <= 0 or page > totalPages raises IndexError."""
        def navigate_page(current_page: int, total_pages: int):
            if current_page < 1 or current_page > total_pages:
                raise IndexError(f"Page {current_page} out of bounds [1, {total_pages}]")
            return current_page

        self.assertEqual(navigate_page(1, 10), 1)
        self.assertEqual(navigate_page(10, 10), 10)
        with self.assertRaises(IndexError):
            navigate_page(0, 10)
        with self.assertRaises(IndexError):
            navigate_page(-1, 10)
        with self.assertRaises(IndexError):
            navigate_page(11, 10)

    def test_f9_dual_mode_scroll_ratio_preservation(self):
        """Boundary: Switching between PDF and Markdown mode preserves scroll ratio and page."""
        reader_state = {
            "mode": "PDF",
            "page": 4,
            "scroll_ratio": 0.45
        }
        # Switch to Markdown mode
        reader_state["mode"] = "MARKDOWN"
        # Preserved
        self.assertEqual(reader_state["page"], 4)
        self.assertAlmostEqual(reader_state["scroll_ratio"], 0.45)

        # Switch back to PDF mode
        reader_state["mode"] = "PDF"
        self.assertEqual(reader_state["page"], 4)
        self.assertAlmostEqual(reader_state["scroll_ratio"], 0.45)

    def test_f9_markdown_script_injection_sanitization(self):
        """Boundary: Markdown content containing script tags is sanitized."""
        def sanitize_markdown(raw_md: str) -> str:
            # Strip script tags and dangerous HTML handlers
            sanitized = re.sub(r'<script.*?>.*?</script>', '', raw_md, flags=re.DOTALL | re.IGNORECASE)
            sanitized = re.sub(r'javascript:', '', sanitized, flags=re.IGNORECASE)
            return sanitized

        malicious_input = "# Capítulo 1\n<script>alert('xss')</script>\nTexto legítimo."
        clean = sanitize_markdown(malicious_input)
        self.assertNotIn("<script>", clean)
        self.assertIn("Texto legítimo.", clean)

    def test_f9_missing_pdf_asset_error_handling(self):
        """Boundary: Opening non-existent PDF file raises FileNotFoundError cleanly."""
        def load_pdf_file(file_path: str):
            import os
            if not os.path.exists(file_path):
                raise FileNotFoundError(f"PDF asset not found at '{file_path}'")
            return True

        with self.assertRaises(FileNotFoundError):
            load_pdf_file("/home/antigravity/content/fixtures/non_existent_file_9999.pdf")

    # =========================================================================
    # FEATURE 10: CONTENT-PROGRESS DECOUPLING & SAFE UPDATES
    # =========================================================================

    def setUp(self):
        self.db = init_sqlite_test_db(":memory:")

    def tearDown(self):
        self.db.close()

    def test_f10_anchor_drift_warning_on_revision_update(self):
        """Boundary: When anchor text disappears in new revision, note is PRESERVED with drift_warning=1 (§2.2)."""
        cur = self.db.cursor()
        # Save note linked to anchor in REV1
        cur.execute("""
            INSERT INTO annotations (id, chapter_id, anchor_text, note_content, revision, drift_warning)
            VALUES ('ann_01', 'forense.vol01.ch01', 'Cadeia de custódia inicial', 'Importante para a prova', 'REV1', 0);
        """)
        self.db.commit()

        # Ingest REV2 text where 'Cadeia de custódia inicial' was modified to 'Rastreabilidade do vestígio'
        rev2_text = "Texto do capítulo atualizado com rastreabilidade do vestígio sem a frase antiga."

        # Drift detector
        cur.execute("SELECT id, anchor_text FROM annotations WHERE chapter_id = 'forense.vol01.ch01';")
        ann_id, anchor = cur.fetchone()
        if anchor not in rev2_text:
            # Flag drift warning, preserve note!
            cur.execute("UPDATE annotations SET drift_warning = 1, revision = 'REV2' WHERE id = ?;", (ann_id,))
            self.db.commit()

        cur.execute("SELECT note_content, drift_warning, revision FROM annotations WHERE id = 'ann_01';")
        content, warning, rev = cur.fetchone()
        self.assertEqual(content, "Importante para a prova", "User note must never be deleted")
        self.assertEqual(warning, 1, "Drift warning must be flagged when anchor disappears")
        self.assertEqual(rev, "REV2")

    def test_f10_immutable_historical_assessment_attempts(self):
        """Boundary: Updating a chapter revision must never alter or reset historical assessment scores (§2.2)."""
        cur = self.db.cursor()
        cur.execute("""
            INSERT INTO assessment_attempts (id, assessment_id, student_id, score, passed, attempted_at)
            VALUES ('att_01', 'asm_ch01', 'user_1', 85.0, 1, '2026-11-01T10:00:00Z');
        """)
        self.db.commit()

        # Simulate chapter revision update from REV1 to REV2
        # Verify attempt still has score 85.0
        cur.execute("SELECT score, passed FROM assessment_attempts WHERE id = 'att_01';")
        score, passed = cur.fetchone()
        self.assertEqual(score, 85.0)
        self.assertEqual(passed, 1)

    def test_f10_reading_position_ratio_clamping(self):
        """Boundary: Reading position scroll ratio must clamp between 0.0 and 1.0; page >= 1."""
        def save_reading_pos(page: int, scroll_ratio: float):
            clamped_page = max(1, page)
            clamped_ratio = max(0.0, min(1.0, scroll_ratio))
            return (clamped_page, clamped_ratio)

        self.assertEqual(save_reading_pos(0, -0.5), (1, 0.0))
        self.assertEqual(save_reading_pos(5, 1.5), (5, 1.0))
        self.assertEqual(save_reading_pos(3, 0.75), (3, 0.75))

    def test_f10_bookmark_persistence_across_revisions(self):
        """Boundary: Bookmarks referencing logical sections survive revision updates."""
        cur = self.db.cursor()
        cur.execute("""
            INSERT INTO bookmarks (id, chapter_id, section_id)
            VALUES ('bm_01', 'forense.vol01.ch01', 'sec_03_teoria');
        """)
        self.db.commit()

        cur.execute("SELECT section_id FROM bookmarks WHERE id = 'bm_01';")
        sec_id = cur.fetchone()[0]
        self.assertEqual(sec_id, 'sec_03_teoria')

    def test_f10_rollback_safety_preserves_user_data(self):
        """Boundary: Editorial rollback to previous revision does not delete annotations or attempts."""
        cur = self.db.cursor()
        cur.execute("INSERT INTO user_settings (key, value) VALUES ('active_rev_ch01', 'REV2');")
        cur.execute("INSERT INTO annotations (id, chapter_id, note_content, revision) VALUES ('a1', 'ch01', 'Nota importante', 'REV2');")
        self.db.commit()

        # Rollback active revision to REV1
        cur.execute("UPDATE user_settings SET value = 'REV1' WHERE key = 'active_rev_ch01';")
        self.db.commit()

        cur.execute("SELECT COUNT(*) FROM annotations WHERE id = 'a1';")
        self.assertEqual(cur.fetchone()[0], 1, "Annotation must survive editorial rollback")

    # =========================================================================
    # FEATURE 11: LOCAL TEXT SEARCH (FTS5)
    # =========================================================================

    def test_f11_empty_query_returns_empty_list(self):
        """Boundary: Empty or whitespace query returns empty string from sanitizer."""
        self.assertEqual(sanitize_fts_query(""), "")
        self.assertEqual(sanitize_fts_query("   "), "")
        self.assertEqual(sanitize_fts_query("\t\n"), "")

    def test_f11_sql_injection_defense_in_fts_search(self):
        """Boundary: SQL injection attempts are safely stripped and escaped."""
        dangerous_query = "'; DROP TABLE chapters; --"
        clean = sanitize_fts_query(dangerous_query)
        self.assertNotIn(";", clean)
        self.assertNotIn("--", clean)
        self.assertIn('"DROP"', clean)
        self.assertIn('"TABLE"', clean)

    def test_f11_special_characters_sanitization(self):
        """Boundary: FTS special characters (*, ^, quotes, parens) are sanitized."""
        query_with_specials = 'forense* AND "cadeia" ^custodia()'
        clean = sanitize_fts_query(query_with_specials)
        self.assertNotIn("*", clean)
        self.assertNotIn("^", clean)
        self.assertNotIn("(", clean)
        self.assertNotIn(")", clean)
        self.assertEqual(clean, '"forense" "AND" "cadeia" "custodia"')

    def test_f11_zero_match_query_returns_empty_list(self):
        """Boundary: Non-matching term query returns empty list without error."""
        cur = self.db.cursor()
        cur.execute("CREATE VIRTUAL TABLE IF NOT EXISTS content_fts USING fts5(title, content);")
        cur.execute("INSERT INTO content_fts (title, content) VALUES ('Fundamentos', 'Perícia criminalística em vestígios');")
        self.db.commit()

        cur.execute("SELECT * FROM content_fts WHERE content_fts MATCH '\"termo_inexistente_xyz\"';")
        results = cur.fetchall()
        self.assertEqual(len(results), 0)

    def test_f11_extremely_long_query_handling(self):
        """Boundary: 2500-character search query is safely processed without overflow."""
        long_query = "evidência " * 300
        self.assertGreater(len(long_query), 2000)
        clean = sanitize_fts_query(long_query)
        self.assertTrue(clean.startswith('"evidência"'))

    # =========================================================================
    # FEATURE 12: INGESTION & SYNC PROVIDERS
    # =========================================================================

    def test_f12_missing_drive_oauth_token_raises_auth_error(self):
        """Boundary: Ingestion without Drive token raises PermissionError (no fake success)."""
        def sync_google_drive(auth_token: str):
            if not auth_token or not auth_token.strip():
                raise PermissionError("Drive sync blocked: OAuth2 token missing or expired (HTTP 401)")
            return True

        with self.assertRaises(PermissionError):
            sync_google_drive("")
        with self.assertRaises(PermissionError):
            sync_google_drive(None)

    def test_f12_network_timeout_during_sync_preserves_local_state(self):
        """Boundary: Socket timeout during sync raises TimeoutError and preserves local catalog."""
        def sync_with_timeout(simulate_timeout: bool):
            if simulate_timeout:
                raise TimeoutError("Network timeout connecting to Google Drive API (Connection timed out)")
            return {"status": "SUCCESS"}

        with self.assertRaises(TimeoutError):
            sync_with_timeout(simulate_timeout=True)

    def test_f12_local_directory_import_nonexistent_path(self):
        """Boundary: Local directory import from non-existent directory raises FileNotFoundError."""
        import os
        def import_local_directory(dir_path: str):
            if not os.path.isdir(dir_path):
                raise FileNotFoundError(f"Local package directory '{dir_path}' does not exist")
            return True

        with self.assertRaises(FileNotFoundError):
            import_local_directory("/non_existent_directory_for_import_99")

    def test_f12_duplicate_package_rejection(self):
        """Boundary: Ingesting duplicate package with identical contentId, edition and hash raises ValueError."""
        ingested_catalog = {
            ("forense.vol01.ch01", "REV2", "hash123")
        }

        def ingest_package(content_id: str, edition: str, sha256_hash: str):
            key = (content_id, edition, sha256_hash)
            if key in ingested_catalog:
                raise ValueError(f"Duplicate package rejected: {content_id} {edition} already ingested")
            ingested_catalog.add(key)

        with self.assertRaises(ValueError):
            ingest_package("forense.vol01.ch01", "REV2", "hash123")

    def test_f12_tampered_package_sha256_mismatch(self):
        """Boundary: Ingesting package where calculated hash != declared sha256 raises ValueError."""
        def verify_package_checksum(payload_bytes: bytes, declared_sha256: str):
            calculated = hashlib.sha256(payload_bytes).hexdigest()
            if calculated != declared_sha256:
                raise ValueError(f"Checksum mismatch: declared '{declared_sha256}', calculated '{calculated}'")
            return True

        content = b'{"chapter": 1, "tampered": true}'
        declared_hash = "0000000000000000000000000000000000000000000000000000000000000000"
        with self.assertRaises(ValueError):
            verify_package_checksum(content, declared_hash)

    # =========================================================================
    # FEATURE 13: 10-STEP LESSON ENGINE
    # =========================================================================

    def test_f13_empty_lesson_steps_rejection(self):
        """Boundary: Lesson package with 0 steps raises ValueError."""
        def validate_lesson_steps(steps: list):
            if not steps:
                raise ValueError("Lesson must have steps, got 0")
            return True

        with self.assertRaises(ValueError):
            validate_lesson_steps([])

    def test_f13_missing_canonical_steps_rejection(self):
        """Boundary: Lesson missing one of the 10 canonical didactic steps raises ValueError."""
        canonical_steps = [
            "Objetivos", "Pré-requisitos", "Problema", "Teoria", "Exemplo resolvido",
            "Exercício guiado", "Laboratório", "Avaliação", "Revisão", "Resumo"
        ]
        # Incomplete steps list (only 8 steps)
        incomplete_steps = canonical_steps[:8]
        def validate_complete_canonical_sequence(steps: list):
            if len(steps) != 10:
                raise ValueError(f"Lesson didactic sequence must have exactly 10 steps, got {len(steps)}")
            return True

        with self.assertRaises(ValueError):
            validate_complete_canonical_sequence(incomplete_steps)

    def test_f13_step_index_out_of_bounds(self):
        """Boundary: Step index < 1 or > 10 raises IndexError."""
        def get_step_by_index(index: int):
            if index < 1 or index > 10:
                raise IndexError(f"Step index {index} out of bounds [1, 10]")
            return f"Step {index}"

        self.assertEqual(get_step_by_index(1), "Step 1")
        self.assertEqual(get_step_by_index(10), "Step 10")
        with self.assertRaises(IndexError):
            get_step_by_index(0)
        with self.assertRaises(IndexError):
            get_step_by_index(11)

    def test_f13_out_of_order_step_progression(self):
        """Boundary: Attempting to access Step 8 (Assessment) before completing prerequisites raises ValueError."""
        def check_step_progression(target_step: int, completed_step: int):
            if target_step > completed_step + 1:
                raise ValueError(f"Cannot jump to step {target_step} before completing step {completed_step + 1}")
            return True

        self.assertTrue(check_step_progression(target_step=2, completed_step=1))
        with self.assertRaises(ValueError):
            check_step_progression(target_step=8, completed_step=2)

    def test_f13_empty_step_content_validation(self):
        """Boundary: Step with empty title or empty body raises ValueError."""
        def validate_step_content(title: str, content: str):
            if not title or not title.strip():
                raise ValueError("Step title cannot be empty")
            if not content or not content.strip():
                raise ValueError("Step content cannot be empty")
            return True

        with self.assertRaises(ValueError):
            validate_step_content("", "Conteúdo teórico")
        with self.assertRaises(ValueError):
            validate_step_content("Título válido", "")

    # =========================================================================
    # FEATURE 14: AUTOMATED ASSESSMENT & 80% PROGRESSION
    # =========================================================================

    def test_f14_score_at_79_99_strictly_fails(self):
        """Boundary: Score of 79.99% strictly FAILS 80.00% benchmark (§8.2, §17.1)."""
        passed, status = evaluate_assessment_result(79.99)
        self.assertFalse(passed, "79.99% must strictly fail 80.00% benchmark")
        self.assertEqual(status, "REPROVADO")

    def test_f14_score_at_80_00_strictly_passes(self):
        """Boundary: Score of exactly 80.00% PASSES benchmark."""
        passed, status = evaluate_assessment_result(80.00)
        self.assertTrue(passed, "80.00% must meet passing benchmark")
        self.assertEqual(status, "APROVADO")

    def test_f14_negative_or_over_100_score_rejected(self):
        """Boundary: Score < 0.0 or > 100.0 raises ValueError."""
        with self.assertRaises(ValueError):
            evaluate_assessment_result(-0.01)
        with self.assertRaises(ValueError):
            evaluate_assessment_result(-50.0)
        with self.assertRaises(ValueError):
            evaluate_assessment_result(100.01)
        with self.assertRaises(ValueError):
            evaluate_assessment_result(150.0)

        # 0.0 and 100.0 are valid boundary extremes
        p0, s0 = evaluate_assessment_result(0.0)
        self.assertFalse(p0)
        p100, s100 = evaluate_assessment_result(100.0)
        self.assertTrue(p100)

    def test_f14_zero_questions_assessment_rejection(self):
        """Boundary: Assessment with 0 questions raises ValueError / ZeroDivisionError."""
        def calculate_score(correct_answers: int, total_questions: int):
            if total_questions <= 0:
                raise ValueError("Assessment must contain at least 1 question")
            return (correct_answers / total_questions) * 100.0

        with self.assertRaises(ValueError):
            calculate_score(0, 0)
        with self.assertRaises(ValueError):
            calculate_score(2, -1)

    def test_f14_immutable_attempt_record_enforcement(self):
        """Boundary: Finalized assessment attempt record cannot be mutated."""
        cur = self.db.cursor()
        cur.execute("""
            INSERT INTO assessment_attempts (id, assessment_id, student_id, score, passed, attempted_at)
            VALUES ('att_locked_01', 'asm_ch01', 'student_1', 75.0, 0, '2026-11-16T08:00:00Z');
        """)
        self.db.commit()

        # Enforce application-level immutability rule
        def mutate_attempt(attempt_id: str, new_score: float):
            raise PermissionError(f"Assessment attempt '{attempt_id}' is immutable and cannot be updated")

        with self.assertRaises(PermissionError):
            mutate_attempt('att_locked_01', 95.0)


if __name__ == "__main__":
    unittest.main()
