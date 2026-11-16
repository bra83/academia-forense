import 'dart:convert';
import 'package:crypto/crypto.dart';

class PackageSource {
  final String provider; // google_drive, local_file, local_directory, fixture
  final String? fileId;
  final String? revision;
  final String? sha256;

  const PackageSource({
    required this.provider,
    this.fileId,
    this.revision,
    this.sha256,
  });

  factory PackageSource.fromJson(Map<String, dynamic> json) {
    return PackageSource(
      provider: json['provider'] as String? ?? 'fixture',
      fileId: json['fileId'] as String?,
      revision: json['revision'] as String?,
      sha256: json['sha256'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provider': provider,
        if (fileId != null) 'fileId': fileId,
        if (revision != null) 'revision': revision,
        if (sha256 != null) 'sha256': sha256,
      };

  PackageSource copyWith({
    String? provider,
    String? fileId,
    String? revision,
    String? sha256,
  }) {
    return PackageSource(
      provider: provider ?? this.provider,
      fileId: fileId ?? this.fileId,
      revision: revision ?? this.revision,
      sha256: sha256 ?? this.sha256,
    );
  }
}

class SectionItem {
  final String sectionId;
  final String title;
  final int orderIndex;
  final String markdownContent;
  final String? anchorKey;
  final int? page;

  const SectionItem({
    required this.sectionId,
    required this.title,
    required this.orderIndex,
    required this.markdownContent,
    this.anchorKey,
    this.page,
  });

  factory SectionItem.fromJson(Map<String, dynamic> json) {
    return SectionItem(
      sectionId: (json['sectionId'] ?? json['id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      orderIndex: (json['orderIndex'] ?? json['page'] ?? 0) as int,
      markdownContent: (json['markdownContent'] ?? json['content'] ?? '') as String,
      anchorKey: json['anchorKey'] as String?,
      page: json['page'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'sectionId': sectionId,
        'title': title,
        'orderIndex': orderIndex,
        'markdownContent': markdownContent,
        if (anchorKey != null) 'anchorKey': anchorKey,
      };
}

class GlossaryItem {
  final String term;
  final String definition;

  const GlossaryItem({required this.term, required this.definition});

  factory GlossaryItem.fromJson(Map<String, dynamic> json) {
    return GlossaryItem(
      term: (json['term'] ?? '') as String,
      definition: (json['definition'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'term': term,
        'definition': definition,
      };
}

class FigureItem {
  final String figureId;
  final String caption;
  final String assetPath;

  const FigureItem({
    required this.figureId,
    required this.caption,
    required this.assetPath,
  });

  factory FigureItem.fromJson(Map<String, dynamic> json) {
    return FigureItem(
      figureId: (json['figureId'] ?? json['id'] ?? '') as String,
      caption: (json['caption'] ?? '') as String,
      assetPath: (json['assetPath'] ?? json['path'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'figureId': figureId,
        'caption': caption,
        'assetPath': assetPath,
      };
}

class TableItem {
  final String? tableId;
  final String? caption;
  final List<dynamic>? headers;
  final List<dynamic>? rows;
  final Map<String, dynamic> rawData;

  const TableItem({
    this.tableId,
    this.caption,
    this.headers,
    this.rows,
    this.rawData = const {},
  });

  factory TableItem.fromJson(Map<String, dynamic> json) {
    return TableItem(
      tableId: (json['tableId'] ?? json['id']) as String?,
      caption: json['caption'] as String?,
      headers: (json['columns'] ?? json['headers']) as List<dynamic>?,
      rows: (json['data'] ?? json['rows']) as List<dynamic>?,
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() => rawData.isNotEmpty ? rawData : {
        if (tableId != null) 'tableId': tableId,
        if (caption != null) 'caption': caption,
        if (headers != null) 'headers': headers,
        if (rows != null) 'rows': rows,
      };
}

class ReferenceItem {
  final String citationKey;
  final String formattedText;
  final int? year;

  const ReferenceItem({
    required this.citationKey,
    required this.formattedText,
    this.year,
  });

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      citationKey: (json['citationKey'] ?? json['key'] ?? '') as String,
      formattedText: (json['formattedText'] ?? json['text'] ?? '') as String,
      year: json['year'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'citationKey': citationKey,
        'formattedText': formattedText,
        if (year != null) 'year': year,
      };
}

class ExerciseItem {
  final String exerciseId;
  final String prompt;
  final String exerciseType; // objective, discursive, code
  final String? solution;

  const ExerciseItem({
    required this.exerciseId,
    required this.prompt,
    required this.exerciseType,
    this.solution,
  });

  factory ExerciseItem.fromJson(Map<String, dynamic> json) {
    return ExerciseItem(
      exerciseId: (json['exerciseId'] ?? json['id'] ?? '') as String,
      prompt: (json['prompt'] ?? '') as String,
      exerciseType: (json['exerciseType'] ?? json['type'] ?? 'objective') as String,
      solution: json['solution'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'prompt': prompt,
        'exerciseType': exerciseType,
        if (solution != null) 'solution': solution,
      };
}

class LaboratoryItem {
  final String labId;
  final String domain;
  final String title;
  final String instructions;
  final String? expectedResult;

  const LaboratoryItem({
    required this.labId,
    required this.domain,
    required this.title,
    required this.instructions,
    this.expectedResult,
  });

  factory LaboratoryItem.fromJson(Map<String, dynamic> json) {
    return LaboratoryItem(
      labId: (json['labId'] ?? json['id'] ?? '') as String,
      domain: (json['domain'] ?? 'digital_forensics') as String,
      title: (json['title'] ?? '') as String,
      instructions: (json['instructions'] ?? '') as String,
      expectedResult: json['expectedResult'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'labId': labId,
        'domain': domain,
        'title': title,
        'instructions': instructions,
        if (expectedResult != null) 'expectedResult': expectedResult,
      };
}

class AssessmentOption {
  final String optionId;
  final String text;
  final bool isCorrect;

  const AssessmentOption({
    required this.optionId,
    required this.text,
    required this.isCorrect,
  });

  factory AssessmentOption.fromJson(Map<String, dynamic> json) {
    return AssessmentOption(
      optionId: (json['optionId'] ?? json['id'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      isCorrect: json['isCorrect'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'optionId': optionId,
        'text': text,
        'isCorrect': isCorrect,
      };
}

class AssessmentQuestion {
  final String questionId;
  final String prompt;
  final String type; // multiple_choice, discursive, code_check
  final double points;
  final List<AssessmentOption> options;
  final String? rubric;

  const AssessmentQuestion({
    required this.questionId,
    required this.prompt,
    required this.type,
    required this.points,
    this.options = const [],
    this.rubric,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    final opts = <AssessmentOption>[];
    if (json['options'] is List) {
      for (final opt in json['options'] as List) {
        if (opt is Map<String, dynamic>) {
          opts.add(AssessmentOption.fromJson(opt));
        }
      }
    }
    return AssessmentQuestion(
      questionId: (json['questionId'] ?? json['id'] ?? '') as String,
      prompt: (json['prompt'] ?? '') as String,
      type: (json['type'] ?? 'multiple_choice') as String,
      points: ((json['points'] ?? 10) as num).toDouble(),
      options: opts,
      rubric: json['rubric'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'prompt': prompt,
        'type': type,
        'points': points,
        'options': options.map((o) => o.toJson()).toList(),
        if (rubric != null) 'rubric': rubric,
      };
}

class AssessmentItem {
  final String assessmentId;
  final double passingScorePercent;
  final List<AssessmentQuestion> questions;

  const AssessmentItem({
    required this.assessmentId,
    this.passingScorePercent = 80.0,
    required this.questions,
  });

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    final qs = <AssessmentQuestion>[];
    if (json['questions'] is List) {
      for (final q in json['questions'] as List) {
        if (q is Map<String, dynamic>) {
          qs.add(AssessmentQuestion.fromJson(q));
        }
      }
    }
    return AssessmentItem(
      assessmentId: (json['assessmentId'] ?? json['id'] ?? '') as String,
      passingScorePercent: ((json['passingScorePercent'] ?? 80.0) as num).toDouble(),
      questions: qs,
    );
  }

  Map<String, dynamic> toJson() => {
        'assessmentId': assessmentId,
        'passingScorePercent': passingScorePercent,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

class AudioMetadata {
  final bool enabled;
  final String language;
  final String? voicePreferred;

  const AudioMetadata({
    required this.enabled,
    required this.language,
    this.voicePreferred,
  });

  factory AudioMetadata.fromJson(Map<String, dynamic> json) {
    return AudioMetadata(
      enabled: json['enabled'] as bool? ?? true,
      language: (json['language'] ?? 'pt-BR') as String,
      voicePreferred: json['voicePreferred'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'language': language,
        if (voicePreferred != null) 'voicePreferred': voicePreferred,
      };
}

class ChapterPackage {
  final String schemaVersion;
  final String contentId;
  final String type;
  final int volume;
  final int chapter;
  final String title;
  final String language;
  final String edition;
  final String editorialStatus;
  final PackageSource source;
  final List<SectionItem> sections;
  final List<String> learningObjectives;
  final List<String> prerequisites;
  final List<GlossaryItem> glossary;
  final List<FigureItem> figures;
  final List<TableItem> tables;
  final List<ReferenceItem> references;
  final List<ExerciseItem> exercises;
  final List<LaboratoryItem> laboratories;
  final AssessmentItem? assessment;
  final AudioMetadata audio;

  const ChapterPackage({
    required this.schemaVersion,
    required this.contentId,
    required this.type,
    required this.volume,
    required this.chapter,
    required this.title,
    required this.language,
    required this.edition,
    required this.editorialStatus,
    required this.source,
    required this.sections,
    required this.learningObjectives,
    required this.prerequisites,
    required this.glossary,
    required this.figures,
    required this.tables,
    required this.references,
    required this.exercises,
    required this.laboratories,
    this.assessment,
    required this.audio,
  });

  factory ChapterPackage.fromJson(Map<String, dynamic> json) {
    return ChapterPackage(
      schemaVersion: (json['schemaVersion'] ?? '1.0') as String,
      contentId: (json['contentId'] ?? '') as String,
      type: (json['type'] ?? 'chapter') as String,
      volume: (json['volume'] ?? 1) as int,
      chapter: (json['chapter'] ?? 1) as int,
      title: (json['title'] ?? '') as String,
      language: (json['language'] ?? 'pt-BR') as String,
      edition: (json['edition'] ?? 'REV1') as String,
      editorialStatus: (json['editorialStatus'] ?? 'Planejado') as String,
      source: PackageSource.fromJson(json['source'] as Map<String, dynamic>? ?? {}),
      sections: (json['sections'] as List? ?? [])
          .map((s) => SectionItem.fromJson(s as Map<String, dynamic>))
          .toList(),
      learningObjectives: (json['learningObjectives'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      prerequisites: (json['prerequisites'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      glossary: (json['glossary'] as List? ?? [])
          .map((g) => GlossaryItem.fromJson(g as Map<String, dynamic>))
          .toList(),
      figures: (json['figures'] as List? ?? [])
          .map((f) => FigureItem.fromJson(f as Map<String, dynamic>))
          .toList(),
      tables: (json['tables'] as List? ?? [])
          .map((t) => TableItem.fromJson(t as Map<String, dynamic>))
          .toList(),
      references: (json['references'] as List? ?? [])
          .map((r) => ReferenceItem.fromJson(r as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => ExerciseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      laboratories: (json['laboratories'] as List? ?? [])
          .map((l) => LaboratoryItem.fromJson(l as Map<String, dynamic>))
          .toList(),
      assessment: json['assessment'] != null
          ? AssessmentItem.fromJson(json['assessment'] as Map<String, dynamic>)
          : null,
      audio: json['audio'] != null
          ? AudioMetadata.fromJson(json['audio'] as Map<String, dynamic>)
          : const AudioMetadata(enabled: true, language: 'pt-BR'),
    );
  }

  factory ChapterPackage.fromJsonString(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return ChapterPackage.fromJson(map);
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'contentId': contentId,
        'type': type,
        'volume': volume,
        'chapter': chapter,
        'title': title,
        'language': language,
        'edition': edition,
        'editorialStatus': editorialStatus,
        'source': source.toJson(),
        'sections': sections.map((s) => s.toJson()).toList(),
        'learningObjectives': learningObjectives,
        'prerequisites': prerequisites,
        'glossary': glossary.map((g) => g.toJson()).toList(),
        'figures': figures.map((f) => f.toJson()).toList(),
        'tables': tables.map((t) => t.toJson()).toList(),
        'references': references.map((r) => r.toJson()).toList(),
        'exercises': exercises.map((e) => e.toJson()).toList(),
        'laboratories': laboratories.map((l) => l.toJson()).toList(),
        if (assessment != null) 'assessment': assessment!.toJson(),
        'audio': audio.toJson(),
      };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// Computes authentic SHA-256 hash of this package's payload (excluding mutable source.sha256).
  String computeContentSha256() {
    final copy = toJson();
    final sourceMap = Map<String, dynamic>.from(copy['source'] as Map);
    sourceMap['sha256'] = null;
    copy['source'] = sourceMap;
    final jsonStr = json.encode(copy);
    final bytes = utf8.encode(jsonStr);
    return sha256.convert(bytes).toString();
  }
}
