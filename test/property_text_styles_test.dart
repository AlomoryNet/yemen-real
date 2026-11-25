import 'dart:math' as math;

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
  }) => TextStyle(
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
    test(
      'Cairo styles are reused across rebuilds but stay brightness-aware',
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
      },
    );

    test('token line heights are unchanged by caching', () {
      expect(PropertyTextStyles.price().height, 1.2);
      expect(PropertyTextStyles.title().height, 1.3);
      expect(PropertyTextStyles.meta().height, 1.25);
      expect(PropertyTextStyles.muted().height, 1.25);
      expect(PropertyTextStyles.chip().height, isNull);
      expect(PropertyTextStyles.badge().height, isNull);
      expect(PropertyTextStyles.featuredBadge().height, isNull);
      expect(PropertyTextStyles.caption().height, isNull);
    });

    test('featuredBadge keeps AA contrast on the deep amber fill', () {
      expect(PropertyTextStyles.featuredBadge().color, AppColors.onAccentBadge);

      final contrast =
          _contrastRatio(AppColors.onAccentBadge, AppColors.accentBadgeFill);
      expect(contrast, greaterThanOrEqualTo(4.5));
    });
  });
}

double _relativeLuminance(Color color) {
  double channel(int value) {
    final scaled = value / 255;
    return scaled <= 0.03928
        ? scaled / 12.92
        : math.pow((scaled + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.red) +
      0.7152 * channel(color.green) +
      0.0722 * channel(color.blue);
}

double _contrastRatio(Color a, Color b) {
  final first = _relativeLuminance(a);
  final second = _relativeLuminance(b);
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}
