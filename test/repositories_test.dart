import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/repositories/admin_repository.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/repositories/commission_repository.dart';
import 'package:yemen_real_estate_portal/repositories/property_repository.dart';
import 'package:yemen_real_estate_portal/repositories/rental_request_repository.dart';
import 'package:yemen_real_estate_portal/config/env_config.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    // Ensure initialized in isolated mock/demo mode for local repository unit testing
    EnvConfig.setForceDemoModeForTesting(true);
    await SupabaseService.initialize();
  });

  tearDownAll(() {
    EnvConfig.setForceDemoModeForTesting(false);
  });

  group('Repositories Execution Tests', () {
    test('AuthRepository sign in and sign out', () async {
      final authRepo = AuthRepository();
      final user = await authRepo.signIn(
        email: 'user@yemen.local',
        password: 'password123',
      );
      expect(user.id, isNotEmpty);
      expect(user.fullName, isNotEmpty);

      // Test Admin login with user specified credentials
      final adminUser = await authRepo.signIn(
        email: 'mohammed.f.saqqaf@gmail.com',
        password: '772522233',
      );
      expect(adminUser.isAdmin, isTrue);
      expect(adminUser.fullName, equals('م. محمد السقاف'));
      expect(adminUser.phone, equals('+967772522233'));

      await authRepo.signOut();
      final current = await authRepo.getCurrentUser();
      expect(current, isNull);
    });

    test('PropertyRepository fetch and filter properties', () async {
      final propRepo = PropertyRepository();
      final all = await propRepo.getProperties();
      expect(all, isNotEmpty);

      final rentOnly = await propRepo.getProperties(
        dealType: AppConstants.dealRent,
      );
      for (final p in rentOnly) {
        expect(p.dealType, equals(AppConstants.dealRent));
      }

      final saleOnly = await propRepo.getProperties(
        dealType: AppConstants.dealSale,
      );
      for (final p in saleOnly) {
        expect(p.dealType, equals(AppConstants.dealSale));
      }
    });

    test('PropertyRepository create and toggle favorite', () async {
      final propRepo = PropertyRepository();
      final newProperty = Property(
        id: '',
        ownerId: 'demo-user-1',
        title: 'شقة تجريبية جديدة في الستين',
        description: 'شقة واسعة ومجهزة',
        dealType: AppConstants.dealRent,
        propertyTypeId: 'apartment',
        city: 'صنعاء',
        district: 'الستين',
        price: 300,
        currency: AppConstants.currencyUsd,
        areaSqm: 140,
        contactPhone: '770000000',
        createdAt: DateTime.now(),
      );

      final created = await propRepo.createProperty(
        property: newProperty,
        imageUrls: ['https://example.com/test.jpg'],
      );
      expect(created.id, isNotEmpty);
      expect(created.title, equals(newProperty.title));

      // Toggle favorite
      final isFavAfterToggle = await propRepo.toggleFavorite(
        'test-user-1',
        created.id,
      );
      expect(isFavAfterToggle, isTrue);

      final isFavSecondToggle = await propRepo.toggleFavorite(
        'test-user-1',
        created.id,
      );
      expect(isFavSecondToggle, isFalse);
    });

    test('RentalRequestRepository submit inquiry request', () async {
      final reqRepo = RentalRequestRepository();
      final req = await reqRepo.submitRentalRequest(
        propertyId: 'prop-1',
        userId: 'test-user-1',
        fullName: 'نبيل سعيد',
        phone: '773333333',
        notes: 'عائلة مكونة من 3 أفراد',
      );

      expect(req.requestNumber, startsWith('REQ-'));
      expect(req.status, equals(AppConstants.reqStatusNew));
      expect(req.fullName, equals('نبيل سعيد'));
    });

    test('CommissionRepository manual record creation', () async {
      final commRepo = CommissionRepository();
      final comm = await commRepo.createCommission(
        propertyId: 'prop-1',
        liableParty: AppConstants.liableBoth,
        sellerAmount: 200,
        buyerAmount: 200,
        totalAmount: 400,
        currency: AppConstants.currencyUsd,
        reasonAndNotes: 'اتفاق توثيق مكتوب',
      );

      expect(comm.id, isNotEmpty);
      expect(comm.totalAmount, equals(400));
      expect(comm.liableParty, equals(AppConstants.liableBoth));
      expect(comm.settlementStatus, equals(AppConstants.commStatusDue));
    });

    test('AdminRepository stats and CSV exports with UTF-8 BOM', () async {
      final adminRepo = AdminRepository();
      final stats = await adminRepo.getDashboardStats();
      expect(stats.totalProperties, greaterThanOrEqualTo(0));
      expect(stats.totalUsers, greaterThan(0));

      final propRepo = PropertyRepository();
      final properties = await propRepo.getProperties();
      final propCsv = adminRepo.exportPropertiesToCsv(properties);
      expect(propCsv, startsWith('\uFEFF'));
      expect(propCsv, contains('عنوان العقار'));

      final reqRepo = RentalRequestRepository();
      final requests = await reqRepo.getUserRentalRequests('test-user-1');
      final reqCsv = adminRepo.exportRentalRequestsToCsv(requests);
      expect(reqCsv, startsWith('\uFEFF'));
      expect(reqCsv, contains('رقم الطلب'));

      final commRepo = CommissionRepository();
      final commissions = await commRepo.getCommissions();
      final commCsv = adminRepo.exportCommissionsToCsv(commissions);
      expect(commCsv, startsWith('\uFEFF'));
      expect(commCsv, contains('الطرف المتحمل'));
    });

    test(
      'AuthRepository strictly prevents unconfirmed email login and supports resend',
      () async {
        final authRepo = AuthRepository();
        const testEmail = 'unverified.tester@example.com';

        // 1. Sign up creates user in unverified state
        final signedUp = await authRepo.signUp(
          email: testEmail,
          password: 'Password123!',
          fullName: 'مستخدم تجريبي للتحقق',
          phone: '+967770112233',
        );
        expect(signedUp.isVerified, isFalse);

        // Current active user should still be null (no authenticated session granted)
        final currentBeforeConfirm = await authRepo.getCurrentUser();
        expect(currentBeforeConfirm, isNull);

        // 2. Attempting to sign in before confirmation throws email_not_confirmed
        try {
          await authRepo.signIn(email: testEmail, password: 'Password123!');
          fail('Should not allow login for unconfirmed email');
        } catch (e) {
          expect(e.toString(), contains('تأكيده'));
        }

        // 3. Resend confirmation email executes successfully
        await authRepo.resendConfirmationEmail(testEmail);

        // 4. Verifying user email allows login to succeed
        await authRepo.verifyUserEmail(testEmail);
        final confirmedLogin = await authRepo.signIn(
          email: testEmail,
          password: 'Password123!',
        );
        expect(confirmedLogin.email?.toLowerCase(), equals(testEmail));
        expect(confirmedLogin.isVerified, isTrue);

        await authRepo.signOut();
      },
    );
  });
}
