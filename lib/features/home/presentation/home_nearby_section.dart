import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/property.dart';
import '../../../shared/widgets/property_card.dart';

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
    final shown = nearbyProperties.take(4).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    // On the very first frame MediaQuery width can be 0 (before viewport
    // metrics arrive); clamp so SizedBox never gets a negative width.
    final double cardWidth = screenWidth < 768
        ? (screenWidth - 68).clamp(0.0, double.infinity)
        : 240;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.near_me_rounded,
                    color: AppColors.primaryInk, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.dash_nearby_title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      usingFallback
                          ? '${nearbyProperties.length} ${context.l10n.dash_nearby_fallback_count}'
                          : '${nearbyProperties.length} ${context.l10n.dash_nearby_in_range_count}',
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () => context.push('/map', extra: true),
                icon: const Icon(Icons.map_rounded, size: 17),
                label: Text(context.l10n.dash_view_all),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!locationResolved)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (shown.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  context.l10n.dash_no_nearby_properties,
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: shown
                    .map((property) => SizedBox(
                          width: cardWidth,
                          child: PropertyCard(property: property),
                        ))
                    .toList(),
              ),
        ],
      ),
    );
  }
}