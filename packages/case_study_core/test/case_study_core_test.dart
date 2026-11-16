import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:crypto/crypto.dart';
import 'package:persistence_core/persistence_core.dart';
import 'package:case_study_core/case_study_core.dart';

void main() {
  group('CaseOntology (§15.2, §15.3)', () {
    test('Tripartite ontology categories match §15.2', () {
      expect(CaseOntologyCategory.values.length, equals(3));
      final values = CaseOntologyCategory.values.map((c) => c.value).toSet();
      expect(values, equals({'FATO_DOCUMENTADO', 'INFERENCIA', 'HIPOTESE_ALTERNATIVA'}));
    });

    test('CaseNature enum matches §15.3', () {
      expect(CaseNature.values.length, equals(3));
      expect(CaseNature.fromValue('documentedcase'), equals(CaseNature.documentedCase));
      expect(CaseNature.fromValue('syntheticCase'), equals(CaseNature.syntheticCase));
      expect(CaseNature.fromValue('hypotheticalExercise'), equals(CaseNature.hypotheticalExercise));
    });

    test('CaseEntry model serialization and deserialization', () {
      final now = DateTime(2026, 11, 16, 12, 0);
      final entry = CaseEntry(
        id: 'entry-01',
        category: CaseOntologyCategory.documentedFact,
        description: 'Conexão na ERB Savassi às 10:45',
        linkedFactIds: [],
        timestamp: now,
      );

      final map = entry.toMap();
      expect(map['category'], equals('FATO_DOCUMENTADO'));

      final restored = CaseEntry.fromMap(map);
      expect(restored.id, equals('entry-01'));
      expect(restored.category, equals(CaseOntologyCategory.documentedFact));
      expect(restored.description, equals('Conexão na ERB Savassi às 10:45'));
    });
  });

  group('CaseMethodologyValidator (§15.2)', () {
    test('Valid submission with documented facts and grounded inferences passes', () {
      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'Registro no firewall de tentativa de login às 03:14',
        ),
        const CaseEntry(
          id: 'F2',
          category: CaseOntologyCategory.documentedFact,
          description: 'Captura de tráfego indicando IP de origem externa',
        ),
        const CaseEntry(
          id: 'INF1',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Atacante possuía acesso externo à rede corporativa',
          linkedFactIds: ['F1', 'F2'],
        ),
        const CaseEntry(
          id: 'H1',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese A: Credencial de funcionário vazada',
        ),
        const CaseEntry(
          id: 'H2',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese B: Exploração de dia zero no gateway VPN',
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);
      expect(result.isValidMethodology, isTrue);
      expect(result.factsCount, equals(2));
      expect(result.inferencesCount, equals(1));
      expect(result.hypothesesCount, equals(2));
      expect(result.unlinkedInferences, isEmpty);
      expect(result.competingHypotheses.length, equals(2));
    });

    test('Ungrounded inference without fact link fails validation', () {
      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'Porta 22 aberta',
        ),
        const CaseEntry(
          id: 'INF_UNGROUNDED',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Suspeito apagou os logs intencionalmente',
          linkedFactIds: [], // Empty link!
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);
      expect(result.isValidMethodology, isFalse);
      expect(result.unlinkedInferences, contains('INF_UNGROUNDED'));
      expect(result.validationErrors.any((e) => e.contains('Inferência não fundamentada')), isTrue);
    });

    test('Submission with zero documented facts fails validation', () {
      final entries = [
        const CaseEntry(
          id: 'H1',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese sem qualquer fato preliminar',
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);
      expect(result.isValidMethodology, isFalse);
      expect(result.validationErrors.any((e) => e.contains('Nenhum fato documentado')), isTrue);
    });
  });

  group('ForensicTimelineReconstruction (§15.2)', () {
    test('Multi-source events sorted strictly chronologically', () {
      final events = [
        TimelineEvent(
          id: 'EV3',
          timestamp: DateTime(2026, 11, 16, 11, 20),
          sourceType: TimelineSourceType.telephonyCdr,
          sourceIdentifier: 'ERB_PAMPULHA',
          description: 'Chamada conectada na ERB Pampulha',
        ),
        TimelineEvent(
          id: 'EV1',
          timestamp: DateTime(2026, 11, 16, 10, 15),
          sourceType: TimelineSourceType.systemLog,
          sourceIdentifier: 'FIREWALL_01',
          description: 'Conexão VPN autorizada',
        ),
        TimelineEvent(
          id: 'EV2',
          timestamp: DateTime(2026, 11, 16, 10, 45),
          sourceType: TimelineSourceType.testimony,
          sourceIdentifier: 'DEPOIMENTO_TESTEMUNHA',
          description: 'Testemunha afirma ter visto suspeito no escritório',
        ),
      ];

      final sorted = ForensicTimelineReconstruction.sortChronologically(events);
      expect(sorted[0].id, equals('EV1'));
      expect(sorted[1].id, equals('EV2'));
      expect(sorted[2].id, equals('EV3'));
    });

    test('Timeline gap detection identifies unrecorded periods', () {
      final events = [
        TimelineEvent(
          id: 'EV1',
          timestamp: DateTime(2026, 11, 16, 10, 0),
          sourceType: TimelineSourceType.systemLog,
          sourceIdentifier: 'LOG',
          description: 'Evento 1',
        ),
        TimelineEvent(
          id: 'EV2',
          timestamp: DateTime(2026, 11, 16, 14, 0), // 4 hours later!
          sourceType: TimelineSourceType.systemLog,
          sourceIdentifier: 'LOG',
          description: 'Evento 2',
        ),
      ];

      final gaps = ForensicTimelineReconstruction.detectGaps(
        events,
        const Duration(hours: 2),
      );
      expect(gaps.length, equals(1));
      expect(gaps.first.gapDuration.inHours, equals(4));
    });
  });

  group('PortfolioReportExporter & Signed PDF (§16, §16.1)', () {
    test('Generates report bundle with genuine SHA-256 signature and mandatory disclaimer', () {
      final bundle = PortfolioReportExporter.generateReportBundle(
        activityId: 'lab-hash-01',
        studentName: 'Aluno Forense',
        methodology: 'Cálculo de hashes segundo ISO 27037',
        resultsSummary: 'SHA-256 e MD5 validados com sucesso.',
        timestampOverride: '2026-11-16T11:20:00Z',
      );

      expect(bundle.activityId, equals('lab-hash-01'));
      expect(bundle.studentName, equals('Aluno Forense'));
      expect(bundle.sha256Signature.length, equals(64));

      // Mandatory disclaimer verification (§16.1)
      expect(bundle.disclaimer, contains('DECLARAÇÃO EDUCACIONAL INTERNA'));
      expect(bundle.disclaimer, contains('Não constitui laudo pericial oficial'));

      // Check signature math
      final raw = 'lab-hash-01|Aluno Forense|2026-11-16T11:20:00Z|Cálculo de hashes segundo ISO 27037|SHA-256 e MD5 validados com sucesso.';
      final expectedSig = sha256.convert(utf8.encode(raw)).toString();
      expect(bundle.sha256Signature, equals(expectedSig));
      expect(bundle.verifyIntegrity(), isTrue);
    });

    test('Cryptographic signature tampering detection', () {
      final bundle = PortfolioReportExporter.generateReportBundle(
        activityId: 'case-01',
        studentName: 'Discente A',
        methodology: 'Metodologia Original Rigorosa',
        resultsSummary: 'Resultados Genuínos',
        timestampOverride: '2026-11-16T10:00:00Z',
      );

      final isTampered = !PortfolioReportExporter.verifyReportTampering(
        activityId: bundle.activityId,
        studentName: bundle.studentName,
        timestamp: bundle.timestamp,
        methodology: 'Metodologia Adulterada Ilegitima',
        resultsSummary: bundle.resultsSummary,
        signature: bundle.sha256Signature,
      );

      expect(isTampered, isTrue, reason: 'Altering report content must invalidate cryptographic signature');
    });

    test('Authentic PDF byte generation contains %PDF- magic bytes and text', () {
      final bundle = PortfolioReportExporter.generateReportBundle(
        activityId: 'case-pdf-01',
        studentName: 'Perito Estudante',
        methodology: 'Exame de Evidência Digital',
        resultsSummary: 'Assinatura digital preservada.',
        timestampOverride: '2026-11-16T10:00:00Z',
        includePdf: true,
      );

      expect(bundle.pdfBytes, isNotNull);
      final bytes = bundle.pdfBytes!;

      // Verify PDF header magic bytes: %PDF-
      expect(bytes.length, greaterThan(100));
      expect(bytes[0], equals(0x25)); // %
      expect(bytes[1], equals(0x50)); // P
      expect(bytes[2], equals(0x44)); // D
      expect(bytes[3], equals(0x46)); // F
      expect(bytes[4], equals(0x2D)); // -

      final pdfString = utf8.decode(bytes, allowMalformed: true);
      expect(pdfString.contains('%%EOF'), isTrue);
      expect(pdfString.contains('ACADEMIA FORENSE'), isTrue);
      expect(pdfString.contains('EDUCACIONAL INTERNA'), isTrue);
    });

    test('Case submission recording in persistence_core (LaboratoryDao)', () async {
      final db = AppDatabase(DatabaseConnectionFactory.inMemory());
      addTearDown(db.close);

      // Seed curriculum -> volume -> chapter -> case study
      await db.curriculumDao.insertCurriculum(
        CurriculumsCompanion.insert(
          id: 'curr_case_test',
          name: 'Currículo Casos',
          version: '1.0',
          description: 'Desc',
        ),
      );
      await db.curriculumDao.insertVolume(
        VolumesCompanion.insert(
          id: 'vol_case_test',
          curriculumId: 'curr_case_test',
          volumeNumber: 1,
          title: 'Volume Casos',
          discipline: 'Telefonia',
          description: 'Desc',
          totalChapters: 1,
        ),
      );
      await db.curriculumDao.insertChapter(
        ChaptersCompanion.insert(
          id: 'ch_case_test',
          volumeId: 'vol_case_test',
          chapterNumber: 1,
          title: 'Capítulo Caso',
          orderIndex: 1,
        ),
      );
      await db.laboratoryDao.insertCaseStudy(
        CaseStudiesCompanion.insert(
          id: 'case_telephony_01',
          chapterId: 'ch_case_test',
          caseTitle: 'Caso Extorsão Telefônica',
          incidentSummary: 'Análise de ERBs e CDRs do suspeito',
          documentedFactsJson: '[]',
          investigativeInferencesJson: '[]',
          alternativeHypothesesJson: '[]',
          evidentialMatrixJson: '{}',
        ),
      );

      final bundle = PortfolioReportExporter.generateReportBundle(
        activityId: 'case_telephony_01',
        studentName: 'Perito Aluno',
        methodology: 'Triangulação de antenas ERB',
        resultsSummary: 'Compatibilidade com presença no setor A',
      );

      final submissionId = await PortfolioReportExporter.recordCaseSubmission(
        laboratoryDao: db.laboratoryDao,
        caseStudyId: 'case_telephony_01',
        reportBundle: bundle,
        conclusionText: 'Conclui-se pela compatibilidade técnica da localização.',
        hypothesisEvaluation: {'H1': 'CONFIRMADA', 'H2': 'DESCARTADA'},
        reportPdfPath: '/data/reports/report_01.pdf',
      );

      expect(submissionId, startsWith('sub_case_telephony_01_'));

      final submissions = await db.laboratoryDao.getSubmissionsForCase('case_telephony_01');
      expect(submissions.length, equals(1));
      expect(submissions.first.id, equals(submissionId));
      expect(submissions.first.conclusionText, contains('Conclui-se pela compatibilidade'));
    });
  });
}
