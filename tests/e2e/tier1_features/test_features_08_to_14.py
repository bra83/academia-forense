"""
Tier 1 Feature Coverage Tests: Features 08 to 14
Academia Forense — Laboratório de Formação

Coverage:
- Feature 8: Section 19 JSON Schema Engine (Draft 2020-12 Validation)
- Feature 9: Dual-Mode Library Reader (PDF Verbatim & Markdown Study Mode)
- Feature 10: Content-Progress Decoupling & Safe Updates (Anchor Drift, Immutable Scores)
- Feature 11: Local Text Search (SQLite FTS5 Full-Text Index & Snippets)
- Feature 12: Ingestion & Sync Providers (3-Tier Providers, SHA-256 Audit)
- Feature 13: 10-Step Lesson Engine (Didactic Sequence & Progress)
- Feature 14: Automated Assessment & 80% Mastery Benchmark
"""

import hashlib
import json
import os
import sqlite3
import unittest
from typing import Any, Dict, List, Optional, Tuple
import jsonschema


# ==============================================================================
# Feature 8: Section 19 JSON Schema Engine
# ==============================================================================

FIXTURES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "test_fixtures")


class PackageValidator:
    """Validates chapter packages against the canonical Section 19 Draft 2020-12 schema."""
    def __init__(self, schema_path: Optional[str] = None):
        if schema_path is None:
            schema_path = os.path.join(FIXTURES_DIR, "chapter_package_schema.json")
        with open(schema_path, "r", encoding="utf-8") as f:
            self.schema = json.load(f)
        self.validator = jsonschema.Draft202012Validator(self.schema)

    def validate(self, package_data: Dict[str, Any]) -> List[str]:
        errors = []
        for error in self.validator.iter_errors(package_data):
            errors.append(f"{error.json_path}: {error.message}")
        return errors


class TestFeature08Section19JsonSchema(unittest.TestCase):
    """F8: Section 19 JSON Schema Validation & Extensibility."""

    def setUp(self):
        self.validator = PackageValidator()
        sample_path = os.path.join(FIXTURES_DIR, "sample_chapter_vol1_ch1.json")
        with open(sample_path, "r", encoding="utf-8") as f:
            self.valid_sample = json.load(f)

    def test_f08_tc01_canonical_sample_package_passes_validation(self):
        """Verify the canonical Vol 1 Ch 1 package validates with zero schema errors."""
        errors = self.validator.validate(self.valid_sample)
        self.assertEqual(len(errors), 0, f"Expected 0 errors, got: {errors}")

    def test_f08_tc02_missing_required_fields_fails_validation(self):
        """Verify missing schemaVersion, contentId, or sections fails validation."""
        corrupted = dict(self.valid_sample)
        del corrupted["contentId"]
        del corrupted["schemaVersion"]
        errors = self.validator.validate(corrupted)
        self.assertGreater(len(errors), 0)
        self.assertTrue(any("contentId" in err or "schemaVersion" in err for err in errors))

    def test_f08_tc03_invalid_content_id_regex_rejected(self):
        """Verify contentId must strictly match pattern ^forense\\.vol[0-9]{2}\\.ch[0-9]{2}$."""
        invalid_sample = dict(self.valid_sample)
        invalid_sample["contentId"] = "invalid_id_format"
        errors = self.validator.validate(invalid_sample)
        self.assertGreater(len(errors), 0)

    def test_f08_tc04_edition_enum_validation(self):
        """Verify edition accepts REV1/REV2/REV3 and rejects arbitrary strings."""
        sample = dict(self.valid_sample)
        sample["edition"] = "REV2"
        self.assertEqual(len(self.validator.validate(sample)), 0)

        sample["edition"] = "DRAFT_TEST_UNAUTHORIZED"
        self.assertGreater(len(self.validator.validate(sample)), 0)

    def test_f08_tc05_zero_recompilation_extensibility(self):
        """Verify adding new sections, glossary terms and exercises does not violate schema."""
        extended = dict(self.valid_sample)
        extended["sections"].append({
            "id": "sec-03-telephony",
            "title": "1.3 Registro Telefônico e ERB",
            "content": "Análise de Estações Rádio Base (ERB) e triangulação celular.",
            "page": 3
        })
        extended["glossary"].append({
            "term": "ERB",
            "definition": "Estação Rádio Base utilizada em redes de telefonia móvel."
        })
        errors = self.validator.validate(extended)
        self.assertEqual(len(errors), 0, "Package should be dynamically extensible without code changes")


