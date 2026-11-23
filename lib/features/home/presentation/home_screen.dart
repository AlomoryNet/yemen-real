import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../models/property.dart';
import '../../../providers/dashboard_filter_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../data/demo_properties_generator.dart';
import '../../../services/device_location_service.dart';
import '../../map/presentation/yemen_map_screen.dart';
import '../../map/services/map_cluster_service.dart';
import 'home_hero_section.dart';
import 'home_nearby_section.dart';
import 'home_governorate_picker.dart';
import 'home_property_sections.dart';
import 'home_publisher_cta.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Filter selections live in dashboardFilterProvider (Phase 2).
  // Only the location-first state remains local to the screen.

  // Location-first dashboard state
  latlong.LatLng _userCenter = DeviceLocationService.ibbCenter;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolveLocation());
  }

  Future<void> _resolveLocation() async {
    // Simplified: use Ibb center as default, no location permission request
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
      ),
    );
  }

  void _onDistrictChosen(String district) {
    final controller = ref.read(dashboardFilterProvider.notifier).searchController;
    controller.text = district;
    ref.read(dashboardFilterProvider.notifier).setSearchQuery(district);
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

  void _onGovernoratePickerRequested() {
    final dashboardFilter = ref.read(dashboardFilterProvider);
    final notifier = ref.read(dashboardFilterProvider.notifier);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => HomeGovernoratePickerSheet(
        initialGovernorate: dashboardFilter.governorate,
        onGovernorateSelected: notifier.setGovernorate,
        onDistrictChosen: _onDistrictChosen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(propertyTypesProvider);
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    final forSaleAsync = ref.watch(propertiesForSaleProvider);
    final forRentAsync = ref.watch(propertiesForRentProvider);
    final settings = ref.watch(settingsProvider);
    final nearbyProperties = _nearbyProperties(settings.searchRadiusKm);
    final dashboardFilter = ref.watch(dashboardFilterProvider);
    final dashboardNotifier = ref.read(dashboardFilterProvider.notifier);

    final bool usingFallback = _userCenter.latitude ==
            DeviceLocationService.ibbCenter.latitude &&
        _userCenter.longitude == DeviceLocationService.ibbCenter.longitude;

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/'),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            key: const ValueKey('dashboard_map_fab'),
            heroTag: 'dashboard_map_fab',
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            elevation: 6,
            icon: const Icon(Icons.map_rounded, size: 18),
            label: Text(context.l10n.dash_view_map),
            onPressed: () => context.push('/map', extra: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Search Section
            HomeHeroSection(
              typesAsync: typesAsync,
              searchController: dashboardNotifier.searchController,
              selectedDealType: dashboardFilter.dealType,
              selectedTypeId: dashboardFilter.typeId,
              selectedGovernorate: dashboardFilter.governorate,
              onSearchSubmit: _onSearchSubmit,
              onDealTypeChanged: dashboardNotifier.setDealType,
              onTypeToggled: dashboardNotifier.setTypeId,
              onGovernorateToggled: dashboardNotifier.setGovernorate,
              onGovernoratePickerRequested: _onGovernoratePickerRequested,
              onDistrictChosen: _onDistrictChosen,
            ),

            const SizedBox(height: 24),

            // Properties Near You Section
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

            // Content Container
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Featured Properties Section
                      HomeSectionHeader(
                        title: 'عقارات مميزة',
                        subtitle: 'مختارات عقارية موثوقة ومميزة في اليمن',
                        onViewAll: () {
                          ref
                              .read(propertyFilterProvider.notifier)
                              .resetFilters();
                          context.push(
                            '/map',
                            extra: const MapScreenArgs(initialListView: true),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      featuredAsync.when(
                        data: (properties) => HomePropertyGrid(properties: properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل العقارات المميزة...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () =>
                              ref.refresh(featuredPropertiesProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Properties For Sale Section
                      HomeSectionHeader(
                        title: 'أحدث العقارات للبيع',
                        subtitle: 'شقق، فلل، وأراضٍ معروضة للبيع المباشر',
                        onViewAll: () {
                          final f = ref.read(propertyFilterProvider.notifier);
                          f.resetFilters();
                          f.setDealType(AppConstants.dealSale);
                          context.push(
                            '/map',
                            extra: const MapScreenArgs(
                              initialListView: true,
                              dealType: AppConstants.dealSale,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      forSaleAsync.when(
                        data: (properties) => HomePropertyGrid(properties: properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل عقارات للبيع...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(propertiesForSaleProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Properties For Rent Section
                      HomeSectionHeader(
                        title: 'أحدث العقارات للإيجار',
                        subtitle: 'شقق سكنية ومقرات تجارية جاهزة للإيجار',
                        onViewAll: () {
                          final f = ref.read(propertyFilterProvider.notifier);
                          f.resetFilters();
                          f.setDealType(AppConstants.dealRent);
                          context.push(
                            '/map',
                            extra: const MapScreenArgs(
                              initialListView: true,
                              dealType: AppConstants.dealRent,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      forRentAsync.when(
                        data: (properties) => HomePropertyGrid(properties: properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل عقارات للإيجار...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(propertiesForRentProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Publisher Call-To-Action Banner
                      const HomePublisherCta(),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}