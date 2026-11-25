import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/repositories/property_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    AppConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    AppConfig.setForceDemoModeForTesting(false);
  });

  group('Sole Publishing Admin & Review Lifecycle Tests', () {
    test(
      'Sole administrator profile has super_admin role and Mohammed Al-Saqqaf name',
      () {
        final admin = UserProfile(
          id: 'admin-mohammed-saqqaf',
          fullName: 'م/محمد السقاف',
          email: 'mo772522233@gmail.com',
          role: AppConstants.roleSuperAdmin,
          isVerified: true,
          createdAt: DateTime.now(),
        );

        expect(admin.isAdmin, isTrue);
        expect(admin.role, equals(AppConstants.roleSuperAdmin));
        expect(admin.fullName, equals('م/محمد السقاف'));
        expect(admin.email, equals('mo772522233@gmail.com'));
      },
    );

    test('Regular user is strictly NOT an admin', () {
      final user = UserProfile(
        id: 'user-regular-1',
        fullName: 'مستخدم عادي',
        email: 'regular@example.com',
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime.now(),
      );

      expect(user.isAdmin, isFalse);
    });

    test(
      'Property approval transitions status to published and records review timestamp',
      () async {
        final repo = PropertyRepository();

        final pendingProp = Property(
          id: 'test-prop-pending',
          ownerId: 'u-1',
          title: 'عقار تجريبي بانتظار الموافقة',
          description: 'وصف العقار',
          dealType: AppConstants.dealSale,
          propertyTypeId: 'apartment',
          city: 'صنعاء',
          district: 'حدة',
          price: 150000,
          areaSqm: 120,
          contactPhone: '772522233',
          status: AppConstants.statusPending,
          createdAt: DateTime.now(),
        );
        SupabaseService.demoProperties.add(pendingProp);

        expect(pendingProp.status, equals(AppConstants.statusPending));

        // Approve property publishing
        await repo.approvePropertyPublishing('test-prop-pending');

        final updated = SupabaseService.demoProperties.firstWhere(
          (p) => p.id == 'test-prop-pending',
        );
        expect(updated.status, equals(AppConstants.statusPublished));
        expect(updated.isPublished, isTrue);
        expect(updated.reviewedAt, isNotNull);
      },
    );

    test(
      'Property rejection transitions status to rejected and records reason',
      () async {
        final repo = PropertyRepository();

        final pendingProp = Property(
          id: 'test-prop-to-reject',
          ownerId: 'u-1',
          title: 'عقار تجريبي مخالف',
          description: 'وصف العقار',
          dealType: AppConstants.dealSale,
          propertyTypeId: 'apartment',
          city: 'صنعاء',
          district: 'حدة',
          price: 150000,
          areaSqm: 120,
          contactPhone: '772522233',
          status: AppConstants.statusPending,
          createdAt: DateTime.now(),
        );
        SupabaseService.demoProperties.add(pendingProp);

        // Reject property publishing
        await repo.rejectPropertyPublishing(
          'test-prop-to-reject',
          'مخالفة معايير التسعير المعتمدة',
        );

        final updated = SupabaseService.demoProperties.firstWhere(
          (p) => p.id == 'test-prop-to-reject',
        );
        expect(updated.status, equals(AppConstants.statusRejected));
        expect(
          updated.rejectionReason,
          equals('مخالفة معايير التسعير المعتمدة'),
        );
        expect(updated.reviewedAt, isNotNull);
      },
    );
  });
}
