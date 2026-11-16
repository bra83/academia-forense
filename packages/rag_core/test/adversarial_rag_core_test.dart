import 'package:flutter_test/flutter_test.dart';
import 'package:rag_core/rag_core.dart';

void main() {
  group('Milestone 3 Adversarial: Unapproved Chapter Leakage Defense (§9.2, §18.3)', () {
    final unapprovedStatuses = [
      'Planejado',
      'Importado',
      'Em revisão',
      'Substituído',
      'Arquivado',
      'Rascunho',
      'Pendente',
      'draft',
      'unreviewed',
      'archived',
    ];

    for (final status in unapprovedStatuses) {
      test('strictly rejects unapproved status: "$status"', () {
        final chunk = RagDocumentChunk(
          chunkId: 'chunk_$status',
          editorialStatus: status,
          text: 'Texto não auditado em status $status.',
          volume: 1,
          chapter: 1,
          page: 1,
        );

        // Validation must throw ArgumentError
        expect(
          () => EditorialContextFilter.validateApprovedChunks([chunk]),
          throwsArgumentError,
          reason: 'Chunk with status "$status" must not pass approval validation',
        );

        // Filtering must remove it
        final filtered = EditorialContextFilter.filterApprovedChunks([chunk]);
        expect(filtered, isEmpty,
            reason: 'Chunk with status "$status" must be filtered out of RAG context');

        // Raw map filtering & validation
        final raw = [
          {'chunkId': 'c1', 'editorialStatus': status, 'text': 'Texto $status'}
        ];
        expect(() => EditorialContextFilter.validateRawChunks(raw), throwsArgumentError);
        expect(EditorialContextFilter.filterRawChunks(raw), isEmpty);
      });
    }

    test('retains only approved and published chapters in mixed batches', () {
      final mixedBatch = [
        const RagDocumentChunk(chunkId: 'c1', editorialStatus: 'Aprovado', text: 'T1'),
        const RagDocumentChunk(chunkId: 'c2', editorialStatus: 'Planejado', text: 'T2'),
        const RagDocumentChunk(chunkId: 'c3', editorialStatus: 'Publicado', text: 'T3'),
        const RagDocumentChunk(chunkId: 'c4', editorialStatus: 'Em revisão', text: 'T4'),
        const RagDocumentChunk(chunkId: 'c5', editorialStatus: 'Substituído', text: 'T5'),
        const RagDocumentChunk(chunkId: 'c6', editorialStatus: 'approved', text: 'T6'),
        const RagDocumentChunk(chunkId: 'c7', editorialStatus: 'published', text: 'T7'),
        const RagDocumentChunk(chunkId: 'c8', editorialStatus: 'Arquivado', text: 'T8'),
      ];

      final filtered = EditorialContextFilter.filterApprovedChunks(mixedBatch);
      expect(filtered.length, equals(4));
      final ids = filtered.map((c) => c.chunkId).toList();
      expect(ids, equals(['c1', 'c3', 'c6', 'c7']));
    });
  });

  group('Milestone 3 Adversarial: Zero Hallucination Guarantee (§9.2)', () {
    test('declares absence of support when candidate chunk list is empty', () {
      final res = RagContextBuilder.buildContextInjection([]);
      expect(res, equals(RagContextBuilder.absenceOfSupportMessage));
      expect(res, contains('Declarar ausência de suporte'));
      expect(res, contains('Não há material aprovado na Enciclopédia'));
    });

    test('declares absence of support when all candidate chunks are unapproved', () {
      const unapprovedBatch = [
        RagDocumentChunk(chunkId: 'u1', editorialStatus: 'Planejado', text: 'Preliminar'),
        RagDocumentChunk(chunkId: 'u2', editorialStatus: 'Em revisão', text: 'Sob revisão'),
        RagDocumentChunk(chunkId: 'u3', editorialStatus: 'Substituído', text: 'Antigo'),
      ];
      final res = RagContextBuilder.buildContextInjection(unapprovedBatch);
      expect(res, equals(RagContextBuilder.absenceOfSupportMessage));
    });

    test('raw map builder declares absence of support when empty or unapproved', () {
      expect(
        RagContextBuilder.buildFromRawChunks([]),
        equals(RagContextBuilder.absenceOfSupportMessage),
      );

      final unapprovedRaw = [
        {'editorialStatus': 'Planejado', 'text': 'Draft'}
      ];
      expect(
        RagContextBuilder.buildFromRawChunks(unapprovedRaw),
        equals(RagContextBuilder.absenceOfSupportMessage),
      );
    });
  });

  group('Milestone 3 Adversarial: Citation Bounds & Tag Validation (§9.2)', () {
    test('verifies strict curriculum bounds: volumes 1-9 and chapters 1-113', () {
      // Valid extremes
      expect(() => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: 1), returnsNormally);
      expect(() => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: 113), returnsNormally);
      expect(() => RagCitationEngine.verifyCitationBounds(volume: 9, chapter: 1), returnsNormally);
      expect(() => RagCitationEngine.verifyCitationBounds(volume: 9, chapter: 113), returnsNormally);

      // Volume boundaries: < 1 or > 9
      for (final badVol in [-10, -1, 0, 10, 15, 99]) {
        expect(
          () => RagCitationEngine.verifyCitationBounds(volume: badVol, chapter: 1),
          throwsA(isA<CitationLookupError>()),
          reason: 'Volume $badVol is out of bounds [1, 9]',
        );
      }

      // Chapter boundaries: < 1 or > 113
      for (final badChap in [-10, -1, 0, 114, 200, 999]) {
        expect(
          () => RagCitationEngine.verifyCitationBounds(volume: 1, chapter: badChap),
          throwsA(isA<CitationLookupError>()),
          reason: 'Chapter $badChap is out of bounds [1, 113]',
        );
      }
    });

    test('page validation against total chapter pages bounds', () {
      // Within bounds
      expect(
        () => RagCitationEngine.validateCitationPage(page: 1, chapterTotalPages: 50),
        returnsNormally,
      );
      expect(
        () => RagCitationEngine.validateCitationPage(page: 50, chapterTotalPages: 50),
        returnsNormally,
      );

      // Out of bounds
      expect(
        () => RagCitationEngine.validateCitationPage(page: 0, chapterTotalPages: 50),
        throwsArgumentError,
      );
      expect(
        () => RagCitationEngine.validateCitationPage(page: -1, chapterTotalPages: 50),
        throwsArgumentError,
      );
      expect(
        () => RagCitationEngine.validateCitationPage(page: 51, chapterTotalPages: 50),
        throwsArgumentError,
      );
      expect(
        () => RagCitationEngine.validateCitationPage(page: 1000, chapterTotalPages: 50),
        throwsArgumentError,
      );
    });

    test('rejects ungrounded responses missing [FONTE] or [INFERÊNCIA]', () {
      final ungroundedReplies = [
        'A resposta para a sua dúvida é que o perito assina o laudo.',
        'Sem dúvida o hash SHA-256 é imutável e inquebrável.',
        'Segundo meus conhecimentos gerais sobre forense computacional...',
        '   ',
      ];

      for (final reply in ungroundedReplies) {
        expect(
          () => RagCitationEngine.validateResponseTags(reply),
          throwsArgumentError,
          reason: 'Reply without [FONTE] or [INFERÊNCIA] must be rejected',
        );
      }

      // Valid replies
      expect(
        () => RagCitationEngine.validateResponseTags(
          'O laudo é peça técnica [FONTE: Vol 1, Cap 1, p. 10].',
        ),
        returnsNormally,
      );
      expect(
        () => RagCitationEngine.validateResponseTags(
          '[INFERÊNCIA: Isso demonstra que a cadeia foi preservada].',
        ),
        returnsNormally,
      );
    });
  });
}
