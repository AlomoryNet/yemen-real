import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/shared/widgets/deferred_screen.dart';

Widget _subject({
  required Future<void> Function() load,
  Widget Function()? builder,
}) {
  return MaterialApp(
    home: DeferredScreen(
      load: load,
      builder: builder ?? () => const Text('ready'),
      loadingText: 'loading',
      errorText: 'failed',
      retryText: 'Retry',
    ),
  );
}

void main() {
  testWidgets('shows a loader until the deferred library is ready', (
    tester,
  ) async {
    final completer = Completer<void>();
    await tester.pumpWidget(_subject(load: () => completer.future));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('ready'), findsNothing);

    completer.complete();
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('ready'), findsOneWidget);
  });

  testWidgets('offers a retry when loading fails', (tester) async {
    var calls = 0;
    Future<void> load() async {
      calls++;
      if (calls == 1) throw StateError('offline');
    }

    await tester.pumpWidget(_subject(load: load));
    await tester.pumpAndSettle();

    expect(find.text('failed'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text('failed'), findsNothing);
    expect(find.text('ready'), findsOneWidget);
  });
}
