import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/theme/app_theme.dart';
import 'package:yemen_real_estate_portal/features/home/presentation/home_trust_section.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';

Widget _app(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('ar', 'YE'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  testWidgets('landing trust section renders its heading, stats and pillars', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const HomeTrustSection()));
    await tester.pumpAndSettle();

    expect(find.text('بوابتك للعقارات في اليمن'), findsOneWidget);
    expect(find.text('لماذا تختار بوابة اليمن العقارية؟'), findsOneWidget);

    for (final value in ['440+', '22', '103', '0']) {
      expect(find.text(value), findsOneWidget);
    }

    for (final title in [
      'إعلانات موثّقة',
      'خريطة تفاعلية',
      'تواصل مباشر',
      'دعم محلي',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('landing trust section adapts to a wide window', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const HomeTrustSection()));
    await tester.pumpAndSettle();

    expect(find.text('عقار للبيع والإيجار'), findsOneWidget);
    expect(find.text('تغطية كل المحافظات'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
