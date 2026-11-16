import 'dart:async';
import 'package:flutter/services.dart';

/// Supported Sherpa-ONNX TTS engine package identifiers (§11, §12.1).
class SherpaOnnxPackages {
  static const String release = 'com.k2fsa.sherpa.onnx.tts.engine';
  static const String debug = 'com.k2fsa.sherpa.onnx.tts.engine.debug';

  static const List<String> supported = [release, debug];
}

/// Information about a voice reported by the native TTS engine.
class TtsVoiceInfo {
  final String name;
  final String locale;
  final int quality;
  final int latency;
  final bool requiresNetwork;

  const TtsVoiceInfo({
    required this.name,
    required this.locale,
    this.quality = 0,
    this.latency = 0,
    this.requiresNetwork = false,
  });

  factory TtsVoiceInfo.fromMap(Map<dynamic, dynamic> map) {
    return TtsVoiceInfo(
      name: map['name'] as String? ?? '',
      locale: map['locale'] as String? ?? 'pt-BR',
      quality: (map['quality'] as num?)?.toInt() ?? 0,
      latency: (map['latency'] as num?)?.toInt() ?? 0,
      requiresNetwork: map['requiresNetwork'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'locale': locale,
        'quality': quality,
        'latency': latency,
        'requiresNetwork': requiresNetwork,
      };

  @override
  String toString() => 'TtsVoiceInfo($name, $locale)';
}

/// Native TTS playback event emitted through EventChannel.
abstract class TtsBridgeEvent {
  final String utteranceId;
  const TtsBridgeEvent(this.utteranceId);
}

class TtsStartEvent extends TtsBridgeEvent {
  const TtsStartEvent(super.utteranceId);
}

class TtsDoneEvent extends TtsBridgeEvent {
  const TtsDoneEvent(super.utteranceId);
}

class TtsErrorEvent extends TtsBridgeEvent {
  final int errorCode;
  const TtsErrorEvent(super.utteranceId, this.errorCode);
}

/// Android Native TTS Bridge interface and implementation.
class AndroidTtsBridge {
  static const String methodChannelName = 'com.academia_forense/tts_bridge/methods';
  static const String eventChannelName = 'com.academia_forense/tts_bridge/events';

  static const double minSpeed = 0.65;
  static const double maxSpeed = 1.50;
  static const double speedStep = 0.05;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<TtsBridgeEvent>? _eventStream;

  AndroidTtsBridge({
    MethodChannel? methodChannel,
    EventChannel? eventChannel,
  })  : _methodChannel = methodChannel ?? const MethodChannel(methodChannelName),
        _eventChannel = eventChannel ?? const EventChannel(eventChannelName);

  /// Stream of playback progress events (start, done, error).
  Stream<TtsBridgeEvent> get events {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map<TtsBridgeEvent>((dynamic raw) {
      if (raw is Map) {
        final event = raw['event'] as String?;
        final utteranceId = raw['utteranceId'] as String? ?? '';
        final errorCode = (raw['errorCode'] as num?)?.toInt() ?? -1;

        switch (event) {
          case 'start':
            return TtsStartEvent(utteranceId);
          case 'done':
            return TtsDoneEvent(utteranceId);
          case 'error':
            return TtsErrorEvent(utteranceId, errorCode);
        }
      }
      return TtsErrorEvent('unknown', -1);
    });
    return _eventStream!;
  }

  /// Queries PackageManager for installed Sherpa-ONNX engines.
  Future<List<String>> detectInstalledEngines() async {
    final result = await _methodChannel.invokeListMethod<String>('detectInstalledEngines');
    return result ?? [];
  }

  /// Checks if either release or debug Sherpa-ONNX engine is installed.
  Future<bool> isSherpaInstalled() async {
    final result = await _methodChannel.invokeMethod<bool>('isEngineInstalled');
    return result ?? false;
  }

  /// Initializes native TextToSpeech targeting Sherpa-ONNX engine.
  Future<bool> initEngine({String? enginePackage}) async {
    final result = await _methodChannel.invokeMapMethod<String, dynamic>(
      'initEngine',
      {'enginePackage': enginePackage},
    );
    return result?['success'] == true;
  }

  /// Queries genuine available voices from the initialized engine.
  Future<List<TtsVoiceInfo>> getAvailableVoices() async {
    final result = await _methodChannel.invokeListMethod<dynamic>('getAvailableVoices');
    if (result == null) return [];
    return result
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => TtsVoiceInfo.fromMap(m))
        .toList();
  }

  /// Sets voice with strict validation against genuine installed voices.
  Future<bool> setVoice(String voiceName) async {
    if (voiceName.isEmpty) {
      throw ArgumentError('Voice name cannot be empty');
    }
    final result = await _methodChannel.invokeMethod<bool>(
      'setVoice',
      {'voiceName': voiceName},
    );
    return result ?? false;
  }

  /// Sets playback speed, enforcing [0.65, 1.50] bounds.
  Future<bool> setSpeed(double speed) async {
    final snapped = snapSpeed(speed);
    final result = await _methodChannel.invokeMethod<bool>(
      'setSpeed',
      {'speed': snapped},
    );
    return result ?? false;
  }

  /// Synthesizes and plays a chunk with utterance tracking.
  Future<bool> speakChunk({
    required String chunkId,
    required String text,
    double? speed,
    bool queue = false,
  }) async {
    if (speed != null) {
      validateSpeed(speed);
    }
    final result = await _methodChannel.invokeMethod<bool>(
      'speakChunk',
      {
        'chunkId': chunkId,
        'text': text,
        'speed': speed != null ? snapSpeed(speed) : null,
        'queue': queue,
      },
    );
    return result ?? false;
  }

  /// Stops current playback immediately.
  Future<void> stop() async {
    await _methodChannel.invokeMethod<void>('stop');
  }

  /// Shuts down the TextToSpeech engine and frees native resources.
  Future<void> shutdown() async {
    await _methodChannel.invokeMethod<void>('shutdown');
  }

  /// Validates that speed falls within [0.65, 1.50].
  static double validateSpeed(double speed) {
    final rounded = double.parse(speed.toStringAsFixed(2));
    if (rounded < minSpeed || rounded > maxSpeed) {
      throw RangeError.value(speed, 'speed', 'Playback speed must be between $minSpeed and $maxSpeed');
    }
    return rounded;
  }

  /// Validates speed and snaps to the nearest 0.05 step.
  static double snapSpeed(double speed) {
    validateSpeed(speed);
    final snapped = (speed / speedStep).round() * speedStep;
    final clamped = snapped.clamp(minSpeed, maxSpeed);
    return double.parse(clamped.toStringAsFixed(2));
  }
}
