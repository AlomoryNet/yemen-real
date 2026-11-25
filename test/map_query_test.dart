import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/map_screen_args.dart';
import 'package:yemen_real_estate_portal/models/map_query.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/models/property_filter_selection.dart';
import 'package:yemen_real_estate_portal/providers/map_query_provider.dart';

Property _property(
  String id, {
  String city = 'إب',
  String district = 'إب',
  double latitude = 13.9667,
  double longitude = 44.1833,
  bool featured = false,
}) {
  return Property(
    id: id,
    ownerId: 'owner',
    title: id,
    description: '',
    dealType: AppConstants.dealSale,
    propertyTypeId: 'apartment',
    city: city,
    district: district,
    latitude: latitude,
    longitude: longitude,
    price: 1000,
    areaSqm: 100,
    contactPhone: '770000000',
    status: AppConstants.statusPublished,
    isFeatured: featured,
    createdAt: DateTime(2026),
  );
}

void main() {
  test('MapQuery copyWith can clear nullable filters and preserve context', () {
    const query = MapQuery(
      freeText: 'شقة',
      governorate: 'إب',
      view: MapViewMode.list,
      source: MapQuerySource.search,
    );

    final cleared = query.copyWith(governorate: null, freeText: '');

    expect(cleared.governorate, isNull);
    expect(cleared.freeText, isEmpty);
    expect(cleared.view, MapViewMode.list);
    expect(cleared.source, MapQuerySource.search);
    expect(cleared.hasActiveFilters, isFalse);
  });

  test('applySelection and resetFilters keep view and source', () {
    const original = MapQuery(
      freeText: 'draft text',
      view: MapViewMode.list,
      source: MapQuerySource.featured,
      onlyFeatured: true,
    );

    final applied = original.applySelection(
      const PropertyFilterSelection(governorate: 'صنعاء', minBedrooms: 3),
    );
    expect(applied.governorate, 'صنعاء');
    expect(applied.minBedrooms, 3);
    expect(applied.freeText, 'draft text');
    expect(applied.onlyFeatured, isTrue);

    final reset = applied.resetFilters();
    expect(reset.hasActiveFilters, isFalse);
    expect(reset.view, MapViewMode.list);
    expect(reset.source, MapQuerySource.featured);
    expect(reset.filterKey, const MapQuery().filterKey);
  });

  test('cameraKey ignores free text but filterKey does not', () {
    const a = MapQuery(freeText: '其一');
    const b = MapQuery(freeText: '其二');

    expect(a.cameraKey, b.cameraKey);
    expect(a.filterKey, isNot(b.filterKey));
  });

  test('MapQueryNotifier commits one selection and one reset', () {
    final container = ProviderContainer(
      overrides: [
        mapQueryProvider.overrideWith((_) => MapQueryNotifier()),
      ],
    );
    addTearDown(container.dispose);
    final notifier = container.read(mapQueryProvider.notifier);

    notifier.applySelection(
      const PropertyFilterSelection(governorate: 'إب', dealType: 'sale'),
    );
    expect(container.read(mapQueryProvider).governorate, 'إب');
    expect(container.read(mapQueryProvider).dealType, 'sale');

    notifier.resetFilters();
    expect(container.read(mapQueryProvider).hasActiveFilters, isFalse);
  });

  test('filterMapProperties treats text and chips as independent filters', () {
    final listings = [
      _property('first', city: 'إب'),
      _property('second', city: 'أمانة العاصمة'),
    ];

    final byChip = filterMapProperties(
      listings: listings,
      query: const MapQuery(governorate: 'صنعاء'),
    );
    expect(byChip.map((p) => p.id).toList(), ['second']);

    // A stale English label in free text no longer wipes out Arabic-keyed data
    // unless the caller intentionally submitted it as free text.
    final byText = filterMapProperties(
      listings: listings,
      query: const MapQuery(freeText: 'Ibb'),
    );
    expect(byText, isEmpty);
  });

  test('filterMapProperties applies featured, nearby and polygon filters', () {
    const center = latlong.LatLng(13.9667, 44.1833);
    final featuredNear = _property(
      'featured-near',
      latitude: 13.9767,
      featured: true,
    );
    final plainNear = _property('plain-near', latitude: 13.9767);
    final featuredFar = _property(
      'featured-far',
      latitude: 15.35,
      longitude: 44.20,
      featured: true,
    );
    final listings = [featuredNear, plainNear, featuredFar];

    final featured = filterMapProperties(
      listings: listings,
      query: const MapQuery(onlyFeatured: true),
    );
    expect(featured.map((p) => p.id).toList(), [
      'featured-near',
      'featured-far',
    ]);

    final nearby = filterMapProperties(
      listings: listings,
      query: MapQuery(nearbyCenter: center, radiusKm: 5),
    );
    expect(nearby.map((p) => p.id).toList(), ['featured-near', 'plain-near']);

    final polygon = filterMapProperties(
      listings: listings,
      query: const MapQuery(),
      drawnPolygon: const [
        latlong.LatLng(13.95, 44.15),
        latlong.LatLng(14.00, 44.15),
        latlong.LatLng(14.00, 44.22),
        latlong.LatLng(13.95, 44.22),
      ],
    );
    expect(polygon.map((p) => p.id).toList(), ['featured-near', 'plain-near']);
  });

  test('dashboard MapScreenArgs factories seed list view and query source', () {
    const center = latlong.LatLng(13.9667, 44.1833);

    final search = MapScreenArgs.search(
      searchQuery: 'صنعاء',
      dealType: 'sale',
    );
    expect(search.initialListView, isTrue);
    expect(search.source, MapQuerySource.search);
    expect(search.searchQuery, 'صنعاء');
    expect(search.dealType, 'sale');

    final nearby = MapScreenArgs.nearby(center: center, radiusKm: 10);
    expect(nearby.initialListView, isTrue);
    expect(nearby.source, MapQuerySource.nearby);
    expect(nearby.nearbyCenter, center);
    expect(nearby.radiusKm, 10);

    final featured = MapScreenArgs.featured();
    expect(featured.initialListView, isTrue);
    expect(featured.source, MapQuerySource.featured);
    expect(featured.onlyFeatured, isTrue);

    final category = MapScreenArgs.category(dealType: 'rent');
    expect(category.initialListView, isTrue);
    expect(category.source, MapQuerySource.category);
    expect(category.dealType, 'rent');
  });
}
