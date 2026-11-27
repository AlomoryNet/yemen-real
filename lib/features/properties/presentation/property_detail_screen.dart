import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_maplibre/flutter_map_maplibre.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre/maplibre.dart' as ml;
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/map_sources.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/property_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../repositories/report_repository.dart';
import '../../../services/device_location_service.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/external_contact_buttons.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/map/user_location.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../property_requests/presentation/rental_request_modal.dart';
import 'widgets/property_image_gallery.dart';
import '../../../core/l10n/app_strings.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() =>
      _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _restoreUserLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// The detail map is read-only, so just reveal the blue dot when the user
  /// already granted permission — never prompt from a passive screen.
  Future<void> _restoreUserLocation() async {
    final result = await DeviceLocationService.currentLocationIfPermitted();
    if (!mounted || !result.hasPosition) return;
    setState(() => _userLocation = result.position);
  }

  void _onUserLocated(LatLng position) {
    setState(() => _userLocation = position);
    _mapController.move(position, 15);
  }

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
                  showOptionalFeedback(
                    context,
                    ref,
                    context.l10n.detail_report_submitted,
                    backgroundColor: AppColors.success,
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
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.contentMaxWidth(context),
              ),
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
                        TextButton(
                          onPressed: () => context.go('/'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            context.l10n.detail_home,
                            style: AppFonts.cairo(
                              textStyle:
                                  Theme.of(context).textTheme.bodySmall,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        TextButton(
                          onPressed: () => context.go('/map'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            context.l10n.detail_properties,
                            style: AppFonts.cairo(
                              textStyle:
                                  Theme.of(context).textTheme.bodySmall,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Icon(
                          Directionality.of(context) == TextDirection.rtl
                              ? Icons.chevron_left
                              : Icons.chevron_right,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                        Expanded(
                          child: Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.cairo(
                              textStyle:
                                  Theme.of(context).textTheme.bodySmall,
                              color: colors.onSurface,
                              fontWeight: FontWeight.bold,
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
                                PropertyImageGallery(images: property.images),
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
                          PropertyImageGallery(images: property.images),
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

  Widget _buildActionSidebar(
    BuildContext context,
    Property property,
    bool isFav,
    FavoritesNotifier favNotifier,
  ) {
    final settings = ref.watch(settingsProvider);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priceConverted =
        property.currency.toUpperCase() != settings.currencyCode.toUpperCase();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusBadge.dealType(property.dealType),
                      if (property.isFeatured)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accentBadgeFill,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            context.l10n.sh_property_featured,
                            style: PropertyTextStyles.featuredBadge(),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: isFav
                      ? context.l10n.remove_favorite
                      : context.l10n.save_favorite,
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? colors.error : colors.onSurfaceVariant,
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
            const SizedBox(height: 12),

            // Display price in the preferred currency, with the stored amount
            // kept visible whenever a conversion is applied.
            Text(
              Formatters.formatDisplayPrice(
                property.price,
                property.currency,
                settings.currencyCode,
                settings.currencyRates,
              ),
              style: AppFonts.cairo(
                textStyle: textTheme.headlineSmall,
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (priceConverted)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  Formatters.formatCurrency(
                    property.price,
                    property.currency,
                  ),
                  style: AppFonts.cairo(
                    textStyle: textTheme.bodyMedium,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Divider(color: colors.outlineVariant),
            const SizedBox(height: 20),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: colors.primaryContainer,
                child: Icon(
                  Icons.person_outline,
                  color: colors.onPrimaryContainer,
                ),
              ),
              title: Text(
                property.owner?.fullName ?? tr.misc_verified_advertiser,
                style: AppFonts.cairo(
                  textStyle: textTheme.titleSmall,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                '${context.l10n.detail_publish_date} ${Formatters.formatDate(property.createdAt)}',
                style: AppFonts.cairo(
                  textStyle: textTheme.bodySmall,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 16),

            ExternalContactButtons(
              contactPhone: property.contactPhone,
              contactWhatsapp: property.contactWhatsapp,
              propertyTitle: property.title,
              propertyId: property.id,
            ),

            if (property.isForRent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.onAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.assignment_outlined, size: 20),
                  label: Text(
                    context.l10n.detail_send_rental_request,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(textStyle: textTheme.labelLarge),
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
                  side: BorderSide(color: colors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  Icons.description_outlined,
                  color: colors.primary,
                  size: 20,
                ),
                label: Text(
                  context.l10n.detail_contract_preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    textStyle: textTheme.labelLarge,
                    color: colors.primary,
                  ),
                ),
                onPressed: () => context.push('/contract', extra: property),
              ),
            ),

            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => _showReportDialog(context, property),
                  icon: Icon(
                    Icons.flag_outlined,
                    size: 18,
                    color: colors.error,
                  ),
                  label: Text(
                    context.l10n.detail_report_action,
                    style: AppFonts.cairo(
                      textStyle: textTheme.labelLarge,
                      color: colors.error,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showOptionalFeedback(
                      context,
                      ref,
                      context.l10n.detail_link_copied,
                    );
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  label: Text(
                    context.l10n.detail_share_ad,
                    style: AppFonts.cairo(
                      textStyle: textTheme.labelLarge,
                      color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: AppFonts.cairo(
            textStyle: textTheme.headlineSmall,
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.location_on_outlined, color: colors.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${AppConstants.getGovernorateNameAr(property.city)} - ${AppConstants.getDistrictNameAr(property.district)} ${property.addressDetails != null ? '(${property.addressDetails})' : ''}',
                style: AppFonts.cairo(
                  textStyle: textTheme.bodyLarge,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Wrap(
            spacing: 24,
            runSpacing: 20,
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

        Text(
          context.l10n.detail_description_title,
          style: AppFonts.cairo(
            textStyle: textTheme.titleLarge,
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          property.description,
          style: AppFonts.cairo(
            textStyle: textTheme.bodyLarge,
            height: 1.7,
            color: colors.onSurfaceVariant,
          ),
        ),

        _buildLocationMapSection(context, property),
      ],
    );
  }

  Widget _buildLocationMapSection(BuildContext context, Property property) {
    final coords = (property.latitude != null && property.longitude != null)
        ? (property.latitude!, property.longitude!)
        : AppConstants.getCoordinatesForGovernorate(property.city);
    final latLng = LatLng(coords.$1, coords.$2);
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: colors.secondaryContainer,
              foregroundColor: colors.onSecondaryContainer,
              child: const Icon(Icons.map_rounded, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.detail_map_section_title,
                    style: AppFonts.cairo(
                      textStyle: textTheme.titleLarge,
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${AppConstants.getGovernorateNameAr(property.city)} — ${AppConstants.getDistrictNameAr(property.district)} ${property.addressDetails != null ? '(${property.addressDetails})' : ''}',
                    style: AppFonts.cairo(
                      textStyle: textTheme.bodyMedium,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320,
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: colors.outlineVariant),
            ),
            child: Stack(
              children: [
                RepaintBoundary(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: latLng,
                      initialZoom: 14.5,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                      cameraConstraint: CameraConstraint.containLatitude(),
                    ),
                    children: [
                      MapLibreLayer(
                        style: const ml.MapStyle.url(
                          AppMapSources.openFreeMapStyleUrl,
                        ),
                        onError: (event) =>
                            debugPrint('Detail map error: ${event.message}'),
                        children: [
                          FlutterMapAdapter(
                            child: MarkerLayer(
                              markers: [
                                Marker(
                                  point: latLng,
                                  width: 140,
                                  height: 52,
                                  child: Semantics(
                                    label: Formatters.formatCurrency(
                                      property.price,
                                      property.currency,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius: BorderRadius.circular(999),
                                        border: Border.all(
                                          color: colors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: colors.onPrimary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              Formatters.formatCurrency(
                                                property.price,
                                                property.currency,
                                              ),
                                              style: AppFonts.cairo(
                                                textStyle:
                                                    textTheme.labelSmall,
                                                color: colors.onPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_userLocation != null)
                            FlutterMapAdapter(
                              child: MarkerLayer(
                                markers: [userLocationMarker(_userLocation!)],
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 72),
                        child: RichAttributionWidget(
                          alignment: AttributionAlignment.bottomRight,
                          attributions: [
                            TextSourceAttribution(
                              AppMapSources.openFreeMapAttribution,
                              onTap: () {
                                final uri = Uri.parse(
                                  AppMapSources.openFreeMapAttributionUrl,
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
                ),
                PositionedDirectional(
                  top: 12,
                  end: 12,
                  child: LocateMeButton(
                    heroTag: 'detail_locate_me',
                    onLocated: _onUserLocated,
                  ),
                ),
                PositionedDirectional(
                  start: 12,
                  end: 12,
                  bottom: 12,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: Text(
                          context.l10n.detail_open_full_map,
                          style: AppFonts.cairo(
                            textStyle: textTheme.labelLarge,
                          ),
                        ),
                        onPressed: () => context.push('/map'),
                      ),
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.directions_outlined, size: 16),
                        label: Text(
                          context.l10n.detail_directions_google_maps,
                          style: AppFonts.cairo(
                            textStyle: textTheme.labelLarge,
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
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String label, String value) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppFonts.cairo(
                    textStyle: textTheme.bodySmall,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: AppFonts.cairo(
                    textStyle: textTheme.titleSmall,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
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
