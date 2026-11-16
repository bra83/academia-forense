import 'package:flutter_test/flutter_test.dart';
import 'package:content_core/content_core.dart';

void main() {
  group('ChapterPackage & Models Serialization', () {
    test('round-trips ChapterPackage to and from JSON', () {
      const sample = ChapterPackage(
        schemaVersion: '1.0',
        contentId: 'forense.vol01.ch01',
        type: 'chapter',
        volume: 1,
        chapter: 1,
        title: 'Dos Dados às Evidências Digitais',
        language: 'pt-BR',
        edition: 'REV2',
        editorialStatus: 'Publicado',
        source: PackageSource(
          provider: 'fixture',
          fileId: 'seed_vol01_ch01_rev2',
          revision: '2.0',
          sha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        ),
        sections: [
          SectionItem(
            sectionId: 'sec-01',
            title: '1.1 Da Informação Bruta ao Vestígio',
            orderIndex: 0,
            markdownContent: 'Texto explicativo com fórmula: \$H(X) = -\\sum P(x) \\log_2 P(x)\$',
            anchorKey: 'sec01_anchor',
          ),
        ],
        learningObjectives: [
          'Diferenciar dados de vestígios e evidências.',
          'Calcular entropia de Shannon em artefatos binários.',
        ],
        prerequisites: [],
        glossary: [
          GlossaryItem(
            term: 'Vestígio',
            definition: 'Todo objeto ou material bruto encontrado no local do fato.',
          ),
        ],
        figures: [
          FigureItem(
            figureId: 'fig-01',
            caption: 'Diagrama de fluxo probatório',
            assetPath: 'assets/figures/ch01_flow.png',
          ),
        ],
        tables: [
          TableItem(
            tableId: 'tbl-01',
            caption: 'Entropia de formatos de arquivo',
            headers: ['Formato', 'Entropia'],
            rows: [
              ['TXT', 4.1],
              ['ZIP', 7.9],
            ],
          ),
        ],
        references: [
          ReferenceItem(
            citationKey: 'ISO27037',
            formattedText: 'ISO/IEC 27037: Guidelines for identification, collection, acquisition and preservation of digital evidence.',
            year: 2012,
          ),
        ],
        exercises: [
          ExerciseItem(
            exerciseId: 'ex-01',
            prompt: 'O que define a cadeia de custódia?',
            exerciseType: 'objective',
            solution: 'Histórico ininterrupto e documentado da posse do vestígio.',
          ),
        ],
        laboratories: [
          LaboratoryItem(
            labId: 'lab-01',
            domain: 'digital_forensics',
            title: 'Cálculo de Hashes de Evidência',
            instructions: 'Calcule o hash SHA-256 da imagem pericial fornecida.',
            expectedResult: 'Hashes idênticos antes e após a análise.',
          ),
        ],
        assessment: AssessmentItem(
          assessmentId: 'eval-ch01',
          passingScorePercent: 80.0,
          questions: [
            AssessmentQuestion(
              questionId: 'q-01',
              prompt: 'A cadeia de custódia prevê quantas etapas no art. 158-B do CPP?',
              type: 'multiple_choice',
              points: 100.0,
              options: [
                AssessmentOption(optionId: 'opt-a', text: '10 etapas', isCorrect: true),
                AssessmentOption(optionId: 'opt-b', text: '5 etapas', isCorrect: false),
              ],
            ),
          ],
        ),
        audio: AudioMetadata(
          enabled: true,
          language: 'pt-BR',
          voicePreferred: 'pt-BR-Kokoro-Braseiro',
        ),
      );

      final jsonMap = sample.toJson();
      final reconstructed = ChapterPackage.fromJson(jsonMap);

      expect(reconstructed.contentId, equals('forense.vol01.ch01'));
      expect(reconstructed.edition, equals('REV2'));
      expect(reconstructed.volume, equals(1));
      expect(reconstructed.chapter, equals(1));
      expect(reconstructed.sections.length, equals(1));
      expect(reconstructed.sections.first.markdownContent, contains('\\sum'));
      expect(reconstructed.glossary.length, equals(1));
      expect(reconstructed.assessment?.questions.first.options.first.isCorrect, isTrue);

      final computedSha = sample.computeContentSha256();
      expect(computedSha.length, equals(64));
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(computedSha), isTrue);
    });

    test('ErrataEntry serialization and deserialization', () {
      final errata = ErrataEntry(
        errataId: 'err-001',
        volumeId: 1,
        chapterNumber: 1,
        chapterId: 'forense.vol01.ch01',
        revision: 'REV2',
        printedPageNumber: 42,
        originalText: 'Texto antigo',
        correctedText: 'Texto corrigido',
        justification: 'Correção terminológica',
      );

      final map = errata.toJson();
      final roundTrip = ErrataEntry.fromJson(map);

      expect(roundTrip.errataId, equals('err-001'));
      expect(roundTrip.printedPageNumber, equals(42));
      expect(roundTrip.correctedText, equals('Texto corrigido'));
    });
  });

  group('Section19Validator', () {
    final validator = Section19Validator();

    test('validates correct package successfully', () {
      final jsonMap = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Dos Dados às Evidências Digitais',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {
          'provider': 'fixture',
          'fileId': 'seed_ch01',
          'revision': '2.0',
          'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        },
        'sections': [
          {
            'sectionId': 'sec-01',
            'title': '1.1 Introdução',
            'orderIndex': 0,
            'markdownContent': 'Conteúdo de introdução.',
          }
        ],
        'learningObjectives': ['Compreender conceitos periciais fundamentais.'],
        'prerequisites': [],
        'glossary': [
          {'term': 'Vestígio', 'definition': 'Elemento material bruto.'}
        ],
        'figures': [],
        'tables': [],
        'references': [],
        'exercises': [],
        'laboratories': [],
        'assessment': {
          'assessmentId': 'eval-01',
          'passingScorePercent': 80.0,
          'questions': [
            {
              'questionId': 'q-01',
              'prompt': 'Pergunta?',
              'type': 'multiple_choice',
              'points': 100,
              'options': [
                {'optionId': 'o-1', 'text': 'Opção', 'isCorrect': true}
              ]
            }
          ]
        },
        'audio': {'enabled': true, 'language': 'pt-BR'},
      };

      final report = validator.validateJsonMap(jsonMap);
      expect(report.isValid, isTrue, reason: report.errors.join('\n'));
      expect(report.errors, isEmpty);
    });

    test('rejects missing mandatory fields', () {
      final jsonMap = {
        'schemaVersion': '1.0',
        'type': 'chapter',
      };
      final report = validator.validateJsonMap(jsonMap);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.contains('contentId')), isTrue);
      expect(report.errors.any((e) => e.contains('sections')), isTrue);
    });

    test('rejects invalid contentId regex pattern', () {
      final jsonMap = {
        'schemaVersion': '1.0',
        'contentId': 'invalid_content_id',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Capítulo',
        'language': 'pt-BR',
        'edition': 'REV2',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 'sec-1', 'title': 'T', 'orderIndex': 0, 'markdownContent': 'C'}
        ],
      };
      final report = validator.validateJsonMap(jsonMap);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.contains('contentId')), isTrue);
    });

    test('rejects invalid edition enum pattern', () {
      final jsonMap = {
        'schemaVersion': '1.0',
        'contentId': 'forense.vol01.ch01',
        'type': 'chapter',
        'volume': 1,
        'chapter': 1,
        'title': 'Capítulo',
        'language': 'pt-BR',
        'edition': 'DRAFT_UNAUTHORIZED',
        'editorialStatus': 'Publicado',
        'source': {'provider': 'fixture'},
        'sections': [
          {'sectionId': 'sec-1', 'title': 'T', 'orderIndex': 0, 'markdownContent': 'C'}
        ],
      };
      final report = validator.validateJsonMap(jsonMap);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.contains('edition')), isTrue);
    });
  });

  group('CurriculumCatalog', () {
    test('covers 9 volumes and 113 chapters continuously', () {
      expect(CurriculumCatalog.volumes.length, equals(9));

      var currentCh = 1;
      for (final vol in CurriculumCatalog.volumes) {
        expect(vol.chapterStart, equals(currentCh));
        expect(vol.chapterEnd, greaterThanOrEqualTo(vol.chapterStart));
        currentCh = vol.chapterEnd + 1;
      }
      expect(currentCh - 1, equals(113));
    });

    test('maps chapters to volumes correctly', () {
      expect(CurriculumCatalog.getVolumeForChapter(1), equals(1));
      expect(CurriculumCatalog.getVolumeForChapter(10), equals(1));
      expect(CurriculumCatalog.getVolumeForChapter(11), equals(2));
      expect(CurriculumCatalog.getVolumeForChapter(24), equals(3));
      expect(CurriculumCatalog.getVolumeForChapter(54), equals(5));
      expect(CurriculumCatalog.getVolumeForChapter(113), equals(9));
      expect(() => CurriculumCatalog.getVolumeForChapter(114), throwsArgumentError);
    });

    test('verifies 7 editorial states and public availability filter', () {
      expect(CurriculumCatalog.editorialStates.length, equals(7));
      expect(CurriculumCatalog.isPubliclyAvailable('Aprovado'), isTrue);
      expect(CurriculumCatalog.isPubliclyAvailable('Publicado'), isTrue);
      expect(CurriculumCatalog.isPubliclyAvailable('Planejado'), isFalse);
      expect(CurriculumCatalog.isPubliclyAvailable('Importado'), isFalse);
      expect(CurriculumCatalog.isPubliclyAvailable('Em revisão'), isFalse);
      expect(CurriculumCatalog.isPubliclyAvailable('Substituído'), isFalse);
      expect(CurriculumCatalog.isPubliclyAvailable('Arquivado'), isFalse);
    });

    test('validates lifecycle transitions', () {
      expect(CurriculumCatalog.canTransition('Planejado', 'Importado'), isTrue);
      expect(CurriculumCatalog.canTransition('Importado', 'Em revisão'), isTrue);
      expect(CurriculumCatalog.canTransition('Em revisão', 'Aprovado'), isTrue);
      expect(CurriculumCatalog.canTransition('Aprovado', 'Publicado'), isTrue);
      expect(CurriculumCatalog.canTransition('Publicado', 'Planejado'), isFalse);
    });
  });

  group('DualModeReader', () {
    test('switches modes and preserves reading position', () {
      final reader = DualModeReader(
        documentId: 'doc-ch01',
        pdfPath: '/path/to/vol01_ch01.pdf',
        markdownContent: '# Perícia Digital\n\nFórmula: \$H(X) = -\\sum P(x) \\log_2 P(x)\$',
        metadata: {
          'volume': 1,
          'chapter': 1,
          'revision': 'REV2',
          'sha256': 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
        },
      );

      expect(reader.currentMode, equals('markdown_study'));
      reader.currentPage = 14;
      reader.scrollRatio = 0.62;

      reader.switchMode('pdf_verbatim');
      expect(reader.currentMode, equals('pdf_verbatim'));
      expect(reader.currentPage, equals(14));
      expect(reader.scrollRatio, closeTo(0.62, 0.001));

      final prov = reader.getOriginProvenance();
      expect(prov.volume, equals(1));
      expect(prov.chapter, equals(1));
      expect(prov.revision, equals('REV2'));
      expect(prov.originalPage, equals(14));
      expect(prov.sha256, contains('e3b0c442'));

      expect(
        DualModeReader.recommendedModeForContent(
          hasComplexDiagram: true,
          transcriptionComplete: true,
        ),
        equals('pdf_verbatim'),
      );
    });
  });

  group('ContentSearchEngine (Real SQLite FTS5)', () {
    late ContentSearchEngine engine;

    setUp(() {
      engine = ContentSearchEngine();
      engine.indexDocument(
        chapterId: 'ch01',
        title: 'Dos Dados às Evidências',
        sectionTitle: 'Cadeia de Custódia',
        bodyText: 'A preservação da cadeia de custódia garante a integridade dos vestígios digitais e evita nulidades processuais.',
      );
      engine.indexDocument(
        chapterId: 'ch02',
        title: 'Sistemas de Arquivos',
        sectionTitle: 'Metadados NTFS',
        bodyText: 'A análise da tabela MFT no NTFS permite recuperar timestamps STANDARD_INFORMATION e FILE_NAME.',
      );
    });

    tearDown(() {
      engine.close();
    });

    test('exact keyword search matches expected chapter', () {
      final results = engine.search('custódia');
      expect(results.length, equals(1));
      expect(results.first.chapterId, equals('ch01'));
      expect(results.first.sectionTitle, contains('Cadeia de Custódia'));
    });

    test('prefix search matches root words', () {
      final results = engine.search('vestígi*');
      expect(results.length, equals(1));
      expect(results.first.chapterId, equals('ch01'));
    });

    test('snippet generation highlights matched term in [MATCH] tags', () {
      final results = engine.search('NTFS');
      expect(results.length, equals(1));
      expect(results.first.snippet, contains('[MATCH]NTFS[/MATCH]'));
    });

    test('multiple terms with AND operator', () {
      final results = engine.search('cadeia AND integridade');
      expect(results.length, equals(1));
      expect(results.first.chapterId, equals('ch01'));
    });

    test('no matches returns empty list cleanly without throwing', () {
      final results = engine.search('termo_inexistente_xyz_999');
      expect(results, isEmpty);
    });
  });

  group('AnnotationEngine (Decoupling & Drift Tolerance)', () {
    test('preserves notes and detects anchor drift on revision update', () {
      final engine = AnnotationEngine();
      engine.addAnnotation(
        noteId: 'n1',
        chapterId: 'ch01',
        revision: 'REV1',
        anchorText: 'Cadeia de custódia preliminar',
        note: 'Verificar portaria da PF',
      );
      engine.addAnnotation(
        noteId: 'n2',
        chapterId: 'ch01',
        revision: 'REV1',
        anchorText: 'Termo Permanente',
        note: 'Nota sobre termo permanente',
      );

      expect(engine.annotations.length, equals(2));

      // Revision update where "Termo Permanente" exists, but "Cadeia de custódia preliminar" does not
      const newText = 'Aqui temos o Termo Permanente, mas o texto anterior foi totalmente reescrito.';
      engine.applyRevisionUpdate(
        chapterId: 'ch01',
        fromRevision: 'REV1',
        toRevision: 'REV2',
        newContent: newText,
        reason: 'Atualização para REV2',
      );

      final ann1 = engine.annotations.firstWhere((a) => a.noteId == 'n1');
      final ann2 = engine.annotations.firstWhere((a) => a.noteId == 'n2');

      // Notes are NOT deleted!
      expect(ann1.revision, equals('REV2'));
      expect(ann1.driftWarning, isTrue); // Anchor missing -> drift warning
      expect(ann1.note, equals('Verificar portaria da PF'));

      expect(ann2.revision, equals('REV2'));
      expect(ann2.driftWarning, isFalse); // Anchor found -> no drift warning

      expect(engine.auditJournal.length, equals(1));
      expect(engine.auditJournal.first.fromRevision, equals('REV1'));
      expect(engine.auditJournal.first.toRevision, equals('REV2'));
    });
  });

  group('Volume1PrintPreservation & Errata', () {
    test('exact 133 printed pages baseline and canonical revisions', () {
      expect(Volume1PrintPreservation.totalPrintedPages, equals(133));

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
    });

    test('errata table attaches to physical page (1-133)', () {
      final printMgr = Volume1PrintPreservation();
      printMgr.addErrata(
        const ErrataEntry(
          errataId: 'err-1',
          volumeId: 1,
          chapterNumber: 1,
          chapterId: 'forense.vol01.ch01',
          revision: 'REV2',
          printedPageNumber: 12,
          originalText: 'Texto original',
          correctedText: 'Texto corrigido',
        ),
      );

      final found = printMgr.getErrataForChapterAndPage(1, 12);
      expect(found.length, equals(1));
      expect(found.first.correctedText, equals('Texto corrigido'));

      // Rejects out-of-bounds page > 133
      expect(
        () => printMgr.addErrata(
          const ErrataEntry(
            errataId: 'err-bad',
            volumeId: 1,
            chapterNumber: 1,
            chapterId: 'forense.vol01.ch01',
            revision: 'REV2',
            printedPageNumber: 134,
            originalText: 'A',
            correctedText: 'B',
          ),
        ),
        throwsRangeError,
      );
    });
  });

  group('CurriculumManifestValidator (§24.3)', () {
    final validator = CurriculumManifestValidator();

    test('validates correct curriculum manifest with all 7 official states', () {
      final manifestMap = {
        'curriculumId': 'cur-test-2026',
        'title': 'Academia Forense',
        'version': '1.0',
        'language': 'pt-BR',
        'totalVolumes': 9,
        'totalChapters': 113,
        'editorialStatusDistribution': {
          'Planejado': 87,
          'Importado': 0,
          'Em revisão': 16,
          'Aprovado': 0,
          'Publicado': 10,
          'Substituído': 0,
          'Arquivado': 0,
        },
        'volume1PrintPreservation': {
          'volumeId': 1,
          'exactPrintedPages': 133,
          'canonicalRevisions': {
            'chapters1to4': 'REV2',
            'chapters5to10': 'REV1',
          },
          'errataTable': 'content/fixtures/volume_01/vol01_errata.json',
        },
        'volumes': List.generate(
          9,
          (i) => {
            'volume_id': i + 1,
            'roman': 'Volume ${i + 1}',
            'title': 'Título ${i + 1}',
            'chapter_start': 1,
            'chapter_end': 10,
            'chapter_count': 10,
            'area': 'Área',
          },
        ),
        'chapters': List.generate(
          113,
          (i) => {
            'volume_id': 1,
            'volume_title': 'Fundamentos',
            'chapter_id': i + 1,
            'content_id': 'forense.vol01.ch${(i + 1).toString().padLeft(2, '0')}',
            'title': 'Capítulo ${i + 1}',
            'slug': 'ch-${i + 1}',
            'expected_revision': 'REV1',
            'editorial_status': 'Planejado',
            'language': 'pt-BR',
          },
        ),
      };

      final report = validator.validateJsonMap(manifestMap);
      expect(report.isValid, isTrue, reason: report.errors.join('\n'));
    });

    test('rejects manifest missing any of the 7 editorial states', () {
      final incompleteMap = {
        'curriculumId': 'cur-test-2026',
        'title': 'Academia Forense',
        'version': '1.0',
        'language': 'pt-BR',
        'totalVolumes': 9,
        'totalChapters': 113,
        'editorialStatusDistribution': {
          'Planejado': 87,
          'Em revisão': 16,
          'Publicado': 10,
          // Missing Importado, Aprovado, Substituído, Arquivado
        },
        'volume1PrintPreservation': {
          'volumeId': 1,
          'exactPrintedPages': 133,
          'canonicalRevisions': {'chapters1to4': 'REV2', 'chapters5to10': 'REV1'},
          'errataTable': 'errata.json',
        },
        'volumes': List.generate(9, (i) => {}),
        'chapters': List.generate(113, (i) => {}),
      };

      final report = validator.validateJsonMap(incompleteMap);
      expect(report.isValid, isFalse);
      expect(report.errors.any((e) => e.contains('Importado')), isTrue);
      expect(report.errors.any((e) => e.contains('Arquivado')), isTrue);
    });
  });
}
