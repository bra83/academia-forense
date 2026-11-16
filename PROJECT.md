# Project: Academia Forense — Laboratório de Formação

## Architecture

Academia Forense is a multiplatform educational platform built with Flutter & Dart targeting Android (Samsung Galaxy A57 reference) and Windows desktop, backed by on-device SQLite (Drift), a native Kotlin Android TTS bridge for offline neural speech (Kokoro Braseiro / Sherpa-ONNX), Google Gemini API for private intelligent tutoring and remote speech generation (Charon voice), and an incremental content engine.

### System Architecture Diagram
```
┌────────────────────────────────────────────────────────────────────────┐
│                        apps/academia_flutter                           │
│   (Android 5-Tab Navigation / Windows Lateral NavigationRail & Hub)    │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │
   ┌─────────────────────────────────┼─────────────────────────────────┐
   │                                 │                                 │
   ▼                                 ▼                                 ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│  design_system   │       │  learning_core   │       │  laboratory_core │
│  (Tokens, Theme, │       │  (Curriculum,    │       │  (Multi-domain,  │
│   Widgets, Rail) │       │   Lesson Engine) │       │   Datasets, SQL) │
└──────────────────┘       └────────┬─────────┘       └────────┬─────────┘
                                    │                          │
   ┌────────────────────────────────┼──────────────────────────┼─────────┐
   │                                │                          │         │
   ▼                                ▼                          ▼         ▼
┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐
│   content_core   │       │ assessment_core  │       │ case_study_core  │
│   (Schema v1.0,  │       │ (Grading, Rubric,│       │ (Facts vs Hypoth,│
│   Dual Reader)   │       │  80% Progression)│       │  PDF Portfolio)  │
└────────┬─────────┘       └──────────────────┘       └──────────────────┘
         │
         ├───────────────────────────────────┐
         ▼                                   ▼
┌──────────────────┐                ┌──────────────────┐
│    drive_sync    │                │   audio_core     │
│ (OAuth2, Local,  │                │ (Queue, Chunks,  │
│  SHA-256 Audit)  │                │  Dual Engine)    │
└────────┬─────────┘                └────────┬─────────┘
         │                                   │
         │                  ┌────────────────┴────────────────┐
         │                  ▼                                 ▼
         │       ┌──────────────────────┐          ┌──────────────────────┐
         │       │ native/android_tts_  │          │      ai_gateway      │
         │       │ bridge (Kokoro/ONNX) │          │  (Gemini REST & RAG, │
         │       └──────────────────────┘          │   Charon TTS Audio)  │
         │                                         └──────────┬───────────┘
         │                                                    │
         │                                         ┌──────────┴───────────┐
         │                                         ▼                      ▼
         │                                ┌──────────────────┐  ┌──────────────────┐
         │                                │     rag_core     │  │  Secure Vault    │
         │                                │ (Local Indexing, │  │ (Keystore/DPAPI  │
         │                                │  Strict Context) │  │  BYOK Storage)   │
         │                                └──────────────────┘  └──────────────────┘
         ▼
┌────────────────────────────────────────────────────────────────────────┐
│                          persistence_core                              │
│         (Drift / SQLite 3.40: 24 Relational Entities & Migrations)      │
└────────────────────────────────────────────────────────────────────────┘
```

## Feature Inventory

