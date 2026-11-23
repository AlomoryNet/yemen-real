import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/property_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/property.dart';

/// Area / bedrooms / bathrooms chips shared by all property card layouts.
///
/// Replaces the three private implementations previously living in the
/// dashboard card, the map selected card and the map cluster tile.
class PropertySpecChips extends StatelessWidget {
  final Property property;
  final bool compact;

  const PropertySpecChips({
    super.key,
    required this.property,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 4 : 6,
      runSpacing: compact ? 4 : 6,
      children: [
        _chip(
          icon: Icons.straighten_rounded,
          label: Formatters.formatArea(property.areaSqm),
        ),
        if (property.bedrooms > 0)
          _chip(
            icon: Icons.bed_rounded,
            label: '${property.bedrooms} ${context.l10n.sh_property_rooms}',
          ),
        if (property.bathrooms > 0)
          _chip(
            icon: Icons.bathtub_rounded,
            label: '${property.bathrooms} ${context.l10n.sh_property_bathrooms}',
          ),
      ],
    );
  }

  Widget _chip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: AppColors.primaryInk),
          SizedBox(width: compact ? 3 : 5),
          Text(label, style: PropertyTextStyles.chip(size: compact ? 10.5 : 11.5)),
        ],
      ),
    );
  }
}
