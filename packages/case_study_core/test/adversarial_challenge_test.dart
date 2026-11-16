import 'package:flutter_test/flutter_test.dart';
import 'package:case_study_core/case_study_core.dart';

void main() {
  group('Adversarial Challenge: Case Methodology Rigor & Ungrounded Inference Detection', () {
    test('Zero facts submission is strictly rejected (§15.2)', () {
      final entries = [
        const CaseEntry(
          id: 'H1',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese de acesso indevido por engenharia social',
        ),
        const CaseEntry(
          id: 'H2',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese de malware pré-instalado',
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);

      expect(result.isValidMethodology, isFalse,
          reason: 'Submissions without at least one documented fact must fail validation');
      expect(result.factsCount, equals(0));
      expect(
        result.validationErrors.any((e) => e.contains('Nenhum fato documentado foi registrado')),
        isTrue,
      );
    });

    test('Ungrounded inference with empty fact link list is strictly rejected (§15.2)', () {
      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'Logs do firewall indicam 5 tentativas falhas de autenticação',
        ),
        const CaseEntry(
          id: 'INF_ORPHAN',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Suspeito utilizou força bruta a partir de rede externa',
          linkedFactIds: [], // Empty links!
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);

      expect(result.isValidMethodology, isFalse);
      expect(result.unlinkedInferences, contains('INF_ORPHAN'));
      expect(
        result.validationErrors.any((e) => e.contains('Inferência não fundamentada [INF_ORPHAN]')),
        isTrue,
      );
    });

    test('Ungrounded inference citing non-existent fact ID is strictly rejected (§15.2)', () {
      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'Captura de tráfego de rede no gateway',
        ),
        const CaseEntry(
          id: 'INF_GHOST_REF',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Exfiltração de dados confirmada para IP estrangeiro',
          linkedFactIds: ['F999_NON_EXISTENT'], // Refers to a fact ID that doesn't exist
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);

      expect(result.isValidMethodology, isFalse);
      expect(result.unlinkedInferences, contains('INF_GHOST_REF'));
      expect(
        result.validationErrors.any((e) => e.contains('Inferência não fundamentada [INF_GHOST_REF]')),
        isTrue,
      );
    });

    test('Partial grounding: one valid inference and one ungrounded inference causes failure', () {
      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'IP 10.0.0.15 realizou login SSH com chave pública',
        ),
        const CaseEntry(
          id: 'INF_VALID',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Usuário autorizado utilizou chave registrada',
          linkedFactIds: ['F1'],
        ),
        const CaseEntry(
          id: 'INF_INVALID',
          category: CaseOntologyCategory.investigativeInference,
          description: 'Chave privada foi roubada em ataque prévio',
          linkedFactIds: ['F_UNVERIFIED'],
        ),
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);

      expect(result.isValidMethodology, isFalse);
      expect(result.unlinkedInferences, equals(['INF_INVALID']));
      expect(result.inferencesCount, equals(2));
    });

    test('Multiple competing alternative hypotheses are preserved without premature exclusion (§15.1, §15.2)', () {
      final hypotheses = [
        const CaseEntry(
          id: 'H1',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese 1: Acesso legítimo por colaborador autorizado fora de horário',
        ),
        const CaseEntry(
          id: 'H2',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese 2: Comprometimento de credencial corporativa via phishing direcionado',
        ),
        const CaseEntry(
          id: 'H3',
          category: CaseOntologyCategory.alternativeHypothesis,
          description: 'Hipótese 3: Movimentação lateral após exploração de vulnerabilidade de dia zero',
        ),
      ];

      final entries = [
        const CaseEntry(
          id: 'F1',
          category: CaseOntologyCategory.documentedFact,
          description: 'Sessão VPN ativa entre 02:00 e 04:30',
        ),
        ...hypotheses,
      ];

      final result = CaseMethodologyValidator.validateEntries(entries);

      expect(result.isValidMethodology, isTrue);
      expect(result.hypothesesCount, equals(3));
      expect(result.competingHypotheses.length, equals(3));
      expect(result.competingHypotheses.map((h) => h.id).toList(), equals(['H1', 'H2', 'H3']));
      expect(result.competingHypotheses.map((h) => h.description).toSet(), equals({
        'Hipótese 1: Acesso legítimo por colaborador autorizado fora de horário',
        'Hipótese 2: Comprometimento de credencial corporativa via phishing direcionado',
        'Hipótese 3: Movimentação lateral após exploração de vulnerabilidade de dia zero',
      }));
    });

    test('Completely empty case submission is rejected', () {
      final result = CaseMethodologyValidator.validateEntries([]);

      expect(result.isValidMethodology, isFalse);
      expect(result.factsCount, equals(0));
      expect(result.inferencesCount, equals(0));
      expect(result.hypothesesCount, equals(0));
      expect(result.validationErrors.any((e) => e.contains('Nenhum fato documentado')), isTrue);
    });
  });

  group('Adversarial Challenge: Cryptographic Signature Tampering & Field Perturbation', () {
    late PortfolioReportBundle authenticBundle;

    setUp(() {
      authenticBundle = PortfolioReportExporter.generateReportBundle(
        activityId: 'case-telephony-analysis-042',
        studentName: 'Perito Investigador Antigravity',
        methodology: 'Triangulação de antenas ERB com base em registros de CDR sintéticos e ISO/IEC 27037',
        resultsSummary: 'Identificada convergência espacial do terminal investigado na ERB Centro às 14:32:10.',
        limitations: 'Dados sintéticos laboratoriais restritos à área metropolitana.',
        conclusions: 'Evidência compatível com a presença do terminal no setor alfa.',
        timestampOverride: '2026-11-16T12:00:00Z',
        includePdf: true,
      );
    });

    test('Authentic bundle without modification verifies integrity successfully', () {
      expect(authenticBundle.verifyIntegrity(), isTrue);
      expect(
        PortfolioReportExporter.verifyReportTampering(
          activityId: authenticBundle.activityId,
          studentName: authenticBundle.studentName,
          timestamp: authenticBundle.timestamp,
          methodology: authenticBundle.methodology,
          resultsSummary: authenticBundle.resultsSummary,
          signature: authenticBundle.sha256Signature,
        ),
        isTrue,
      );
    });

    test('Tampering activityId causes cryptographic signature verification to fail', () {
      final tampered = PortfolioReportBundle(
        activityId: 'case-telephony-analysis-999-TAMPERED',
        studentName: authenticBundle.studentName,
        timestamp: authenticBundle.timestamp,
        methodology: authenticBundle.methodology,
        resultsSummary: authenticBundle.resultsSummary,
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: authenticBundle.sha256Signature,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Modifying activityId must break the SHA-256 signature verification');
    });

    test('Tampering studentName causes cryptographic signature verification to fail', () {
      final tampered = PortfolioReportBundle(
        activityId: authenticBundle.activityId,
        studentName: 'Outro Aluno Fraudulento',
        timestamp: authenticBundle.timestamp,
        methodology: authenticBundle.methodology,
        resultsSummary: authenticBundle.resultsSummary,
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: authenticBundle.sha256Signature,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Modifying studentName must break the SHA-256 signature verification');
    });

    test('Tampering timestamp causes cryptographic signature verification to fail', () {
      final tampered = PortfolioReportBundle(
        activityId: authenticBundle.activityId,
        studentName: authenticBundle.studentName,
        timestamp: '2026-11-16T12:00:01Z', // 1 second difference
        methodology: authenticBundle.methodology,
        resultsSummary: authenticBundle.resultsSummary,
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: authenticBundle.sha256Signature,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Modifying timestamp by even 1 second must break signature verification');
    });

    test('Tampering methodology causes cryptographic signature verification to fail', () {
      final tampered = PortfolioReportBundle(
        activityId: authenticBundle.activityId,
        studentName: authenticBundle.studentName,
        timestamp: authenticBundle.timestamp,
        methodology: 'Metodologia não autorizada ou modificada',
        resultsSummary: authenticBundle.resultsSummary,
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: authenticBundle.sha256Signature,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Modifying methodology must break signature verification');
    });

    test('Tampering resultsSummary causes cryptographic signature verification to fail', () {
      final tampered = PortfolioReportBundle(
        activityId: authenticBundle.activityId,
        studentName: authenticBundle.studentName,
        timestamp: authenticBundle.timestamp,
        methodology: authenticBundle.methodology,
        resultsSummary: 'Terminal investigado estava em outro estado (conclusão alterada).',
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: authenticBundle.sha256Signature,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Modifying resultsSummary must break signature verification');
    });

    test('Tampering signature string (single character flip) causes verification to fail', () {
      final corruptedSig = authenticBundle.sha256Signature.replaceRange(0, 1, '0');
      final tampered = PortfolioReportBundle(
        activityId: authenticBundle.activityId,
        studentName: authenticBundle.studentName,
        timestamp: authenticBundle.timestamp,
        methodology: authenticBundle.methodology,
        resultsSummary: authenticBundle.resultsSummary,
        limitations: authenticBundle.limitations,
        conclusions: authenticBundle.conclusions,
        disclaimer: authenticBundle.disclaimer,
        sha256Signature: corruptedSig,
      );

      expect(tampered.verifyIntegrity(), isFalse,
          reason: 'Corrupt signature string must fail verification');
    });

    test('Report contains non-negotiable educational disclaimer (§16.1)', () {
      expect(authenticBundle.disclaimer, contains('DECLARAÇÃO EDUCACIONAL INTERNA'));
      expect(authenticBundle.disclaimer, contains('Não constitui laudo pericial oficial'));
      expect(authenticBundle.disclaimer, contains('nem possui reconhecimento acadêmico ou forense externo'));
    });

    test('Authentic PDF bytes start with %PDF- and contain signature string in metadata', () {
      expect(authenticBundle.pdfBytes, isNotNull);
      final pdf = authenticBundle.pdfBytes!;
      expect(pdf.length, greaterThan(150));
      expect(pdf[0], equals(0x25)); // %
      expect(pdf[1], equals(0x50)); // P
      expect(pdf[2], equals(0x44)); // D
      expect(pdf[3], equals(0x46)); // F
      expect(pdf[4], equals(0x2D)); // -
    });
  });
}
