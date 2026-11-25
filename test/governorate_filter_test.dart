import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/constants/app_constants.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';

void main() {
  group("Sana'a governorate alias matching", () {
    test('treats the capital and the governorate as one search area', () {
      expect(AppConstants.canonicalGovernorate('صنعاء'), 'صنعاء');
      expect(AppConstants.canonicalGovernorate('أمانة العاصمة'), 'صنعاء');
      expect(AppConstants.canonicalGovernorate('أمانة العاصمة صنعاء'), 'صنعاء');
      expect(AppConstants.canonicalGovernorate('محافظة صنعاء'), 'صنعاء');

      expect(AppConstants.governorateMatches('صنعاء', 'أمانة العاصمة'), isTrue);
      expect(AppConstants.governorateMatches('أمانة العاصمة', 'صنعاء'), isTrue);
      expect(AppConstants.governorateMatches('صنعاء', 'محافظة صنعاء'), isTrue);
      expect(AppConstants.governorateMatches('صنعاء', 'عدن'), isFalse);
    });

    test('finds the two Bayt Bous listings when صنعاء is selected', () {
      final matches = DemoPropertiesGenerator.cachedDemoProperties.where((p) {
        return p.status == AppConstants.statusPublished &&
            AppConstants.governorateMatches('صنعاء', p.city) &&
            p.district == 'بيت بوس';
      }).toList();

      expect(matches, hasLength(2));
      expect(matches.map((p) => p.city).toSet(), {'أمانة العاصمة'});
    });
  });
}
