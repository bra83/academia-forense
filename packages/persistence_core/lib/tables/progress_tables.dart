import 'package:drift/drift.dart';
import 'curriculum_tables.dart';

/// 14. StudySession Table (§17.1 - 13h weekly pace tracker)
class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  DateTimeColumn get startTime => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer().withDefault(const Constant(0))();
  IntColumn get pagesRead => integer().withDefault(const Constant(0))();
  IntColumn get notesCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// 15. ReadingPosition Table (§7.1, §17.1)
class ReadingPositions extends Table {
  TextColumn get chapterId => text().references(Chapters, #id)();
  IntColumn get pageNumber => integer().withDefault(const Constant(1))();
  RealColumn get scrollRatio => real().withDefault(const Constant(0.0))();
  IntColumn get lastParagraphIndex => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {chapterId};
}

/// 16. Bookmark Table (§7.1)
class Bookmarks extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  IntColumn get pageNumber => integer()();
  TextColumn get sectionTitle => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 17. Annotation Table (§7.1, §2.2 drift tolerance)
class Annotations extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  IntColumn get pageNumber => integer()();
  TextColumn get selectedText => text()();
  TextColumn get note => text()();
  TextColumn get highlightColor => text().withDefault(const Constant('#347259'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 18. ReviewSchedule Table (Spaced Repetition SM-2 §17.1)
class ReviewSchedules extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get competencyId => text().nullable().references(Competencies, #id)();
  DateTimeColumn get scheduledDate => dateTime()();
  IntColumn get repetitionIntervalDays => integer().withDefault(const Constant(1))();
  RealColumn get easinessFactor => real().withDefault(const Constant(2.5))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
