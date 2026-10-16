import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/utils/formatters.dart';
import 'package:yemen_real_estate_portal/core/utils/validators.dart';
import 'package:yemen_real_estate_portal/models/commission.dart';
import 'package:yemen_real_estate_portal/models/property.dart';
import 'package:yemen_real_estate_portal/models/rental_request.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';

void main() {
  group('Models & Logic Tests', () {
    test('UserProfile isAdmin role check works correctly', () {
      final normalUser = UserProfile(
        id: 'u-1',
        fullName: 'أحمد علي',
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
      );
      expect(normalUser.isAdmin, isFalse);

      final adminUser = UserProfile(
        id: 'u-2',
        fullName: 'مدير النظام',
        role: AppConstants.roleAdmin,
        createdAt: DateTime.now(),
      );
      expect(adminUser.isAdmin, isTrue);

      final superAdminUser = UserProfile(
        id: 'u-3',
        fullName: 'المدير العام',
        role: AppConstants.roleSuperAdmin,
        createdAt: DateTime.now(),
      );
      expect(superAdminUser.isAdmin, isTrue);
    });

    test('Property getters work properly for rent and sale', () {
      final rentProperty = Property(
        id: 'p-1',
        ownerId: 'u-1',
        title: 'شقة للإيجار في حدة',
        description: 'شقة واسعة',
        dealType: AppConstants.dealRent,
        propertyTypeId: 'apartment',
        city: 'صنعاء',
        district: 'حدة',
        price: 500,
        currency: AppConstants.currencyUsd,
        areaSqm: 180,
        contactPhone: '770000000',
        createdAt: DateTime.now(),
      );

      expect(rentProperty.isForRent, isTrue);
      expect(rentProperty.isForSale, isFalse);
      expect(rentProperty.isPublished, isTrue);
    });

    test('Commission model records liable party both correctly', () {
      final comm = Commission(
        id: 'c-1',
        propertyId: 'p-1',
        liableParty: AppConstants.liableBoth,
        sellerAmount: 250,
        buyerAmount: 250,
        totalAmount: 500,
        currency: AppConstants.currencyUsd,
        recordedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      expect(comm.totalAmount, equals(500));
      expect(comm.liableParty, equals(AppConstants.liableBoth));
      expect(comm.settlementStatus, equals(AppConstants.commStatusDue));
    });

    test('RentalRequest status and request number', () {
      final req = RentalRequest(
        id: 'r-1',
        requestNumber: 'REQ-2026-1001',
        propertyId: 'p-1',
        userId: 'u-1',
        fullName: 'محمد ناصر',
        phone: '771234567',
        status: AppConstants.reqStatusNew,
        createdAt: DateTime.now(),
      );

      expect(req.requestNumber, equals('REQ-2026-1001'));
      expect(req.status, equals(AppConstants.reqStatusNew));
    });
  });

  group('Formatters Tests', () {
    test('formatPhoneForDialing handles Yemeni numbers properly', () {
      expect(
        Formatters.formatPhoneForDialing('770000000'),
        equals('+967770000000'),
      );
      expect(
        Formatters.formatPhoneForDialing('0770000000'),
        equals('+967770000000'),
      );
      expect(
        Formatters.formatPhoneForDialing('+967770000000'),
        equals('+967770000000'),
      );
      expect(
        Formatters.formatPhoneForDialing('00967770000000'),
        equals('+967770000000'),
      );
    });

    test('formatPhoneForWhatsApp cleans numbers for wa.me links', () {
      expect(
        Formatters.formatPhoneForWhatsApp('770000000'),
        equals('967770000000'),
      );
      expect(
        Formatters.formatPhoneForWhatsApp('+967770000000'),
        equals('967770000000'),
      );
      expect(
        Formatters.formatPhoneForWhatsApp('00967770000000'),
        equals('967770000000'),
      );
    });

    test('formatArea appends m2 symbol', () {
      expect(Formatters.formatArea(150), contains('م²'));
    });
  });

  group('Validators Tests', () {
    test('requiredField validation', () {
      expect(Validators.requiredField(null), isNotNull);
      expect(Validators.requiredField(''), isNotNull);
      expect(Validators.requiredField('  '), isNotNull);
      expect(Validators.requiredField('نص صحيح'), isNull);
    });

    test('email validation', () {
      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('test@example.com'), isNull);
    });

    test('phone validation', () {
      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('770000000'), isNull);
      expect(Validators.phone('+967770000000'), isNull);
    });

    test('positiveNumber validation', () {
      expect(Validators.positiveNumber('-10'), isNotNull);
      expect(Validators.positiveNumber('0'), isNotNull);
      expect(Validators.positiveNumber('abc'), isNotNull);
      expect(Validators.positiveNumber('1000'), isNull);
    });
  });
}
