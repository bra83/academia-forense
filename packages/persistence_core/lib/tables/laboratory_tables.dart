import 'package:drift/drift.dart';
import 'curriculum_tables.dart';

/// 10. Laboratory Table (7 multi-disciplinary domains §14.1)
class Laboratories extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get domain => text()(); // Informatics, Math, Programming, Digital Forensics, Telephony, Linguistics, Multimedia
  TextColumn get title => text()();
  TextColumn get environmentType => text()(); // SQLite, Python, MetadataExtractor, CDRAnalyzer, AudioAcoustic
  TextColumn get initialDatasetPath => text().nullable()();
  TextColumn get instructionsMarkdown => text()();
  TextColumn get verificationRubricJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 11. LaboratoryRun Table (§14.2)
class LaboratoryRuns extends Table {
  TextColumn get id => text()();
  TextColumn get laboratoryId => text().references(Laboratories, #id)();
  DateTimeColumn get executedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get commandsExecutedJson => text()();
  TextColumn get outputArtifactPath => text().nullable()();
  BoolColumn get isPassed => boolean()();
  TextColumn get metricsJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 12. CaseStudy Table (§15 - Facts vs Inferences solver)
class CaseStudies extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get caseTitle => text()();
  TextColumn get incidentSummary => text()();
  TextColumn get documentedFactsJson => text()();
  TextColumn get investigativeInferencesJson => text()();
  TextColumn get alternativeHypothesesJson => text()();
  TextColumn get evidentialMatrixJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 13. CaseSubmission Table (§15, §16.1 PDF Portfolio)
class CaseSubmissions extends Table {
  TextColumn get id => text()();
  TextColumn get caseStudyId => text().references(CaseStudies, #id)();
  DateTimeColumn get submittedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get reportPdfPath => text().nullable()();
  TextColumn get conclusionText => text()();
  TextColumn get hypothesisEvaluationJson => text()();
  TextColumn get tutorEvaluationJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
