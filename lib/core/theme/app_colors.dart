import 'package:flutter/material.dart';

/// Central color tokens.
///
/// Screens use the semantic getters below so a single `isDark` switch keeps
/// text, surfaces and dividers readable in both themes. The `light*`/`dark*`
/// constants are used by [AppTheme] to build both ThemeData objects eagerly,
/// which means a theme never accidentally inherits the other theme's palette.
class AppColors {
  // Brand Primary & Heritage Tones
  static const Color primary = Color(0xFF134E4A); // Deep Teal Heritage
  static const Color primaryDark = Color(0xFF0F3B38);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color lightPrimaryMuted = Color(0xFFCCFBF1);
  static const Color darkPrimaryMuted = Color(0xFF134E4A);

  /// Foreground teal for text/icons on surfaces (bright in dark mode).
  static Color get primaryInk => isDark ? primaryLight : primary;

  // Amber & Accent Gold
  static const Color accent = Color(0xFFD97706); // Warm Amber Gold
  static const Color accentLight = Color(0xFFFDE68A);
  static const Color accentDark = Color(0xFF92400E);

  /// Foreground amber for text/icons on surfaces (bright in dark mode).
  static Color get accentInk => isDark ? accentLight : accentDark;

  // Light palette (explicit — used by AppTheme.lightTheme)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);

  // Dark palette (explicit — used by AppTheme.darkTheme)
  static const Color darkBackground = Color(0xFF0B1320);
  static const Color darkSurface = Color(0xFF152238);
  static const Color darkSurfaceVariant = Color(0xFF1E2D4A);
  static const Color darkBorder = Color(0xFF334663);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Status & Feedback
  static const Color success = Color(0xFF16A34A);
  static const Color successMuted = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFEA580C);
  static const Color warningMuted = Color(0xFFFFEDD5);
  static const Color error = Color(0xFFDC2626);
  static const Color errorMuted = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0284C7);
  static const Color infoMuted = Color(0xFFE0F2FE);

  /// Kept white for text over images/gradients/footers in either theme.
  static const Color textLight = Color(0xFFF8FAFC);

  /// Mirror of the effective app brightness, set from `main.dart`.
  /// Screens read the semantic getters below; they never need a BuildContext.
  static bool isDark = false;

  // Semantic, brightness-aware tokens used throughout the UI.
  static Color get background => isDark ? darkBackground : lightBackground;
  static Color get surface => isDark ? darkSurface : lightSurface;
  static Color get surfaceVariant =>
      isDark ? darkSurfaceVariant : lightSurfaceVariant;
  static Color get divider => isDark ? darkBorder : lightDivider;
  static Color get border => isDark ? darkBorder : lightBorder;
  static Color get textPrimary => isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textMuted => isDark ? darkTextMuted : lightTextMuted;
  static Color get primaryMuted =>
      isDark ? darkPrimaryMuted : lightPrimaryMuted;

  /// Elevation shadow tint, tuned per theme.
  static Color get shadow => isDark ? const Color(0x66000000) : const Color(0x1C000000);
}
