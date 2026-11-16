import 'package:flutter_test/flutter_test.dart';
import 'package:content_core/content_core.dart';

void main() {
  group('Adversarial Schema Boundary Testing (Dart Section19Validator)', () {
    late Section19Validator validator;

    setUp(() {
      validator = Section19Validator();
    });

    test('rejects corrupt, truncated, or non-object JSON syntax', () {
      final corruptSamples = [
        '',
        '   ',
        '{"schemaVersion": "1.0", "contentId": ',
        '{"schemaVersion": "1.0", "volume": 1,}',
        '{"unclosed": "brace"',
        '[1, 2, 3]',
        '"just a string"',
        '12345',
        'true',
      ];

      for (final badJson in corruptSamples) {
        final report = validator.validateJsonString(badJson);
        expect(report.isValid, isFalse, reason: 'Bad JSON should fail: $badJson');
        expect(report.errors, isNotEmpty);
      }
    });

    test('rejects missing mandatory top-level fields', () {
      final mandatoryFields = [
        'schemaVersion',
        'contentId',
        'type',
        'volume',
        'chapter',
        'title',
        'language',
        'edition',
        'editorialStatus',
        'source',
        'sections',
      ];

      final baseValid = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Vestígios Digitais',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {
          'provider': 'fixture',
          'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        },
        'sections': [
          {
            'sectionId': 'sec-01',
            'title': 'Introdução',
            'orderIndex': 0,
            'markdownContent': 'Conteúdo de teste.',
          }
        ],
      };

      for (final field in mandatoryFields) {
        final copy = Map<String, dynamic>.from(baseValid);
        copy.remove(field);
        final report = validator.validateJsonMap(copy);
        expect(report.isValid, isFalse, reason: 'Missing $field must be rejected');
        expect(
          report.errors.any((e) => e.contains(field)),
          isTrue,
          reason: 'Error should explicitly cite missing field $field',
        );
      }
    });

    test('rejects invalid contentId regex pattern', () {
      final invalidIds = [
        'forense.vol1.ch01', // single digit vol
        'forense.vol01.ch1', // single digit ch
        'forense.vol001.ch01', // 3 digits vol
        'forense.vol01.ch001', // 3 digits ch
        'forense_vol01_ch01', // underscore
        'FORENSE.VOL01.CH01', // uppercase prefix
        'forense.vol01.ch01.extra', // trailing extension
        'forense.vol01.', // truncated
        'forense.vol.ch01', // missing numbers
        'random_string_id',
      ];

      final baseValid = {
        'schemaVersion': '1.0',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Test',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 's1', 'title': 't', 'markdownContent': 'c'}
        ],
      };

      for (final cid in invalidIds) {
        final map = Map<String, dynamic>.from(baseValid);
        map['contentId'] = cid;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Invalid contentId "$cid" must fail');
        expect(report.errors.any((e) => e.contains('contentId')), isTrue);
      }
    });

    test('rejects out-of-range volume numbers (must be 1..9)', () {
      final outOfRangeVolumes = [-5, -1, 0, 10, 11, 99];
      final baseValid = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'chapter': 1,
        'title': 'Test',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 's1', 'title': 't', 'markdownContent': 'c'}
        ],
      };

      for (final vol in outOfRangeVolumes) {
        final map = Map<String, dynamic>.from(baseValid);
        map['volume'] = vol;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Volume $vol should fail bounds check');
        expect(report.errors.any((e) => e.contains('volume')), isTrue);
      }
    });

    test('rejects out-of-range chapter numbers (must be 1..113)', () {
      final outOfRangeChapters = [-1, 0, 114, 115, 500];
      final baseValid = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'volume': 1,
        'title': 'Test',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 's1', 'title': 't', 'markdownContent': 'c'}
        ],
      };

      for (final ch in outOfRangeChapters) {
        final map = Map<String, dynamic>.from(baseValid);
        map['chapter'] = ch;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Chapter $ch should fail bounds check');
        expect(report.errors.any((e) => e.contains('chapter')), isTrue);
      }
    });

    test('rejects invalid editions, types, and editorial statuses', () {
      final baseValid = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Test',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 's1', 'title': 't', 'markdownContent': 'c'}
        ],
      };

      // Invalid edition (must match ^REV[0-9]+$)
      for (final badEdition in ['1.0', 'v1', 'rev2', 'REV-1', 'EDITION_2', 'REV', 'REVA', 'REV 1']) {
        final map = Map<String, dynamic>.from(baseValid);
        map['edition'] = badEdition;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Edition $badEdition must be rejected');
      }

      // Invalid editorial status
      for (final badStatus in ['draft', 'finished', 'final', 'unknown', 'pending']) {
        final map = Map<String, dynamic>.from(baseValid);
        map['editorialStatus'] = badStatus;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Status $badStatus must be rejected');
      }

      // Invalid type
      for (final badType in ['book', 'magazine', 'lecture', 'exercise']) {
        final map = Map<String, dynamic>.from(baseValid);
        map['type'] = badType;
        final report = validator.validateJsonMap(map);
        expect(report.isValid, isFalse, reason: 'Type $badType must be rejected');
      }
    });
  });

  group('Adversarial Content-Progress Decoupling & Anchor Drift (AnnotationEngine)', () {
    late AnnotationEngine engine;

    setUp(() {
      engine = AnnotationEngine();
    });

    test('preserves notes and clears drift when anchor text is intact in modified chapter', () {
      engine.addAnnotation(
        noteId: 'n1',
        chapterId: 'forense.vol01.ch01',
        revision: 'REV1',
        anchorText: 'cadeia de custódia ininterrupta',
        note: 'Ponto crítico da prova pericial',
      );

      // New revision has expanded text, but the anchor text remains intact
      const newContent = '''
# Capítulo 1 (Revisado)
A rastreabilidade dos vestígios é garantida por meio da cadeia de custódia ininterrupta,
conforme diretrizes da ISO/IEC 27037.
''';

      engine.applyRevisionUpdate(
        chapterId: 'forense.vol01.ch01',
        fromRevision: 'REV1',
        toRevision: 'REV2',
        newContent: newContent,
      );

      final notes = engine.getAnnotationsForChapter('forense.vol01.ch01');
      expect(notes.length, equals(1));
      expect(notes.first.noteId, equals('n1'));
      expect(notes.first.note, equals('Ponto crítico da prova pericial'));
      expect(notes.first.revision, equals('REV2'));
      expect(notes.first.driftWarning, isFalse);
    });

    test('preserves notes and flags drift warning when anchor text is completely removed', () {
      engine.addAnnotation(
        noteId: 'n2',
        chapterId: 'forense.vol01.ch01',
        revision: 'REV1',
        anchorText: 'Algoritmo MD5 é suficiente para perícia criminal',
        note: 'Nota contestando a segurança do MD5',
      );

      // In REV2, the obsolete MD5 reference was entirely deleted and replaced by SHA-256
      const newContent = '''
# Capítulo 1 (Revisado)
Atualmente recomenda-se a utilização exclusiva de funções hash SHA-256 ou superior.
''';

      engine.applyRevisionUpdate(
        chapterId: 'forense.vol01.ch01',
        fromRevision: 'REV1',
        toRevision: 'REV2',
        newContent: newContent,
        reason: 'Substituição de MD5 por SHA-256',
      );

      final notes = engine.getAnnotationsForChapter('forense.vol01.ch01');
      expect(notes.length, equals(1));
      expect(notes.first.noteId, equals('n2'));
      expect(notes.first.note, equals('Nota contestando a segurança do MD5'));
      expect(notes.first.revision, equals('REV2'));
      // Drift detected!
      expect(notes.first.driftWarning, isTrue);

      // Audit journal records the transition
      expect(engine.auditJournal.length, equals(1));
      expect(engine.auditJournal.first.fromRevision, equals('REV1'));
      expect(engine.auditJournal.first.toRevision, equals('REV2'));
    });

    test('handles multiple annotations with mixed intact and drifted anchors', () {
      engine.addAnnotation(
        noteId: 'n-intact',
        chapterId: 'forense.vol01.ch02',
        revision: 'REV1',
        anchorText: 'Entropia de Shannon',
        note: 'H(X) calculada em bits',
      );
      engine.addAnnotation(
        noteId: 'n-drifted',
        chapterId: 'forense.vol01.ch02',
        revision: 'REV1',
        anchorText: 'Texto Removido da Seção 3',
        note: 'Nota sobre seção excluída',
      );

      const updatedText = 'A Entropia de Shannon expressa a incerteza média da informação.';

      engine.applyRevisionUpdate(
        chapterId: 'forense.vol01.ch02',
        fromRevision: 'REV1',
        toRevision: 'REV2',
        newContent: updatedText,
      );

      final annotations = engine.getAnnotationsForChapter('forense.vol01.ch02');
      expect(annotations.length, equals(2));

      final intact = annotations.firstWhere((a) => a.noteId == 'n-intact');
      final drifted = annotations.firstWhere((a) => a.noteId == 'n-drifted');

      expect(intact.driftWarning, isFalse);
      expect(drifted.driftWarning, isTrue);
      // Both notes remain untouched
      expect(intact.note, equals('H(X) calculada em bits'));
      expect(drifted.note, equals('Nota sobre seção excluída'));
    });
  });

  group('Adversarial Offline Search (ContentSearchEngine FTS5)', () {
    late ContentSearchEngine searchEngine;

    setUp(() {
      searchEngine = ContentSearchEngine();
      // Populate standard indexed chapters
      searchEngine.indexDocument(
        chapterId: 'forense.vol01.ch01',
        title: 'Dos Dados às Evidências Digitais',
        sectionTitle: 'Cadeia de Custódia',
        bodyText: 'A cadeia de custódia compreende o rastreamento ininterrupto de vestígios forenses.',
      );
      searchEngine.indexDocument(
        chapterId: 'forense.vol01.ch02',
        title: 'Computação Forense e Entropia',
        sectionTitle: 'Análise Matemática',
        bodyText: 'A entropia de Shannon permite distinguir dados criptografados de arquivos compactados.',
      );
      searchEngine.indexDocument(
        chapterId: 'forense.vol05.ch54',
        title: 'Telefonia e Registros CDR',
        sectionTitle: 'Extração de ERBs',
        bodyText: 'Registros de detalhamento de chamadas CDR indicam azimute e célula ERB utilizada pelo terminal.',
      );
    });

    tearDown(() {
      searchEngine.close();
    });

    test('empty or whitespace queries return empty results without throwing', () {
      expect(searchEngine.search(''), isEmpty);
      expect(searchEngine.search('   '), isEmpty);
      expect(searchEngine.search('\t\n\r'), isEmpty);
    });

    test('queries with extreme special characters do not crash FTS5 or leak syntax errors', () {
      final trickyQueries = [
        '"',
        '""',
        '"""',
        '*',
        '**',
        '***',
        'AND',
        'AND AND',
        'OR',
        'NOT',
        'NEAR()',
        '()',
        '[]',
        '{}',
        '^',
        ':',
        '+',
        '-',
        '":""',
        'MATCH *',
        'SELECT * FROM fts_content;',
        "'; DROP TABLE fts_content; --",
        "' OR '1'='1",
      ];

      for (final query in trickyQueries) {
        expect(() => searchEngine.search(query), returnsNormally, reason: 'Failed safely on query: $query');
      }
    });

    test('non-existent terms return empty list cleanly', () {
      final results = searchEngine.search('termo_inexistente_xyz_99999');
      expect(results, isEmpty);
    });

    test('valid queries with accents and prefix wildcards match accurately', () {
      // Accent match
      final hits1 = searchEngine.search('custódia');
      expect(hits1.length, equals(1));
      expect(hits1.first.chapterId, equals('forense.vol01.ch01'));
      expect(hits1.first.snippet, contains('[MATCH]custódia[/MATCH]'));

      // Prefix wildcard match
      final hits2 = searchEngine.search('entrop*');
      expect(hits2.length, equals(1));
      expect(hits2.first.chapterId, equals('forense.vol01.ch02'));

      // Boolean AND
      final hits3 = searchEngine.search('cadeia AND vestígios');
      expect(hits3.length, equals(1));
      expect(hits3.first.chapterId, equals('forense.vol01.ch01'));
    });
  });

  group('Curriculum & Print Baseline Verification', () {
    test('verifies exactly 9 volumes and 113 chapters continuity', () {
      expect(CurriculumCatalog.volumes.length, equals(9));

      var currentChapter = 1;
      for (final vol in CurriculumCatalog.volumes) {
        expect(vol.chapterStart, equals(currentChapter), reason: 'Volume ${vol.volumeId} start gap');
        expect(vol.chapterCount, equals(vol.chapterEnd - vol.chapterStart + 1));
        currentChapter = vol.chapterEnd + 1;
      }
      expect(currentChapter - 1, equals(113), reason: 'Final chapter must be 113');
    });

    test('verifies exact 133 printed pages boundary for Volume 1', () {
      final vol1 = CurriculumCatalog.getVolumeInfo(1);
      expect(vol1.printedPages, equals(133));
      expect(Volume1PrintPreservation.totalPrintedPages, equals(133));
    });

    test('enforces errata page bounds strictly [1..133]', () {
      final printPreservation = Volume1PrintPreservation();

      // Valid errata on page 1 and page 133
      printPreservation.addErrata(const ErrataEntry(
        errataId: 'err-01',
        volumeId: 1,
        chapterNumber: 1,
        chapterId: 'forense.vol01.ch01',
        revision: 'REV2',
        printedPageNumber: 1,
        originalText: 'Original',
        correctedText: 'Correção de data na introdução.',
      ));
      printPreservation.addErrata(const ErrataEntry(
        errataId: 'err-133',
        volumeId: 1,
        chapterNumber: 10,
        chapterId: 'forense.vol01.ch10',
        revision: 'REV1',
        printedPageNumber: 133,
        originalText: 'Original bibliografia',
        correctedText: 'Ajuste de bibliografia na página final.',
      ));

      expect(printPreservation.allErrata.length, equals(2));

      // Boundary violations: page 0 and page 134 must throw RangeError
      expect(
        () => printPreservation.addErrata(const ErrataEntry(
          errataId: 'err-invalid-0',
          volumeId: 1,
          chapterNumber: 1,
          chapterId: 'forense.vol01.ch01',
          revision: 'REV2',
          printedPageNumber: 0,
          originalText: 'Original',
          correctedText: 'Página zero inválida',
        )),
        throwsA(isA<RangeError>()),
      );

      expect(
        () => printPreservation.addErrata(const ErrataEntry(
          errataId: 'err-invalid-134',
          volumeId: 1,
          chapterNumber: 10,
          chapterId: 'forense.vol01.ch10',
          revision: 'REV1',
          printedPageNumber: 134,
          originalText: 'Original',
          correctedText: 'Página 134 além do limite',
        )),
        throwsA(isA<RangeError>()),
      );
    });

    test('verifies canonical revision rules for Volume 1 (Ch 1-4 REV2, Ch 5-10 REV1)', () {
      for (var ch = 1; ch <= 4; ch++) {
        expect(Volume1PrintPreservation.getCanonicalRevision(ch), equals('REV2'));
        expect(Volume1PrintPreservation.validateChapterRevision(ch, 'REV2'), isTrue);
        expect(Volume1PrintPreservation.validateChapterRevision(ch, 'REV1'), isFalse);
      }
      for (var ch = 5; ch <= 10; ch++) {
        expect(Volume1PrintPreservation.getCanonicalRevision(ch), equals('REV1'));
        expect(Volume1PrintPreservation.validateChapterRevision(ch, 'REV1'), isTrue);
        expect(Volume1PrintPreservation.validateChapterRevision(ch, 'REV2'), isFalse);
      }
      expect(() => Volume1PrintPreservation.getCanonicalRevision(11), throwsArgumentError);
    });

    test('verifies 7-state editorial lifecycle transitions', () {
      expect(CurriculumCatalog.editorialStates.length, equals(7));
      expect(CurriculumCatalog.canTransition('Planejado', 'Importado'), isTrue);
      expect(CurriculumCatalog.canTransition('Planejado', 'Publicado'), isFalse);
      expect(CurriculumCatalog.canTransition('Importado', 'Em revisão'), isTrue);
      expect(CurriculumCatalog.canTransition('Em revisão', 'Aprovado'), isTrue);
      expect(CurriculumCatalog.canTransition('Aprovado', 'Publicado'), isTrue);
      expect(CurriculumCatalog.canTransition('Publicado', 'Substituído'), isTrue);
      expect(CurriculumCatalog.canTransition('Publicado', 'Arquivado'), isTrue);
      expect(CurriculumCatalog.canTransition('Arquivado', 'Publicado'), isFalse);
    });
  });
}
