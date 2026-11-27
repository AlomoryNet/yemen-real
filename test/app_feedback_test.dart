import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/core/utils/app_feedback.dart';
import 'package:yemen_real_estate_portal/providers/settings_provider.dart';

class _FeedbackButton extends ConsumerStatefulWidget {
  const _FeedbackButton({super.key, required this.message});

  final String message;

  @override
  ConsumerState<_FeedbackButton> createState() => _FeedbackButtonState();
}

class _FeedbackButtonState extends ConsumerState<_FeedbackButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => showOptionalFeedback(context, ref, widget.message),
      child: const Text('tap'),
    );
  }
}

void main() {
  Future<ProviderContainer> readyContainer() async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(settingsProvider.notifier).loaded;
    return container;
  }

  testWidgets('optional feedback follows the notifications setting', (
    tester,
  ) async {
    final container = await readyContainer();
    final buttonKey = GlobalKey<_FeedbackButtonState>();

    Widget app(String message) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: _FeedbackButton(key: buttonKey, message: message),
          ),
        ),
      ),
    );

    await tester.pumpWidget(app('Saved on'));
    await tester.tap(find.text('tap'));
    await tester.pump();
    expect(find.text('Saved on'), findsOneWidget);

    await container
        .read(settingsProvider.notifier)
        .setNotificationsEnabled(false);
    // Rebuild with a different message so the old snackbar cannot be mistaken
    // for new feedback; the global key preserves the same button state.
    await tester.pumpWidget(app('Saved off'));
    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(find.text('Saved off'), findsNothing);
  });
}
