import 'dart:convert';
import 'validation_report.dart';

/// Validator for curriculum manifests conforming to Draft 2020-12 rules.
class CurriculumManifestValidator {
  static final RegExp _contentIdRegex = RegExp(r'^forense\.vol[0-9]{2}\.ch[0-9]{2,3}$');
  static final RegExp _versionRegex = RegExp(r'^[0-9]+\.[0-9]+$');

  static const Set<String> _validEditorialStates = {
    'Planejado',
    'Importado',
    'Em revisão',
    'Aprovado',
    'Publicado',
    'Substituído',
    'Arquivado',
  };

  /// Validates a raw curriculum manifest JSON string.
  ValidationReport validateJsonString(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return ValidationReport.failure([
          'Manifest root must be an object (Map<String, dynamic>).'
        ]);
      }
      return validateJsonMap(decoded);
    } catch (e) {
      return ValidationReport.failure(['Malformed JSON syntax in manifest: $e']);
    }
  }

  /// Validates a decoded manifest Map.
  ValidationReport validateJsonMap(Map<String, dynamic> manifest) {
    final errors = <String>[];
    final warnings = <String>[];

    const requiredFields = [
      'curriculumId',
      'title',
      'version',
      'language',
      'totalVolumes',
      'totalChapters',
      'editorialStatusDistribution',
      'volume1PrintPreservation',
      'volumes',
      'chapters',
    ];

    for (final field in requiredFields) {
      if (!manifest.containsKey(field) || manifest[field] == null) {
        errors.add('Manifest missing required field "$field"');
      }
    }

    if (manifest['totalVolumes'] != 9) {
      errors.add('Manifest totalVolumes must equal 9 (got ${manifest['totalVolumes']})');
    }

    if (manifest['totalChapters'] != 113) {
      errors.add('Manifest totalChapters must equal 113 (got ${manifest['totalChapters']})');
    }

    if (manifest['version'] != null && !_versionRegex.hasMatch(manifest['version'].toString())) {
      errors.add('Manifest version must match pattern ^[0-9]+\\.[0-9]+\$');
    }

    // Validate 7 editorial lifecycle states
    if (manifest['editorialStatusDistribution'] is Map) {
      final dist = manifest['editorialStatusDistribution'] as Map;
      for (final state in _validEditorialStates) {
        if (!dist.containsKey(state)) {
          errors.add('editorialStatusDistribution missing state "$state"');
        } else if (dist[state] is! int || (dist[state] as int) < 0) {
          errors.add('editorialStatusDistribution["$state"] must be a non-negative integer');
        }
      }
    } else {
      errors.add('editorialStatusDistribution must be an object');
    }

    // Validate Volume 1 Print Preservation
    if (manifest['volume1PrintPreservation'] is Map) {
      final v1 = manifest['volume1PrintPreservation'] as Map;
      if (v1['volumeId'] != 1) {
        errors.add('volume1PrintPreservation volumeId must be 1');
      }
      if (v1['exactPrintedPages'] != 133) {
        errors.add('volume1PrintPreservation exactPrintedPages must be 133');
      }
      if (v1['canonicalRevisions'] is Map) {
        final revs = v1['canonicalRevisions'] as Map;
        if (revs['chapters1to4'] != 'REV2') {
          errors.add('canonicalRevisions.chapters1to4 must be "REV2"');
        }
        if (revs['chapters5to10'] != 'REV1') {
          errors.add('canonicalRevisions.chapters5to10 must be "REV1"');
        }
      } else {
        errors.add('volume1PrintPreservation missing canonicalRevisions');
      }
    }

    // Validate volumes
    if (manifest['volumes'] is List) {
      final vols = manifest['volumes'] as List;
      if (vols.length != 9) {
        errors.add('volumes array must contain exactly 9 entries (got ${vols.length})');
      }
    }

    // Validate chapters
    if (manifest['chapters'] is List) {
      final chs = manifest['chapters'] as List;
      if (chs.length != 113) {
        errors.add('chapters array must contain exactly 113 entries (got ${chs.length})');
      }
      for (var i = 0; i < chs.length; i++) {
        final ch = chs[i];
        if (ch is Map) {
          final cid = ch['content_id']?.toString() ?? '';
          if (!_contentIdRegex.hasMatch(cid)) {
            errors.add('chapters[$i].content_id "$cid" does not match ^forense\\.vol[0-9]{2}\\.ch[0-9]{2,3}\$');
          }
          final status = ch['editorial_status']?.toString();
          if (!_validEditorialStates.contains(status)) {
            errors.add('chapters[$i].editorial_status "$status" is not a valid 7-state status');
          }
        }
      }
    }

    return errors.isEmpty
        ? ValidationReport.success(warnings)
        : ValidationReport.failure(errors, warnings);
  }
}
