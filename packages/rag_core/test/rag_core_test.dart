import 'package:flutter_test/flutter_test.dart';
import 'package:rag_core/rag_core.dart';

void main() {
  group('Strict RAG Editorial Context Bounding (§9.2, §18.3)', () {
    test('filters out unapproved, planned, or under-review chapters', () {
      const candidateChunks = [
        RagDocumentChunk(
          chunkId: 'c1',
          editorialStatus: 'approved',
          text: 'Texto oficial aprovado.',
        ),
        RagDocumentChunk(
          chunkId: 'c2',
          editorialStatus: 'Planejado',
          text: 'Texto preliminar não auditado.',
        ),
        RagDocumentChunk(
          chunkId: 'c3',
          editorialStatus: 'Em revisão',
          text: 'Texto sob revisão técnica.',
        ),
        RagDocumentChunk(
          chunkId: 'c4',
          editorialStatus: 'published',
          text: 'Texto publicado.',
        ),
      ];

      final filtered = EditorialContextFilter.filterApprovedChunks(candidateChunks);
      expect(filtered.length, equals(2));
      final ids = filtered.map((c) => c.chunkId).toList();
      expect(ids, contains('c1'));
      expect(ids, contains('c4'));
      expect(ids, isNot(contains('c2')));
      expect(ids, isNot(contains('c3')));
    });

    test('validating unapproved chunks directly throws ArgumentError', () {
      const validChunks = [
        RagDocumentChunk(
          chunkId: 'c1',
          editorialStatus: 'Aprovado',
          text: 'Texto aprovado.',
        ),
      ];
      expect(() => EditorialContextFilter.validateApprovedChunks(validChunks), returnsNormally);

      const unapprovedChunks = [
        RagDocumentChunk(
          chunkId: 'c2',
          editorialStatus: 'Planejado',
          text: 'Texto não auditado.',
        ),
      ];
      expect(
        () => EditorialContextFilter.validateApprovedChunks(unapprovedChunks),
        throwsArgumentError,
      );
    });
  });

  group('Citation Parser & Provenance Enforcement (§9.2)', () {
    test('parses explicit [FONTE: ...] and [INFERÊNCIA] tags accurately', () {
      const tutorReply =
          'Segundo a norma [FONTE: Vol 1, Cap 1, p. 12], a cadeia de custódia inicia-se no local. '
          '[INFERÊNCIA: Isso implica que a fixação fotográfica prévia é indispensável].';

      final res = RagCitationEngine.parseResponseCitations(tutorReply);
      expect(res.hasFonte, isTrue);
      expect(res.hasInferencia, isTrue);
      expect(res.fontes.length, equals(1));
      expect(res.fontes.first, equals('Vol 1, Cap 1, p. 12'));
    });

    test('rejects ungrounded claims lacking citation tags with ArgumentError', () {
      const ungrounded = 'A enciclopédia afirma categoricamente que o hash MD5 nunca colide.';
      final res = RagCitationEngine.parseResponseCitations(ungrounded);
      expect(res.hasFonte, isFalse);
      expect(res.hasInferencia, isFalse);

      expect(() => RagCitationEngine.validateResponseTags(ungrounded), throwsArgumentError);

      const validTagged = 'Segundo a Enciclopédia [FONTE: Vol 1 Ch 1], a cadeia de custódia preserva a idoneidade.';
      expect(() => RagCitationEngine.validateResponseTags(validTagged), returnsNormally);
    });

    test('verifies citation volume (1..9) and chapter (1..113) boundaries', () {
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: 1),
        returnsNormally,
      );
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 9, chapter: 113),
        returnsNormally,
      );

      // Volume < 1 or > 9
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 0, chapter: 1),
        throwsA(isA<CitationLookupError>()),
      );
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 15, chapter: 1),
        throwsA(isA<CitationLookupError>()),
      );

      // Chapter < 1 or > 113
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: 0),
        throwsA(isA<CitationLookupError>()),
      );
      expect(
        () => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: 200),
        throwsA(isA<CitationLookupError>()),
      );
    });

    test('validates citation page within chapter page count boundaries', () {
      expect(
        () => RagCitationEngine.validateCitationPage(page: 15, chapterTotalPages: 20),
        returnsNormally,
      );

      expect(
        () => RagCitationEngine.validateCitationPage(page: 0, chapterTotalPages: 20),
        throwsArgumentError,
      );
      expect(
        () => RagCitationEngine.validateCitationPage(page: 999, chapterTotalPages: 20),
        throwsArgumentError,
      );
    });
  });

  group('Zero Hallucination Guarantee (§9.2)', () {
    test('declares absence of support when no approved chunks match', () {
      final res = RagContextBuilder.buildContextInjection([]);
      expect(res, startsWith('Declarar ausência de suporte'));
      expect(res, contains('Não há material aprovado na Enciclopédia'));
    });

    test('formats approved chunks with explicit metadata citations', () {
      const chunks = [
        RagDocumentChunk(
          chunkId: 'c1',
          editorialStatus: 'Aprovado',
          volume: 1,
          chapter: 2,
          page: 5,
          text: 'O princípio de Locard postula que todo contato deixa uma marca.',
        ),
      ];

      final res = RagContextBuilder.buildContextInjection(chunks);
      expect(res, contains('[FONTE: Vol 1, Cap 2, p. 5]'));
      expect(res, contains('princípio de Locard'));
    });
  });
}
