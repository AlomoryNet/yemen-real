import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preferences persisted locally with SharedPreferences — the standard
/// approach for settings that are per-device and don't need a backend.
class SettingsState {
  final Locale locale;
  final ThemeMode themeMode;
  final String addPropertyStyle; // 'outlined' | 'fab'
  final String assetCountVisibility; // 'always' | 'only_positive'
  final bool notificationsEnabled;
  final double searchRadiusKm;
  final bool locationPromptShown;
  final double? latitude;
  final double? longitude;

  const SettingsState({
    this.locale = const Locale('ar', 'YE'),
    this.themeMode = ThemeMode.system,
    this.addPropertyStyle = 'outlined',
    this.assetCountVisibility = 'always',
    this.notificationsEnabled = true,
    this.searchRadiusKm = 25,
    this.locationPromptShown = false,
    this.latitude,
    this.longitude,
  });

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    String? addPropertyStyle,
    String? assetCountVisibility,
    bool? notificationsEnabled,
    double? searchRadiusKm,
    bool? locationPromptShown,
    double? latitude,
    double? longitude,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      addPropertyStyle: addPropertyStyle ?? this.addPropertyStyle,
      assetCountVisibility: assetCountVisibility ?? this.assetCountVisibility,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      locationPromptShown: locationPromptShown ?? this.locationPromptShown,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  static const _kLocale = 'settings_locale';
  static const _kTheme = 'settings_theme';
  static const _kAddStyle = 'settings_add_property_style';
  static const _kCountVisibility = 'settings_asset_count_visibility';
  static const _kNotifications = 'settings_notifications';
  static const _kRadius = 'settings_search_radius';
  static const _kLocationPrompt = 'settings_location_prompt_shown';
  static const _kLatitude = 'settings_latitude';
  static const _kLongitude = 'settings_longitude';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_kLocale);
      final themeName = prefs.getString(_kTheme);
      state = state.copyWith(
        locale: lang == 'en'
            ? const Locale('en', 'US')
            : const Locale('ar', 'YE'),
        themeMode: _themeFromString(themeName),
        addPropertyStyle: prefs.getString(_kAddStyle) ?? 'outlined',
        assetCountVisibility: prefs.getString(_kCountVisibility) ?? 'always',
        notificationsEnabled: prefs.getBool(_kNotifications) ?? true,
        searchRadiusKm: prefs.getDouble(_kRadius) ?? 25,
        locationPromptShown: prefs.getBool(_kLocationPrompt) ?? false,
        latitude: prefs.getDouble(_kLatitude),
        longitude: prefs.getDouble(_kLongitude),
      );
    } catch (_) {
      // use defaults when prefs unavailable
    }
  }

  ThemeMode _themeFromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocale, locale.languageCode);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, _themeToString(mode));
  }

  Future<void> setAddPropertyStyle(String style) async {
    state = state.copyWith(addPropertyStyle: style);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAddStyle, style);
  }

  Future<void> setAssetCountVisibility(String visibility) async {
    state = state.copyWith(assetCountVisibility: visibility);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCountVisibility, visibility);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, enabled);
  }

  Future<void> setSearchRadius(double radius) async {
    state = state.copyWith(searchRadiusKm: radius);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kRadius, radius);
  }

  Future<void> markLocationPromptShown() async {
    state = state.copyWith(locationPromptShown: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLocationPrompt, true);
  }

  /// Cache the resolved location so later launches can show nearby listings
  /// without re-prompting.
  Future<void> setLocation(double latitude, double longitude) async {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      locationPromptShown: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLatitude, latitude);
    await prefs.setDouble(_kLongitude, longitude);
    await prefs.setBool(_kLocationPrompt, true);
  }

  /// Settings → reset location (prompts again on the next dashboard visit).
  Future<void> resetLocation() async {
    state = state.copyWith(
      latitude: null,
      longitude: null,
      locationPromptShown: false,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLatitude);
    await prefs.remove(_kLongitude);
    await prefs.setBool(_kLocationPrompt, false);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
