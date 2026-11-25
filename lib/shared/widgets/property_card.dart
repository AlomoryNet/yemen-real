import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/property_text_styles.dart';
import '../../core/utils/formatters.dart';
import '../../models/property.dart';
import '../../providers/settings_provider.dart';
import 'property/favorite_button.dart';
import 'property/property_image.dart';
import 'property/property_spec_chips.dart';
import 'status_badge.dart';

/// Visual variants of the one property card design.
///
/// All variants share the same tokens, content order and sub-widgets; only the
/// arrangement and density change. Use [grid] for dashboards/favorites, [row]
/// for dense lists, [overlay] for the floating map card and [management] for
/// owner/admin listings.
enum PropertyCardLayout { grid, row, overlay, management }

/// Canonical property card used on every surface of the app.
class PropertyCard extends ConsumerWidget {
  final Property property;
  final PropertyCardLayout layout;
  final VoidCallback? onTap;

  /// Trailing control (chevron, overflow menu, …).
  final Widget? trailing;

  /// Extra content below the specs (owner/views/date, GPS accuracy, …).
  final Widget? footer;

  /// Quick action buttons (call, WhatsApp, directions) for [layout] overlay.
  final List<Widget>? actions;

  /// Full-width secondary action for [layout] overlay.
  final Widget? secondaryAction;

  /// Confirmation caption under the price on the floating map card.
  final Widget? priceCaption;

  /// Location-accuracy row used instead of the plain location line in overlay.
  final Widget? locationDetail;

  /// Additional pills shown next to the deal badge (e.g. discount pill).
  final List<Widget>? extraBadges;

  /// Carousel source for [layout] overlay. Falls back to a single image.
  final List<String>? imageUrls;
  final int? activeImageIndex;
  final ValueChanged<int>? onImageIndexChanged;
  final VoidCallback? onClose;

  final double? imageHeight;
  final bool selected;

  /// `null` = sensible default for the layout (see [showFavoriteByDefault]).
  final bool? showFavorite;
  final bool? showStatus;

  const PropertyCard({
    super.key,
    required this.property,
    this.layout = PropertyCardLayout.grid,
    this.onTap,
    this.trailing,
    this.footer,
    this.actions,
    this.secondaryAction,
    this.priceCaption,
    this.locationDetail,
    this.extraBadges,
    this.imageUrls,
    this.activeImageIndex,
    this.onImageIndexChanged,
    this.onClose,
    this.imageHeight,
    this.selected = false,
    this.showFavorite,
    this.showStatus,
  });

  bool get _favoriteVisible =>
      showFavorite ??
      (layout == PropertyCardLayout.grid ||
          layout == PropertyCardLayout.overlay);

