import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/device_location_service.dart';
import '../../../shared/widgets/app_page_body.dart';

/// Settings screen — per-device preferences (language, theme, display,
/// location, notifications, about). Uses SharedPreferences through
/// [settingsProvider] and the generated [AppLocalizations] for strings.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final distanceLabel = settings.distanceUnit == 'miles'
        ? l10n.set_distance_unit_miles
        : l10n.set_distance_unit_km;
    final displayRadius = settings
        .displayDistance(settings.searchRadiusKm)
        .round();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.title_settings,
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryInk,
        elevation: 0,
      ),
      body: AppPageBody(
        child: Theme(
          data: Theme.of(context).copyWith(
            cardTheme: CardThemeData(
              color: AppColors.surface,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.divider),
              ),
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _sectionHeader(Icons.language_rounded, l10n.language),
              Card(
                child: Column(
                  children: [
                    _radioTile<Locale>(
                      title: l10n.language_ar,
                      value: const Locale('ar', 'YE'),
                      groupValue: settings.locale,
                      onChanged: (v) => notifier.setLocale(v!),
                    ),
                    _radioTile<Locale>(
                      title: l10n.language_en,
                      value: const Locale('en', 'US'),
                      groupValue: settings.locale,
                      onChanged: (v) => notifier.setLocale(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                Icons.dashboard_customize_outlined,
                l10n.set_display,
              ),
              Card(
                child: Column(
                  children: [
                    _subHeader(l10n.theme),
                    _radioTile<ThemeMode>(
                      title: l10n.theme_system,
                      value: ThemeMode.system,
                      groupValue: settings.themeMode,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                    _radioTile<ThemeMode>(
                      title: l10n.theme_light,
                      value: ThemeMode.light,
                      groupValue: settings.themeMode,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                    _radioTile<ThemeMode>(
                      title: l10n.theme_dark,
                      value: ThemeMode.dark,
                      groupValue: settings.themeMode,
                      onChanged: (v) => notifier.setThemeMode(v!),
                    ),
                    const Divider(height: 1),
                    _subHeader(l10n.set_add_property_style),
                    _radioTile<String>(
                      title: l10n.add_property_style_outline,
                      value: 'outlined',
                      groupValue: settings.addPropertyStyle,
                      onChanged: (v) => notifier.setAddPropertyStyle(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.add_property_style_fab,
                      value: 'fab',
                      groupValue: settings.addPropertyStyle,
                      onChanged: (v) => notifier.setAddPropertyStyle(v!),
                    ),
                    const Divider(height: 1),
                    _subHeader(l10n.set_asset_count_visibility),
                    _radioTile<String>(
                      title: l10n.asset_count_always,
                      value: 'always',
                      groupValue: settings.assetCountVisibility,
                      onChanged: (v) => notifier.setAssetCountVisibility(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_asset_count_positive_only,
                      value: 'only_positive',
                      groupValue: settings.assetCountVisibility,
                      onChanged: (v) => notifier.setAssetCountVisibility(v!),
                    ),
                    const Divider(height: 1),
                    _subHeader(l10n.set_text_size),
                    _radioTile<String>(
                      title: l10n.set_text_size_small,
                      value: 'small',
                      groupValue: settings.textSize,
                      onChanged: (v) => notifier.setTextSize(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_text_size_medium,
                      value: 'medium',
                      groupValue: settings.textSize,
                      onChanged: (v) => notifier.setTextSize(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_text_size_large,
                      value: 'large',
                      groupValue: settings.textSize,
                      onChanged: (v) => notifier.setTextSize(v!),
                    ),
                    const Divider(height: 1),
                    _subHeader(l10n.set_default_map_view),
                    _radioTile<String>(
                      title: l10n.set_default_map_view_map,
                      value: 'map',
                      groupValue: settings.defaultMapView,
                      onChanged: (v) => notifier.setDefaultMapView(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_default_map_view_list,
                      value: 'list',
                      groupValue: settings.defaultMapView,
                      onChanged: (v) => notifier.setDefaultMapView(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(Icons.location_on_outlined, l10n.set_location),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.near_me_rounded,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(
                        l10n.set_current_location,
                        style: AppFonts.cairo(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        settings.latitude != null && settings.longitude != null
                            ? '${settings.latitude!.toStringAsFixed(4)}, '
                                  '${settings.longitude!.toStringAsFixed(4)}'
                            : l10n.set_default_ibb,
                      ),
                      trailing: TextButton(
                        onPressed: () => notifier.resetLocation(),
                        child: Text(
                          l10n.set_reset_location,
                          style: AppFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(
                        l10n.location_permission_title,
                        style: AppFonts.cairo(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        l10n.location_permission_message,
                        style: AppFonts.cairo(fontSize: 12),
                      ),
                      trailing: TextButton(
                        onPressed: () async {
                          final result =
                              await DeviceLocationService.requestLocation();
                          if (!context.mounted) return;
                          if (result.granted && result.position != null) {
                            await notifier.setLocation(
                              result.position!.latitude,
                              result.position!.longitude,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.set_current_location),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          } else if (result.permanentlyDenied) {
                            await DeviceLocationService.openAppSettings();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.location_permission_message),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          }
                        },
                        child: Text(
                          l10n.set_retry_location,
                          style: AppFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.location_city_outlined,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(
                        l10n.set_search_radius,
                        style: AppFonts.cairo(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$displayRadius $distanceLabel'),
                          Text(
                            l10n.set_search_radius_hint,
                            style: AppFonts.cairo(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: settings.searchRadiusKm,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: '$displayRadius $distanceLabel',
                      onChanged: (v) => notifier.setSearchRadius(v),
                    ),
                    const Divider(height: 1),
                    _subHeader(l10n.set_distance_unit),
                    _radioTile<String>(
                      title: l10n.set_distance_unit_km,
                      value: 'km',
                      groupValue: settings.distanceUnit,
                      onChanged: (v) => notifier.setDistanceUnit(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_distance_unit_miles,
                      value: 'miles',
                      groupValue: settings.distanceUnit,
                      onChanged: (v) => notifier.setDistanceUnit(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                Icons.notifications_none_rounded,
                l10n.notifications,
              ),
              Card(
                child: SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active_outlined,
                    color: AppColors.primaryInk,
                  ),
                  title: Text(
                    l10n.notifications_on,
                    style: AppFonts.cairo(fontWeight: FontWeight.w600),
                  ),
                  value: settings.notificationsEnabled,
                  onChanged: (v) => notifier.setNotificationsEnabled(v),
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(Icons.attach_money_rounded, l10n.set_currency),
              Card(
                child: Column(
                  children: [
                    _subHeader(l10n.set_currency),
                    _radioTile<String>(
                      title: l10n.set_currency_yer,
                      value: AppConstants.currencyYer,
                      groupValue: settings.currencyCode,
                      onChanged: (v) => notifier.setCurrency(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_currency_sar,
                      value: AppConstants.currencySar,
                      groupValue: settings.currencyCode,
                      onChanged: (v) => notifier.setCurrency(v!),
                    ),
                    _radioTile<String>(
                      title: l10n.set_currency_usd,
                      value: AppConstants.currencyUsd,
                      groupValue: settings.currencyCode,
                      onChanged: (v) => notifier.setCurrency(v!),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(Icons.info_outline, l10n.about),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.apartment_rounded,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(
                        l10n.app_name,
                        style: AppFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${l10n.about_version} ${AppConstants.appVersion}',
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.mail_outline,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(l10n.about_contact),
                      subtitle: const Text('support@yemenrealestate.local'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        Icons.privacy_tip_outlined,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(l10n.about_privacy),
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onTap: () => _showLegalDialog(
                        context,
                        title: l10n.about_privacy,
                        body: l10n.about_privacy_body,
                      ),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.description_outlined,
                        color: AppColors.primaryInk,
                      ),
                      title: Text(l10n.about_terms),
                      trailing: Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                      onTap: () => _showLegalDialog(
                        context,
                        title: l10n.about_terms,
                        body: l10n.about_terms_body,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryInk),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: AppFonts.cairo(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryInk,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(70),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  /// Group label inside a settings card (e.g. المظهر / زر إضافة العقار).
  Widget _subHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: AppFonts.cairo(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showLegalDialog(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          title,
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            body,
            style: AppFonts.cairo(fontSize: 13.5, height: 1.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppLocalizations.of(ctx)!.close,
              style: AppFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _radioTile<T>({
    required String title,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
  }) {
    return RadioListTile<T>(
      title: Text(title, style: AppFonts.cairo(fontSize: 13.5)),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      dense: true,
    );
  }
}
