import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/features/map/presentation/map_screen_args.dart';
import 'package:yemen_real_estate_portal/features/notifications/presentation/notifications_screen.dart';
import 'package:yemen_real_estate_portal/features/saved_searches/presentation/saved_searches_screen.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:yemen_real_estate_portal/models/map_query.dart';
import 'package:yemen_real_estate_portal/models/notification_item.dart';
import 'package:yemen_real_estate_portal/models/saved_search.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/providers/auth_provider.dart';
import 'package:yemen_real_estate_portal/providers/notification_provider.dart';
import 'package:yemen_real_estate_portal/providers/saved_search_provider.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/repositories/notification_repository.dart';
import 'package:yemen_real_estate_portal/repositories/saved_search_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository(this._user);

  UserProfile? _user;

  void setUser(UserProfile? user) => _user = user;

  @override
  Future<UserProfile?> getCurrentUser() async => _user;
}

UserProfile _user() => UserProfile(
      id: 'saved-search-user',
      fullName: 'مستخدم البحث',
      role: AppConstants.roleUser,
      isVerified: true,
      createdAt: DateTime(2026),
    );

ProviderContainer _container(UserProfile? user) {
  final container = ProviderContainer(
    overrides: [
      authProvider.overrideWith((ref) => AuthNotifier(_FakeAuthRepository(user))),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

Widget _routerApp(Widget child, ProviderContainer container) {
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
      GoRoute(
        path: '/map',
        builder: (context, state) => const Scaffold(body: Text('map')),
      ),
    ],
  );
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ar', 'YE'),
    ),
  );
}

