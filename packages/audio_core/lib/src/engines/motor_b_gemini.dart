import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../chunker/sentence_segmenter.dart';
import '../wav/wav_header_builder.dart';
import 'motor_a_kokoro.dart';

/// Exceptions for Gemini TTS service errors (§10, §13).
class GeminiTtsException implements Exception {
  final String message;
  final int? statusCode;
  const GeminiTtsException(this.message, [this.statusCode]);

  @override
  String toString() => 'GeminiTtsException($statusCode): $message';
}

class GeminiAuthException extends GeminiTtsException {
  const GeminiAuthException(super.message, [super.statusCode = 401]);
}

class GeminiQuotaExceededException extends GeminiTtsException {
  const GeminiQuotaExceededException(super.message, [super.statusCode = 429]);
}

class GeminiModelNotFoundException extends GeminiTtsException {
  const GeminiModelNotFoundException(super.message, [super.statusCode = 404]);
}

/// Helper that builds payloads for Gemini speech synthesis (§13.1, §21).
class GeminiTtsPayloadBuilder {
  static const String defaultVoice = 'Charon';
  static const Set<String> supportedVoices = {
    'Charon',
    'Aoede',
    'Kore',
    'Fenrir',
    'Puck',
  };

  /// Builds generateContent payload with AUDIO response modality and voiceConfig (§13).
  static Map<String, dynamic> buildGenerateContentPayload({
    required String text,
    String voiceName = defaultVoice,
  }) {
    validateVoice(voiceName);
    return {
      'contents': [
        {
          'parts': [
            {'text': text}
          ]
        }
      ],
      'generationConfig': {
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {
              'voiceName': voiceName,
            }
          }
        }
      }
    };
  }

  /// Builds standard TTS request payload tested in F21.
  static Map<String, dynamic> buildRequestPayload({
    required String text,
    String voiceName = defaultVoice,
    int sampleRate = 24000,
  }) {
    validateVoice(voiceName);
    return {
      'input': {'text': text},
      'voice': {
        'name': voiceName,
        'languageCode': 'pt-BR',
      },
      'audioConfig': {
        'audioEncoding': 'LINEAR16',
        'sampleRateHertz': sampleRate,
      }
    };
  }

  /// Validates voice against supported voices list.
  static void validateVoice(String voiceName) {
    if (!supportedVoices.contains(voiceName)) {
      throw ArgumentError(
        "Voice '$voiceName' is not supported by Gemini TTS. Choose from $supportedVoices",
      );
    }
  }
}

/// Represents synthesized speech audio with raw PCM and playable WAV buffers.
class GeminiSpeechChunk {
  final String chunkId;
  final int paragraphIndex;
  final Uint8List rawPcm;
  final Uint8List wavBytes;
  final int sampleRate;
  final Duration duration;

  const GeminiSpeechChunk({
    required this.chunkId,
    required this.paragraphIndex,
    required this.rawPcm,
    required this.wavBytes,
    required this.sampleRate,
    required this.duration,
  });
}

/// REST client communicating with Google Gemini speech generation API (§13).
class GeminiTtsClient {
  static const String defaultBaseUrl = 'https://generativelanguage.googleapis.com';
  static const String defaultModel = 'gemini-2.0-flash-exp';

  final http.Client _httpClient;
  final String _apiKey;
  final String _baseUrl;
  final String _model;

  GeminiTtsClient({
    required String apiKey,
    http.Client? httpClient,
    String baseUrl = defaultBaseUrl,
    String model = defaultModel,
  })  : _apiKey = apiKey,
        _httpClient = httpClient ?? http.Client(),
        _baseUrl = baseUrl,
        _model = model;

  String get model => _model;

  void close()=>_httpClient.close();

