import 'package:flutter/material.dart';

/// Locale mirror for code that has no `BuildContext` (constants, repositories,
/// services). Updated from `main.dart` whenever the Settings locale changes.
class AppLocale {
  static Locale current = const Locale('ar', 'YE');

  static bool get isArabic => current.languageCode == 'ar';
}
