import 'package:meta/meta.dart';

/// Base abstract class for all structured didactic components (§8.1).
@immutable
abstract class DidacticComponent {
  const DidacticComponent({required this.type});

  final String type;

  Map<String, dynamic> toJson();
}

/// 1. AcademicText: Standard expository didactic prose.
class AcademicText extends DidacticComponent {
  const AcademicText({
    required this.content,
    this.sectionId,
  }) : super(type: 'academic_text');

  final String content;
  final String? sectionId;

  factory AcademicText.fromJson(Map<String, dynamic> json) {
    return AcademicText(
      content: json['content'] as String? ?? '',
      sectionId: json['sectionId'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'content': content,
        if (sectionId != null) 'sectionId': sectionId,
      };
}

/// 2. CalloutBox: Highlighted notes, forensic warnings, and technical tips.
enum CalloutVariant { info, warning, attention, tip }

class CalloutBox extends DidacticComponent {
  const CalloutBox({
    required this.title,
    required this.content,
    this.variant = CalloutVariant.attention,
  }) : super(type: 'callout_box');

  final String title;
  final String content;
  final CalloutVariant variant;

  factory CalloutBox.fromJson(Map<String, dynamic> json) {
    final variantStr = json['variant'] as String? ?? 'attention';
    final parsedVariant = CalloutVariant.values.firstWhere(
      (v) => v.name == variantStr,
      orElse: () => CalloutVariant.attention,
    );
    return CalloutBox(
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      variant: parsedVariant,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'content': content,
        'variant': variant.name,
      };
}

/// 3. InteractiveTable: Tabular data with headers, rows, and optional caption.
class InteractiveTable extends DidacticComponent {
  const InteractiveTable({
    required this.headers,
    required this.rows,
    this.caption,
  }) : super(type: 'interactive_table');

  final List<String> headers;
  final List<List<dynamic>> rows;
  final String? caption;

  factory InteractiveTable.fromJson(Map<String, dynamic> json) {
    return InteractiveTable(
      headers: (json['headers'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rows: (json['rows'] as List<dynamic>?)
              ?.map((r) => r is List ? r : [r])
              .toList() ??
          [],
      caption: json['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'headers': headers,
        'rows': rows,
        if (caption != null) 'caption': caption,
      };
}

/// 4. Formula: Mathematical and forensic equations in LaTeX format.
class Formula extends DidacticComponent {
  const Formula({
    required this.latex,
    this.description,
  }) : super(type: 'formula');

  final String latex;
  final String? description;

  factory Formula.fromJson(Map<String, dynamic> json) {
    return Formula(
      latex: json['latex'] as String? ?? '',
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'latex': latex,
        if (description != null) 'description': description,
      };
}

/// 5. CodeSnippet: Syntax-highlighted forensic code / scripts.
class CodeSnippet extends DidacticComponent {
  const CodeSnippet({
    required this.code,
    required this.language,
    this.description,
  }) : super(type: 'code_snippet');

  final String code;
  final String language;
  final String? description;

  factory CodeSnippet.fromJson(Map<String, dynamic> json) {
    return CodeSnippet(
      code: json['code'] as String? ?? '',
      language: json['language'] as String? ?? 'python',
      description: json['description'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'code': code,
        'language': language,
        if (description != null) 'description': description,
      };
}

/// 6. ObjectiveQuestion: Multiple-choice question with single correct answer.
class ObjectiveQuestion extends DidacticComponent {
  const ObjectiveQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    this.explanation,
  }) : super(type: 'objective_question');

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  factory ObjectiveQuestion.fromJson(Map<String, dynamic> json) {
    return ObjectiveQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        if (explanation != null) 'explanation': explanation,
      };
}

/// 7. ConceptAssociation: Associative matching between terms and definitions.
class ConceptPair {
  const ConceptPair({required this.left, required this.right});

  final String left;
  final String right;

  Map<String, dynamic> toJson() => {'left': left, 'right': right};

  factory ConceptPair.fromJson(Map<String, dynamic> json) {
    return ConceptPair(
      left: json['left'] as String? ?? '',
      right: json['right'] as String? ?? '',
    );
  }
}

class ConceptAssociation extends DidacticComponent {
  const ConceptAssociation({
    required this.id,
    required this.instruction,
    required this.pairs,
  }) : super(type: 'concept_association');

  final String id;
  final String instruction;
  final List<ConceptPair> pairs;

  factory ConceptAssociation.fromJson(Map<String, dynamic> json) {
    return ConceptAssociation(
      id: json['id'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      pairs: (json['pairs'] as List<dynamic>?)
              ?.map((p) => ConceptPair.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'instruction': instruction,
        'pairs': pairs.map((p) => p.toJson()).toList(),
      };
}

/// 8. EventOrdering: Chronological ordering of forensic custody / event stages.
class EventOrdering extends DidacticComponent {
  const EventOrdering({
    required this.id,
    required this.instruction,
    required this.events,
    required this.correctOrder,
  }) : super(type: 'event_ordering');

  final String id;
  final String instruction;
  final List<String> events;
  final List<int> correctOrder;

  factory EventOrdering.fromJson(Map<String, dynamic> json) {
    return EventOrdering(
      id: json['id'] as String? ?? '',
      instruction: json['instruction'] as String? ?? '',
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOrder: (json['correctOrder'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'instruction': instruction,
        'events': events,
        'correctOrder': correctOrder,
      };
}

/// 9. ErrorIdentification: Identification of forensic flaws/errors in a passage.
class ErrorIdentification extends DidacticComponent {
  const ErrorIdentification({
    required this.id,
    required this.textWithErrors,
    required this.errorIndices,
    required this.corrections,
  }) : super(type: 'error_identification');

  final String id;
  final String textWithErrors;
  final List<int> errorIndices;
  final List<String> corrections;

  factory ErrorIdentification.fromJson(Map<String, dynamic> json) {
    return ErrorIdentification(
      id: json['id'] as String? ?? '',
      textWithErrors: json['textWithErrors'] as String? ?? '',
      errorIndices: (json['errorIndices'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      corrections: (json['corrections'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'textWithErrors': textWithErrors,
        'errorIndices': errorIndices,
        'corrections': corrections,
      };
}

/// 10. DatasetInterpretation: Interpretation of forensic telemetry / datasets.
class DatasetInterpretation extends DidacticComponent {
  const DatasetInterpretation({
    required this.id,
    required this.prompt,
    required this.dataset,
    required this.columns,
    required this.questions,
  }) : super(type: 'dataset_interpretation');

  final String id;
  final String prompt;
  final List<Map<String, dynamic>> dataset;
  final List<String> columns;
  final List<ObjectiveQuestion> questions;

  factory DatasetInterpretation.fromJson(Map<String, dynamic> json) {
    return DatasetInterpretation(
      id: json['id'] as String? ?? '',
      prompt: json['prompt'] as String? ?? '',
      dataset: (json['dataset'] as List<dynamic>?)
              ?.map((d) => Map<String, dynamic>.from(d as Map))
              .toList() ??
          [],
      columns: (json['columns'] as List<dynamic>?)
              ?.map((c) => c.toString())
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => ObjectiveQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'prompt': prompt,
        'dataset': dataset,
        'columns': columns,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}