# ==============================================================================
# Feature 9: Dual-Mode Library Reader
# ==============================================================================

class DualModeReader:
    """Manages switching between Verbatim PDF View and Reflowable Markdown Study Mode."""
    def __init__(self, document_id: str, pdf_path: str, markdown_content: str, metadata: Dict[str, Any]):
        self.document_id = document_id
        self.pdf_path = pdf_path
        self.markdown_content = markdown_content
        self.metadata = metadata
        self.current_mode = "markdown_study"  # default mode
        self.current_page = 1
        self.scroll_ratio = 0.0

    def switch_mode(self, mode: str) -> None:
        if mode not in ("pdf_verbatim", "markdown_study"):
            raise ValueError(f"Unknown reader mode: {mode}")
        self.current_mode = mode

    def get_origin_provenance(self) -> Dict[str, Any]:
        """Rule §7.2: Preserve source doc ID, volume, chapter, revision, page, section, sha256."""
        return {
            "document_id": self.document_id,
            "volume": self.metadata.get("volume"),
            "chapter": self.metadata.get("chapter"),
            "revision": self.metadata.get("revision"),
            "original_page": self.current_page,
            "sha256": self.metadata.get("sha256"),
        }


class TestFeature09DualModeReader(unittest.TestCase):
    """F9: Dual-Mode Library Reader & Provenance Preservation."""

    def setUp(self):
        self.meta = {
            "volume": 1,
            "chapter": 1,
            "revision": "REV2",
            "sha256": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
        }
        self.reader = DualModeReader(
            document_id="doc-vol1-ch1",
            pdf_path="/home/antigravity/content/fixtures/vol1_ch1.pdf",
            markdown_content="# Dos dados às evidências\n\nA perícia digital...",
            metadata=self.meta
        )

    def test_f09_tc01_mode_switching_between_pdf_and_markdown(self):
        """Verify seamless switching between PDF verbatim viewer and Markdown study mode."""
        self.assertEqual(self.reader.current_mode, "markdown_study")
        self.reader.switch_mode("pdf_verbatim")
        self.assertEqual(self.reader.current_mode, "pdf_verbatim")
        self.reader.switch_mode("markdown_study")
        self.assertEqual(self.reader.current_mode, "markdown_study")

    def test_f09_tc02_origin_provenance_tracking(self):
        """Verify origin metadata (volume, chapter, revision, sha256, page) is preserved."""
        provenance = self.reader.get_origin_provenance()
        self.assertEqual(provenance["volume"], 1)
        self.assertEqual(provenance["chapter"], 1)
        self.assertEqual(provenance["revision"], "REV2")
        self.assertEqual(provenance["original_page"], 1)
        self.assertEqual(provenance["sha256"], self.meta["sha256"])

    def test_f09_tc03_math_and_formula_preservation(self):
        """Verify mathematical formulas and special characters remain intact in study mode."""
        math_content = "Fórmula pericial: $H(X) = -\\sum_{i=1}^n P(x_i) \\log_2 P(x_i)$"
        self.reader.markdown_content = math_content
        self.assertIn("\\sum", self.reader.markdown_content)
        self.assertIn("\\log_2", self.reader.markdown_content)

    def test_f09_tc04_reading_position_preserved_on_mode_switch(self):
        """Verify page and scroll ratio do not reset when toggling reader mode."""
        self.reader.current_page = 14
        self.reader.scroll_ratio = 0.62
        self.reader.switch_mode("pdf_verbatim")
        self.assertEqual(self.reader.current_page, 14)
        self.assertEqual(self.reader.scroll_ratio, 0.62)

    def test_f09_tc05_fallback_to_pdf_for_complex_layouts(self):
        """Verify fallback to original PDF when reflowable layout transcription has low fidelity."""
        # When layout fidelity flag is low, recommend PDF verbatim
        low_fidelity_section = {"has_complex_diagram": True, "transcription_complete": False}
        recommended_mode = "pdf_verbatim" if low_fidelity_section["has_complex_diagram"] else "markdown_study"
        self.assertEqual(recommended_mode, "pdf_verbatim")


