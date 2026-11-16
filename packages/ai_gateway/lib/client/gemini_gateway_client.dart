import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:persistence_core/persistence_core.dart';
import '../discovery/gemini_discovery_service.dart';
import '../exceptions/gemini_exceptions.dart';
import '../models/gemini_model_info.dart';
import '../prompting/pedagogical_mode.dart';
import '../prompting/tutor_prompt_builder.dart';

/// Context chunk placeholder model for RAG integration.
class RagDocumentChunkRef {
  const RagDocumentChunkRef({
    required this.chunkId,
    required this.text,
    this.editorialStatus = 'Aprovado',
    this.volume = 1,
    this.chapter = 1,
    this.page = 1,
    this.sectionId,
  });

  final String chunkId;
  final String text;
  final String editorialStatus;
  final int volume;
  final int chapter;
  final int page;
  final String? sectionId;
}

/// Offline preserved query item (§10.3).
class OfflinePreservedQuery {
  OfflinePreservedQuery({
    required this.id,
    required this.modelId,
    required this.mode,
    required this.userQuery,
    required this.timestamp,
  });

  final String id;
  final String modelId;
  final PedagogicalMode mode;
  final String userQuery;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'modelId': modelId,
        'mode': mode.value,
        'userQuery': userQuery,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Abstract contract for Gemini AI Gateway as defined in PROJECT.md.
abstract class AiGatewayContract {
  Future<List<GeminiModelInfo>> discoverModels({required String apiKey});

  Future<String> queryTutor({
    required String apiKey,
    required String modelId,
    required PedagogicalMode mode,
    required String userQuery,
    required List<RagDocumentChunkRef> contextChunks,
    String? chapterTitle,
  });
}

/// Production implementation of AiGatewayContract (§9.3, §10.1, §10.2, §10.3).
class GeminiGatewayClient implements AiGatewayContract {
  GeminiGatewayClient({
    required SecureVaultContract secureVault,
    http.Client? client,
    GeminiModelDiscoveryService? discoveryService,
  })  : _vault = secureVault,
        _client = client ?? http.Client(),
        _discoveryService = discoveryService ?? GeminiModelDiscoveryService(client: client);

  final SecureVaultContract _vault;
  final http.Client _client;
  final GeminiModelDiscoveryService _discoveryService;

  final List<OfflinePreservedQuery> _offlineQueue = [];

  List<OfflinePreservedQuery> get offlineQueue => List.unmodifiable(_offlineQueue);

  /// Stores BYOK Gemini API key securely in vault (§10.2).
  Future<void> saveApiKey(String apiKey) async {
    final trimmed = apiKey.trim();
    if (trimmed.isEmpty) {
      throw const GeminiAuthException(
        'Gemini API error (HTTP 401: Unauthorized - API key missing or invalid)',
      );
    }
    await _vault.storeApiKey(trimmed);
  }

  /// Gets masked API key for safe UI display (e.g. AIza...489F or ***).
  Future<String> getMaskedApiKey() async {
    final key = await _vault.getApiKey();
    return SecureVaultContract.maskKey(key);
  }

  /// Discovers Gemini text models using discovery service.
  @override
  Future<List<GeminiModelInfo>> discoverModels({required String apiKey}) async {
    final catalog = await _discoveryService.discoverModels(apiKey: apiKey);
    return catalog.textTutorModels;
  }

  /// Queries the Gemini private tutor with full pedagogical prompting and RAG context chunks.
  @override
  Future<String> queryTutor({
    required String apiKey,
    required String modelId,
    required PedagogicalMode mode,
    required String userQuery,
    required List<RagDocumentChunkRef> contextChunks,
    String? chapterTitle,
  }) async {
    // 1. Validate API Key
    final trimmedKey = apiKey.trim();
    if (trimmedKey.isEmpty) {
      throw const GeminiAuthException(
        'Gemini API error (HTTP 401: Unauthorized - API key missing or invalid)',
      );
    }

    // 2. Validate user query (empty, length bounds, prompt injection)
    final validatedQuery = TutorPromptBuilder.validateAndFilterQuery(userQuery);

    // 3. Enforce text tutor model constraint: reject audio/TTS models
    if (modelId.toLowerCase().contains('audio') || modelId.toLowerCase().contains('speech')) {
      throw ArgumentError("Model '$modelId' is not a text generation model");
    }

    // 4. Construct prompt with pedagogical mode directives
    final sysPrompt = TutorPromptBuilder.buildSystemPrompt(
      mode,
      chapterTitle ?? 'Ciências Forenses',
    );

    // 5. Construct context injection from approved chunks
    final contextBuffer = StringBuffer();
    for (final chunk in contextChunks) {
      if (chunk.editorialStatus != 'Aprovado' &&
          chunk.editorialStatus != 'Publicado' &&
          chunk.editorialStatus != 'approved' &&
          chunk.editorialStatus != 'published') {
        throw ArgumentError(
          "RAG context rejected: chapter status '${chunk.editorialStatus}' is not approved for RAG (§9.2)",
        );
      }
      contextBuffer.writeln(
        '[FONTE: Vol ${chunk.volume}, Cap ${chunk.chapter}, p. ${chunk.page}] ${chunk.text}',
      );
    }

    final fullPrompt = StringBuffer();
    fullPrompt.writeln(sysPrompt);
    if (contextBuffer.isNotEmpty) {
      fullPrompt.writeln('\nContexto Aprovado da Enciclopédia:');
      fullPrompt.writeln(contextBuffer.toString());
    }
    fullPrompt.writeln('\nPergunta do Aluno: $validatedQuery');

    // 6. Execute REST call
    final cleanModel = modelId.startsWith('models/') ? modelId.substring(7) : modelId;
    final endpoint =
        'https://generativelanguage.googleapis.com/v1beta/models/$cleanModel:generateContent?key=$trimmedKey';

    final requestPayload = {
      'contents': [
        {
          'parts': [
            {'text': fullPrompt.toString()}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2, // Low temperature for high academic rigor
        'maxOutputTokens': 2048,
      }
    };

    try {
      final response = await _client.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String? ?? '';
          }
        }
        return '';
      } else if (response.statusCode == 400) {
        throw GeminiBadRequestException('Gemini API error (HTTP 400: Bad Request): ${response.body}');
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw GeminiAuthException(
          'Gemini API error (HTTP ${response.statusCode}: Unauthorized or Forbidden): ${response.body}',
          statusCode: response.statusCode,
        );
      } else if (response.statusCode == 404) {
        throw GeminiNotFoundException(
          "Gemini API error (HTTP 404: Model '$modelId' not found in account catalog)",
        );
      } else if (response.statusCode == 429) {
        throw const GeminiQuotaExceededException(
          'Gemini API error (HTTP 429: RESOURCE_EXHAUSTED - Quota exceeded for account)',
        );
      } else {
        throw GeminiServerException(
          'Gemini API error (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // Offline preservation of student query (§10.3)
      _offlineQueue.add(
        OfflinePreservedQuery(
          id: 'off_${DateTime.now().millisecondsSinceEpoch}',
          modelId: modelId,
          mode: mode,
          userQuery: validatedQuery,
          timestamp: DateTime.now(),
        ),
      );
      rethrow;
    }
  }
}
