import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../data/demo_properties_generator.dart';
import '../../../models/property.dart';
import '../../../providers/dashboard_filter_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/device_location_service.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/property_category_section.dart';
import '../../../shared/widgets/property_filter_sheet.dart';
import '../../map/presentation/yemen_map_screen.dart';
import '../../map/services/map_cluster_service.dart';
import 'home_hero_section.dart';
import 'home_nearby_section.dart';
import 'home_publisher_cta.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Filter selections live in dashboardFilterProvider. Only the
  // location-first state remains local to the screen.

  latlong.LatLng _userCenter = DeviceLocationService.ibbCenter;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveLocation());
  }

  Future<void> _resolveLocation() async {
    // Simplified: use Ibb center as default, no location permission request.
    setState(() {
      _userCenter = DeviceLocationService.ibbCenter;
      _locationResolved = true;
    });
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
      extra: MapScreenArgs(
        initialListView: true,
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
      extra: MapScreenArgs(
        initialListView: true,
        dealType: dealType,
      ),
    );
  }

  /// All listings within the configured radius of the dashboard centre (Ibb
  /// by default), nearest first. The section displays at most four of them but
  /// uses the full list for its count and for the "view all" destination.
  List<Property> _nearbyProperties(double radiusKm) {
    const distance = latlong.Distance();
    final scored = <(Property, double)>[];
    for (final property
        in DemoPropertiesGenerator.generateAllDemoProperties()) {
      if (property.status != AppConstants.statusPublished) continue;
      final coords = MapClusterService.getPropertyCoordinates(property);
      final km = distance.as(
        latlong.LengthUnit.Kilometer,
        _userCenter,
        latlong.LatLng(coords.$1, coords.$2),
      );
      if (km <= radiusKm) scored.add((property, km));
    }
    scored.sort((a, b) => a.$2.compareTo(b.$2));
    return scored.map((entry) => entry.$1).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Keep the property-type cache warm for the shared filter sheet.
    ref.watch(propertyTypesProvider);
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    final forSaleAsync = ref.watch(propertiesForSaleProvider);
    final forRentAsync = ref.watch(propertiesForRentProvider);
    final settings = ref.watch(settingsProvider);
    final nearbyProperties = _nearbyProperties(settings.searchRadiusKm);
    final dashboardFilter = ref.watch(dashboardFilterProvider);

    final usingFallback = _userCenter.latitude ==
            DeviceLocationService.ibbCenter.latitude &&
        _userCenter.longitude == DeviceLocationService.ibbCenter.longitude;

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/'),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('dashboard_map_fab'),
        heroTag: 'dashboard_map_fab',
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.map_rounded, size: 18),
        label: Text(l10n.dash_view_map),
        onPressed: () => context.push('/map', extra: false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomeHeroSection(
              searchController:
                  ref.read(dashboardFilterProvider.notifier).searchController,
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
                    locationResolved: _locationResolved,
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
                          countText:
                              '${properties.length} ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.star_rounded,
                          onViewAll: () => _openCategory(null),
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_featured_title,
                          subtitle: l10n.dash_featured_subtitle,
                          loadingMessage: l10n.dash_loading_featured,
                          icon: Icons.star_rounded,
                          onViewAll: () => _openCategory(null),
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_featured_title,
                          subtitle: l10n.dash_featured_subtitle,
                          message: error.toString(),
                          icon: Icons.star_rounded,
                          onViewAll: () => _openCategory(null),
                          onRetry: () => ref.refresh(featuredPropertiesProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      forSaleAsync.when(
                        data: (properties) => PropertyCategorySection(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          countText:
                              '${properties.length} ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.sell_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealSale),
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          loadingMessage: l10n.dash_loading_for_sale,
                          icon: Icons.sell_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealSale),
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_for_sale_title,
                          subtitle: l10n.dash_for_sale_subtitle,
                          message: error.toString(),
                          icon: Icons.sell_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealSale),
                          onRetry: () => ref.refresh(propertiesForSaleProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      forRentAsync.when(
                        data: (properties) => PropertyCategorySection(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          countText:
                              '${properties.length} ${l10n.map_properties_available}',
                          properties: properties,
                          icon: Icons.key_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealRent),
                        ),
                        loading: () => PropertyCategorySection.loading(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          loadingMessage: l10n.dash_loading_for_rent,
                          icon: Icons.key_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealRent),
                        ),
                        error: (error, _) => PropertyCategorySection.error(
                          title: l10n.dash_for_rent_title,
                          subtitle: l10n.dash_for_rent_subtitle,
                          message: error.toString(),
                          icon: Icons.key_outlined,
                          onViewAll: () =>
                              _openCategory(AppConstants.dealRent),
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
