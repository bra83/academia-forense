import '../filter/editorial_context_filter.dart';
import '../models/rag_chunk.dart';

/// Context Builder with Zero Hallucination Guarantee (§9.2).
class RagContextBuilder {
  RagContextBuilder._();

  static const String absenceOfSupportMessage =
      'Declarar ausência de suporte: Não há material aprovado na Enciclopédia de Ciências Forenses sobre este tópico específico.';

  /// Filters and formats candidate chunks.
  /// If no approved chunks exist, strictly declares absence of support.
  static String buildContextInjection(List<RagDocumentChunk> candidateChunks) {
    final approved = EditorialContextFilter.filterApprovedChunks(candidateChunks);

    if (approved.isEmpty) {
      return absenceOfSupportMessage;
    }

    final buffer = StringBuffer();
    buffer.writeln('=== CONTEXTO APROVADO DA ENCICLOPÉDIA DE CIÊNCIAS FORENSES ===');
    for (final c in approved) {
      buffer.writeln('${c.citationTag} ${c.text}');
    }
    return buffer.toString();
  }

  /// Builds context from raw maps.
  static String buildFromRawChunks(List<Map<String, dynamic>> rawChunks) {
    final approved = EditorialContextFilter.filterRawChunks(rawChunks);
    if (approved.isEmpty) {
      return absenceOfSupportMessage;
    }

    final buffer = StringBuffer();
    for (final c in approved) {
      final vol = c['volume'] ?? 1;
      final ch = c['chapter'] ?? 1;
      final pg = c['page'] ?? 1;
      final text = c['text'] ?? '';
      buffer.writeln('[FONTE: Vol $vol, Cap $ch, p. $pg] $text');
    }
    return buffer.toString();
  }
}
