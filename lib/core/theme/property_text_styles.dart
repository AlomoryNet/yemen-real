import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// Typography tokens shared by every property card variant.
///
/// These are getters (not constants) so the brightness-aware [AppColors]
/// getters are read at paint time and dark mode stays correct. Each distinct
/// Cairo variant is created once and reused: a dashboard rebuild used to build
/// ~100 styles, which kept the UI isolate busy on first frame.
class PropertyTextStyles {
  const PropertyTextStyles._();

  static final Map<(double, FontWeight, Color, double?), TextStyle> _styles =
      <(double, FontWeight, Color, double?), TextStyle>{};

  /// Indirection kept so unit tests can verify caching without depending on
  /// the bundled font asset.
  static TextStyle Function({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) _fontFactory = AppFonts.cairo;

  @visibleForTesting
  static void setFontFactoryForTesting(
    TextStyle Function({
      Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      double? height,
    }) factory,
  ) {
    _fontFactory = factory;
    _styles.clear();
  }

  static TextStyle _cairo({
    required double size,
    required FontWeight weight,
    required Color color,
    double? height,
  }) {
    final key = (size, weight, color, height);
    return _styles.putIfAbsent(
      key,
      () => _fontFactory(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      ),
    );
  }

  static TextStyle price({double size = 18, FontWeight weight = FontWeight.bold}) =>
      _cairo(
        size: size,
        weight: weight,
        color: AppColors.primaryInk,
        height: 1.2,
      );

  static TextStyle title({
    double size = 14,
    FontWeight weight = FontWeight.w600,
  }) =>
      _cairo(
        size: size,
        weight: weight,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle meta({double size = 12}) => _cairo(
        size: size,
        weight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.25,
      );

  static TextStyle muted({double size = 11}) => _cairo(
        size: size,
        weight: FontWeight.w400,
        color: AppColors.textMuted,
        height: 1.25,
      );

  static TextStyle chip({double size = 11.5}) => _cairo(
        size: size,
        weight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle badge({double size = 11}) => _cairo(
        size: size,
        weight: FontWeight.bold,
        color: AppColors.textLight,
      );

  /// Tiny teal text used for the "price confirmed" caption on the map card.
  static TextStyle caption({double size = 11}) => _cairo(
        size: size,
        weight: FontWeight.w600,
        color: AppColors.primaryInk,
      );
}
