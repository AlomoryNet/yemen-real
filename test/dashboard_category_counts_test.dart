import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/providers/property_provider.dart';
import 'package:yemen_real_estate_portal/repositories/property_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() => AppConfig.setForceDemoModeForTesting(false));

  test(
    'dashboard section counts use full totals, not the 10-card preview',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final featuredPreview = await container.read(
        featuredPropertiesProvider.future,
      );
      final forSalePreview = await container.read(
        propertiesForSaleProvider.future,
      );
      final forRentPreview = await container.read(
        propertiesForRentProvider.future,
      );

      expect(featuredPreview, hasLength(10));
      expect(forSalePreview, hasLength(10));
      expect(forRentPreview, hasLength(10));

      final featuredCount = await container.read(featuredCountProvider.future);
      final forSaleCount = await container.read(
        propertiesForSaleCountProvider.future,
      );
      final forRentCount = await container.read(
        propertiesForRentCountProvider.future,
      );

      // The map's "View all" surfaces these totals from the same full dataset,
      // so the dashboard header must agree with them instead of showing the
      // preview length.
      final mapListings = await container.read(allMapPropertiesProvider.future);
      expect(featuredCount, 88);
      expect(featuredCount, mapListings.where((p) => p.isFeatured).length);
      expect(
        forSaleCount,
        mapListings.where((p) => p.dealType == AppConstants.dealSale).length,
      );
      expect(
        forRentCount,
        mapListings.where((p) => p.dealType == AppConstants.dealRent).length,
      );
      expect(featuredCount, greaterThan(featuredPreview.length));
      expect(forSaleCount, greaterThan(forSalePreview.length));
      expect(forRentCount, greaterThan(forRentPreview.length));
    },
  );

  test(
    'empty live catalogue falls back to the same demo feeds as nearby/map',
    () async {
      final container = ProviderContainer(
        overrides: [
          propertyRepositoryProvider.overrideWith(
            (ref) => EmptyPropertyRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);

      final featuredPreview = await container.read(
        featuredPropertiesProvider.future,
      );
      final forSalePreview = await container.read(
        propertiesForSaleProvider.future,
      );
      final forRentPreview = await container.read(
        propertiesForRentProvider.future,
      );

      expect(featuredPreview, isNotEmpty);
      expect(featuredPreview.every((property) => property.isFeatured), isTrue);
      expect(forSalePreview, isNotEmpty);
      expect(
        forSalePreview.every((p) => p.dealType == AppConstants.dealSale),
        isTrue,
      );
      expect(forRentPreview, isNotEmpty);
      expect(
        forRentPreview.every((p) => p.dealType == AppConstants.dealRent),
        isTrue,
      );

      expect(
        await container.read(featuredCountProvider.future),
        greaterThan(0),
      );
      expect(
        await container.read(propertiesForSaleCountProvider.future),
        greaterThan(0),
      );
      expect(
        await container.read(propertiesForRentCountProvider.future),
        greaterThan(0),
      );
    },
  );

  test('a non-empty live result still wins over the demo fallback', () async {
    final live = SupabaseService.demoProperties.first;
    final container = ProviderContainer(
      overrides: [
        propertyRepositoryProvider.overrideWith(
          (ref) => StubPropertyRepository(properties: [live], count: 1),
        ),
      ],
    );
    addTearDown(container.dispose);

    final preview = await container.read(propertiesForSaleProvider.future);
    final count = await container.read(propertiesForSaleCountProvider.future);

    expect(preview, hasLength(1));
    expect(preview.single.id, live.id);
    expect(count, 1);
  });
}

class EmptyPropertyRepository extends PropertyRepository {
  @override
  Future<List<Property>> getProperties({
    String? dealType,
    String? propertyTypeId,
    String? city,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String sortBy = 'newest',
    int limit = 20,
    int offset = 0,
    bool onlyFeatured = false,
  }) async {
    return const <Property>[];
  }

  @override
  Future<int> getPropertyCount({
    String? dealType,
    bool onlyFeatured = false,
  }) async {
    return 0;
  }
}

class StubPropertyRepository extends PropertyRepository {
  StubPropertyRepository({required this.properties, required this.count});

  final List<Property> properties;
  final int count;

  @override
  Future<List<Property>> getProperties({
    String? dealType,
    String? propertyTypeId,
    String? city,
    String? searchQuery,
    double? minPrice,
    double? maxPrice,
    double? minArea,
    double? maxArea,
    int? bedrooms,
    String sortBy = 'newest',
    int limit = 20,
    int offset = 0,
    bool onlyFeatured = false,
  }) async {
    return properties;
  }

  @override
  Future<int> getPropertyCount({
    String? dealType,
    bool onlyFeatured = false,
  }) async {
    return count;
  }
}
