import 'package:meta/meta.dart';

/// Provenance tags enforced by Section 9.2 for academic transparency.
enum ProvenanceTag {
  fonteDaEnciclopedia('[FONTE DA ENCICLOPÉDIA]'),
  conhecimentoComplementar('[CONHECIMENTO COMPLEMENTAR]'),
  inferenciaDoTutor('[INFERÊNCIA DO TUTOR]'),
  exercicioHipotetico('[EXERCÍCIO HIPOTÉTICO]');

  const ProvenanceTag(this.tag);

  final String tag;
}

/// Representation of an indexed RAG document chunk (§9.2, §18.3).
@immutable
class RagDocumentChunk {
  const RagDocumentChunk({
    required this.chunkId,
    required this.text,
    required this.editorialStatus,
    this.volume = 1,
    this.chapter = 1,
    this.page = 1,
    this.sectionId,
    this.sha256,
    this.chapterTitle,
  });

  final String chunkId;
  final String text;
  final String editorialStatus;
  final int volume;
  final int chapter;
  final int page;
  final String? sectionId;
  final String? sha256;
  final String? chapterTitle;

  bool get isApproved {
    const allowed = {'Aprovado', 'Publicado', 'approved', 'published'};
    return allowed.contains(editorialStatus);
  }

  /// Formatted citation tag (e.g. "[FONTE: Vol 1, Cap 1, p. 12]").
  String get citationTag => '[FONTE: Vol $volume, Cap $chapter, p. $page]';

  Map<String, dynamic> toJson() => {
        'chunkId': chunkId,
        'text': text,
        'editorialStatus': editorialStatus,
        'volume': volume,
        'chapter': chapter,
        'page': page,
        if (sectionId != null) 'sectionId': sectionId,
        if (sha256 != null) 'sha256': sha256,
        if (chapterTitle != null) 'chapterTitle': chapterTitle,
      };

  factory RagDocumentChunk.fromJson(Map<String, dynamic> json) {
    return RagDocumentChunk(
      chunkId: json['chunkId'] as String? ?? json['chunk_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      editorialStatus: json['editorialStatus'] as String? ?? json['editorial_status'] as String? ?? 'Planejado',
      volume: json['volume'] as int? ?? 1,
      chapter: json['chapter'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      sectionId: json['sectionId'] as String? ?? json['section_id'] as String?,
      sha256: json['sha256'] as String?,
      chapterTitle: json['chapterTitle'] as String? ?? json['chapter_title'] as String?,
    );
  }
}
