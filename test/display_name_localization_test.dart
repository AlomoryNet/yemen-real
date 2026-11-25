import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_labels_en.dart';
import 'package:yemen_real_estate_portal/core/l10n/app_locale.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';

void main() {
  final initialLocale = AppLocale.current;
  tearDown(() => AppLocale.current = initialLocale);

  test('governorate display names follow the active locale', () {
    AppLocale.current = const Locale('ar', 'YE');
    expect(AppConstants.getGovernorateNameAr('أمانة العاصمة'), 'أمانة العاصمة');
    expect(AppConstants.getGovernorateNameAr('صنعاء'), 'صنعاء');

    AppLocale.current = const Locale('en', 'US');
    expect(AppConstants.getGovernorateNameAr('أمانة العاصمة'), "Sana'a Capital");
    expect(AppConstants.getGovernorateNameAr('صنعاء'), "Sana'a Governorate");
    expect(AppConstants.getGovernorateNameAr('محافظة صنعاء'),
        "Sana'a Governorate");
    expect(AppConstants.getGovernorateNameAr('عدن'), 'Aden');
    expect(AppConstants.getGovernorateNameAr('مكان غير معروف'),
        'مكان غير معروف');
  });

  test('demo location English names are display labels, not slugs', () {
    expect(AppLabelsEn.governorate['أمانة العاصمة'], "Sana'a Capital");
    expect(AppLabelsEn.governorate['صنعاء'], "Sana'a Governorate");
    expect(AppLabelsEn.governorate.values, isNot(contains('sanaa_capital')));
    expect(AppLabelsEn.governorate.values, isNot(contains('sanaa_gov')));
  });

  test('district display names follow the active locale', () {
    AppLocale.current = const Locale('ar', 'YE');
    expect(AppConstants.getDistrictNameAr('بيت بوس'), 'بيت بوس');

    AppLocale.current = const Locale('en', 'US');
    expect(AppConstants.getDistrictNameAr('بيت بوس'), 'Bayt Bous');
    expect(AppConstants.getDistrictNameAr('المكلا'), 'Mukalla');
    expect(AppConstants.getDistrictNameAr('حي غير معروف'), 'حي غير معروف');
  });

  test('every demo district has an English display label', () {
    AppLocale.current = const Locale('en', 'US');
    for (final governorate in DemoPropertiesGenerator.allGovernorates) {
      for (final district in governorate.districts) {
        expect(
          AppConstants.getDistrictNameAr(district),
          isNot(district),
          reason: 'Missing English label for $district',
        );
      }
    }
  });
}
