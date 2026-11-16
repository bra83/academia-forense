/// Domain categories for practical forensic laboratories (§14.1).
enum LabDomain {
  informatics('Informatica', 'Informática Forense'),
  mathematics('Matematica', 'Matemática e Estatística Forense'),
  programming('Programacao', 'Programação e Análise de Dados Forense'),
  digitalForensics('PericiaDigital', 'Perícia Digital'),
  telephony('Telefonia', 'Telefonia e Registros de Comunicação'),
  linguistics('LinguisticaForense', 'Linguística Forense'),
  multimedia('Multimidia', 'Multimídia Forense (Áudio/Imagem/Vídeo)');

  final String value;
  final String displayName;

  const LabDomain(this.value, this.displayName);

  /// Parse a LabDomain from its serialized or §14.1 string representation.
  static LabDomain fromValue(String value) {
    for (final domain in LabDomain.values) {
      if (domain.value.toLowerCase() == value.toLowerCase() ||
          domain.name.toLowerCase() == value.toLowerCase()) {
        return domain;
      }
    }
    throw ArgumentError('Domínio de laboratório desconhecido: $value');
  }

  /// Safe lookup returning null if not found.
  static LabDomain? tryFromValue(String? value) {
    if (value == null) return null;
    for (final domain in LabDomain.values) {
      if (domain.value.toLowerCase() == value.toLowerCase() ||
          domain.name.toLowerCase() == value.toLowerCase()) {
        return domain;
      }
    }
    return null;
  }
}
