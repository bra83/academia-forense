import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:persistence_core/persistence_core.dart';
import 'lab_step_validator.dart';

/// Comprehensive report of a laboratory execution run.
class LabExecutionReport {
  final String runId;
  final String laboratoryId;
  final DateTime executedAt;
  final bool isPassed;
  final double scorePercent;
  final List<String> commandsExecuted;
  final String? outputArtifactPath;
  final Map<String, dynamic> metrics;
  final LabStepValidationResult validationResult;

  const LabExecutionReport({
    required this.runId,
    required this.laboratoryId,
    required this.executedAt,
    required this.isPassed,
    required this.scorePercent,
    required this.commandsExecuted,
    this.outputArtifactPath,
    required this.metrics,
    required this.validationResult,
  });

  Map<String, dynamic> toMap() => {
    'runId': runId,
    'laboratoryId': laboratoryId,
    'executedAt': executedAt.toIso8601String(),
    'isPassed': isPassed,
    'scorePercent': scorePercent,
    'commandsExecuted': commandsExecuted,
    'outputArtifactPath': outputArtifactPath,
    'metrics': metrics,
    'feedback': validationResult.feedback,
  };
}

/// Orchestrates laboratory execution, rubric validation, and persistence logging.
class LabExecutionEngine {
  final LaboratoryDao? laboratoryDao;

  const LabExecutionEngine({this.laboratoryDao});

  /// Executes validation and records execution run into the persistence database.
  Future<LabExecutionReport> executeAndRecord({
    required String laboratoryId,
    required List<String> commandsExecuted,
    required Map<String, dynamic> actualOutputs,
    required List<RubricCriterion> criteria,
    String? outputArtifactPath,
    Map<String, dynamic>? additionalMetrics,
  }) async {
    final stopwatch = Stopwatch()..start();
    final executedAt = DateTime.now().toUtc();
    final runId = 'run_${laboratoryId}_${executedAt.millisecondsSinceEpoch}';

    final validationResult = LabStepValidator.validateStep(
      criteria: criteria,
      actualOutputs: actualOutputs,
    );

    stopwatch.stop();

    final metrics = <String, dynamic>{
      'executionTimeMs': stopwatch.elapsedMilliseconds,
      'scorePercent': validationResult.scorePercent,
      'passedCount': validationResult.passedCriteria.length,
      'failedCount': validationResult.failedCriteria.length,
      if (additionalMetrics != null) ...additionalMetrics,
    };

    final report = LabExecutionReport(
      runId: runId,
      laboratoryId: laboratoryId,
      executedAt: executedAt,
      isPassed: validationResult.isValid,
      scorePercent: validationResult.scorePercent,
      commandsExecuted: commandsExecuted,
      outputArtifactPath: outputArtifactPath,
      metrics: metrics,
      validationResult: validationResult,
    );

    if (laboratoryDao != null) {
      await laboratoryDao!.recordLaboratoryRun(
        LaboratoryRunsCompanion.insert(
          id: runId,
          laboratoryId: laboratoryId,
          executedAt: Value(executedAt),
          commandsExecutedJson: jsonEncode(commandsExecuted),
          outputArtifactPath: Value(outputArtifactPath),
          isPassed: validationResult.isValid,
          metricsJson: Value(jsonEncode(metrics)),
        ),
      );
    }

    return report;
  }
}
