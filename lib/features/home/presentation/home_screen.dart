import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/dashboard_filter_provider.dart';
import '../../../providers/home_nearby_properties_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/device_location_service.dart';
import '../../../shared/widgets/add_property_fab.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/property_category_section.dart';
import '../../../shared/widgets/property_filter_sheet.dart';
import '../../map/presentation/map_screen_args.dart';
import 'home_hero_section.dart';
import 'home_nearby_section.dart';
import 'home_publisher_cta.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Filter selections live in dashboardFilterProvider; the location-first
  // centre and the nearby listing cache live in providers so they survive
  // rebuilds without rescanning the whole catalogue in `build`.

  @override
  void initState() {
    super.initState();
    // A post-frame callback can run after a hot restart has already disposed
    // this State. Capture the notifiers via `ref.read` here (safe in initState)
    // instead of touching `ref` or inherited widgets after the async gaps.
    final settingsNotifier = ref.read(settingsProvider.notifier);
    final settings = ref.read(settingsProvider);
    final centerNotifier = ref.read(homeCenterProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationOnFirstRun(settings, settingsNotifier, centerNotifier);
    });
  }

  /// Ask once on the first dashboard visit. If the user denies it, Settings
  /// keeps an explicit retry action — we never nag on every rebuild.
  Future<void> _requestLocationOnFirstRun(
    SettingsState settings,
    SettingsNotifier settingsNotifier,
    StateController<latlong.LatLng> centerNotifier,
  ) async {
    if (!mounted) return;
    // A denial is still a completed first-run prompt — Settings owns retry.
    if (settings.locationPromptShown) return;

    // Ask first, then persist the "shown" flag: no SharedPreferences write
    // competes with the OS permission dialog or the first frame.
    final result = await DeviceLocationService.requestLocation();
    await settingsNotifier.markLocationPromptShown();
    if (!result.granted || result.position == null) return;
    await settingsNotifier.setLocation(
      result.position!.latitude,
      result.position!.longitude,
    );
    if (!mounted) return;
    centerNotifier.state = result.position!;
  }

  void _onSearchSubmit() {
    final dashboardFilter = ref.read(dashboardFilterProvider);
    final dashboardNotifier = ref.read(dashboardFilterProvider.notifier);
    final searchNotifier = ref.read(propertyFilterProvider.notifier);
    final query = dashboardNotifier.searchController.text.trim();

    searchNotifier.resetFilters();
    if (query.isNotEmpty) {
      searchNotifier.setSearchQuery(query);
      dashboardNotifier.setSearchQuery(query);
    }
    if (dashboardFilter.dealType.isNotEmpty) {
      searchNotifier.setDealType(dashboardFilter.dealType);
    }
    if (dashboardFilter.typeId != null) {
      searchNotifier.setPropertyType(dashboardFilter.typeId);
    }
    if (dashboardFilter.governorate != null &&
        dashboardFilter.governorate!.isNotEmpty) {
      searchNotifier.setCity(dashboardFilter.governorate);
    }

    context.push(
      '/map',
      extra: MapScreenArgs.search(
        searchQuery: query,
        dealType: dashboardFilter.dealType,
        propertyTypeId: dashboardFilter.typeId,
        city: dashboardFilter.governorate,
        district: dashboardFilter.district,
      ),
    );
  }

  Future<void> _onFilterRequested() async {
    final dashboardFilter = ref.read(dashboardFilterProvider);
    final propertyTypes = ref.read(propertyTypesProvider).value ?? const [];
    final selection = await showPropertyFilterSheet(
      context: context,
      initial: PropertyFilterSelection(
        dealType: dashboardFilter.dealType,
        typeId: dashboardFilter.typeId,
        governorate: dashboardFilter.governorate,
        district: dashboardFilter.district,
      ),
      propertyTypes: propertyTypes,
      title: context.l10n.map_filter_results,
    );
    if (selection != null) {
      ref.read(dashboardFilterProvider.notifier).applySelection(selection);
    }
  }

  void _openCategory(String? dealType) {
    final searchNotifier = ref.read(propertyFilterProvider.notifier);
    searchNotifier.resetFilters();
    if (dealType != null && dealType.isNotEmpty) {
      searchNotifier.setDealType(dealType);
    }
    context.push(
      '/map',
      extra: MapScreenArgs.category(dealType: dealType),
    );
  }

  void _openFeatured() {
    context.push('/map', extra: MapScreenArgs.featured());
  }

  void _openNearby(latlong.LatLng center, double radiusKm) {
    context.push(
      '/map',
      extra: MapScreenArgs.nearby(center: center, radiusKm: radiusKm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the property-type cache warm for the shared filter sheet.
    ref.watch(propertyTypesProvider);
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    final forSaleAsync = ref.watch(propertiesForSaleProvider);
    final forRentAsync = ref.watch(propertiesForRentProvider);
    // Section headers show the true category total; the providers above are
    // deliberately capped at 10 preview cards for dashboard performance.
    final featuredCount = ref.watch(featuredCountProvider).value;
    final forSaleCount = ref.watch(propertiesForSaleCountProvider).value;
    final forRentCount = ref.watch(propertiesForRentCountProvider).value;
    final nearbyProperties = ref.watch(nearbyPropertiesProvider);
    final center = ref.watch(homeCenterProvider);
    final radiusKm = ref.watch(homeSearchRadiusProvider);
    final dashboardFilter = ref.watch(dashboardFilterProvider);

    final usingFallback =
        center.latitude == DeviceLocationService.ibbCenter.latitude &&
        center.longitude == DeviceLocationService.ibbCenter.longitude;

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/'),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        // Scaffold places the FAB at the trailing edge (endFloat). Stack the
        // compact add action on that same edge instead of centering it over
        // the wider extended map FAB, which made it look detached.
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const AddPropertyFab(
            key: ValueKey('home_add_property_fab'),
            heroTag: 'home_add_property',
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            key: const ValueKey('dashboard_map_fab'),
            heroTag: 'dashboard_map_fab',
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textLight,
            elevation: 6,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(l10n.dash_view_map),
            onPressed: () => context.push('/map', extra: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeroSection(
              searchController: ref
                  .read(dashboardFilterProvider.notifier)
                  .searchController,
              onSearchSubmit: _onSearchSubmit,
              onFilterRequested: _onFilterRequested,
              activeFilterCount: dashboardFilter.activeFilterCount,
            ),

            const SizedBox(height: 24),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HomeNearbySection(
                    nearbyProperties: nearbyProperties,
                    usingFallback: usingFallback,
                    locationResolved: true,
                    onViewAll: () => _openNearby(center, radiusKm),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    children: [
                      featuredAsync.when(
                        data: (properties) => PropertyCategorySection(
                          title: l10n.dash_featured_title,
                          subtitle: l10n.dash_featured_subtitle,
                          countText: featuredCount == null
                              ? null
                              : '$featuredCount ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.star_rounded,
                          onViewAll: _openFeatured,
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_featured_title,
                          subtitle: l10n.dash_featured_subtitle,
                          loadingMessage: l10n.dash_loading_featured,
                          icon: Icons.star_rounded,
                          onViewAll: _openFeatured,
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_featured_title,
                          subtitle: l10n.dash_featured_subtitle,
                          message: error.toString(),
                          icon: Icons.star_rounded,
                          onViewAll: _openFeatured,
                          onRetry: () =>
                              ref.refresh(featuredPropertiesProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      forSaleAsync.when(
                        data: (properties) => PropertyCategorySection(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          countText: forSaleCount == null
                              ? null
                              : '$forSaleCount ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.sell_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealSale),
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          loadingMessage: l10n.dash_loading_for_sale,
                          icon: Icons.sell_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealSale),
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          message: error.toString(),
                          icon: Icons.sell_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealSale),
                          onRetry: () => ref.refresh(propertiesForSaleProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      forRentAsync.when(
                        data: (properties) => PropertyCategorySection(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          countText: forRentCount == null
                              ? null
                              : '$forRentCount ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.key_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealRent),
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          loadingMessage: l10n.dash_loading_for_rent,
                          icon: Icons.key_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealRent),
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          message: error.toString(),
                          icon: Icons.key_outlined,
                          onViewAll: () => _openCategory(AppConstants.dealRent),
                          onRetry: () => ref.refresh(propertiesForRentProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      const HomePublisherCta(),
                    ],
                  ),
                ),
              ),
            ),

            const AppFooter(),
          ],
        ),
      ),
    );
  }
}
