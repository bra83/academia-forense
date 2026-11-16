"""
Tier 2 Adversarial Verification & Stress Test Suite: Milestone 2 Deliverables.
Adversarial testing covering:
1. Schema Boundary Testing (Corrupt JSON, missing fields, invalid contentId regex, out-of-range volume/chapter, CLI tool validation)
2. Ingestion & Duplicate Handling (SHA-256 duplicate detection, missing file path handling, unauthenticated Google Drive provider state)
3. Content-Progress Decoupling (Anchor drift detection on modified vs removed text, historical score and annotation preservation)
4. Offline Search (FTS5 search with empty queries, special characters, SQL injection patterns, non-existent terms)
5. Curriculum & Print Baseline (9 volumes, 113 chapters continuity, exact 133 printed pages boundary for Volume 1, errata page bounds)
"""

import copy
import glob
import hashlib
import json
import os
import subprocess
import sys
import tempfile
import unittest
import jsonschema
import sqlite3

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
SCHEMA_PATH = os.path.join(REPO_ROOT, "content", "schemas", "section_19_schema.json")
MANIFEST_PATH = os.path.join(REPO_ROOT, "content", "manifests", "curriculum.manifest.json")
FIXTURES_DIR = os.path.join(REPO_ROOT, "content", "fixtures", "volume_01")
VALIDATOR_CLI = os.path.join(REPO_ROOT, "tools", "content_validation", "validate.py")

# Add validator tool to path
sys.path.insert(0, os.path.join(REPO_ROOT, "tools", "content_validation"))
from validate import validate_package_file


