import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/settings/presentation/settings_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/providers/settings_provider.dart';

Widget _settingsApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar', 'YE'),
      home: const SettingsScreen(),
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

  testWidgets('About section renders a real version string, not a closure',
      (tester) async {
    final container = await readyContainer();
    await tester.pumpWidget(_settingsApp(container));

    await tester.scrollUntilVisible(
      find.text('الإصدار: ${AppConstants.appVersion}'),
      600,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('الإصدار: ${AppConstants.appVersion}'), findsOneWidget);
    expect(find.textContaining('Closure:'), findsNothing);
    expect(find.textContaining('() =>'), findsNothing);
  });

  testWidgets('currency rate fields change state and the live preview',
      (tester) async {
    final container = await readyContainer();
    await tester.pumpWidget(_settingsApp(container));

    final usdField = find.byKey(const ValueKey('usd_rate_field'));
    await tester.scrollUntilVisible(usdField, 600,
        scrollable: find.byType(Scrollable).first);
    await tester.enterText(
      find.descendant(of: usdField, matching: find.byType(TextField)),
      '300',
    );
    await tester.pump();

    expect(container.read(settingsProvider).usdToYerRate, 300);
    expect(find.textContaining('مثال:'), findsWidgets);

    final resetRates = find.byKey(const ValueKey('reset_currency_rates'));
    await tester.scrollUntilVisible(resetRates, 600,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(resetRates);
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).usdToYerRate, 250);
    expect(container.read(settingsProvider).sarToYerRate, 66.7);
  });

  testWidgets('tapping a currency field keeps the keyboard attached',
      (tester) async {
    final container = await readyContainer();
    await tester.pumpWidget(_settingsApp(container));

    final usdField = find.byKey(const ValueKey('usd_rate_field'));
    await tester.scrollUntilVisible(
      usdField,
      600,
      scrollable: find.byType(Scrollable).first,
    );
    final textField = find.descendant(
      of: usdField,
      matching: find.byType(TextField),
    );

    await tester.tap(textField);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    // The IME resize produces scroll updates; only a user drag may unfocus.
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.enterText(textField, '275');
    await tester.pump();
    expect(container.read(settingsProvider).usdToYerRate, 275);

    // A deliberate drag still dismisses the keyboard, as on the register form.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 200));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('reset-all asks first, then restores defaults', (tester) async {
    final container = await readyContainer();
    await container.read(settingsProvider.notifier).setCurrency('USD');
    await tester.pumpWidget(_settingsApp(container));

    final resetButton = find.byKey(const ValueKey('reset_all_settings'));
    await tester.scrollUntilVisible(resetButton, 600,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(find.text('إعادة تعيين جميع الإعدادات؟'), findsOneWidget);
    expect(container.read(settingsProvider).currencyCode, 'USD');

    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('إعادة تعيين الإعدادات'),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).currencyCode, 'YER');
    expect(find.text('إعادة تعيين جميع الإعدادات؟'), findsNothing);
  });
}
