import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/theme/app_colors.dart';
import 'package:yemen_real_estate_portal/features/auth/presentation/widgets/auth_ui.dart';

void main() {
  tearDown(() => AppColors.isDark = false);

  testWidgets('auth scaffold top-aligns a scrollable card under the app bar', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(
        home: AuthFormScaffold(
          title: 'Sign In',
          subtitle: 'Welcome back',
          child: SizedBox(height: 400),
        ),
      ),
    );

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);

    final scroll = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    expect(scroll.padding, const EdgeInsets.fromLTRB(16, 20, 16, 32));

    final cardTop = tester.getTopLeft(find.byType(Card)).dy;
    expect(cardTop, lessThan(200));
  });

  testWidgets('auth actions keep long labels inside the button', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AuthPrimaryButton(
                label: 'A very long localized call to action that must not '
                    'overflow the available button width',
                icon: Icons.login,
                onPressed: () {},
              ),
              AuthSecondaryButton(
                label: 'A very long demo shortcut label that must also be '
                    'wrapped safely on a narrow screen',
                icon: Icons.person_outline,
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );

    final primary = tester.widget<Text>(
      find.descendant(
        of: find.byType(ElevatedButton),
        matching: find.textContaining('A very long localized'),
      ),
    );
    expect(primary.maxLines, 1);
    expect(primary.overflow, TextOverflow.ellipsis);

    final secondary = tester.widget<Text>(
      find.descendant(
        of: find.byType(OutlinedButton),
        matching: find.textContaining('A very long demo shortcut'),
      ),
    );
    expect(secondary.maxLines, 2);
    expect(secondary.overflow, TextOverflow.ellipsis);

    expect(tester.takeException(), isNull);
  });

  testWidgets('primary action shows a spinner and rejects taps while loading', (
    tester,
  ) async {
    var pressed = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthPrimaryButton(
            label: 'Continue',
            loading: true,
            onPressed: () => pressed++,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    expect(pressed, 0);
  });

  testWidgets('info banners use semantic tones and an ellipsized action', (
    tester,
  ) async {
    AppColors.isDark = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthInfoBanner(
            tone: AuthInfoTone.warning,
            icon: Icons.schedule_outlined,
            message: 'Your email is not confirmed yet',
            actionLabel: 'Resend the confirmation message now',
            onAction: () {},
          ),
        ),
      ),
    );

    final bannerContainer = tester.widget<Container>(
      find.ancestor(
        of: find.byIcon(Icons.schedule_outlined),
        matching: find.byType(Container),
      ),
    );
    final decoration = bannerContainer.decoration as BoxDecoration;
    expect(decoration.color, AppColors.warningFill);

    final action = tester.widget<Text>(
      find.text('Resend the confirmation message now'),
    );
    expect(action.maxLines, 1);
    expect(action.overflow, TextOverflow.ellipsis);
  });
}