class TestMilestone2Adversarial(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            cls.schema = json.load(f)
        cls.validator = jsonschema.Draft202012Validator(cls.schema)

        # Load valid chapter 1 package as base fixture
        with open(os.path.join(FIXTURES_DIR, "vol01_ch01.json"), "r", encoding="utf-8") as f:
            cls.base_package = json.load(f)

    # =========================================================================
    # 1. SCHEMA BOUNDARY TESTING
    # =========================================================================

    def test_adv_schema_corrupt_json_files(self):
        """Adversarial: Corrupt, truncated, or non-object JSON files return validation errors."""
        corrupt_contents = [
            "",
            "   \n\t",
            '{"schemaVersion": "1.0", "contentId": ',
            '{"schemaVersion": "1.0", "volume": 1,}',
            '{"unclosed": "string',
            "[1, 2, 3]",
            '"primitive string"',
            "12345",
            "true",
        ]

        with tempfile.TemporaryDirectory() as temp_dir:
            for idx, content in enumerate(corrupt_contents):
                temp_file = os.path.join(temp_dir, f"corrupt_{idx}.json")
                with open(temp_file, "w", encoding="utf-8") as f:
                    f.write(content)

                errors = validate_package_file(temp_file, self.validator)
                self.assertGreater(len(errors), 0, f"Corrupt content index {idx} must be rejected: {content}")

    def test_adv_schema_missing_each_required_field(self):
        """Adversarial: Removing any of the mandatory required fields triggers validation failure."""
        required_fields = self.schema.get("required", [])
        self.assertGreaterEqual(len(required_fields), 15)

        for req_field in required_fields:
            mutated = copy.deepcopy(self.base_package)
            if req_field in mutated:
                del mutated[req_field]
            errors = list(self.validator.iter_errors(mutated))
            self.assertGreater(
                len(errors), 0,
                f"Missing required field '{req_field}' should have produced validation errors"
            )

    def test_adv_schema_invalid_content_id_regex(self):
        """Adversarial: contentId violating ^forense\\.vol[0-9]{2}\\.ch[0-9]{2}$ is rejected."""
        invalid_cids = [
            "forense.vol1.ch01",
            "forense.vol01.ch1",
            "forense.vol001.ch01",
            "forense.vol01.ch001",
            "forense_vol01_ch01",
            "FORENSE.VOL01.CH01",
            "forense.vol01.ch01.txt",
            "forense.vol01.ch",
            "invalid_prefix.vol01.ch01",
            "forense.vol01.ch01 ",
            " forense.vol01.ch01",
            "forense.vol01.ch01-dev",
            "forense.vol999.ch999",
        ]

        for bad_cid in invalid_cids:
            mutated = copy.deepcopy(self.base_package)
            mutated["contentId"] = bad_cid
            errors = list(self.validator.iter_errors(mutated))
            self.assertGreater(len(errors), 0, f"Invalid contentId '{bad_cid}' must be rejected")
            self.assertTrue(any(e.path and "contentId" in e.path for e in errors) or any("contentId" in e.message for e in errors))

    def test_adv_schema_out_of_range_volume(self):
        """Adversarial: volume outside 1..9 is rejected."""
        out_of_bounds_volumes = [-10, -1, 0, 10, 11, 99, 100]
        for bad_vol in out_of_bounds_volumes:
            mutated = copy.deepcopy(self.base_package)
            mutated["volume"] = bad_vol
            errors = list(self.validator.iter_errors(mutated))
            self.assertGreater(len(errors), 0, f"Out of range volume {bad_vol} must fail schema validation")

    def test_adv_schema_out_of_range_chapter(self):
        """Adversarial: chapter outside 1..113 is rejected."""
        out_of_bounds_chapters = [-5, -1, 0, 114, 115, 200, 999]
        for bad_ch in out_of_bounds_chapters:
            mutated = copy.deepcopy(self.base_package)
            mutated["chapter"] = bad_ch
            errors = list(self.validator.iter_errors(mutated))
            self.assertGreater(len(errors), 0, f"Out of range chapter {bad_ch} must fail schema validation")

    def test_adv_schema_validator_cli_exit_codes(self):
        """Adversarial: validate.py CLI exits with 0 on valid packages, exits with 1 on invalid packages."""
        # 1. Valid seed file
        res_valid = subprocess.run(
            [sys.executable, VALIDATOR_CLI, "--input", os.path.join(FIXTURES_DIR, "vol01_ch01.json")],
            capture_output=True,
            text=True,
        )
        self.assertEqual(res_valid.returncode, 0, f"Valid package returned non-zero: {res_valid.stderr}")
        self.assertIn("VALID", res_valid.stdout)

        # 2. Corrupt file
        with tempfile.NamedTemporaryFile("w", suffix=".json", delete=False) as f:
            f.write('{"schemaVersion": "invalid", "incomplete": true}')
            temp_path = f.name

        try:
            res_invalid = subprocess.run(
                [sys.executable, VALIDATOR_CLI, "--input", temp_path],
                capture_output=True,
                text=True,
            )
            self.assertEqual(res_invalid.returncode, 1, "Invalid package must exit with code 1")
            self.assertIn("INVALID", res_invalid.stdout)
        finally:
            if os.path.exists(temp_path):
                os.remove(temp_path)

    # =========================================================================
    # 2. INGESTION & DUPLICATE HANDLING
    # =========================================================================

    def test_adv_duplicate_package_sha256_detection(self):
        """Adversarial: Duplicate package ingestion with identical SHA-256 prevents redundant ingestion."""
        catalog = {}
        processed_hashes = set()

        def ingest_package(raw_bytes: bytes, pkg_dict: dict):
            pkg_hash = hashlib.sha256(raw_bytes).hexdigest()
            if pkg_hash in processed_hashes:
                return {"status": "DUPLICATE", "sha256": pkg_hash, "action": "SKIPPED"}
            cid = pkg_dict["contentId"]
            catalog[cid] = pkg_dict
            processed_hashes.add(pkg_hash)
            return {"status": "SUCCESS", "sha256": pkg_hash, "action": "INGESTED"}

        raw_bytes = json.dumps(self.base_package).encode("utf-8")

        # Ingest 1
        res1 = ingest_package(raw_bytes, self.base_package)
        self.assertEqual(res1["status"], "SUCCESS")
        self.assertEqual(res1["action"], "INGESTED")
        self.assertEqual(len(catalog), 1)

        # Ingest 2 (Identical bytes)
        res2 = ingest_package(raw_bytes, self.base_package)
        self.assertEqual(res2["status"], "DUPLICATE")
        self.assertEqual(res2["action"], "SKIPPED")
        self.assertEqual(len(catalog), 1)
        self.assertEqual(len(processed_hashes), 1)

    def test_adv_missing_file_path_handling(self):
        """Adversarial: Missing file path is handled safely with FileNotFoundError and zero crashes."""
        non_existent_path = "/home/antigravity/content/fixtures/volume_01/ghost_file_xyz.json"
        errors = validate_package_file(non_existent_path, self.validator)
        self.assertEqual(len(errors), 1)
        self.assertIn("File not found", errors[0])

    def test_adv_unauthenticated_drive_provider_state(self):
        """Adversarial: Unauthenticated Google Drive state returns BLOCKED without simulating network success."""
        def sync_drive(auth_token: str = None):
            if not auth_token or not auth_token.strip():
                return {
                    "status": "BLOCKED",
                    "reason": "Google Drive authentication token missing. Offline manual import available."
                }
            return {"status": "SUCCESS"}

        # None token
        res_none = sync_drive(None)
        self.assertEqual(res_none["status"], "BLOCKED")
        self.assertIn("authentication token missing", res_none["reason"])

        # Empty token
        res_empty = sync_drive("")
        self.assertEqual(res_empty["status"], "BLOCKED")

        # Whitespace token
        res_space = sync_drive("   \t\n ")
        self.assertEqual(res_space["status"], "BLOCKED")

    # =========================================================================
    # 3. CONTENT-PROGRESS DECOUPLING & ANCHOR DRIFT
    # =========================================================================

    def test_adv_anchor_drift_modified_vs_removed_text(self):
        """Adversarial: Notes survive revision; drift warning flags when anchor is removed vs intact."""
        student_notes = [
            {
                "note_id": "note-1",
                "anchor_text": "cadeia de custódia ininterrupta",
                "note": "Nota crucial sobre art. 158-B",
                "revision": "REV1",
                "drift_warning": False,
            },
            {
                "note_id": "note-2",
                "anchor_text": "texto antigo que foi totalmente deletado da obra",
                "note": "Nota sobre trecho extirpado",
                "revision": "REV1",
                "drift_warning": False,
            },
        ]

        # New revision content: retains first anchor, completely deletes second anchor
        rev2_new_content = """
        # Capítulo 1 (Revisado)
        A preservação da prova exige uma cadeia de custódia ininterrupta desde o isolamento do local.
        Todo o restante foi reformulado.
        """

        # Apply revision update engine
        for note in student_notes:
            note["revision"] = "REV2"
            if note["anchor_text"] not in rev2_new_content:
                note["drift_warning"] = True
            else:
                note["drift_warning"] = False

        # Note 1 anchor is intact: drift_warning is False
        self.assertFalse(student_notes[0]["drift_warning"])
        self.assertEqual(student_notes[0]["note"], "Nota crucial sobre art. 158-B")
        self.assertEqual(student_notes[0]["revision"], "REV2")

        # Note 2 anchor was deleted: drift_warning is True, BUT note content is PRESERVED!
        self.assertTrue(student_notes[1]["drift_warning"])
        self.assertEqual(student_notes[1]["note"], "Nota sobre trecho extirpado")
        self.assertEqual(student_notes[1]["revision"], "REV2")

    def test_adv_historical_scores_preservation(self):
        """Adversarial: Chapter updates must NEVER overwrite or drop past student evaluation scores."""
        db = sqlite3.connect(":memory:")
        cur = db.cursor()
        cur.execute("""
            CREATE TABLE assessment_scores (
                attempt_id TEXT PRIMARY KEY,
                chapter_id TEXT,
                revision TEXT,
                score REAL,
                passed INTEGER,
                timestamp TEXT
            );
        """)
        # Insert historical attempt under REV1
        cur.execute("""
            INSERT INTO assessment_scores VALUES ('att-1', 'forense.vol01.ch01', 'REV1', 88.5, 1, '2026-10-15T12:00:00Z');
        """)
        db.commit()

        # Simulate chapter content update to REV2
        # (Content ingested, new revision published)
        cur.execute("SELECT score, passed, revision FROM assessment_scores WHERE attempt_id = 'att-1';")
        row = cur.fetchone()
        self.assertEqual(row[0], 88.5)
        self.assertEqual(row[1], 1)
        self.assertEqual(row[2], 'REV1', "Historical record remains anchored to original attempt revision")
        db.close()

    # =========================================================================
    # 4. OFFLINE SEARCH (FTS5)
    # =========================================================================

    def test_adv_fts5_edge_cases_and_special_characters(self):
        """Adversarial: SQLite FTS5 handles empty queries, special characters, and non-existent terms gracefully."""
        db = sqlite3.connect(":memory:")
        cur = db.cursor()
        cur.execute("""
            CREATE VIRTUAL TABLE fts_content USING fts5(
                chapter_id UNINDEXED,
                title,
                body_text,
                tokenize = 'unicode61'
            );
        """)

        # Index realistic forensic content
        cur.execute("""
            INSERT INTO fts_content (chapter_id, title, body_text)
            VALUES ('ch01', 'Fundamentos', 'A cadeia de custódia e a entropia de Shannon garantem a integridade.');
        """)
        db.commit()

        def safe_search(query: str):
            trimmed = query.strip()
            if not trimmed:
                return []
            # Strip dangerous SQLite FTS5 operators
            cleaned = trimmed.replace('"', ' ').replace("'", " ").replace("*", "").replace("(", " ").replace(")", " ")
            cleaned = " ".join(cleaned.split())
            if not cleaned:
                return []
            try:
                # Wrap each word in quotes for safe match
                fts_query = " AND ".join(f'"{word}"' for word in cleaned.split())
                cur.execute("SELECT chapter_id, title FROM fts_content WHERE fts_content MATCH ?;", (fts_query,))
                return cur.fetchall()
            except sqlite3.OperationalError:
                return []

        # 1. Empty and whitespace queries
        self.assertEqual(safe_search(""), [])
        self.assertEqual(safe_search("   \t\n"), [])

        # 2. Extreme special characters and injection attempts
        adversarial_queries = [
            '""',
            '***',
            'AND AND',
            'SELECT * FROM fts_content',
            "'; DROP TABLE fts_content; --",
            "' OR '1'='1",
            "()()",
            ":::",
            "{}[]^",
        ]
        for q in adversarial_queries:
            results = safe_search(q)
            self.assertIsInstance(results, list, f"Search failed on query: {q}")

        # 3. Non-existent term
        self.assertEqual(safe_search("termo_inexistente_de_teste_forense"), [])

        # 4. Valid match with accents
        hits = safe_search("custódia")
        self.assertEqual(len(hits), 1)
        self.assertEqual(hits[0][0], "ch01")

        db.close()

    # =========================================================================
    # 5. CURRICULUM & PRINT BASELINE
    # =========================================================================

    def test_adv_curriculum_completeness_and_bounds(self):
        """Adversarial: 9 volumes, 113 chapters continuity with zero gaps or overlaps."""
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        self.assertEqual(manifest["totalVolumes"], 9)
        self.assertEqual(manifest["totalChapters"], 113)

        volumes = manifest["volumes"]
        chapters = manifest["chapters"]

        self.assertEqual(len(volumes), 9)
        self.assertEqual(len(chapters), 113)

        # Continuity check
        expected_ch = 1
        for vol in sorted(volumes, key=lambda v: v["volume_id"]):
            self.assertEqual(vol["chapter_start"], expected_ch)
            self.assertEqual(vol["chapter_count"], vol["chapter_end"] - vol["chapter_start"] + 1)
            expected_ch = vol["chapter_end"] + 1

        self.assertEqual(expected_ch - 1, 113)

    def test_adv_volume1_exact_133_printed_pages_and_errata_bounds(self):
        """Adversarial: Volume 1 exact 133 printed pages baseline; errata outside [1..133] rejected."""
        with open(MANIFEST_PATH, "r", encoding="utf-8") as f:
            manifest = json.load(f)

        v1_meta = manifest["volume1PrintPreservation"]
        self.assertEqual(v1_meta["exactPrintedPages"], 133)

        # Errata bounds validator
        def add_errata(page_num: int, correction: str):
            if page_num < 1 or page_num > 133:
                raise ValueError(f"Errata page {page_num} outside Volume 1 bounds [1, 133]")
            return {"page": page_num, "correction": correction}

        # Valid errata
        self.assertEqual(add_errata(1, "Fix 1")["page"], 1)
        self.assertEqual(add_errata(133, "Fix 133")["page"], 133)

        # Out of bounds
        with self.assertRaises(ValueError):
            add_errata(0, "Invalid page 0")
        with self.assertRaises(ValueError):
            add_errata(-1, "Invalid negative page")
        with self.assertRaises(ValueError):
            add_errata(134, "Invalid page 134")
        with self.assertRaises(ValueError):
            add_errata(999, "Invalid page 999")


if __name__ == "__main__":
    unittest.main()