  /// Synthesizes text to speech, returning raw PCM and a strictly compliant 44-byte WAV.
  Future<GeminiSpeechChunk> synthesize({
    required String chunkId,
    required String text,
    int paragraphIndex = 0,
    String voiceName = GeminiTtsPayloadBuilder.defaultVoice,
    int sampleRate = 24000,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) {
      throw ArgumentError('Text to synthesize cannot be empty');
    }
    GeminiTtsPayloadBuilder.validateVoice(voiceName);

    if (_apiKey.isEmpty) {
      throw const GeminiAuthException('Gemini API key is empty', 401);
    }

    final uri = Uri.parse('$_baseUrl/v1beta/models/$_model:generateContent?key=$_apiKey');
    final payload = GeminiTtsPayloadBuilder.buildGenerateContentPayload(
      text: cleanText,
      voiceName: voiceName,
    );

    final http.Response response;
    try {
      response = await _httpClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      if (e is GeminiTtsException) rethrow;
      throw const GeminiTtsException('Falha de conexão com Gemini TTS.');
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      throw GeminiAuthException('Unauthorized: Invalid or expired Gemini API key', response.statusCode);
    }
    if (response.statusCode == 404) {
      throw GeminiModelNotFoundException("Model '$_model' not found on Gemini endpoint", 404);
    }
    if (response.statusCode == 429) {
      throw GeminiQuotaExceededException('Gemini API quota exceeded (HTTP 429)', 429);
    }
    if (response.statusCode != 200) {
      throw GeminiTtsException('Gemini TTS: HTTP ${response.statusCode}', response.statusCode);
    }

    final String base64Data = _extractBase64Audio(response.body);
    if (base64Data.isEmpty) {
      throw const GeminiTtsException('Empty audio payload received from Gemini TTS endpoint');
    }

    // Gemini may return either headerless PCM or a complete RIFF/WAV.
    // Never prepend a second WAV header (Android players then reject it).
    final decoded = base64Decode(base64Data);
    final isWav = decoded.length >= 44 &&
        decoded[0]==0x52 && decoded[1]==0x49 &&
        decoded[2]==0x46 && decoded[3]==0x46 &&
        decoded[8]==0x57 && decoded[9]==0x41 &&
        decoded[10]==0x56 && decoded[11]==0x45;
    final int actualSampleRate;
    final Uint8List wavBytes;
    final Uint8List rawPcm;
    if (isWav) {
      final header = WavHeaderBuilder.parseAndValidateWav(decoded);
      actualSampleRate = header.sampleRate;
      wavBytes = decoded;
      rawPcm = Uint8List.fromList(decoded.sublist(44));
    } else {
      actualSampleRate = sampleRate;
      rawPcm = decoded;
      wavBytes = WavHeaderBuilder.packagePcmToWav(
          decoded, sampleRate: sampleRate);
    }
    if(rawPcm.isEmpty)throw const GeminiTtsException(
      'O Gemini retornou áudio vazio.');

    final totalSamples = rawPcm.length ~/ 2;
    final durationSec = totalSamples / actualSampleRate;
    final duration = Duration(microseconds: (durationSec * 1000000).round());

    return GeminiSpeechChunk(
      chunkId: chunkId,
      paragraphIndex: paragraphIndex,
      rawPcm: rawPcm,
      wavBytes: wavBytes,
      sampleRate: actualSampleRate,
      duration: duration,
    );
  }

  /// Extracts base64 audio data from either generateContent or legacy TTS response formats.
  static String _extractBase64Audio(String responseBody) {
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to parse Gemini JSON response: $e');
    }

    // 1. generateContent structure: candidates[0].content.parts[0].inlineData.data
    final candidates = data['candidates'] as List<dynamic>?;
    if (candidates != null && candidates.isNotEmpty) {
      final firstCandidate = candidates.first as Map<String, dynamic>;
      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      if (parts != null && parts.isNotEmpty) {
        for (final p in parts) {
          if (p is Map<String, dynamic>) {
            final inlineData = p['inlineData'] as Map<String, dynamic>?;
            final base64String = inlineData?['data'] as String?;
            if (base64String != null && base64String.isNotEmpty) {
              return base64String;
            }
          }
        }
      }
    }

    // 2. Legacy / alternative structure: audioContent
    final audioContent = data['audioContent'] as String?;
    if (audioContent != null && audioContent.isNotEmpty) {
      return audioContent;
    }

    return '';
  }
}

/// Motor B — Gemini TTS online speech controller (§11, §13).
class MotorBGeminiController {
  final GeminiTtsClient _client;

  MotorPlaybackState _state = MotorPlaybackState.idle;
  double _speed = 1.0;
  String _selectedVoice = GeminiTtsPayloadBuilder.defaultVoice;
  List<AudioChunk> _queue = [];
  int _currentIndex = 0;

  DateTime? _playbackStartTime;
  Duration? _timeToFirstAudio;
  GeminiSpeechChunk? _lastSynthesizedChunk;

  final StreamController<MotorProgressEvent> _progressController =
      StreamController<MotorProgressEvent>.broadcast(sync: true);
  final StreamController<String> _errorController =
      StreamController<String>.broadcast(sync: true);

  MotorBGeminiController({required GeminiTtsClient client}) : _client = client;

