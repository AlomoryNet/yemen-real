import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_logo.dart';
import 'package:yemen_real_estate_portal/shared/widgets/empty_state_view.dart';
import 'package:yemen_real_estate_portal/shared/widgets/loading_view.dart';
import 'package:yemen_real_estate_portal/shared/widgets/status_badge.dart';

void main() {
  testWidgets('AppLogo renders Arabic title correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: Scaffold(body: AppLogo(size: 40))),
    );

    expect(find.text(AppConstants.appNameAr), findsOneWidget);
    expect(find.text(AppConstants.appNameEn), findsOneWidget);
  });

  testWidgets('StatusBadge displays correct label for deal and status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: Scaffold(
          body: Column(
            children: [
              StatusBadge.dealType(AppConstants.dealSale),
              StatusBadge.dealType(AppConstants.dealRent),
              StatusBadge.rentalRequest(AppConstants.reqStatusNew),
            ],
          ),
        ),
      ),
    );

    expect(find.text('للبيع'), findsOneWidget);
    expect(find.text('للإيجار'), findsOneWidget);
    expect(find.text('جديد'), findsOneWidget);
  });

  testWidgets('EmptyStateView renders title and action button', (
    WidgetTester tester,
  ) async {
    bool clicked = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: Scaffold(
          body: EmptyStateView(
            title: 'لا توجد نتائج',
            description: 'يرجى المحاولة لاحقاً',
            actionText: 'إعادة المحاولة',
            onAction: () => clicked = true,
          ),
        ),
      ),
    );

    expect(find.text('لا توجد نتائج'), findsOneWidget);
    expect(find.text('يرجى المحاولة لاحقاً'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await tester.tap(find.text('إعادة المحاولة'));
    expect(clicked, isTrue);
  });

  testWidgets('LoadingView renders message and progress indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: Scaffold(body: LoadingView(message: 'جاري التحميل...')),
      ),
    );

    expect(find.text('جاري التحميل...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
