import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/repositories/admin_repository.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
  });

  test('demo store keeps 440 published listings and adds review data', () async {
    final properties = SupabaseService.demoProperties;
    expect(
      properties.where((p) => p.status == AppConstants.statusPublished).length,
      440,
    );
    expect(
      properties.where((p) => p.status == AppConstants.statusPending).length,
      3,
    );
    for (final id in ['demo-pending-1', 'demo-pending-2', 'demo-pending-3']) {
      expect(properties.any((p) => p.id == id), isTrue, reason: id);
    }

    // The canonical Yemen + Bayt Bous regression must stay at two listings;
    // pending demo submissions must not leak into published map results.
    final baytBous = properties
        .where(
          (p) =>
              p.status == AppConstants.statusPublished &&
              p.district == 'بيت بوس' &&
              (AppConstants.governorateMatches('صنعاء', p.city) ||
                  AppConstants.governorateMatches('أمانة العاصمة', p.city)),
        )
        .toList();
    expect(baytBous, hasLength(2));
  });

  test('admin demo records refer to real properties', () {
    final ids = SupabaseService.demoProperties.map((p) => p.id).toSet();

    expect(SupabaseService.demoRentalRequests, hasLength(4));
    expect(SupabaseService.demoCommissions, hasLength(4));
    expect(SupabaseService.demoReports, hasLength(3));

    for (final request in SupabaseService.demoRentalRequests) {
      expect(ids.contains(request.propertyId), isTrue, reason: request.id);
    }
    for (final commission in SupabaseService.demoCommissions) {
      expect(ids.contains(commission.propertyId), isTrue, reason: commission.id);
    }
    for (final report in SupabaseService.demoReports) {
      expect(ids.contains(report.propertyId), isTrue, reason: report.id);
    }
    for (final favoriteId in SupabaseService.demoFavoriteIds) {
      expect(ids.contains(favoriteId), isTrue, reason: favoriteId);
    }
  });

  test('quick demo logins resolve to stable demo profiles', () async {
    final auth = AuthRepository();

    final user = await auth.signIn(
      email: 'user@yemenrealestate.local',
      password: 'Demo@2026',
    );
    expect(user.id, 'demo-user-2');
    expect(user.isAdmin, isFalse);

    final admin = await auth.signIn(
      email: 'mo772522233@gmail.com',
      password: 'Demo@2026',
    );
    expect(admin.role, AppConstants.roleSuperAdmin);

    final stats = await AdminRepository().getDashboardStats();
    expect(stats.totalUsers, SupabaseService.demoUsers.length);
    expect(stats.totalUsers, greaterThan(1));
  });
}

