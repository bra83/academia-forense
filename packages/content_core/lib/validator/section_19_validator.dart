import 'dart:convert';
import '../models/chapter_package.dart';
import 'validation_report.dart';

/// Validator implementing strict Draft 2020-12 rules for Section 19 educational packages.
class Section19Validator {
  static final RegExp _schemaVersionRegex = RegExp(r'^[0-9]+\.[0-9]+$');
  static final RegExp _contentIdRegex = RegExp(r'^forense\.vol[0-9]{2}\.ch[0-9]{2}$');
  static final RegExp _editionRegex = RegExp(r'^REV[0-9]+$');
  static final RegExp _sha256Regex = RegExp(r'^[a-fA-F0-9]{64}$');

  static const Set<String> _validTypes = {'chapter', 'appendix', 'case_study'};
  static const Set<String> _validLanguages = {'pt-BR', 'en-US'};
  static const Set<String> _validProviders = {
    'google_drive',
    'local_file',
    'local_directory',
    'fixture',
  };
  static const Set<String> _validEditorialStatuses = {
    'Planejado',
    'Importado',
    'Em revisão',
    'Aprovado',
    'Publicado',
    'Substituído',
    'Arquivado',
    'planned',
    'imported',
    'under_review',
    'approved',
    'published',
    'superseded',
    'archived',
  };
  static const Set<String> _validExerciseTypes = {'objective', 'discursive', 'code'};
  static const Set<String> _validLabDomains = {
    'informatics',
    'math',
    'programming',
    'digital_forensics',
    'telephony',
    'linguistics',
    'multimedia',
  };
  static const Set<String> _validQuestionTypes = {
    'multiple_choice',
    'discursive',
    'code_check',
  };

  /// Validates a ChapterPackage instance.
  ValidationReport validatePackage(ChapterPackage package) {
    return validateJsonMap(package.toJson());
  }

