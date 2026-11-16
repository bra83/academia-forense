import '../models/case_ontology.dart';

/// Validation report for investigative case study methodology (§15.2).
class CaseMethodologyValidationResult {
  final bool isValidMethodology;
  final int factsCount;
  final int inferencesCount;
  final int hypothesesCount;
  final List<String> unlinkedInferences;
  final List<String> validationErrors;
  final List<CaseEntry> competingHypotheses;

  const CaseMethodologyValidationResult({
    required this.isValidMethodology,
    required this.factsCount,
    required this.inferencesCount,
    required this.hypothesesCount,
    required this.unlinkedInferences,
    required this.validationErrors,
    required this.competingHypotheses,
  });

  Map<String, dynamic> toMap() => {
    'valid_methodology': isValidMethodology,
    'facts_count': factsCount,
    'inferences_count': inferencesCount,
    'hypotheses_count': hypothesesCount,
    'unlinked_inferences': unlinkedInferences,
    'errors': validationErrors,
  };
}

/// Evaluates forensic methodology rigor according to §15.2:
/// 1. Strict separation of facts vs inferences vs hypotheses.
/// 2. Facts count must be >= 1.
/// 3. Inferences without fact grounding are strictly forbidden.
/// 4. Competing alternative hypotheses must be preserved without premature exclusion.
class CaseMethodologyValidator {
  static CaseMethodologyValidationResult validateEntries(List<CaseEntry> entries) {
    final facts = entries.where((e) => e.category == CaseOntologyCategory.documentedFact).toList();
    final inferences = entries.where((e) => e.category == CaseOntologyCategory.investigativeInference).toList();
    final hypotheses = entries.where((e) => e.category == CaseOntologyCategory.alternativeHypothesis).toList();

    final factIds = facts.map((f) => f.id).toSet();
    final unlinkedInferences = <String>[];
    final errors = <String>[];

    if (facts.isEmpty) {
      errors.add('Submissão metodologicamente inválida: Nenhum fato documentado foi registrado.');
    }

    for (final inf in inferences) {
      final hasValidFactLink = inf.linkedFactIds.any((fid) => factIds.contains(fid));
      if (!hasValidFactLink) {
        unlinkedInferences.add(inf.id);
        errors.add(
          'Inferência não fundamentada [${inf.id}]: "${inf.description}". '
          'Toda inferência deve estar vinculada a pelo menos um fato documentado comprovado (§15.2).',
        );
      }
    }

    final isValid = facts.isNotEmpty && unlinkedInferences.isEmpty;

    return CaseMethodologyValidationResult(
      isValidMethodology: isValid,
      factsCount: facts.length,
      inferencesCount: inferences.length,
      hypothesesCount: hypotheses.length,
      unlinkedInferences: unlinkedInferences,
      validationErrors: errors,
      competingHypotheses: hypotheses,
    );
  }
}
