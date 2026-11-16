import 'dart:math' as math;

/// Descriptive statistics results bundle.
class DescriptiveStatistics {
  final int count;
  final double mean;
  final double variance;
  final double standardDeviation;
  final double min;
  final double max;
  final double median;

  const DescriptiveStatistics({
    required this.count,
    required this.mean,
    required this.variance,
    required this.standardDeviation,
    required this.min,
    required this.max,
    required this.median,
  });

  Map<String, dynamic> toMap() => {
    'count': count,
    'mean': mean,
    'variance': variance,
    'standardDeviation': standardDeviation,
    'min': min,
    'max': max,
    'median': median,
  };
}

/// Bayesian probability analysis result.
class BayesianProbabilityResult {
  final double prior;
  final double sensitivity;
  final double specificity;
  final double probabilityEvidence;
  final double posterior;

  const BayesianProbabilityResult({
    required this.prior,
    required this.sensitivity,
    required this.specificity,
    required this.probabilityEvidence,
    required this.posterior,
  });

  Map<String, dynamic> toMap() => {
    'prior': prior,
    'sensitivity': sensitivity,
    'specificity': specificity,
    'p_evidence': probabilityEvidence,
    'posterior': posterior,
  };
}

/// Executor for Matemática e Estatística Forense practical tasks (§14.1).
class MathematicsExecutor {
  /// Basic arithmetic evaluation.
  static double calculate(double a, String op, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) throw ArgumentError('Divisão por zero não é permitida.');
        return a / b;
      case '^':
        return math.pow(a, b).toDouble();
      default:
        throw ArgumentError('Operador não suportado: $op');
    }
  }

  /// Calculates descriptive statistics (mean, sample variance, standard deviation, median, min, max).
  static DescriptiveStatistics calculateDescriptiveStatistics(List<double> values) {
    if (values.isEmpty) {
      throw ArgumentError('A lista de valores não pode estar vazia.');
    }

    final n = values.length;
    final sorted = List<double>.from(values)..sort();
    final min = sorted.first;
    final max = sorted.last;

    final sum = values.reduce((a, b) => a + b);
    final mean = sum / n;

    double variance = 0.0;
    if (n > 1) {
      final sumSquaredDiffs = values.fold<double>(
        0.0,
        (acc, val) => acc + math.pow(val - mean, 2),
      );
      variance = sumSquaredDiffs / (n - 1);
    }
    final standardDeviation = math.sqrt(variance);

    final double median;
    if (n % 2 == 1) {
      median = sorted[n ~/ 2];
    } else {
      median = (sorted[(n ~/ 2) - 1] + sorted[n ~/ 2]) / 2.0;
    }

    return DescriptiveStatistics(
      count: n,
      mean: mean,
      variance: variance,
      standardDeviation: standardDeviation,
      min: min,
      max: max,
      median: median,
    );
  }

  /// Calculates Bayesian probability:
  /// P(H|E) = (sensitivity * prior) / ((sensitivity * prior) + ((1 - specificity) * (1 - prior)))
  static BayesianProbabilityResult computeBayesianProbability({
    required double prior,
    required double sensitivity,
    required double specificity,
  }) {
    if (prior < 0.0 || prior > 1.0) {
      throw ArgumentError('Prior deve estar no intervalo [0, 1].');
    }
    if (sensitivity < 0.0 || sensitivity > 1.0) {
      throw ArgumentError('Sensibilidade deve estar no intervalo [0, 1].');
    }
    if (specificity < 0.0 || specificity > 1.0) {
      throw ArgumentError('Especificidade deve estar no intervalo [0, 1].');
    }

    final pEvidence = (sensitivity * prior) + ((1.0 - specificity) * (1.0 - prior));
    if (pEvidence == 0.0) {
      return BayesianProbabilityResult(
        prior: prior,
        sensitivity: sensitivity,
        specificity: specificity,
        probabilityEvidence: 0.0,
        posterior: 0.0,
      );
    }

    final posterior = (sensitivity * prior) / pEvidence;

    return BayesianProbabilityResult(
      prior: prior,
      sensitivity: sensitivity,
      specificity: specificity,
      probabilityEvidence: pEvidence,
      posterior: posterior,
    );
  }
}
