class ValidationReport {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationReport({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationReport.success([List<String> warnings = const []]) {
    return ValidationReport(isValid: true, warnings: warnings);
  }

  factory ValidationReport.failure(List<String> errors, [List<String> warnings = const []]) {
    return ValidationReport(isValid: false, errors: errors, warnings: warnings);
  }

  @override
  String toString() {
    if (isValid) {
      return 'ValidationReport: VALID (warnings: ${warnings.length})';
    }
    return 'ValidationReport: INVALID (${errors.length} errors):\n  ${errors.join('\n  ')}';
  }
}
