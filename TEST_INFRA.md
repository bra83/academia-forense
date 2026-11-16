# E2E Test Infra: Academia Forense

## Test Philosophy
- **Opaque-box & Requirement-driven**: Derived directly from `ORIGINAL_REQUEST.md` and user-facing specifications, completely independent of internal implementation code or private methods.
- **Methodology**: Category-Partition + Boundary Value Analysis (BVA) + Pairwise Combinatorial Testing + Real-World Workload Testing.
- **Progressive Testability**: Verification does not require features more complex than the tested feature.
- **Zero Simulation / Anti-Cheating**: Tests must verify real file modifications, database records in SQLite, network request schemas, and actual audio/JSON payloads.

## Test Architecture
- **Location**: `/home/antigravity/tests/e2e/`
- **Runner**: `/home/antigravity/tests/test_runner.py` (executable with `python3 tests/test_runner.py --all`)
- **Pass/Fail Semantics**: Exit code 0 on 100% pass; non-zero exit code on any test failure. Emits machine-readable JUnit XML and JSON test summaries.
- **Directory Layout**:
  ```
  tests/
  ├── e2e/
  │   ├── tier1_features/         # Happy path isolation tests (>= 5 per feature)
  │   ├── tier2_boundaries/       # Boundary value, edge, corrupt, offline inputs
  │   ├── tier3_pairwise/         # Combinatorial feature interactions
  │   └── tier4_scenarios/        # Realistic end-to-end user workflows
  ├── test_runner.py              # Canonical test harness & runner
  └── test_fixtures/              # Test manifest fixtures, invalid schemas, sample audio
  ```

## Feature Coverage Matrix (28 Features)

| # | Feature | Scope | Tier 1 (≥5) | Tier 2 (≥5) | Tier 3 (Pairwise) | Tier 4 (Workload) |
|---|---------|-------|:-----------:|:-----------:|:-----------------:|:-----------------:|
| 1 | Design System Palette | WCAG AAA contrast, exact hex tokens, cards, borders | 5 | 5 | ✓ | ✓ |
| 2 | Dual Responsive Navigation | 5-tab Android bottom bar vs Windows NavigationRail | 5 | 5 | ✓ | ✓ |
| 3 | Adjustable Typography | Font size 14-22sp, line height 1.5, text readability | 5 | 5 | ✓ | ✓ |
| 4 | Relational Persistence | 24 Drift entities, foreign keys, transactions, rollback | 5 | 5 | ✓ | ✓ |
| 5 | Secure Settings Vault | Encrypted BYOK Gemini key, Keystore/DPAPI, mask in logs | 5 | 5 | ✓ | ✓ |
| 6 | Curriculum Tree & Statuses | 9 vols / 113 chapters, 7 editorial states | 5 | 5 | ✓ | ✓ |
| 7 | Volume I Print Preservation | Ch 1-4 REV2, Ch 5-10 REV1, 133 printed pages, errata table | 5 | 5 | ✓ | ✓ |
| 8 | Section 19 JSON Schema | Draft 2020-12 validation, zero-recompilation packages | 5 | 5 | ✓ | ✓ |
| 9 | Dual-Mode Library Reader | Verbatim original PDF viewer + reflowable Markdown study | 5 | 5 | ✓ | ✓ |
| 10 | Content-Progress Decoupling | Notes survive revision changes, anchor drift detection | 5 | 5 | ✓ | ✓ |
| 11 | Local Text Search (FTS5) | Offline search across chapters, glossaries, references | 5 | 5 | ✓ | ✓ |
| 12 | Ingestion & Sync Providers | Drive API, local directory/ZIP import, seed fixtures | 5 | 5 | ✓ | ✓ |
| 13 | 10-Step Lesson Engine | Didactic sequence, theory, examples, exercises | 5 | 5 | ✓ | ✓ |
| 14 | Assessment & 80% Mastery | Objective & discursive exams, passing score 80%, rubrics | 5 | 5 | ✓ | ✓ |
| 15 | Adaptive Study Plan | 13h weekly target tracking, review schedule, gaps | 5 | 5 | ✓ | ✓ |
| 16 | Dynamic Gemini Discovery | GET /v1beta/models, model categorization (text vs audio) | 5 | 5 | ✓ | ✓ |
| 17 | 7 Pedagogical Tutor Modes | Explicar, Simplificar, Aprofundar, Exemplificar, Me testar, Revisar, Orientar | 5 | 5 | ✓ | ✓ |
| 18 | Strict RAG Provenance | Approved chapter grounding, [FONTE]/[INFERÊNCIA] tags | 5 | 5 | ✓ | ✓ |
| 19 | Android Native TTS Bridge | Kokoro Braseiro package detection, voice listing | 5 | 5 | ✓ | ✓ |
| 20 | Sentence Segmenter & Queue | 250-650 char chunks (target 450), maxNumSentences=2 | 5 | 5 | ✓ | ✓ |
| 21 | Gemini Online TTS (Charon) | Speech generation payload, Charon voice, 44-byte WAV | 5 | 5 | ✓ | ✓ |
| 22 | Audio UI & Highlighting | Speed 0.65x-1.50x, follow-along highlight, no silent fallback | 5 | 5 | ✓ | ✓ |
| 23 | Multi-Discipline Lab Engine | 7 domains: Informatics, Math, Python, Forensics, etc. | 5 | 5 | ✓ | ✓ |
| 24 | Platform-Bounded Labs | Android lightweight (32MB budget) vs Windows Python env | 5 | 5 | ✓ | ✓ |
| 25 | Investigative Case Matrix | Facts vs Inferences vs Hypotheses, forensic timeline | 5 | 5 | ✓ | ✓ |
| 26 | Portfolio & PDF Export | Meu Espaço dashboard, signed forensic PDF report export | 5 | 5 | ✓ | ✓ |
| 27 | Multiplatform CI Workflows | GitHub Actions configuration for Ubuntu and Windows | 5 | 5 | ✓ | ✓ |
| 28 | Integrity & Anti-Cheating | Authentic logic verification, zero dummy/mock bypasses | 5 | 5 | ✓ | ✓ |

