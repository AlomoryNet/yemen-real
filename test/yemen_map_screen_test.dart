import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/env_config.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    EnvConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    EnvConfig.setForceDemoModeForTesting(false);
  });

  testWidgets('YemenMapScreen renders map controls, chips and header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('ar', 'YE'),
          home: YemenMapScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify presence of the floating search pill, filter button and map/list toggle
    expect(find.text('ابحث بالمحافظة، الحي، أو اسم العقار...'), findsWidgets);
    expect(find.text('الفلاتر'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.text('عرض القائمة'), findsOneWidget);

    // The compact add-property FAB belongs to the list view only.
    expect(find.byKey(const ValueKey('map_add_property_fab')), findsNothing);
    await tester.tap(find.text('عرض القائمة'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('map_add_property_fab')), findsOneWidget);
    expect(find.byIcon(Icons.add_home_outlined), findsOneWidget);
  });

  testWidgets('صنعاء + بيت بوس filter shows both listings', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: const YemenMapScreen(
            initialListView: true,
            initialFilters: MapScreenArgs(city: 'صنعاء', district: 'بيت بوس'),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2 عقار'), findsWidgets);
    expect(find.textContaining('بيت بوس'), findsWidgets);
  });

  testWidgets('English governorate label keeps Arabic-keyed results', (
    tester,
  ) async {
    final previousLocale = AppLocale.current;
    addTearDown(() => AppLocale.current = previousLocale);
    AppLocale.current = const Locale('en', 'US');

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en', 'US'),
          home: const YemenMapScreen(
            initialListView: true,
            initialFilters: MapScreenArgs(city: 'صنعاء', district: 'بيت بوس'),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('2 properties available'), findsOneWidget);
    expect(find.text("Sana'a Governorate"), findsWidgets);
    expect(find.text('Bayt Bous'), findsWidgets);
  });
}
