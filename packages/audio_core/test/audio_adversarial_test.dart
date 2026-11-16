import 'dart:convert';
import 'dart:typed_data';
import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Adversarial Stress Test: Sentence Segmenter Boundaries (§12.2, §12.3)', () {
    test('extreme text size: 0 characters (empty and whitespace-only)', () {
      final resEmpty = SentenceSegmenter.segment('');
      expect(resEmpty.chunks, isEmpty);
      expect(resEmpty.firstChunk, isNull);
      expect(resEmpty.totalCharacters, 0);

      final resWhitespace = SentenceSegmenter.segment('    \r\n\t  \n   ');
      expect(resWhitespace.chunks, isEmpty);
      expect(resWhitespace.firstChunk, isNull);
      expect(resWhitespace.totalCharacters, 0);
    });

    test('extreme text size: 50 characters short text', () {
      const shortText = 'Vestígio digital íntegro sob custódia pericial.';
      expect(shortText.length, lessThanOrEqualTo(50));

      final result = SentenceSegmenter.segment(shortText);
      expect(result.chunks.length, 1);
      expect(result.firstChunk, isNotNull);
      expect(result.firstChunk!.text, shortText);
      expect(result.firstChunk!.sentenceCount, 1);
      expect(result.firstChunk!.length, shortText.length);
      expect(result.firstChunk!.length, lessThanOrEqualTo(SentenceSegmenter.maxChars));
    });

    test('extreme text size: 10,000 characters text without punctuation', () {
      // 1,500 words without terminal punctuation (. ! ? ; :)
      final words = List.generate(1500, (i) => 'palavraPericial${i % 100}');
      final longText = words.join(' ');
      expect(longText.length, greaterThan(10000));

      final result = SentenceSegmenter.segment(longText);
      expect(result.chunks, isNotEmpty);
      expect(result.chunks.length, greaterThan(15));

      // 1. Verify no chunk exceeds 650 chars
      for (final chunk in result.chunks) {
        expect(
          chunk.length,
          lessThanOrEqualTo(SentenceSegmenter.maxChars),
          reason: 'Chunk ${chunk.id} exceeded 650 chars: ${chunk.length}',
        );
      }

      // 2. Verify sentence count does not exceed 2
      for (final chunk in result.chunks) {
        expect(
          chunk.sentenceCount,
          lessThanOrEqualTo(SentenceSegmenter.maxNumSentences),
          reason: 'Chunk ${chunk.id} exceeded max 2 sentences: ${chunk.sentenceCount}',
        );
      }

      // 3. Verify words are never cut mid-token and 100% of words preserved
      final reassembledWords = result.chunks
          .expand((c) => c.text.split(RegExp(r'\s+')))
          .where((w) => w.isNotEmpty)
          .toList();

      expect(reassembledWords.length, equals(words.length));
      expect(reassembledWords, equals(words));
    });

    test('texts with heavy Portuguese abbreviations (Dr., Art., fls., pág., Prof., Exmo.)', () {
      const abbreviationText =
          'O Dr. Silva examinou o Art. 158 do CPP e as fls. 45 do laudo forense. '
          'O Prof. Souza e o Exmo. Juiz avaliaram o pág. 12 do anexo pericial.';

      final result = SentenceSegmenter.segment(abbreviationText);
      expect(result.chunks, isNotEmpty);

      // Verify no chunk exceeds 650 chars
      for (final chunk in result.chunks) {
        expect(chunk.length, lessThanOrEqualTo(SentenceSegmenter.maxChars));
        expect(chunk.sentenceCount, lessThanOrEqualTo(SentenceSegmenter.maxNumSentences));
      }

      // Verify 100% words preserved without truncation
      final originalWords = abbreviationText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final chunkWords = result.chunks
          .expand((c) => c.text.split(RegExp(r'\s+')))
          .where((w) => w.isNotEmpty)
          .toList();

      expect(chunkWords, equals(originalWords));
      expect(chunkWords.contains('Dr.'), isTrue);
      expect(chunkWords.contains('Art.'), isTrue);
      expect(chunkWords.contains('fls.'), isTrue);
      expect(chunkWords.contains('pág.'), isTrue);
      expect(chunkWords.contains('Prof.'), isTrue);
      expect(chunkWords.contains('Exmo.'), isTrue);
    });

    test('texts with formulas, quotes, brackets, and citations', () {
      const formulaText =
          'Segundo o laudo, "a entropia calculada foi H(X) = 7.98 bits/byte para o arquivo suspeito". '
          'A função SHA-256("evidencia") resultou no hash [FONTE: Vol 1, Ch 2, p. 15]. '
          'A equação final E = m * c^2 valida o modelo matemático forense.';

      final result = SentenceSegmenter.segment(formulaText);
      expect(result.chunks, isNotEmpty);

      for (final chunk in result.chunks) {
        expect(chunk.length, lessThanOrEqualTo(SentenceSegmenter.maxChars));
        expect(chunk.sentenceCount, lessThanOrEqualTo(SentenceSegmenter.maxNumSentences));
      }

      final originalWords = formulaText.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
      final chunkWords = result.chunks
          .expand((c) => c.text.split(RegExp(r'\s+')))
          .where((w) => w.isNotEmpty)
          .toList();

      expect(chunkWords, equals(originalWords));
    });
  });

  group('Adversarial Stress Test: Speed Limits & Bounds Probing (§12.2, §22)', () {
    late AudioPlaybackController controller;

    setUp(() {
      controller = AudioPlaybackController();
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('sub-minimum speed boundary values (< 0.65) are strictly rejected', () {
      final subMinSpeeds = [0.64, 0.50, 0.30, 0.10, 0.0, -0.05, -1.0, -10.0, -99.9];
      for (final s in subMinSpeeds) {
        expect(
          () => controller.setSpeed(s),
          throwsA(isA<RangeError>()),
          reason: 'Speed $s below 0.65 should throw RangeError',
        );
      }
    });

    test('super-maximum speed boundary values (> 1.50) are strictly rejected', () {
      final superMaxSpeeds = [1.51, 1.55, 1.75, 2.0, 3.5, 5.0, 10.0, 100.0];
      for (final s in superMaxSpeeds) {
        expect(
          () => controller.setSpeed(s),
          throwsA(isA<RangeError>()),
          reason: 'Speed $s above 1.50 should throw RangeError',
        );
      }
    });

    test('0.05 step snapping across valid spectrum [0.65, 1.50]', () {
      final testCases = {
        0.65: 0.65,
        0.66: 0.65,
        0.67: 0.65,
        0.68: 0.70,
        0.72: 0.70,
        0.73: 0.75,
        0.88: 0.90,
        0.98: 1.00,
        1.02: 1.00,
        1.24: 1.25,
        1.47: 1.45,
        1.48: 1.50,
        1.50: 1.50,
      };

      testCases.forEach((input, expected) {
        controller.setSpeed(input);
        expect(
          controller.speed,
          closeTo(expected, 0.001),
          reason: 'Input $input should snap to $expected, got ${controller.speed}',
        );
      });
    });
  });

  group('Adversarial Stress Test: 44-Byte WAV Header Validation (§13, §21)', () {
    test('truncated WAV buffers (< 44 bytes) throw FormatException', () {
      final testLengths = [0, 1, 8, 16, 20, 32, 40, 43];
      for (final len in testLengths) {
        final truncatedBuffer = Uint8List(len);
        expect(
          () => WavHeaderBuilder.parseAndValidateWav(truncatedBuffer),
          throwsA(isA<FormatException>().having((e) => e.message, 'message', contains('Truncated WAV'))),
          reason: 'Buffer of length $len must be rejected as truncated',
        );
      }
    });

    test('corrupted magic bytes throw FormatException', () {
      // 1. Corrupted RIFF
      final badRiff = WavHeaderBuilder.createWavHeader(pcmDataLength: 100);
      badRiff[0] = 0x58; // 'X'
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(badRiff),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains("Missing 'RIFF'"))),
      );

      // 2. Corrupted WAVE
      final badWave = WavHeaderBuilder.createWavHeader(pcmDataLength: 100);
      badWave[8] = 0x58; // 'X'
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(badWave),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains("Missing 'WAVE'"))),
      );

      // 3. Corrupted fmt
      final badFmt = WavHeaderBuilder.createWavHeader(pcmDataLength: 100);
      badFmt[12] = 0x58; // 'X'
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(badFmt),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains("Missing 'fmt '"))),
      );

      // 4. Corrupted data
      final badData = WavHeaderBuilder.createWavHeader(pcmDataLength: 100);
      badData[36] = 0x58; // 'X'
      expect(
        () => WavHeaderBuilder.parseAndValidateWav(badData),
        throwsA(isA<FormatException>().having((e) => e.message, 'message', contains("Missing 'data'"))),
      );
    });

    test('corrupted or invalid audio parameters throw ArgumentError in createWavHeader', () {
      // Negative pcm data length
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: -1),
        throwsA(isA<ArgumentError>()),
      );

      // Zero or negative sample rate
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, sampleRate: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, sampleRate: -24000),
        throwsA(isA<ArgumentError>()),
      );

      // Zero or negative channels
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, numChannels: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, numChannels: -1),
        throwsA(isA<ArgumentError>()),
      );

      // Invalid bits per sample (not multiple of 8 or non-positive)
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, bitsPerSample: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, bitsPerSample: 7),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WavHeaderBuilder.createWavHeader(pcmDataLength: 100, bitsPerSample: 13),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('corrupted Base64 payloads throw FormatException', () {
      final corruptedPayloads = [
        r'$$$NotBase64%%%',
        '==invalidPadding',
        'a', // incomplete base64 unit
        'abc',
      ];
      for (final bad in corruptedPayloads) {
        expect(
          () => WavHeaderBuilder.base64PcmToWav(bad),
          throwsA(isA<FormatException>()),
          reason: 'Malformed base64 "$bad" should throw FormatException',
        );
      }
    });

    test('empty or zero-byte audio payloads are rejected', () {
      expect(
        () => WavHeaderBuilder.packagePcmToWav(Uint8List(0)),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => WavHeaderBuilder.base64PcmToWav(''),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => WavHeaderBuilder.base64PcmToWav('   '),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('Adversarial Stress Test: Network / Quota Drops & Anti-Silent Fallback (§11.1)', () {
    test('HTTP 429 quota exhaustion transitions controller to error without silent fallback', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": {"code": 429, "message": "Quota exceeded"}}', 429);
      });

      final client = GeminiTtsClient(apiKey: 'quota-exceeded-key', httpClient: mockHttp);
      final motorB = MotorBGeminiController(client: client);
      final controller = AudioPlaybackController(
        initialEngine: AudioEngine.geminiOnline,
        motorB: motorB,
      );

      final failures = <AudioEngineFailure>[];
      final failureSub = controller.failureStream.listen(failures.add);

      // Attempt playback
      await controller.startPlayback(['Texto de teste sob quota 429']);

      // Await stream dispatch
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.state, PlaybackStatus.error);
      expect(controller.selectedEngine, AudioEngine.geminiOnline); // MUST NOT switch silently!
      expect(failures, isNotEmpty);
      expect(failures.first.error, isTrue);
      expect(failures.first.silentFallbackAllowed, isFalse);
      expect(failures.first.failedEngine, 'gemini_online');

      await failureSub.cancel();
      await motorB.dispose();
      await controller.dispose();
    });

    test('HTTP 401 unauthorized transitions controller to error without silent fallback', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": {"code": 401, "message": "Invalid API Key"}}', 401);
      });

      final client = GeminiTtsClient(apiKey: 'bad-key', httpClient: mockHttp);
      final motorB = MotorBGeminiController(client: client);
      final controller = AudioPlaybackController(
        initialEngine: AudioEngine.geminiOnline,
        motorB: motorB,
      );

      await controller.startPlayback(['Texto sob 401']);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.state, PlaybackStatus.error);
      expect(controller.selectedEngine, AudioEngine.geminiOnline);

      await motorB.dispose();
      await controller.dispose();
    });

    test('HTTP 404 model not found transitions controller to error without silent fallback', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": {"code": 404, "message": "Model not found"}}', 404);
      });

      final client = GeminiTtsClient(
        apiKey: 'key',
        model: 'non-existent-model',
        httpClient: mockHttp,
      );
      final motorB = MotorBGeminiController(client: client);
      final controller = AudioPlaybackController(
        initialEngine: AudioEngine.geminiOnline,
        motorB: motorB,
      );

      await controller.startPlayback(['Texto sob 404']);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(controller.state, PlaybackStatus.error);
      expect(controller.selectedEngine, AudioEngine.geminiOnline);

      await motorB.dispose();
      await controller.dispose();
    });

    test('attempting silent fallback without user confirmation strictly throws StateError', () {
      final controller = AudioPlaybackController(initialEngine: AudioEngine.geminiOnline);

      expect(
        () => controller.handleEngineFailure(
          targetFallback: AudioEngine.kokoroLocal,
          userConfirmed: false,
        ),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('strictly blocked without confirmation'),
        )),
      );

      // Selected engine remains Gemini Online
      expect(controller.selectedEngine, AudioEngine.geminiOnline);
    });

    test('explicit user confirmation allows fallback switch', () {
      final controller = AudioPlaybackController(initialEngine: AudioEngine.geminiOnline);

      final report = controller.handleEngineFailure(
        targetFallback: AudioEngine.kokoroLocal,
        userConfirmed: true,
      );

      expect(report.error, isFalse);
      expect(controller.selectedEngine, AudioEngine.kokoroLocal);
      expect(controller.state, PlaybackStatus.idle);
    });
  });

  group('Adversarial Stress Test: Seeking Bounds Clamping', () {
    late AudioPlaybackController controller;

    setUp(() {
      controller = AudioPlaybackController();
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('seeking clamps negative indices to 0', () async {
      await controller.startPlayback(['P0', 'P1', 'P2']);

      await controller.seekParagraph(-1);
      expect(controller.currentParagraphIndex, 0);

      await controller.seekParagraph(-999);
      expect(controller.currentParagraphIndex, 0);
    });

    test('seeking clamps out-of-bounds indices to totalParagraphs - 1', () async {
      await controller.startPlayback(['P0', 'P1', 'P2']);

      await controller.seekParagraph(3);
      expect(controller.currentParagraphIndex, 2);

      await controller.seekParagraph(1000);
      expect(controller.currentParagraphIndex, 2);
    });

    test('navigation on empty playlist is safe and does not throw', () async {
      await controller.startPlayback([]);
      expect(controller.totalParagraphs, 0);
      expect(controller.currentParagraphIndex, 0);

      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 0);

      await controller.prevParagraph();
      expect(controller.currentParagraphIndex, 0);

      await controller.seekParagraph(5);
      expect(controller.currentParagraphIndex, 0);
    });
  });
}
