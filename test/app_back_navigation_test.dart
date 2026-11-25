import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/config/app_router.dart';

void main() {
  group('app back navigation policy', () {
    test('exit info bar is bottom-anchored, not floating in the middle', () {
      final snackBar = exitInfoSnackBar(message: 'Press again to exit');

      expect(snackBar.behavior, SnackBarBehavior.fixed);
      expect(snackBar.margin, isNull);
    });

    test('auth locations are only root-like when they have no stack', () {
      expect(isAuthFlowLocation('/login?redirectTo=%2Fmap'), isTrue);
      expect(isAuthFlowLocation('/register'), isTrue);
      expect(isAuthFlowLocation('/forgot-password'), isTrue);
      expect(isAuthFlowLocation('/map'), isFalse);
      expect(isAuthFlowLocation('/'), isFalse);
    });

    testWidgets('Back pops an auth screen pushed from inside the app', (
      tester,
    ) async {
      final navKey = GlobalKey<NavigatorState>();
      final router = GoRouter(
        navigatorKey: navKey,
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('home screen'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('login screen'))),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      router.push('/login');
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/login');
      expect(find.text('login screen'), findsOneWidget);

      final nav = navKey.currentState!;
      expect(nav.canPop(), isTrue);

      final result = await appBackPress(
        currentLocation: router.state.uri.toString(),
        nav: nav,
        navigationHistory: const <String>['/', '/login'],
        context: tester.element(find.text('login screen')),
        lastBackPressTime: null,
      );

      expect(result.handled, isTrue);
      await tester.pumpAndSettle();

      expect(router.state.uri.path, '/');
      expect(find.text('home screen'), findsOneWidget);
    });
  });
}
