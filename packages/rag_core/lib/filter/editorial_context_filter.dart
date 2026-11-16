import '../models/rag_chunk.dart';

/// Filters and bounds RAG context strictly to approved editorial content (§9.2, §18.3).
class EditorialContextFilter {
  EditorialContextFilter._();

  static const Set<String> allowedStatuses = {
    'Aprovado',
    'Publicado',
    'approved',
    'published',
  };

  /// Filters candidate chunks and retains only approved/published chapters.
  static List<RagDocumentChunk> filterApprovedChunks(List<RagDocumentChunk> chunks) {
    return chunks.where((c) => allowedStatuses.contains(c.editorialStatus)).toList();
  }

  /// Filters list of raw maps.
  static List<Map<String, dynamic>> filterRawChunks(List<Map<String, dynamic>> chunks) {
    return chunks.where((c) {
      final status = c['editorialStatus'] ?? c['editorial_status'];
      return allowedStatuses.contains(status);
    }).toList();
  }

  /// Validates that all chunks in a candidate batch are approved.
  /// Throws ArgumentError if any chunk has unapproved status (e.g. 'Planejado', 'Em revisão').
  static void validateApprovedChunks(List<RagDocumentChunk> chunks) {
    for (final c in chunks) {
      if (!allowedStatuses.contains(c.editorialStatus)) {
        throw ArgumentError(
          "RAG context rejected: chapter status '${c.editorialStatus}' is not approved for RAG (§9.2)",
        );
      }
    }
  }

  /// Validates raw map chunks.
  static void validateRawChunks(List<Map<String, dynamic>> chunks) {
    for (final c in chunks) {
      final status = c['editorialStatus'] ?? c['editorial_status'];
      if (!allowedStatuses.contains(status)) {
        throw ArgumentError(
          "RAG context rejected: chapter status '$status' is not approved for RAG",
        );
      }
    }
  }
}
