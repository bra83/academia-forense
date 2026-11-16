/// Rubric condition type for step verification.
enum RubricCriterionType {
  exactMatch,
  containsText,
  regexPattern,
  numericRange,
  customCheck,
}

/// A single evaluation criterion in a lab rubric.
class RubricCriterion {
  final String id;
  final String description;
  final RubricCriterionType type;
  final dynamic targetValue;
  final double weight;

  const RubricCriterion({
    required this.id,
    required this.description,
    required this.type,
    required this.targetValue,
    this.weight = 1.0,
  });

  bool evaluate(dynamic actualValue) {
    if (actualValue == null) return false;
    switch (type) {
      case RubricCriterionType.exactMatch:
        return actualValue.toString().trim() == targetValue.toString().trim();
      case RubricCriterionType.containsText:
        return actualValue.toString().toLowerCase().contains(targetValue.toString().toLowerCase());
      case RubricCriterionType.regexPattern:
        final reg = RegExp(targetValue.toString());
        return reg.hasMatch(actualValue.toString());
      case RubricCriterionType.numericRange:
        final numVal = actualValue is num ? actualValue.toDouble() : double.tryParse(actualValue.toString());
        if (numVal == null) return false;
        if (targetValue is List && targetValue.length >= 2) {
          final min = (targetValue[0] as num).toDouble();
          final max = (targetValue[1] as num).toDouble();
          return numVal >= min && numVal <= max;
        }
        return false;
      case RubricCriterionType.customCheck:
        return actualValue == true;
    }
  }
}

/// Result of evaluating a lab step against its rubric.
class LabStepValidationResult {
  final bool isValid;
  final double scorePercent;
  final List<String> passedCriteria;
  final List<String> failedCriteria;
  final String feedback;

  const LabStepValidationResult({
    required this.isValid,
    required this.scorePercent,
    required this.passedCriteria,
    required this.failedCriteria,
    required this.feedback,
  });
}

/// Validator for lab step outputs and rubric compliance.
class LabStepValidator {
  static LabStepValidationResult validateStep({
    required List<RubricCriterion> criteria,
    required Map<String, dynamic> actualOutputs,
  }) {
    if (criteria.isEmpty) {
      return const LabStepValidationResult(
        isValid: true,
        scorePercent: 100.0,
        passedCriteria: [],
        failedCriteria: [],
        feedback: 'Passo validado sem critérios adicionais restritivos.',
      );
    }

    var totalWeight = 0.0;
    var achievedWeight = 0.0;
    final passed = <String>[];
    final failed = <String>[];

    for (final crit in criteria) {
      totalWeight += crit.weight;
      final actualVal = actualOutputs[crit.id];
      final isMatch = crit.evaluate(actualVal);
      if (isMatch) {
        achievedWeight += crit.weight;
        passed.add(crit.description);
      } else {
        failed.add('${crit.description} (Valor obtido: $actualVal)');
      }
    }

    final scorePercent = totalWeight > 0 ? (achievedWeight / totalWeight) * 100.0 : 0.0;
    final isValid = scorePercent >= 80.0; // Standard 80% passing benchmark

    final feedback = isValid
        ? 'Etapa concluída com sucesso (${scorePercent.toStringAsFixed(1)}%).'
        : 'Etapa não atingiu o índice mínimo de 80% (${scorePercent.toStringAsFixed(1)}%). Pendências: ${failed.join("; ")}';

    return LabStepValidationResult(
      isValid: isValid,
      scorePercent: scorePercent,
      passedCriteria: passed,
      failedCriteria: failed,
      feedback: feedback,
    );
  }
}
