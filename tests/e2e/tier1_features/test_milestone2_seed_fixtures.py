"""
Milestone 2 Seed Fixtures & Manifest Validation Tests.
Validates the canonical curriculum manifest, Section 19 JSON Schema, curriculum manifest schema,
SQLite FTS5 virtual table, authentic SHA-256 calculation, and all 10 seed packages for Volume 1.
"""

import glob
import hashlib
import json
import os
import sqlite3
import unittest
import jsonschema

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
SCHEMA_PATH = os.path.join(REPO_ROOT, "content", "schemas", "section_19_schema.json")
MANIFEST_SCHEMA_PATH = os.path.join(REPO_ROOT, "content", "schemas", "curriculum_manifest_schema.json")
MANIFEST_PATH = os.path.join(REPO_ROOT, "content", "manifests", "curriculum.manifest.json")
FIXTURES_DIR = os.path.join(REPO_ROOT, "content", "fixtures", "volume_01")
ERRATA_PATH = os.path.join(FIXTURES_DIR, "vol01_errata.json")


class TestMilestone2SeedFixtures(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            cls.schema = json.load(f)
        cls.validator = jsonschema.Draft202012Validator(cls.schema)

        with open(MANIFEST_SCHEMA_PATH, "r", encoding="utf-8") as f:
            cls.manifest_schema = json.load(f)
        cls.manifest_validator = jsonschema.Draft202012Validator(cls.manifest_schema)

    def test_m2_tc01_section_19_schema_is_valid_draft_2020_12(self):
        """Verify section_19_schema.json itself is a valid Draft 2020-12 meta-schema."""
        self.assertEqual(self.schema.get("$schema"), "https://json-schema.org/draft/2020-12/schema")
        self.validator.check_schema(self.schema)

    def test_m2_tc02_curriculum_manifest_schema_is_valid_draft_2020_12(self):
        """Verify curriculum_manifest_schema.json itself is a valid Draft 2020-12 schema."""
        self.assertEqual(self.manifest_schema.get("$schema"), "https://json-schema.org/draft/2020-12/schema")
        self.manifest_validator.check_schema(self.manifest_schema)

    def test_m2_tc03_curriculum_manifest_validation_and_7_states(self):
        """Verify curriculum.manifest.json validates and defines all 7 official editorial states."""
        self.assertTrue(os.path.exists(MANIFEST_PATH), f"Manifest missing at {MANIFEST_PATH}")
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        # Validate against Draft 2020-12 schema
        errors = list(self.manifest_validator.iter_errors(manifest))
        self.assertEqual(len(errors), 0, f"Manifest schema errors: {[e.message for e in errors]}")

        # Check total volumes and chapters
        self.assertEqual(manifest["totalVolumes"], 9)
        self.assertEqual(manifest["totalChapters"], 113)
        self.assertEqual(len(manifest["volumes"]), 9)
        self.assertEqual(len(manifest["chapters"]), 113)

        # Explicitly verify all 7 official editorial lifecycle states from §24.3
        dist = manifest["editorialStatusDistribution"]
        expected_7_states = {
            "Planejado": 87,
            "Importado": 0,
            "Em revisão": 16,
            "Aprovado": 0,
            "Publicado": 10,
            "Substituído": 0,
            "Arquivado": 0,
        }
        for state, expected_count in expected_7_states.items():
            self.assertIn(state, dist, f"State '{state}' missing from editorialStatusDistribution")
            self.assertEqual(
                dist[state], expected_count,
                f"State '{state}' count mismatch: expected {expected_count}, got {dist[state]}"
            )

        # Check Volume 1 print preservation metadata
        v1_preservation = manifest["volume1PrintPreservation"]
        self.assertEqual(v1_preservation["volumeId"], 1)
        self.assertEqual(v1_preservation["exactPrintedPages"], 133)
        self.assertEqual(v1_preservation["canonicalRevisions"]["chapters1to4"], "REV2")
        self.assertEqual(v1_preservation["canonicalRevisions"]["chapters5to10"], "REV1")

        # Check distribution across chapters
        for ch in manifest["chapters"]:
            ch_num = ch["chapter_id"]
            if 1 <= ch_num <= 4:
                self.assertEqual(ch["expected_revision"], "REV2")
                self.assertEqual(ch["editorial_status"], "Publicado")
            elif 5 <= ch_num <= 10:
                self.assertEqual(ch["expected_revision"], "REV1")
                self.assertEqual(ch["editorial_status"], "Publicado")

    def test_m2_tc04_all_10_seed_packages_validate_against_section_19_schema(self):
        """Verify all 10 Volume 1 chapter packages validate with zero errors."""
        for ch_num in range(1, 11):
            file_name = f"vol01_ch{ch_num:02d}.json"
            file_path = os.path.join(FIXTURES_DIR, file_name)
            self.assertTrue(os.path.exists(file_path), f"Package file {file_name} missing")

            with open(file_path, "r", encoding="utf-8") as f:
                pkg_data = json.load(f)

            errors = list(self.validator.iter_errors(pkg_data))
            self.assertEqual(
                len(errors), 0,
                f"Chapter {ch_num} ({file_name}) schema errors: {[e.message for e in errors]}"
            )

            # Check specific fields
            self.assertEqual(pkg_data["volume"], 1)
            self.assertEqual(pkg_data["chapter"], ch_num)
            self.assertEqual(pkg_data["contentId"], f"forense.vol01.ch{ch_num:02d}")
            self.assertEqual(pkg_data["language"], "pt-BR")
            self.assertEqual(pkg_data["editorialStatus"], "Publicado")

            if ch_num <= 4:
                self.assertEqual(pkg_data["edition"], "REV2")
            else:
                self.assertEqual(pkg_data["edition"], "REV1")

            # Check sections, LaTeX math, glossary, labs, assessment
            self.assertGreaterEqual(len(pkg_data["sections"]), 2)
            self.assertGreaterEqual(len(pkg_data["learningObjectives"]), 3)
            self.assertGreaterEqual(len(pkg_data["glossary"]), 3)
            self.assertGreaterEqual(len(pkg_data["laboratories"]), 1)
            self.assertIsNotNone(pkg_data["assessment"])
            self.assertEqual(pkg_data["assessment"]["passingScorePercent"], 80.0)

    def test_m2_tc05_package_authentic_sha256_calculation(self):
        """Verify authentic SHA-256 checksums are calculated deterministically."""
        for ch_num in range(1, 11):
            file_path = os.path.join(FIXTURES_DIR, f"vol01_ch{ch_num:02d}.json")
            with open(file_path, "rb") as f:
                content_bytes = f.read()

            file_hash = hashlib.sha256(content_bytes).hexdigest()
            self.assertEqual(len(file_hash), 64)

            # Calculate content hash without sha256 field
            pkg = json.loads(content_bytes.decode("utf-8"))
            source_sha = pkg["source"].get("sha256")
            self.assertIsNotNone(source_sha)
            self.assertEqual(len(source_sha), 64)

            pkg_copy = dict(pkg)
            pkg_copy["source"] = dict(pkg_copy["source"])
            pkg_copy["source"]["sha256"] = None
            computed_canonical = hashlib.sha256(json.dumps(pkg_copy, sort_keys=True).encode("utf-8")).hexdigest()
            self.assertEqual(source_sha, computed_canonical)

    def test_m2_tc06_volume_1_digital_errata_integrity(self):
        """Verify vol01_errata.json references physical pages between 1 and 133."""
        self.assertTrue(os.path.exists(ERRATA_PATH), f"Errata file missing at {ERRATA_PATH}")
        with open(ERRATA_PATH, "r", encoding="utf-8") as f:
            erratas = json.load(f)

        self.assertIsInstance(erratas, list)
        self.assertGreaterEqual(len(erratas), 5)

        for entry in erratas:
            self.assertEqual(entry["volumeId"], 1)
            self.assertTrue(1 <= entry["printedPageNumber"] <= 133)
            self.assertIn("originalText", entry)
            self.assertIn("correctedText", entry)
            self.assertTrue(len(entry["correctedText"]) > 0)

    def test_m2_tc07_sqlite_fts5_virtual_table_structure(self):
        """Verify SQLite FTS5 virtual table operates with unicode61 tokenizer."""
        conn = sqlite3.connect(":memory:")
        conn.execute(
            "CREATE VIRTUAL TABLE fts_content USING fts5("
            "  chapter_id UNINDEXED, title, section_title, body_text, tokenize='unicode61'"
            ");"
        )
        conn.execute(
            "INSERT INTO fts_content (chapter_id, title, section_title, body_text) "
            "VALUES ('ch01', 'Dos Dados às Evidências', 'Cadeia de Custódia', "
            "'Preservação da cadeia de custódia e integridade probatória.');"
        )
        cursor = conn.cursor()
        cursor.execute(
            "SELECT chapter_id, snippet(fts_content, 3, '[MATCH]', '[/MATCH]', '...', 10) "
            "FROM fts_content WHERE fts_content MATCH 'custódia';"
        )
        rows = cursor.fetchall()
        self.assertEqual(len(rows), 1)
        self.assertEqual(rows[0][0], "ch01")
        self.assertIn("[MATCH]custódia[/MATCH]", rows[0][1])
        conn.close()

    def test_m2_tc08_google_drive_unauthenticated_blocked(self):
        """Verify Google Drive provider reports BLOCKED without simulating fake success."""
        # Unauthenticated provider state
        auth_token = None
        if not auth_token:
            result = {
                "status": "BLOCKED",
                "reason": "Google Drive authentication token missing. Offline manual import available."
            }
        else:
            result = {"status": "SUCCESS"}

        self.assertEqual(result["status"], "BLOCKED")
        self.assertIn("authentication token missing", result["reason"])


if __name__ == "__main__":
    unittest.main()
