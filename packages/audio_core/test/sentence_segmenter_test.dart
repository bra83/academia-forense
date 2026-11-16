import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentenceSegmenter Unit Tests (§12.2, §12.3)', () {
    const sampleForensicText =
        'A perícia forense digital fundamenta-se na transformação de dados brutos em evidências legalmente válidas. '
        'Para assegurar a idoneidade probatória, é imperativo o estrito cumprimento da cadeia de custódia formal. '
        'A identificação e coleta de vestígios digitais devem obedecer rigorosamente às diretrizes estabelecidas na norma ISO 27037. '
        'Qualquer manipulação indevida no suporte de armazenamento original pode gerar nulidade processual insanável. '
        'A replicação bit a bit do disco rígido ou memória flash deve ser validada por funções de dispersão criptográfica como SHA-256.';

    test('default constants match specifications (§12.2)', () {
      expect(SentenceSegmenter.minChars, 250);
      expect(SentenceSegmenter.targetChars, 450);
      expect(SentenceSegmenter.maxChars, 650);
      expect(SentenceSegmenter.maxNumSentences, 2);
      expect(SentenceSegmenter.silenceScale, 0.06);
      expect(SentenceSegmenter.numThreads, 4);
    });

    test('empty or whitespace text returns empty result', () {
      final resEmpty = SentenceSegmenter.segment('');
      expect(resEmpty.chunks, isEmpty);
      expect(resEmpty.firstChunk, isNull);

      final resWhitespace = SentenceSegmenter.segment('   \n\t  ');
      expect(resWhitespace.chunks, isEmpty);
      expect(resWhitespace.firstChunk, isNull);
    });

    test('chunks respect maxChars bound (<= 650 characters)', () {
      final result = SentenceSegmenter.segment(sampleForensicText);
      expect(result.chunks, isNotEmpty);
      for (final chunk in result.chunks) {
        expect(
          chunk.length,
          lessThanOrEqualTo(SentenceSegmenter.maxChars),
          reason: 'Chunk ${chunk.id} exceeded max 650 chars: ${chunk.length}',
        );
      }
    });

    test('chunks respect maxNumSentences bound (<= 2 sentences per chunk)', () {
      final result = SentenceSegmenter.segment(sampleForensicText);
      for (final chunk in result.chunks) {
        expect(
          chunk.sentenceCount,
          lessThanOrEqualTo(SentenceSegmenter.maxNumSentences),
          reason: 'Chunk ${chunk.id} exceeded max 2 sentences: ${chunk.sentenceCount}',
        );
      }
    });

    test('first chunk is available immediately for low latency (§12.4)', () {
      final result = SentenceSegmenter.segment(sampleForensicText);
      expect(result.firstChunk, isNotNull);
      expect(result.firstChunk!.index, 0);
      expect(result.firstChunk!.text, isNotEmpty);
      expect(result.firstChunk!.text, result.chunks.first.text);
    });

    test('segmentStream yields all chunks sequentially', () async {
      final streamChunks = await SentenceSegmenter.segmentStream(sampleForensicText).toList();
      final directResult = SentenceSegmenter.segment(sampleForensicText);

      expect(streamChunks.length, directResult.chunks.length);
      for (var i = 0; i < streamChunks.length; i++) {
        expect(streamChunks[i].text, directResult.chunks[i].text);
      }
    });

    test('preserves total content and words without truncation or duplication (§12.3)', () {
      final chunks = SentenceSegmenter.segmentText(sampleForensicText);
      expect(chunks, isNotEmpty);

      // Reconstruct words
      final originalWords = sampleForensicText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final chunkWords = chunks.join(' ').split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();

      expect(chunkWords, equals(originalWords));
    });

    test('handles oversized sentences by cleanly splitting at word boundaries', () {
      // Long sentence without terminal punctuation
      final longSentence = List.generate(80, (i) => 'PalavraExtensa$i').join(' ');
      expect(longSentence.length, greaterThan(SentenceSegmenter.maxChars));

      final result = SentenceSegmenter.segment(longSentence);
      expect(result.chunks.length, greaterThan(1));
      for (final chunk in result.chunks) {
        expect(chunk.length, lessThanOrEqualTo(SentenceSegmenter.maxChars));
        for (final word in chunk.text.split(' ')) {
          expect(word.startsWith('PalavraExtensa'), isTrue);
        }
      }
    });
  });
}
