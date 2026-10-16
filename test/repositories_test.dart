import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/repositories/commission_repository.dart';
import 'package:yemen_real_estate_portal/repositories/property_repository.dart';
import 'package:yemen_real_estate_portal/repositories/rental_request_repository.dart';
import 'package:yemen_real_estate_portal/services/supabase_service.dart';

void main() {
  setUp(() async {
    // Ensure initialized in fallback/demo mode for local testing
    await SupabaseService.initialize();
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
  });
}