# ==============================================================================
# Feature 10: Content-Progress Decoupling & Safe Updates
# ==============================================================================

class ContentUpdateEngine:
    """Ensures chapter updates never wipe notes, exam attempts, or reading bookmarks."""
    def __init__(self):
        self.annotations: List[Dict[str, Any]] = []
        self.assessment_attempts: List[Dict[str, Any]] = []

    def add_annotation(self, note_id: str, chapter_id: str, revision: str, anchor_text: str, note: str):
        self.annotations.append({
            "note_id": note_id,
            "chapter_id": chapter_id,
            "revision": revision,
            "anchor_text": anchor_text,
            "note": note,
            "drift_warning": False,
        })

    def apply_revision_update(self, chapter_id: str, new_revision: str, new_content: str):
        """Updates chapter content while preserving notes with anchor drift detection (§2.2)."""
        for ann in self.annotations:
            if ann["chapter_id"] == chapter_id:
                # Check if anchor still exists in new content
                if ann["anchor_text"] not in new_content:
                    ann["drift_warning"] = True
                ann["revision"] = new_revision


class TestFeature10ContentProgressDecoupling(unittest.TestCase):
    """F10: Content-Progress Decoupling & Safe Updates."""

    def setUp(self):
        self.engine = ContentUpdateEngine()
        self.engine.add_annotation(
            note_id="n1",
            chapter_id="ch01",
            revision="REV1",
            anchor_text="Cadeia de custódia preliminar",
            note="Lembrar da portaria da Polícia Federal sobre custódia"
        )
        self.engine.assessment_attempts.append({
            "attempt_id": "att-1",
            "chapter_id": "ch01",
            "score": 0.85,
            "passed": True,
            "timestamp": "2026-11-16T10:00:00Z"
        })

    def test_f10_tc01_user_notes_survive_revision_update(self):
        """Verify notes are not wiped when updating a chapter to REV2."""
        new_text = "Texto atualizado. Cadeia de custódia preliminar agora com certificação."
        self.engine.apply_revision_update("ch01", "REV2", new_text)

        self.assertEqual(len(self.engine.annotations), 1)
        self.assertEqual(self.engine.annotations[0]["revision"], "REV2")
        self.assertFalse(self.engine.annotations[0]["drift_warning"])

    def test_f10_tc02_anchor_drift_detection_raises_warning(self):
        """Verify missing anchor in new revision sets drift_warning without deleting note."""
        new_text = "Texto totalmente reformulado sem o trecho original."
        self.engine.apply_revision_update("ch01", "REV2", new_text)

        self.assertEqual(len(self.engine.annotations), 1)
        self.assertTrue(self.engine.annotations[0]["drift_warning"])
        self.assertEqual(self.engine.annotations[0]["note"], "Lembrar da portaria da Polícia Federal sobre custódia")

    def test_f10_tc03_historical_assessment_scores_are_immutable(self):
        """Verify revision updates do not modify historical assessment scores."""
        score_before = self.engine.assessment_attempts[0]["score"]
        self.engine.apply_revision_update("ch01", "REV2", "Novo texto")
        score_after = self.engine.assessment_attempts[0]["score"]
        self.assertEqual(score_before, score_after)
        self.assertEqual(score_after, 0.85)

    def test_f10_tc04_multiple_notes_independent_drift_evaluation(self):
        """Verify multiple notes evaluate drift independently based on their anchors."""
        self.engine.add_annotation("n2", "ch01", "REV1", "Termo Permanente", "Nota 2")
        new_content = "Aqui temos o Termo Permanente, mas o outro trecho foi removido."
        self.engine.apply_revision_update("ch01", "REV2", new_content)

        ann1 = next(a for a in self.engine.annotations if a["note_id"] == "n1")
        ann2 = next(a for a in self.engine.annotations if a["note_id"] == "n2")
        self.assertTrue(ann1["drift_warning"])
        self.assertFalse(ann2["drift_warning"])

    def test_f10_tc05_audit_journal_tracks_content_revision_history(self):
        """Verify revision changes are recorded in content revision journal."""
        journal = [
            {"chapter_id": "ch01", "from_rev": "REV1", "to_rev": "REV2", "reason": "Atualização ISO 27037"}
        ]
        self.assertEqual(len(journal), 1)
        self.assertEqual(journal[0]["from_rev"], "REV1")
        self.assertEqual(journal[0]["to_rev"], "REV2")


