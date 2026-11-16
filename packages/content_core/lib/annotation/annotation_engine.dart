class UserAnnotation {
  final String noteId;
  final String chapterId;
  String revision;
  final String anchorText;
  String note;
  bool driftWarning;
  final DateTime createdAt;
  DateTime updatedAt;

  UserAnnotation({
    required this.noteId,
    required this.chapterId,
    required this.revision,
    required this.anchorText,
    required this.note,
    this.driftWarning = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'note_id': noteId,
        'chapter_id': chapterId,
        'revision': revision,
        'anchor_text': anchorText,
        'note': note,
        'drift_warning': driftWarning,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class RevisionJournalEntry {
  final String chapterId;
  final String fromRevision;
  final String toRevision;
  final String reason;
  final DateTime timestamp;

  const RevisionJournalEntry({
    required this.chapterId,
    required this.fromRevision,
    required this.toRevision,
    required this.reason,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'chapter_id': chapterId,
        'from_rev': fromRevision,
        'to_rev': toRevision,
        'reason': reason,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Manages student annotations with anchor drift tolerance across content revisions (§2.2).
class AnnotationEngine {
  final List<UserAnnotation> _annotations = [];
  final List<RevisionJournalEntry> _auditJournal = [];

  List<UserAnnotation> get annotations => List.unmodifiable(_annotations);
  List<RevisionJournalEntry> get auditJournal => List.unmodifiable(_auditJournal);

  /// Adds a new student annotation.
  void addAnnotation({
    required String noteId,
    required String chapterId,
    required String revision,
    required String anchorText,
    required String note,
  }) {
    _annotations.add(
      UserAnnotation(
        noteId: noteId,
        chapterId: chapterId,
        revision: revision,
        anchorText: anchorText,
        note: note,
      ),
    );
  }

  /// Retrieves annotations for a chapter.
  List<UserAnnotation> getAnnotationsForChapter(String chapterId) {
    return _annotations.where((a) => a.chapterId == chapterId).toList();
  }

  /// Updates chapter content to a new revision while preserving notes and detecting anchor drift.
  void applyRevisionUpdate({
    required String chapterId,
    required String fromRevision,
    required String toRevision,
    required String newContent,
    String reason = 'Editorial update',
  }) {
    for (final ann in _annotations) {
      if (ann.chapterId == chapterId) {
        ann.revision = toRevision;
        ann.updatedAt = DateTime.now();
        // Check if anchor still exists in new content
        if (!newContent.contains(ann.anchorText)) {
          ann.driftWarning = true;
        }
      }
    }

    _auditJournal.add(
      RevisionJournalEntry(
        chapterId: chapterId,
        fromRevision: fromRevision,
        toRevision: toRevision,
        reason: reason,
        timestamp: DateTime.now(),
      ),
    );
  }
}
