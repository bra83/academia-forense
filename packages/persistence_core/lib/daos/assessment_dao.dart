import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/assessment_tables.dart';

part 'assessment_dao.g.dart';

@DriftAccessor(tables: [
  Assessments,
  AssessmentAttempts,
])
class AssessmentDao extends DatabaseAccessor<AppDatabase> with _$AssessmentDaoMixin {
  AssessmentDao(super.db);

  // Assessments
  Future<Assessment?> getAssessmentById(String id) =>
      (select(assessments)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<Assessment?> getAssessmentForChapter(String chapterId) =>
      (select(assessments)..where((tbl) => tbl.chapterId.equals(chapterId))).getSingleOrNull();

  Future<int> insertAssessment(AssessmentsCompanion entry) =>
      into(assessments).insertOnConflictUpdate(entry);

  // Attempts
  Future<int> recordAttempt(AssessmentAttemptsCompanion attempt) =>
      into(assessmentAttempts).insert(attempt);

  Future<List<AssessmentAttempt>> getAttemptsForAssessment(String assessmentId) =>
      (select(assessmentAttempts)
            ..where((tbl) => tbl.assessmentId.equals(assessmentId))
            ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)]))
          .get();

  Future<bool> hasPassedAssessment(String assessmentId) async {
    final passedAttempts = await (select(assessmentAttempts)
          ..where((tbl) => tbl.assessmentId.equals(assessmentId) & tbl.passed.equals(true)))
        .get();
    return passedAttempts.isNotEmpty;
  }

  Future<double?> getHighestScore(String assessmentId) async {
    final attempts = await getAttemptsForAssessment(assessmentId);
    if (attempts.isEmpty) return null;
    return attempts.map((a) => a.score).reduce((max, s) => s > max ? s : max);
  }
}
