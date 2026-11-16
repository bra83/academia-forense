import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:content_core/content_core.dart';
import 'package:drive_sync/drive_sync.dart';

String getRepoRoot() {
  var dir = Directory.current;
  while (!File('${dir.path}/content/schemas/section_19_schema.json').existsSync()) {
    final parent = dir.parent;
    if (parent.path == dir.path) {
      return '/home/antigravity';
    }
    dir = parent;
  }
  return dir.path;
}

void main() {
  final repoRoot = getRepoRoot();
  final fixturesPath = '$repoRoot/content/fixtures/volume_01';

  group('GoogleDriveContentProvider (§1.1, §2.1)', () {
    test('reports BLOCKED when unauthenticated without simulating success', () async {
      const provider = GoogleDriveContentProvider(authToken: null);
      final result = await provider.sync();

      expect(result.status, equals(SyncStatus.blocked));
      expect(result.isBlocked, isTrue);
      expect(result.reason, contains('authentication token missing'));
    });

    test('reports BLOCKED when token is whitespace', () async {
      const provider = GoogleDriveContentProvider(authToken: '   ');
      final result = await provider.sync();

      expect(result.status, equals(SyncStatus.blocked));
    });
  });

  group('LocalDirectoryContentProvider (§2.1)', () {
    final provider = LocalDirectoryContentProvider();

    test('ingests JSON file and computes authentic 64-char SHA-256', () async {
      final samplePath = '$fixturesPath/vol01_ch01.json';
      final result = await provider.ingestJsonFile(samplePath);

      expect(result.status, equals(SyncStatus.success));
      expect(result.isSuccess, isTrue);
      expect(result.sha256, isNotNull);
      expect(result.sha256!.length, equals(64));
      expect(result.package?.contentId, equals('forense.vol01.ch01'));
      expect(result.package?.volume, equals(1));
      expect(result.package?.edition, equals('REV2'));
    });

    test('throws FileSystemException when file does not exist', () async {
      expect(
        () => provider.ingestJsonFile('$repoRoot/non_existent_package_file.json'),
        throwsA(isA<FileSystemException>()),
      );
    });
  });

  group('FixtureContentProvider', () {
    late FixtureContentProvider provider;

    setUp(() {
      provider = FixtureContentProvider(
        baseFixturesPath: fixturesPath,
      );
    });

    test('loads Chapter 1 fixture accurately', () async {
      final result = await provider.loadChapterFixture(1);

      expect(result.status, equals(SyncStatus.success));
      expect(result.package?.chapter, equals(1));
      expect(result.package?.edition, equals('REV2'));
      expect(result.sha256!.length, equals(64));
    });

    test('loads all 10 seed packages for Volume 1', () async {
      final results = await provider.loadAllVolume1Fixtures();

      expect(results.length, equals(10));
      for (var i = 0; i < 10; i++) {
        final res = results[i];
        expect(res.isSuccess, isTrue, reason: 'Failed for Chapter ${i + 1}: ${res.errors}');
        expect(res.package?.chapter, equals(i + 1));
        if (i < 4) {
          expect(res.package?.edition, equals('REV2'));
        } else {
          expect(res.package?.edition, equals('REV1'));
        }
      }
    });
  });

  group('ContentIngestionEngine (10-Step Pipeline & Safe Updates)', () {
    test('executes 10-step pipeline and deduplicates duplicate SHA-256', () async {
      final engine = ContentIngestionEngine();
      final file = File('$fixturesPath/vol01_ch01.json');
      final bytes = await file.readAsBytes();

      // First ingestion -> SUCCESS
      final res1 = await engine.ingestPackageBytes(bytes, sourceFileName: 'vol01_ch01.json');
      expect(res1.status, equals(SyncStatus.success));
      expect(engine.catalog.containsKey('forense.vol01.ch01'), isTrue);
      expect(engine.processedHashes.contains(res1.sha256), isTrue);

      // Second ingestion with identical bytes -> DUPLICATE
      final res2 = await engine.ingestPackageBytes(bytes, sourceFileName: 'vol01_ch01.json');
      expect(res2.status, equals(SyncStatus.duplicate));
      expect(res2.isDuplicate, isTrue);

      // Verify sync journal logged the operations
      expect(engine.syncJournal.length, equals(1));
      expect(engine.syncJournal.first['status'], equals('IMPORTED'));
      expect(engine.syncJournal.first['sha256'], equals(res1.sha256));
    });

    test('safe revision update preserves student notes and detects anchor drift', () async {
      final engine = ContentIngestionEngine();

      // Pre-populate student annotation on REV1
      engine.annotationEngine.addAnnotation(
        noteId: 'note-01',
        chapterId: 'forense.vol01.ch01',
        revision: 'REV1',
        anchorText: 'entropia de Shannon',
        note: 'Nota de estudo sobre entropia',
      );
      engine.annotationEngine.addAnnotation(
        noteId: 'note-02',
        chapterId: 'forense.vol01.ch01',
        revision: 'REV1',
        anchorText: 'Trecho Obsoleto Que Foi Deletado',
        note: 'Nota sobre trecho que sumiu',
      );

      // Ingest Ch 1 (which contains 'entropia de Shannon' but not the obsolete text)
      final file = File('$fixturesPath/vol01_ch01.json');
      final bytes = await file.readAsBytes();

      // Simulate prior catalog presence so revision decoupling triggers
      final pkgMap = json.decode(utf8.decode(bytes)) as Map<String, dynamic>;
      final initialPkg = ChapterPackage.fromJson(pkgMap);
      // Pre-set in catalog as REV1
      engine.setInitialCatalogPackage(ChapterPackage(
        schemaVersion: initialPkg.schemaVersion,
        contentId: initialPkg.contentId,
        type: initialPkg.type,
        volume: initialPkg.volume,
        chapter: initialPkg.chapter,
        title: initialPkg.title,
        language: initialPkg.language,
        edition: 'REV1',
        editorialStatus: initialPkg.editorialStatus,
        source: initialPkg.source,
        sections: initialPkg.sections,
        learningObjectives: initialPkg.learningObjectives,
        prerequisites: initialPkg.prerequisites,
        glossary: initialPkg.glossary,
        figures: initialPkg.figures,
        tables: initialPkg.tables,
        references: initialPkg.references,
        exercises: initialPkg.exercises,
        laboratories: initialPkg.laboratories,
        assessment: initialPkg.assessment,
        audio: initialPkg.audio,
      ));

      final res = await engine.ingestPackageBytes(bytes, sourceFileName: 'vol01_ch01.json');
      expect(res.status, equals(SyncStatus.success));

      final ann1 = engine.annotationEngine.annotations.firstWhere((a) => a.noteId == 'note-01');
      final ann2 = engine.annotationEngine.annotations.firstWhere((a) => a.noteId == 'note-02');

      // Notes are preserved!
      expect(ann1.revision, equals('REV2'));
      expect(ann1.driftWarning, isFalse); // Anchor 'entropia de Shannon' exists in Ch 1
      expect(ann2.revision, equals('REV2'));
      expect(ann2.driftWarning, isTrue); // Obsolete text doesn't exist -> drift warning
    });
  });
}
