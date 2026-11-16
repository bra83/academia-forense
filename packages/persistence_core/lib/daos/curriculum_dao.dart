import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/curriculum_tables.dart';

part 'curriculum_dao.g.dart';

@DriftAccessor(tables: [
  Curriculums,
  Volumes,
  Chapters,
  Lessons,
  LearningObjectives,
  Competencies,
  Exercises,
])
class CurriculumDao extends DatabaseAccessor<AppDatabase> with _$CurriculumDaoMixin {
  CurriculumDao(super.db);

  // Curriculums
  Future<List<Curriculum>> getAllCurricula() => select(curriculums).get();
  Future<Curriculum?> getCurriculumById(String id) =>
      (select(curriculums)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<int> insertCurriculum(CurriculumsCompanion entry) =>
      into(curriculums).insertOnConflictUpdate(entry);

  // Volumes
  Future<List<Volume>> getVolumes() =>
      (select(volumes)..orderBy([(t) => OrderingTerm(expression: t.volumeNumber)])).get();
  Future<Volume?> getVolumeById(String id) =>
      (select(volumes)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<int> insertVolume(VolumesCompanion entry) =>
      into(volumes).insertOnConflictUpdate(entry);

  // Chapters
  Future<List<Chapter>> getChaptersForVolume(String volumeId) =>
      (select(chapters)
            ..where((tbl) => tbl.volumeId.equals(volumeId))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
  Future<Chapter?> getChapterById(String id) =>
      (select(chapters)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  Future<int> insertChapter(ChaptersCompanion entry) =>
      into(chapters).insertOnConflictUpdate(entry);
  Future<int> updateChapterStatus(String chapterId, String status) =>
      (update(chapters)..where((t) => t.id.equals(chapterId)))
          .write(ChaptersCompanion(editorialStatus: Value(status), updatedAt: Value(DateTime.now())));

  // Lessons
  Future<List<Lesson>> getLessonsForChapter(String chapterId) =>
      (select(lessons)
            ..where((tbl) => tbl.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
  Future<int> insertLesson(LessonsCompanion entry) =>
      into(lessons).insertOnConflictUpdate(entry);

  // Objectives
  Future<List<LearningObjective>> getObjectivesForChapter(String chapterId) =>
      (select(learningObjectives)
            ..where((tbl) => tbl.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
  Future<int> insertObjective(LearningObjectivesCompanion entry) =>
      into(learningObjectives).insertOnConflictUpdate(entry);

  // Competencies
  Future<List<Competency>> getAllCompetencies() => select(competencies).get();
  Future<Competency?> getCompetencyByCode(String code) =>
      (select(competencies)..where((tbl) => tbl.code.equals(code))).getSingleOrNull();
  Future<int> insertCompetency(CompetenciesCompanion entry) =>
      into(competencies).insertOnConflictUpdate(entry);

  // Exercises
  Future<List<Exercise>> getExercisesForLesson(String lessonId) =>
      (select(exercises)
            ..where((tbl) => tbl.lessonId.equals(lessonId))
            ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
          .get();
  Future<int> insertExercise(ExercisesCompanion entry) =>
      into(exercises).insertOnConflictUpdate(entry);
}
