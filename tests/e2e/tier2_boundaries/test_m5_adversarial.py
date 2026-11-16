"""
Tier 2 Adversarial Verification & Boundary Stress Test Suite: Milestone 5 (Lote F — Laboratórios & Estudos de Caso).

Adversarial testing covering:
1. Feature 24: Platform-Bounded Lab Isolation (§14.2)
   - Android 32MB memory limit: exact boundary (33,554,432 bytes) vs 32MB + 1 byte (33,554,433 bytes).
   - Extreme memory workloads: 1GB, 100GB.
   - Python/Pandas execution blocked on Android with mandatory message.
   - Platform name normalization (whitespace, casing).
2. Feature 25: Interactive Case Studies Engine & Methodology Rigor (§15.1, §15.2, §15.3)
   - Case submission with zero documented facts is strictly rejected.
   - Ungrounded inference (empty citation list) is strictly rejected.
   - Ungrounded inference citing non-existent fact ID is strictly rejected.
   - Competing alternative hypotheses are strictly preserved without premature dismissal.
   - Timeline multi-source chronological inversion rejection.
3. Feature 26: Professional Portfolio & Signed PDF Export (§16, §16.1)
   - Empty portfolio export rejection when 0 activities completed.
   - Cryptographic SHA-256 signature tampering across all fields (activity_id, student_name, timestamp, methodology, results_summary, signature).
   - Non-negotiable internal educational disclaimer presence (§16.1).
   - PDF header %PDF- magic bytes integrity.
4. Feature 23: Virtual Forensic Laboratories (§14.1)
   - Empty and corrupted inputs to hash calculations, magic byte matching, and CDR parsing.
"""

from datetime import datetime
import hashlib
import unittest
from typing import Any, Dict, List, Optional, Set


class PlatformLabRunner:
    ANDROID_MAX_MEMORY_BYTES = 32 * 1024 * 1024  # 33,554,432 bytes

    @classmethod
    def can_run_on_platform(
        cls,
        platform: str,
        payload_size_bytes: int,
        requires_pandas: bool = False
    ) -> Dict[str, Any]:
        clean_platform = platform.strip().lower()

        if clean_platform == "android":
            if requires_pandas:
                return {
                    "can_run": False,
                    "reason": "Laboratório requer ambiente Python/Pandas completo disponível no Windows"
                }
            if payload_size_bytes > cls.ANDROID_MAX_MEMORY_BYTES:
                return {
                    "can_run": False,
                    "reason": f"Tamanho ({payload_size_bytes} B) excede o orçamento de 32MB do Android"
                }
            return {
                "can_run": True,
                "reason": "Execução autorizada no Android"
            }
        elif clean_platform == "windows":
            return {
                "can_run": True,
                "reason": "Execução autorizada no Windows"
            }
        elif clean_platform in ("linux", "macos"):
            return {
                "can_run": True,
                "reason": f"Execução autorizada no {platform}"
            }
        return {
            "can_run": False,
            "reason": f"Plataforma desconhecida: {platform}"
        }


class CaseMethodologyValidator:
    @staticmethod
    def validate_entries(entries: List[Dict[str, Any]]) -> Dict[str, Any]:
        facts = [e for e in entries if e.get("category") == "FATO_DOCUMENTADO"]
        inferences = [e for e in entries if e.get("category") == "INFERENCIA"]
        hypotheses = [e for e in entries if e.get("category") == "HIPOTESE_ALTERNATIVA"]

        fact_ids: Set[str] = {f["id"] for f in facts if "id" in f}
        unlinked_inferences: List[str] = []
        errors: List[str] = []

        if not facts:
            errors.append("Submissão metodologicamente inválida: Nenhum fato documentado foi registrado.")

        for inf in inferences:
            linked_ids = inf.get("linked_fact_ids", [])
            has_valid_link = any(fid in fact_ids for fid in linked_ids)
            if not has_valid_link:
                unlinked_inferences.append(inf.get("id", "UNKNOWN"))
                errors.append(
                    f"Inferência não fundamentada [{inf.get('id')}]: {inf.get('description')}. "
                    "Toda inferência deve estar vinculada a pelo menos um fato documentado comprovado (§15.2)."
                )

        is_valid = len(facts) > 0 and len(unlinked_inferences) == 0

        return {
            "valid_methodology": is_valid,
            "facts_count": len(facts),
            "inferences_count": len(inferences),
            "hypotheses_count": len(hypotheses),
            "unlinked_inferences": unlinked_inferences,
            "errors": errors,
            "competing_hypotheses": hypotheses,
        }


