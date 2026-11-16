import 'dart:convert';
import 'dart:typed_data';
import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('GeminiTtsPayloadBuilder Unit Tests (§13.1, §21)', () {
    test('default voice is Charon', () {
      expect(GeminiTtsPayloadBuilder.defaultVoice, 'Charon');
      expect(GeminiTtsPayloadBuilder.supportedVoices, contains('Charon'));
      expect(GeminiTtsPayloadBuilder.supportedVoices, contains('Aoede'));
      expect(GeminiTtsPayloadBuilder.supportedVoices, contains('Kore'));
      expect(GeminiTtsPayloadBuilder.supportedVoices, contains('Fenrir'));
      expect(GeminiTtsPayloadBuilder.supportedVoices, contains('Puck'));
    });

    test('builds generateContent payload correctly with Charon voice', () {
      final payload = GeminiTtsPayloadBuilder.buildGenerateContentPayload(
        text: 'Texto pericial forense',
        voiceName: 'Charon',
      );

      final contents = payload['contents'] as List;
      expect(contents.first['parts'].first['text'], 'Texto pericial forense');

      final genConfig = payload['generationConfig'] as Map;
      expect(genConfig['responseModalities'], ['AUDIO']);

      final voiceConfig = genConfig['speechConfig']['voiceConfig']['prebuiltVoiceConfig'];
      expect(voiceConfig['voiceName'], 'Charon');
    });

    test('builds standard request payload correctly with pt-BR', () {
      final req = GeminiTtsPayloadBuilder.buildRequestPayload(
        text: 'Análise de vestígio telemático',
        voiceName: 'Charon',
        sampleRate: 24000,
      );

      expect(req['input']['text'], 'Análise de vestígio telemático');
      expect(req['voice']['name'], 'Charon');
      expect(req['voice']['languageCode'], 'pt-BR');
      expect(req['audioConfig']['audioEncoding'], 'LINEAR16');
      expect(req['audioConfig']['sampleRateHertz'], 24000);
    });

    test('rejects unsupported voice names', () {
      expect(
        () => GeminiTtsPayloadBuilder.validateVoice('UnsupportedVoice999'),
        throwsArgumentError,
      );
      expect(
        () => GeminiTtsPayloadBuilder.buildGenerateContentPayload(
          text: 'teste',
          voiceName: 'fake_voice',
        ),
        throwsArgumentError,
      );
    });
  });

  group('GeminiTtsClient REST Client Tests (§13)', () {
    test('successful generateContent response synthesizes valid WAV', () async {
      final samplePcm = Uint8List.fromList([0, 0, 10, 0, 20, 0, 30, 0]);
      final b64 = base64Encode(samplePcm);

      final mockHttp = MockClient((request) async {
        expect(request.url.path, contains('generateContent'));
        expect(request.url.queryParameters['key'], 'test-api-key');

        final responseJson = {
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
        return http.Response(jsonEncode(responseJson), 200);
      });

      final client = GeminiTtsClient(
        apiKey: 'test-api-key',
        httpClient: mockHttp,
      );

      final chunk = await client.synthesize(
        chunkId: 'chk-001',
        text: 'Texto pericial',
        voiceName: 'Charon',
      );

      expect(chunk.chunkId, 'chk-001');
      expect(chunk.rawPcm.length, samplePcm.length);
      expect(chunk.wavBytes.length, 44 + samplePcm.length);
      expect(chunk.sampleRate, 24000);

      // Verify synthesized WAV header
      final wavInfo = WavHeaderBuilder.parseAndValidateWav(chunk.wavBytes);
      expect(wavInfo.sampleRate, 24000);
      expect(wavInfo.channels, 1);
      expect(wavInfo.dataSize, samplePcm.length);
    });

    test('empty API key throws GeminiAuthException (401)', () async {
      final client = GeminiTtsClient(apiKey: '');
      expect(
        () => client.synthesize(chunkId: 'chk-01', text: 'teste'),
        throwsA(isA<GeminiAuthException>().having((e) => e.statusCode, 'statusCode', 401)),
      );
    });

    test('HTTP 401/403 triggers GeminiAuthException', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": "API key not valid"}', 401);
      });
      final client = GeminiTtsClient(apiKey: 'bad-key', httpClient: mockHttp);

      expect(
        () => client.synthesize(chunkId: 'chk-01', text: 'teste'),
        throwsA(isA<GeminiAuthException>()),
      );
    });

    test('HTTP 404 triggers GeminiModelNotFoundException', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": "Model not found"}', 404);
      });
      final client = GeminiTtsClient(apiKey: 'test-key', httpClient: mockHttp);

      expect(
        () => client.synthesize(chunkId: 'chk-01', text: 'teste'),
        throwsA(isA<GeminiModelNotFoundException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('HTTP 429 triggers GeminiQuotaExceededException', () async {
      final mockHttp = MockClient((request) async {
        return http.Response('{"error": "Resource exhausted"}', 429);
      });
      final client = GeminiTtsClient(apiKey: 'test-key', httpClient: mockHttp);

      expect(
        () => client.synthesize(chunkId: 'chk-01', text: 'teste'),
        throwsA(isA<GeminiQuotaExceededException>().having((e) => e.statusCode, 'statusCode', 429)),
      );
    });

    test('empty audio response triggers GeminiTtsException', () async {
      final mockHttp = MockClient((request) async {
        return http.Response(jsonEncode({'candidates': []}), 200);
      });
      final client = GeminiTtsClient(apiKey: 'test-key', httpClient: mockHttp);

      expect(
        () => client.synthesize(chunkId: 'chk-01', text: 'teste'),
        throwsA(isA<GeminiTtsException>()),
      );
    });
  });
}
