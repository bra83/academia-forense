import 'dart:convert';
import 'package:flutter/services.dart';

/// Bundled excerpts from the source ZIP. They are not full PDF transcriptions,
/// and their editorial accuracy has not been independently certified.
class StudySection {
  const StudySection({required this.title, required this.text});
  final String title;
  final String text;
}

class StudyChapter {
  const StudyChapter({
    required this.id,
    required this.volume,
    required this.number,
    required this.title,
    required this.edition,
    required this.editorialStatus,
    required this.pdfFileId,
    required this.sections,
  });

  final String id;
  final int volume;
  final int number;
  final String title;
  final String edition;
  final String editorialStatus;
  final String pdfFileId;
  final List<StudySection> sections;

  bool get isPublished => editorialStatus.toLowerCase() == 'publicado';
  String get originalPdfUrl => 'https://drive.google.com/file/d/' + pdfFileId + '/view';

  factory StudyChapter.fromMap(Map<String, dynamic> source) {
    final doc = source['source'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final sections = (source['sections'] as List<dynamic>? ?? const <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .map((s) => StudySection(
              title: (s['title'] ?? 'Seção').toString(),
              text: (s['markdownContent'] ?? '').toString(),
            ))
        .toList(growable: false);
    return StudyChapter(
      id: (source['contentId'] ?? '').toString(),
      volume: (source['volume'] as num).toInt(),
      number: (source['chapter'] as num).toInt(),
      title: (source['title'] ?? 'Sem título').toString(),
      edition: (source['edition'] ?? '').toString(),
      editorialStatus: (source['editorialStatus'] ?? 'Em revisão').toString(),
      pdfFileId: (doc['fileId'] ?? '').toString(),
      sections: sections,
    );
  }
}

class StudyCatalog {
  /// Only chapters 01..26 were supplied. Do not fabricate chapters 27..113.
  static Future<List<StudyChapter>> loadBundledPreviews() async {
    final chapters = <StudyChapter>[];
    for (var n = 1; n <= 26; n++) {
      final v = n <= 10 ? 1 : (n <= 23 ? 2 : 3);
      final name = 'vol' + v.toString().padLeft(2, '0') +
          '_ch' + n.toString().padLeft(2, '0') + '.json';
      final raw = await rootBundle.loadString('assets/chapters/' + name);
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final chapter = StudyChapter.fromMap(data);
      if (chapter.number != n || chapter.volume != v) {
        throw FormatException('Capítulo divergente no pacote: ' + name);
      }
      chapters.add(chapter);
    }
    return chapters;
  }
}
