import 'dart:convert';
import 'dart:typed_data';
import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('Audio Queue & Chunker Integration Tests (§12, §13)', () {
    test('end-to-end segmentation, queue chaining, and highlight sync', () async {
      // 1. Prepare multi-paragraph forensic text
      final paragraphs = [
        'A preservação de vestígios digitais requer estrita conformidade com a ISO 27037. '
            'Qualquer quebra da cadeia de custódia acarreta nulidade processual absoluta.',
        'A extração forense em dispositivos móveis exige isolamento de sinais de rádio via caixa de Faraday. '
            'Em seguida, a imagem física bit a bit deve ser gerada com validação por hash criptográfico.',
      ];

      // 2. Prepare Mock Gemini Client
      final samplePcm = Uint8List.fromList(List.generate(20, (i) => i % 256));
      final b64 = base64Encode(samplePcm);

      final mockHttp = MockClient((request) async {
        final resp = {
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'inlineData': {
                      'mimeType': 'audio/pcm',
                      'data': b64,
                    }
                  }
                ]
              }
            }
          ]
        };
        return http.Response(jsonEncode(resp), 200);
      });

      final geminiClient = GeminiTtsClient(
        apiKey: 'valid-api-key',
        httpClient: mockHttp,
      );
      final motorB = MotorBGeminiController(client: geminiClient);

      final controller = AudioPlaybackController(
        initialEngine: AudioEngine.geminiOnline,
        motorB: motorB,
      );

      final highlightEvents = <HighlightState>[];
      final sub = controller.highlightStream.listen(highlightEvents.add);

      // 3. Start playback across paragraphs
      await controller.startPlayback(paragraphs);

      // Verify controller state
      expect(
        [PlaybackStatus.playing, PlaybackStatus.loading, PlaybackStatus.stopped],
        contains(controller.state),
      );
      expect(controller.totalParagraphs, 2);
      expect(controller.totalChunks, greaterThanOrEqualTo(2));
      expect(controller.currentParagraphIndex, inInclusiveRange(0, 1));

      // Check first chunk text exists
      expect(controller.currentChunkText, isNotEmpty);

      // 4. Seek to paragraph 0, then advance to paragraph 1
      await controller.seekParagraph(0);
      expect(controller.currentParagraphIndex, 0);

      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 1);

      // 5. Check highlight events captured
      expect(highlightEvents, isNotEmpty);
      expect(highlightEvents.any((h) => h.currentParagraphIndex == 1), isTrue);

      await sub.cancel();
      await motorB.dispose();
      await controller.dispose();
    });
  });
}
