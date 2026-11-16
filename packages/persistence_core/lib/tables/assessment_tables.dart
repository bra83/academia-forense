import 'package:drift/drift.dart';
import 'curriculum_tables.dart';

/// 8. Assessment Table (§8.2, 80% progression benchmark)
class Assessments extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get title => text()();
  RealColumn get passingBenchmark => real().withDefault(const Constant(0.80))();
  TextColumn get questionDataJson => text()();
  IntColumn get totalQuestions => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 9. AssessmentAttempt Table (Immutable score logging §2.2, §8.2)
class AssessmentAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get assessmentId => text().references(Assessments, #id)();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  RealColumn get score => real()();
  BoolColumn get passed => boolean()();
  TextColumn get responsesJson => text()();
  TextColumn get discursiveFeedback => text().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
