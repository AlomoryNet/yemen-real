import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';

/// Shared, top-aligned card layout for the login, register and reset screens.
///
/// Keeping one scaffold makes the three auth screens use the same app-bar,
/// card, spacing and scroll behaviour. The content starts near the top instead
/// of floating in the middle of a tall screen, which also behaves better when
/// the keyboard opens.
class AuthFormScaffold extends StatelessWidget {
  const AuthFormScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.divider),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subtitle,
                      style: AppFonts.cairo(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Label above an auth input, with consistent spacing and theme colours.
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.child,
  });

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Full-width primary action. Colours and shape come from the app theme, and
/// the label is ellipsized so long localized text never overflows a button.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: onPrimary,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Full-width secondary action (demo shortcuts, alternative sign-in options).
class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 17),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single, centered text button that combines a prompt and its link.
/// Using one button instead of a cramped row of two widgets keeps Arabic and
/// English strings from squeezing into each other on narrow screens.
class AuthSwitchLink extends StatelessWidget {
  const AuthSwitchLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onPressed,
  });

  final String prompt;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: RichText(
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            style: AppFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(text: '$prompt  '),
              TextSpan(
                text: action,
                style: AppFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryInk,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AuthInfoTone { info, error, warning, success }

/// Themed info/error banner with an optional resend-style action.
class AuthInfoBanner extends StatelessWidget {
  const AuthInfoBanner({
    super.key,
    required this.message,
    required this.icon,
    this.tone = AuthInfoTone.info,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.actionLoading = false,
  });

  final String message;
  final IconData icon;
  final AuthInfoTone tone;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final bool actionLoading;

  @override
  Widget build(BuildContext context) {
    late final Color fill;
    late final Color ink;
    switch (tone) {
      case AuthInfoTone.info:
        fill = AppColors.primaryFill;
        ink = AppColors.primaryInk;
      case AuthInfoTone.error:
        fill = AppColors.errorFill;
        ink = AppColors.errorInk;
      case AuthInfoTone.warning:
        fill = AppColors.warningFill;
        ink = AppColors.warningInk;
      case AuthInfoTone.success:
        fill = AppColors.successFill;
        ink = AppColors.successInk;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ink.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: ink, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: ink,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: actionLoading ? null : onAction,
                icon: actionLoading
                    ? SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          color: ink,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(actionIcon ?? Icons.send_rounded, size: 16, color: ink),
                label: Text(
                  actionLabel!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
