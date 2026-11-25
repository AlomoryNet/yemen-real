import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';

/// Compact, theme-aware FAB for the primary "Add property" action.
/// Used on Home and in the map's list view (never over the map itself).
class AddPropertyFab extends StatelessWidget {
  const AddPropertyFab({
    Key? key,
    this.heroTag = 'add_property_fab',
    this.tooltip,
  }) : super(key: key ?? const ValueKey('add_property_fab'));

  final String heroTag;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 4,
      tooltip: tooltip ?? context.l10n.title_add_property,
      onPressed: () => context.push('/add-property'),
      child: const Icon(Icons.add_home_outlined, size: 20),
    );
  }
}
