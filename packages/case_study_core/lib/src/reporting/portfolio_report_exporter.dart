import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';

/// Mandatory non-accreditation disclaimer (§16.1).
const String kMandatoryEducationalDisclaimer =
    'DECLARAÇÃO EDUCACIONAL INTERNA: Este documento é um registro de exercício prático '
    'executado na plataforma Academia Forense — Laboratório de Formação. '
    'Não constitui laudo pericial oficial nem possui reconhecimento acadêmico ou forense externo.';

/// Signed forensic report bundle representing a completed case or lab study (§16.1).
class PortfolioReportBundle {
  final String activityId;
  final String studentName;
  final String timestamp;
  final String methodology;
  final String resultsSummary;
  final String limitations;
  final String conclusions;
  final String disclaimer;
  final String sha256Signature;
  final Uint8List? pdfBytes;

  const PortfolioReportBundle({
    required this.activityId,
    required this.studentName,
    required this.timestamp,
    required this.methodology,
    required this.resultsSummary,
    required this.limitations,
    required this.conclusions,
    required this.disclaimer,
    required this.sha256Signature,
    this.pdfBytes,
  });

  Map<String, dynamic> toMap() => {
    'activity_id': activityId,
    'student_name': studentName,
    'timestamp': timestamp,
    'methodology': methodology,
    'results_summary': resultsSummary,
    'limitations': limitations,
    'conclusions': conclusions,
    'disclaimer': disclaimer,
    'sha256_signature': sha256Signature,
    // CamelCase convenience aliases
    'activityId': activityId,
    'studentName': studentName,
    'resultsSummary': resultsSummary,
    'sha256Signature': sha256Signature,
  };

  /// Verifies whether the report bundle content has been tampered with.
  bool verifyIntegrity() {
    final raw = '$activityId|$studentName|$timestamp|$methodology|$resultsSummary';
    final computedSig = sha256.convert(utf8.encode(raw)).toString();
    return computedSig == sha256Signature;
  }
}

/// Generates signed portfolio reports and authentic PDF binaries (§16, §16.1).
class PortfolioReportExporter {
  /// Generates a signed report bundle with cryptographic SHA-256 signature and mandatory disclaimer.
  static PortfolioReportBundle generateReportBundle({
    required String activityId,
    required String studentName,
    required String methodology,
    required String resultsSummary,
    String limitations = 'Exercício em ambiente controlado com dados sintéticos.',
    String conclusions = 'Análise técnica finalizada conforme rubrica de avaliação.',
    String? timestampOverride,
    bool includePdf = true,
  }) {
    final timestamp = timestampOverride ?? '${DateTime.now().toUtc().toIso8601String().split('.').first}Z';
    final reportRaw = '$activityId|$studentName|$timestamp|$methodology|$resultsSummary';
    final signature = sha256.convert(utf8.encode(reportRaw)).toString();

    Uint8List? pdf;
    if (includePdf) {
      pdf = buildAuthenticPdfBytes(
        title: 'ACADEMIA FORENSE — RELATÓRIO TÉCNICO DIDÁTICO',
        activityId: activityId,
        studentName: studentName,
        timestamp: timestamp,
        methodology: methodology,
        resultsSummary: resultsSummary,
        limitations: limitations,
        conclusions: conclusions,
        disclaimer: kMandatoryEducationalDisclaimer,
        signature: signature,
      );
    }

    return PortfolioReportBundle(
      activityId: activityId,
      studentName: studentName,
      timestamp: timestamp,
      methodology: methodology,
      resultsSummary: resultsSummary,
      limitations: limitations,
      conclusions: conclusions,
      disclaimer: kMandatoryEducationalDisclaimer,
      sha256Signature: signature,
      pdfBytes: pdf,
    );
  }

  /// Verifies if a given report bundle signature is valid and untampered.
  static bool verifyReportTampering({
    required String activityId,
    required String studentName,
    required String timestamp,
    required String methodology,
    required String resultsSummary,
    required String signature,
  }) {
    final raw = '$activityId|$studentName|$timestamp|$methodology|$resultsSummary';
    final computed = sha256.convert(utf8.encode(raw)).toString();
    return computed == signature;
  }

  /// Builds authentic, valid binary PDF document bytes starting with `%PDF-1.4`.
  static Uint8List buildAuthenticPdfBytes({
    required String title,
    required String activityId,
    required String studentName,
    required String timestamp,
    required String methodology,
    required String resultsSummary,
    required String limitations,
    required String conclusions,
    required String disclaimer,
    required String signature,
  }) {
    // Sanitize ASCII text for standard PDF Type1 Font
    String cleanText(String input) {
      return input
          .replaceAll('(', '\\(')
          .replaceAll(')', '\\)')
          .replaceAll('\r', '')
          .replaceAll('\n', ' ');
    }

    final streamBuffer = StringBuffer();
    streamBuffer.writeln('BT');
    streamBuffer.writeln('/F1 16 Tf');
    streamBuffer.writeln('50 780 Td');
    streamBuffer.writeln('(${cleanText(title)}) Tj');

    streamBuffer.writeln('/F1 10 Tf');
    streamBuffer.writeln('0 -30 Td');
    streamBuffer.writeln('(Atividade / Caso: ${cleanText(activityId)}) Tj');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(Discente: ${cleanText(studentName)}) Tj');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(Timestamp UTC: ${cleanText(timestamp)}) Tj');

