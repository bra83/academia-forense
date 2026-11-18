import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../exceptions/gemini_exceptions.dart';
import '../models/gemini_model_info.dart';

/// Service for querying live Gemini models and categorizing text vs audio capabilities (§10.1).
class GeminiModelDiscoveryService {
  GeminiModelDiscoveryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _defaultEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models';

  /// Parses and categorizes raw API model list payload into text tutor models and audio speech models.
  static GeminiModelCatalog parseAndCategorize(Map<String, dynamic> apiResponse) {
    final rawList = apiResponse['models'] as List<dynamic>? ?? [];
    final textModels = <GeminiModelInfo>[];
    final speechModels = <GeminiModelInfo>[];

    for (final item in rawList) {
      if (item is! Map<String, dynamic>) continue;
      final model = GeminiModelInfo.fromJson(item);
      final methods = model.supportedGenerationMethods;

      // Text models support generateContent
      if (methods.contains('generateContent')) {
        textModels.add(model);
      }
      // Audio speech models support generateSpeech or contain speech in name/description
      if (methods.contains('generateSpeech') ||
          model.name.toLowerCase().contains('speech') ||
          model.name.toLowerCase().contains('tts') ||
          (model.description != null && model.description!.toLowerCase().contains('speech generation'))) {
        speechModels.add(model);
      }
    }

    final nextPageToken = apiResponse['nextPageToken'] as String?;

    return GeminiModelCatalog(
      textTutorModels: textModels,
      audioSpeechModels: speechModels,
      nextPageToken: nextPageToken,
    );
  }

  /// Discovers Gemini models from live Google Gemini REST API (§10.1).
  Future<GeminiModelCatalog> discoverModels({
    required String apiKey,
    String? pageToken,
  }) async {
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      throw const GeminiAuthException(
        'Gemini API error (HTTP 401: Unauthorized - API key missing or invalid)',
        statusCode: 401,
      );
    }

    final uri = Uri.parse(_defaultEndpoint).replace(
      queryParameters: {
        'key': trimmedKey,
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
      },
    );

    try {
      final response = await _client.get(uri);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return parseAndCategorize(decoded);
      } else if (response.statusCode == 400) {
        throw GeminiBadRequestException('Gemini API error (HTTP 400: Bad Request): ${response.body}');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw GeminiAuthException(
          'Gemini API error (HTTP ${response.statusCode}: Unauthorized or Forbidden): ${response.body}',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw GeminiNotFoundException('Gemini API error (HTTP 404: Models endpoint not found)');
      } else if (response.statusCode == 429) {
        throw const GeminiQuotaExceededException(
          'Gemini API error (HTTP 429: RESOURCE_EXHAUSTED - Quota exceeded for account)',
        );
      } else if (response.statusCode >= 500) {
        throw GeminiServerException(
          'Gemini API error (HTTP ${response.statusCode}: Server Error): ${response.body}',
          statusCode: response.statusCode,
        );
      } else {
        throw GeminiBadRequestException(
          'Gemini API error (HTTP ${response.statusCode}): ${response.body}',
        );
      }
    } on SocketException catch (e) {
      throw GeminiNetworkException(
        'Failed to reach https://ai.google.dev/api/models (No internet connection): $e',
      );
    } on http.ClientException catch (e) {
      throw GeminiNetworkException(
        'Failed to reach https://ai.google.dev/api/models (No internet connection): $e',
      );
    }
  }
}
