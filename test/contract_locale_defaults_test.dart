import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/models/contract_default_text.dart';
import 'package:yemen_real_estate_portal/models/property_contract.dart';

void main() {
  final initialLocale = AppLocale.current;
  tearDown(() => AppLocale.current = initialLocale);

  PropertyContract buildContract(String dealType) {
    return PropertyContract.defaultTemplate(
      propertyId: 'property-1',
      ownerName: 'Owner',
      city: 'صنعاء',
      district: 'بيت بوس',
      price: 1000,
      dealType: dealType,
    );
  }

  test('Arabic locale keeps the original default contract text', () {
    AppLocale.current = const Locale('ar', 'YE');
    final contract = buildContract('rent');

    expect(contract.title, 'عقد إيجار شرعي وقانوني');
    expect(contract.ownerAddress, 'صنعاء، الجمهورية اليمنية');
    expect(contract.paymentFrequency, 'شهرياً مقدماً');
    expect(contract.durationText, 'سنة واحدة');
    expect(contract.utilitiesPayableBy,
        'المستأجر بالكامل (كهرباء، ماء، خدمات نظافة)');
    expect(contract.maintenanceLiability,
        'استلم المستأجر العين بحالة ممتازة وتعهد بتسليمها سليمة');
    expect(contract.latePaymentPolicy,
        'مهلة أسبوعين كحد أقصى وإلا يعتبر العقد مفسوخاً تلقائياً');
    expect(contract.customClauses, ContractDefaultText.arabic.rentClauses);
  });

  test('English locale generates English lease defaults at creation time', () {
    AppLocale.current = const Locale('en', 'US');
    final contract = buildContract('rent');

    expect(contract.title, 'Legal lease contract');
    expect(contract.ownerAddress, "Sana'a, Republic of Yemen");
    expect(contract.paymentFrequency, 'Monthly in advance');
    expect(contract.durationText, 'One full year');
    expect(contract.utilitiesPayableBy,
        'Tenant bears all utility bills (electricity, water, sanitation)');
    expect(contract.maintenanceLiability,
        'The tenant received the property in excellent condition and undertakes to return it intact');
    expect(contract.latePaymentPolicy,
        'A maximum grace period of two weeks; otherwise the contract is automatically terminated');
    expect(contract.customClauses, ContractDefaultText.english.rentClauses);
  });

  test('English sale defaults use sale title, payment and clauses', () {
    AppLocale.current = const Locale('en', 'US');
    final contract = buildContract('sale');

    expect(contract.title, 'Property sale and purchase contract');
    expect(contract.paymentFrequency, 'Full payment upon notarization');
    expect(contract.durationText, 'Permanent ownership');
    expect(contract.endDate, 'Indefinite');
    expect(contract.securityDeposit, 0.0);
    expect(contract.customClauses, ContractDefaultText.english.saleClauses);
  });

  test('generated default text survives JSON persistence', () {
    AppLocale.current = const Locale('en', 'US');
    final contract = buildContract('rent');
    final restored = PropertyContract.fromJson(contract.toJson());

    expect(restored.title, contract.title);
    expect(restored.paymentFrequency, contract.paymentFrequency);
    expect(restored.utilitiesPayableBy, contract.utilitiesPayableBy);
    expect(restored.customClauses, contract.customClauses);
  });
}
