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
  int _session=0;
  int _utteranceCounter=0;
  String? _activeUtterance;

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
      bool success=false;
      if(enginePackage==null){
        final engines=await _bridge.detectInstalledEngines();
        for(final engine in engines){
          try{success=await _bridge.initEngine(enginePackage:engine).timeout(const Duration(seconds:18));}catch(_){success=false;}
          if(success)break;
        }
      }else{success=await _bridge.initEngine(enginePackage:enginePackage).timeout(const Duration(seconds:18));}
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
        if(_state!=MotorPlaybackState.playing||event.utteranceId!=_activeUtterance)return;
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

    _session++;
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
      final session=_session;
      final utterance='voice_${session}_${++_utteranceCounter}_${chunk.id}';
      _activeUtterance=utterance;
      final accepted=await _bridge.speakChunk(
        chunkId: utterance,
        text: chunk.text,
        speed: _speed,
        queue: false,
      );
      if(!accepted&&session==_session)throw StateError('Motor recusou a síntese');
    } catch (e) {
      _state = MotorPlaybackState.error;
      _errorController.add('Error speaking chunk ${chunk.id}: $e');
      _emitProgress();
    }
  }

  /// Handles completion of a chunk utterance, chaining to the next chunk (§12.3).
  Future<void> _onChunkCompleted(String utteranceId) async {
    if (_state != MotorPlaybackState.playing||utteranceId!=_activeUtterance) return;
    _activeUtterance=null;

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
      _activeUtterance=null;
      _state = MotorPlaybackState.paused;
      await _bridge.stop();
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
    _session++;_activeUtterance=null;
    _state = MotorPlaybackState.stopped;
    await _bridge.stop();
    _emitProgress();
  }

  /// Seeks to a specific chunk index.
  Future<void> seekChunk(int targetIndex) async {
    if (_queue.isEmpty) return;
    _currentIndex = targetIndex.clamp(0, _queue.length - 1);
    if (_state == MotorPlaybackState.playing) {
      _activeUtterance=null;
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