    streamBuffer.writeln('0 -25 Td');
    streamBuffer.writeln('/F1 12 Tf');
    streamBuffer.writeln('(1. Metodologia Empregada:) Tj');
    streamBuffer.writeln('/F1 10 Tf');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(${cleanText(methodology)}) Tj');

    streamBuffer.writeln('0 -25 Td');
    streamBuffer.writeln('/F1 12 Tf');
    streamBuffer.writeln('(2. Sumario dos Resultados:) Tj');
    streamBuffer.writeln('/F1 10 Tf');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(${cleanText(resultsSummary)}) Tj');

    streamBuffer.writeln('0 -25 Td');
    streamBuffer.writeln('/F1 12 Tf');
    streamBuffer.writeln('(3. Limitacoes Tecnicas:) Tj');
    streamBuffer.writeln('/F1 10 Tf');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(${cleanText(limitations)}) Tj');

    streamBuffer.writeln('0 -25 Td');
    streamBuffer.writeln('/F1 12 Tf');
    streamBuffer.writeln('(4. Conclusoes:) Tj');
    streamBuffer.writeln('/F1 10 Tf');
    streamBuffer.writeln('0 -15 Td');
    streamBuffer.writeln('(${cleanText(conclusions)}) Tj');

    streamBuffer.writeln('0 -35 Td');
    streamBuffer.writeln('/F1 9 Tf');
    streamBuffer.writeln('([AVISO OBRIGATORIO DE NATUREZA ACADEMICA]) Tj');
    streamBuffer.writeln('0 -12 Td');
    streamBuffer.writeln('(${cleanText(disclaimer)}) Tj');

    streamBuffer.writeln('0 -30 Td');
    streamBuffer.writeln('/F1 8 Tf');
    streamBuffer.writeln('(Assinatura Criptografica SHA-256: ${cleanText(signature)}) Tj');
    streamBuffer.writeln('ET');

    final streamContent = utf8.encode(streamBuffer.toString());
    final streamLength = streamContent.length;

    final bodyBuffer = BytesBuilder();

    // Header
    final header = utf8.encode('%PDF-1.4\n%\xe2\xe3\xcf\xd3\n');
    bodyBuffer.add(header);

    final offsets = <int>[];

    void writeObject(int objNum, String content) {
      offsets.add(bodyBuffer.length);
      bodyBuffer.add(utf8.encode('$objNum 0 obj\n$content\nendobj\n'));
    }

    // 1 0 obj: Catalog
    writeObject(1, '<< /Type /Catalog /Pages 2 0 R >>');

    // 2 0 obj: Pages
    writeObject(2, '<< /Type /Pages /Kids [3 0 R] /Count 1 >>');

    // 3 0 obj: Page
    writeObject(
      3,
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
      '/Resources << /Font << /F1 4 0 R >> >> '
      '/Contents 5 0 R >>',
    );

    // 4 0 obj: Font
    writeObject(4, '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');

    // 5 0 obj: Stream content
    offsets.add(bodyBuffer.length);
    bodyBuffer.add(utf8.encode('5 0 obj\n<< /Length $streamLength >>\nstream\n'));
    bodyBuffer.add(streamContent);
    bodyBuffer.add(utf8.encode('\nendstream\nendobj\n'));

    // Cross-reference table (xref)
    final xrefOffset = bodyBuffer.length;
    final xrefBuffer = StringBuffer();
    xrefBuffer.writeln('xref');
    xrefBuffer.writeln('0 6');
    xrefBuffer.writeln('0000000000 65535 f ');
    for (final off in offsets) {
      xrefBuffer.writeln(off.toString().padLeft(10, '0') + ' 00000 n ');
    }
    xrefBuffer.writeln('trailer');
    xrefBuffer.writeln('<< /Size 6 /Root 1 0 R >>');
    xrefBuffer.writeln('startxref');
    xrefBuffer.writeln('$xrefOffset');
    xrefBuffer.writeln('%%EOF');

    bodyBuffer.add(utf8.encode(xrefBuffer.toString()));

    return bodyBuffer.toBytes();
  }

  /// Records the case submission into the persistence database via LaboratoryDao.
  static Future<String> recordCaseSubmission({
    required LaboratoryDao laboratoryDao,
    required String caseStudyId,
    required PortfolioReportBundle reportBundle,
    required String conclusionText,
    required Map<String, dynamic> hypothesisEvaluation,
    String? reportPdfPath,
    String? tutorEvaluationJson,
  }) async {
    final submissionId = 'sub_${caseStudyId}_${DateTime.now().toUtc().millisecondsSinceEpoch}';

    await laboratoryDao.recordCaseSubmission(
      CaseSubmissionsCompanion.insert(
        id: submissionId,
        caseStudyId: caseStudyId,
        submittedAt: Value(DateTime.now().toUtc()),
        reportPdfPath: Value(reportPdfPath),
        conclusionText: conclusionText,
        hypothesisEvaluationJson: jsonEncode(hypothesisEvaluation),
        tutorEvaluationJson: Value(tutorEvaluationJson),
      ),
    );

    return submissionId;
  }
}
