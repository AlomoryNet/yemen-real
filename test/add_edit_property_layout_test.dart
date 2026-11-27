import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/features/properties/presentation/add_edit_property_screen.dart';
import 'package:yemen_real_estate_portal/features/properties/presentation/widgets/location_pin_picker.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/models/property_type.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/providers/location_provider.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';
import 'package:yemen_real_estate_portal/shared/widgets/map/user_location.dart';

import 'helpers/fake_geolocator.dart';
import 'helpers/maplibre_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const devicePosition = LatLng(15.5, 44.25);
  // The pin picker starts centred on Sanaa (15.22, 44.35) at zoom 13; keep
  // this position inside that narrow viewport so the marker layer builds its
  // child instead of culling it.
  const nearbyPosition = LatLng(15.221, 44.351);
  final initialLocale = AppLocale.current;
  UserProfile? previousDemoUser;

  setUpAll(() async {
    registerFakeMapLibrePlatform();
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  setUp(() {
    previousDemoUser = SupabaseService.demoCurrentUser;
    SupabaseService.demoCurrentUser = UserProfile(
      id: 'tester',
      fullName: 'Test User',
      email: 'user@yemenrealestate.local',
      isVerified: true,
      createdAt: DateTime(2026),
    );
    SharedPreferences.setMockInitialValues({});
    AppLocale.current = const Locale('ar', 'YE');
  });

  tearDown(() {
    SupabaseService.demoCurrentUser = previousDemoUser;
    AppLocale.current = initialLocale;
    SharedPreferences.setMockInitialValues({});
    resetGeolocatorMock();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
  });

  Widget buildApp({Property? property}) {
    return ProviderScope(
      overrides: [
        propertyTypesProvider.overrideWith(
          (ref) async => [
            PropertyType(
              id: 'apartment',
              // Reproduces the backend row that showed a raw `en` in the
              // Arabic property-type dropdown.
              nameAr: 'en',
              nameEn: 'شقق سكنية',
            ),
          ],
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar', 'YE'),
        home: AddEditPropertyScreen(propertyToEdit: property),
      ),
    );
  }

  testWidgets('Arabic pin picker renders RTL controls without raw en labels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    mockGeolocator(checkPermission: LocationPermission.denied);

    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byTooltip('موقعي'), findsOneWidget);
    expect(find.byTooltip('تكبير الخريطة'), findsOneWidget);
    expect(find.byTooltip('تصغير الخريطة'), findsOneWidget);
    expect(find.byIcon(Icons.location_on_rounded), findsOneWidget);
    expect(find.text('en'), findsNothing);
    expect(find.text('شقق سكنية'), findsWidgets);
    expect(find.text('اسحب الخريطة حتى يستقر الدبوس على موقع العقار'),
        findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pin caption identifies the place and relocate re-prompts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.denied,
      requestPermission: LocationPermission.whileInUse,
      position: devicePosition,
      calls: calls,
    );

    final property = Property(
      id: 'p1',
      ownerId: 'tester',
      title: 'شقة',
      description: 'وصف',
      dealType: 'sale',
      propertyTypeId: 'apartment',
      city: 'أمانة العاصمة',
      district: 'بيت بوس',
      latitude: 15.3547,
      longitude: 44.2075,
      price: 100000,
      areaSqm: 120,
      contactPhone: '770000000',
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(buildApp(property: property));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // Editing an existing pin keeps its coordinates and names the nearest
    // governorate in a compact caption.
    expect(
      find.text('15.35470, 44.20750 · أمانة العاصمة'),
      findsOneWidget,
    );
    expect(find.text('إزالة'), findsOneWidget);
    expect(calls, isNot(contains('requestPermission')));

    final locate = find.byTooltip('موقعي');
    await tester.ensureVisible(locate);
    await tester.tap(locate);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(calls, contains('requestPermission'));
    expect(
      find.text('15.50000, 44.25000 · أمانة العاصمة'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('granted permission reveals the blue dot without prompting', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    final calls = <String>[];
    mockGeolocator(
      checkPermission: LocationPermission.always,
      position: nearbyPosition,
      calls: calls,
    );

    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(calls, contains('checkPermission'));
    expect(calls, contains('getCurrentPosition'));
    expect(calls, isNot(contains('requestPermission')));
    await tester.ensureVisible(find.byTooltip('موقعي'));
    await tester.pump();
    expect(find.byType(UserLocationMarker), findsOneWidget);
    expect(calls, isNot(contains('requestPermission')));
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid camera frames keep the exact final pin for save', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    mockGeolocator(checkPermission: LocationPermission.denied);

    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    final picker = tester.widget<LocationPinPicker>(
      find.byType(LocationPinPicker),
    );
    final state = tester.state<LocationPinPickerState>(
      find.byType(LocationPinPicker),
    );
    // 40 gesture frames without an intervening pump. The old form called
    // setState on every frame and rebuilt the entire form during rendering.
    for (var i = 0; i < 40; i++) {
      state.applyGestureCenter(
        LatLng(12.825 + i * 0.00001, 45.010 + i * 0.00001),
      );
    }
    await tester.pump();

    expectSamePin(
      picker.selectedPin.value,
      const LatLng(12.82539, 45.01039),
    );
    expect(find.text('12.82539, 45.01039 · عدن'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pin picker coalesces gesture frames and flushes final value', (
    tester,
  ) async {
    mockGeolocator(checkPermission: LocationPermission.denied);
    final pin = ValueNotifier<LatLng?>(null);
    addTearDown(pin.dispose);
    final commits = <LatLng?>[];
    var hostBuilds = 0;

    Widget buildHost() {
      return MaterialApp(
        locale: const Locale('ar', 'YE'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _PinHost(
          pin: pin,
          onCommit: commits.add,
          onBuild: () => hostBuilds++,
        ),
      );
    }

    await tester.pumpWidget(buildHost());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    final state = tester.state<LocationPinPickerState>(
      find.byType(LocationPinPicker),
    );
    final buildsBeforeGestures = hostBuilds;

    for (var i = 0; i < 40; i++) {
      state.applyGestureCenter(
        LatLng(15.22 + i * 0.00001, 44.35 + i * 0.00001),
      );
    }
    // No pumps yet: a moving camera must not rebuild the host form.
    expect(hostBuilds, buildsBeforeGestures);
    expect(commits, isEmpty);
    expectSamePin(pin.value, const LatLng(15.22039, 44.35039));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    expect(commits, hasLength(1));
    expectSamePin(commits.single, const LatLng(15.22039, 44.35039));
    expect(hostBuilds, lessThanOrEqualTo(buildsBeforeGestures + 2));
    expect(find.text('15.22039, 44.35039 · صنعاء'), findsOneWidget);

    // A fresh burst followed by a tap commits at once; the stale debounced
    // frame must never overwrite the tapped coordinate.
    for (var i = 0; i < 20; i++) {
      state.applyGestureCenter(
        LatLng(13.958 + i * 0.00001, 44.163 + i * 0.00001),
      );
    }
    const tapped = LatLng(13.95891, 44.16381);
    state.commitPin(tapped);
    expect(commits, hasLength(2));
    expectSamePin(pin.value, tapped);
    await tester.pump(const Duration(milliseconds: 200));
    expect(commits, hasLength(2));
    await tester.pump();
    expect(find.text('13.95891, 44.16381 · إب'), findsOneWidget);

    // Clear, zoom and locate still work through the extracted widget.
    await tester.tap(find.text('إزالة'));
    await tester.pump();
    expect(pin.value, isNull);
    expect(commits.last, isNull);
    expect(
      find.text('اسحب الخريطة حتى يستقر الدبوس على موقع العقار'),
      findsOneWidget,
    );

    // Governorate changes move the camera through the same public picker API.
    const moved = LatLng(15.3547, 44.2075);
    state.moveTo(moved);
    expectSamePin(pin.value, moved);
    expectSamePin(commits.last, moved);
    await tester.pump();
    expect(find.text('15.35470, 44.20750 · أمانة العاصمة'), findsOneWidget);

    final zoomBefore = state.cameraZoom;
    await tester.tap(find.byTooltip('تكبير الخريطة'));
    await tester.pump();
    final zoomedIn = state.cameraZoom;
    expect(zoomedIn, greaterThan(zoomBefore));
    await tester.tap(find.byTooltip('تصغير الخريطة'));
    await tester.pump();
    expect(state.cameraZoom, lessThan(zoomedIn));

    mockGeolocator(
      checkPermission: LocationPermission.denied,
      requestPermission: LocationPermission.whileInUse,
      position: nearbyPosition,
    );
    await tester.tap(find.byTooltip('موقعي'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expectSamePin(pin.value, nearbyPosition);
    expectSamePin(commits.last, nearbyPosition);
    expect(find.byType(UserLocationMarker), findsOneWidget);

    // Disposing with a pending gesture flushes the last coordinate.
    const finalPin = LatLng(14.7978, 42.9545);
    state.applyGestureCenter(finalPin);
    final beforeDispose = commits.length;
    await tester.pumpWidget(const SizedBox.shrink());
    expect(commits, hasLength(beforeDispose + 1));
    expectSamePin(commits.last, finalPin);
    expect(tester.takeException(), isNull);
  });
}

void expectSamePin(LatLng? actual, LatLng expected) {
  expect(actual, isNotNull);
  // Generated by repeated `+ 0.00001` additions, so compare at sub-nanodegree
  // precision rather than against a decimal literal's binary representation.
  expect(actual!.latitude, closeTo(expected.latitude, 1e-9));
  expect(actual.longitude, closeTo(expected.longitude, 1e-9));
}

class _PinHost extends StatefulWidget {
  const _PinHost({
    required this.pin,
    required this.onCommit,
    required this.onBuild,
  });

  final ValueNotifier<LatLng?> pin;
  final ValueChanged<LatLng?> onCommit;
  final VoidCallback onBuild;

  @override
  State<_PinHost> createState() => _PinHostState();
}

class _PinHostState extends State<_PinHost> {
  @override
  void initState() {
    super.initState();
    widget.onBuild();
  }

  @override
  Widget build(BuildContext context) {
    widget.onBuild();
    return Scaffold(
      body: LocationPinPicker(
        selectedPin: widget.pin,
        initialCenter: const LatLng(15.22, 44.35),
        onPinCommitted: _onCommit,
      ),
    );
  }

  void _onCommit(LatLng? value) {
    widget.onCommit(value);
    if (mounted) setState(() {});
  }
}
