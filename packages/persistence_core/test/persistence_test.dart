import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:persistence_core/persistence_core.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late AppDatabase db;

  setUp(() {
    // In-memory test connection with foreign keys enabled
    db = AppDatabase(DatabaseConnectionFactory.inMemory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Relational Schema (24 Entities §17)', () {
    test('All 24 relational tables exist in schema definition', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();
      expect(tableNames.length, equals(24));

      final expectedTables = {
        'curriculums',
        'volumes',
        'chapters',
        'lessons',
        'learning_objectives',
        'competencies',
        'exercises',
        'assessments',
        'assessment_attempts',
        'laboratories',
        'laboratory_runs',
        'case_studies',
        'case_submissions',
        'study_sessions',
        'reading_positions',
        'bookmarks',
        'annotations',
        'review_schedules',
        'content_revisions',
        'source_documents',
        'user_settings_entries',
        'sync_journals',
        'a_i_interactions',
        'audio_settings_entries',
      };

      for (final expected in expectedTables) {
        expect(tableNames.contains(expected), isTrue, reason: 'Missing table $expected');
      }
    });

    test('Foreign key constraints reject orphaned child records', () async {
      // Trying to insert a Chapter referencing a non-existent Volume must fail
      expect(
        () async {
          await db.curriculumDao.insertChapter(
            ChaptersCompanion.insert(
              id: 'orphan_ch_01',
              volumeId: 'non_existent_vol',
              chapterNumber: 1,
              title: 'Capítulo Órfão',
              orderIndex: 1,
            ),
          );
        },
        throwsA(isA<SqliteException>()),
      );
    });

    test('Transaction rollbacks restore database to consistent state on error', () async {
      // Insert curriculum first
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curriculum_main',
          name: 'Perito Forense Oficial',
          version: '1.0.0',
          description: 'Currículo integrado',
        ),
      );

      try {
        await db.transaction(() async {
          await db.curriculumDao.insertVolume(
            VolumesCompanion.insert(
              id: 'vol_tx_01',
              curriculumId: 'curriculum_main',
              volumeNumber: 1,
              title: 'Volume Transação',
              discipline: 'Informática',
              description: 'Desc',
              totalChapters: 10,
            ),
          );

          // Simulate mid-transaction failure
          throw Exception('Simulated fatal transaction failure');
        });
      } catch (_) {
        // Expected
      }

      final vol = await db.curriculumDao.getVolumeById('vol_tx_01');
      expect(vol, isNull, reason: 'Transaction must rollback volume insert');
    });
  });

  group('CurriculumDao (§3, §24.2, §24.3)', () {
    test('Curriculum hierarchy and 7-state editorial lifecycle', () async {
      // 1. Insert Curriculum
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_forense',
          name: 'Academia Forense Perito Criminal',
          version: '1.0.0',
          description: 'Trilha completa',
          weeklyTargetHours: const Value(13.0),
        ),
      );

      // 2. Insert Volume I (Print preserved)
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_01',
          curriculumId: 'curr_forense',
          volumeNumber: 1,
          title: 'Volume I — Fundamentos Periciais',
          discipline: 'Informática e Computação Forense',
          description: '133 páginas impressas',
          totalChapters: 10,
          isPrintPreserved: const Value(true),
        ),
      );

      // 3. Insert Chapter with status 'Planejado'
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'vol_01_ch_01',
          volumeId: 'vol_01',
          chapterNumber: 1,
          title: 'Arquitetura de Sistemas Digitais',
          editorialStatus: const Value('Planejado'),
          orderIndex: 1,
        ),
      );

      // 4. Update status along 7-state lifecycle: Planejado -> Em revisão -> Aprovado -> Publicado
      await db.curriculumDao.updateChapterStatus('vol_01_ch_01', 'Em revisão');
      var ch = await db.curriculumDao.getChapterById('vol_01_ch_01');
      expect(ch?.editorialStatus, equals('Em revisão'));

      await db.curriculumDao.updateChapterStatus('vol_01_ch_01', 'Publicado');
      ch = await db.curriculumDao.getChapterById('vol_01_ch_01');
      expect(ch?.editorialStatus, equals('Publicado'));

      // 5. Insert Lessons and Learning Objectives
      await db.curriculumDao.insertLesson(
        LessonsCompanion.insert(
          id: 'lesson_01_01',
          chapterId: 'vol_01_ch_01',
          lessonNumber: 1,
          title: 'Estrutura de CPU e Memória',
          orderIndex: 1,
        ),
      );

      await db.curriculumDao.insertObjective(
        LearningObjectivesCompanion.insert(
          id: 'obj_01_01',
          chapterId: 'vol_01_ch_01',
          description: 'Compreender a hierarquia de barramentos e registradores',
          bloomTaxonomyLevel: 'Understand',
          orderIndex: 1,
        ),
      );

      final lessons = await db.curriculumDao.getLessonsForChapter('vol_01_ch_01');
      final objs = await db.curriculumDao.getObjectivesForChapter('vol_01_ch_01');
      expect(lessons.length, equals(1));
      expect(objs.length, equals(1));
    });
  });

  group('UserProgressDao (§7.1, §17.1)', () {
    setUp(() async {
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_test',
          name: 'Currículo Teste',
          version: '1.0',
          description: 'Teste',
        ),
      );
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_test',
          curriculumId: 'curr_test',
          volumeNumber: 1,
          title: 'Volume Teste',
          discipline: 'Forense',
          description: 'Desc',
          totalChapters: 1,
        ),
      );
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_test_01',
          volumeId: 'vol_test',
          chapterNumber: 1,
          title: 'Capítulo 01',
          orderIndex: 1,
        ),
      );
    });

    test('Reading position updates and bookmarking', () async {
      // Save initial reading position
      await db.userProgressDao.saveReadingPosition(
        chapterId: 'ch_test_01',
        pageNumber: 15,
        scrollRatio: 0.45,
        lastParagraphIndex: 8,
      );

      var pos = await db.userProgressDao.getReadingPosition('ch_test_01');
      expect(pos?.pageNumber, equals(15));
      expect(pos?.scrollRatio, closeTo(0.45, 0.001));
      expect(pos?.lastParagraphIndex, equals(8));

      // Add Bookmark
      await db.userProgressDao.addBookmark(
        BookmarksCompanion.insert(
          id: 'bm_01',
          chapterId: 'ch_test_01',
          pageNumber: 15,
          sectionTitle: 'Análise de Memória Volátil',
        ),
      );

      final bookmarks = await db.userProgressDao.getBookmarksForChapter('ch_test_01');
      expect(bookmarks.length, equals(1));
      expect(bookmarks.first.sectionTitle, equals('Análise de Memória Volátil'));
    });

    test('Annotations and Spaced Repetition Review Schedule', () async {
      // Save Annotation
      await db.userProgressDao.saveAnnotation(
        AnnotationsCompanion.insert(
          id: 'annot_01',
          chapterId: 'ch_test_01',
          pageNumber: 15,
          selectedText: 'A cadeia de custódia inicia-se com a preservação do vestígio.',
          note: 'Artigo 158-A do CPP',
          highlightColor: const Value('#347259'),
        ),
      );

      final notes = await db.userProgressDao.getAnnotationsForChapter('ch_test_01');
      expect(notes.length, equals(1));
      expect(notes.first.note, equals('Artigo 158-A do CPP'));

      // Schedule review
      final reviewDate = DateTime.now().add(const Duration(days: 1));
      await db.userProgressDao.scheduleReview(
        ReviewSchedulesCompanion.insert(
          id: 'rev_sched_01',
          chapterId: 'ch_test_01',
          scheduledDate: reviewDate,
          repetitionIntervalDays: const Value(1),
          easinessFactor: const Value(2.5),
        ),
      );

      final pending = await db.userProgressDao.getPendingReviews(DateTime.now().add(const Duration(days: 2)));
      expect(pending.length, equals(1));

      // Mark review completed
      await db.userProgressDao.markReviewCompleted('rev_sched_01');
      final pendingAfter = await db.userProgressDao.getPendingReviews(DateTime.now().add(const Duration(days: 2)));
      expect(pendingAfter.isEmpty, isTrue);
    });
  });

  group('AssessmentDao (§8.2, 80% passing benchmark)', () {
    setUp(() async {
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_test',
          name: 'Currículo',
          version: '1.0',
          description: 'Desc',
        ),
      );
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_test',
          curriculumId: 'curr_test',
          volumeNumber: 1,
          title: 'Volume',
          discipline: 'Discipline',
          description: 'Desc',
          totalChapters: 1,
        ),
      );
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_test_01',
          volumeId: 'vol_test',
          chapterNumber: 1,
          title: 'Capítulo 01',
          orderIndex: 1,
        ),
      );
    });

    test('Records score attempts and enforces 80% benchmark', () async {
      await db.assessmentDao.insertAssessment(
        AssessmentsCompanion.insert(
          id: 'assess_ch01',
          chapterId: 'ch_test_01',
          title: 'Avaliação de Fixação — Capítulo 1',
          passingBenchmark: const Value(0.80),
          questionDataJson: '{"questions": []}',
          totalQuestions: 10,
        ),
      );

      // Attempt 1: 70% (Failed)
      await db.assessmentDao.recordAttempt(
        AssessmentAttemptsCompanion.insert(
          id: 'att_01',
          assessmentId: 'assess_ch01',
          score: 0.70,
          passed: false,
          responsesJson: '{"q1": "A"}',
          durationSeconds: const Value(300),
        ),
      );

      expect(await db.assessmentDao.hasPassedAssessment('assess_ch01'), isFalse);
      expect(await db.assessmentDao.getHighestScore('assess_ch01'), equals(0.70));

      // Attempt 2: 85% (Passed)
      await db.assessmentDao.recordAttempt(
        AssessmentAttemptsCompanion.insert(
          id: 'att_02',
          assessmentId: 'assess_ch01',
          score: 0.85,
          passed: true,
          responsesJson: '{"q1": "B"}',
          durationSeconds: const Value(280),
        ),
      );

      expect(await db.assessmentDao.hasPassedAssessment('assess_ch01'), isTrue);
      expect(await db.assessmentDao.getHighestScore('assess_ch01'), equals(0.85));
    });
  });

  group('Laboratory & Case Studies DAO (§14, §15)', () {
    setUp(() async {
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_test',
          name: 'Currículo',
          version: '1.0',
          description: 'Desc',
        ),
      );
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_test',
          curriculumId: 'curr_test',
          volumeNumber: 1,
          title: 'Volume',
          discipline: 'Discipline',
          description: 'Desc',
          totalChapters: 1,
        ),
      );
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_test_01',
          volumeId: 'vol_test',
          chapterNumber: 1,
          title: 'Capítulo 01',
          orderIndex: 1,
        ),
      );
    });

    test('Records laboratory run execution and case study submissions', () async {
      // 1. Laboratory
      await db.laboratoryDao.insertLaboratory(
        LaboratoriesCompanion.insert(
          id: 'lab_cdr_01',
          chapterId: 'ch_test_01',
          domain: 'Telephony',
          title: 'Extração e Cruzamento de ERBs / CDRs',
          environmentType: 'CDRAnalyzer',
          instructionsMarkdown: 'Instruções do laboratório de telefonia...',
          verificationRubricJson: '{"requiredERBs": 3}',
        ),
      );

      await db.laboratoryDao.recordLaboratoryRun(
        LaboratoryRunsCompanion.insert(
          id: 'run_01',
          laboratoryId: 'lab_cdr_01',
          commandsExecutedJson: '["analyze_erb --file target.csv"]',
          isPassed: true,
          metricsJson: const Value('{"durationMs": 140}'),
        ),
      );

      final runs = await db.laboratoryDao.getRunsForLaboratory('lab_cdr_01');
      expect(runs.length, equals(1));
      expect(runs.first.isPassed, isTrue);

      // 2. Case Study
      await db.laboratoryDao.insertCaseStudy(
        CaseStudiesCompanion.insert(
          id: 'case_01',
          chapterId: 'ch_test_01',
          caseTitle: 'Operação Falso Alibi',
          incidentSummary: 'Análise de registros de torre celular e metadados de fotos.',
          documentedFactsJson: '["Registro ERB 14:32", "Exif 14:35"]',
          investigativeInferencesJson: '["Dispositivo estava em trânsito"]',
          alternativeHypothesesJson: '["Possível clonagem de IMSI"]',
          evidentialMatrixJson: '{"corroborated": true}',
        ),
      );

      await db.laboratoryDao.recordCaseSubmission(
        CaseSubmissionsCompanion.insert(
          id: 'sub_01',
          caseStudyId: 'case_01',
          conclusionText: 'Conclusão pericial: álibi refutado pela triangulação de ERB.',
          hypothesisEvaluationJson: '{"hypo1": "refuted"}',
        ),
      );

      final subs = await db.laboratoryDao.getSubmissionsForCase('case_01');
      expect(subs.length, equals(1));
      expect(subs.first.conclusionText, contains('álibi refutado'));
    });
  });

  group('Audio & Settings DAO (§12.3, §13, §17.1)', () {
    test('Default audio settings (Kokoro / Charon, 450 chunk target) and updates', () async {
      final settings = await db.audioDao.getAudioSettings();
      expect(settings.preferredEngine, equals('kokoro'));
      expect(settings.voiceName, equals('Charon'));
      expect(settings.playbackSpeed, equals(1.0));
      expect(settings.chunkCharTarget, equals(450));

      // Update speed to 1.25x and engine to geminiTts
      await db.audioDao.updateAudioSettings(
        preferredEngine: 'geminiTts',
        playbackSpeed: 1.25,
      );

      final updated = await db.audioDao.getAudioSettings();
      expect(updated.preferredEngine, equals('geminiTts'));
      expect(updated.playbackSpeed, equals(1.25));
    });

    test('User settings key-value persistence', () async {
      await db.settingsDao.setSetting('weekly_target_hours', '13.0');
      await db.settingsDao.setSetting('theme_mode', 'light');

      expect(await db.settingsDao.getSetting('weekly_target_hours'), equals('13.0'));
      expect(await db.settingsDao.getSetting('theme_mode'), equals('light'));

      await db.settingsDao.deleteSetting('theme_mode');
      expect(await db.settingsDao.getSetting('theme_mode'), isNull);
    });
  });

  group('Database Backup and JSON Export/Import (§17)', () {
    test('Export to JSON and import into fresh database restores entire hierarchy without foreign key errors', () async {
      // 1. Setup complete hierarchy in source database
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_export',
          name: 'Currículo de Exportação',
          version: '1.0',
          description: 'Desc',
        ),
      );

      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_export',
          curriculumId: 'curr_export',
          volumeNumber: 1,
          title: 'Volume Export',
          discipline: 'Informática',
          description: 'Desc',
          totalChapters: 1,
        ),
      );

      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_export_01',
          volumeId: 'vol_export',
          chapterNumber: 1,
          title: 'Capítulo Exportação',
          orderIndex: 1,
        ),
      );

      await db.assessmentDao.insertAssessment(
        AssessmentsCompanion.insert(
          id: 'assess_export_01',
          chapterId: 'ch_export_01',
          title: 'Exame de Exportação',
          passingBenchmark: const Value(0.80),
          questionDataJson: '{"q": 1}',
          totalQuestions: 5,
        ),
      );

      await db.assessmentDao.recordAttempt(
        AssessmentAttemptsCompanion.insert(
          id: 'attempt_export_01',
          assessmentId: 'assess_export_01',
          score: 0.92,
          passed: true,
          responsesJson: '{"1": "A"}',
          durationSeconds: const Value(180),
        ),
      );

      await db.userProgressDao.saveReadingPosition(
        chapterId: 'ch_export_01',
        pageNumber: 42,
        scrollRatio: 0.75,
        lastParagraphIndex: 12,
      );

      await db.userProgressDao.addBookmark(
        BookmarksCompanion.insert(
          id: 'bm_export_01',
          chapterId: 'ch_export_01',
          pageNumber: 42,
          sectionTitle: 'Seção Forense Exportada',
        ),
      );

      await db.userProgressDao.saveAnnotation(
        AnnotationsCompanion.insert(
          id: 'annot_export_01',
          chapterId: 'ch_export_01',
          pageNumber: 42,
          selectedText: 'Texto destacado para backup',
          note: 'Nota associada à evidência',
        ),
      );

      await db.settingsDao.setSetting('app_edition', 'editorial_v1');
      await db.settingsDao.setSetting('backup_timestamp', '2026-11-16');

      // 2. Export database to JSON
      final jsonExport = await db.exportToJson();
      expect(jsonExport['version'], equals(1));
      expect(jsonExport['curriculums'], isNotEmpty);
      expect(jsonExport['volumes'], isNotEmpty);
      expect(jsonExport['chapters'], isNotEmpty);
      expect(jsonExport['assessments'], isNotEmpty);
      expect(jsonExport['assessmentAttempts'], isNotEmpty);
      expect(jsonExport['readingPositions'], isNotEmpty);
      expect(jsonExport['bookmarks'], isNotEmpty);
      expect(jsonExport['annotations'], isNotEmpty);
      expect(jsonExport['settings'], isNotEmpty);

      // 3. Import into a completely FRESH, EMPTY database (with foreign keys ON)
      final freshDb = AppDatabase(DatabaseConnectionFactory.inMemory());
      await freshDb.importFromJson(jsonExport);

      // 4. Verify all records restored faithfully
      final curr = await freshDb.curriculumDao.getCurriculumById('curr_export');
      expect(curr, isNotNull);
      expect(curr?.name, equals('Currículo de Exportação'));

      final vol = await freshDb.curriculumDao.getVolumeById('vol_export');
      expect(vol, isNotNull);
      expect(vol?.curriculumId, equals('curr_export'));

      final ch = await freshDb.curriculumDao.getChapterById('ch_export_01');
      expect(ch, isNotNull);
      expect(ch?.volumeId, equals('vol_export'));

      final assess = await freshDb.assessmentDao.getAssessmentById('assess_export_01');
      expect(assess, isNotNull);
      expect(assess?.chapterId, equals('ch_export_01'));

      final attempts = await freshDb.assessmentDao.getAttemptsForAssessment('assess_export_01');
      expect(attempts.length, equals(1));
      expect(attempts.first.score, closeTo(0.92, 0.001));
      expect(attempts.first.passed, isTrue);

      final pos = await freshDb.userProgressDao.getReadingPosition('ch_export_01');
      expect(pos?.pageNumber, equals(42));
      expect(pos?.scrollRatio, closeTo(0.75, 0.001));

      final bmarks = await freshDb.userProgressDao.getBookmarksForChapter('ch_export_01');
      expect(bmarks.length, equals(1));
      expect(bmarks.first.sectionTitle, equals('Seção Forense Exportada'));

      final notes = await freshDb.userProgressDao.getAnnotationsForChapter('ch_export_01');
      expect(notes.length, equals(1));
      expect(notes.first.note, equals('Nota associada à evidência'));

      final edition = await freshDb.settingsDao.getSetting('app_edition');
      expect(edition, equals('editorial_v1'));

      await freshDb.close();
    });
  });

  group('Secure Vault (Keystore/DPAPI Abstraction §10.2, §17.1)', () {
    test('maskKey masks sensitive credentials for safe logging', () {
      expect(SecureVaultContract.maskKey('AIzaSyD-gemini-test-key-12345'), equals('AIza...2345'));
      expect(SecureVaultContract.maskKey('12345678'), equals('1234...5678'));
      expect(SecureVaultContract.maskKey(null), equals('***'));
      expect(SecureVaultContract.maskKey(''), equals('***'));
      expect(SecureVaultContract.maskKey('   '), equals('***'));
      expect(SecureVaultContract.maskKey('short'), equals('***'));
    });

    test('InMemorySecureVault stores, retrieves, and clears API key', () async {
      final vault = InMemorySecureVault();
      expect(await vault.hasApiKey(), isFalse);

      await vault.storeApiKey('AIzaSyD-gemini-test-key-12345');
      expect(await vault.hasApiKey(), isTrue);
      expect(await vault.getApiKey(), equals('AIzaSyD-gemini-test-key-12345'));

      await vault.deleteApiKey();
      expect(await vault.hasApiKey(), isFalse);
    });

    test('PlatformSecureVault encrypts credentials and decrypts accurately', () async {
      final vault = PlatformSecureVault(masterSalt: 'test_hardware_uuid_salt');
      await vault.storeApiKey('secret_gemini_api_key_secure_value');

      expect(await vault.hasApiKey(), isTrue);
      expect(await vault.getApiKey(), equals('secret_gemini_api_key_secure_value'));

      // Test arbitrary secure values
      await vault.storeSecureValue('drive_refresh_token', 'rt_token_987654');
      expect(await vault.getSecureValue('drive_refresh_token'), equals('rt_token_987654'));

      await vault.clearAll();
      expect(await vault.hasApiKey(), isFalse);
      expect(await vault.getSecureValue('drive_refresh_token'), isNull);
    });
  });

  group('SQLite FTS5 Full-Text Search in Drift/SQLite (§7.1, §18.3)', () {
    test('indexes sections and queries matches with snippet highlighting', () async {
      await db.indexContentFts5(
        chapterId: 'ch01',
        title: 'Dos Dados às Evidências',
        sectionTitle: 'Cadeia de Custódia',
        bodyText: 'A integridade da prova pericial digital depende do rigor da cadeia de custódia ininterrupta.',
      );
      await db.indexContentFts5(
        chapterId: 'ch02',
        title: 'Sistemas de Arquivos',
        sectionTitle: 'Metadados NTFS',
        bodyText: 'Análise detalhada de timestamps STANDARD_INFORMATION e FILE_NAME na MFT.',
      );

      final hits = await db.searchContentFts5('custódia');
      expect(hits.length, equals(1));
      expect(hits.first['chapter_id'], equals('ch01'));
      expect(hits.first['snippet'].toString(), contains('[MATCH]custódia[/MATCH]'));

      final ntfsHits = await db.searchContentFts5('NTFS');
      expect(ntfsHits.length, equals(1));
      expect(ntfsHits.first['chapter_id'], equals('ch02'));

      final emptyHits = await db.searchContentFts5('termo_inexistente_xyz');
      expect(emptyHits, isEmpty);
    });
  });
}
