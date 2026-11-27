import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/property_map_view.dart';
import 'package:yemen_real_estate_portal/features/properties/presentation/property_detail_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/services/device_location_service.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';
import 'package:yemen_real_estate_portal/shared/widgets/map/user_location.dart';

import 'helpers/fake_geolocator.dart';
import 'helpers/maplibre_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const userPosition = LatLng(15.3547, 44.2075);

  setUpAll(() async {
    registerFakeMapLibrePlatform();
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  setUp(() => resetGeolocatorMock());
  tearDown(() => resetGeolocatorMock());
  tearDownAll(() => AppConfig.setForceDemoModeForTesting(false));

  test('silent lookup reads an already granted permission without prompting',
      () async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.whileInUse,
      position: userPosition,
      calls: calls,
    );

    final result = await DeviceLocationService.currentLocationIfPermitted();

    expect(result.hasPosition, isTrue);
    expect(result.granted, isTrue);
    expect(calls, contains('checkPermission'));
    expect(calls, isNot(contains('requestPermission')));
  });

  test('silent lookup never opens a permission dialog when denied', () async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.denied,
      calls: calls,
    );

    final result = await DeviceLocationService.currentLocationIfPermitted();

    expect(result.hasPosition, isFalse);
    expect(calls, isNot(contains('requestPermission')));
  });

  test('silent lookup falls back to the cached position when no fresh fix',
      () async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.always,
      failCurrentPosition: true,
      lastKnownPosition: userPosition,
      calls: calls,
    );

    final result = await DeviceLocationService.currentLocationIfPermitted();

    expect(result.hasPosition, isTrue);
    expect(result.position!.latitude, closeTo(userPosition.latitude, 0.0001));
    expect(calls, contains('getCurrentPosition'));
    expect(calls, contains('getLastKnownPosition'));
  });

  test('relocate button re-prompts and returns the device position', () async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.denied,
      requestPermission: LocationPermission.whileInUse,
      position: userPosition,
      calls: calls,
    );

    final result = await DeviceLocationService.requestLocation();

    expect(result.hasPosition, isTrue);
    expect(calls, contains('requestPermission'));
    expect(calls, contains('getCurrentPosition'));
    expect(result.position!.latitude, closeTo(userPosition.latitude, 0.0001));
    expect(
      result.position!.longitude,
      closeTo(userPosition.longitude, 0.0001),
    );
  });

  testWidgets('locate button prompts on tap and reports the position', (
    tester,
  ) async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.denied,
      requestPermission: LocationPermission.always,
      position: userPosition,
      calls: calls,
    );
    LatLng? located;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: Center(
            child: LocateMeButton(
              heroTag: null,
              onLocated: (position) => located = position,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.my_location_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.my_location_rounded));
    await tester.pumpAndSettle();

    expect(located, isNotNull);
    expect(calls, contains('requestPermission'));
    expect(find.text('تعذّر تحديد موقعك. يرجى المحاولة مرة أخرى.'), findsNothing);
  });

  testWidgets('permanently denied permission shows the settings shortcut', (
    tester,
  ) async {
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.deniedForever,
      calls: calls,
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: Center(
            child: LocateMeButton(heroTag: null, onLocated: (_) {}),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.my_location_rounded));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'إذن الموقع متوقف. اسمح به من إعدادات التطبيق لعرض موقعك على الخريطة.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(SnackBarAction, 'الإعدادات'), findsOneWidget);
    expect(calls, isNot(contains('getCurrentPosition')));
  });

  testWidgets('/map shows the blue dot when permission is already granted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    mockGeolocator(
      checkPermission: LocationPermission.always,
      position: userPosition,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: YemenMapScreen(key: UniqueKey()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byTooltip('موقعي'), findsOneWidget);
    expect(find.byType(UserLocationMarker), findsOneWidget);
  });

  testWidgets('/map hides the blue dot but keeps the button when denied', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    mockGeolocator(checkPermission: LocationPermission.denied);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: YemenMapScreen(key: UniqueKey()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(find.byTooltip('موقعي'), findsOneWidget);
    expect(find.byType(UserLocationMarker), findsNothing);
  });

  testWidgets('shared map renderer places the dot above property markers', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar', 'YE'),
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: PropertyMapView(
              properties: const [],
              userLocation: userPosition,
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(UserLocationMarker), findsOneWidget);
  });

  testWidgets('property detail restores the blue dot without prompting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.always,
      position: userPosition,
      calls: calls,
    );
    final propertyId = DemoPropertiesGenerator.cachedDemoProperties.first.id;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: PropertyDetailScreen(propertyId: propertyId),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byTooltip('موقعي'), findsOneWidget);
    expect(find.byType(UserLocationMarker), findsOneWidget);
    expect(calls, contains('checkPermission'));
    expect(calls, isNot(contains('requestPermission')));
    expect(tester.takeException(), isNull);
  });
}
