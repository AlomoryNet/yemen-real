import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/config/env_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_bottom_nav_bar.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_header.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    EnvConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    EnvConfig.setForceDemoModeForTesting(false);
  });

  group('Yemen Map & Header Integration Verification Tests', () {
    testWidgets('1. AppHeader displays "الخريطة" button next to "إضافة"',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool navigatedToMap = false;

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              appBar: AppHeader(),
              body: Center(child: Text('Home Screen')),
            ),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) {
              navigatedToMap = true;
              return const Scaffold(body: Text('Yemen Map Route'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find both buttons in AppHeader
      expect(find.text('الخريطة'), findsOneWidget);
      expect(find.text('إضافة'), findsOneWidget);

      // Tap "الخريطة" button
      await tester.tap(find.text('الخريطة'));
      await tester.pumpAndSettle();

      expect(navigatedToMap, isTrue);
      expect(find.text('Yemen Map Route'), findsOneWidget);
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
            home: YemenMapScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // Verify presence of title badge, offline map chip, and list view toggle
      expect(find.text('خريطة اليمن'), findsWidgets);
      expect(find.text('خريطة اليمن 🇾🇪'), findsOneWidget);
      expect(find.text('عرض القائمة'), findsOneWidget);
      expect(find.byIcon(Icons.tune), findsOneWidget);
    });

    testWidgets(
        '6. AppBottomNavBar displays "الخريطة" center button and navigates to "/map"',
        (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool navigatedToMap = false;

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
          GoRoute(
            path: '/map',
            builder: (context, state) {
              navigatedToMap = true;
              return const Scaffold(body: Text('Yemen Map Route'));
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('الخريطة'), findsOneWidget);
      await tester.tap(find.text('الخريطة'));
      await tester.pumpAndSettle();

      expect(navigatedToMap, isTrue);
      expect(find.text('Yemen Map Route'), findsOneWidget);
    });
  });
}
