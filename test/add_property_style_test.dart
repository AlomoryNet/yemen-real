import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/features/home/presentation/home_hero_section.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/providers/settings_provider.dart';

Widget _heroApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar', 'YE'),
      home: Scaffold(
        body: HomeHeroSection(
          searchController: TextEditingController(),
          onSearchSubmit: () {},
          onFilterRequested: () {},
          activeFilterCount: 0,
        ),
      ),
    ),
  );
}

void main() {
  Future<ProviderContainer> readyContainer() async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).loaded;
    return container;
  }

  testWidgets('outline mode shows the hero add-property button', (tester) async {
    final container = await readyContainer();
    expect(container.read(settingsProvider).addPropertyStyle, 'outlined');

    await tester.pumpWidget(_heroApp(container));

    expect(
      find.byKey(const ValueKey('home_add_property_outlined')),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.map_rounded), findsNothing);
  });

  testWidgets('FAB mode replaces the hero outline with the map shortcut',
      (tester) async {
    final container = await readyContainer();
    await container
        .read(settingsProvider.notifier)
        .setAddPropertyStyle('fab');

    await tester.pumpWidget(_heroApp(container));

    expect(
      find.byKey(const ValueKey('home_add_property_outlined')),
      findsNothing,
    );
    expect(find.byIcon(Icons.map_rounded), findsOneWidget);
  });
}
