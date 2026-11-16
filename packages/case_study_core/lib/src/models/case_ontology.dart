/// Tripartite forensic ontology category (§15.2).
enum CaseOntologyCategory {
  documentedFact('FATO_DOCUMENTADO', 'Fato Documentado'),
  investigativeInference('INFERENCIA', 'Inferência Investigativa'),
  alternativeHypothesis('HIPOTESE_ALTERNATIVA', 'Hipótese Alternativa');

  final String value;
  final String label;

  const CaseOntologyCategory(this.value, this.label);

  static CaseOntologyCategory fromValue(String val) {
    final clean = val.trim().toUpperCase();
    for (final cat in CaseOntologyCategory.values) {
      if (cat.value == clean || cat.name.toUpperCase() == clean) {
        return cat;
      }
    }
    throw ArgumentError('Categoria ontológica desconhecida: $val');
  }

  static CaseOntologyCategory? tryFromValue(String? val) {
    if (val == null) return null;
    final clean = val.trim().toUpperCase();
    for (final cat in CaseOntologyCategory.values) {
      if (cat.value == clean || cat.name.toUpperCase() == clean) {
        return cat;
      }
    }
    return null;
  }
}

/// Nature of case study (§15.3).
enum CaseNature {
  documentedCase('documentedCase', 'Caso Documentado Real'),
  syntheticCase('syntheticCase', 'Caso Sintético Controlado'),
  hypotheticalExercise('hypotheticalExercise', 'Exercício Hipotético Didático');

  final String value;
  final String label;

  const CaseNature(this.value, this.label);

  static CaseNature fromValue(String val) {
    for (final nature in CaseNature.values) {
      if (nature.value.toLowerCase() == val.toLowerCase() ||
          nature.name.toLowerCase() == val.toLowerCase()) {
        return nature;
      }
    }
    throw ArgumentError('Natureza de caso desconhecida: $val');
  }
}

/// Single ontological entry within an investigative case study (§15.2).
class CaseEntry {
  final String id;
  final CaseOntologyCategory category;
  final String description;
  final List<String> linkedFactIds;
  final DateTime? timestamp;

  const CaseEntry({
    required this.id,
    required this.category,
    required this.description,
    this.linkedFactIds = const [],
    this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category.value,
    'description': description,
    'linked_facts': linkedFactIds,
    'timestamp': timestamp?.toIso8601String(),
  };

  factory CaseEntry.fromMap(Map<String, dynamic> map) {
    return CaseEntry(
      id: map['id'] as String,
      category: CaseOntologyCategory.fromValue(map['category'] as String),
      description: map['description'] as String,
      linkedFactIds: (map['linked_facts'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      timestamp: map['timestamp'] != null ? DateTime.tryParse(map['timestamp'] as String) : null,
    );
  }
}
