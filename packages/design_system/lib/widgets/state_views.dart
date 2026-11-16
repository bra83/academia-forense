import 'package:flutter/material.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import 'forensic_buttons.dart';

/// Loading State View
class ForensicLoadingView extends StatelessWidget {
  const ForensicLoadingView({
    super.key,
    this.message = 'Carregando conteúdo forense...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(ForensicColors.forestGreenPrimary),
              strokeWidth: 3.0,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ForensicTypography.caption.copyWith(
                fontSize: 14,
                color: ForensicColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error State View with retry action
class ForensicErrorView extends StatelessWidget {
  const ForensicErrorView({
    super.key,
    this.title = 'Falha na Operação',
    required this.message,
    this.onRetry,
    this.retryLabel = 'Tentar novamente',
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: ForensicColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: ForensicColors.error,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ForensicTypography.sectionTitle.copyWith(
                color: ForensicColors.forestGreenDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ForensicTypography.body.copyWith(
                color: ForensicColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ForensicPrimaryButton(
                onPressed: onRetry,
                label: retryLabel,
                icon: const Icon(Icons.refresh, size: 18),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Empty State View with optional CTA
class ForensicEmptyView extends StatelessWidget {
  const ForensicEmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: ForensicColors.greenLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ForensicColors.forestGreenPrimary,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ForensicTypography.sectionTitle,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ForensicTypography.body.copyWith(
                color: ForensicColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ForensicPrimaryButton(
                onPressed: onAction,
                label: actionLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Success State View
class ForensicSuccessView extends StatelessWidget {
  const ForensicSuccessView({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: ForensicColors.successContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: ForensicColors.success,
                size: 44,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: ForensicTypography.sectionTitle.copyWith(
                color: ForensicColors.forestGreenDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: ForensicTypography.body.copyWith(
                color: ForensicColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ForensicPrimaryButton(
                onPressed: onAction,
                label: actionLabel!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
