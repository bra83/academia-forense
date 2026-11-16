import 'package:audio_core/audio_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AudioPlaybackController Unit Tests (§11.1, §12.5, §22)', () {
    late AudioPlaybackController controller;

    setUp(() {
      controller = AudioPlaybackController(initialEngine: AudioEngine.kokoroLocal);
    });

    tearDown(() async {
      await controller.dispose();
    });

    test('initial state and speed defaults', () {
      expect(controller.selectedEngine, AudioEngine.kokoroLocal);
      expect(controller.state, PlaybackStatus.idle);
      expect(controller.speed, 1.00);
      expect(controller.currentParagraphIndex, 0);
      expect(controller.totalParagraphs, 0);
    });

    test('playback speed bounds strictly enforced [0.65, 1.50]', () {
      controller.setSpeed(0.65);
      expect(controller.speed, 0.65);

      controller.setSpeed(1.50);
      expect(controller.speed, 1.50);

      // Lower bound violations
      expect(() => controller.setSpeed(0.64), throwsRangeError);
      expect(() => controller.setSpeed(0.0), throwsRangeError);
      expect(() => controller.setSpeed(-1.0), throwsRangeError);

      // Upper bound violations
      expect(() => controller.setSpeed(1.51), throwsRangeError);
      expect(() => controller.setSpeed(2.0), throwsRangeError);
      expect(() => controller.setSpeed(10.0), throwsRangeError);
    });

    test('speed snaps to nearest 0.05 step (§12.2)', () {
      controller.setSpeed(0.72);
      expect(controller.speed, 0.70);

      controller.setSpeed(0.73);
      expect(controller.speed, 0.75);

      controller.setSpeed(1.24);
      expect(controller.speed, 1.25);

      controller.setSpeed(1.48);
      expect(controller.speed, 1.50);
    });

    test('playback state transitions: idle -> playing -> paused -> playing -> stopped', () async {
      expect(controller.state, PlaybackStatus.idle);

      final paragraphs = [
        'Primeiro parágrafo de introdução pericial.',
        'Segundo parágrafo detalhando análise do vestígio.',
      ];

      await controller.startPlayback(paragraphs);
      expect(controller.state, PlaybackStatus.playing);
      expect(controller.totalParagraphs, 2);
      expect(controller.currentParagraphIndex, 0);

      await controller.pause();
      expect(controller.state, PlaybackStatus.paused);

      await controller.resume();
      expect(controller.state, PlaybackStatus.playing);

      await controller.stop();
      expect(controller.state, PlaybackStatus.stopped);
    });

    test('paragraph highlight synchronization advances and steps back', () async {
      final paragraphs = [
        'Parágrafo 0 sobre hash SHA-256 e integridade.',
        'Parágrafo 1 sobre cadeia de custódia formal.',
        'Parágrafo 2 sobre análise de memória volátil RAM.',
        'Parágrafo 3 sobre quesitos do juízo e laudo pericial.',
      ];

      final highlights = <HighlightState>[];
      final sub = controller.highlightStream.listen(highlights.add);

      await controller.startPlayback(paragraphs);
      expect(controller.currentParagraphIndex, 0);

      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 1);

      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 2);

      await controller.prevParagraph();
      expect(controller.currentParagraphIndex, 1);

      await sub.cancel();
    });

    test('paragraph boundary clamping strictly restricts to [0, totalParagraphs - 1]', () async {
      final paragraphs = [
        'Parágrafo A de dados telemáticos.',
        'Parágrafo B de triangulação ERB.',
      ];

      await controller.startPlayback(paragraphs);
      expect(controller.currentParagraphIndex, 0);

      // Stepping back at 0 remains at 0
      await controller.prevParagraph();
      expect(controller.currentParagraphIndex, 0);

      // Seeking negative clamped to 0
      await controller.seekParagraph(-5);
      expect(controller.currentParagraphIndex, 0);

      // Advancing to last
      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 1);

      // Advancing past end clamps to totalParagraphs - 1
      await controller.nextParagraph();
      expect(controller.currentParagraphIndex, 1);

      await controller.seekParagraph(999);
      expect(controller.currentParagraphIndex, 1);
    });

    test('anti-silent-fallback: engine failure leaves selected engine unchanged (§11.1)', () {
      final geminiController = AudioPlaybackController(initialEngine: AudioEngine.geminiOnline);

      final failure = geminiController.handleEngineFailure(errorMessage: 'Network timeout');
      expect(failure.error, isTrue);
      expect(failure.silentFallbackAllowed, isFalse);
      expect(failure.failedEngine, 'gemini_online');
      expect(geminiController.selectedEngine, AudioEngine.geminiOnline);
      expect(geminiController.state, PlaybackStatus.error);
    });

    test('anti-silent-fallback: fallback without user confirmation is strictly blocked (§11.1)', () {
      final geminiController = AudioPlaybackController(initialEngine: AudioEngine.geminiOnline);

      // Attempt silent fallback without confirmation must throw StateError
      expect(
        () => geminiController.handleEngineFailure(
          targetFallback: AudioEngine.kokoroLocal,
          userConfirmed: false,
        ),
        throwsStateError,
      );
      expect(geminiController.selectedEngine, AudioEngine.geminiOnline);

      // Fallback with user confirmation is allowed
      final result = geminiController.handleEngineFailure(
        targetFallback: AudioEngine.kokoroLocal,
        userConfirmed: true,
      );
      expect(result.error, isFalse);
      expect(geminiController.selectedEngine, AudioEngine.kokoroLocal);
    });
  });
}