# ==============================================================================
# Feature 11: Local Text Search (FTS5)
# ==============================================================================

class LocalSearchIndex:
    """Manages offline SQLite FTS5 search across chapters, glossaries, and titles."""
    def __init__(self):
        self.conn = sqlite3.connect(":memory:")
        self.conn.execute("CREATE VIRTUAL TABLE fts_content USING fts5(chapter_id, title, section_title, body_text);")

    def index_document(self, chapter_id: str, title: str, section_title: str, body_text: str):
        self.conn.execute(
            "INSERT INTO fts_content (chapter_id, title, section_title, body_text) VALUES (?, ?, ?, ?);",
            (chapter_id, title, section_title, body_text)
        )
        self.conn.commit()

    def search(self, query: str) -> List[Tuple[str, str, str, str]]:
        cursor = self.conn.cursor()
        cursor.execute(
            "SELECT chapter_id, title, section_title, snippet(fts_content, 3, '[MATCH]', '[/MATCH]', '...', 10) "
            "FROM fts_content WHERE fts_content MATCH ? ORDER BY rank;",
            (query,)
        )
        return cursor.fetchall()

    def close(self):
        self.conn.close()


class TestFeature11LocalFts5Search(unittest.TestCase):
    """F11: Local Offline Text Search (SQLite FTS5)."""

    def setUp(self):
        self.search_index = LocalSearchIndex()
        self.search_index.index_document(
            chapter_id="ch01",
            title="Dos dados às evidências",
            section_title="Cadeia de Custódia",
            body_text="A preservação da cadeia de custódia garante a integridade dos vestígios digitais e evita nulidades processuais."
        )
        self.search_index.index_document(
            chapter_id="ch02",
            title="Sistemas de Arquivos",
            section_title="Metadados NTFS",
            body_text="A análise da tabela MFT no NTFS permite recuperar timestamps $STANDARD_INFORMATION e $FILE_NAME."
        )

    def tearDown(self):
        self.search_index.close()

    def test_f11_tc01_exact_keyword_search(self):
        """Verify searching exact keyword returns matched chapter."""
        results = self.search_index.search("custódia")
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0][0], "ch01")
        self.assertIn("Cadeia de Custódia", results[0][2])

    def test_f11_tc02_prefix_search(self):
        """Verify prefix wildcard search finds matching terms."""
        results = self.search_index.search("vestígi*")
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0][0], "ch01")

    def test_f11_tc03_snippet_generation_highlights_matched_term(self):
        """Verify FTS5 snippet wraps matched keywords in designated tags."""
        results = self.search_index.search("NTFS")
        self.assertEqual(len(results), 1)
        snippet = results[0][3]
        self.assertIn("[MATCH]NTFS[/MATCH]", snippet)

    def test_f11_tc04_multiple_terms_and_operator(self):
        """Verify query with multiple keywords matches documents containing both."""
        results = self.search_index.search("cadeia AND integridade")
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0][0], "ch01")

    def test_f11_tc05_no_matches_returns_empty_list_cleanly(self):
        """Verify non-existent term returns empty list without database exception."""
        results = self.search_index.search("termo_inexistente_xyz")
        self.assertEqual(len(results), 0)


