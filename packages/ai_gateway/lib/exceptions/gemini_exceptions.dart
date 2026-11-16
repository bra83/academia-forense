/// Base class for all Gemini API exceptions (§10.3).
abstract class GeminiApiException implements Exception {
  const GeminiApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'GeminiApiException(HTTP $statusCode): $message';
}

/// HTTP 400: Bad Request
class GeminiBadRequestException extends GeminiApiException {
  const GeminiBadRequestException(super.message) : super(statusCode: 400);
}

/// HTTP 401 / 403: Unauthorized or Forbidden / Invalid API key
class GeminiAuthException extends GeminiApiException {
  const GeminiAuthException(super.message, {super.statusCode = 401});
}

/// HTTP 404: Model or resource not found in account catalog
class GeminiNotFoundException extends GeminiApiException {
  const GeminiNotFoundException(super.message) : super(statusCode: 404);
}

/// HTTP 429: Resource Exhausted / Quota exceeded
class GeminiQuotaExceededException extends GeminiApiException {
  const GeminiQuotaExceededException(super.message) : super(statusCode: 429);
}

/// HTTP 500 / 503: Internal Server Error or Service Unavailable
class GeminiServerException extends GeminiApiException {
  const GeminiServerException(super.message, {super.statusCode = 500});
}

/// Network failure, timeout, or offline state
class GeminiNetworkException extends GeminiApiException {
  const GeminiNetworkException(super.message) : super(statusCode: 0);
}

/// Prompt injection detected / Adversarial attack defense (§9.3)
class GeminiAdversarialPromptException extends GeminiApiException {
  const GeminiAdversarialPromptException(super.message) : super(statusCode: 403);
}
