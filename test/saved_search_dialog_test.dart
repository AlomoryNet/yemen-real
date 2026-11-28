import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/yemen_map_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/saved_search.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/providers/auth_provider.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

import 'helpers/maplibre_test_stub.dart';

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<UserProfile?> getCurrentUser() async => UserProfile(
    id: 'saved-search-user',
    fullName: 'Test',
    role: AppConstants.roleUser,
    isVerified: true,
    createdAt: DateTime(2026),
  );
}

void main() {
  setUp(() async {
    registerFakeMapLibrePlatform();
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
    SupabaseService.demoSavedSearches = <SavedSearch>[];
  });

  tearDown(() {
    SupabaseService.demoSavedSearches = <SavedSearch>[];
    AppConfig.setForceDemoModeForTesting(false);
  });

  testWidgets('saving a search from the filter sheet tears down cleanly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(_FakeAuthRepository())),
      ],
    );
    addTearDown(container.dispose);
    await container.read(authProvider.notifier).loadCurrentUser();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar', 'YE'),
          home: YemenMapScreen(key: UniqueKey()),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('الفلاتر ✓'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.ensureVisible(find.byTooltip('حفظ البحث'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byTooltip('حفظ البحث'));
    await tester.pumpAndSettle();

    expect(find.text('حفظ البحث الحالي'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'تجربة');
    await tester.tap(find.widgetWithText(FilledButton, 'حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('تم حفظ البحث'), findsOneWidget);
    expect(
      SupabaseService.demoSavedSearches.where((s) => s.name == 'تجربة'),
      hasLength(1),
    );
  });
}
