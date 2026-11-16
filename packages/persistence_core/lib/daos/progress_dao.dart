import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/progress_tables.dart';
import '../tables/curriculum_tables.dart';

part 'progress_dao.g.dart';

@DriftAccessor(tables: [
  StudySessions,
  ReadingPositions,
  Bookmarks,
  Annotations,
  ReviewSchedules,
  Chapters,
  Competencies,
])
class UserProgressDao extends DatabaseAccessor<AppDatabase> with _$UserProgressDaoMixin {
  UserProgressDao(super.db);

  // Reading Positions
  Future<ReadingPosition?> getReadingPosition(String chapterId) =>
      (select(readingPositions)..where((tbl) => tbl.chapterId.equals(chapterId))).getSingleOrNull();

  Future<int> saveReadingPosition({
    required String chapterId,
    required int pageNumber,
    required double scrollRatio,
    int lastParagraphIndex = 0,
  }) {
    return into(readingPositions).insertOnConflictUpdate(
      ReadingPositionsCompanion(
        chapterId: Value(chapterId),
        pageNumber: Value(pageNumber),
        scrollRatio: Value(scrollRatio),
        lastParagraphIndex: Value(lastParagraphIndex),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Bookmarks
  Future<List<Bookmark>> getBookmarksForChapter(String chapterId) =>
      (select(bookmarks)
            ..where((tbl) => tbl.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm(expression: t.pageNumber)]))
          .get();

  Future<int> addBookmark(BookmarksCompanion bookmark) =>
      into(bookmarks).insertOnConflictUpdate(bookmark);

  Future<int> removeBookmark(String bookmarkId) =>
      (delete(bookmarks)..where((tbl) => tbl.id.equals(bookmarkId))).go();

  // Annotations
  Future<List<Annotation>> getAnnotationsForChapter(String chapterId) =>
      (select(annotations)
            ..where((tbl) => tbl.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm(expression: t.pageNumber)]))
          .get();

  Future<int> saveAnnotation(AnnotationsCompanion annotation) =>
      into(annotations).insertOnConflictUpdate(annotation);

  Future<int> deleteAnnotation(String annotationId) =>
      (delete(annotations)..where((tbl) => tbl.id.equals(annotationId))).go();

  // Study Sessions
  Future<int> startStudySession(StudySessionsCompanion session) =>
      into(studySessions).insert(session);

  Future<int> endStudySession(String sessionId, {required int durationSeconds, int pagesRead = 0, int notesCount = 0}) =>
      (update(studySessions)..where((tbl) => tbl.id.equals(sessionId))).write(
        StudySessionsCompanion(
          endTime: Value(DateTime.now()),
          durationSeconds: Value(durationSeconds),
          pagesRead: Value(pagesRead),
          notesCount: Value(notesCount),
        ),
      );

  Future<List<StudySession>> getRecentStudySessions({int limit = 20}) =>
      (select(studySessions)
            ..orderBy([(t) => OrderingTerm(expression: t.startTime, mode: OrderingMode.desc)])
            ..limit(limit))
          .get();

  // Spaced Repetition / Review Schedules
  Future<List<ReviewSchedule>> getPendingReviews(DateTime beforeDate) =>
      (select(reviewSchedules)
            ..where((tbl) => tbl.isCompleted.equals(false) & tbl.scheduledDate.isSmallerOrEqualValue(beforeDate))
            ..orderBy([(t) => OrderingTerm(expression: t.scheduledDate)]))
          .get();

  Future<int> scheduleReview(ReviewSchedulesCompanion entry) =>
      into(reviewSchedules).insertOnConflictUpdate(entry);

  Future<int> markReviewCompleted(String reviewId) =>
      (update(reviewSchedules)..where((tbl) => tbl.id.equals(reviewId))).write(
        ReviewSchedulesCompanion(
          isCompleted: const Value(true),
          lastReviewedAt: Value(DateTime.now()),
        ),
      );
}
