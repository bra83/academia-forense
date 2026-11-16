import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:content_core/content_core.dart';
import '../models/sync_result.dart';

/// Bundled seed fixture importer for offline testing and initial seeding (§2.1).
class FixtureContentProvider {
  final String baseFixturesPath;
  final Section19Validator _validator = Section19Validator();

  FixtureContentProvider({
    this.baseFixturesPath = 'content/fixtures/volume_01',
  });

  String get providerName => 'fixture';

  /// Loads a specific chapter fixture from the bundled fixtures directory.
  Future<IngestionResult> loadChapterFixture(int chapterNumber) async {
    final paddedCh = chapterNumber.toString().padLeft(2, '0');
    final filePath = '$baseFixturesPath/vol01_ch$paddedCh.json';
    final file = File(filePath);

    if (!await file.exists()) {
      return IngestionResult.failure([
        'Fixture not found for Chapter $chapterNumber at $filePath',
      ]);
    }

    final bytes = await file.readAsBytes();
    final sha256Hash = sha256.convert(bytes).toString();
    final jsonString = utf8.decode(bytes);

    final report = _validator.validateJsonString(jsonString);
    if (!report.isValid) {
      return IngestionResult.failure(report.errors, sha256: sha256Hash);
    }

    final pkg = ChapterPackage.fromJsonString(jsonString);
    return IngestionResult.success(
      sha256: sha256Hash,
      package: pkg,
      previewMetadata: {
        'contentId': pkg.contentId,
        'title': pkg.title,
        'edition': pkg.edition,
        'volume': pkg.volume,
        'chapter': pkg.chapter,
      },
    );
  }

  /// Loads all 10 seed packages for Volume 1.
  Future<List<IngestionResult>> loadAllVolume1Fixtures() async {
    final results = <IngestionResult>[];
    for (var ch = 1; ch <= 10; ch++) {
      results.add(await loadChapterFixture(ch));
    }
    return results;
  }
}
