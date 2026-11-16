import 'package:drift/drift.dart';

/// 1. Curriculum Table (§3, §17)
class Curriculums extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get version => text()();
  TextColumn get description => text()();
  IntColumn get totalVolumes => integer().withDefault(const Constant(9))();
  RealColumn get weeklyTargetHours => real().withDefault(const Constant(13.0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 2. Volume Table (9 Volumes §3, §24.2)
class Volumes extends Table {
  TextColumn get id => text()();
  TextColumn get curriculumId => text().references(Curriculums, #id)();
  IntColumn get volumeNumber => integer()();
  TextColumn get title => text()();
  TextColumn get discipline => text()();
  TextColumn get description => text()();
  IntColumn get totalChapters => integer()();
  BoolColumn get isPrintPreserved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 3. Chapter Table (113 Chapters §3, 7-state lifecycle §24.3)
class Chapters extends Table {
  TextColumn get id => text()();
  TextColumn get volumeId => text().references(Volumes, #id)();
  IntColumn get chapterNumber => integer()();
  TextColumn get title => text()();
  TextColumn get editorialStatus => text().withDefault(const Constant('Planejado'))();
  TextColumn get activeRevisionId => text().nullable()();
  IntColumn get orderIndex => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 4. Lesson Table (10-step lesson engine §8)
class Lessons extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  IntColumn get lessonNumber => integer()();
  TextColumn get title => text()();
  IntColumn get stepCount => integer().withDefault(const Constant(10))();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(30))();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 5. LearningObjective Table (Bloom Taxonomy §8.1)
class LearningObjectives extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get lessonId => text().nullable().references(Lessons, #id)();
  TextColumn get description => text()();
  TextColumn get bloomTaxonomyLevel => text()(); // Remember, Understand, Apply, Analyze, Evaluate, Create
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 6. Competency Table (Curriculum mastery matrix §17)
class Competencies extends Table {
  TextColumn get id => text()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get domain => text()(); // Informatics, Math, Programming, Digital Forensics, Telephony, Linguistics, Multimedia
  RealColumn get targetScore => real().withDefault(const Constant(0.80))();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 7. Exercise Table (Guided & Solved examples §8.1)
class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get lessonId => text().nullable().references(Lessons, #id)();
  TextColumn get exerciseType => text()(); // Guided, Solved, Independent
  TextColumn get problemPrompt => text()();
  TextColumn get solvedSolution => text()();
  IntColumn get orderIndex => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
