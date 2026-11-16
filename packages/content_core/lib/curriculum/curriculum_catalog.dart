class VolumeInfo {
  final int volumeId;
  final String roman;
  final String title;
  final int chapterStart;
  final int chapterEnd;
  final int chapterCount;
  final int printedPages;
  final String area;

  const VolumeInfo({
    required this.volumeId,
    required this.roman,
    required this.title,
    required this.chapterStart,
    required this.chapterEnd,
    required this.chapterCount,
    this.printedPages = 0,
    required this.area,
  });
}

class ChapterSummary {
  final int chapterNumber;
  final String contentId;
  final String title;
  final int volumeId;
  final String expectedRevision;
  final String editorialStatus;

  const ChapterSummary({
    required this.chapterNumber,
    required this.contentId,
    required this.title,
    required this.volumeId,
    required this.expectedRevision,
    required this.editorialStatus,
  });
}

/// Canonical curriculum catalog covering all 9 volumes and 113 chapters (§3, §24.3).
class CurriculumCatalog {
  static const List<String> editorialStates = [
    'Planejado',
    'Importado',
    'Em revisão',
    'Aprovado',
    'Publicado',
    'Substituído',
    'Arquivado',
  ];

  static const List<VolumeInfo> volumes = [
    VolumeInfo(
      volumeId: 1,
      roman: 'Volume I',
      title: 'Fundamentos das Ciências Forenses',
      chapterStart: 1,
      chapterEnd: 10,
      chapterCount: 10,
      printedPages: 133,
      area: 'Fundamentos',
    ),
    VolumeInfo(
      volumeId: 2,
      roman: 'Volume II',
      title: 'Computação, Python, SQL e Matemática',
      chapterStart: 11,
      chapterEnd: 23,
      chapterCount: 13,
      area: 'Computação e Métodos Quantitativos',
    ),
    VolumeInfo(
      volumeId: 3,
      roman: 'Volume III',
      title: 'Estatística e Ciência de Dados Forense',
      chapterStart: 24,
      chapterEnd: 39,
      chapterCount: 16,
      area: 'Estatística e Ciência de Dados',
    ),
    VolumeInfo(
      volumeId: 4,
      roman: 'Volume IV',
      title: 'Perícia Digital',
      chapterStart: 40,
      chapterEnd: 53,
      chapterCount: 14,
      area: 'Perícia Digital e Resposta a Incidentes',
    ),
    VolumeInfo(
      volumeId: 5,
      roman: 'Volume V',
      title: 'Telefonia, Geolocalização e Cronologias',
      chapterStart: 54,
      chapterEnd: 66,
      chapterCount: 13,
      area: 'Telefonia e Geolocalização',
    ),
    VolumeInfo(
      volumeId: 6,
      roman: 'Volume VI',
      title: 'Linguística Forense e NLP',
      chapterStart: 67,
      chapterEnd: 78,
      chapterCount: 12,
      area: 'Linguística Forense',
    ),
    VolumeInfo(
      volumeId: 7,
      roman: 'Volume VII',
      title: 'Documentoscopia e Multimídia',
      chapterStart: 79,
      chapterEnd: 90,
      chapterCount: 12,
      area: 'Documentoscopia e Multimídia',
    ),
    VolumeInfo(
      volumeId: 8,
      roman: 'Volume VIII',
      title: 'Áreas Forenses Complementares',
      chapterStart: 91,
      chapterEnd: 100,
      chapterCount: 10,
      area: 'Áreas Complementares',
    ),
    VolumeInfo(
      volumeId: 9,
      roman: 'Volume IX',
      title: 'Pesquisa e Exercício Profissional',
      chapterStart: 101,
      chapterEnd: 113,
      chapterCount: 13,
      area: 'Pesquisa e Prática Profissional',
    ),
  ];

  static const Map<String, List<String>> _validTransitions = {
    'Planejado': ['Importado'],
    'Importado': ['Em revisão'],
    'Em revisão': ['Aprovado', 'Planejado'],
    'Aprovado': ['Publicado', 'Em revisão'],
    'Publicado': ['Substituído', 'Arquivado'],
    'Substituído': ['Arquivado'],
    'Arquivado': [],
  };

  /// Returns the volume ID (1-9) for a given chapter number (1-113).
  static int getVolumeForChapter(int chapterNumber) {
    if (chapterNumber < 1 || chapterNumber > 113) {
      throw ArgumentError('Chapter $chapterNumber outside valid range 1-113');
    }
    for (final vol in volumes) {
      if (chapterNumber >= vol.chapterStart && chapterNumber <= vol.chapterEnd) {
        return vol.volumeId;
      }
    }
    throw ArgumentError('Volume not found for chapter $chapterNumber');
  }

  /// Returns metadata for a volume.
  static VolumeInfo getVolumeInfo(int volumeId) {
    return volumes.firstWhere(
      (v) => v.volumeId == volumeId,
      orElse: () => throw ArgumentError('Volume $volumeId does not exist'),
    );
  }

  /// Rule §3: Only Aprovado or Publicado chapters are available for study.
  static bool isPubliclyAvailable(String state) {
    final s = state.trim().toLowerCase();
    return s == 'aprovado' ||
        s == 'publicado' ||
        s == 'approved' ||
        s == 'published';
  }

  /// Validates whether a lifecycle transition is allowed.
  static bool canTransition(String fromState, String toState) {
    final allowed = _validTransitions[fromState];
    if (allowed == null) return false;
    return allowed.contains(toState);
  }
}