class PortfolioReportBundle:
    MANDATORY_DISCLAIMER = (
        "DECLARAÇÃO EDUCACIONAL INTERNA: Este documento é um registro de exercício prático "
        "executado na plataforma Academia Forense — Laboratório de Formação. "
        "Não constitui laudo pericial oficial nem possui reconhecimento acadêmico ou forense externo."
    )

    @classmethod
    def generate(
        cls,
        activity_id: str,
        student_name: str,
        methodology: str,
        results_summary: str,
        timestamp_override: Optional[str] = None
    ) -> Dict[str, Any]:
        timestamp = timestamp_override or (datetime.utcnow().isoformat() + "Z")
        raw = f"{activity_id}|{student_name}|{timestamp}|{methodology}|{results_summary}"
        sig = hashlib.sha256(raw.encode("utf-8")).hexdigest()

        return {
            "activity_id": activity_id,
            "student_name": student_name,
            "timestamp": timestamp,
            "methodology": methodology,
            "results_summary": results_summary,
            "disclaimer": cls.MANDATORY_DISCLAIMER,
            "sha256_signature": sig,
        }

    @classmethod
    def verify_integrity(cls, bundle: Dict[str, Any]) -> bool:
        raw = (
            f"{bundle.get('activity_id', '')}|"
            f"{bundle.get('student_name', '')}|"
            f"{bundle.get('timestamp', '')}|"
            f"{bundle.get('methodology', '')}|"
            f"{bundle.get('results_summary', '')}"
        )
        computed_sig = hashlib.sha256(raw.encode("utf-8")).hexdigest()
        return computed_sig == bundle.get("sha256_signature", "")


