import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/property_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../repositories/report_repository.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/external_contact_buttons.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../property_requests/presentation/rental_request_modal.dart';
import '../../../core/l10n/app_strings.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  int _activeImageIndex = 0;

  void _showReportDialog(BuildContext context, Property property) {
    final reasonController = TextEditingController();
    String selectedReason = context.l10n.detail_reason_inaccurate;
    final reportReasons = [
      context.l10n.detail_reason_inaccurate,
      context.l10n.detail_reason_price,
      context.l10n.detail_reason_duplicate,
      context.l10n.detail_reason_images,
      context.l10n.detail_reason_fraud,
      context.l10n.detail_reason_other,
    ];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            context.l10n.detail_report_title,
            style: AppFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.detail_report_intro,
                style: AppFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.detail_report_reason_label,
                style: AppFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedReason,
                items: reportReasons
                    .map(
                      (r) => DropdownMenuItem(
                        value: r,
                        child: Text(r, style: AppFonts.cairo(fontSize: 13)),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedReason = val);
                },
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.detail_report_details_label,
                style: AppFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.detail_report_details_hint,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.detail_cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final authUser = ref.read(authProvider).user;
                final reportRepo = ReportRepository();
                await reportRepo.submitReport(
                  propertyId: property.id,
                  reporterId: authUser?.id,
                  reason: selectedReason,
                  details: reasonController.text.trim(),
                );
                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.detail_report_submitted,
                        style: AppFonts.cairo(),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: Text(context.l10n.detail_submit_report),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyDetailProvider(widget.propertyId));

    return Scaffold(
      appBar: AppHeader(title: context.l10n.property_details, showBack: true),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : const AppBottomNavBar(currentRoute: '/property'),
      body: AppPageBody(
        child: propertyAsync.when(
          data: (property) => _buildDetailContent(context, property),
          loading: () =>
              LoadingView(message: context.l10n.detail_loading, skeleton: true),
          error: (err, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ErrorView(
                  message: err.toString(),
                  onRetry: () =>
                      ref.refresh(propertyDetailProvider(widget.propertyId)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/map'),
                  child: Text(context.l10n.detail_browse_properties),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent(BuildContext context, Property property) {
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final isFav = ref
        .watch(favoritesProvider)
        .maybeWhen(
          data: (list) => list.any((p) => p.id == property.id),
          orElse: () => false,
        );
    final isDesktop = Responsive.isDesktop(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Navigation breadcrumb
                    Row(
                      children: [
                        InkWell(
                          onTap: () => context.go('/'),
                          child: Text(
                            context.l10n.detail_home,
                            style: AppFonts.cairo(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        InkWell(
                          onTap: () => context.go('/map'),
                          child: Text(
                            context.l10n.detail_properties,
                            style: AppFonts.cairo(
                              color: AppColors.textMuted,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          ' / ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        Expanded(
                          child: Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.cairo(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Main Layout: Split (Desktop) or Vertical (Mobile)
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildImageGallery(property),
                                const SizedBox(height: 24),
                                _buildPropertyDetails(property),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),
                          Expanded(
                            flex: 2,
                            child: _buildActionSidebar(
                              context,
                              property,
                              isFav,
                              favoritesNotifier,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImageGallery(property),
                          const SizedBox(height: 20),
                          _buildActionSidebar(
                            context,
                            property,
                            isFav,
                            favoritesNotifier,
                          ),
                          const SizedBox(height: 24),
                          _buildPropertyDetails(property),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
          const AppFooter(),
        ],
      ),
    );
  }

  Widget _buildImageGallery(Property property) {
    final images = property.images;
    final hasImages = images.isNotEmpty;

    return Column(
      children: [
        // Main Image Display
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: hasImages
                ? CachedNetworkImage(
                    imageUrl: images[_activeImageIndex].imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.surfaceVariant),
                    errorWidget: (_, __, ___) => _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // Thumbnails Strip
        if (hasImages && images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _activeImageIndex;
                return Tooltip(
                  message: '${context.l10n.detail_view_image} ${index + 1}',
                  child: InkWell(
                    onTap: () => setState(() => _activeImageIndex = index),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: images[index].imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(Icons.apartment, size: 60, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildActionSidebar(
    BuildContext context,
    Property property,
    bool isFav,
    FavoritesNotifier favNotifier,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.divider),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price & Deal badge
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusBadge.dealType(property.dealType),
                      if (property.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentBadgeFill,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            context.l10n.sh_property_featured,
                            style: PropertyTextStyles.featuredBadge(),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: isFav
                      ? context.l10n.remove_favorite
                      : context.l10n.save_favorite,
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? AppColors.error : AppColors.textSecondary,
                  ),
                  onPressed: () {
                    final auth = ref.read(authProvider);
                    if (!auth.isAuthenticated) {
                      AuthPromptDialog.show(
                        context,
                        message: context.l10n.detail_auth_prompt_message,
                        redirectTo: '/property/${property.id}',
                      );
                      return;
                    }
                    favNotifier.toggleFavorite(property.id);
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Price text
            Text(
              Formatters.formatCurrency(property.price, property.currency),
              style: AppFonts.cairo(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryInk,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.divider),
            const SizedBox(height: 16),

            // Publisher Info
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryMuted,
                  child: Icon(Icons.person, color: AppColors.primaryInk),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.owner?.fullName ?? tr.misc_verified_advertiser,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${context.l10n.detail_publish_date} ${Formatters.formatDate(property.createdAt)}',
                        style: AppFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // External Contact Buttons (WhatsApp & Phone call)
            ExternalContactButtons(
              contactPhone: property.contactPhone,
              contactWhatsapp: property.contactWhatsapp,
              propertyTitle: property.title,
              propertyId: property.id,
            ),

            // Rental Request Button (if for rent)
            if (property.isForRent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 20),
                  label: Text(
                    context.l10n.detail_send_rental_request,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    final auth = ref.read(authProvider);
                    if (!auth.isAuthenticated) {
                      AuthPromptDialog.show(
                        context,
                        message: context.l10n.detail_auth_prompt_message,
                        redirectTo: '/property/${property.id}',
                      );
                      return;
                    }
                    RentalRequestModal.show(context, property);
                  },
                ),
              ),
            ],

            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primaryInk, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  Icons.description_outlined,
                  color: AppColors.primaryInk,
                  size: 20,
                ),
                label: Text(
                  context.l10n.detail_contract_preview,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryInk,
                  ),
                ),
                onPressed: () => context.push('/contract', extra: property),
              ),
            ),

            const SizedBox(height: 16),

            // Secondary Actions (Share & Report)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _showReportDialog(context, property),
                  icon: const Icon(
                    Icons.flag_outlined,
                    size: 16,
                    color: AppColors.error,
                  ),
                  label: Text(
                    context.l10n.detail_report_action,
                    style: AppFonts.cairo(fontSize: 12, color: AppColors.error),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          context.l10n.detail_link_copied,
                          style: AppFonts.cairo(),
                        ),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(
                    context.l10n.detail_share_ad,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyDetails(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          property.title,
          style: AppFonts.cairo(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),

        // Location text
        Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primaryInk, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${AppConstants.getGovernorateNameAr(property.city)} - ${AppConstants.getDistrictNameAr(property.district)} ${property.addressDetails != null ? '(${property.addressDetails})' : ''}',
                style: AppFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Specs Grid
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 16,
            children: [
              _buildFeatureItem(
                Icons.straighten,
                context.l10n.detail_total_area,
                Formatters.formatArea(property.areaSqm),
              ),
              _buildFeatureItem(
                Icons.category_outlined,
                context.l10n.detail_property_type,
                property.propertyType?.nameAr ?? property.propertyTypeId,
              ),
              if (property.bedrooms > 0)
                _buildFeatureItem(
                  Icons.bed_outlined,
                  context.l10n.detail_bedrooms,
                  '${property.bedrooms} ${context.l10n.detail_rooms_unit}',
                ),
              if (property.bathrooms > 0)
                _buildFeatureItem(
                  Icons.bathtub_outlined,
                  context.l10n.detail_bathrooms,
                  '${property.bathrooms} ${context.l10n.detail_bathrooms_unit}',
                ),
              _buildFeatureItem(
                Icons.visibility_outlined,
                context.l10n.detail_views_label,
                '${property.viewsCount} ${context.l10n.detail_views_unit}',
              ),
              _buildFeatureItem(
                Icons.shield_outlined,
                context.l10n.detail_publishing_method,
                context.l10n.detail_self_review_published,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // Full Description
        Text(
          context.l10n.detail_description_title,
          style: AppFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          property.description,
          style: AppFonts.cairo(
            fontSize: 14,
            height: 1.8,
            color: AppColors.textSecondary,
          ),
        ),

        // Embedded Interactive Map Section
        _buildLocationMapSection(context, property),
      ],
    );
  }

  Widget _buildLocationMapSection(BuildContext context, Property property) {
    final coords = (property.latitude != null && property.longitude != null)
        ? (property.latitude!, property.longitude!)
        : AppConstants.getCoordinatesForGovernorate(property.city);

    final latLng = LatLng(coords.$1, coords.$2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.map_rounded,
                color: AppColors.primaryInk,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              context.l10n.detail_map_section_title,
              style: AppFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${AppConstants.getGovernorateNameAr(property.city)} — ${AppConstants.getDistrictNameAr(property.district)} ${property.addressDetails != null ? '(${property.addressDetails})' : ''}',
          style: AppFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 14),
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: latLng,
                  initialZoom: 14.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.yemenreal.portal',
                    maxZoom: 19,
                    errorTileCallback: (tile, error, stackTrace) {
                      debugPrint('Detail map tile failed to load: $error');
                    },
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latLng,
                        width: 140,
                        height: 52,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: AppColors.textLight,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  Formatters.formatCurrency(
                                    property.price,
                                    property.currency,
                                  ),
                                  style: const TextStyle(
                                    color: AppColors.textLight,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 64),
                    child: RichAttributionWidget(
                      alignment: AttributionAlignment.bottomRight,
                      attributions: [
                        TextSourceAttribution(
                          'Tiles © Esri — Sources: Esri, HERE, Garmin, USGS, OpenStreetMap contributors, GIS User Community',
                          onTap: () {
                            final uri = Uri.parse(
                              'https://goto.arcgisonline.com/maps/World_Street_Map',
                            );
                            canLaunchUrl(uri).then((ok) {
                              if (ok) {
                                launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Floating Buttons on Map
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.map_rounded, size: 16),
                      label: Text(
                        context.l10n.detail_open_full_map,
                        style: AppFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => context.push('/map'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: Icon(
                        Icons.directions_outlined,
                        color: AppColors.primaryInk,
                        size: 16,
                      ),
                      label: Text(
                        context.l10n.detail_directions_google_maps,
                        style: AppFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        final gmapsUri = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${coords.$1},${coords.$2}',
                        );
                        if (await canLaunchUrl(gmapsUri)) {
                          await launchUrl(
                            gmapsUri,
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    return SizedBox(
      width: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.primaryInk),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.cairo(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
