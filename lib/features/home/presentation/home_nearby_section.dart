import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../models/property.dart';
import '../../../shared/widgets/property_category_section.dart';

/// Nearby-properties section. The presentation is fully provided by
/// [PropertyCategorySection]; this wrapper only supplies the location-aware
/// wording and the nearby "view all" destination.
class HomeNearbySection extends StatelessWidget {
  const HomeNearbySection({
    super.key,
    required this.nearbyProperties,
    required this.usingFallback,
    required this.locationResolved,
  });

  final List<Property> nearbyProperties;
  final bool usingFallback;
  final bool locationResolved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final countText = usingFallback
        ? '${nearbyProperties.length} ${l10n.dash_nearby_fallback_count}'
        : '${nearbyProperties.length} ${l10n.dash_nearby_in_range_count}';

    return PropertyCategorySection(
      title: l10n.dash_nearby_title,
      subtitle: '',
      countText: countText,
      properties: nearbyProperties,
      icon: Icons.near_me_rounded,
      isLoading: !locationResolved,
      emptyMessage: l10n.dash_no_nearby_properties,
      onViewAll: () => context.push('/map', extra: true),
    );
  }
}
