class ErrataEntry {
  final String errataId;
  final int volumeId;
  final int chapterNumber;
  final String chapterId;
  final String revision;
  final int printedPageNumber;
  final String originalText;
  final String correctedText;
  final String? justification;
  final String status;

  const ErrataEntry({
    required this.errataId,
    required this.volumeId,
    required this.chapterNumber,
    required this.chapterId,
    required this.revision,
    required this.printedPageNumber,
    required this.originalText,
    required this.correctedText,
    this.justification,
    this.status = 'active',
  });

  factory ErrataEntry.fromJson(Map<String, dynamic> json) {
    return ErrataEntry(
      errataId: (json['errataId'] ?? json['errata_id'] ?? '') as String,
      volumeId: (json['volumeId'] ?? json['volume_id'] ?? 1) as int,
      chapterNumber: (json['chapterNumber'] ?? json['chapter_number'] ?? json['ch'] ?? 1) as int,
      chapterId: (json['chapterId'] ?? json['chapter_id'] ?? '') as String,
      revision: (json['revision'] ?? 'REV1') as String,
      printedPageNumber: (json['printedPageNumber'] ?? json['printed_page_number'] ?? json['page'] ?? 1) as int,
      originalText: (json['originalText'] ?? json['original_text'] ?? '') as String,
      correctedText: (json['correctedText'] ?? json['corrected_text'] ?? json['correction'] ?? '') as String,
      justification: (json['justification'] ?? json['reason']) as String?,
      status: (json['status'] ?? 'active') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'errataId': errataId,
        'volumeId': volumeId,
        'chapterNumber': chapterNumber,
        'chapterId': chapterId,
        'revision': revision,
        'printedPageNumber': printedPageNumber,
        'originalText': originalText,
        'correctedText': correctedText,
        if (justification != null) 'justification': justification,
        'status': status,
      };
}
