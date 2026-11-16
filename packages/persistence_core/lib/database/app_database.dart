import 'dart:io';
import 'package:drift/drift.dart';

import '../tables/curriculum_tables.dart';
import '../tables/assessment_tables.dart';
import '../tables/laboratory_tables.dart';
import '../tables/progress_tables.dart';
import '../tables/content_tables.dart';
import '../tables/settings_tables.dart';

import '../daos/curriculum_dao.dart';
import '../daos/progress_dao.dart';
import '../daos/assessment_dao.dart';
import '../daos/laboratory_dao.dart';
import '../daos/settings_dao.dart';
import '../daos/audio_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    // 1-7 Curriculum
    Curriculums,
    Volumes,
    Chapters,
    Lessons,
    LearningObjectives,
    Competencies,
    Exercises,

    // 8-9 Assessments
    Assessments,
    AssessmentAttempts,

    // 10-13 Laboratory & Case Studies
    Laboratories,
    LaboratoryRuns,
    CaseStudies,
    CaseSubmissions,

    // 14-18 User Progress & Spaced Repetition
    StudySessions,
    ReadingPositions,
    Bookmarks,
    Annotations,
    ReviewSchedules,

    // 19-20, 22 Content & Revisions & Sync
    ContentRevisions,
    SourceDocuments,
    SyncJournals,

    // 21, 23-24 Settings & AI & Audio
    UserSettingsEntries,
    AIInteractions,
    AudioSettingsEntries,
  ],
  daos: [
    CurriculumDao,
    UserProgressDao,
    AssessmentDao,
    LaboratoryDao,
    SettingsDao,
    AudioDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Schema versioning hooks for future migrations
          if (from < 2) {
            // Future migration steps
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('''
            CREATE VIRTUAL TABLE IF NOT EXISTS fts_content USING fts5(
              chapter_id UNINDEXED,
              title,
              section_title,
              body_text,
              tokenize = 'unicode61'
            );
          ''');
        },
      );

  /// Indexes a document section into the SQLite FTS5 index (§7.1, §18.3).
  Future<void> indexContentFts5({
    required String chapterId,
    required String title,
    required String sectionTitle,
    required String bodyText,
  }) async {
    await customStatement(
      'INSERT INTO fts_content (chapter_id, title, section_title, body_text) VALUES (?, ?, ?, ?);',
      [chapterId, title, sectionTitle, bodyText],
    );
  }

  /// Searches the SQLite FTS5 index for [query] and returns matched snippets (§7.1, §18.3).
  Future<List<Map<String, dynamic>>> searchContentFts5(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return [];

    var ftsQuery = clean;
    if (!ftsQuery.toUpperCase().contains(' AND ') && !ftsQuery.endsWith('*')) {
      ftsQuery = ftsQuery.replaceAll(RegExp(r'["\(\)\{\}\[\]\^\:\+\-]'), ' ').trim();
    }
    if (ftsQuery.isEmpty) return [];

    try {
      final rows = await customSelect(
        "SELECT chapter_id, title, section_title, snippet(fts_content, 3, '[MATCH]', '[/MATCH]', '...', 10) AS snippet "
        'FROM fts_content WHERE fts_content MATCH ? ORDER BY rank;',
        variables: [Variable.withString(ftsQuery)],
      ).get();

      return rows.map((r) => r.data).toList();
    } catch (_) {
      return [];
    }
  }

  /// Exports primary database tables to a structured JSON map for portable offline backups.
  Future<Map<String, dynamic>> exportToJson() async {
    final currs = await select(curriculums).get();
    final vols = await select(volumes).get();
    final chaps = await select(chapters).get();
    final assess = await select(assessments).get();
    final attempts = await select(assessmentAttempts).get();
    final readPos = await select(readingPositions).get();
    final notes = await select(annotations).get();
    final bmarks = await select(bookmarks).get();
    final settings = await select(userSettingsEntries).get();

    return {
      'version': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'curriculums': currs.map((c) => c.toJson()).toList(),
      'volumes': vols.map((v) => v.toJson()).toList(),
      'chapters': chaps.map((c) => c.toJson()).toList(),
      'assessments': assess.map((a) => a.toJson()).toList(),
      'assessmentAttempts': attempts.map((a) => a.toJson()).toList(),
      'readingPositions': readPos.map((r) => r.toJson()).toList(),
      'annotations': notes.map((a) => a.toJson()).toList(),
      'bookmarks': bmarks.map((b) => b.toJson()).toList(),
      'settings': settings.map((s) => s.toJson()).toList(),
    };
  }

  /// Imports and restores progress, content hierarchy, and settings from a structured JSON map.
  /// Records are inserted in topological foreign-key order:
  /// curriculums -> volumes -> chapters -> assessments -> assessmentAttempts -> child progress records.
  Future<void> importFromJson(Map<String, dynamic> data) async {
    await transaction(() async {
      // 1. Curriculums (Root)
      if (data.containsKey('curriculums') && data['curriculums'] is List) {
        for (final item in data['curriculums'] as List) {
          final row = Curriculum.fromJson(item as Map<String, dynamic>);
          await into(curriculums).insertOnConflictUpdate(row);
        }
      }

      // 2. Volumes (references Curriculums)
      if (data.containsKey('volumes') && data['volumes'] is List) {
        for (final item in data['volumes'] as List) {
          final row = Volume.fromJson(item as Map<String, dynamic>);
          await into(volumes).insertOnConflictUpdate(row);
        }
      }

      // 3. Chapters (references Volumes)
      if (data.containsKey('chapters') && data['chapters'] is List) {
        for (final item in data['chapters'] as List) {
          final row = Chapter.fromJson(item as Map<String, dynamic>);
          await into(chapters).insertOnConflictUpdate(row);
        }
      }

      // 4. Assessments (references Chapters)
      if (data.containsKey('assessments') && data['assessments'] is List) {
        for (final item in data['assessments'] as List) {
          final row = Assessment.fromJson(item as Map<String, dynamic>);
          await into(assessments).insertOnConflictUpdate(row);
        }
      }

      // 5. Assessment Attempts (references Assessments)
      if (data.containsKey('assessmentAttempts') && data['assessmentAttempts'] is List) {
        for (final item in data['assessmentAttempts'] as List) {
          final row = AssessmentAttempt.fromJson(item as Map<String, dynamic>);
          await into(assessmentAttempts).insertOnConflictUpdate(row);
        }
      }

      // 6. Reading Positions (references Chapters)
      if (data.containsKey('readingPositions') && data['readingPositions'] is List) {
        for (final item in data['readingPositions'] as List) {
          final row = ReadingPosition.fromJson(item as Map<String, dynamic>);
          await into(readingPositions).insertOnConflictUpdate(row);
        }
      }

      // 7. Annotations (references Chapters)
      if (data.containsKey('annotations') && data['annotations'] is List) {
        for (final item in data['annotations'] as List) {
          final row = Annotation.fromJson(item as Map<String, dynamic>);
          await into(annotations).insertOnConflictUpdate(row);
        }
      }

      // 8. Bookmarks (references Chapters)
      if (data.containsKey('bookmarks') && data['bookmarks'] is List) {
        for (final item in data['bookmarks'] as List) {
          final row = Bookmark.fromJson(item as Map<String, dynamic>);
          await into(bookmarks).insertOnConflictUpdate(row);
        }
      }

      // 9. Settings (standalone key-value)
      if (data.containsKey('settings') && data['settings'] is List) {
        for (final item in data['settings'] as List) {
          final row = UserSettingsEntry.fromJson(item as Map<String, dynamic>);
          await into(userSettingsEntries).insertOnConflictUpdate(row);
        }
      }
    });
  }

  /// Creates a raw file backup of the database to [destination].
  Future<void> backupDatabase(File destination) async {
    // Vacuums into destination file
    await customStatement('VACUUM INTO ?;', [destination.path]);
  }
}
