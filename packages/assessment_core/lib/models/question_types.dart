import 'package:meta/meta.dart';

/// Base abstract class for assessment questions (§8.1, §8.2).
@immutable
abstract class AssessmentQuestion {
  const AssessmentQuestion({
    required this.id,
    required this.prompt,
    required this.type,
    this.points = 1.0,
  });

  final String id;
  final String prompt;
  final String type;
  final double points;

  Map<String, dynamic> toJson();
}

/// 1. Multiple Choice Question
class MultipleChoiceQuestion extends AssessmentQuestion {
  const MultipleChoiceQuestion({
    required super.id,
    required super.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
    super.points = 1.0,
  }) : super(type: 'multiple_choice');

  final List<String> options;
  final int correctIndex;
  final String? explanation;

  factory MultipleChoiceQuestion.fromJson(Map<String, dynamic> json) {
    return MultipleChoiceQuestion(
      id: json['id'] as String? ?? json['questionId'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e is Map ? (e['text'] ?? '').toString() : e.toString())
              .toList() ??
          [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'options': options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };
}

/// 2. Concept Association Question
class ConceptAssociationQuestion extends AssessmentQuestion {
  const ConceptAssociationQuestion({
    required super.id,
    required super.prompt,
    required this.leftItems,
    required this.rightItems,
    required this.correctMatches, // leftIndex -> rightIndex
    super.points = 1.0,
  }) : super(type: 'concept_association');

  final List<String> leftItems;
  final List<String> rightItems;
  final Map<int, int> correctMatches;

  factory ConceptAssociationQuestion.fromJson(Map<String, dynamic> json) {
    final matchesMap = <int, int>{};
    if (json['correctMatches'] is Map) {
      (json['correctMatches'] as Map).forEach((k, v) {
        matchesMap[int.parse(k.toString())] = int.parse(v.toString());
      });
    }
    return ConceptAssociationQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      leftItems: (json['leftItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rightItems: (json['rightItems'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctMatches: matchesMap,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'leftItems': leftItems,
        'rightItems': rightItems,
        'correctMatches': correctMatches.map((k, v) => MapEntry(k.toString(), v)),
      };
}

/// 3. Chronological Ordering Question
class ChronologicalOrderingQuestion extends AssessmentQuestion {
  const ChronologicalOrderingQuestion({
    required super.id,
    required super.prompt,
    required this.events,
    required this.correctSequence, // List of original indices in correct chronological order
    super.points = 1.0,
  }) : super(type: 'chronological_ordering');

  final List<String> events;
  final List<int> correctSequence;

  factory ChronologicalOrderingQuestion.fromJson(Map<String, dynamic> json) {
    return ChronologicalOrderingQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      events: (json['events'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctSequence: (json['correctSequence'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'events': events,
        'correctSequence': correctSequence,
      };
}

/// 4. Error Identification Question
class ErrorIdentificationQuestion extends AssessmentQuestion {
  const ErrorIdentificationQuestion({
    required super.id,
    required super.prompt,
    required this.baseText,
    required this.segments,
    required this.errorSegmentIndices,
    this.corrections = const [],
    super.points = 1.0,
  }) : super(type: 'error_identification');

  final String baseText;
  final List<String> segments;
  final List<int> errorSegmentIndices;
  final List<String> corrections;

  factory ErrorIdentificationQuestion.fromJson(Map<String, dynamic> json) {
    return ErrorIdentificationQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      baseText: json['baseText'] as String? ?? '',
      segments: (json['segments'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      errorSegmentIndices: (json['errorSegmentIndices'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      corrections: (json['corrections'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'baseText': baseText,
        'segments': segments,
        'errorSegmentIndices': errorSegmentIndices,
        'corrections': corrections,
      };
}

/// 5. Dataset Interpretation Question
class DatasetInterpretationQuestion extends AssessmentQuestion {
  const DatasetInterpretationQuestion({
    required super.id,
    required super.prompt,
    required this.dataset,
    required this.expectedAnswer,
    this.tolerance = 0.0,
    super.points = 1.0,
  }) : super(type: 'dataset_interpretation');

  final List<Map<String, dynamic>> dataset;
  final dynamic expectedAnswer;
  final double tolerance;

  factory DatasetInterpretationQuestion.fromJson(Map<String, dynamic> json) {
    return DatasetInterpretationQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      dataset: (json['dataset'] as List<dynamic>?)?.map((d) => Map<String, dynamic>.from(d as Map)).toList() ?? [],
      expectedAnswer: json['expectedAnswer'],
      tolerance: (json['tolerance'] as num?)?.toDouble() ?? 0.0,
      points: (json['points'] as num?)?.toDouble() ?? 1.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'dataset': dataset,
        'expectedAnswer': expectedAnswer,
        'tolerance': tolerance,
      };
}

/// 6. Discursive Question with Rubric
class DiscursiveQuestion extends AssessmentQuestion {
  const DiscursiveQuestion({
    required super.id,
    required super.prompt,
    required this.criteriaWeights, // criteriaName -> weight
    this.modelAnswer,
    super.points = 10.0,
  }) : super(type: 'discursive');

  final Map<String, double> criteriaWeights;
  final String? modelAnswer;

  factory DiscursiveQuestion.fromJson(Map<String, dynamic> json) {
    final weights = <String, double>{};
    if (json['criteriaWeights'] is Map) {
      (json['criteriaWeights'] as Map).forEach((k, v) {
        weights[k.toString()] = (v as num).toDouble();
      });
    }
    return DiscursiveQuestion(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      criteriaWeights: weights,
      modelAnswer: json['modelAnswer'] as String?,
      points: (json['points'] as num?)?.toDouble() ?? 10.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'prompt': prompt,
        'type': type,
        'points': points,
        'criteriaWeights': criteriaWeights,
        if (modelAnswer != null) 'modelAnswer': modelAnswer,
      };
}