  /// Validates a raw JSON string.
  ValidationReport validateJsonString(String jsonString) {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return ValidationReport.failure([
          'Root JSON document must be an object (Map<String, dynamic>).'
        ]);
      }
      return validateJsonMap(decoded);
    } catch (e) {
      return ValidationReport.failure(['Malformed JSON syntax: $e']);
    }
  }

  /// Validates a raw JSON Map against Section 19 schema rules.
  ValidationReport validateJsonMap(Map<String, dynamic> json) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. Mandatory top-level fields
    const requiredFields = [
      'schemaVersion',
      'contentId',
      'type',
      'volume',
      'chapter',
      'title',
      'language',
      'edition',
      'editorialStatus',
      'source',
      'sections',
    ];

    for (final field in requiredFields) {
      if (!json.containsKey(field) || json[field] == null) {
        errors.add('Missing mandatory top-level field: "$field"');
      }
    }

    // 2. schemaVersion
    if (json.containsKey('schemaVersion') && json['schemaVersion'] != null) {
      final sv = json['schemaVersion'];
      if (sv is! String || !_schemaVersionRegex.hasMatch(sv)) {
        errors.add(
          'Field "schemaVersion" must match pattern ^[0-9]+\\.[0-9]+\$ (got "$sv")',
        );
      }
    }

    // 3. contentId
    if (json.containsKey('contentId') && json['contentId'] != null) {
      final cid = json['contentId'];
      if (cid is! String || !_contentIdRegex.hasMatch(cid)) {
        errors.add(
          'Field "contentId" must match pattern ^forense\\.vol[0-9]{2}\\.ch[0-9]{2}\$ (got "$cid")',
        );
      }
    }

    // 4. type
    if (json.containsKey('type') && json['type'] != null) {
      final t = json['type'];
      if (t is! String || !_validTypes.contains(t)) {
        errors.add('Field "type" must be one of $_validTypes (got "$t")');
      }
    }

    // 5. volume (1..9)
    if (json.containsKey('volume') && json['volume'] != null) {
      final v = json['volume'];
      if (v is! int || v < 1 || v > 9) {
        errors.add('Field "volume" must be an integer between 1 and 9 (got "$v")');
      }
    }

    // 6. chapter (1..113)
    if (json.containsKey('chapter') && json['chapter'] != null) {
      final ch = json['chapter'];
      if (ch is! int || ch < 1 || ch > 113) {
        errors.add('Field "chapter" must be an integer between 1 and 113 (got "$ch")');
      }
    }

    // 7. title
    if (json.containsKey('title') && json['title'] != null) {
      final title = json['title'];
      if (title is! String || title.trim().isEmpty) {
        errors.add('Field "title" must be a non-empty string');
      }
    }

    // 8. language
    if (json.containsKey('language') && json['language'] != null) {
      final lang = json['language'];
      if (lang is! String || !_validLanguages.contains(lang)) {
        errors.add('Field "language" must be one of $_validLanguages (got "$lang")');
      }
    }

    // 9. edition
    if (json.containsKey('edition') && json['edition'] != null) {
      final ed = json['edition'];
      if (ed is! String || !_editionRegex.hasMatch(ed)) {
        errors.add(
          'Field "edition" must match pattern ^REV[0-9]+\$ (e.g. REV1, REV2, REV3) (got "$ed")',
        );
      }
    }

    // 10. editorialStatus
    if (json.containsKey('editorialStatus') && json['editorialStatus'] != null) {
      final status = json['editorialStatus'];
      if (status is! String || !_validEditorialStatuses.contains(status)) {
        errors.add(
          'Field "editorialStatus" must be one of $_validEditorialStatuses (got "$status")',
        );
      }
    }

    // 11. source
    if (json.containsKey('source') && json['source'] != null) {
      if (json['source'] is! Map) {
        errors.add('Field "source" must be an object');
      } else {
        final src = json['source'] as Map;
        if (!src.containsKey('provider') || src['provider'] == null) {
          errors.add('Field "source.provider" is required');
        } else if (!_validProviders.contains(src['provider'])) {
          errors.add(
            'Field "source.provider" must be one of $_validProviders (got "${src['provider']}")',
          );
        }
        if (src.containsKey('sha256') && src['sha256'] != null && src['sha256'] != '') {
          final sha = src['sha256'].toString();
          if (!_sha256Regex.hasMatch(sha)) {
            errors.add(
              'Field "source.sha256" must be a 64-character hex string (got "$sha")',
            );
          }
        }
      }
    }

    // 12. sections
    if (json.containsKey('sections') && json['sections'] != null) {
      if (json['sections'] is! List) {
        errors.add('Field "sections" must be an array');
      } else {
        final secs = json['sections'] as List;
        if (secs.isEmpty) {
          errors.add('Field "sections" must contain at least one section');
        }
        for (var i = 0; i < secs.length; i++) {
          final item = secs[i];
          if (item is! Map) {
            errors.add('sections[$i] must be an object');
            continue;
          }
          final sid = item['sectionId'] ?? item['id'];
          if (sid == null || sid.toString().trim().isEmpty) {
            errors.add('sections[$i] missing required "sectionId" (or "id")');
          }
          final stitle = item['title'];
          if (stitle == null || stitle.toString().trim().isEmpty) {
            errors.add('sections[$i] missing required "title"');
          }
          final scontent = item['markdownContent'] ?? item['content'];
          if (scontent == null) {
            errors.add('sections[$i] missing required "markdownContent" (or "content")');
          }
        }
      }
    }

    // 13. glossary (optional in minimal, required in full Section 19)
    if (json.containsKey('glossary') && json['glossary'] is List) {
      final gloss = json['glossary'] as List;
      for (var i = 0; i < gloss.length; i++) {
        final g = gloss[i];
        if (g is Map) {
          if (!g.containsKey('term') || g['term'] == null || g['term'].toString().isEmpty) {
            errors.add('glossary[$i] missing required "term"');
          }
          if (!g.containsKey('definition') || g['definition'] == null || g['definition'].toString().isEmpty) {
            errors.add('glossary[$i] missing required "definition"');
          }
        }
      }
    }

    // 14. exercises (if present)
    if (json.containsKey('exercises') && json['exercises'] is List) {
      final exs = json['exercises'] as List;
      for (var i = 0; i < exs.length; i++) {
        final ex = exs[i];
        if (ex is Map) {
          final t = ex['exerciseType'] ?? ex['type'];
          if (t != null && !_validExerciseTypes.contains(t)) {
            errors.add(
              'exercises[$i].exerciseType must be one of $_validExerciseTypes (got "$t")',
            );
          }
        }
      }
    }

    // 15. laboratories (if present)
    if (json.containsKey('laboratories') && json['laboratories'] is List) {
      final labs = json['laboratories'] as List;
      for (var i = 0; i < labs.length; i++) {
        final lab = labs[i];
        if (lab is Map) {
          final d = lab['domain'];
          if (d != null && !_validLabDomains.contains(d)) {
            errors.add(
              'laboratories[$i].domain must be one of $_validLabDomains (got "$d")',
            );
          }
        }
      }
    }

    // 16. assessment (if present)
    if (json.containsKey('assessment') && json['assessment'] != null) {
      if (json['assessment'] is! Map) {
        errors.add('Field "assessment" must be an object or null');
      } else {
        final ass = json['assessment'] as Map;
        final aid = ass['assessmentId'] ?? ass['id'];
        if (aid == null) {
          errors.add('assessment missing required "assessmentId"');
        }
        final passScore = ass['passingScorePercent'];
        if (passScore != null && (passScore is! num || passScore < 0 || passScore > 100)) {
          errors.add('assessment "passingScorePercent" must be between 0 and 100');
        }
        final qs = ass['questions'];
        if (qs is List) {
          for (var i = 0; i < qs.length; i++) {
            final q = qs[i];
            if (q is Map) {
              if (q['questionId'] == null && q['id'] == null) {
                errors.add('assessment.questions[$i] missing "questionId"');
              }
              if (q['prompt'] == null) {
                errors.add('assessment.questions[$i] missing "prompt"');
              }
              if (q['type'] != null && !_validQuestionTypes.contains(q['type'])) {
                errors.add(
                  'assessment.questions[$i].type must be one of $_validQuestionTypes (got "${q['type']}")',
                );
              }
            }
          }
        }
      }
    }

    return errors.isEmpty
        ? ValidationReport.success(warnings)
        : ValidationReport.failure(errors, warnings);
  }
}
