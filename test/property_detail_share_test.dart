import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';
import 'package:yemen_real_estate_portal/features/properties/presentation/property_detail_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

import 'helpers/fake_geolocator.dart';
import 'helpers/maplibre_test_stub.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerFakeMapLibrePlatform();
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  setUp(() => resetGeolocatorMock());
  tearDown(() => resetGeolocatorMock());
  tearDownAll(() => AppConfig.setForceDemoModeForTesting(false));

  testWidgets('share action copies a property link', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    mockGeolocator(checkPermission: LocationPermission.denied);
    final property = DemoPropertiesGenerator.cachedDemoProperties.first;
    String? copiedLink;
    const platformChannel = MethodChannel('flutter/platform', JSONMethodCodec());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(platformChannel, (call) async {
      if (call.method == 'Clipboard.setData') {
        copiedLink = call.arguments['text'] as String;
      }
      return null;
    });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(platformChannel, null);
    });

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: PropertyDetailScreen(propertyId: property.id),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final shareButton = find.byKey(const Key('property_detail_share_button'));
    await tester.scrollUntilVisible(
      shareButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(shareButton);
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('تم نسخ رابط العقار للمشاركة'), findsOneWidget);
    expect(copiedLink, 'yemenreal://property/${property.id}');
    expect(tester.takeException(), isNull);
  });
}
