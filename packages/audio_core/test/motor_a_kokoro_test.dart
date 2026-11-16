import 'package:audio_core/audio_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MotorAKokoroController Unit Tests (§11, §12)', () {
    late AndroidTtsBridge bridge;
    late MotorAKokoroController motorA;
    final List<MethodCall> calls = [];

    setUp(() {
      calls.clear();
      bridge = AndroidTtsBridge();

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.methodChannelName),
        (MethodCall call) async {
          calls.add(call);
          switch (call.method) {
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
                }
              ];
            case 'setVoice':
              return true;
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

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.eventChannelName),
        (MethodCall call) async {
          return null;
        },
      );

      motorA = MotorAKokoroController(bridge: bridge);
    });

    tearDown(() async {
      await motorA.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.methodChannelName),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel(AndroidTtsBridge.eventChannelName),
        null,
      );
    });

    test('initializes local Sherpa-ONNX engine', () async {
      final ok = await motorA.initialize(defaultVoice: 'pt_BR-kokoro-braseiro-neural');
      expect(ok, isTrue);
      expect(motorA.state, MotorPlaybackState.idle);
      expect(motorA.selectedVoice, 'pt_BR-kokoro-braseiro-neural');
    });

    test('enqueues chunks and invokes speakChunk on bridge', () async {
      await motorA.initialize();

      const text = 'Primeira frase pericial. Segunda frase pericial.';
      final result = SentenceSegmenter.segment(text);

      await motorA.playChunks(result.chunks);
      expect(motorA.state, MotorPlaybackState.playing);
      expect(motorA.totalChunks, result.chunks.length);

      final speakCall = calls.firstWhere((c) => c.method == 'speakChunk');
      expect(speakCall.arguments['chunkId'], result.firstChunk!.id);
      expect(speakCall.arguments['text'], result.firstChunk!.text);
    });

    test('pause, resume, and stop change motor state', () async {
      await motorA.initialize();

      final chunks = SentenceSegmenter.segment('Frase 1. Frase 2.').chunks;
      await motorA.playChunks(chunks);
      expect(motorA.state, MotorPlaybackState.playing);

      await motorA.pause();
      expect(motorA.state, MotorPlaybackState.paused);

      await motorA.resume();
      expect(motorA.state, MotorPlaybackState.playing);

      await motorA.stop();
      expect(motorA.state, MotorPlaybackState.stopped);
    });

    test('setSpeed validates and updates bridge speed', () async {
      await motorA.initialize();
      await motorA.setSpeed(1.24);
      expect(motorA.speed, 1.25);

      expect(() => motorA.setSpeed(0.50), throwsRangeError);
    });
  });
}
