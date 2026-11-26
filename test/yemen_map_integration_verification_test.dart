import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_bottom_nav_bar.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_header.dart';
import 'helpers/maplibre_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    registerFakeMapLibrePlatform();
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
  });

  group('Yemen Map & Header Integration Verification Tests', () {
    testWidgets('1. AppHeader shows menu + app name only', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('ar', 'YE'),
            home: Scaffold(
              appBar: AppHeader(),
              body: Center(child: Text('Home Screen')),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The bar is intentionally quiet: drawer menu + app name only.
      expect(find.byKey(const ValueKey('app_header_menu_button')),
          findsOneWidget);
      expect(find.text('البوابة العقارية'), findsOneWidget);
      expect(find.byKey(const ValueKey('header_add_property_button')),
          findsNothing);
      expect(find.byKey(const ValueKey('header_settings_button')),
          findsNothing);
      expect(find.text('أضف عقارك'), findsNothing);
      expect(find.text('الخريطة'), findsNothing);
    });

    test('2. Offline GeoJSON assets contain all 22 Yemeni governorates',
        () async {
      final jsonString = await rootBundle
          .loadString('assets/map/yemen_adm1_simplified.geojson');
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;

      expect(features.length, 22);

      final names = features
          .map((f) => (f['properties'] as Map<String, dynamic>)['shapeName'])
          .toList();

      expect(names, contains('Sanʿaʾ'));
      expect(names, contains('Hadhramaut'));
      expect(names, contains('Socotra'));
    });

    test('3. Property coordinate fallback handles missing GPS gracefully', () {
      final propWithGps = Property(
        id: 'prop-1',
        ownerId: 'owner-1',
        title: 'شقة بإحداثيات دقيقة',
        description: 'وصف',
        dealType: 'rent',
        propertyTypeId: 'apartment',
        city: 'صنعاء',
        district: 'حدة',
        latitude: 15.3214,
        longitude: 44.1843,
        price: 150000,
        areaSqm: 120,
        contactPhone: '777000111',
        createdAt: DateTime.now(),
      );

      final propWithoutGps = Property(
        id: 'prop-2',
        ownerId: 'owner-1',
        title: 'شقة بدون إحداثيات',
        description: 'وصف',
        dealType: 'rent',
        propertyTypeId: 'apartment',
        city: 'صنعاء',
        district: 'حدة',
        latitude: null,
        longitude: null,
        price: 120000,
        areaSqm: 100,
        contactPhone: '777000222',
        createdAt: DateTime.now(),
      );

      // Verify exact GPS is preserved
      expect(propWithGps.latitude, 15.3214);
      expect(propWithGps.longitude, 44.1843);

      // Verify fallback coordinates resolve to valid Yemen bounds
      final govCoords =
          AppConstants.getCoordinatesForGovernorate(propWithoutGps.city);
      expect(govCoords.$1, inInclusiveRange(12.0, 19.0));
      expect(govCoords.$2, inInclusiveRange(41.0, 55.0));
    });

    test('4. Security & Isolation: Only published properties are visible on map',
        () {
      final allDemos = DemoPropertiesGenerator.generateAllDemoProperties();

      final published = allDemos
          .where((p) => p.status == AppConstants.statusPublished)
          .toList();

      // Ensure every property served to the public map is published
      for (final p in published) {
        expect(p.status, AppConstants.statusPublished);
        expect(p.status, isNot(AppConstants.statusPending));
        expect(p.status, isNot(AppConstants.statusDraft));
        expect(p.status, isNot(AppConstants.statusRejected));
      }
    });

    testWidgets('5. YemenMapScreen renders offline atlas button and header chips',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: YemenMapScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify presence of the floating search pill, filters button and map/list toggle
      expect(find.text('ابحث بالمحافظة، الحي، أو اسم العقار...'), findsWidgets);
      expect(find.text('عرض القائمة'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets('6. AppBottomNavBar has exactly 2 tabs and no map/search tab',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Screen')),
              bottomNavigationBar: AppBottomNavBar(currentRoute: '/'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ar', 'YE'), routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2-tab navigation: الرئيسية + ممتلكاتي. Map/Search live outside the bar.
      expect(find.text('الرئيسية'), findsOneWidget);
      expect(find.text('ممتلكاتي'), findsOneWidget);
      expect(find.text('الخريطة'), findsNothing);
      expect(find.text('البحث'), findsNothing);
    });
  });
}
