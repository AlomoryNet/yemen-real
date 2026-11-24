import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/core/theme/app_theme_scope.dart';
import 'package:yemen_real_estate_portal/providers/settings_provider.dart';

void main() {
  Future<SettingsNotifier> readyNotifier() async {
    SharedPreferences.setMockInitialValues({});
    final notifier = SettingsNotifier();
    await notifier.loaded;
    return notifier;
  }

  test('default settings state', () async {
    final notifier = await readyNotifier();
    expect(notifier.state.locale, const Locale('ar', 'YE'));
    expect(notifier.state.themeMode, ThemeMode.system);
    expect(notifier.state.addPropertyStyle, 'outlined');
    expect(notifier.state.assetCountVisibility, 'always');
    expect(notifier.state.notificationsEnabled, true);
    expect(notifier.state.searchRadiusKm, 25);
    expect(notifier.state.currencyCode, 'YER');
    expect(notifier.state.distanceUnit, 'km');
    expect(notifier.state.textSize, 'medium');
    expect(notifier.state.defaultMapView, 'map');
  });

  test('theme mode changes via setThemeMode', () async {
    final notifier = await readyNotifier();
    await notifier.setThemeMode(ThemeMode.dark);
    expect(notifier.state.themeMode, ThemeMode.dark);
  });

  test('locale changes via setLocale', () async {
    final notifier = await readyNotifier();
    await notifier.setLocale(const Locale('en', 'US'));
    expect(notifier.state.locale, const Locale('en', 'US'));
  });

  test('currency changes via setCurrency', () async {
    final notifier = await readyNotifier();
    await notifier.setCurrency('SAR');
    expect(notifier.state.currencyCode, 'SAR');
    await notifier.setCurrency('USD');
    expect(notifier.state.currencyCode, 'USD');
    await notifier.setCurrency('YER');
    expect(notifier.state.currencyCode, 'YER');
  });

  test('distance unit changes via setDistanceUnit', () async {
    final notifier = await readyNotifier();
    await notifier.setDistanceUnit('miles');
    expect(notifier.state.distanceUnit, 'miles');
    await notifier.setDistanceUnit('km');
    expect(notifier.state.distanceUnit, 'km');
  });

  test('text size changes via setTextSize', () async {
    final notifier = await readyNotifier();
    await notifier.setTextSize('large');
    expect(notifier.state.textSize, 'large');
    await notifier.setTextSize('small');
    expect(notifier.state.textSize, 'small');
    await notifier.setTextSize('medium');
    expect(notifier.state.textSize, 'medium');
  });

  test('default map view changes via setDefaultMapView', () async {
    final notifier = await readyNotifier();
    await notifier.setDefaultMapView('list');
    expect(notifier.state.defaultMapView, 'list');
    await notifier.setDefaultMapView('map');
    expect(notifier.state.defaultMapView, 'map');
  });

  test('search radius and notifications persist together', () async {
    final notifier = await readyNotifier();
    await notifier.setSearchRadius(60);
    await notifier.setNotificationsEnabled(false);
    expect(notifier.state.searchRadiusKm, 60);
    expect(notifier.state.notificationsEnabled, false);
  });

  test('text size maps to the root text scaler', () {
    expect(const SettingsState(textSize: 'small').textScaleFactor, 0.85);
    expect(const SettingsState(textSize: 'medium').textScaleFactor, 1.0);
    expect(const SettingsState(textSize: 'large').textScaleFactor, 1.15);
  });

  test('distance display converts stored kilometres to miles', () {
    expect(const SettingsState(distanceUnit: 'km').displayDistance(16.09344),
        16.09344);
    expect(
      const SettingsState(distanceUnit: 'miles').displayDistance(16.09344),
      closeTo(10, 0.00001),
    );
  });

  test('new preferences reload from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final first = SettingsNotifier();
    await first.loaded;
    await first.setCurrency('USD');
    await first.setTextSize('large');
    await first.setDistanceUnit('miles');
    await first.setDefaultMapView('list');

    final reloaded = SettingsNotifier();
    await reloaded.loaded;
    expect(reloaded.state.currencyCode, 'USD');
    expect(reloaded.state.textSize, 'large');
    expect(reloaded.state.distanceUnit, 'miles');
    expect(reloaded.state.defaultMapView, 'list');
  });

  testWidgets('theme scope rebuilds route subtree on brightness change',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).loaded;
    final buildCount = ValueNotifier<int>(0);

    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: MaterialApp(home: _ThemeProbe(buildCount: buildCount)),
      ),
    );

    final before = buildCount.value;
    await tester.tap(find.byKey(const ValueKey('switch_theme')));
    await tester.pump();

    expect(container.read(settingsProvider).themeMode, ThemeMode.dark);
    expect(buildCount.value, greaterThan(before));
  });
}

class _ThemeProbe extends ConsumerWidget {
  const _ThemeProbe({required this.buildCount});

  final ValueNotifier<int> buildCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: AppThemeScope(
        child: Builder(
          builder: (context) {
            buildCount.value++;
            return TextButton(
              key: const ValueKey('switch_theme'),
              onPressed: () =>
                  ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark),
              child: const Text('switch'),
            );
          },
        ),
      ),
    );
  }
}