  bool get _statusVisible =>
      showStatus ?? (layout == PropertyCardLayout.management);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = switch (layout) {
      PropertyCardLayout.grid => _buildGrid(context, ref),
      PropertyCardLayout.row => _buildRow(context, ref),
      PropertyCardLayout.overlay => _buildOverlay(context, ref),
      PropertyCardLayout.management => _buildManagement(context, ref),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: selected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap ?? () => context.push('/property/${property.id}'),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layouts
  // ---------------------------------------------------------------------------

  Widget _buildGrid(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              // Cap decode size: the first dashboard frame builds up to 16
              // cards, so full-resolution network images are unnecessary.
              child: PropertyImage(
                imageUrl: property.primaryImageUrl,
                memCacheWidth: 800,
              ),
            ),
            PositionedDirectional(top: 12, start: 12, child: _badges(context)),
            if (_favoriteVisible)
              PositionedDirectional(
                top: 8,
                end: 8,
                child: _FavoriteSlot(propertyId: property.id),
              ),
          ],
        ),
        _contentGrid(ref),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: footer!,
          ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 92,
              height: 92,
              child: PropertyImage(
                imageUrl: property.primaryImageUrl,
                memCacheWidth: 184,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _badges(context),
                const SizedBox(height: 4),
                _price(size: 15, ref: ref),
                const SizedBox(height: 2),
                _title(maxLines: 2, size: 13),
                const SizedBox(height: 4),
                _location(size: 11),
                const SizedBox(height: 6),
                PropertySpecChips(property: property, compact: true),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context, WidgetRef ref) {
    final images = imageUrls ?? const <String>[];
    final image = images.length > 1
        ? PropertyImageCarousel(
            imageUrls: images,
            height: imageHeight ?? 155,
            initialIndex: activeImageIndex ?? 0,
            onIndexChanged: onImageIndexChanged,
            topStart: _badges(context),
            topEnd: _imageTopEnd(context),
          )
        : Stack(
            children: [
              SizedBox(
                height: imageHeight ?? 155,
                width: double.infinity,
                child: PropertyImage(
                  imageUrl:
                      property.primaryImageUrl ??
                      (images.isEmpty ? null : images.first),
                  memCacheWidth: 800,
                ),
              ),
              PositionedDirectional(
                top: 10,
                start: 10,
                child: _badges(context),
              ),
              PositionedDirectional(
                top: 10,
                end: 10,
                child: _imageTopEnd(context),
              ),
            ],
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [image, _contentOverlay(ref)],
    );
  }

  Widget _buildManagement(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: PropertyImage(
                imageUrl: property.primaryImageUrl,
                memCacheWidth: 800,
              ),
            ),
            PositionedDirectional(top: 10, start: 10, child: _badges(context)),
          ],
        ),
        _contentManagement(ref),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: footer!,
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared fragments
  // ---------------------------------------------------------------------------

  Widget _imageTopEnd(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onClose != null) _closeButton(context),
        if (_favoriteVisible) ...[
          const SizedBox(width: 6),
          _FavoriteSlot(propertyId: property.id),
        ],
      ],
    );
  }

  Widget _closeButton(BuildContext context) {
    return Tooltip(
      message: context.l10n.close,
      child: Material(
        color: AppColors.surface.withAlpha(230),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onClose,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(Icons.close, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _badges(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        StatusBadge.dealType(property.dealType),
        if (_statusVisible) StatusBadge.propertyStatus(property.status),
        if (property.isFeatured) _featuredBadge(context),
        if (extraBadges != null) ...extraBadges!,
      ],
    );
  }

  Widget _featuredBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        context.l10n.sh_property_featured,
        style: PropertyTextStyles.badgeOnAccent(),
      ),
    );
  }

  Widget _price({double size = 18, required WidgetRef ref}) => Text(
    Formatters.formatCurrencyPreferred(
      property.price,
      ref.watch(settingsProvider).currencyCode,
    ),
    style: PropertyTextStyles.price(size: size),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );

  Widget _title({int maxLines = 2, double size = 14}) => Text(
    property.title,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    style: PropertyTextStyles.title(size: size),
  );

  Widget _location({double size = 12}) => Row(
    children: [
      Icon(
        Icons.location_on_outlined,
        size: size + 3,
        color: AppColors.textMuted,
      ),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          '${AppConstants.getGovernorateNameAr(property.city)} - '
          '${AppConstants.getDistrictNameAr(property.district)}',
          style: PropertyTextStyles.meta(size: size),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );

  Widget _contentGrid(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _price(ref: ref),
          const SizedBox(height: 4),
          _title(),
          const SizedBox(height: 8),
          _location(),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          PropertySpecChips(property: property),
        ],
      ),
    );
  }

  Widget _contentOverlay(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _price(ref: ref),
                    if (priceCaption != null) ...[
                      const SizedBox(height: 2),
                      priceCaption!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          _title(maxLines: 2, size: 13),
          const SizedBox(height: 4),
          if (locationDetail != null) ...[
            locationDetail!,
            const SizedBox(height: 6),
          ] else
            _location(size: 11),
          const SizedBox(height: 8),
          PropertySpecChips(property: property, compact: true),
          if (footer != null) ...[const SizedBox(height: 8), footer!],
          if (actions != null) ...[
            const SizedBox(height: 10),
            Row(children: actions!),
          ],
          if (secondaryAction != null) ...[
            const SizedBox(height: 8),
            secondaryAction!,
          ],
        ],
      ),
    );
  }

  Widget _contentManagement(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _price(ref: ref)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 4),
          _title(),
          const SizedBox(height: 8),
          _location(),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          PropertySpecChips(property: property),
        ],
      ),
    );
  }
}

class _FavoriteSlot extends StatelessWidget {
  final String propertyId;

  const _FavoriteSlot({required this.propertyId});

  @override
  Widget build(BuildContext context) => FavoriteButton(propertyId: propertyId);
}