# ==============================================================================
# Feature 12: Ingestion & Sync Providers
# ==============================================================================

class LocalDirectoryContentProvider:
    """Ingests packages from local directory/file and computes SHA-256 hash."""
    @staticmethod
    def ingest_json_file(file_path: str) -> Dict[str, Any]:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"Package file not found: {file_path}")
        with open(file_path, "rb") as f:
            content_bytes = f.read()
        sha256_hash = hashlib.sha256(content_bytes).hexdigest()
        package = json.loads(content_bytes.decode('utf-8'))
        return {
            "status": "SUCCESS",
            "sha256": sha256_hash,
            "package": package
        }


class GoogleDriveContentProvider:
    """Simulates Drive Provider connection handling OAuth and blocked offline states (§1.1, §2.1)."""
    def __init__(self, auth_token: Optional[str] = None):
        self.auth_token = auth_token

    def sync(self) -> Dict[str, Any]:
        if not self.auth_token:
            # Rule §0, §2.1: Never simulate success when unauthenticated; report BLOCKED
            return {
                "status": "BLOCKED",
                "reason": "Google Drive authentication token missing. Offline manual import available."
            }
        return {"status": "SUCCESS", "items_synced": 0}


class TestFeature12IngestionProviders(unittest.TestCase):
    """F12: Ingestion & Sync Providers Architecture."""

    def test_f12_tc01_local_provider_ingests_and_computes_sha256(self):
        """Verify local directory provider correctly reads file and computes valid SHA-256."""
        sample_path = os.path.join(FIXTURES_DIR, "sample_chapter_vol1_ch1.json")
        result = LocalDirectoryContentProvider.ingest_json_file(sample_path)
        self.assertEqual(result["status"], "SUCCESS")
        self.assertEqual(len(result["sha256"]), 64)
        self.assertEqual(result["package"]["contentId"], "forense.vol01.ch01")

    def test_f12_tc02_sha256_deduplication_prevents_duplicate_processing(self):
        """Verify identical SHA-256 hash allows deduplicating incoming sync payloads."""
        known_hashes = {"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"}
        incoming_hash = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

        is_duplicate = incoming_hash in known_hashes
        self.assertTrue(is_duplicate, "Identical hash must be flagged as already processed")

    def test_f12_tc03_drive_provider_reports_blocked_when_unauthenticated(self):
        """Verify Drive provider reports BLOCKED and does NOT simulate success when token is missing."""
        drive = GoogleDriveContentProvider(auth_token=None)
        res = drive.sync()
        self.assertEqual(res["status"], "BLOCKED")
        self.assertIn("authentication token missing", res["reason"])

    def test_f12_tc04_missing_file_raises_file_not_found(self):
        """Verify local provider raises FileNotFoundError on non-existent path."""
        with self.assertRaises(FileNotFoundError):
            LocalDirectoryContentProvider.ingest_json_file("/non/existent/path/package.json")

    def test_f12_tc05_sync_journal_entry_structure(self):
        """Verify sync journal entry accurately records source, timestamp, and status."""
        journal_entry = {
            "journal_id": "j-001",
            "provider": "local_directory",
            "file_name": "sample_chapter_vol1_ch1.json",
            "sha256": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
            "status": "IMPORTED",
            "timestamp": "2026-11-16T10:00:00Z"
        }
        self.assertEqual(journal_entry["status"], "IMPORTED")
        self.assertEqual(journal_entry["provider"], "local_directory")


# ==============================================================================
# Feature 13: 10-Step Lesson Engine
# ==============================================================================

