import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../tables/settings_tables.dart';
import '../tables/content_tables.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [
  UserSettingsEntries,
  SyncJournals,
  AIInteractions,
  ContentRevisions,
  SourceDocuments,
])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  // User Settings
  Future<String?> getSetting(String key) async {
    final entry = await (select(userSettingsEntries)..where((tbl) => tbl.key.equals(key))).getSingleOrNull();
    return entry?.value;
  }

  Future<int> setSetting(String key, String value) =>
      into(userSettingsEntries).insertOnConflictUpdate(
        UserSettingsEntriesCompanion(
          key: Value(key),
          value: Value(value),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<int> deleteSetting(String key) =>
      (delete(userSettingsEntries)..where((tbl) => tbl.key.equals(key))).go();

  // Sync Journals
  Future<int> logSyncJournal(SyncJournalsCompanion entry) =>
      into(syncJournals).insert(entry);

  Future<List<SyncJournal>> getRecentSyncLogs({int limit = 50}) =>
      (select(syncJournals)
            ..orderBy([(t) => OrderingTerm(expression: t.syncedAt, mode: OrderingMode.desc)])
            ..limit(limit))
          .get();

  // AI Interactions
  Future<int> logAIInteraction(AIInteractionsCompanion interaction) =>
      into(aIInteractions).insert(interaction);

  Future<List<AIInteraction>> getAIInteractionsForChapter(String chapterId, {int limit = 20}) =>
      (select(aIInteractions)
            ..where((tbl) => tbl.chapterId.equals(chapterId))
            ..orderBy([(t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)])
            ..limit(limit))
          .get();

  // Content Revisions
  Future<ContentRevision?> getActiveRevision(String chapterId) =>
      (select(contentRevisions)
            ..where((tbl) => tbl.chapterId.equals(chapterId) & tbl.isApproved.equals(true))
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .getSingleOrNull();

  Future<int> insertContentRevision(ContentRevisionsCompanion revision) =>
      into(contentRevisions).insertOnConflictUpdate(revision);

  // Source Documents
  Future<List<SourceDocument>> getDocumentsForChapter(String chapterId) =>
      (select(sourceDocuments)..where((tbl) => tbl.chapterId.equals(chapterId))).get();

  Future<int> insertSourceDocument(SourceDocumentsCompanion doc) =>
      into(sourceDocuments).insertOnConflictUpdate(doc);
}
