import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

  group('Adversarial Ingestion & Duplicate Handling (ContentIngestionEngine)', () {
    late ContentIngestionEngine engine;

    setUp(() {
      engine = ContentIngestionEngine();
    });

    test('ingests package once then detects duplicate SHA-256 on second ingestion', () async {
      final file = File('$fixturesPath/vol01_ch01.json');
      final bytes = await file.readAsBytes();

      // First ingestion
      final res1 = await engine.ingestPackageBytes(bytes, sourceFileName: 'vol01_ch01.json');
      expect(res1.status, equals(SyncStatus.success));
      expect(res1.isSuccess, isTrue);
      expect(engine.catalog.containsKey('forense.vol01.ch01'), isTrue);
      expect(engine.processedHashes.contains(res1.sha256), isTrue);
      expect(engine.syncJournal.length, equals(1));
      expect(engine.syncJournal.first['status'], equals('IMPORTED'));

      // Second ingestion with identical SHA-256
      final res2 = await engine.ingestPackageBytes(bytes, sourceFileName: 'vol01_ch01.json');
      expect(res2.status, equals(SyncStatus.duplicate));
      expect(res2.isDuplicate, isTrue);
      expect(res2.reason, contains('Duplicate package detected with identical SHA-256'));

      // Catalog not duplicated or corrupted
      expect(engine.catalog.length, equals(1));
      expect(engine.syncJournal.length, equals(1)); // Duplicate skipped journal mutation
    });

    test('rejects empty byte payload gracefully without throwing unhandled exceptions', () async {
      final res = await engine.ingestPackageBytes([]);
      expect(res.status, equals(SyncStatus.failed));
      expect(res.errors, contains('Empty payload detected.'));
      expect(engine.catalog, isEmpty);
    });

    test('rejects corrupt/non-UTF8 byte streams gracefully', () async {
      final corruptBytes = [0xC0, 0xAF, 0xFF, 0xFE, 0xFD]; // invalid UTF-8
      final res = await engine.ingestPackageBytes(corruptBytes);
      expect(res.status, equals(SyncStatus.failed));
      expect(res.errors.any((e) => e.contains('Invalid UTF-8 byte stream')), isTrue);
      expect(engine.catalog, isEmpty);
    });

    test('rejects malformed JSON payload and logs FAILED_VALIDATION in sync journal', () async {
      final malformedBytes = utf8.encode('{"schemaVersion": "1.0", "unclosed": ');
      final res = await engine.ingestPackageBytes(malformedBytes, sourceFileName: 'malformed.json');

      expect(res.status, equals(SyncStatus.failed));
      expect(res.sha256, isNotNull);
      expect(res.sha256!.length, equals(64));
      expect(res.errors.any((e) => e.contains('Malformed JSON syntax')), isTrue);

      // Journal records the validation failure for forensic audit
      expect(engine.syncJournal.length, equals(1));
      expect(engine.syncJournal.first['status'], equals('FAILED_VALIDATION'));
      expect(engine.syncJournal.first['sha256'], equals(res.sha256));
    });

    test('rejects package with mismatched curriculum mapping (e.g. Ch 15 in Vol 1)', () async {
      final file = File('$fixturesPath/vol01_ch01.json');
      final validMap = json.decode(await file.readAsString()) as Map<String, dynamic>;

      // Inconsistent: declare Volume 1, but Chapter 15 (which belongs to Volume 2)
      validMap['volume'] = 1;
      validMap['chapter'] = 15;
      validMap['contentId'] = 'forense.vol01.ch15';

      final alteredBytes = utf8.encode(json.encode(validMap));
      final res = await engine.ingestPackageBytes(alteredBytes);

      expect(res.status, equals(SyncStatus.failed));
      expect(
        res.errors.any((e) => e.contains('Inconsistent curriculum mapping')),
        isTrue,
        reason: 'Must catch Chapter 15 belonging to Volume 2, not Volume 1',
      );
      expect(engine.catalog.containsKey('forense.vol01.ch15'), isFalse);
    });
  });

  group('Adversarial Missing File Path Handling (LocalDirectoryContentProvider)', () {
    late LocalDirectoryContentProvider provider;

    setUp(() {
      provider = LocalDirectoryContentProvider();
    });

    test('throws FileSystemException when package file does not exist', () async {
      const nonExistentPath = '/home/antigravity/content/fixtures/volume_01/ghost_ch99.json';
      expect(
        () => provider.ingestJsonFile(nonExistentPath),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('throws FileSystemException when directory does not exist', () async {
      const nonExistentDir = '/home/antigravity/content/non_existent_directory_404';
      expect(
        () => provider.ingestDirectory(nonExistentDir),
        throwsA(isA<FileSystemException>()),
      );
    });

    test('handles directory with mixed valid and invalid JSON files gracefully', () async {
      final tempDir = await Directory.systemTemp.createTemp('forensic_ingest_test_');
      try {
        // Write one valid file
        final validFile = File('${tempDir.path}/valid.json');
        final validSrc = await File('$fixturesPath/vol01_ch01.json').readAsString();
        await validFile.writeAsString(validSrc);

        // Write one corrupt file
        final corruptFile = File('${tempDir.path}/corrupt.json');
        await corruptFile.writeAsString('{not valid json at all');

        final results = await provider.ingestDirectory(tempDir.path);
        expect(results.length, equals(2));

        final successResult = results.firstWhere((r) => r.isSuccess);
        final failureResult = results.firstWhere((r) => !r.isSuccess);

        expect(successResult.status, equals(SyncStatus.success));
        expect(successResult.package?.contentId, equals('forense.vol01.ch01'));

        expect(failureResult.status, equals(SyncStatus.failed));
        expect(failureResult.errors, isNotEmpty);
      } finally {
        await tempDir.delete(recursive: true);
      }
    });
  });

  group('Adversarial Google Drive Provider State Handling', () {
    test('reports BLOCKED when authToken is null', () async {
      const provider = GoogleDriveContentProvider(authToken: null);
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.blocked));
      expect(res.isBlocked, isTrue);
      expect(res.reason, contains('authentication token missing'));
    });

    test('reports BLOCKED when authToken is empty string', () async {
      const provider = GoogleDriveContentProvider(authToken: '');
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.blocked));
      expect(res.isBlocked, isTrue);
    });

    test('reports BLOCKED when authToken is whitespace only', () async {
      const provider = GoogleDriveContentProvider(authToken: '   \t\n  ');
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.blocked));
      expect(res.isBlocked, isTrue);
    });

    test('reports BLOCKED when Drive API returns HTTP 401 Unauthorized', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": {"code": 401, "message": "Unauthorized"}}', 401);
      });

      final provider = GoogleDriveContentProvider(
        authToken: 'expired_or_invalid_oauth_token',
        client: mockClient,
      );
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.blocked));
      expect(res.isBlocked, isTrue);
      expect(res.reason, contains('HTTP 401'));
    });

    test('reports BLOCKED when Drive API returns HTTP 403 Forbidden', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"error": {"code": 403, "message": "Forbidden"}}', 403);
      });

      final provider = GoogleDriveContentProvider(
        authToken: 'insufficient_scopes_token',
        client: mockClient,
      );
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.blocked));
      expect(res.isBlocked, isTrue);
      expect(res.reason, contains('HTTP 403'));
    });

    test('reports FAILURE when Drive API returns HTTP 500 Server Error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final provider = GoogleDriveContentProvider(
        authToken: 'valid_token_but_server_down',
        client: mockClient,
      );
      final res = await provider.sync();

      expect(res.status, equals(SyncStatus.failed));
      expect(res.errors.any((e) => e.contains('HTTP 500')), isTrue);
    });
  });
}
