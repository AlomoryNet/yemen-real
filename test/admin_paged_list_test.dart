import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';

import 'package:yemen_real_estate_portal/features/admin/presentation/widgets/admin_paged_list.dart';

void main() {
  testWidgets('AdminPagedList reveals rows incrementally via Load more', (
    tester,
  ) async {
    final items = List<String>.generate(50, (i) => 'Row $i');

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminPagedList<String>(
            items: items,
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    // Only the first page is built.
    expect(find.text('Row 0'), findsOneWidget);
    expect(find.text('Row 11'), findsOneWidget);
    expect(find.text('Row 12'), findsNothing);
    expect(find.byType(OutlinedButton), findsOneWidget);

    // Reveal the next page.
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(find.text('Row 12'), findsOneWidget);
    expect(find.text('Row 23'), findsOneWidget);
    expect(find.text('Row 24'), findsNothing);
  });

  testWidgets('AdminPagedList hides Load more when all rows fit', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminPagedList<String>(
            items: const ['A', 'B'],
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsNothing);
  });

  testWidgets('AdminPagedList asks the caller for external pages', (
    tester,
  ) async {
    var loadCalls = 0;
    Future<void> loadMore() async {
      loadCalls++;
    }

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminPagedList<String>(
            items: const ['A', 'B'],
            hasMore: true,
            onLoadMore: loadMore,
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);

    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();

    expect(loadCalls, 1);
  });

  testWidgets('AdminPagedList hides the button when the caller has no more', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AdminPagedList<String>(
            items: const ['A'],
            hasMore: false,
            onLoadMore: () async {},
            itemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsNothing);
  });
}
