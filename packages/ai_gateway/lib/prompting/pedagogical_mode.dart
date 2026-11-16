/// The 7 official pedagogical tutor modes (§9.3).
enum PedagogicalMode {
  explicar('explicar'),
  simplificar('simplificar'),
  aprofundar('aprofundar'),
  exemplificar('exemplificar'),
  meTestar('meTestar'),
  revisar('revisar'),
  orientarLab('orientarLab');

  const PedagogicalMode(this.value);

  final String value;

  static const List<String> validModeStrings = [
    'explicar',
    'simplificar',
    'aprofundar',
    'exemplificar',
    'meTestar',
    'revisar',
    'orientarLab',
  ];

  static PedagogicalMode fromString(String mode) {
    for (final m in PedagogicalMode.values) {
      if (m.value == mode) return m;
    }
    throw ArgumentError(
      "Invalid tutor mode '$mode'. Must be one of {explicar, simplificar, aprofundar, exemplificar, meTestar, revisar, orientarLab}",
    );
  }
}
