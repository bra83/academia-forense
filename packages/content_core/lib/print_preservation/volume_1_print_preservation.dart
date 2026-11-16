import 'dart:convert';
import '../models/errata_entry.dart';

/// Manages the 133 printed pages baseline for Volume I (Ch 1-4 REV2, Ch 5-10 REV1) and errata (§1.3, §24.2).
class Volume1PrintPreservation {
  static const int totalPrintedPages = 133;

  final List<ErrataEntry> _errataStore = [];

  List<ErrataEntry> get allErrata => List.unmodifiable(_errataStore);

  /// Returns canonical revision code for a Volume I chapter:
  /// - Chapters 1 to 4: REV2
  /// - Chapters 5 to 10: REV1
  static String getCanonicalRevision(int chapterNumber) {
    if (chapterNumber >= 1 && chapterNumber <= 4) {
      return 'REV2';
    } else if (chapterNumber >= 5 && chapterNumber <= 10) {
      return 'REV1';
    }
    throw ArgumentError('Chapter $chapterNumber is not in Volume I (1..10)');
  }

  /// Validates whether a chapter matches its canonical revision.
  static bool validateChapterRevision(int chapterNumber, String revision) {
    final expected = getCanonicalRevision(chapterNumber);
    return revision.toUpperCase() == expected.toUpperCase();
  }

  /// Adds a digital errata entry referencing a physical page of the 133 printed pages.
  void addErrata(ErrataEntry errata) {
    if (errata.volumeId != 1) {
      throw ArgumentError('Errata must target Volume 1 (got ${errata.volumeId})');
    }
    if (errata.printedPageNumber < 1 || errata.printedPageNumber > totalPrintedPages) {
      throw RangeError(
        'Errata page ${errata.printedPageNumber} outside Volume 1 bounds [1, $totalPrintedPages]',
      );
    }
    _errataStore.add(errata);
  }

  /// Loads errata entries from JSON string.
  void loadErrataFromJson(String jsonString) {
    final decoded = json.decode(jsonString);
    if (decoded is List) {
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          addErrata(ErrataEntry.fromJson(item));
        }
      }
    }
  }

  /// Queries errata entries for a specific chapter and physical page number.
  List<ErrataEntry> getErrataForChapterAndPage(int chapterNumber, int pageNumber) {
    return _errataStore
        .where((e) => e.chapterNumber == chapterNumber && e.printedPageNumber == pageNumber)
        .toList();
  }

  /// Queries all errata entries for a specific chapter.
  List<ErrataEntry> getErrataForChapter(int chapterNumber) {
    return _errataStore.where((e) => e.chapterNumber == chapterNumber).toList();
  }
}
