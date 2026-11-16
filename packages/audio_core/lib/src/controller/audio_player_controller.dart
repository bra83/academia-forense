import 'dart:async';
import 'package:persistence_core/daos/audio_dao.dart';
import '../chunker/sentence_segmenter.dart';
import '../engines/motor_a_kokoro.dart';
import '../engines/motor_b_gemini.dart';

/// Available speech synthesis engines (§11.1).
enum AudioEngine {
  kokoroLocal('kokoro_local'),
  geminiOnline('gemini_online');

  final String value;
  const AudioEngine(this.value);

  static AudioEngine fromString(String val) {
    if (val == 'gemini_online' || val == 'gemini' || val == 'geminiTts') {
      return AudioEngine.geminiOnline;
    }
    return AudioEngine.kokoroLocal;
  }
}

/// Unified playback states for UI and controller (§12.5).
enum PlaybackStatus {
  idle,
  loading,
  playing,
  paused,
  stopped,
  error,
}

/// Highlight synchronization metadata (§12.6).
class HighlightState {
  final int currentParagraphIndex;
  final int totalParagraphs;
  final int currentChunkIndex;
  final int totalChunks;
  final String currentChunkText;
  final PlaybackStatus status;

  const HighlightState({
    required this.currentParagraphIndex,
    required this.totalParagraphs,
    required this.currentChunkIndex,
    required this.totalChunks,
    required this.currentChunkText,
    required this.status,
  });

  @override
  String toString() =>
      'HighlightState(para: $currentParagraphIndex/$totalParagraphs, chunk: $currentChunkIndex/$totalChunks, status: $status)';
}

/// Error report structure when an engine failure occurs (§11.1).
class AudioEngineFailure {
  final bool error;
  final String failedEngine;
  final bool silentFallbackAllowed;
  final String message;

  const AudioEngineFailure({
    this.error = true,
    required this.failedEngine,
    this.silentFallbackAllowed = false,
    required this.message,
  });

  Map<String, dynamic> toMap() => {
        'error': error,
        'failed_engine': failedEngine,
        'silent_fallback_allowed': silentFallbackAllowed,
        'message': message,
      };
}

/// Abstract contract for audio playback subsystem.
abstract class AudioCoreContract {
  AudioEngine get selectedEngine;
  PlaybackStatus get state;
  double get speed;
  int get currentParagraphIndex;
  int get totalParagraphs;
  Stream<HighlightState> get highlightStream;
  Stream<AudioEngineFailure> get failureStream;

  Future<void> startPlayback(List<String> paragraphs, {int startParagraph = 0});
  Future<void> pause();
  Future<void> resume();
  Future<void> stop();
  Future<void> nextParagraph();
  Future<void> prevParagraph();
  Future<void> seekParagraph(int index);
  void setSpeed(double newSpeed);
  void switchEngine(AudioEngine engine);
}

/// Unified controller orchestrating Motor A (Kokoro) and Motor B (Gemini Charon) (§11, §12, §13).
class AudioPlaybackController implements AudioCoreContract {
  static const double minSpeed = 0.65;
  static const double maxSpeed = 1.50;
  static const double speedStep = 0.05;
  static const double defaultSpeed = 1.00;

  AudioEngine _selectedEngine;
  PlaybackStatus _state = PlaybackStatus.idle;
  double _speed = defaultSpeed;

  int _currentParagraphIndex = 0;
  int _totalParagraphs = 0;
  int _currentChunkIndex = 0;
  int _totalChunks = 0;
  String _currentChunkText = '';

  List<String> _paragraphs = [];
  List<AudioChunk> _allChunks = [];

  final MotorAKokoroController? _motorA;
  final MotorBGeminiController? _motorB;
  final AudioDao? _audioDao;

  StreamSubscription? _motorASubscription;
  StreamSubscription? _motorBSubscription;

  final StreamController<HighlightState> _highlightController =
      StreamController<HighlightState>.broadcast(sync: true);
  final StreamController<AudioEngineFailure> _failureController =
      StreamController<AudioEngineFailure>.broadcast(sync: true);

  AudioPlaybackController({
    AudioEngine initialEngine = AudioEngine.kokoroLocal,
    MotorAKokoroController? motorA,
    MotorBGeminiController? motorB,
    AudioDao? audioDao,
  })  : _selectedEngine = initialEngine,
        _motorA = motorA,
        _motorB = motorB,
        _audioDao = audioDao {
    _initEngineSubscriptions();
  }

  @override
  AudioEngine get selectedEngine => _selectedEngine;

  @override
  PlaybackStatus get state => _state;

  @override
  double get speed => _speed;

  @override
  int get currentParagraphIndex => _currentParagraphIndex;

  @override
  int get totalParagraphs => _totalParagraphs;

