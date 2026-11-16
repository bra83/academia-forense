import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/laboratory_tables.dart';

part 'laboratory_dao.g.dart';

@DriftAccessor(tables: [
  Laboratories,
  LaboratoryRuns,
  CaseStudies,
  CaseSubmissions,
])
class LaboratoryDao extends DatabaseAccessor<AppDatabase> with _$LaboratoryDaoMixin {
  LaboratoryDao(super.db);

  // Laboratories
  Future<List<Laboratory>> getLaboratoriesForChapter(String chapterId) =>
      (select(laboratories)..where((tbl) => tbl.chapterId.equals(chapterId))).get();

  Future<Laboratory?> getLaboratoryById(String id) =>
      (select(laboratories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertLaboratory(LaboratoriesCompanion entry) =>
      into(laboratories).insertOnConflictUpdate(entry);

  // Laboratory Runs
  Future<int> recordLaboratoryRun(LaboratoryRunsCompanion run) =>
      into(laboratoryRuns).insert(run);

  Future<List<LaboratoryRun>> getRunsForLaboratory(String laboratoryId) =>
      (select(laboratoryRuns)
            ..where((tbl) => tbl.laboratoryId.equals(laboratoryId))
            ..orderBy([(t) => OrderingTerm(expression: t.executedAt, mode: OrderingMode.desc)]))
          .get();

  // Case Studies
  Future<List<CaseStudy>> getCaseStudiesForChapter(String chapterId) =>
      (select(caseStudies)..where((tbl) => tbl.chapterId.equals(chapterId))).get();

  Future<CaseStudy?> getCaseStudyById(String id) =>
      (select(caseStudies)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<int> insertCaseStudy(CaseStudiesCompanion entry) =>
      into(caseStudies).insertOnConflictUpdate(entry);

  // Case Submissions
  Future<int> recordCaseSubmission(CaseSubmissionsCompanion submission) =>
      into(caseSubmissions).insert(submission);

  Future<List<CaseSubmission>> getSubmissionsForCase(String caseStudyId) =>
      (select(caseSubmissions)
            ..where((tbl) => tbl.caseStudyId.equals(caseStudyId))
            ..orderBy([(t) => OrderingTerm(expression: t.submittedAt, mode: OrderingMode.desc)]))
          .get();
}
