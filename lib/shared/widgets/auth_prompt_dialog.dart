import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';

class AuthPromptDialog extends StatelessWidget {
  final String message;
  final String? redirectTo;

  const AuthPromptDialog({super.key, required this.message, this.redirectTo});

  static Future<void> show(
    BuildContext context, {
    String? message,
    String? redirectTo,
  }) {
    final resolvedMessage = message ?? context.l10n.sh_auth_prompt_message;
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
      builder: (ctx) =>
          AuthPromptDialog(message: resolvedMessage, redirectTo: redirectTo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.primaryInk,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              context.l10n.sh_auth_login_required,
              style: AppFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: AppFonts.cairo(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.sh_auth_info_note,
                    style: AppFonts.cairo(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  // Capture the router while this dialog context is valid; the
                  // pushed auth route keeps the current screen on the stack.
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  final uri = Uri(
                    path: '/login',
                    queryParameters: {
                      if (redirectTo != null) 'redirectTo': redirectTo!,
                      'reason': message,
                    },
                  );
                  router.push(uri.toString());
                },
                child: Text(
                  context.l10n.sh_login,
                  style: AppFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  final uri = Uri(
                    path: '/register',
                    queryParameters: {
                      if (redirectTo != null) 'redirectTo': redirectTo!,
                      'reason': message,
                    },
                  );
                  router.push(uri.toString());
                },
                child: Text(
                  context.l10n.sh_auth_register_new,
                  style: AppFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.sh_auth_continue_guest,
              style: AppFonts.cairo(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }
}
