import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/property_map_view.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/property.dart';

void main() {
  testWidgets('repeated cluster taps reuse the map animation ticker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final now = DateTime(2026);
    final properties = List<Property>.generate(
      3,
      (index) => Property(
        id: 'cluster-$index',
        ownerId: 'owner',
        title: 'عقار',
        description: 'وصف',
        dealType: AppConstants.dealSale,
        propertyTypeId: 'apartment',
        city: 'صنعاء',
        district: 'بيت بوس',
        latitude: 15.3547,
        longitude: 44.2075,
        price: 100000,
        areaSqm: 100,
        contactPhone: '+967770000000',
        createdAt: now,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: PropertyMapView(properties: properties, initialZoom: 7.5),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    final clusterBadge = find.byWidgetPredicate(
      (widget) =>
          widget is GestureDetector &&
          widget.onTap != null &&
          widget.child.runtimeType.toString() == '_ClusterBadge',
    );
    expect(clusterBadge, findsOneWidget);

    // The old code created a new AnimationController on every cluster tap, so
    // the second callback made SingleTickerProviderStateMixin assert.
    tester.widget<GestureDetector>(clusterBadge).onTap!.call();
    await tester.pump(const Duration(milliseconds: 80));
    tester.widget<GestureDetector>(clusterBadge).onTap!.call();
    await tester.pump(const Duration(milliseconds: 800));

    expect(tester.takeException(), isNull);
  });
}