  int get currentChunkIndex => _currentChunkIndex;
  int get totalChunks => _totalChunks;
  String get currentChunkText => _currentChunkText;

  @override
  Stream<HighlightState> get highlightStream => _highlightController.stream;

  @override
  Stream<AudioEngineFailure> get failureStream => _failureController.stream;

  void _initEngineSubscriptions() {
    if (_motorA != null) {
      _motorASubscription = _motorA.progressStream.listen((event) {
        if (_selectedEngine == AudioEngine.kokoroLocal) {
          _handleMotorProgress(event);
        }
      });
      _motorA.errorStream.listen((err) {
        if (_selectedEngine == AudioEngine.kokoroLocal) {
          handleEngineFailure(errorMessage: err);
        }
      });
    }

    if (_motorB != null) {
      _motorBSubscription = _motorB.progressStream.listen((event) {
        if (_selectedEngine == AudioEngine.geminiOnline) {
          _handleMotorProgress(event);
        }
      });
      _motorB.errorStream.listen((err) {
        if (_selectedEngine == AudioEngine.geminiOnline) {
          handleEngineFailure(errorMessage: err);
        }
      });
    }
  }

  void _handleMotorProgress(MotorProgressEvent event) {
    _currentChunkIndex = event.chunkIndex;
    _currentParagraphIndex = event.paragraphIndex;
    if (_allChunks.isNotEmpty && _currentChunkIndex < _allChunks.length) {
      _currentChunkText = _allChunks[_currentChunkIndex].text;
    }

    switch (event.state) {
      case MotorPlaybackState.idle:
        _state = PlaybackStatus.idle;
        break;
      case MotorPlaybackState.loading:
        _state = PlaybackStatus.loading;
        break;
      case MotorPlaybackState.playing:
        _state = PlaybackStatus.playing;
        break;
      case MotorPlaybackState.paused:
        _state = PlaybackStatus.paused;
        break;
      case MotorPlaybackState.stopped:
        _state = PlaybackStatus.stopped;
        break;
      case MotorPlaybackState.error:
        _state = PlaybackStatus.error;
        break;
    }
    _emitHighlight();
  }

  /// Sets speed enforcing range [0.65, 1.50] and snapping to 0.05 step (§12.2, §22).
  @override
  void setSpeed(double newSpeed) {
    final rounded = double.parse(newSpeed.toStringAsFixed(2));
    if (rounded < minSpeed || rounded > maxSpeed) {
      throw RangeError.value(
        newSpeed,
        'speed',
        'Speed $rounded out of bounds [$minSpeed, $maxSpeed]',
      );
    }

    final snapped = (rounded / speedStep).round() * speedStep;
    _speed = double.parse(snapped.clamp(minSpeed, maxSpeed).toStringAsFixed(2));

    _motorA?.setSpeed(_speed);
    _motorB?.setSpeed(_speed);

    _audioDao?.updateAudioSettings(playbackSpeed: _speed);
  }

  /// Sets active engine explicitly.
  @override
  void switchEngine(AudioEngine engine) {
    _selectedEngine = engine;
    _audioDao?.updateAudioSettings(preferredEngine: engine.value);
  }

  /// Starts playback given a list of paragraphs or chapter text (§12.5).
  @override
  Future<void> startPlayback(
    List<String> paragraphs, {
    int startParagraph = 0,
  }) async {
    final validParagraphs = paragraphs.where((p) => p.trim().isNotEmpty).toList();
    if (validParagraphs.isEmpty) {
      _state = PlaybackStatus.idle;
      _emitHighlight();
      return;
    }

    _paragraphs = validParagraphs;
    _totalParagraphs = validParagraphs.length;
    _currentParagraphIndex = startParagraph.clamp(0, _totalParagraphs - 1);

    // Segment each paragraph into chunks
    _allChunks = [];
    var globalChunkCounter = 0;
    for (var i = 0; i < _paragraphs.length; i++) {
      final segResult = SentenceSegmenter.segment(
        _paragraphs[i],
        paragraphIndex: i,
        idPrefix: 'p${i}_chk',
      );
      for (final chunk in segResult.chunks) {
        _allChunks.add(AudioChunk(
          id: chunk.id,
          index: globalChunkCounter++,
          paragraphIndex: i,
          text: chunk.text,
          sentenceCount: chunk.sentenceCount,
        ));
      }
    }

    _totalChunks = _allChunks.length;
    final startIndex = _allChunks.indexWhere((c) => c.paragraphIndex == _currentParagraphIndex);
    _currentChunkIndex = startIndex != -1 ? startIndex : 0;
    _currentChunkText = _allChunks.isNotEmpty ? _allChunks[_currentChunkIndex].text : '';

    _state = PlaybackStatus.playing;
    _emitHighlight();

    if (_selectedEngine == AudioEngine.kokoroLocal) {
      if (_motorA != null) {
        await _motorA.playChunks(_allChunks, startIndex: _currentChunkIndex);
      }
    } else {
      if (_motorB != null) {
        await _motorB.playChunks(_allChunks, startIndex: _currentChunkIndex);
      }
    }
  }

