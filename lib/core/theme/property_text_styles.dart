import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Typography tokens shared by every property card variant.
///
/// These are getters (not constants) so the brightness-aware [AppColors]
/// getters are read at paint time and dark mode stays correct.
class PropertyTextStyles {
  const PropertyTextStyles._();

  static TextStyle price({double size = 18, FontWeight weight = FontWeight.bold}) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.primaryInk,
        height: 1.2,
      );

  static TextStyle title({
    double size = 14,
    FontWeight weight = FontWeight.w600,
  }) =>
      GoogleFonts.cairo(
        fontSize: size,
        fontWeight: weight,
        color: AppColors.textPrimary,
        height: 1.3,
      );

  static TextStyle meta({double size = 12}) => GoogleFonts.cairo(
        fontSize: size,
        color: AppColors.textSecondary,
        height: 1.25,
      );

  static TextStyle muted({double size = 11}) => GoogleFonts.cairo(
        fontSize: size,
        color: AppColors.textMuted,
        height: 1.25,
      );

  static TextStyle chip({double size = 11.5}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle badge({double size = 11}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      );

  /// Tiny teal text used for the "price confirmed" caption on the map card.
  static TextStyle caption({double size = 11}) => GoogleFonts.cairo(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryInk,
      );
}
