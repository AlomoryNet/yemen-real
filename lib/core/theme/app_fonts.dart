import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Local Cairo typography helpers.
///
/// The app bundles the variable `assets/fonts/Cairo.ttf`, which exposes a
/// `wght` axis from 200 to 1000. These helpers set that axis explicitly so a
/// requested [FontWeight] renders correctly without any Google Fonts runtime
/// HTTP fetch.
class AppFonts {
  const AppFonts._();

  /// Font family declared in `pubspec.yaml` for the bundled variable font.
  static const String family = 'CairoLocal';

  static TextStyle cairo({
    TextStyle? textStyle,
    Color? color,
    Color? backgroundColor,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    ui.TextBaseline? textBaseline,
    double? height,
    ui.Locale? locale,
    ui.Paint? foreground,
    ui.Paint? background,
    List<Shadow>? shadows,
    List<ui.FontFeature>? fontFeatures,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
  }) {
    final requested = TextStyle(
      color: color,
      backgroundColor: backgroundColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      textBaseline: textBaseline,
      height: height,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
    );
    final effective = textStyle == null ? requested : textStyle.merge(requested);
    final variations = effective.fontVariations ?? <ui.FontVariation>[
      if (effective.fontWeight != null)
        ui.FontVariation('wght', _wght(effective.fontWeight!)),
    ];

    return effective.copyWith(
      fontFamily: family,
      fontVariations: variations.isEmpty ? null : variations,
    );
  }

  /// Builds a Cairo [TextTheme] from an optional Material baseline.
  static TextTheme cairoTextTheme([TextTheme? textTheme]) {
    textTheme ??= ThemeData.light().textTheme;
    return TextTheme(
      displayLarge: cairo(textStyle: textTheme.displayLarge),
      displayMedium: cairo(textStyle: textTheme.displayMedium),
      displaySmall: cairo(textStyle: textTheme.displaySmall),
      headlineLarge: cairo(textStyle: textTheme.headlineLarge),
      headlineMedium: cairo(textStyle: textTheme.headlineMedium),
      headlineSmall: cairo(textStyle: textTheme.headlineSmall),
      titleLarge: cairo(textStyle: textTheme.titleLarge),
      titleMedium: cairo(textStyle: textTheme.titleMedium),
      titleSmall: cairo(textStyle: textTheme.titleSmall),
      bodyLarge: cairo(textStyle: textTheme.bodyLarge),
      bodyMedium: cairo(textStyle: textTheme.bodyMedium),
      bodySmall: cairo(textStyle: textTheme.bodySmall),
      labelLarge: cairo(textStyle: textTheme.labelLarge),
      labelMedium: cairo(textStyle: textTheme.labelMedium),
      labelSmall: cairo(textStyle: textTheme.labelSmall),
    );
  }

  /// Maps Flutter's 100–900 weights onto the bundled font's 200–1000 axis.
  static double _wght(FontWeight weight) =>
      ((weight.index + 1) * 100).clamp(200, 1000).toDouble();
}
