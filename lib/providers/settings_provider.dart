import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency_rates.dart';

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
  final String currencyCode; // 'YER' | 'SAR' | 'USD'
  final double usdToYerRate; // display-only reference rate, user-editable
  final double sarToYerRate;
  final String distanceUnit; // 'km' | 'miles'
  final String textSize; // 'small' | 'medium' | 'large'
  final String defaultMapView; // 'list' | 'map'

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
    this.currencyCode = 'YER',
    this.usdToYerRate = CurrencyRates.defaultUsdToYer,
    this.sarToYerRate = CurrencyRates.defaultSarToYer,
    this.distanceUnit = 'km',
    this.textSize = 'medium',
    this.defaultMapView = 'map',
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
    String? currencyCode,
    double? usdToYerRate,
    double? sarToYerRate,
    String? distanceUnit,
    String? textSize,
    String? defaultMapView,
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
      currencyCode: currencyCode ?? this.currencyCode,
      usdToYerRate: usdToYerRate ?? this.usdToYerRate,
      sarToYerRate: sarToYerRate ?? this.sarToYerRate,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      textSize: textSize ?? this.textSize,
      defaultMapView: defaultMapView ?? this.defaultMapView,
    );
  }

  /// Linear scaling applied by `MaterialApp.textScaler` for the chosen size.
  double get textScaleFactor => switch (textSize) {
    'small' => 0.85,
    'large' => 1.15,
    _ => 1.0,
  };

  /// Radius values stay stored in kilometres; convert only for display.
  double displayDistance(num kilometers) => distanceUnit == 'miles'
      ? kilometers / 1.609344
      : kilometers.toDouble();

  /// Reference rates entered in Settings, never fetched from a network.
  CurrencyRates get currencyRates => CurrencyRates(
    usdToYer: usdToYerRate,
    sarToYer: sarToYerRate,
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  /// Completes once persisted preferences have been applied to [state].
  late final Future<void> loaded;

  SettingsNotifier() : super(const SettingsState()) {
    loaded = _load();
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
  static const _kCurrency = 'settings_currency';
  static const _kUsdRate = 'settings_usd_to_yer_rate';
  static const _kSarRate = 'settings_sar_to_yer_rate';
  static const _kDistanceUnit = 'settings_distance_unit';
  static const _kTextSize = 'settings_text_size';
  static const _kDefaultMapView = 'settings_default_map_view';

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
        currencyCode: prefs.getString(_kCurrency) ?? 'YER',
        usdToYerRate: CurrencyRates.sanitize(
          prefs.getDouble(_kUsdRate) ?? CurrencyRates.defaultUsdToYer,
          CurrencyRates.defaultUsdToYer,
        ),
        sarToYerRate: CurrencyRates.sanitize(
          prefs.getDouble(_kSarRate) ?? CurrencyRates.defaultSarToYer,
          CurrencyRates.defaultSarToYer,
        ),
        distanceUnit: prefs.getString(_kDistanceUnit) ?? 'km',
        textSize: prefs.getString(_kTextSize) ?? 'medium',
        defaultMapView: prefs.getString(_kDefaultMapView) ?? 'map',
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

  Future<void> setCurrency(String currency) async {
    state = state.copyWith(currencyCode: currency);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCurrency, currency);
  }

  /// Display-only reference rate: 1 USD = [rate] YER.
  Future<void> setUsdToYerRate(double rate) async {
    final safeRate = CurrencyRates.sanitize(
      rate,
      CurrencyRates.defaultUsdToYer,
    );
    state = state.copyWith(usdToYerRate: safeRate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kUsdRate, safeRate);
  }

  /// Display-only reference rate: 1 SAR = [rate] YER.
  Future<void> setSarToYerRate(double rate) async {
    final safeRate = CurrencyRates.sanitize(
      rate,
      CurrencyRates.defaultSarToYer,
    );
    state = state.copyWith(sarToYerRate: safeRate);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kSarRate, safeRate);
  }

  Future<void> resetCurrencyRates() async {
    await setUsdToYerRate(CurrencyRates.defaultUsdToYer);
    await setSarToYerRate(CurrencyRates.defaultSarToYer);
  }

  Future<void> setDistanceUnit(String unit) async {
    state = state.copyWith(distanceUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDistanceUnit, unit);
  }

  Future<void> setTextSize(String size) async {
    state = state.copyWith(textSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTextSize, size);
  }

  Future<void> setDefaultMapView(String view) async {
    state = state.copyWith(defaultMapView: view);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultMapView, view);
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

  /// Settings → reset everything back to the app defaults.
  Future<void> resetAll() async {
    state = const SettingsState();
    final prefs = await SharedPreferences.getInstance();
    for (final key in [
      _kLocale,
      _kTheme,
      _kAddStyle,
      _kCountVisibility,
      _kNotifications,
      _kRadius,
      _kLocationPrompt,
      _kLatitude,
      _kLongitude,
      _kCurrency,
      _kUsdRate,
      _kSarRate,
      _kDistanceUnit,
      _kTextSize,
      _kDefaultMapView,
    ]) {
      await prefs.remove(key);
    }
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
