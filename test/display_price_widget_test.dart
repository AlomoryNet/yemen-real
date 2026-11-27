import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/utils/formatters.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/providers/settings_provider.dart';
import 'package:yemen_real_estate_portal/shared/widgets/property_card.dart';

Property _property() => Property(
  id: 'display-price-property',
  ownerId: 'owner',
  title: 'شقة للبيع',
  description: 'وصف',
  dealType: AppConstants.dealSale,
  propertyTypeId: 'apartment',
  city: 'صنعاء',
  district: 'بيت بوس',
  price: 1000000,
  currency: AppConstants.currencyYer,
  areaSqm: 120,
  contactPhone: '+967770000000',
  createdAt: DateTime(2026),
);

void main() {
  testWidgets('PropertyCard shows an estimated price and keeps the stored amount',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(settingsProvider.notifier);
    await notifier.loaded;
    await notifier.setCurrency(AppConstants.currencyUsd);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: PropertyCard(property: _property()),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final settings = container.read(settingsProvider);
    final expected = Formatters.formatDisplayPrice(
      1000000,
      AppConstants.currencyYer,
      AppConstants.currencyUsd,
      settings.currencyRates,
    );
    expect(find.text(expected), findsOneWidget);
    expect(expected.startsWith('≈ '), isTrue);
    // The actual saved price remains visible beside the estimate.
    expect(
      find.text(Formatters.formatCurrency(1000000, AppConstants.currencyYer)),
      findsOneWidget,
    );
  });
}
