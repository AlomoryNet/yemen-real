import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_fonts.dart';
import '../../providers/settings_provider.dart';

/// Shows a non-critical confirmation only when Settings → Notifications is on.
///
/// Errors and required confirmations still use `ScaffoldMessenger` directly;
/// this helper is for optional success feedback the user can choose to mute.
void showOptionalFeedback(
  BuildContext context,
  WidgetRef ref,
  String message, {
  Color? backgroundColor,
}) {
  if (!context.mounted) return;
  if (!ref.read(settingsProvider).notificationsEnabled) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: AppFonts.cairo()),
      backgroundColor: backgroundColor,
    ),
  );
}