void main() {
  setUp(() {
    AppConfig.setForceDemoModeForTesting(true);
    SupabaseService.demoSavedSearches = <SavedSearch>[];
    SupabaseService.demoNotifications = <NotificationItem>[];
  });

  tearDown(() {
    SupabaseService.demoSavedSearches = <SavedSearch>[];
    SupabaseService.demoNotifications = <NotificationItem>[];
    AppConfig.setForceDemoModeForTesting(false);
  });

  test('MapQuery saved JSON round-trips every alert filter', () {
    const query = MapQuery(
      freeText: 'شقة',
      dealType: 'rent',
      propertyTypeId: 'apartment',
      governorate: 'إب',
      district: 'ال970',
      minPrice: 100,
      maxPrice: 500,
      minBedrooms: 3,
      onlyFeatured: true,
      onlyExactCoordinates: true,
      nearbyCenter: LatLng(13.9667, 44.1833),
      radiusKm: 5,
      view: MapViewMode.map,
      source: MapQuerySource.featured,
    );

    final json =
        jsonDecode(jsonEncode(query.toSavedJson())) as Map<String, dynamic>;
    final restored = MapQuery.fromSavedJson(json);

    expect(restored.filterKey, query.filterKey);
    expect(restored.nearbyCenter, isNotNull);
    expect(restored.nearbyCenter!.latitude, 13.9667);
    expect(restored.view, MapViewMode.list);
    expect(restored.source, MapQuerySource.general);
  });

  test('MapQuery saved JSON ignores malformed legacy values', () {
    final restored = MapQuery.fromSavedJson(<String, dynamic>{
      'propertyTypeId': 42,
      'governorate': 7,
      'minPrice': 'not-a-number',
      'minBedrooms': '2',
      'onlyFeatured': 'true',
      'onlyExactCoordinates': '1',
      'nearbyLatitude': '13.5',
      'nearbyLongitude': 44.2,
      'radiusKm': 7,
    });

    expect(restored.propertyTypeId, isNull);
    expect(restored.governorate, isNull);
    expect(restored.minPrice, isNull);
    expect(restored.minBedrooms, 2);
    expect(restored.onlyFeatured, isTrue);
    expect(restored.onlyExactCoordinates, isTrue);
    expect(restored.nearbyCenter, isNotNull);
    expect(restored.radiusKm, 7);
  });

  test('SavedSearch maps Supabase rows both ways', () {
    const query = MapQuery(dealType: 'sale', governorate: 'صنعاء');
    final row = <String, dynamic>{
      'id': 'search-1',
      'user_id': 'saved-search-user',
      'name': 'شقق صنعاء',
      'query': query.toSavedJson(),
      'notify': false,
      'created_at': '2026-11-28T01:00:00Z',
      'updated_at': '2026-11-28T02:00:00Z',
    };

    // Supabase JSONB columns can arrive as Map<dynamic, dynamic>.
    final saved = SavedSearch.fromJson(<String, dynamic>{
      ...row,
      'query': Map<dynamic, dynamic>.from(query.toSavedJson()),
    });

    expect(saved.query.filterKey, query.filterKey);
    expect(saved.notify, isFalse);
    expect(saved.createdAt, DateTime.utc(2026, 11, 28, 1));
    expect(saved.toJson()['query']['governorate'], 'صنعاء');
    expect(saved.copyWith(notify: true).notify, isTrue);
  });

  test('MapScreenArgs.fromSavedSearch restores the full captured filter', () {
    const query = MapQuery(
      freeText: 'فيلا',
      dealType: 'sale',
      propertyTypeId: 'villa',
      governorate: 'إب',
      district: 'itim',
      minPrice: 1000,
      maxPrice: 9000,
      minBedrooms: 4,
      onlyFeatured: true,
      onlyExactCoordinates: true,
      nearbyCenter: LatLng(14.0, 44.0),
      radiusKm: 12,
    );
    final saved = SavedSearch(
      id: 's',
      userId: 'u',
      name: 'بحث',
      query: query,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    final args = MapScreenArgs.fromSavedSearch(saved);

    expect(args.initialListView, isTrue);
    expect(args.searchQuery, 'فيلا');
    expect(args.propertyTypeId, 'villa');
    expect(args.city, 'إب');
    expect(args.district, 'itim');
    expect(args.minPrice, 1000);
    expect(args.maxPrice, 9000);
    expect(args.minBedrooms, 4);
    expect(args.onlyFeatured, isTrue);
    expect(args.onlyExactCoordinates, isTrue);
    expect(args.nearbyCenter, isNotNull);
    expect(args.radiusKm, 12);
  });

  test('saved-search repository creates, updates and deletes in demo mode', () async {
    final repo = SavedSearchRepository();
    final created = await repo.createSavedSearch(
      userId: 'saved-search-user',
      name: 'إيجارات إب',
      query: const MapQuery(dealType: 'rent', governorate: 'إب'),
    );

    var all = await repo.getSavedSearches('saved-search-user');
    expect(all.map((item) => item.id), contains(created.id));

    await repo.updateSavedSearch(created.copyWith(name: 'إيجارات صنعاء'));
    all = await repo.getSavedSearches('saved-search-user');
    expect(
      all.firstWhere((item) => item.id == created.id).name,
      'إيجارات صنعاء',
    );

    await repo.deleteSavedSearch(
      id: created.id,
      userId: 'saved-search-user',
    );
    all = await repo.getSavedSearches('saved-search-user');
    expect(all.map((item) => item.id), isNot(contains(created.id)));
  });

  test('notification repository seeds and acknowledges demo alerts', () async {
    final repo = NotificationRepository();
    final initial = await repo.getNotifications('saved-search-user');
    expect(initial, isNotEmpty);
    expect(initial.first.isRead, isFalse);

    await repo.markAsRead(
      id: initial.first.id,
      userId: 'saved-search-user',
    );
    var after = await repo.getNotifications('saved-search-user');
    expect(
      after.firstWhere((item) => item.id == initial.first.id).isRead,
      isTrue,
    );

    await repo.markAllAsRead('saved-search-user');
    after = await repo.getNotifications('saved-search-user');
    expect(after.every((item) => item.isRead), isTrue);
  });

  test('saved-search and notification providers reload after sign-in', () async {
    final fakeAuth = _FakeAuthRepository(null);
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => AuthNotifier(fakeAuth)),
      ],
    );
    addTearDown(container.dispose);
    final auth = container.read(authProvider.notifier);
    await auth.loadCurrentUser();

    expect(container.read(savedSearchesProvider).value, isEmpty);
    expect(container.read(unreadNotificationsCountProvider), 0);

    fakeAuth.setUser(_user());
    await auth.loadCurrentUser();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    expect(container.read(savedSearchesProvider).value, isNotEmpty);
    expect(container.read(unreadNotificationsCountProvider), 1);
  });

  testWidgets('saved searches screen lists a stored search with alert toggle', (
    tester,
  ) async {
    final container = _container(_user());

    await tester.pumpWidget(
      _routerApp(const SavedSearchesScreen(), container),
    );
    await tester.pumpAndSettle();

    expect(find.text('عمليات البحث المحفوظة'), findsWidgets);
    expect(find.text('إيجارات إب'), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsWidgets);
    expect(find.text('فتح النتائج'), findsOneWidget);
  });

  testWidgets('notifications screen shows an unread alert', (tester) async {
    final container = _container(_user());

    await tester.pumpWidget(
      _routerApp(const NotificationsScreen(), container),
    );
    await tester.pumpAndSettle();

    expect(find.text('عقار جديد يطابق بحثك'), findsOneWidget);
    expect(find.text('تعليم الكل كمقروء'), findsOneWidget);
  });
}
