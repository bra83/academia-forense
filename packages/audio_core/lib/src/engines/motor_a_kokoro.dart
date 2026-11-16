import 'dart:async';
import 'package:android_tts_bridge/android_tts_bridge.dart';
import '../chunker/sentence_segmenter.dart';

/// Playback state for speech motors.
enum MotorPlaybackState {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

/// Progress event emitted during motor playback.
class MotorProgressEvent {
  final String chunkId;
  final int chunkIndex;
  final int paragraphIndex;
  final int totalChunks;
  final MotorPlaybackState state;
  final Duration? latencyToFirstAudio;

  const MotorProgressEvent({
    required this.chunkId,
    required this.chunkIndex,
    required this.paragraphIndex,
    required this.totalChunks,
    required this.state,
    this.latencyToFirstAudio,
  });

  @override
  String toString() =>
      'MotorProgressEvent(chunk: $chunkIndex/$totalChunks, para: $paragraphIndex, state: $state)';
}

/// Motor A — Kokoro Braseiro local speech engine controller (§11, §12).
class MotorAKokoroController {
  final AndroidTtsBridge _bridge;

  MotorPlaybackState _state = MotorPlaybackState.idle;
  double _speed = 1.0;
  String? _selectedVoice;
  List<AudioChunk> _queue = [];
  int _currentIndex = 0;

  DateTime? _playbackStartTime;
  Duration? _timeToFirstAudio;
  bool _firstAudioReceived = false;

  StreamSubscription<TtsBridgeEvent>? _bridgeSubscription;
  final StreamController<MotorProgressEvent> _progressController =
      StreamController<MotorProgressEvent>.broadcast(sync: true);
  final StreamController<String> _errorController =
      StreamController<String>.broadcast(sync: true);

  MotorAKokoroController({AndroidTtsBridge? bridge})
      : _bridge = bridge ?? AndroidTtsBridge();

  MotorPlaybackState get state => _state;
  double get speed => _speed;
  String? get selectedVoice => _selectedVoice;
  int get currentChunkIndex => _currentIndex;
  int get totalChunks => _queue.length;
  Duration? get timeToFirstAudio => _timeToFirstAudio;
  Stream<MotorProgressEvent> get progressStream => _progressController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Initializes the local Kokoro engine via the native bridge.
  Future<bool> initialize({String? enginePackage, String? defaultVoice}) async {
    _state = MotorPlaybackState.loading;
    try {
      final success = await _bridge.initEngine(enginePackage: enginePackage);
      if (!success) {
        _state = MotorPlaybackState.error;
        _errorController.add('Failed to initialize Sherpa-ONNX Kokoro engine');
        return false;
      }

      if (defaultVoice != null) {
        await setVoice(defaultVoice);
      }

      _listenToBridgeEvents();
      _state = MotorPlaybackState.idle;
      return true;
    } catch (e) {
      _state = MotorPlaybackState.error;
      _errorController.add('Engine initialization error: $e');
      return false;
    }
  }

  void _listenToBridgeEvents() {
    _bridgeSubscription?.cancel();
    _bridgeSubscription = _bridge.events.listen(
      (event) {
        if (event is TtsStartEvent) {
          if (!_firstAudioReceived && _playbackStartTime != null) {
            _firstAudioReceived = true;
            _timeToFirstAudio = DateTime.now().difference(_playbackStartTime!);
          }
          _emitProgress();
        } else if (event is TtsDoneEvent) {
          _onChunkCompleted(event.utteranceId);
        } else if (event is TtsErrorEvent) {
          _state = MotorPlaybackState.error;
          _errorController.add('TTS error on utterance ${event.utteranceId}: code ${event.errorCode}');
          _emitProgress();
        }
      },
      onError: (err) {
        _state = MotorPlaybackState.error;
        _errorController.add('EventChannel error: $err');
        _emitProgress();
      },
    );
  }

  /// Sets playback speed within [0.65, 1.50] with 0.05 step snapping.
  Future<void> setSpeed(double newSpeed) async {
    final snapped = AndroidTtsBridge.snapSpeed(newSpeed);
    _speed = snapped;
    if (_state == MotorPlaybackState.playing || _state == MotorPlaybackState.paused) {
      await _bridge.setSpeed(_speed);
    }
  }

