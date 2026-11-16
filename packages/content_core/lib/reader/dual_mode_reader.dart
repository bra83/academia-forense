enum ReaderMode {
  pdfVerbatim,
  markdownStudy;

  String get value => this == ReaderMode.pdfVerbatim ? 'pdf_verbatim' : 'markdown_study';

  static ReaderMode fromString(String mode) {
    if (mode == 'pdf_verbatim') return ReaderMode.pdfVerbatim;
    if (mode == 'markdown_study') return ReaderMode.markdownStudy;
    throw ArgumentError('Unknown reader mode: $mode');
  }
}

class ReaderProvenance {
  final String documentId;
  final int? volume;
  final int? chapter;
  final String? revision;
  final int originalPage;
  final String? sha256;

  const ReaderProvenance({
    required this.documentId,
    this.volume,
    this.chapter,
    this.revision,
    required this.originalPage,
    this.sha256,
  });

  Map<String, dynamic> toMap() => {
        'document_id': documentId,
        'volume': volume,
        'chapter': chapter,
        'revision': revision,
        'original_page': originalPage,
        'sha256': sha256,
      };
}

/// Manages switching between Verbatim PDF View and Reflowable Markdown Study Mode (§7.1, §7.2).
class DualModeReader {
  final String documentId;
  final String pdfPath;
  String markdownContent;
  final Map<String, dynamic> metadata;

  ReaderMode _currentMode = ReaderMode.markdownStudy;
  int _currentPage = 1;
  double _scrollRatio = 0.0;
  final int totalPages;

  DualModeReader({
    required this.documentId,
    required this.pdfPath,
    required this.markdownContent,
    this.metadata = const {},
    this.totalPages = 100,
  });

  String get currentMode => _currentMode.value;

  ReaderMode get mode => _currentMode;

  int get currentPage => _currentPage;

  set currentPage(int page) {
    if (page < 1 || page > totalPages) {
      throw RangeError('Page $page out of range [1, $totalPages]');
    }
    _currentPage = page;
  }

  double get scrollRatio => _scrollRatio;

  set scrollRatio(double ratio) {
    // Clamping scroll ratio to [0.0, 1.0]
    _scrollRatio = ratio.clamp(0.0, 1.0);
  }

  /// Switches reader mode while preserving reading position.
  void switchMode(String modeString) {
    _currentMode = ReaderMode.fromString(modeString);
  }

  /// Returns origin provenance tracking metadata (§7.2).
  ReaderProvenance getOriginProvenance() {
    return ReaderProvenance(
      documentId: documentId,
      volume: metadata['volume'] as int?,
      chapter: metadata['chapter'] as int?,
      revision: metadata['revision'] as String?,
      originalPage: _currentPage,
      sha256: metadata['sha256'] as String?,
    );
  }

  /// Determines if section has complex diagrams requiring PDF verbatim view.
  static String recommendedModeForContent({
    required bool hasComplexDiagram,
    required bool transcriptionComplete,
  }) {
    if (hasComplexDiagram || !transcriptionComplete) {
      return 'pdf_verbatim';
    }
    return 'markdown_study';
  }
}
