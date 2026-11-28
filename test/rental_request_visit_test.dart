import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/core/theme/app_colors.dart';
import 'package:yemen_real_estate_portal/features/property_requests/presentation/my_rental_requests_screen.dart';
import 'package:yemen_real_estate_portal/features/property_requests/presentation/rental_request_modal.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/rental_request.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/providers/auth_provider.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

class _FakeAuthRepository extends AuthRepository {
  @override
  Future<UserProfile?> getCurrentUser() async => UserProfile(
    id: 'demo-user-2',
    fullName: 'Visit Tester',
    phone: '770000000',
    role: AppConstants.roleUser,
    isVerified: true,
    createdAt: DateTime(2026),
  );
}

Widget _localizedApp({required Widget child}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en', 'US'),
    home: Scaffold(body: child),
  );
}

void main() {
  late ProviderContainer container;

  setUp(() async {
    AppLocale.current = const Locale('en', 'US');
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(_FakeAuthRepository())),
      ],
    );
    await container.read(authProvider.notifier).loadCurrentUser();
  });

  tearDown(() {
    container.dispose();
    AppConfig.setForceDemoModeForTesting(false);
    AppLocale.current = const Locale('ar', 'YE');
  });

  testWidgets('my requests shows the scheduled property visit', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final visit = DateTime(2026, 12, 2, 10, 30);
    SupabaseService.demoRentalRequests = [
      RentalRequest(
        id: 'visit-req-1',
        requestNumber: 'REQ-2026-2001',
        propertyId: 'demo-property-1',
        userId: 'demo-user-2',
        fullName: 'Visit Tester',
        phone: '771234567',
        scheduledVisitAt: visit,
        status: AppConstants.reqStatusContacted,
        createdAt: DateTime(2026, 11, 28),
        propertyTitle: 'Test rental',
      ),
    ];

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedApp(child: const MyRentalRequestsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Scheduled visit:'), findsOneWidget);
    expect(find.textContaining('2026/12/02 10:30'), findsOneWidget);
    expect(find.textContaining('No visit scheduled yet'), findsNothing);
  });

  testWidgets('rental request form exposes the optional visit picker', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedApp(
          child: RentalRequestModal(
            property: SupabaseService.demoProperties.first,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Preferred visit time (optional)'), findsOneWidget);
    expect(find.text('Pick a visit date and time'), findsOneWidget);
  });

  testWidgets('success note uses theme-aware readable colors', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    AppColors.isDark = true;
    addTearDown(() => AppColors.isDark = false);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _localizedApp(
          child: RentalRequestModal(
            property: SupabaseService.demoProperties.first,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final submit = find.text('Send Rental Request Now');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    final note = find.textContaining('Note: This request');
    expect(note, findsOneWidget);
    expect(tester.widget<Text>(note).style?.color, AppColors.warningInk);

    final noteContainer = tester.widget<Container>(
      find.ancestor(of: note, matching: find.byType(Container)).first,
    );
    expect(
      (noteContainer.decoration as BoxDecoration).color,
      AppColors.warningFill,
    );
  });
}
