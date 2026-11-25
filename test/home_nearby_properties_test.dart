import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/home/presentation/home_nearby_calculator.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/providers/home_nearby_properties_provider.dart';
import 'package:yemen_real_estate_portal/providers/property_provider.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

Property _property(
  String id, {
  required double latitude,
  required double longitude,
  String status = AppConstants.statusPublished,
}) {
  return Property(
    id: id,
    ownerId: 'owner',
    title: id,
    description: '',
    dealType: AppConstants.dealSale,
    propertyTypeId: 'apartment',
    city: 'إب',
    district: 'إب',
    latitude: latitude,
    longitude: longitude,
    price: 1000,
    areaSqm: 100,
    contactPhone: '770000000',
    status: status,
    createdAt: DateTime(2026),
  );
}

void main() {
  const ibb = latlong.LatLng(13.9667, 44.1833);

  test('computeNearbyProperties filters radius/status and sorts nearest first',
      () {
    // latlong2 rounds `as(Kilometer)` to whole km, so keep a clear gap.
    final near = _property('near', latitude: 14.05, longitude: 44.1833);
    final nearer = _property('nearer', latitude: 14.01, longitude: 44.1833);
    final far = _property('far', latitude: 15.35, longitude: 44.20);
    final draft = _property('draft', latitude: 13.9670, longitude: 44.1833,
        status: AppConstants.statusDraft);

    final result = computeNearbyProperties(
      listings: [far, near, draft, nearer],
      center: ibb,
      radiusKm: 25,
    );

    expect(result.map((property) => property.id).toList(), ['nearer', 'near']);
  });

  test('nearbyPropertiesProvider caches the scan until its inputs change', () {
    final original = SupabaseService.demoProperties;
    SupabaseService.demoProperties = [
      _property('near', latitude: 13.9767, longitude: 44.1833),
    ];
    addTearDown(() => SupabaseService.demoProperties = original);

    final container = ProviderContainer(
      overrides: [
        homeCenterProvider.overrideWith((ref) => ibb),
        homeSearchRadiusProvider.overrideWithValue(25),
        featuredPropertiesProvider.overrideWith((ref) async => const []),
        propertiesForSaleProvider.overrideWith((ref) async => const []),
        propertiesForRentProvider.overrideWith((ref) async => const []),
      ],
    );
    addTearDown(container.dispose);

    final first = container.read(nearbyPropertiesProvider);
    expect(first, hasLength(1));
    expect(identical(first, container.read(nearbyPropertiesProvider)), isTrue);

    // Moving the centre invalidates the cached scan.
    container.read(homeCenterProvider.notifier).state =
        const latlong.LatLng(15.35, 44.20);
    final moved = container.read(nearbyPropertiesProvider);
    expect(moved, isEmpty);
    expect(identical(first, moved), isFalse);
  });
}
