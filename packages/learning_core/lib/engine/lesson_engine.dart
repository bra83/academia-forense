import '../models/didactic_components.dart';

/// The 10 canonical didactic steps (§8, §8.1).
class CanonicalDidacticSteps {
  CanonicalDidacticSteps._();

  static const List<String> steps = [
    '1. Objetivos de aprendizagem',
    '2. Pré-requisitos',
    '3. Apresentação do problema',
    '4. Explicação teórica',
    '5. Exemplo resolvido',
    '6. Exercício guiado',
    '7. Atividade prática',
    '8. Avaliação',
    '9. Revisão dos erros',
    '10. Resumo e referências',
  ];

  static const List<String> shortKeys = [
    'objectives',
    'prerequisites',
    'problem',
    'theory',
    'solved_example',
    'guided_exercise',
    'practical_activity',
    'assessment',
    'error_review',
    'summary_references',
  ];

  static const int totalSteps = 10;
}

/// Represents an individual step within a 10-step didactic lesson.
class DidacticStep {
  DidacticStep({
    required this.index, // 1-indexed (1 to 10)
    required this.title,
    required this.content,
    this.key,
    this.components = const [],
    this.isCompleted = false,
  }) {
    if (index < 1 || index > CanonicalDidacticSteps.totalSteps) {
      throw RangeError.range(index, 1, CanonicalDidacticSteps.totalSteps, 'index', 'Step index must be between 1 and 10');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('Step title cannot be empty');
    }
    if (content.trim().isEmpty) {
      throw ArgumentError('Step content cannot be empty');
    }
  }

  final int index;
  final String title;
  final String content;
  final String? key;
  final List<DidacticComponent> components;
  bool isCompleted;

  Map<String, dynamic> toJson() => {
        'index': index,
        'title': title,
        'content': content,
        if (key != null) 'key': key,
        'isCompleted': isCompleted,
        'components': components.map((c) => c.toJson()).toList(),
      };
}

/// 10-Step Didactic Lesson Engine (§8, §8.1)
class LessonEngine {
  LessonEngine({
    required this.lessonId,
    List<DidacticStep>? initialSteps,
  }) {
    if (initialSteps != null) {
      setSteps(initialSteps);
    } else {
      // Default initialization with 10 canonical steps
      _steps = List.generate(
        CanonicalDidacticSteps.totalSteps,
        (i) => DidacticStep(
          index: i + 1,
          title: CanonicalDidacticSteps.steps[i],
          content: 'Conteúdo da etapa ${CanonicalDidacticSteps.steps[i]}',
          key: CanonicalDidacticSteps.shortKeys[i],
        ),
      );
    }
  }

  final String lessonId;
  late List<DidacticStep> _steps;
  final Set<int> _completedStepIndices = {}; // 0-indexed set of completed step indices
  int _currentStepIndex = 0; // 0-indexed (0 to 9)

  /// Public access to canonical steps list
  static List<String> get DIDACTIC_STEPS => CanonicalDidacticSteps.steps;

  List<DidacticStep> get steps => List.unmodifiable(_steps);

  int get currentStepIndex => _currentStepIndex;

  /// Current 1-indexed step number (1 to 10)
  int get currentStepNumber => _currentStepIndex + 1;

  Set<int> get completedSteps => Set.unmodifiable(_completedStepIndices);

  void setSteps(List<DidacticStep> newSteps) {
    if (newSteps.length != CanonicalDidacticSteps.totalSteps) {
      throw ArgumentError(
        'Lesson didactic sequence must have exactly 10 steps, got ${newSteps.length}',
      );
    }
    // Verify each step has non-empty title and content
    for (int i = 0; i < newSteps.length; i++) {
      if (newSteps[i].title.trim().isEmpty) {
        throw ArgumentError('Step title cannot be empty at index $i');
      }
      if (newSteps[i].content.trim().isEmpty) {
        throw ArgumentError('Step content cannot be empty at index $i');
      }
    }
    _steps = List.from(newSteps);
    _completedStepIndices.clear();
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i].isCompleted) {
        _completedStepIndices.add(i);
      }
    }
  }

  /// Sets current step index (0-indexed: 0..9) with bounds and progression checks.
  set currentStepIndex(int newIndex) {
    if (newIndex < 0 || newIndex >= CanonicalDidacticSteps.totalSteps) {
      throw RangeError.range(
        newIndex,
        0,
        CanonicalDidacticSteps.totalSteps - 1,
        'currentStepIndex',
        'Step index out of bounds [0, 9]',
      );
    }
    // Allow backwards navigation anytime to completed or current steps
    if (newIndex <= _currentStepIndex || _completedStepIndices.contains(newIndex)) {
      _currentStepIndex = newIndex;
      return;
    }

    // Forward navigation: cannot jump ahead past the next uncompleted step
    final maxAllowed = _maxAccessibleIndex();
    if (newIndex > maxAllowed) {
      throw ArgumentError(
        'Cannot jump to step ${newIndex + 1} before completing prerequisite steps up to $maxAllowed',
      );
    }
    _currentStepIndex = newIndex;
  }

  /// Sets current step by 1-indexed number (1..10)
  void navigateToStepNumber(int stepNumber) {
    if (stepNumber < 1 || stepNumber > CanonicalDidacticSteps.totalSteps) {
      throw RangeError.range(
        stepNumber,
        1,
        CanonicalDidacticSteps.totalSteps,
        'stepNumber',
        'Step index $stepNumber out of bounds [1, 10]',
      );
    }
    currentStepIndex = stepNumber - 1;
  }

  int _maxAccessibleIndex() {
    for (int i = 0; i < CanonicalDidacticSteps.totalSteps; i++) {
      if (!_completedStepIndices.contains(i)) {
        return i;
      }
    }
    return CanonicalDidacticSteps.totalSteps - 1;
  }

  /// Completes current step and automatically advances to next step if available.
  void completeCurrentStep() {
    _completedStepIndices.add(_currentStepIndex);
    _steps[_currentStepIndex].isCompleted = true;
    if (_currentStepIndex < CanonicalDidacticSteps.totalSteps - 1) {
      _currentStepIndex++;
    }
  }

  /// Checks if step 8 (Assessment) is unlocked (steps 1..7 completed)
  bool canUnlockAssessment() {
    for (int i = 0; i < 7; i++) {
      if (!_completedStepIndices.contains(i)) {
        return false;
      }
    }
    return true;
  }

  /// Returns progress percentage [0.0, 100.0]
  double get progressPercentage =>
      (_completedStepIndices.length / CanonicalDidacticSteps.totalSteps) * 100.0;

  /// True when all 10 canonical steps have been completed.
  bool get isCompleted =>
      _completedStepIndices.length == CanonicalDidacticSteps.totalSteps;

  DidacticStep get currentStep => _steps[_currentStepIndex];

  DidacticStep getStep(int index1Based) {
    if (index1Based < 1 || index1Based > CanonicalDidacticSteps.totalSteps) {
      throw RangeError.range(
        index1Based,
        1,
        CanonicalDidacticSteps.totalSteps,
        'index1Based',
        'Step index $index1Based out of bounds [1, 10]',
      );
    }
    return _steps[index1Based - 1];
  }
}
