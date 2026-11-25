import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../data/demo_properties_generator.dart';
import '../features/home/presentation/home_nearby_calculator.dart';
import '../models/property.dart';
import '../services/device_location_service.dart';
import '../services/supabase_service.dart';
import 'property_provider.dart';
import 'settings_provider.dart';

/// Dashboard centre. Starts at Ibb and moves once first-run location consent
/// succeeds; keeping it in a provider avoids a full `setState` rebuild.
final homeCenterProvider =
    StateProvider<latlong.LatLng>((ref) => DeviceLocationService.ibbCenter);

/// Isolated so tests can override the radius without touching SharedPreferences.
final homeSearchRadiusProvider = Provider<double>(
  (ref) => ref.watch(settingsProvider.select((state) => state.searchRadiusKm)),
);

/// Nearby listings used by the dashboard section.
///
/// Riverpod caches this value: the 440-item scan and sort only reruns when the
/// centre, radius or one of the dashboard listing feeds changes. This keeps the
/// work off `HomeScreen.build`, which previously repeated it on every rebuild.
final nearbyPropertiesProvider = Provider<List<Property>>((ref) {
  // Subscribing to the dashboard feeds invalidates the cached result after an
  // add/edit/refresh without adding any new network requests.
  ref.watch(featuredPropertiesProvider);
  ref.watch(propertiesForSaleProvider);
  ref.watch(propertiesForRentProvider);

  final center = ref.watch(homeCenterProvider);
  final radiusKm = ref.watch(homeSearchRadiusProvider);
  final listings = SupabaseService.demoProperties.isNotEmpty
      ? SupabaseService.demoProperties
      : DemoPropertiesGenerator.cachedDemoProperties;

  return computeNearbyProperties(
    listings: listings,
    center: center,
    radiusKm: radiusKm,
  );
});
