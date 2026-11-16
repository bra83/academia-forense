import '../exceptions/gemini_exceptions.dart';
import 'pedagogical_mode.dart';

/// Constructs pedagogical prompts, validates user queries and defends against prompt injections (§9.3).
class TutorPromptBuilder {
  TutorPromptBuilder._();

  static const int MAX_QUERY_LENGTH = 8192;

  static final List<RegExp> _adversarialPatterns = [
    RegExp(r'ignore previous instructions', caseSensitive: false),
    RegExp(r'você agora é dan', caseSensitive: false),
    RegExp(r'voce agora e dan', caseSensitive: false),
    RegExp(r'jailbreak', caseSensitive: false),
    RegExp(r'revele o prompt de sistema', caseSensitive: false),
    RegExp(r'system prompt leak', caseSensitive: false),
  ];

  /// Builds canonical pedagogical system prompt for a chosen mode (§9.3).
  static String buildSystemPrompt(PedagogicalMode mode, String chapterTitle) {
    final basePreamble =
        "Você é o Professor Particular de Ciências Forenses da Academia Forense. "
        "Capítulo ativo: '$chapterTitle'. "
        "Responda em português brasileiro com rigor científico, sem elogios vazios ou adivinhações. ";

    final modeDirectives = {
      PedagogicalMode.explicar:
          "Modo Explicar: Forneça ensino convencional estruturado, claro e didático.",
      PedagogicalMode.simplificar:
          "Modo Simplificar: Aborde conceitos fundamentais para iniciantes com analogias precisas.",
      PedagogicalMode.aprofundar:
          "Modo Aprofundar: Aprofunde na literatura científica pericial, normas técnicas e fórmulas. Aprofunde na fundamentação jurídica (CPP) e metodológica científica.",
      PedagogicalMode.exemplificar:
          "Modo Exemplificar: Apresente casos práticos ou cenários simulados documentados.",
      PedagogicalMode.meTestar:
          "Modo Me Testar: Faça perguntas socráticas sem revelar a resposta imediatamente. Corrija o raciocínio. Faça perguntas socráticas e avalie os raciocínios do aluno.",
      PedagogicalMode.revisar:
          "Modo Revisar: Foque em repetição direcionada dos pontos críticos e erros frequentes. Sintetize os pontos-chave e conceitos críticos.",
      PedagogicalMode.orientarLab:
          "Modo Orientar Laboratório: Guie o aluno passo a passo na execução e resolução de problemas práticos.",
    };

    return basePreamble + modeDirectives[mode]!;
  }

  /// Validates and filters user queries against empty inputs, length overflow, and adversarial injections.
  static String validateAndFilterQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Tutor query cannot be empty');
    }

    if (query.length > MAX_QUERY_LENGTH) {
      throw ArgumentError(
        'Query length ${query.length} exceeds maximum $MAX_QUERY_LENGTH characters',
      );
    }

    final lower = query.toLowerCase();
    for (final pat in _adversarialPatterns) {
      if (pat.hasMatch(lower)) {
        throw GeminiAdversarialPromptException(
          "Adversarial prompt injection pattern detected: '${pat.pattern}'",
        );
      }
    }

    return trimmed;
  }

  /// Builds full structured prompt payload including active lesson context and user query.
  static Map<String, dynamic> buildLessonTutorPayload({
    required PedagogicalMode mode,
    required String userQuery,
    required String volumeId,
    required String lessonTopic,
    required String activeStep,
  }) {
    final validatedQuery = validateAndFilterQuery(userQuery);
    final systemPrompt = buildSystemPrompt(mode, lessonTopic);
    final contextScope = 'Volume: $volumeId, Tópico: $lessonTopic, Etapa: $activeStep';

    return {
      'system_instruction': systemPrompt,
      'context_scope': contextScope,
      'user_query': validatedQuery,
      'mode': mode.value,
    };
  }
}
