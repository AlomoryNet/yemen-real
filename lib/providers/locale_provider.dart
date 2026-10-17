// Yemen Real Estate Portal — بوابة اليمن العقارية
// Locale Provider — إدارة وتغيير لغة التطبيق (العربية / English)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _prefKey = 'selected_app_language_code';

  LocaleNotifier() : super(const Locale('ar')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && (code == 'ar' || code == 'en')) {
        state = Locale(code);
      }
    } catch (_) {}
  }

  Future<void> setLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    state = Locale(languageCode);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {}
  }

  Future<void> toggleLocale() async {
    final nextCode = state.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(nextCode);
  }

  bool get isArabic => state.languageCode == 'ar';
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
