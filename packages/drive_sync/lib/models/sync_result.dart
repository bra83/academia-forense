import 'package:content_core/content_core.dart';

enum SyncStatus {
  success,
  blocked,
  failed,
  duplicate,
}

class IngestionResult {
  final SyncStatus status;
  final String? sha256;
  final ChapterPackage? package;
  final String? reason;
  final List<String> errors;
  final List<String> warnings;
  final Map<String, dynamic> previewMetadata;

  const IngestionResult({
    required this.status,
    this.sha256,
    this.package,
    this.reason,
    this.errors = const [],
    this.warnings = const [],
    this.previewMetadata = const {},
  });

  bool get isSuccess => status == SyncStatus.success;
  bool get isBlocked => status == SyncStatus.blocked;
  bool get isDuplicate => status == SyncStatus.duplicate;

  factory IngestionResult.success({
    required String sha256,
    required ChapterPackage package,
    Map<String, dynamic> previewMetadata = const {},
    List<String> warnings = const [],
  }) {
    return IngestionResult(
      status: SyncStatus.success,
      sha256: sha256,
      package: package,
      previewMetadata: previewMetadata,
      warnings: warnings,
    );
  }

  factory IngestionResult.blocked(String reason) {
    return IngestionResult(
      status: SyncStatus.blocked,
      reason: reason,
    );
  }

  factory IngestionResult.duplicate(String sha256, String reason) {
    return IngestionResult(
      status: SyncStatus.duplicate,
      sha256: sha256,
      reason: reason,
    );
  }

  factory IngestionResult.failure(List<String> errors, {String? sha256}) {
    return IngestionResult(
      status: SyncStatus.failed,
      sha256: sha256,
      errors: errors,
      reason: errors.join('; '),
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status.name.toUpperCase(),
        if (sha256 != null) 'sha256': sha256,
        if (reason != null) 'reason': reason,
        'errors': errors,
        'warnings': warnings,
        'preview': previewMetadata,
      };
}
