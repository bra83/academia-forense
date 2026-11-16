import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:content_core/content_core.dart';
import '../models/sync_result.dart';

/// 10-step Content Ingestion Engine from §2.1.
class ContentIngestionEngine {
  final Section19Validator _validator;
  final Set<String> _processedSha256Hashes = {};
  final Map<String, ChapterPackage> _catalog = {};
  final List<Map<String, dynamic>> _syncJournal = [];
  final AnnotationEngine _annotationEngine;

  ContentIngestionEngine({
    Section19Validator? validator,
    AnnotationEngine? annotationEngine,
  })  : _validator = validator ?? Section19Validator(),
        _annotationEngine = annotationEngine ?? AnnotationEngine();

  Set<String> get processedHashes => Set.unmodifiable(_processedSha256Hashes);
  Map<String, ChapterPackage> get catalog => Map.unmodifiable(_catalog);
  List<Map<String, dynamic>> get syncJournal => List.unmodifiable(_syncJournal);
  AnnotationEngine get annotationEngine => _annotationEngine;

  /// Registers an existing package in catalog (for migrations and testing).
  void setInitialCatalogPackage(ChapterPackage pkg) {
    _catalog[pkg.contentId] = pkg;
  }

  /// Executes the canonical 10-step ingestion pipeline on [rawJsonBytes].
  Future<IngestionResult> ingestPackageBytes(
    List<int> rawJsonBytes, {
    String? sourceFileName,
    String provider = 'local_directory',
  }) async {
    // Step 1: Detect new/modified file
    if (rawJsonBytes.isEmpty) {
      return IngestionResult.failure(['Empty payload detected.']);
    }

    // Step 2: Identify type & location
    String jsonString;
    try {
      jsonString = utf8.decode(rawJsonBytes);
    } catch (e) {
      return IngestionResult.failure(['Invalid UTF-8 byte stream: $e']);
    }

    // Step 3: Compute authentic SHA-256 for deduplication
    final sha256Hash = sha256.convert(rawJsonBytes).toString();
    if (_processedSha256Hashes.contains(sha256Hash)) {
      return IngestionResult.duplicate(
        sha256Hash,
        'Duplicate package detected with identical SHA-256 hash ($sha256Hash). Skipping redundant processing.',
      );
    }

    // Step 7: Validate schema & integrity
    final report = _validator.validateJsonString(jsonString);
    if (!report.isValid) {
      _recordJournal(
        provider: provider,
        fileName: sourceFileName ?? 'unknown',
        sha256: sha256Hash,
        status: 'FAILED_VALIDATION',
      );
      return IngestionResult.failure(report.errors, sha256: sha256Hash);
    }

    // Parse JSON
    final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
    final package = ChapterPackage.fromJson(jsonMap);

    // Step 4: Extract text, images, tables, refs
    final extractedMetadata = {
      'sectionsCount': package.sections.length,
      'glossaryTermsCount': package.glossary.length,
      'figuresCount': package.figures.length,
      'tablesCount': package.tables.length,
      'referencesCount': package.references.length,
      'exercisesCount': package.exercises.length,
      'laboratoriesCount': package.laboratories.length,
      'hasAssessment': package.assessment != null,
      'audioEnabled': package.audio.enabled,
    };

    // Step 5: Associate with volume, chapter, lab
    final volumeId = package.volume;
    final chapterNumber = package.chapter;
    final expectedVolumeId = CurriculumCatalog.getVolumeForChapter(chapterNumber);
    if (volumeId != expectedVolumeId) {
      return IngestionResult.failure([
        'Inconsistent curriculum mapping: Chapter $chapterNumber belongs to Volume $expectedVolumeId, but package specifies Volume $volumeId.',
      ], sha256: sha256Hash);
    }

    // Step 6: Classify revision & editorial status
    final isApproved = CurriculumCatalog.isPubliclyAvailable(package.editorialStatus);

    // Step 8: Provide preview metadata
    final preview = {
      'contentId': package.contentId,
      'title': package.title,
      'volume': package.volume,
      'chapter': package.chapter,
      'edition': package.edition,
      'editorialStatus': package.editorialStatus,
      'isPubliclyAvailable': isApproved,
      ...extractedMetadata,
    };

    // Step 9: Publish only approved content
    // Non-approved content can be staged in staging/catalog with their status preserved,
    // but only Aprovado/Publicado is marked ready for public curriculum study.

    // Step 10: Safe catalog update without affecting user notes/scores (§2.2)
    final existingPackage = _catalog[package.contentId];
    if (existingPackage != null) {
      // Revision update: safe update with anchor drift detection
      final combinedMarkdown = package.sections.map((s) => s.markdownContent).join('\n\n');
      _annotationEngine.applyRevisionUpdate(
        chapterId: package.contentId,
        fromRevision: existingPackage.edition,
        toRevision: package.edition,
        newContent: combinedMarkdown,
        reason: 'Revision upgrade from ${existingPackage.edition} to ${package.edition}',
      );
    }

    // Register into catalog and record deduplication hash
    _catalog[package.contentId] = package;
    _processedSha256Hashes.add(sha256Hash);

    _recordJournal(
      provider: provider,
      fileName: sourceFileName ?? '${package.contentId}.json',
      sha256: sha256Hash,
      status: 'IMPORTED',
    );

    return IngestionResult.success(
      sha256: sha256Hash,
      package: package,
      previewMetadata: preview,
      warnings: report.warnings,
    );
  }

  void _recordJournal({
    required String provider,
    required String fileName,
    required String sha256,
    required String status,
  }) {
    _syncJournal.add({
      'journal_id': 'j-${DateTime.now().millisecondsSinceEpoch}-${_syncJournal.length}',
      'provider': provider,
      'file_name': fileName,
      'sha256': sha256,
      'status': status,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