  /// Sets voice with strict validation.
  Future<bool> setVoice(String voiceName) async {
    final success = await _bridge.setVoice(voiceName);
    if (success) {
      _selectedVoice = voiceName;
    }
    return success;
  }

  /// Queries genuine available voices from the native engine.
  Future<List<TtsVoiceInfo>> getAvailableVoices() => _bridge.getAvailableVoices();

  /// Enqueues chunks and begins playback (§12.3, §12.4).
  Future<void> playChunks(List<AudioChunk> chunks, {int startIndex = 0}) async {
    if (chunks.isEmpty) {
      _state = MotorPlaybackState.idle;
      return;
    }

    _queue = List.unmodifiable(chunks);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _playbackStartTime = DateTime.now();
    _firstAudioReceived = false;
    _timeToFirstAudio = null;

    _state = MotorPlaybackState.playing;
    await _speakCurrentChunk();
  }

  /// Synthesizes and plays the current chunk.
  Future<void> _speakCurrentChunk() async {
    if (_currentIndex >= _queue.length) {
      _state = MotorPlaybackState.stopped;
      _emitProgress();
      return;
    }

    final chunk = _queue[_currentIndex];
    try {
      await _bridge.speakChunk(
        chunkId: chunk.id,
        text: chunk.text,
        speed: _speed,
        queue: false,
      );
    } catch (e) {
      _state = MotorPlaybackState.error;
      _errorController.add('Error speaking chunk ${chunk.id}: $e');
      _emitProgress();
    }
  }

  /// Handles completion of a chunk utterance, chaining to the next chunk (§12.3).
  Future<void> _onChunkCompleted(String utteranceId) async {
    if (_state != MotorPlaybackState.playing) return;

    if (_currentIndex < _queue.length - 1) {
      _currentIndex++;
      await _speakCurrentChunk();
    } else {
      _state = MotorPlaybackState.stopped;
      _emitProgress();
    }
  }

  /// Pauses playback.
  Future<void> pause() async {
    if (_state == MotorPlaybackState.playing) {
      await _bridge.stop();
      _state = MotorPlaybackState.paused;
      _emitProgress();
    }
  }

  /// Resumes playback from current chunk.
  Future<void> resume() async {
    if (_state == MotorPlaybackState.paused) {
      _state = MotorPlaybackState.playing;
      await _speakCurrentChunk();
    }
  }

  /// Stops playback immediately.
  Future<void> stop() async {
    await _bridge.stop();
    _state = MotorPlaybackState.stopped;
    _emitProgress();
  }

  /// Seeks to a specific chunk index.
  Future<void> seekChunk(int targetIndex) async {
    if (_queue.isEmpty) return;
    _currentIndex = targetIndex.clamp(0, _queue.length - 1);
    if (_state == MotorPlaybackState.playing) {
      await _bridge.stop();
      await _speakCurrentChunk();
    } else {
      _emitProgress();
    }
  }

  /// Seeks to the first chunk of a specific paragraph.
  Future<void> seekParagraph(int paragraphIndex) async {
    if (_queue.isEmpty) return;
    final foundIndex = _queue.indexWhere((c) => c.paragraphIndex == paragraphIndex);
    if (foundIndex != -1) {
      await seekChunk(foundIndex);
    }
  }

  void _emitProgress() {
    if (_queue.isEmpty) return;
    final chunk = _queue[_currentIndex.clamp(0, _queue.length - 1)];
    _progressController.add(MotorProgressEvent(
      chunkId: chunk.id,
      chunkIndex: _currentIndex,
      paragraphIndex: chunk.paragraphIndex,
      totalChunks: _queue.length,
      state: _state,
      latencyToFirstAudio: _timeToFirstAudio,
    ));
  }

  /// Shuts down native resources.
  Future<void> dispose() async {
    await _bridgeSubscription?.cancel();
    _bridgeSubscription = null;
    await _bridge.shutdown();
    await _progressController.close();
    await _errorController.close();
  }
}
