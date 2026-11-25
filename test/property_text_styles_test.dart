import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/theme/app_colors.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:yemen_real_estate_portal/core/theme/property_text_styles.dart';

void main() {
  // Avoid a runtime font download: these tests care about token identity and
  // colours, not the Cairo glyphs themselves.
  TextStyle fakeFont({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) =>
      TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: height,
      );

  setUp(() => PropertyTextStyles.setFontFactoryForTesting(fakeFont));
  tearDown(() => AppColors.isDark = false);
  tearDownAll(
    () => PropertyTextStyles.setFontFactoryForTesting(AppFonts.cairo),
  );

  group('PropertyTextStyles caching', () {
    test('Cairo styles are reused across rebuilds but stay brightness-aware',
        () {
      AppColors.isDark = false;
      final light = PropertyTextStyles.price();
      expect(light.color, AppColors.primary);
      expect(identical(light, PropertyTextStyles.price()), isTrue);

      AppColors.isDark = true;
      final dark = PropertyTextStyles.price();
      expect(dark.color, AppColors.primaryLight);
      expect(identical(dark, light), isFalse);
      expect(identical(dark, PropertyTextStyles.price()), isTrue);

      // Switching back must reuse the light instance, not grow the cache.
      AppColors.isDark = false;
      expect(identical(PropertyTextStyles.price(), light), isTrue);
    });

    test('token line heights are unchanged by caching', () {
      expect(PropertyTextStyles.price().height, 1.2);
      expect(PropertyTextStyles.title().height, 1.3);
      expect(PropertyTextStyles.meta().height, 1.25);
      expect(PropertyTextStyles.muted().height, 1.25);
      expect(PropertyTextStyles.chip().height, isNull);
      expect(PropertyTextStyles.badge().height, isNull);
      expect(PropertyTextStyles.caption().height, isNull);
    });
  });
}
