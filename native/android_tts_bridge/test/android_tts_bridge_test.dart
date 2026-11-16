import 'package:android_tts_bridge/android_tts_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AndroidTtsBridge Unit Tests', () {
    late AndroidTtsBridge bridge;
    final List<MethodCall> methodCalls = [];

    setUp(() {
      methodCalls.clear();
      bridge = AndroidTtsBridge();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.methodChannelName),
        (MethodCall call) async {
          methodCalls.add(call);
          switch (call.method) {
            case 'detectInstalledEngines':
              return ['com.k2fsa.sherpa.onnx.tts.engine'];
            case 'isEngineInstalled':
              return true;
            case 'initEngine':
              return {'success': true, 'engine': 'com.k2fsa.sherpa.onnx.tts.engine'};
            case 'getAvailableVoices':
              return [
                {
                  'name': 'pt_BR-kokoro-braseiro-neural',
                  'locale': 'pt-BR',
                  'quality': 400,
                  'latency': 200,
                  'requiresNetwork': false,
                },
                {
                  'name': 'pt_BR-kokoro-clara',
                  'locale': 'pt-BR',
                  'quality': 400,
                  'latency': 200,
                  'requiresNetwork': false,
                }
              ];
            case 'setVoice':
              final name = call.arguments['voiceName'] as String?;
              if (name == 'pt_BR-kokoro-braseiro-neural' || name == 'pt_BR-kokoro-clara') {
                return true;
              }
              throw PlatformException(code: 'INVALID_VOICE', message: 'Voice not supported');
            case 'setSpeed':
              return true;
            case 'speakChunk':
              return true;
            case 'stop':
            case 'shutdown':
              return null;
            default:
              return null;
          }
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.methodChannelName),
        null,
      );
    });

    test('detectInstalledEngines invokes native method channel', () async {
      final engines = await bridge.detectInstalledEngines();
      expect(engines, contains('com.k2fsa.sherpa.onnx.tts.engine'));
      expect(methodCalls.last.method, 'detectInstalledEngines');
    });

    test('initEngine passes engine package and returns true', () async {
      final success = await bridge.initEngine(enginePackage: 'com.k2fsa.sherpa.onnx.tts.engine');
      expect(success, isTrue);
      expect(methodCalls.last.method, 'initEngine');
      expect(methodCalls.last.arguments['enginePackage'], 'com.k2fsa.sherpa.onnx.tts.engine');
    });

    test('getAvailableVoices parses native voice list correctly', () async {
      final voices = await bridge.getAvailableVoices();
      expect(voices.length, 2);
      expect(voices[0].name, 'pt_BR-kokoro-braseiro-neural');
      expect(voices[0].locale, 'pt-BR');
      expect(voices[0].requiresNetwork, isFalse);
    });

    test('setVoice succeeds for valid voice and rejects empty voice', () async {
      final success = await bridge.setVoice('pt_BR-kokoro-braseiro-neural');
      expect(success, isTrue);
      expect(methodCalls.last.arguments['voiceName'], 'pt_BR-kokoro-braseiro-neural');

      expect(() => bridge.setVoice(''), throwsArgumentError);
    });

    test('setSpeed validates [0.65, 1.50] and snaps to 0.05 step', () async {
      await bridge.setSpeed(0.65);
      expect(methodCalls.last.arguments['speed'], 0.65);

      await bridge.setSpeed(1.24);
      expect(methodCalls.last.arguments['speed'], 1.25);

      await bridge.setSpeed(0.72);
      expect(methodCalls.last.arguments['speed'], 0.70);

      expect(() => bridge.setSpeed(0.60), throwsRangeError);
      expect(() => bridge.setSpeed(1.55), throwsRangeError);
    });

    test('speakChunk serializes chunkId, text and speed parameters', () async {
      await bridge.speakChunk(
        chunkId: 'chk-001',
        text: 'Texto pericial forense.',
        speed: 1.15,
        queue: true,
      );
      final call = methodCalls.last;
      expect(call.method, 'speakChunk');
      expect(call.arguments['chunkId'], 'chk-001');
      expect(call.arguments['text'], 'Texto pericial forense.');
      expect(call.arguments['speed'], 1.15);
      expect(call.arguments['queue'], isTrue);
    });

    test('stop and shutdown invoke proper methods', () async {
      await bridge.stop();
      expect(methodCalls.last.method, 'stop');

      await bridge.shutdown();
      expect(methodCalls.last.method, 'shutdown');
    });
  });
}
