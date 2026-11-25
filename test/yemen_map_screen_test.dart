import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
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
    // A direct /map visit starts scoped to the default city, so the active
    // filter label is shown instead of the plain "Filters" chip.
    expect(find.text('الفلاتر ✓'), findsOneWidget);
    expect(find.byIcon(Icons.tune), findsOneWidget);
    expect(find.text('عرض القائمة'), findsOneWidget);

    // The compact add-property FAB belongs to the list view only.
    expect(find.byKey(const ValueKey('map_add_property_fab')), findsNothing);
    await tester.tap(find.text('عرض القائمة'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('map_add_property_fab')), findsOneWidget);
    expect(find.byIcon(Icons.add_home_outlined), findsOneWidget);
  });

  testWidgets('filter sheet opens scoped to the fallback governorate', (
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

    await tester.tap(find.text('الفلاتر ✓'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DropdownMenu<String> &&
            widget.initialSelection == 'إب',
      ),
      findsOneWidget,
    );
  });

  testWidgets('filter sheet localizes property type labels', (tester) async {
    final previousLocale = AppLocale.current;
    addTearDown(() => AppLocale.current = previousLocale);
    AppLocale.current = const Locale('en', 'US');

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('en', 'US'),
          home: YemenMapScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Filters ✓'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Apartments'), findsOneWidget);
    expect(find.text('شقق سكنية'), findsNothing);
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

  testWidgets('resetting the filter sheet keeps free text separate from chips', (
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
          home: const YemenMapScreen(initialListView: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Search by governorate, neighborhood, or property name...',
    );
    expect(tester.widget<TextField>(searchField).controller!.text, 'Ibb');

    await tester.tap(find.text('Filters ✓'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.tap(find.text('Reset').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.tap(find.text('Apply filters'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    // The reset must drop the auto-written "Ibb" label, otherwise it becomes
    // a stale free-text query that matches none of the Arabic-keyed listings.
    expect(tester.widget<TextField>(searchField).controller!.text, isEmpty);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('440 properties available'), findsOneWidget);
  });

  testWidgets('removing the governorate chip clears the auto search label', (
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
          home: const YemenMapScreen(initialListView: true),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.decoration?.hintText ==
              'Search by governorate, neighborhood, or property name...',
    );
    expect(tester.widget<TextField>(searchField).controller!.text, 'Ibb');

    final governorateChip = find.widgetWithText(Chip, 'Ibb');
    expect(governorateChip, findsOneWidget);
    await tester.tap(
      find.descendant(
        of: governorateChip,
        matching: find.byIcon(Icons.close_rounded),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();

    expect(tester.widget<TextField>(searchField).controller!.text, isEmpty);
    expect(find.text('Filters'), findsOneWidget);
    expect(find.text('440 properties available'), findsOneWidget);
  });

  testWidgets(
    'camera animation stops when the map screen is popped mid-flight',
    (tester) async {
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
              initialFilters: MapScreenArgs(city: 'صنعاء', district: 'بيت بوس'),
            ),
          ),
        ),
      );

      // The initial filter triggers the fit-to-results camera animation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Popping while that animation is still running used to leave its listener
      // calling into a disposed _PropertyMapViewState.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 800));

      expect(tester.takeException(), isNull);
    },
  );
}
