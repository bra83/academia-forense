import 'package:meta/meta.dart';

/// Representation of a discovered Gemini Model (§10.1).
@immutable
class GeminiModelInfo {
  const GeminiModelInfo({
    required this.name,
    this.displayName,
    this.description,
    this.supportedGenerationMethods = const [],
    this.inputTokenLimit,
  });

  final String name; // e.g. "models/gemini-1.5-pro"
  final String? displayName;
  final String? description;
  final List<String> supportedGenerationMethods;
  final int? inputTokenLimit;

  /// Short model ID without 'models/' prefix.
  String get shortId => name.startsWith('models/') ? name.substring(7) : name;

  /// Whether model supports text generation (e.g. for Tutor).
  bool get isTextModel => supportedGenerationMethods.contains('generateContent');

  /// Whether model supports audio speech synthesis (TTS).
  bool get isAudioModel =>
      supportedGenerationMethods.contains('generateSpeech') ||
      name.toLowerCase().contains('speech') ||
      name.toLowerCase().contains('tts') ||
      (description != null && description!.toLowerCase().contains('speech generation'));

  factory GeminiModelInfo.fromJson(Map<String, dynamic> json) {
    return GeminiModelInfo(
      name: json['name'] as String? ?? '',
      displayName: json['displayName'] as String?,
      description: json['description'] as String?,
      supportedGenerationMethods: (json['supportedGenerationMethods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      inputTokenLimit: json['inputTokenLimit'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (displayName != null) 'displayName': displayName,
        if (description != null) 'description': description,
        'supportedGenerationMethods': supportedGenerationMethods,
        if (inputTokenLimit != null) 'inputTokenLimit': inputTokenLimit,
      };
}

/// Catalog categorizing discovered models into text tutor and audio speech models (§10.1).
class GeminiModelCatalog {
  const GeminiModelCatalog({
    required this.textTutorModels,
    required this.audioSpeechModels,
    this.nextPageToken,
  });

  final List<GeminiModelInfo> textTutorModels;
  final List<GeminiModelInfo> audioSpeechModels;
  final String? nextPageToken;

  /// Validates that a model ID is suitable for the private tutor (must be a text generation model).
  void validateTutorModel(String modelId) {
    final cleanId = modelId.startsWith('models/') ? modelId.substring(7) : modelId;
    final found = textTutorModels.any((m) => m.shortId == cleanId || m.name == modelId);
    if (!found) {
      // Check if it exists as an audio model
      final isAudio = audioSpeechModels.any((m) => m.shortId == cleanId || m.name == modelId);
      if (isAudio) {
        throw ArgumentError("Model '$modelId' is not a text generation model");
      }
      throw LookupError("Gemini API error (HTTP 404: Model '$modelId' not found in account catalog)");
    }
  }

  /// Validates that a model ID is suitable for TTS audio generation.
  void validateTtsModel(String modelId) {
    final cleanId = modelId.startsWith('models/') ? modelId.substring(7) : modelId;
    final found = audioSpeechModels.any((m) => m.shortId == cleanId || m.name == modelId);
    if (!found) {
      throw ArgumentError("Model '$modelId' is not an audio generation model");
    }
  }
}

/// Custom LookupError for compatibility with boundary tests
class LookupError implements Exception {
  LookupError(this.message);
  final String message;
  @override
  String toString() => message;
}
