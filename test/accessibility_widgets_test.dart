import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/theme/app_colors.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';
import 'package:yemen_real_estate_portal/shared/widgets/property/favorite_button.dart';
import 'package:yemen_real_estate_portal/shared/widgets/property_card.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() => AppConfig.setForceDemoModeForTesting(false));

  Property demoProperty() => Property(
    id: 'a11y-property',
    ownerId: 'owner',
    title: 'Test property',
    description: 'Test description',
    dealType: AppConstants.dealSale,
    propertyTypeId: 'apartment',
    city: 'صنعاء',
    district: 'بيت بوس',
    price: 1000000,
    areaSqm: 120,
    contactPhone: '+967770000000',
    isFeatured: true,
    createdAt: DateTime(2026),
  );

  testWidgets('FavoriteButton exposes a tooltip and a 48dp target', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en', 'US'),
          home: Scaffold(
            body: Center(child: FavoriteButton(propertyId: 'p1')),
          ),
        ),
      ),
    );
    await tester.pump();

    final button = tester.widget<IconButton>(find.byType(IconButton));
    expect(button.tooltip, 'Add to Favorites');
    expect(button.constraints?.minWidth, 48);
    expect(button.constraints?.minHeight, 48);
  });

  testWidgets('PropertyCard close control is labeled and large enough', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en', 'US'),
          home: Scaffold(
            body: PropertyCard(
              property: demoProperty(),
              layout: PropertyCardLayout.overlay,
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byTooltip('Close'), findsOneWidget);

    final target = tester.widget<SizedBox>(
      find
          .ancestor(
            of: find.byIcon(Icons.close),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(target.width, 48);
    expect(target.height, 48);

    final featured = tester.widget<Text>(find.text('Featured'));
    expect(featured.style?.color, AppColors.onAccent);
  });
}

