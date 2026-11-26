import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/providers/property_provider.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() => AppConfig.setForceDemoModeForTesting(false));

  test('dashboard section counts use full totals, not the 10-card preview',
      () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final featuredPreview = await container.read(featuredPropertiesProvider.future);
    final forSalePreview = await container.read(propertiesForSaleProvider.future);
    final forRentPreview = await container.read(propertiesForRentProvider.future);

    expect(featuredPreview, hasLength(10));
    expect(forSalePreview, hasLength(10));
    expect(forRentPreview, hasLength(10));

    final featuredCount = await container.read(featuredCountProvider.future);
    final forSaleCount = await container.read(propertiesForSaleCountProvider.future);
    final forRentCount = await container.read(propertiesForRentCountProvider.future);

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
  });
}
