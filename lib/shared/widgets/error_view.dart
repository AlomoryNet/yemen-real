import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  /// Optional context-specific headline; defaults to the generic error title.
  final String? title;

  const ErrorView({super.key, required this.message, this.onRetry, this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.errorMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? context.l10n.sh_error_unexpected,
              style: AppFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(context.l10n.sh_retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