  @override
  Future<void> pause() async {
    if (_state == PlaybackStatus.playing || _state == PlaybackStatus.loading) {
      _state = PlaybackStatus.paused;
      if (_selectedEngine == AudioEngine.kokoroLocal) {
        await _motorA?.pause();
      } else {
        _motorB?.pause();
      }
      _emitHighlight();
    }
  }

  @override
  Future<void> resume() async {
    if (_state == PlaybackStatus.paused) {
      _state = PlaybackStatus.playing;
      if (_selectedEngine == AudioEngine.kokoroLocal) {
        await _motorA?.resume();
      } else {
        _motorB?.resume();
      }
      _emitHighlight();
    }
  }

  @override
  Future<void> stop() async {
    _state = PlaybackStatus.stopped;
    if (_selectedEngine == AudioEngine.kokoroLocal) {
      await _motorA?.stop();
    } else {
      _motorB?.stop();
    }
    _emitHighlight();
  }

  /// Advances to next paragraph with boundary clamping [0, totalParagraphs - 1].
  @override
  Future<void> nextParagraph() async {
    if (_totalParagraphs == 0) return;
    if (_currentParagraphIndex < _totalParagraphs - 1) {
      await seekParagraph(_currentParagraphIndex + 1);
    }
  }

  /// Steps back to previous paragraph with boundary clamping [0, totalParagraphs - 1].
  @override
  Future<void> prevParagraph() async {
    if (_totalParagraphs == 0) return;
    if (_currentParagraphIndex > 0) {
      await seekParagraph(_currentParagraphIndex - 1);
    }
  }

  /// Seeks to a specific paragraph index, strictly clamped within [0, totalParagraphs - 1].
  @override
  Future<void> seekParagraph(int index) async {
    if (_totalParagraphs == 0) return;
    _currentParagraphIndex = index.clamp(0, _totalParagraphs - 1);

    final targetChunk = _allChunks.indexWhere((c) => c.paragraphIndex == _currentParagraphIndex);
    if (targetChunk != -1) {
      _currentChunkIndex = targetChunk;
      _currentChunkText = _allChunks[_currentChunkIndex].text;
    }

    _emitHighlight();

    if (_selectedEngine == AudioEngine.kokoroLocal) {
      await _motorA?.seekParagraph(_currentParagraphIndex);
    } else {
      _motorB?.seekParagraph(_currentParagraphIndex);
    }
  }

  /// STRICT ANTI-SILENT-FALLBACK MANDATE (§11.1).
  ///
  /// Never fallback silently between engines.
  /// If [targetFallback] is requested without [userConfirmed], throws StateError.
  /// If confirmed, allows explicit fallback switch.
  AudioEngineFailure handleEngineFailure({
    String? errorMessage,
    AudioEngine? targetFallback,
    bool userConfirmed = false,
  }) {
    if (targetFallback != null && !userConfirmed) {
      throw StateError(
        'Silent fallback to Kokoro on Gemini TTS failure is strictly blocked without confirmation',
      );
    }

    if (targetFallback != null && userConfirmed) {
      _selectedEngine = targetFallback;
      _state = PlaybackStatus.idle;
      _emitHighlight();
      return AudioEngineFailure(
        error: false,
        failedEngine: _selectedEngine.value,
        silentFallbackAllowed: false,
        message: 'Fallback autorizado pelo usuário para ${_selectedEngine.value}.',
      );
    }

    _state = PlaybackStatus.error;
    final failure = AudioEngineFailure(
      error: true,
      failedEngine: _selectedEngine.value,
      silentFallbackAllowed: false,
      message: errorMessage ??
          'Erro na reprodução com ${_selectedEngine.value}. O motor não foi alterado silenciosamente.',
    );
    _failureController.add(failure);
    _emitHighlight();
    return failure;
  }

  void _emitHighlight() {
    _highlightController.add(HighlightState(
      currentParagraphIndex: _currentParagraphIndex,
      totalParagraphs: _totalParagraphs,
      currentChunkIndex: _currentChunkIndex,
      totalChunks: _totalChunks,
      currentChunkText: _currentChunkText,
      status: _state,
    ));
  }

  Future<void> dispose() async {
    await _motorASubscription?.cancel();
    await _motorBSubscription?.cancel();
    await _highlightController.close();
    await _failureController.close();
  }
}
