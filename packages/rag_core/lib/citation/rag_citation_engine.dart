/// Exception raised when citation targets an invalid volume or chapter.
class CitationLookupError implements Exception {
  CitationLookupError(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Parsed citations report from tutor response (§9.2).
class CitationParseResult {
  const CitationParseResult({
    required this.hasFonte,
    required this.hasInferencia,
    required this.fontes,
    this.hasComplementar = false,
    this.hasHipotetico = false,
  });

  final bool hasFonte;
  final bool hasInferencia;
  final List<String> fontes;
  final bool hasComplementar;
  final bool hasHipotetico;

  bool get isGrounded => hasFonte;
}

/// Engine for validating academic provenance and citation tags (§9.2, §18.3).
class RagCitationEngine {
  RagCitationEngine._();

  static final RegExp _fonteRegex = RegExp(r'\[FONTE:\s*([^\]]+)\]', caseSensitive: false);

  /// Parses citation tags from tutor response.
  static CitationParseResult parseResponseCitations(String tutorResponse) {
    final hasFonte = tutorResponse.contains('[FONTE');
    final hasInferencia = tutorResponse.contains('[INFERÊNCIA');
    final hasComplementar = tutorResponse.contains('[CONHECIMENTO COMPLEMENTAR');
    final hasHipotetico = tutorResponse.contains('[EXERCÍCIO HIPOTÉTICO');

    final matches = _fonteRegex.allMatches(tutorResponse);
    final fontes = matches.map((m) => m.group(1)!.trim()).toList();

    return CitationParseResult(
      hasFonte: hasFonte,
      hasInferencia: hasInferencia,
      fontes: fontes,
      hasComplementar: hasComplementar,
      hasHipotetico: hasHipotetico,
    );
  }

  /// Strictly validates that tutor response contains [FONTE] or [INFERÊNCIA] tags.
  /// Throws ArgumentError if response makes untagged claims (§9.2).
  static void validateResponseTags(String response) {
    final hasFonte = response.contains('[FONTE');
    final hasInferencia = response.contains('[INFERÊNCIA');

    if (!hasFonte && !hasInferencia) {
      throw ArgumentError(
        'Tutor response must explicitly contain [FONTE] or [INFERÊNCIA] tag (§9.2)',
      );
    }
  }

  /// Verifies volume (1-9) and chapter (1-113) citation boundaries.
  static void verifyCitationBounds({required int volume, required int chapter}) {
    if (volume < 1 || volume > 9) {
      throw CitationLookupError(
        'Invalid citation: Volume $volume does not exist in curriculum (1-9)',
      );
    }
    if (chapter < 1 || chapter > 113) {
      throw CitationLookupError(
        'Invalid citation: Chapter $chapter does not exist in curriculum (1-113)',
      );
    }
  }

  /// Validates page bounds against chapter total pages count.
  static void validateCitationPage({
    required int page,
    required int chapterTotalPages,
  }) {
    if (page < 1 || page > chapterTotalPages) {
      throw ArgumentError(
        'Citation page $page out of bounds [1, $chapterTotalPages]',
      );
    }
  }
}