  MotorPlaybackState get state => _state;
  double get speed => _speed;
  String get selectedVoice => _selectedVoice;
  int get currentChunkIndex => _currentIndex;
  int get totalChunks => _queue.length;
  Duration? get timeToFirstAudio => _timeToFirstAudio;
  GeminiSpeechChunk? get lastSynthesizedChunk => _lastSynthesizedChunk;
  Stream<MotorProgressEvent> get progressStream => _progressController.stream;
  Stream<String> get errorStream => _errorController.stream;

  /// Sets playback speed [0.65, 1.50] with 0.05 step snapping.
  void setSpeed(double newSpeed) {
    final rounded = double.parse(newSpeed.toStringAsFixed(2));
    if (rounded < 0.65 || rounded > 1.50) {
      throw RangeError.value(newSpeed, 'speed', 'Playback speed must be between 0.65 and 1.50');
    }
    final snapped = (rounded / 0.05).round() * 0.05;
    _speed = double.parse(snapped.clamp(0.65, 1.50).toStringAsFixed(2));
  }

  /// Sets voice with validation against supported Gemini voices.
  void setVoice(String voiceName) {
    GeminiTtsPayloadBuilder.validateVoice(voiceName);
    _selectedVoice = voiceName;
  }

  /// Enqueues chunks and begins online speech synthesis.
  Future<void> playChunks(List<AudioChunk> chunks, {int startIndex = 0}) async {
    if (chunks.isEmpty) {
      _state = MotorPlaybackState.idle;
      return;
    }

    _queue = List.unmodifiable(chunks);
    _currentIndex = startIndex.clamp(0, _queue.length - 1);
    _playbackStartTime = DateTime.now();
    _timeToFirstAudio = null;

    _state = MotorPlaybackState.playing;
    await _synthesizeAndPlayCurrentChunk();
  }

  Future<void> _synthesizeAndPlayCurrentChunk() async {
    if (_currentIndex >= _queue.length) {
      _state = MotorPlaybackState.stopped;
      _emitProgress();
      return;
    }

    final chunk = _queue[_currentIndex];
    try {
      _state = MotorPlaybackState.loading;
      _emitProgress();

      _lastSynthesizedChunk = await _client.synthesize(
        chunkId: chunk.id,
        text: chunk.text,
        paragraphIndex: chunk.paragraphIndex,
        voiceName: _selectedVoice,
      );

      if (_timeToFirstAudio == null && _playbackStartTime != null) {
        _timeToFirstAudio = DateTime.now().difference(_playbackStartTime!);
      }

      if (_state == MotorPlaybackState.paused || _state == MotorPlaybackState.stopped) {
        _emitProgress();
        return;
      }

      _state = MotorPlaybackState.playing;
      _emitProgress();

      // Chunk synthesis complete; in a real audio sink it plays result.wavBytes.
      // Chaining continues to next chunk on completion.
      if (_state == MotorPlaybackState.playing) {
        if (_currentIndex < _queue.length - 1) {
          _currentIndex++;
          await _synthesizeAndPlayCurrentChunk();
        } else {
          _state = MotorPlaybackState.stopped;
          _emitProgress();
        }
      }
    } catch (e) {
      _state = MotorPlaybackState.error;
      _errorController.add('Gemini synthesis failed: $e');
      _emitProgress();
    }
  }

  void pause() {
    if (_state == MotorPlaybackState.playing || _state == MotorPlaybackState.loading) {
      _state = MotorPlaybackState.paused;
      _emitProgress();
    }
  }

  void resume() {
    if (_state == MotorPlaybackState.paused) {
      _state = MotorPlaybackState.playing;
      _synthesizeAndPlayCurrentChunk();
    }
  }

  void stop() {
    _state = MotorPlaybackState.stopped;
    _emitProgress();
  }

  void seekChunk(int targetIndex) {
    if (_queue.isEmpty) return;
    _currentIndex = targetIndex.clamp(0, _queue.length - 1);
    if (_state == MotorPlaybackState.playing) {
      _synthesizeAndPlayCurrentChunk();
    } else {
      _emitProgress();
    }
  }

  void seekParagraph(int paragraphIndex) {
    if (_queue.isEmpty) return;
    final foundIndex = _queue.indexWhere((c) => c.paragraphIndex == paragraphIndex);
    if (foundIndex != -1) {
      seekChunk(foundIndex);
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

  Future<void> dispose() async {
    await _progressController.close();
    await _errorController.close();
  }
}