## Real-World Application Scenarios (Tier 4)

| # | Scenario | Features Exercised | Description |
|---|----------|--------------------|-------------|
| 1 | Student Onboarding & First Chapter Study | F1, F2, F3, F4, F6, F7, F9, F13, F20, F22 | Student opens app, verifies Vol 1 Ch 1 REV2, adjusts font size, reads in study mode, listens via Kokoro TTS with paragraph highlighting, records reading position. |
| 2 | Offline Assessment & Spaced Repetition Review | F4, F10, F14, F15 | Student takes Ch 1 assessment offline, scores 85%, passes competency, system schedules spaced review for 3 days later, weekly study hours accumulate toward 13h target. |
| 3 | AI Tutor Forensic Questioning & RAG Citation | F5, F16, F17, F18 | Student configures BYOK key, discovers Gemini models, queries tutor in `Aprofundar` mode; tutor grounds response in approved Ch 1 text with citation tags, rejecting hallucinated sources. |
| 4 | Digital Forensics Hash Lab Execution & Report | F4, F23, F24, F26 | Student runs Digital Forensics Lab calculating SHA-256 and MD5 hashes on evidence disk image, validates results against ground truth, exports signed PDF lab report to Meu Espaço. |
| 5 | Telephony CDR Investigative Case Analysis | F4, F24, F25, F26 | Student examines synthetic CDR dataset and cell tower coordinates, separates documented cell hits from investigative movement hypotheses, constructs timeline, and exports case conclusion. |
| 6 | Drive Package Ingestion & Safe Revision Update | F4, F6, F7, F8, F10, F12 | System ingests new chapter package with REV2 revision; existing student notes survive with anchor drift detection, historical exam scores remain unchanged. |
| 7 | Dual-Engine Audio Failure & Recovery Without Silent Fallback | F19, F21, F22 | Student listens via Gemini Charon TTS; network drops (or quota 429); system immediately shows clear error notice and does NOT silently switch to Kokoro without user confirmation. |
| 8 | Multiplatform Database Migration & Backup Restore | F4, F5, F27 | App database triggers schema migration from v1 to v2, verifies data integrity across all 24 entities, exports encrypted backup, and successfully restores into clean instance. |

## Quantitative Coverage Thresholds
- **Tier 1 (Feature Coverage)**: 28 features × 5 tests = **140 tests**
- **Tier 2 (Boundary & Corner Cases)**: 28 features × 5 tests = **140 tests**
- **Tier 3 (Cross-Feature Combinations)**: **28 pairwise tests**
- **Tier 4 (Real-World Scenarios)**: **8 comprehensive workload scenarios**
- **Total Minimum Test Cases**: **316 tests**