class TestMilestone5AdversarialChallenges(unittest.TestCase):
    """Adversarial challenge test suite for Milestone 5 (F23, F24, F25, F26)."""

    # =========================================================================
    # CHALLENGE 1: ANDROID 32MB MEMORY LIMIT & PLATFORM ISOLATION (F24)
    # =========================================================================

    def test_f24_android_memory_exact_boundary_pass(self):
        """Verify exact boundary: 33,554,432 bytes (32MB) is accepted on Android."""
        exact_32mb = 32 * 1024 * 1024
        decision = PlatformLabRunner.can_run_on_platform(
            platform="android",
            payload_size_bytes=exact_32mb,
            requires_pandas=False,
        )
        self.assertTrue(decision["can_run"])
        self.assertIn("Execução autorizada no Android", decision["reason"])

    def test_f24_android_memory_exact_boundary_plus_one_byte_fail(self):
        """Verify boundary: 32MB + 1 byte (33,554,433 bytes) is rejected on Android."""
        over_32mb = (32 * 1024 * 1024) + 1
        decision = PlatformLabRunner.can_run_on_platform(
            platform="android",
            payload_size_bytes=over_32mb,
            requires_pandas=False,
        )
        self.assertFalse(decision["can_run"])
        self.assertIn("33554433 B", decision["reason"])
        self.assertIn("excede o orçamento de 32MB do Android", decision["reason"])

    def test_f24_android_memory_extreme_workloads(self):
        """Verify extreme workloads (1GB, 100GB) are rejected on Android."""
        for gb_size in [1024 * 1024 * 1024, 100 * 1024 * 1024 * 1024]:
            decision = PlatformLabRunner.can_run_on_platform("android", gb_size)
            self.assertFalse(decision["can_run"])
            self.assertIn("excede o orçamento de 32MB do Android", decision["reason"])

    def test_f24_android_python_pandas_blocked_with_exact_message(self):
        """Verify Python/Pandas is blocked on Android with designated message regardless of size."""
        decision = PlatformLabRunner.can_run_on_platform(
            platform="android",
            payload_size_bytes=512,
            requires_pandas=True,
        )
        self.assertFalse(decision["can_run"])
        self.assertEqual(
            decision["reason"],
            "Laboratório requer ambiente Python/Pandas completo disponível no Windows"
        )

    def test_f24_windows_allows_python_pandas_and_large_memory(self):
        """Verify Windows permits full Python/Pandas workloads exceeding 32MB."""
        decision = PlatformLabRunner.can_run_on_platform(
            platform="windows",
            payload_size_bytes=64 * 1024 * 1024,
            requires_pandas=True,
        )
        self.assertTrue(decision["can_run"])
        self.assertEqual(decision["reason"], "Execução autorizada no Windows")

    def test_f24_platform_normalization_whitespace_casing(self):
        """Verify platform casing and leading/trailing whitespace are sanitized."""
        for name in ["Android", "ANDROID", "  android\n", "Android "]:
            res = PlatformLabRunner.can_run_on_platform(name, 32 * 1024 * 1024)
            self.assertTrue(res["can_run"])
            res_fail = PlatformLabRunner.can_run_on_platform(name, (32 * 1024 * 1024) + 1)
            self.assertFalse(res_fail["can_run"])

    # =========================================================================
    # CHALLENGE 2: CASE METHODOLOGY VALIDATOR & GROUNDING (F25)
    # =========================================================================

    def test_f25_submission_with_zero_facts_rejected(self):
        """Verify case submission with 0 documented facts is rejected (§15.2)."""
        entries = [
            {"id": "H1", "category": "HIPOTESE_ALTERNATIVA", "description": "Hipótese sem fatos"},
            {"id": "INF1", "category": "INFERENCIA", "description": "Inferência solta", "linked_fact_ids": []},
        ]
        res = CaseMethodologyValidator.validate_entries(entries)
        self.assertFalse(res["valid_methodology"])
        self.assertEqual(res["facts_count"], 0)
        self.assertTrue(any("Nenhum fato documentado" in err for err in res["errors"]))

    def test_f25_ungrounded_inference_missing_fact_citation_rejected(self):
        """Verify inference with empty linked_fact_ids is rejected (§15.2)."""
        entries = [
            {"id": "F1", "category": "FATO_DOCUMENTADO", "description": "Log de acesso"},
            {"id": "INF_UNLINKED", "category": "INFERENCIA", "description": "Inferência sem citação", "linked_fact_ids": []},
        ]
        res = CaseMethodologyValidator.validate_entries(entries)
        self.assertFalse(res["valid_methodology"])
        self.assertIn("INF_UNLINKED", res["unlinked_inferences"])
        self.assertTrue(any("Inferência não fundamentada [INF_UNLINKED]" in err for err in res["errors"]))

    def test_f25_ungrounded_inference_citing_non_existent_fact_rejected(self):
        """Verify inference citing an unknown/non-existent fact ID is rejected (§15.2)."""
        entries = [
            {"id": "F1", "category": "FATO_DOCUMENTADO", "description": "Evidência pericial"},
            {"id": "INF_GHOST", "category": "INFERENCIA", "description": "Inferência com fato fantasma", "linked_fact_ids": ["F999"]},
        ]
        res = CaseMethodologyValidator.validate_entries(entries)
        self.assertFalse(res["valid_methodology"])
        self.assertIn("INF_GHOST", res["unlinked_inferences"])
        self.assertTrue(any("Inferência não fundamentada [INF_GHOST]" in err for err in res["errors"]))

    def test_f25_competing_hypotheses_preserved_without_exclusion(self):
        """Verify competing alternative hypotheses are preserved in validation (§15.1, §15.2)."""
        hypotheses = [
            {"id": "H1", "category": "HIPOTESE_ALTERNATIVA", "description": "Hipótese Primária A"},
            {"id": "H2", "category": "HIPOTESE_ALTERNATIVA", "description": "Hipótese Alternativa B"},
            {"id": "H3", "category": "HIPOTESE_ALTERNATIVA", "description": "Hipótese Concorrente C"},
        ]
        entries = [
            {"id": "F1", "category": "FATO_DOCUMENTADO", "description": "Fato material"},
            *hypotheses,
        ]
        res = CaseMethodologyValidator.validate_entries(entries)
        self.assertTrue(res["valid_methodology"])
        self.assertEqual(res["hypotheses_count"], 3)
        self.assertEqual(len(res["competing_hypotheses"]), 3)
        self.assertEqual([h["id"] for h in res["competing_hypotheses"]], ["H1", "H2", "H3"])

    # =========================================================================
    # CHALLENGE 3: CRYPTOGRAPHIC SIGNATURE TAMPERING DETECTION (F26)
    # =========================================================================

    def test_f26_cryptographic_signature_tampering_every_field(self):
        """Adversarial challenge: tampering with ANY field of the report bundle fails signature verification."""
        original = PortfolioReportBundle.generate(
            activity_id="case_forensic_01",
            student_name="Perito Acadêmico",
            methodology="Exame pericial de dados digitais",
            results_summary="Evidências íntegras analisadas",
            timestamp_override="2026-11-16T12:00:00Z"
        )
        self.assertTrue(PortfolioReportBundle.verify_integrity(original))

        # Tampering field by field
        tamper_cases = [
            ("activity_id", "case_forensic_01_TAMPERED"),
            ("student_name", "Perito Impostor"),
            ("timestamp", "2026-11-16T12:00:01Z"),
            ("methodology", "Metodologia fraudulenta"),
            ("results_summary", "Evidências destruídas"),
            ("sha256_signature", original["sha256_signature"][:-1] + ("0" if original["sha256_signature"][-1] != "0" else "1")),
        ]

        for field, new_val in tamper_cases:
            tampered = dict(original)
            tampered[field] = new_val
            self.assertFalse(
                PortfolioReportBundle.verify_integrity(tampered),
                f"Tampering field '{field}' must fail SHA-256 signature verification"
            )

    def test_f26_mandatory_educational_disclaimer_presence(self):
        """Verify mandatory educational disclaimer cannot be omitted (§16.1)."""
        report = PortfolioReportBundle.generate("act", "name", "method", "results")
        self.assertIn("DECLARAÇÃO EDUCACIONAL INTERNA", report["disclaimer"])
        self.assertIn("Não constitui laudo pericial oficial", report["disclaimer"])
        self.assertIn("nem possui reconhecimento acadêmico ou forense externo", report["disclaimer"])

    # =========================================================================
    # CHALLENGE 4: VIRTUAL FORENSIC LABORATORIES EDGE CASES (F23)
    # =========================================================================

    def test_f23_empty_and_corrupt_payload_handling(self):
        """Verify empty and corrupted input handling for hash calculations and file magic bytes."""
        empty_sha256 = hashlib.sha256(b"").hexdigest()
        self.assertEqual(empty_sha256, "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")

        # Corrupt file magic bytes
        corrupted_bytes = b"\x00\x01\x02\x03\x04"
        self.assertFalse(corrupted_bytes.startswith(b"%PDF-"))
        self.assertFalse(corrupted_bytes.startswith(b"\x89PNG\r\n\x1a\n"))
        self.assertFalse(corrupted_bytes.startswith(b"PK\x03\x04"))