| # | Feature | Description | Milestone | Source |
|---|---------|-------------|-----------|--------|
| 1 | Academic Editorial Design System | Custom palette (#F5F6F3, #20533F, #163D2E, #347259, #E7F0EA, #26322C, #66736B, #E1E6E0, #F0F2EF), typography scale, cards, buttons, loading/error states | M1 | §5.1, Spec Miner #1 |
| 2 | Dual Responsive Navigation | 5-tab bottom bar on Android (Início, Estudar, Biblioteca, Laboratório, Meu Espaço) and lateral NavigationRail on Windows | M1 | §5.2, Spec Miner #2 |
| 3 | Adjustable Typography Controls | User adjustable font size (14-22 sp) and line-spacing (~1.5) for comfortable academic reading | M1 | §5.1, §7.1, Spec Miner #3 |
| 4 | Relational Persistence (24 Entities) | Drift / SQLite database covering curriculum, progress, assessments, labs, cases, revisions, AI, audio | M1 | §17, §18.2, Spec Miner #4 |
| 5 | Secure Settings & Vault | Encrypted storage for BYOK Gemini API key (Keystore/DPAPI), weekly target (13h), user preferences | M1 | §10.2, §17.1, Spec Miner #8 |
| 6 | Curriculum Tree & Volume Catalog | 9 volumes, 113 chapters, master index, 7-state editorial lifecycle (Planejado, Importado, Em revisão, Aprovado, Publicado, Substituído, Arquivado) | M2 | §3, §24.3, Explorer 2 #2 |
| 7 | Volume I Print Preservation & Errata | Honor 133 printed pages of Vol I (Ch 1-4 REV2, Ch 5-10 REV1); digital errata table without reprinting | M2 | §1.3, §24.2, Explorer 2 #1 |
| 8 | Section 19 JSON Schema Engine | Strict Draft 2020-12 JSON Schema for zero-recompilation educational content packages | M2 | §19, Explorer 2 #3 |
| 9 | Dual-Mode Library Reader | Verbatim original PDF viewer preserving math/tables + reflowable interactive Markdown study reader | M2 | §7.1, §7.2, Spec Miner #6 |
| 10 | Content-Progress Decoupling & Safe Updates | Immutable attempts/scores, annotations drift tolerance, bookmarks and reading position preservation | M2 | §2.2, Explorer 2 #4 |
| 11 | Local Text Search (FTS5) | Offline fast full-text search across all imported chapters, titles, and glossaries | M2 | §7.1, §18.3, Spec Miner #5 |
| 12 | Ingestion & Sync Providers | 3-tier provider architecture: GoogleDriveContentProvider, LocalDirectoryContentProvider, FixtureContentProvider | M2 | §2.1, Explorer 2 #1 |
| 13 | 10-Step Lesson Engine | Didactic structure: Objectives, Prerequisites, Problem, Theory, Solved Example, Guided Exercise, Lab, Assessment, Review, Summary | M3 | §8, §8.1 |
| 14 | Automated Assessment & 80% Progression | Objective & discursive evaluation engine, 80% passing benchmark, competency mastery matrix, attempt logging | M3 | §8.2, §17.1 |
| 15 | Adaptive Study Plan & Spaced Repetition | 13-hour weekly study schedule tracking, review recommendations, competency gap diagnostics | M3 | §17.1, Spec Miner #4 |
| 16 | Dynamic Gemini Model Discovery | Live query of `https://ai.google.dev/api/models` to discover supported models with generation methods | M3 | §10.1, Spec Miner #7 |
| 17 | 7 Pedagogical Tutor Modes | Explicar, Simplificar, Aprofundar, Exemplificar, Me testar, Revisar, Orientar laboratório | M3 | §9.3, Spec Miner #9 |
| 18 | Strict RAG Provenance & Citations | Context injection strictly limited to approved editorial chapters; explicit tags [FONTE]/[INFERÊNCIA]; error handling | M3 | §9.2, §10.3, Spec Miner #10 |
| 19 | Android Native TTS Bridge (Kokoro Braseiro) | MethodChannel/EventChannel bridge to Sherpa-ONNX `com.k2fsa.sherpa.onnx.tts.engine` with voice query and callbacks | M4 | §11, §12.1, Explorer 1 #5 |
| 20 | Sentence Segmenter & Queue Control | Punctuation chunking (250-650 chars, target 450), maxNumSentences=2, silenceScale=0.06, 0.65x-1.50x speed | M4 | §12.2, §12.3, Spec Miner #13 |
| 21 | Gemini Online TTS (Charon Voice) | Remote speech generation via Gemini REST API, Charon default voice, Base64 to 44-byte WAV header conversion | M4 | §13, Spec Miner #12 |
| 22 | Audio Player UI & Follow-along Highlight | Player bar, play/pause, seek, speed slider, paragraph sync highlighting, strict rule against silent fallback | M4 | §12.5, §12.6, Spec Miner #13 |
| 23 | Multi-Discipline Lab Engine | 7 domains: Informatics, Math, Programming (Python), Digital Forensics (hashes/metadata), Telephony (CDRs/ERBs), Linguistics, Multimedia | M5 | §14.1, Spec Miner #14 |
| 24 | Platform-Bounded Lab Isolation | Lightweight tools & queries on Android (32MB budget); full Python/Pandas environments on Windows | M5 | §14.2, Spec Miner #16 |
| 25 | Interactive Case Studies Engine | Forensic scenario solver separating Documented Facts from Investigative Inferences and Alternative Hypotheses | M5 | §15, Spec Miner #15 |
| 26 | Professional Portfolio & PDF Export | Meu Espaço dashboard, skill progression, completed lab runs, exportable signed PDF forensic reports | M5 | §16, §16.1 |
| 27 | Multiplatform CI/CD Pipeline | GitHub Actions workflows for Ubuntu (Lint, Tests, Linux build, APK assemble) and Windows (`windows-latest` release build) | M1/M6 | §25, Explorer 1 #3 |
| 28 | Comprehensive Automated Test Suite | Tiers 1-4 opaque-box E2E test suite + unit/integration/golden tests + Tier 5 adversarial hardening | M6 | §23, §27 |

## Milestones

| # | Name | Scope | Dependencies | Status |
|---|------|-------|-------------|--------|
| M1 | Lote A — Core Architecture, Design System & Persistence | Git repo setup, Flutter app foundation, `design_system`, responsive navigation, `persistence_core` (24 Drift entities), secure vault | none | DONE |
| M2 | Lote B & H — Content Ingestion, Curriculum & Library Engine | `content_core`, `drive_sync`, Section 19 schema, 9 vols / 113 chapters catalog, dual reader, errata, safe updates | M1 | DONE |
| M3 | Lote C & D — Educational Engine & Gemini AI Private Tutor | `learning_core`, `assessment_core`, `ai_gateway`, `rag_core`, 10-step lessons, 80% mastery, BYOK, 7 tutor modes, RAG | M1, M2 | DONE |
| M4 | Lote E — Dual Voice System (Kokoro Braseiro + Gemini Charon) | `audio_core`, `native/android_tts_bridge`, Sherpa-ONNX controller, 450-char chunking, Gemini Charon TTS, audio UI | M1, M2 | DONE |
| M5 | Lote F & G — Practical Labs, Case Studies & Professional Portfolio | `laboratory_core`, `case_study_core`, 7-domain lab runner, fact/inference case solver, Meu Espaço, PDF export | M1, M2, M3 | DONE |
| M6 | Final Milestone: Lote I — 100% E2E Test Suite Pass & Adversarial Hardening | Phase 1: Pass 100% of E2E tests (Tiers 1-4 from E2E Track); Phase 2: Tier 5 adversarial hardening with Challenger | M1, M2, M3, M4, M5, TEST_READY.md | DONE |

*Parallel Track*:
| E2E Testing Track | Requirement-driven opaque-box test infra & test suite (Tiers 1-4) covering all 28 features; produces `TEST_READY.md` | none | COMPLETED |


## Interface Contracts

### 1. `persistence_core` ↔ All Packages
```dart
abstract class AppDatabaseContract {
  // Curriculum & Content
  Future<List<VolumeData>> getVolumes();
  Future<ChapterData?> getChapterById(String chapterId);
  Future<ContentRevisionData?> getActiveRevision(String chapterId);
  Future<void> upsertContentPackage(ChapterPackage package);

  // User Progress & Annotations
  Future<ReadingPositionData?> getReadingPosition(String chapterId);
  Future<void> saveReadingPosition(String chapterId, int page, double scrollRatio);
  Future<List<AnnotationData>> getAnnotations(String chapterId);
  Future<void> saveAnnotation(AnnotationCompanion annotation);

  // Assessments & Labs
  Future<void> recordAssessmentAttempt(AssessmentAttemptCompanion attempt);
  Future<List<AssessmentAttemptData>> getAssessmentHistory(String assessmentId);
  Future<void> recordLaboratoryRun(LaboratoryRunCompanion run);

  // Settings & Audio
  Future<String?> getSetting(String key);
  Future<void> setSetting(String key, String value);
  Future<AudioSettingsData> getAudioSettings();
  Future<void> updateAudioSettings(AudioSettingsCompanion settings);
}
```

### 2. `ai_gateway` ↔ `rag_core` & UI
```dart
enum PedagogicalMode {
  explicar,
  simplificar,
  aprofundar,
  exemplificar,
  meTestar,
  revisar,
  orientarLab,
}

abstract class AiGatewayContract {
  Future<List<GeminiModelInfo>> discoverModels({required String apiKey});
  Future<String> queryTutor({
    required String apiKey,
    required String modelId,
    required PedagogicalMode mode,
    required String userQuery,
    required List<RagDocumentChunk> contextChunks,
  });
}
```

### 3. `audio_core` ↔ `native/android_tts_bridge` & UI
```dart
enum AudioEngineType { kokoro, geminiTts }

abstract class AudioCoreContract {
  Stream<AudioPlaybackState> get stateStream;
  Future<void> setEngine(AudioEngineType engine);
  Future<void> setVoice(String voiceName);
  Future<void> setSpeed(double speed); // 0.65 to 1.50
  Future<void> playText({required String text, required String sectionId});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
}
```

### 4. `content_core` ↔ `drive_sync`
```dart
abstract class ContentIngestionContract {
  Future<IngestionResult> ingestPackageJson(String jsonString);
  Future<IngestionResult> ingestLocalDirectory(String dirPath);
  Future<ValidationReport> validatePackage(ChapterPackage package);
}
```

## Code Layout

```
/home/antigravity/
├── apps/
│   └── academia_flutter/          # Main Flutter runner (lib/main.dart, android/, linux/, windows/)
├── packages/
│   ├── design_system/             # Colors, typography, tokens, widgets
│   ├── content_core/              # Manifests, Section 19 schema, models, dual viewer
│   ├── learning_core/             # Curriculum syllabus, lesson runners, spaced repetition
│   ├── assessment_core/           # Objective and discursive exam engine
│   ├── laboratory_core/           # 7-domain lab runner, SQL and dataset interpreters
│   ├── case_study_core/           # Facts vs inferences solver, timeline, PDF reporter
│   ├── ai_gateway/                # Gemini client, dynamic model discovery, key vault
│   ├── rag_core/                  # Local indexing, chunking, prompt builder
│   ├── audio_core/                # Chunker, queue manager, audio player integration
│   ├── drive_sync/                # Providers: Drive API, local files, fixtures
│   └── persistence_core/          # Drift database, 24 entities, DAOs, migrations
├── native/
│   └── android_tts_bridge/        # Android Kotlin plugin for Sherpa-ONNX Kokoro bridge
├── content/
│   ├── manifests/                 # Canonical curriculum manifests
│   ├── schemas/                   # JSON schemas
│   ├── approved/                  # Approved packages
│   ├── staging/                   # Sync staging area
│   └── fixtures/                  # Seed fixtures for Vol I (Ch 1-4 REV2, Ch 5-10 REV1)
├── tools/
│   ├── content_ingestion/         # CLI ingestion tool
│   └── content_validation/        # CLI package validator
├── tests/
│   ├── unit/                      # Package unit tests
│   ├── integration/               # Cross-package integration tests
│   ├── e2e/                       # Opaque-box E2E test suite
│   └── test_runner.py             # E2E test runner
├── .github/
│   └── workflows/                 # CI/CD workflows (ubuntu-latest & windows-latest)
└── PROJECT.md                     # Single source of truth index
```
