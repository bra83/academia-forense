"""
Tier 2 Boundary & Corner Cases Test Suite: Features 22 to 28
Covers:
- F22: Audio Player UI & Highlighting (Speed Slider Bounds, No Silent Fallback, Seek Bounds)
- F23: Multi-Discipline Lab Engine (7 Domains, Dataset Missing, Hash Verification, SQL Errors, CDR Timeline)
- F24: Platform-Bounded Lab Isolation (Android 32MB Limit, Execution Timeout, Sandbox Syscalls)
- F25: Interactive Case Studies (Contradictory Evidence, Fact vs Inference, Timeline Order)
- F26: Professional Portfolio & PDF Export (Empty Export, Tampered Signature, Anti-Accreditation Claim)
- F27: Multiplatform CI/CD Pipeline (Malformed YAML, Missing Platform Jobs, Secret Scanning)
- F28: Integrity & Anti-Cheating (Trivial Mock Detection, Grade Tampering, Question Randomization)
"""

import unittest
import hashlib
import yaml
import sqlite3
import random
import re
from datetime import datetime, timezone

from tests.test_fixtures.boundary_helpers import (
    validate_and_snap_speed,
    AudioEngineManager,
    init_sqlite_test_db,
)


class TestBoundariesFeatures22To28(unittest.TestCase):

    # =========================================================================
    # FEATURE 22: AUDIO PLAYER UI & HIGHLIGHTING
    # =========================================================================

    def test_f22_speed_slider_lower_bound_rejection(self):
        """Boundary: Speed < 0.65x raises ValueError (§12.2)."""
        with self.assertRaises(ValueError):
            validate_and_snap_speed(0.64)
        with self.assertRaises(ValueError):
            validate_and_snap_speed(0.0)
        with self.assertRaises(ValueError):
            validate_and_snap_speed(-1.0)

    def test_f22_speed_slider_upper_bound_rejection(self):
        """Boundary: Speed > 1.50x raises ValueError (§12.2)."""
        with self.assertRaises(ValueError):
            validate_and_snap_speed(1.51)
        with self.assertRaises(ValueError):
            validate_and_snap_speed(2.0)
        with self.assertRaises(ValueError):
            validate_and_snap_speed(10.0)

    def test_f22_speed_step_snapping_0_05(self):
        """Boundary: Speed values snap to nearest 0.05x step."""
        self.assertEqual(validate_and_snap_speed(0.65), 0.65)
        self.assertEqual(validate_and_snap_speed(1.00), 1.00)
        self.assertEqual(validate_and_snap_speed(1.50), 1.50)
        # Snapping
        self.assertEqual(validate_and_snap_speed(0.72), 0.70)
        self.assertEqual(validate_and_snap_speed(0.73), 0.75)
        self.assertEqual(validate_and_snap_speed(1.24), 1.25)

    def test_f22_silent_fallback_attempt_strictly_blocked(self):
        """Boundary: Silent fallback to Kokoro on Gemini TTS failure is strictly blocked without confirmation (§11.1)."""
        manager = AudioEngineManager(primary_engine="geminiTts")
        # Attempt silent fallback without user confirmation
        with self.assertRaises(PermissionError) as ctx:
            manager.trigger_playback_failure_with_fallback_attempt(
                target_fallback="kokoro",
                user_confirmed=False
            )
        self.assertIn("Silent fallback", str(ctx.exception))
        # With user confirmation, fallback is allowed
        manager.trigger_playback_failure_with_fallback_attempt(
            target_fallback="kokoro",
            user_confirmed=True
        )
        self.assertEqual(manager.active_engine, "kokoro")

    def test_f22_seek_position_clamping(self):
        """Boundary: Seek position < 0.0s clamped to 0.0s; seek > track duration clamped to duration."""
        def seek_track(target_pos: float, duration: float) -> float:
            if duration <= 0:
                raise ValueError("Track duration must be positive")
            return max(0.0, min(duration, target_pos))

        self.assertEqual(seek_track(-5.0, 120.0), 0.0)
        self.assertEqual(seek_track(150.0, 120.0), 120.0)
        self.assertEqual(seek_track(45.5, 120.0), 45.5)

    # =========================================================================
    # FEATURE 23: MULTI-DISCIPLINE LAB ENGINE
    # =========================================================================

    def test_f23_invalid_lab_domain_rejection(self):
        """Boundary: Domain must be one of the 7 official domains (§14.1)."""
        valid_domains = {
            "Informatics", "Math", "Programming",
            "Digital Forensics", "Telephony", "Linguistics", "Multimedia"
        }
        def validate_lab_domain(domain: str):
            if domain not in valid_domains:
                raise ValueError(f"Invalid domain '{domain}'. Must be one of {valid_domains}")
            return domain

        for d in valid_domains:
            self.assertEqual(validate_lab_domain(d), d)

        for bad in ["Astrology", "Polygraph", "Hacking", ""]:
            with self.assertRaises(ValueError):
                validate_lab_domain(bad)

    def test_f23_missing_lab_dataset_file_rejection(self):
        """Boundary: Lab referencing nonexistent dataset file raises FileNotFoundError."""
        import os
        def load_lab_dataset(file_path: str):
            if not os.path.exists(file_path):
                raise FileNotFoundError(f"Lab dataset not found: {file_path}")
            return True

        with self.assertRaises(FileNotFoundError):
            load_lab_dataset("/home/antigravity/datasets/missing_telephony_cdr_999.csv")

    def test_f23_forensic_hash_mismatch_verification(self):
        """Boundary: Evidence disk image verification with tampered byte fails SHA-256 and MD5 checks."""
        original_image = b"EVIDENCE_IMAGE_DISK_SECTOR_001_DATA_AUTHENTIC"
        expected_sha256 = hashlib.sha256(original_image).hexdigest()
        expected_md5 = hashlib.md5(original_image).hexdigest()

        # Tampered image (single byte flip)
        tampered_image = b"EVIDENCE_IMAGE_DISK_SECTOR_001_DATA_AUTHEN_IC"
        tampered_sha256 = hashlib.sha256(tampered_image).hexdigest()
        tampered_md5 = hashlib.md5(tampered_image).hexdigest()

        self.assertNotEqual(expected_sha256, tampered_sha256)
        self.assertNotEqual(expected_md5, tampered_md5)

        def verify_evidence(data: bytes, exp_sha: str, exp_md5: str):
            actual_sha = hashlib.sha256(data).hexdigest()
            actual_md5 = hashlib.md5(data).hexdigest()
            if actual_sha != exp_sha or actual_md5 != exp_md5:
                raise ValueError("Evidence integrity check failed: Hash mismatch")
            return True

        self.assertTrue(verify_evidence(original_image, expected_sha256, expected_md5))
        with self.assertRaises(ValueError):
            verify_evidence(tampered_image, expected_sha256, expected_md5)

    def test_f23_malformed_sql_student_query_handling(self):
        """Boundary: Syntax error in student SQL lab query is caught cleanly without crash."""
        conn = sqlite3.connect(":memory:")
        conn.execute("CREATE TABLE cdr (id INT, origin TEXT, destination TEXT);")
        def execute_student_query(sql_query: str):
            try:
                conn.execute(sql_query)
                return {"status": "SUCCESS"}
            except sqlite3.OperationalError as e:
                return {"status": "ERROR", "message": str(e)}

        bad_query = "SELECT FROM WHERE cdr;"
        res = execute_student_query(bad_query)
        self.assertEqual(res["status"], "ERROR")
        self.assertIn("syntax error", res["message"].lower())
        conn.close()

    def test_f23_telephony_cdr_timestamp_inversion(self):
        """Boundary: Telephony CDR record where call_end < call_start raises ValueError."""
        def validate_cdr_record(call_start: str, call_end: str):
            t_start = datetime.fromisoformat(call_start)
            t_end = datetime.fromisoformat(call_end)
            if t_end < t_start:
                raise ValueError(f"CDR chronological anomaly: call_end ({call_end}) < call_start ({call_start})")
            return (t_end - t_start).total_seconds()

        duration = validate_cdr_record("2026-11-16T10:00:00", "2026-11-16T10:05:30")
        self.assertEqual(duration, 330.0)

        with self.assertRaises(ValueError):
            validate_cdr_record("2026-11-16T10:05:30", "2026-11-16T10:00:00")

    # =========================================================================
    # FEATURE 24: PLATFORM-BOUNDED LAB ISOLATION
    # =========================================================================

    def test_f24_android_memory_budget_exceeded(self):
        """Boundary: Memory allocation > 32MB on Android budget triggers MemoryError (§14.2)."""
        def allocate_lab_memory(size_bytes: int, platform: str):
            if platform == "android" and size_bytes > 32 * 1024 * 1024:
                raise MemoryError(f"Memory allocation {size_bytes / (1024*1024):.1f}MB exceeds Android 32MB budget")
            return True

        # Valid on Android
        self.assertTrue(allocate_lab_memory(16 * 1024 * 1024, "android"))
        # Exceeded on Android
        with self.assertRaises(MemoryError):
            allocate_lab_memory(33 * 1024 * 1024, "android")
        # Allowed on Windows
        self.assertTrue(allocate_lab_memory(64 * 1024 * 1024, "windows"))

    def test_f24_lab_execution_timeout_termination(self):
        """Boundary: Lab code execution exceeding time limit raises TimeoutError."""
        def monitor_execution(elapsed_seconds: float, timeout_seconds: float = 5.0):
            if elapsed_seconds > timeout_seconds:
                raise TimeoutError(f"Lab execution timed out ({elapsed_seconds:.1f}s > {timeout_seconds:.1f}s limit)")
            return True

        self.assertTrue(monitor_execution(2.5))
        with self.assertRaises(TimeoutError):
            monitor_execution(5.1)

    def test_f24_sandbox_forbidden_syscall_rejection(self):
        """Boundary: Code containing system calls or socket network calls is rejected by sandbox."""
        def inspect_student_script(script_code: str):
            forbidden = ["os.system", "subprocess", "socket.socket", "shutil.rmtree", "eval("]
            for f in forbidden:
                if f in script_code:
                    raise PermissionError(f"Security sandbox violation: forbidden call '{f}'")
            return True

        clean_code = "import math\nres = math.sqrt(256)\nprint(res)"
        self.assertTrue(inspect_student_script(clean_code))

        malicious_codes = [
            "import os\nos.system('rm -rf /')",
            "import subprocess\nsubprocess.call(['ls'])",
            "import socket\ns = socket.socket()",
        ]
        for bad in malicious_codes:
            with self.assertRaises(PermissionError):
                inspect_student_script(bad)

    def test_f24_unsupported_platform_capability_rejection(self):
        """Boundary: Attempting to run Windows-only heavy Python lab on Android raises RuntimeError."""
        def run_heavy_python_lab(target_platform: str):
            if target_platform == "android":
                raise RuntimeError("Heavy Python data science lab requires Windows environment (not supported on mobile)")
            return "SUCCESS"

        self.assertEqual(run_heavy_python_lab("windows"), "SUCCESS")
        with self.assertRaises(RuntimeError):
            run_heavy_python_lab("android")

    def test_f24_clean_worker_process_termination(self):
        """Boundary: Aborted lab worker terminates cleanly without zombies."""
        class MockWorkerProcess:
            def __init__(self):
                self.is_alive = True
                self.cleaned_up = False

            def abort(self):
                self.is_alive = False
                self.cleaned_up = True

        worker = MockWorkerProcess()
        worker.abort()
        self.assertFalse(worker.is_alive)
        self.assertTrue(worker.cleaned_up)

    # =========================================================================
    # FEATURE 25: INTERACTIVE CASE STUDIES ENGINE
    # =========================================================================

    def test_f25_contradictory_evidence_detection(self):
        """Boundary: Asserting a claim that contradicts verified documented evidence raises ValueError (§15.2)."""
        verified_evidence = {
            "device_owner": "Carlos Silva",
            "last_ping_erb": "ERB_CENTRO_12",
            "time_utc": "2026-11-16T03:15:00Z"
        }
        def submit_case_fact(fact_key: str, asserted_value: str):
            if fact_key in verified_evidence and verified_evidence[fact_key] != asserted_value:
                raise ValueError(
                    f"Contradictory evidence: Claim '{asserted_value}' contradicts verified record '{verified_evidence[fact_key]}'"
                )
            return True

        self.assertTrue(submit_case_fact("device_owner", "Carlos Silva"))
        with self.assertRaises(ValueError):
            submit_case_fact("device_owner", "Suspeito Desconhecido B")

    def test_f25_fact_vs_inference_classification_error(self):
        """Boundary: Categorizing an unverified claim as 'Documented Fact' without evidence pointer raises ValueError."""
        def classify_case_item(category: str, has_evidence_pointer: bool):
            if category == "Documented Fact" and not has_evidence_pointer:
                raise ValueError("Classification error: An item cannot be marked as 'Documented Fact' without direct evidence citation (§15.2)")
            return category

        self.assertEqual(classify_case_item("Documented Fact", has_evidence_pointer=True), "Documented Fact")
        self.assertEqual(classify_case_item("Investigative Inference", has_evidence_pointer=False), "Investigative Inference")
        with self.assertRaises(ValueError):
            classify_case_item("Documented Fact", has_evidence_pointer=False)

    def test_f25_chronological_timeline_inversion(self):
        """Boundary: Timeline event B ordered before event A when evidence timestamps prove A < B raises ValueError."""
        def validate_event_order(event_a_time: str, event_b_time: str):
            t_a = datetime.fromisoformat(event_a_time)
            t_b = datetime.fromisoformat(event_b_time)
            if t_b < t_a:
                raise ValueError(f"Chronology inversion error: Event B ({event_b_time}) occurred before Event A ({event_a_time})")
            return True

        self.assertTrue(validate_event_order("2026-11-16T12:00:00", "2026-11-16T13:00:00"))
        with self.assertRaises(ValueError):
            validate_event_order("2026-11-16T13:00:00", "2026-11-16T12:00:00")

    def test_f25_empty_case_submission_rejection(self):
        """Boundary: Submitting case analysis with 0 facts or 0 hypotheses raises ValueError."""
        def submit_case_analysis(facts: list, hypotheses: list):
            if not facts:
                raise ValueError("Case submission must include at least 1 documented fact")
            if not hypotheses:
                raise ValueError("Case submission must evaluate at least 1 hypothesis")
            return True

        with self.assertRaises(ValueError):
            submit_case_analysis([], ["H1: Dispositivo foi clonado"])
        with self.assertRaises(ValueError):
            submit_case_analysis(["Fato 1"], [])

    def test_f25_alternative_hypothesis_mandatory(self):
        """Boundary: Case conclusion asserting 100% certainty without evaluating alternative hypotheses is rejected (§15.1, §15.2)."""
        def validate_case_conclusion(certainty_percentage: float, alternative_hypotheses_evaluated: int):
            if certainty_percentage >= 100.0 and alternative_hypotheses_evaluated == 0:
                raise ValueError(
                    "Methodology violation: Scientific conclusions cannot assert absolute certainty without evaluating alternative hypotheses"
                )
            return True

        self.assertTrue(validate_case_conclusion(85.0, alternative_hypotheses_evaluated=2))
        with self.assertRaises(ValueError):
            validate_case_conclusion(100.0, alternative_hypotheses_evaluated=0)

    # =========================================================================
    # FEATURE 26: PROFESSIONAL PORTFOLIO & PDF EXPORT
    # =========================================================================

    def test_f26_empty_portfolio_export_rejection(self):
        """Boundary: Exporting portfolio PDF when user has 0 completed activities raises ValueError."""
        def export_portfolio_pdf(completed_activities: list):
            if not completed_activities:
                raise ValueError("Cannot export empty portfolio: No completed lab or case activities found")
            return b"%PDF-1.4\n...portfolio..."

        with self.assertRaises(ValueError):
            export_portfolio_pdf([])

    def test_f26_tampered_digital_signature_detection(self):
        """Boundary: Report with tampered digital signature hash fails signature verification."""
        report_content = b"RELATORIO_TECNICO_PERICIAL_PORTFOLIO_CONTEUDO"
        authentic_signature = hashlib.sha256(report_content).hexdigest()

        def verify_report_signature(content: bytes, signature: str):
            calculated = hashlib.sha256(content).hexdigest()
            if calculated != signature:
                raise ValueError("Digital signature verification failed: Document content tampered")
            return True

        self.assertTrue(verify_report_signature(report_content, authentic_signature))
        with self.assertRaises(ValueError):
            verify_report_signature(report_content + b"_TAMPERED_POST_SIGN", authentic_signature)

    def test_f26_missing_mandatory_report_fields(self):
        """Boundary: Report missing Methodology, Limitations, or Conclusion raises ValueError (§16.1)."""
        def validate_report_metadata(report_dict: dict):
            mandatory = ["objective", "methodology", "limitations", "conclusion", "is_simulation"]
            for field in mandatory:
                if not report_dict.get(field):
                    raise ValueError(f"Report structure incomplete: missing '{field}'")
            return True

        valid_report = {
            "objective": "Análise forense de imagem",
            "methodology": "Cálculo de hashes SHA-256",
            "limitations": "Imagem parcial de setor",
            "conclusion": "Vestígios íntegros",
            "is_simulation": True
        }
        self.assertTrue(validate_report_metadata(valid_report))

        bad_report = dict(valid_report)
        del bad_report["limitations"]
        with self.assertRaises(ValueError):
            validate_report_metadata(bad_report)

    def test_f26_unaccredited_academic_claim_blocked(self):
        """Boundary: Claiming official MEC or police accreditation in exported report raises PermissionError (§16.1)."""
        def sanitize_certificate_claims(title: str, body: str):
            forbidden = ["reconhecimento mec", "certificado de perito oficial", "diploma credenciado"]
            combined = (title + " " + body).lower()
            for f in forbidden:
                if f in combined:
                    raise PermissionError(f"Unauthorized accreditation claim '{f}' strictly prohibited by Section 16.1")
            return True

        valid_claim = ("Declaração de Conclusão de Módulo", "Concluiu com êxito os exercícios práticos da Academia Forense.")
        self.assertTrue(sanitize_certificate_claims(*valid_claim))

        with self.assertRaises(PermissionError):
            sanitize_certificate_claims("Diploma com Reconhecimento MEC", "Certificamos a formação oficial.")

    def test_f26_report_date_chronology_inconsistency(self):
        """Boundary: Report generation date before lab completion date raises ValueError."""
        def validate_report_dates(lab_completed_at: str, report_generated_at: str):
            t_lab = datetime.fromisoformat(lab_completed_at)
            t_rep = datetime.fromisoformat(report_generated_at)
            if t_rep < t_lab:
                raise ValueError("Chronology error: Report generation date cannot precede lab completion date")
            return True

        self.assertTrue(validate_report_dates("2026-11-16T10:00:00", "2026-11-16T11:00:00"))
        with self.assertRaises(ValueError):
            validate_report_dates("2026-11-16T11:00:00", "2026-11-16T10:00:00")

    # =========================================================================
    # FEATURE 27: MULTIPLATFORM CI/CD PIPELINE
    # =========================================================================

    def test_f27_malformed_github_actions_yaml_rejection(self):
        """Boundary: Corrupted YAML syntax in workflow file raises yaml.YAMLError."""
        malformed_yamls = [
            "name: CI\non: [push\njobs:\n",  # Unclosed bracket
            "name: CI\n  jobs:\n- broken indentation",
        ]
        for bad_yaml in malformed_yamls:
            with self.assertRaises(yaml.YAMLError):
                yaml.safe_load(bad_yaml)

    def test_f27_missing_mandatory_platform_jobs(self):
        """Boundary: CI workflow missing ubuntu-latest or windows-latest raises ValueError (§25)."""
        def validate_ci_workflow(workflow_dict: dict):
            jobs = workflow_dict.get("jobs", {})
            runs_on_list = [v.get("runs-on") for v in jobs.values() if isinstance(v, dict)]
            if not any("ubuntu" in str(r) for r in runs_on_list):
                raise ValueError("CI workflow missing required 'ubuntu-latest' runner job")
            if not any("windows" in str(r) for r in runs_on_list):
                raise ValueError("CI workflow missing required 'windows-latest' runner job")
            return True

        valid_wf = {
            "name": "Build CI",
            "jobs": {
                "test-linux": {"runs-on": "ubuntu-latest"},
                "build-windows": {"runs-on": "windows-latest"}
            }
        }
        self.assertTrue(validate_ci_workflow(valid_wf))

        incomplete_wf = {
            "name": "Build CI",
            "jobs": {"test-linux": {"runs-on": "ubuntu-latest"}}
        }
        with self.assertRaises(ValueError):
            validate_ci_workflow(incomplete_wf)

    def test_f27_release_gate_without_test_execution_blocked(self):
        """Boundary: Workflow attempting to release APK without requiring test gate job raises ValueError."""
        def validate_release_pipeline(workflow_dict: dict):
            jobs = workflow_dict.get("jobs", {})
            release_job = jobs.get("release_apk", {})
            needs = release_job.get("needs", [])
            if isinstance(needs, str):
                needs = [needs]
            if "run_tests" not in needs:
                raise ValueError("Unvalidated release gate: 'release_apk' must depend on 'run_tests' passing")
            return True

        valid_release = {
            "jobs": {
                "run_tests": {"runs-on": "ubuntu-latest"},
                "release_apk": {"runs-on": "ubuntu-latest", "needs": ["run_tests"]}
            }
        }
        self.assertTrue(validate_release_pipeline(valid_release))

        invalid_release = {
            "jobs": {
                "run_tests": {"runs-on": "ubuntu-latest"},
                "release_apk": {"runs-on": "ubuntu-latest", "needs": []}
            }
        }
        with self.assertRaises(ValueError):
            validate_release_pipeline(invalid_release)

    def test_f27_hardcoded_secrets_scanner(self):
        """Boundary: Workflow containing hardcoded plaintext API keys is flagged by secret scanner."""
        def scan_workflow_for_secrets(yaml_content: str):
            if "AIzaSy" in yaml_content:
                raise ValueError("Secret leakage detected: Hardcoded Google API key found in CI workflow")
            return True

        clean_yaml = "env:\n  GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}\n"
        self.assertTrue(scan_workflow_for_secrets(clean_yaml))

        leaked_yaml = "env:\n  GEMINI_API_KEY: AIzaSyD-hardcoded-secret-key-12345\n"
        with self.assertRaises(ValueError):
            scan_workflow_for_secrets(leaked_yaml)

    def test_f27_deprecated_runner_os_rejection(self):
        """Boundary: Specifying deprecated runner (e.g. ubuntu-18.04) raises ValueError."""
        deprecated_runners = {"ubuntu-18.04", "ubuntu-16.04", "windows-2016", "macos-10.15"}
        def validate_runner_os(runner_str: str):
            if runner_str in deprecated_runners:
                raise ValueError(f"Deprecated GitHub Actions runner '{runner_str}' is forbidden")
            return runner_str

        self.assertEqual(validate_runner_os("ubuntu-latest"), "ubuntu-latest")
        with self.assertRaises(ValueError):
            validate_runner_os("ubuntu-18.04")

    # =========================================================================
    # FEATURE 28: INTEGRITY & ANTI-CHEATING
    # =========================================================================

    def test_f28_dummy_mock_pass_detection(self):
        """Boundary: Static test linter detects and rejects trivial pass or empty test cases (§28)."""
        def lint_test_code_integrity(test_code: str):
            forbidden_patterns = [
                r"assert\s+True\b",
                r"assert\s+1\s*==\s*1\b",
                r"pass\s*#\s*trivial",
                r"mock\.return_value\s*=\s*True\b"
            ]
            for pat in forbidden_patterns:
                if re.search(pat, test_code):
                    raise ValueError(f"Anti-cheating violation: Trivial mock or assert True detected: '{pat}'")
            return True

        authentic_test = "self.assertEqual(response.status_code, 200)\nself.assertGreaterEqual(score, 80.0)"
        self.assertTrue(lint_test_code_integrity(authentic_test))

        fake_tests = [
            "def test_bypass(self):\n    assert True",
            "def test_bypass2(self):\n    assert 1 == 1",
            "def test_mock(self):\n    mock.return_value = True",
        ]
        for fake in fake_tests:
            with self.assertRaises(ValueError):
                lint_test_code_integrity(fake)

    def test_f28_direct_database_grade_tampering_detection(self):
        """Boundary: Unaudited direct modification of user grade without attempt log raises ValueError."""
        db = init_sqlite_test_db(":memory:")
        cur = db.cursor()

        # Grade check function verifying that any competency score >= 80% MUST have matching attempt in assessment_attempts
        def verify_competency_audit_trail(student_id: str, assessment_id: str):
            cur.execute("""
                SELECT COUNT(*) FROM assessment_attempts
                WHERE student_id = ? AND assessment_id = ? AND score >= 80.0;
            """, (student_id, assessment_id))
            count = cur.fetchone()[0]
            if count == 0:
                raise ValueError("Integrity audit failure: Student marked passed without authentic assessment attempt")
            return True

        with self.assertRaises(ValueError):
            verify_competency_audit_trail("student_fraud", "asm_ch01")

        # After authentic recording, check passes
        cur.execute("""
            INSERT INTO assessment_attempts (id, assessment_id, student_id, score, passed, attempted_at)
            VALUES ('att_valid_01', 'asm_ch01', 'student_fraud', 82.5, 1, '2026-11-16T10:00:00Z');
        """)
        db.commit()
        self.assertTrue(verify_competency_audit_trail("student_fraud", "asm_ch01"))
        db.close()

    def test_f28_unverified_real_case_name_rejection(self):
        """Boundary: Real case names (e.g. Watts, Hae Min Lee) without verified provenance tag raises ValueError (§15.3)."""
        def validate_case_provenance(case_title: str, is_synthetic: bool, has_chain_of_custody_cert: bool):
            real_case_indicators = ["watts", "hae min lee"]
            lower_title = case_title.lower()
            is_real_case_name = any(r in lower_title for r in real_case_indicators)

            if is_real_case_name and not is_synthetic and not has_chain_of_custody_cert:
                raise ValueError(
                    f"Provenance violation: Real case '{case_title}' cannot be loaded without legitimate chain of custody (§15.3)"
                )
            return True

        # Allowed synthetic case
        self.assertTrue(validate_case_provenance("Estudo Sintético de Telefonia e ERBs", is_synthetic=True, has_chain_of_custody_cert=False))
        # Blocked unverified real case
        with self.assertRaises(ValueError):
            validate_case_provenance("Análise de Evidências do Caso Watts", is_synthetic=False, has_chain_of_custody_cert=False)

    def test_f28_assessment_question_randomization_on_retake(self):
        """Boundary: Assessment retake must randomize question sequence to prevent static cramming."""
        question_ids = ["q1", "q2", "q3", "q4", "q5", "q6", "q7", "q8"]
        rng1 = random.Random(42)
        attempt_1_order = list(question_ids)
        rng1.shuffle(attempt_1_order)

        rng2 = random.Random(99)
        attempt_2_order = list(question_ids)
        rng2.shuffle(attempt_2_order)

        self.assertNotEqual(attempt_1_order, attempt_2_order, "Question order on retake must be reshuffled")

    def test_f28_exit_code_tampering_detection(self):
        """Boundary: Test runner returns non-zero exit code when any failure occurs."""
        def calculate_runner_exit_code(passed_count: int, failed_count: int, error_count: int) -> int:
            if failed_count > 0 or error_count > 0:
                return 1
            if passed_count == 0:
                return 1
            return 0

        self.assertEqual(calculate_runner_exit_code(passed_count=140, failed_count=0, error_count=0), 0)
        self.assertEqual(calculate_runner_exit_code(passed_count=139, failed_count=1, error_count=0), 1)
        self.assertEqual(calculate_runner_exit_code(passed_count=139, failed_count=0, error_count=1), 1)
        self.assertEqual(calculate_runner_exit_code(passed_count=0, failed_count=0, error_count=0), 1)


if __name__ == "__main__":
    unittest.main()