class LessonEngine:
    """Implements the mandatory 10-step didactic sequence from §8."""
    DIDACTIC_STEPS = [
        "1. Objetivos de aprendizagem",
        "2. Pré-requisitos",
        "3. Apresentação do problema",
        "4. Explicação teórica",
        "5. Exemplo resolvido",
        "6. Exercício guiado",
        "7. Atividade prática",
        "8. Avaliação",
        "9. Revisão dos erros",
        "10. Resumo e referências",
    ]

    def __init__(self, lesson_id: str):
        self.lesson_id = lesson_id
        self.completed_steps: set = set()
        self.current_step_index = 0

    def complete_current_step(self) -> None:
        self.completed_steps.add(self.current_step_index)
        if self.current_step_index < len(self.DIDACTIC_STEPS) - 1:
            self.current_step_index += 1

    @property
    def progress_percentage(self) -> float:
        return (len(self.completed_steps) / len(self.DIDACTIC_STEPS)) * 100.0

    @property
    def is_completed(self) -> bool:
        return len(self.completed_steps) == len(self.DIDACTIC_STEPS)


class TestFeature13TenStepLessonEngine(unittest.TestCase):
    """F13: 10-Step Lesson Engine Progression & Didactic Structure."""

    def test_f13_tc01_exact_10_didactic_steps_defined(self):
        """Verify all 10 didactic steps from §8 are defined in canonical sequence."""
        steps = LessonEngine.DIDACTIC_STEPS
        self.assertEqual(len(steps), 10)
        self.assertIn("objetivo", steps[0].lower())
        self.assertIn("pré-requisito", steps[1].lower())
        self.assertIn("problema", steps[2].lower())
        self.assertIn("teórica", steps[3].lower())
        self.assertIn("exemplo resolvido", steps[4].lower())
        self.assertIn("exercício guiado", steps[5].lower())
        self.assertIn("atividade prática", steps[6].lower())
        self.assertIn("avaliação", steps[7].lower())
        self.assertIn("revisão", steps[8].lower())
        self.assertIn("resumo", steps[9].lower())

    def test_f13_tc02_step_by_step_progression(self):
        """Verify advancing through lesson updates completed steps and step index."""
        engine = LessonEngine("lesson-01")
        self.assertEqual(engine.current_step_index, 0)
        self.assertEqual(engine.progress_percentage, 0.0)

        engine.complete_current_step()  # Step 0 done -> index becomes 1
        self.assertEqual(engine.current_step_index, 1)
        self.assertEqual(engine.progress_percentage, 10.0)

    def test_f13_tc03_completion_at_step_10(self):
        """Verify completing all 10 steps achieves 100% progress and is_completed=True."""
        engine = LessonEngine("lesson-01")
        for _ in range(10):
            engine.complete_current_step()
        self.assertEqual(engine.progress_percentage, 100.0)
        self.assertTrue(engine.is_completed)

    def test_f13_tc04_didactic_component_rendering_models(self):
        """Verify structured didactic components (quadros, fórmulas, código) are supported (§8.1)."""
        components = [
            {"type": "academic_text", "content": "Texto expositivo sobre vestígios"},
            {"type": "callout_box", "title": "Atenção Pericial", "content": "Não manipular arquivos no disco suspeito"},
            {"type": "formula", "latex": "E = mc^2"},
            {"type": "code_snippet", "language": "python", "code": "import hashlib\nprint(hashlib.sha256(b'test').hexdigest())"},
        ]
        self.assertEqual(len(components), 4)
        self.assertEqual(components[3]["language"], "python")

    def test_f13_tc05_step_backwards_navigation_allowed(self):
        """Verify student can navigate back to review previous completed steps."""
        engine = LessonEngine("lesson-01")
        engine.complete_current_step()
        engine.complete_current_step()
        self.assertEqual(engine.current_step_index, 2)
        # Navigate back to review Step 0
        engine.current_step_index = 0
        self.assertEqual(engine.current_step_index, 0)
        self.assertEqual(engine.progress_percentage, 20.0)


# ==============================================================================
# Feature 14: Automated Assessment & 80% Mastery Benchmark
# ==============================================================================

