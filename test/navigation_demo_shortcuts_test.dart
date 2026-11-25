import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/features/auth/presentation/login_screen.dart';
import 'package:yemen_real_estate_portal/features/profile/presentation/profile_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_bottom_nav_bar.dart';
import 'package:yemen_real_estate_portal/shared/widgets/app_drawer.dart';

Widget _arabicApp(Widget child) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => child,
      ),
    ],
  );
  return ProviderScope(
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar', 'YE'),
    ),
  );
}

void main() {
  test('drawer keeps root destinations separate from pushed Profile', () {
    expect(
      AppDrawer.rootRoutes,
      containsAll(<String>['/', '/map', '/my-properties', '/admin']),
    );
    expect(AppDrawer.rootRoutes.contains('/profile'), isFalse);
  });

  testWidgets('quick demo user shortcut fills a valid password', (
    tester,
  ) async {
    await tester.pumpWidget(_arabicApp(const LoginScreen()));

    final shortcut = find.text('حساب معلن (إيميل وكلمة مرور)');
    await tester.ensureVisible(shortcut);
    await tester.tap(shortcut);
    await tester.pump();

    final fields = find.byType(TextFormField);
    expect(fields, findsNWidgets(2));
    expect(
      tester.widget<TextFormField>(fields.at(0)).controller!.text,
      'user@yemenrealestate.local',
    );
    expect(
      tester.widget<TextFormField>(fields.at(1)).controller!.text,
      'Demo@2026',
    );
  });

  testWidgets('Profile is a hierarchical page without bottom navigation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(_arabicApp(const ProfileScreen()));
    await tester.pump();

    expect(
      find.byKey(const ValueKey('app_header_back_button')),
      findsOneWidget,
    );
    expect(find.byType(AppBottomNavBar), findsNothing);
    expect(find.byKey(const ValueKey('app_header_menu_button')), findsNothing);
  });
}
