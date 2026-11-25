import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../auth_prompt_dialog.dart';

/// The single auth-gated favorite control used by every property card variant.
///
/// Map/list/dashboard previously had three different heart buttons (some not
/// auth-gated). Routing them all through this widget keeps the behavior and the
/// visual treatment identical everywhere.
class FavoriteButton extends ConsumerWidget {
  final String propertyId;
  final String? redirectTo;
  final double iconSize;
  final double elevation;

  const FavoriteButton({
    super.key,
    required this.propertyId,
    this.redirectTo,
    this.iconSize = 20,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref
        .watch(favoritesProvider)
        .maybeWhen(
          data: (list) => list.any((p) => p.id == propertyId),
          orElse: () => false,
        );

    return Material(
      color: AppColors.surface.withAlpha(230),
      elevation: elevation,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: isFavorite
            ? context.l10n.remove_favorite
            : context.l10n.save_favorite,
        iconSize: iconSize,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? AppColors.error : AppColors.textSecondary,
        ),
        onPressed: () {
          final auth = ref.read(authProvider);
          if (!auth.isAuthenticated) {
            AuthPromptDialog.show(
              context,
              message: context.l10n.sh_auth_prompt_message,
              redirectTo: redirectTo ?? '/property/$propertyId',
            );
            return;
          }
          ref.read(favoritesProvider.notifier).toggleFavorite(propertyId);
        },
      ),
    );
  }
}