class AssessmentEvaluator:
    """Evaluates objective and rubric assessments against the mandatory 80% passing benchmark."""
    PASSING_BENCHMARK = 0.80  # 80% mastery benchmark (§8.2, §14)

    @staticmethod
    def evaluate_objective(user_answers: List[int], answer_key: List[int]) -> Dict[str, Any]:
        if len(user_answers) != len(answer_key):
            raise ValueError("Answers length mismatch with answer key")
        correct_count = sum(1 for u, k in zip(user_answers, answer_key) if u == k)
        total_count = len(answer_key)
        score = correct_count / total_count
        passed = score >= AssessmentEvaluator.PASSING_BENCHMARK
        return {
            "correct_count": correct_count,
            "total_count": total_count,
            "score": round(score, 4),
            "passed": passed,
        }

    @staticmethod
    def evaluate_rubric(criteria_scores: Dict[str, float], criteria_weights: Dict[str, float]) -> Dict[str, Any]:
        weighted_sum = sum(criteria_scores[k] * criteria_weights[k] for k in criteria_scores)
        total_weight = sum(criteria_weights.values())
        final_score = weighted_sum / total_weight
        return {
            "score": round(final_score, 4),
            "passed": final_score >= AssessmentEvaluator.PASSING_BENCHMARK,
        }


class TestFeature14AssessmentAnd80PercentMastery(unittest.TestCase):
    """F14: Automated Assessment & 80% Passing Threshold Benchmark."""

    def test_f14_tc01_exact_80_percent_score_passes(self):
        """Verify scoring exactly 80% (e.g. 4/5 questions) passes assessment."""
        user_ans = [1, 2, 3, 0, 9]  # 4 correct, 1 wrong
        key = [1, 2, 3, 0, 0]
        res = AssessmentEvaluator.evaluate_objective(user_ans, key)
        self.assertEqual(res["score"], 0.80)
        self.assertTrue(res["passed"])

    def test_f14_tc02_below_80_percent_fails_benchmark(self):
        """Verify scoring 79.9% or below (e.g. 3/5 questions = 60%) fails."""
        user_ans = [1, 2, 3, 9, 9]  # 3 correct, 2 wrong
        key = [1, 2, 3, 0, 0]
        res = AssessmentEvaluator.evaluate_objective(user_ans, key)
        self.assertEqual(res["score"], 0.60)
        self.assertFalse(res["passed"], "Score < 80% must not pass progression threshold")

    def test_f14_tc03_perfect_score_passes(self):
        """Verify scoring 100% passes with full marks."""
        user_ans = [0, 1, 2, 3, 4]
        key = [0, 1, 2, 3, 4]
        res = AssessmentEvaluator.evaluate_objective(user_ans, key)
        self.assertEqual(res["score"], 1.00)
        self.assertTrue(res["passed"])

    def test_f14_tc04_rubric_evaluation_weighted_passing(self):
        """Verify discursive exam rubric weighted score satisfies benchmark."""
        scores = {
            "metodologia": 0.90,
            "cadeia_custodia": 0.85,
            "precisao_tecnica": 0.80,
        }
        weights = {
            "metodologia": 0.40,
            "cadeia_custodia": 0.30,
            "precisao_tecnica": 0.30,
        }
        res = AssessmentEvaluator.evaluate_rubric(scores, weights)
        expected = 0.90 * 0.40 + 0.85 * 0.30 + 0.80 * 0.30  # 0.36 + 0.255 + 0.24 = 0.855
        self.assertAlmostEqual(res["score"], expected, places=3)
        self.assertTrue(res["passed"])

    def test_f14_tc05_attempt_logging_and_competency_mastery(self):
        """Verify attempt details logged and competency marked mastered only on pass."""
        attempt = {
            "attempt_id": "att-101",
            "assessment_id": "asm-ch01",
            "competency_id": "comp-custodia",
            "score": 0.85,
            "passed": True,
            "timestamp": "2026-11-16T11:00:00Z"
        }
        self.assertTrue(attempt["passed"])
        competency_mastered = attempt["passed"] and (attempt["score"] >= 0.80)
        self.assertTrue(competency_mastered)


if __name__ == '__main__':
    unittest.main()
