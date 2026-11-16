import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:content_core/content_core.dart';
import '../models/sync_result.dart';

/// Provider for ingesting packages from local directory or JSON file (§2.1).
class LocalDirectoryContentProvider {
  final Section19Validator _validator = Section19Validator();

  String get providerName => 'local_directory';

  /// Ingests a JSON file from local disk and computes authentic SHA-256 hash.
  Future<IngestionResult> ingestJsonFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw FileSystemException('Package file not found: $filePath', filePath);
    }

    final bytes = await file.readAsBytes();
    final sha256Hash = sha256.convert(bytes).toString();

    try {
      final jsonString = utf8.decode(bytes);
      final report = _validator.validateJsonString(jsonString);
      if (!report.isValid) {
        return IngestionResult.failure(report.errors, sha256: sha256Hash);
      }

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final pkg = ChapterPackage.fromJson(jsonMap);

      return IngestionResult.success(
        sha256: sha256Hash,
        package: pkg,
        previewMetadata: {
          'contentId': pkg.contentId,
          'title': pkg.title,
          'edition': pkg.edition,
          'sectionsCount': pkg.sections.length,
          'fileSizeBytes': bytes.length,
        },
        warnings: report.warnings,
      );
    } catch (e) {
      return IngestionResult.failure(['Failed to parse JSON package: $e'], sha256: sha256Hash);
    }
  }

  /// Ingests all package JSON files from a directory.
  Future<List<IngestionResult>> ingestDirectory(String directoryPath) async {
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      throw FileSystemException('Directory not found: $directoryPath', directoryPath);
    }

    final results = <IngestionResult>[];
    await for (final entity in dir.list(recursive: false)) {
      if (entity is File && entity.path.endsWith('.json')) {
        results.add(await ingestJsonFile(entity.path));
      }
    }
    return results;
  }
}
