/// Result of platform memory and environment budget evaluation (§14.2).
class LabPlatformBudgetDecision {
  final bool canRun;
  final String reason;

  const LabPlatformBudgetDecision({
    required this.canRun,
    required this.reason,
  });

  @override
  String toString() => 'LabPlatformBudgetDecision(canRun: $canRun, reason: "$reason")';
}

/// Enforces platform budget isolation: 32MB Android limit vs full Windows Python execution (§14.2).
class PlatformLabRunner {
  /// Maximum payload memory allowed on Android: exactly 32 MB = 33,554,432 bytes.
  static const int androidMaxMemoryBytes = 32 * 1024 * 1024; // 33554432

  /// Alias for backward compatibility with Python test names.
  static const int ANDROID_MAX_MEMORY_BYTES = androidMaxMemoryBytes;

  /// Evaluates whether a lab execution is authorized on the given platform.
  static LabPlatformBudgetDecision canRunOnPlatform({
    required String platform,
    required int payloadSizeBytes,
    bool requiresPandas = false,
  }) {
    final cleanPlatform = platform.trim().toLowerCase();

    if (cleanPlatform == 'android') {
      if (requiresPandas) {
        return const LabPlatformBudgetDecision(
          canRun: false,
          reason: 'Laboratório requer ambiente Python/Pandas completo disponível no Windows',
        );
      }
      if (payloadSizeBytes > androidMaxMemoryBytes) {
        return LabPlatformBudgetDecision(
          canRun: false,
          reason: 'Tamanho ($payloadSizeBytes B) excede o orçamento de 32MB do Android',
        );
      }
      return const LabPlatformBudgetDecision(
        canRun: true,
        reason: 'Execução autorizada no Android',
      );
    } else if (cleanPlatform == 'windows') {
      return const LabPlatformBudgetDecision(
        canRun: true,
        reason: 'Execução autorizada no Windows',
      );
    } else if (cleanPlatform == 'linux' || cleanPlatform == 'macos') {
      return LabPlatformBudgetDecision(
        canRun: true,
        reason: 'Execução autorizada no $platform',
      );
    }

    return LabPlatformBudgetDecision(
      canRun: false,
      reason: 'Plataforma desconhecida: $platform',
    );
  }
}
