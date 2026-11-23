import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/property.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import 'auth_prompt_dialog.dart';
import 'status_badge.dart';

class PropertyCard extends ConsumerWidget {
  final Property property;
  final VoidCallback? onTap;

  const PropertyCard({super.key, required this.property, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref
        .watch(favoritesProvider)
        .maybeWhen(
          data: (list) => list.any((p) => p.id == property.id),
          orElse: () => false,
        );

    final imageUrl = property.primaryImageUrl;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/property/${property.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),

                // Deal Type Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: StatusBadge.dealType(property.dealType),
                ),

                // Featured Badge
                if (property.isFeatured)
                  Positioned(
                    top: 12,
                    right: 85,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.sh_property_featured,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                // Favorite Button
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.white.withAlpha(220),
                    shape: const CircleBorder(),
                    child: IconButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav
                            ? AppColors.error
                            : AppColors.textSecondary,
                      ),
                      onPressed: () {
                        final auth = ref.read(authProvider);
                        if (!auth.isAuthenticated) {
                          AuthPromptDialog.show(
                            context,
                            message: context.l10n.sh_auth_prompt_message,
                            redirectTo: '/property/${property.id}',
                          );
                          return;
                        }
                        favoritesNotifier.toggleFavorite(property.id);
                      },
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Text(
                    Formatters.formatCurrency(
                      property.price,
                      property.currency,
                    ),
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryInk,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Title
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${property.city} - ${property.district}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: AppColors.divider),
                  const SizedBox(height: 10),

                  // Specs (Area, Rooms, Bathrooms) as tonal chips
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildSpecChip(
                        Icons.straighten_rounded,
                        Formatters.formatArea(property.areaSqm),
                      ),
                      if (property.bedrooms > 0)
                        _buildSpecChip(
                          Icons.bed_rounded,
                          '${property.bedrooms} ${context.l10n.sh_property_rooms}',
                        ),
                      if (property.bathrooms > 0)
                        _buildSpecChip(
                          Icons.bathtub_rounded,
                          '${property.bathrooms} ${context.l10n.sh_property_bathrooms}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryInk),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 6),
            Text(
              context.l10n.sh_brand_name,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
