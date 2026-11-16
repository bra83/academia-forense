import 'package:drift/drift.dart';
import 'curriculum_tables.dart';

/// 19. ContentRevision Table (§19, §24.2 - REV1, REV2, checksums)
class ContentRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get revisionCode => text()(); // REV1, REV2, REV3
  TextColumn get author => text()();
  TextColumn get checksumSha256 => text()();
  TextColumn get manifestJson => text()();
  BoolColumn get isApproved => boolean().withDefault(const Constant(false))();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 20. SourceDocument Table (PDF, Markdown, Dataset, Audio files §7.2, §18)
class SourceDocuments extends Table {
  TextColumn get id => text()();
  TextColumn get chapterId => text().references(Chapters, #id)();
  TextColumn get fileName => text()();
  TextColumn get fileType => text()(); // PDF, Markdown, Dataset, Audio
  TextColumn get sha256 => text()();
  IntColumn get fileSizeBytes => integer()();
  TextColumn get localPath => text()();
  DateTimeColumn get importedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// 22. SyncJournal Table (Audit trail §2.1, §17.1)
class SyncJournals extends Table {
  TextColumn get id => text()();
  TextColumn get sourceProvider => text()(); // GoogleDrive, LocalDirectory, Fixture
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get sha256Before => text().nullable()();
  TextColumn get sha256After => text().nullable()();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get status => text().withDefault(const Constant('SUCCESS'))(); // SUCCESS, CONFLICT, FAILED

  @override
  Set<Column> get primaryKey => {id};
}
