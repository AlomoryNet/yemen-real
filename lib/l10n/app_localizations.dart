import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Yemen Real Estate Portal'**
  String get app_name;

  /// No description provided for @app_name_english.
  ///
  /// In en, this message translates to:
  /// **'Yemen Real Estate Portal'**
  String get app_name_english;

  /// No description provided for @title_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get title_dashboard;

  /// No description provided for @title_my_properties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get title_my_properties;

  /// No description provided for @title_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get title_settings;

  /// No description provided for @title_add_property.
  ///
  /// In en, this message translates to:
  /// **'Add Property'**
  String get title_add_property;

  /// No description provided for @header_add_property.
  ///
  /// In en, this message translates to:
  /// **'Add Your Property'**
  String get header_add_property;

  /// No description provided for @header_add_property_free.
  ///
  /// In en, this message translates to:
  /// **'Add Your Property Free'**
  String get header_add_property_free;

  /// No description provided for @header_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get header_settings;

  /// No description provided for @bottom_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get bottom_home;

  /// No description provided for @bottom_my_properties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get bottom_my_properties;

  /// No description provided for @dashboard_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by address, neighborhood, or keywords...'**
  String get dashboard_search_hint;

  /// No description provided for @search_button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_button;

  /// No description provided for @filter_button.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filter_button;

  /// No description provided for @filter_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get filter_save;

  /// No description provided for @filter_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filter_reset;

  /// No description provided for @city_dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get city_dropdown;

  /// No description provided for @district_dropdown.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get district_dropdown;

  /// No description provided for @deal_type.
  ///
  /// In en, this message translates to:
  /// **'Deal Type'**
  String get deal_type;

  /// No description provided for @deal_sale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get deal_sale;

  /// No description provided for @deal_rent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get deal_rent;

  /// No description provided for @deal_all.
  ///
  /// In en, this message translates to:
  /// **'All (Sale/Rent)'**
  String get deal_all;

  /// No description provided for @property_type.
  ///
  /// In en, this message translates to:
  /// **'Property Type'**
  String get property_type;

  /// No description provided for @property_type_all.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get property_type_all;

  /// No description provided for @draw_area.
  ///
  /// In en, this message translates to:
  /// **'Draw Area'**
  String get draw_area;

  /// No description provided for @satellite.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satellite;

  /// No description provided for @map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map;

  /// No description provided for @list_view.
  ///
  /// In en, this message translates to:
  /// **'List View'**
  String get list_view;

  /// No description provided for @asset_count.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get asset_count;

  /// No description provided for @asset_count_plural.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get asset_count_plural;

  /// No description provided for @asset_zero.
  ///
  /// In en, this message translates to:
  /// **'No properties found'**
  String get asset_zero;

  /// No description provided for @asset_count_always.
  ///
  /// In en, this message translates to:
  /// **'Always show property count'**
  String get asset_count_always;

  /// No description provided for @add_property_style_outline.
  ///
  /// In en, this message translates to:
  /// **'Outline button on Home'**
  String get add_property_style_outline;

  /// No description provided for @add_property_style_fab.
  ///
  /// In en, this message translates to:
  /// **'FAB above map FAB'**
  String get add_property_style_fab;

  /// No description provided for @location_permission_title.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get location_permission_title;

  /// No description provided for @location_permission_message.
  ///
  /// In en, this message translates to:
  /// **'We want to find properties near you. Please allow access to your location.'**
  String get location_permission_message;

  /// No description provided for @location_allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get location_allow;

  /// No description provided for @location_deny.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get location_deny;

  /// No description provided for @location_city.
  ///
  /// In en, this message translates to:
  /// **'City: {city}'**
  String location_city(Object city);

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @language_ar.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get language_ar;

  /// No description provided for @language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get theme_system;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get theme_dark;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notifications_on.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notifications_on;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @about_version.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String about_version(Object version);

  /// No description provided for @about_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get about_privacy;

  /// No description provided for @about_privacy_body.
  ///
  /// In en, this message translates to:
  /// **'We respect your privacy and do not share your personal data with any third party without your consent. Your data is used only to provide and improve the platform services.'**
  String get about_privacy_body;

  /// No description provided for @about_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get about_terms;

  /// No description provided for @about_terms_body.
  ///
  /// In en, this message translates to:
  /// **'By using the platform you agree to the terms and conditions governing the service, including the accuracy of listing data and the advertiser\'s responsibility for its content.'**
  String get about_terms_body;

  /// No description provided for @about_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get about_contact;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get register;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @my_requests.
  ///
  /// In en, this message translates to:
  /// **'My Rental Requests'**
  String get my_requests;

  /// No description provided for @my_properties_list.
  ///
  /// In en, this message translates to:
  /// **'My Listed Properties'**
  String get my_properties_list;

  /// No description provided for @admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_panel;

  /// No description provided for @footer_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get footer_contact;

  /// No description provided for @footer_support_email.
  ///
  /// In en, this message translates to:
  /// **'support@yemenrealestate.local'**
  String get footer_support_email;

  /// No description provided for @footer_phone.
  ///
  /// In en, this message translates to:
  /// **'+967 770 000 000'**
  String get footer_phone;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'No Results'**
  String get no_results;

  /// No description provided for @error_occurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get error_occurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @near_you.
  ///
  /// In en, this message translates to:
  /// **'Near You'**
  String get near_you;

  /// No description provided for @nearby_properties.
  ///
  /// In en, this message translates to:
  /// **'Properties Near You'**
  String get nearby_properties;

  /// No description provided for @nearby_map.
  ///
  /// In en, this message translates to:
  /// **'Map Near You'**
  String get nearby_map;

  /// No description provided for @draw_area_button.
  ///
  /// In en, this message translates to:
  /// **'Draw Area'**
  String get draw_area_button;

  /// No description provided for @offline_map.
  ///
  /// In en, this message translates to:
  /// **'Yemen Map 🇾🇪'**
  String get offline_map;

  /// No description provided for @all_governorates.
  ///
  /// In en, this message translates to:
  /// **'All Governorates 🇾🇪'**
  String get all_governorates;

  /// No description provided for @offline_atlas_button.
  ///
  /// In en, this message translates to:
  /// **'View List'**
  String get offline_atlas_button;

  /// No description provided for @add_property_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get add_property_prompt;

  /// No description provided for @manage_properties_prompt.
  ///
  /// In en, this message translates to:
  /// **'To manage your properties, please log in first.'**
  String get manage_properties_prompt;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirm_logout;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @loading_properties.
  ///
  /// In en, this message translates to:
  /// **'Loading properties...'**
  String get loading_properties;

  /// No description provided for @properties_available.
  ///
  /// In en, this message translates to:
  /// **'{count} properties available'**
  String properties_available(Object count);

  /// No description provided for @map_offline_button.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map_offline_button;

  /// No description provided for @satellite_toggle.
  ///
  /// In en, this message translates to:
  /// **'Satellite'**
  String get satellite_toggle;

  /// No description provided for @map_tools.
  ///
  /// In en, this message translates to:
  /// **'Map Tools'**
  String get map_tools;

  /// No description provided for @property_details.
  ///
  /// In en, this message translates to:
  /// **'Property Details'**
  String get property_details;

  /// No description provided for @property_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get property_price;

  /// No description provided for @property_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get property_location;

  /// No description provided for @property_area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get property_area;

  /// No description provided for @property_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Bedrooms'**
  String get property_bedrooms;

  /// No description provided for @property_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get property_bathrooms;

  /// No description provided for @property_type_apt.
  ///
  /// In en, this message translates to:
  /// **'Apartment'**
  String get property_type_apt;

  /// No description provided for @property_type_villa.
  ///
  /// In en, this message translates to:
  /// **'Villa'**
  String get property_type_villa;

  /// No description provided for @property_type_land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get property_type_land;

  /// No description provided for @property_type_shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get property_type_shop;

  /// No description provided for @status_published.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get status_published;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get status_pending;

  /// No description provided for @status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get status_draft;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected;

  /// No description provided for @contact_owner.
  ///
  /// In en, this message translates to:
  /// **'Contact Owner'**
  String get contact_owner;

  /// No description provided for @contact_agent.
  ///
  /// In en, this message translates to:
  /// **'Contact Agent'**
  String get contact_agent;

  /// No description provided for @send_message.
  ///
  /// In en, this message translates to:
  /// **'Send Message'**
  String get send_message;

  /// No description provided for @message_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get message_sent;

  /// No description provided for @save_favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to Favorites'**
  String get save_favorite;

  /// No description provided for @remove_favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get remove_favorite;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @view_on_map.
  ///
  /// In en, this message translates to:
  /// **'View on Map'**
  String get view_on_map;

  /// No description provided for @search_this_area.
  ///
  /// In en, this message translates to:
  /// **'Search This Area'**
  String get search_this_area;

  /// No description provided for @select_city.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get select_city;

  /// No description provided for @select_district.
  ///
  /// In en, this message translates to:
  /// **'Select District'**
  String get select_district;

  /// No description provided for @no_properties_found.
  ///
  /// In en, this message translates to:
  /// **'No Properties Found'**
  String get no_properties_found;

  /// No description provided for @expand_map.
  ///
  /// In en, this message translates to:
  /// **'Expand Map'**
  String get expand_map;

  /// No description provided for @collapse_map.
  ///
  /// In en, this message translates to:
  /// **'Collapse Map'**
  String get collapse_map;

  /// No description provided for @favorite_properties.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorite_properties;

  /// No description provided for @property_requests.
  ///
  /// In en, this message translates to:
  /// **'Property Requests'**
  String get property_requests;

  /// No description provided for @create_request.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get create_request;

  /// No description provided for @my_requests_empty.
  ///
  /// In en, this message translates to:
  /// **'No Requests'**
  String get my_requests_empty;

  /// No description provided for @admin_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get admin_dashboard;

  /// No description provided for @admin_users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get admin_users;

  /// No description provided for @admin_properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get admin_properties;

  /// No description provided for @admin_requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get admin_requests;

  /// No description provided for @admin_analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get admin_analytics;

  /// No description provided for @settings_saved.
  ///
  /// In en, this message translates to:
  /// **'Settings Saved'**
  String get settings_saved;

  /// No description provided for @reset_settings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get reset_settings;

  /// No description provided for @require_auth.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get require_auth;

  /// No description provided for @login_required.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get login_required;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notifications_empty;

  /// No description provided for @clear_all.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clear_all;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @auth_show_password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get auth_show_password;

  /// No description provided for @auth_hide_password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get auth_hide_password;

  /// No description provided for @mark_as_read.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get mark_as_read;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @map_tab.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get map_tab;

  /// No description provided for @search_tab.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search_tab;

  /// No description provided for @profile_tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_tab;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Logout'**
  String get logout_confirmation;

  /// No description provided for @session_expired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please log in again'**
  String get session_expired;

  /// No description provided for @internet_required.
  ///
  /// In en, this message translates to:
  /// **'Internet connection required'**
  String get internet_required;

  /// No description provided for @try_again.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get try_again;

  /// No description provided for @contact_support.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contact_support;

  /// No description provided for @support_email.
  ///
  /// In en, this message translates to:
  /// **'support@yemenrealestate.local'**
  String get support_email;

  /// No description provided for @terms_link.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get terms_link;

  /// No description provided for @privacy_link.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_link;

  /// No description provided for @login_enter_email_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get login_enter_email_first;

  /// No description provided for @login_verification_resent.
  ///
  /// In en, this message translates to:
  /// **'A new confirmation link has been sent to your email. Please check your inbox.'**
  String get login_verification_resent;

  /// No description provided for @login_resend_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend right now'**
  String get login_resend_failed;

  /// No description provided for @login_demo_admin_filled.
  ///
  /// In en, this message translates to:
  /// **'The admin email and demo password have been filled in. You can continue now'**
  String get login_demo_admin_filled;

  /// No description provided for @login_demo_user_filled.
  ///
  /// In en, this message translates to:
  /// **'The demo user email and password have been filled in. You can continue now'**
  String get login_demo_user_filled;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_title;

  /// No description provided for @login_submit.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_submit;

  /// No description provided for @login_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back to the Yemen Real Estate Portal'**
  String get login_subtitle;

  /// No description provided for @login_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get login_sending;

  /// No description provided for @login_resend_now.
  ///
  /// In en, this message translates to:
  /// **'Resend the activation link to my email now'**
  String get login_resend_now;

  /// No description provided for @login_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_email;

  /// No description provided for @login_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_password;

  /// No description provided for @login_remember_me.
  ///
  /// In en, this message translates to:
  /// **'Remember email'**
  String get login_remember_me;

  /// No description provided for @login_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get login_forgot_password;

  /// No description provided for @login_no_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_account;

  /// No description provided for @login_create_account.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get login_create_account;

  /// No description provided for @login_resend_prompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the activation link? Resend it to my email'**
  String get login_resend_prompt;

  /// No description provided for @login_quick_demo.
  ///
  /// In en, this message translates to:
  /// **'Quick sign-in with system accounts:'**
  String get login_quick_demo;

  /// No description provided for @login_demo_admin.
  ///
  /// In en, this message translates to:
  /// **'General Manager (email + password)'**
  String get login_demo_admin;

  /// No description provided for @login_demo_user.
  ///
  /// In en, this message translates to:
  /// **'Advertiser account (email + password)'**
  String get login_demo_user;

  /// No description provided for @register_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm and activate your account'**
  String get register_confirm_title;

  /// No description provided for @register_confirm_message.
  ///
  /// In en, this message translates to:
  /// **'A confirmation message has been sent to your email. Please check your inbox and tap the confirmation link to finish creating your account.'**
  String get register_confirm_message;

  /// No description provided for @register_open_inbox.
  ///
  /// In en, this message translates to:
  /// **'Please open your email inbox and click the activation link sent to you to complete verification and activate your account.'**
  String get register_open_inbox;

  /// No description provided for @register_warning.
  ///
  /// In en, this message translates to:
  /// **'Note: You will not be signed in or granted permissions until you click the link in your email.'**
  String get register_warning;

  /// No description provided for @register_resend_success.
  ///
  /// In en, this message translates to:
  /// **'The confirmation link has been resent to your email'**
  String get register_resend_success;

  /// No description provided for @register_resend_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend right now'**
  String get register_resend_failed;

  /// No description provided for @register_resending.
  ///
  /// In en, this message translates to:
  /// **'Resending...'**
  String get register_resending;

  /// No description provided for @register_resend_prompt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the message? Resend the activation link'**
  String get register_resend_prompt;

  /// No description provided for @register_browse_guest.
  ///
  /// In en, this message translates to:
  /// **'Browse as guest'**
  String get register_browse_guest;

  /// No description provided for @register_go_login.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in'**
  String get register_go_login;

  /// No description provided for @register_title.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Join Yemen\'s leading real estate community for free'**
  String get register_subtitle;

  /// No description provided for @register_go_login_now.
  ///
  /// In en, this message translates to:
  /// **'Go to sign in now'**
  String get register_go_login_now;

  /// No description provided for @register_full_name_required.
  ///
  /// In en, this message translates to:
  /// **'Full name *'**
  String get register_full_name_required;

  /// No description provided for @register_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get register_full_name;

  /// No description provided for @register_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get register_name_hint;

  /// No description provided for @register_email_required.
  ///
  /// In en, this message translates to:
  /// **'Email *'**
  String get register_email_required;

  /// No description provided for @register_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number *'**
  String get register_phone_required;

  /// No description provided for @register_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: 770000000'**
  String get register_phone_hint;

  /// No description provided for @register_password_required.
  ///
  /// In en, this message translates to:
  /// **'Password *'**
  String get register_password_required;

  /// No description provided for @register_password_hint.
  ///
  /// In en, this message translates to:
  /// **'At least 8 characters (numbers and letters for security)'**
  String get register_password_hint;

  /// No description provided for @register_submit.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get register_submit;

  /// No description provided for @register_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get register_have_account;

  /// No description provided for @register_login_link.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get register_login_link;

  /// No description provided for @forgot_link_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent'**
  String get forgot_link_sent;

  /// No description provided for @forgot_check_inbox.
  ///
  /// In en, this message translates to:
  /// **'Check your email inbox and follow the instructions to set a new password.'**
  String get forgot_check_inbox;

  /// No description provided for @forgot_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get forgot_back_to_login;

  /// No description provided for @forgot_title.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgot_title;

  /// No description provided for @forgot_instructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered email address and we will send you a link to reset your password.'**
  String get forgot_instructions;

  /// No description provided for @forgot_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgot_email;

  /// No description provided for @forgot_send_link.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get forgot_send_link;

  /// No description provided for @forgot_return_to_login.
  ///
  /// In en, this message translates to:
  /// **'Return to sign in'**
  String get forgot_return_to_login;

  /// No description provided for @callback_expired_message.
  ///
  /// In en, this message translates to:
  /// **'This activation link has expired or has already been used. Please request a new link to continue.'**
  String get callback_expired_message;

  /// No description provided for @callback_link_error.
  ///
  /// In en, this message translates to:
  /// **'Could not verify the link. Please try again later.'**
  String get callback_link_error;

  /// No description provided for @callback_enter_email_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get callback_enter_email_first;

  /// No description provided for @callback_resend_success.
  ///
  /// In en, this message translates to:
  /// **'A new activation link has been sent to your email'**
  String get callback_resend_success;

  /// No description provided for @callback_resend_failed.
  ///
  /// In en, this message translates to:
  /// **'Unable to resend right now'**
  String get callback_resend_failed;

  /// No description provided for @callback_verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying your email activation...'**
  String get callback_verifying;

  /// No description provided for @callback_waiting.
  ///
  /// In en, this message translates to:
  /// **'Please wait a few seconds while we confirm your account with the Yemen Real Estate Portal servers.'**
  String get callback_waiting;

  /// No description provided for @callback_success_title.
  ///
  /// In en, this message translates to:
  /// **'Your email has been activated successfully!'**
  String get callback_success_title;

  /// No description provided for @callback_success_message.
  ///
  /// In en, this message translates to:
  /// **'Welcome to the Yemen Real Estate Portal. Your email ownership has been confirmed and your account is now fully active.'**
  String get callback_success_message;

  /// No description provided for @callback_continue_operation.
  ///
  /// In en, this message translates to:
  /// **'Continue to complete your action'**
  String get callback_continue_operation;

  /// No description provided for @callback_continue_home.
  ///
  /// In en, this message translates to:
  /// **'Continue to the home page'**
  String get callback_continue_home;

  /// No description provided for @callback_go_home.
  ///
  /// In en, this message translates to:
  /// **'Go to the home page'**
  String get callback_go_home;

  /// No description provided for @callback_login_credentials.
  ///
  /// In en, this message translates to:
  /// **'Sign in with email and password'**
  String get callback_login_credentials;

  /// No description provided for @callback_expired_title.
  ///
  /// In en, this message translates to:
  /// **'Activation link expired or already used'**
  String get callback_expired_title;

  /// No description provided for @callback_cannot_confirm.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm the link'**
  String get callback_cannot_confirm;

  /// No description provided for @callback_expired_fallback.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or the account has already been verified with it. You can try signing in or request a new activation link.'**
  String get callback_expired_fallback;

  /// No description provided for @callback_error_fallback.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the activation link. Please try again.'**
  String get callback_error_fallback;

  /// No description provided for @callback_resend_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email address for resending'**
  String get callback_resend_email_label;

  /// No description provided for @callback_sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get callback_sending;

  /// No description provided for @callback_send_new_link.
  ///
  /// In en, this message translates to:
  /// **'Send a new activation link'**
  String get callback_send_new_link;

  /// No description provided for @callback_back_login.
  ///
  /// In en, this message translates to:
  /// **'Back to the sign-in page'**
  String get callback_back_login;

  /// No description provided for @admin_restricted_title.
  ///
  /// In en, this message translates to:
  /// **'Restricted admin area'**
  String get admin_restricted_title;

  /// No description provided for @admin_restricted_desc.
  ///
  /// In en, this message translates to:
  /// **'This page is reserved for Yemen Real Estate Portal administrators and you do not have permission to access it.'**
  String get admin_restricted_desc;

  /// No description provided for @admin_back_home.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get admin_back_home;

  /// No description provided for @admin_title.
  ///
  /// In en, this message translates to:
  /// **'Administration & Control Dashboard'**
  String get admin_title;

  /// No description provided for @admin_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage the platform, properties, rental requests, and manual commission records.'**
  String get admin_subtitle;

  /// No description provided for @admin_general_manager.
  ///
  /// In en, this message translates to:
  /// **'General Manager: Mohammed Al-Saqqaf'**
  String get admin_general_manager;

  /// No description provided for @admin_loading_stats.
  ///
  /// In en, this message translates to:
  /// **'Loading statistics...'**
  String get admin_loading_stats;

  /// No description provided for @admin_tab_properties.
  ///
  /// In en, this message translates to:
  /// **'Property Management'**
  String get admin_tab_properties;

  /// No description provided for @admin_tab_requests.
  ///
  /// In en, this message translates to:
  /// **'Rental Requests'**
  String get admin_tab_requests;

  /// No description provided for @admin_tab_commissions.
  ///
  /// In en, this message translates to:
  /// **'Commission Records'**
  String get admin_tab_commissions;

  /// No description provided for @admin_tab_reports.
  ///
  /// In en, this message translates to:
  /// **'Violation Reports'**
  String get admin_tab_reports;

  /// No description provided for @admin_tab_users.
  ///
  /// In en, this message translates to:
  /// **'Users (Encrypted)'**
  String get admin_tab_users;

  /// No description provided for @admin_print_pdf.
  ///
  /// In en, this message translates to:
  /// **'Print full PDF report for this section'**
  String get admin_print_pdf;

  /// No description provided for @admin_total_properties.
  ///
  /// In en, this message translates to:
  /// **'Total Properties'**
  String get admin_total_properties;

  /// No description provided for @admin_published_properties.
  ///
  /// In en, this message translates to:
  /// **'Published Properties'**
  String get admin_published_properties;

  /// No description provided for @admin_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get admin_pending_review;

  /// No description provided for @admin_total_users.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get admin_total_users;

  /// No description provided for @admin_commission_records.
  ///
  /// In en, this message translates to:
  /// **'Commission Records'**
  String get admin_commission_records;

  /// No description provided for @admin_pending_title.
  ///
  /// In en, this message translates to:
  /// **'Properties Awaiting Approval'**
  String get admin_pending_title;

  /// No description provided for @admin_awaiting_review.
  ///
  /// In en, this message translates to:
  /// **'awaiting review'**
  String get admin_awaiting_review;

  /// No description provided for @admin_review_complete.
  ///
  /// In en, this message translates to:
  /// **'All reviewed'**
  String get admin_review_complete;

  /// No description provided for @admin_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Review properties added by users and approve their public publication on the map and in search results.'**
  String get admin_pending_desc;

  /// No description provided for @admin_refresh_requests.
  ///
  /// In en, this message translates to:
  /// **'Refresh the request list'**
  String get admin_refresh_requests;

  /// No description provided for @admin_no_pending.
  ///
  /// In en, this message translates to:
  /// **'No properties are awaiting approval — all publication requests have been reviewed and approved.'**
  String get admin_no_pending;

  /// No description provided for @admin_loading_pending.
  ///
  /// In en, this message translates to:
  /// **'Fetching pending publication requests...'**
  String get admin_loading_pending;

  /// No description provided for @admin_for_rent.
  ///
  /// In en, this message translates to:
  /// **'For Rent'**
  String get admin_for_rent;

  /// No description provided for @admin_for_sale.
  ///
  /// In en, this message translates to:
  /// **'For Sale'**
  String get admin_for_sale;

  /// No description provided for @admin_sqm.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get admin_sqm;

  /// No description provided for @admin_rooms.
  ///
  /// In en, this message translates to:
  /// **'bedrooms'**
  String get admin_rooms;

  /// No description provided for @admin_listing_owner.
  ///
  /// In en, this message translates to:
  /// **'Listing owner'**
  String get admin_listing_owner;

  /// No description provided for @admin_platform_user.
  ///
  /// In en, this message translates to:
  /// **'Platform user'**
  String get admin_platform_user;

  /// No description provided for @admin_approve_publish.
  ///
  /// In en, this message translates to:
  /// **'Approve & publish listing'**
  String get admin_approve_publish;

  /// No description provided for @admin_reject_request.
  ///
  /// In en, this message translates to:
  /// **'Reject request'**
  String get admin_reject_request;

  /// No description provided for @admin_view_full_details.
  ///
  /// In en, this message translates to:
  /// **'View full details'**
  String get admin_view_full_details;

  /// No description provided for @admin_approved_prefix.
  ///
  /// In en, this message translates to:
  /// **'Property \"'**
  String get admin_approved_prefix;

  /// No description provided for @admin_approved_suffix.
  ///
  /// In en, this message translates to:
  /// **'\" has been approved for publishing and is now publicly visible in search and on the map.'**
  String get admin_approved_suffix;

  /// No description provided for @admin_approve_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to approve property publishing'**
  String get admin_approve_failed;

  /// No description provided for @admin_default_reject_reason.
  ///
  /// In en, this message translates to:
  /// **'The information is incomplete or does not comply with the platform\'s publishing policy.'**
  String get admin_default_reject_reason;

  /// No description provided for @admin_reject_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Reject property publication request'**
  String get admin_reject_dialog_title;

  /// No description provided for @admin_reject_reason_prompt.
  ///
  /// In en, this message translates to:
  /// **'Please enter a reason for rejecting the listing so the property owner can be notified:'**
  String get admin_reject_reason_prompt;

  /// No description provided for @admin_reject_hint.
  ///
  /// In en, this message translates to:
  /// **'Type the rejection reason here...'**
  String get admin_reject_hint;

  /// No description provided for @admin_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get admin_cancel;

  /// No description provided for @admin_confirm_reject.
  ///
  /// In en, this message translates to:
  /// **'Confirm rejection'**
  String get admin_confirm_reject;

  /// No description provided for @admin_reject_saved.
  ///
  /// In en, this message translates to:
  /// **'The listing rejection has been recorded and the reason saved.'**
  String get admin_reject_saved;

  /// No description provided for @admin_reject_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to record the rejection'**
  String get admin_reject_failed;

  /// No description provided for @admin_properties_list_title.
  ///
  /// In en, this message translates to:
  /// **'Property list & publishing control'**
  String get admin_properties_list_title;

  /// No description provided for @admin_export_csv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get admin_export_csv;

  /// No description provided for @admin_export_properties_title.
  ///
  /// In en, this message translates to:
  /// **'Export property data'**
  String get admin_export_properties_title;

  /// No description provided for @admin_no_properties.
  ///
  /// In en, this message translates to:
  /// **'No properties available'**
  String get admin_no_properties;

  /// No description provided for @admin_status_label.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get admin_status_label;

  /// No description provided for @admin_approve_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Approve & publish listing (Mohammed Al-Saqqaf)'**
  String get admin_approve_tooltip;

  /// No description provided for @admin_approved_by_admin.
  ///
  /// In en, this message translates to:
  /// **'Property approved and published by administrator: Mohammed Al-Saqqaf'**
  String get admin_approved_by_admin;

  /// No description provided for @admin_rejected_by_admin_review.
  ///
  /// In en, this message translates to:
  /// **'Rejected by administration after review'**
  String get admin_rejected_by_admin_review;

  /// No description provided for @admin_rejected_status_updated.
  ///
  /// In en, this message translates to:
  /// **'Publication request rejected and status updated'**
  String get admin_rejected_status_updated;

  /// No description provided for @admin_approve_publish_menu.
  ///
  /// In en, this message translates to:
  /// **'Approve publication'**
  String get admin_approve_publish_menu;

  /// No description provided for @admin_hide_listing.
  ///
  /// In en, this message translates to:
  /// **'Hide listing'**
  String get admin_hide_listing;

  /// No description provided for @admin_republish.
  ///
  /// In en, this message translates to:
  /// **'Republish'**
  String get admin_republish;

  /// No description provided for @admin_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get admin_archive;

  /// No description provided for @admin_delete_permanent.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get admin_delete_permanent;

  /// No description provided for @admin_requests_list_title.
  ///
  /// In en, this message translates to:
  /// **'Rental requests & follow-up'**
  String get admin_requests_list_title;

  /// No description provided for @admin_export_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Export rental requests'**
  String get admin_export_requests_title;

  /// No description provided for @admin_no_requests.
  ///
  /// In en, this message translates to:
  /// **'No rental requests recorded'**
  String get admin_no_requests;

  /// No description provided for @admin_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get admin_phone_label;

  /// No description provided for @admin_property_label.
  ///
  /// In en, this message translates to:
  /// **'Property'**
  String get admin_property_label;

  /// No description provided for @admin_status_under_review.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get admin_status_under_review;

  /// No description provided for @admin_status_contacted.
  ///
  /// In en, this message translates to:
  /// **'Contacted'**
  String get admin_status_contacted;

  /// No description provided for @admin_status_provisional.
  ///
  /// In en, this message translates to:
  /// **'Provisionally accepted'**
  String get admin_status_provisional;

  /// No description provided for @admin_status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get admin_status_rejected;

  /// No description provided for @admin_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get admin_status_completed;

  /// No description provided for @admin_commissions_list_title.
  ///
  /// In en, this message translates to:
  /// **'Administrative commission records (manual)'**
  String get admin_commissions_list_title;

  /// No description provided for @admin_add_commission.
  ///
  /// In en, this message translates to:
  /// **'Record commission'**
  String get admin_add_commission;

  /// No description provided for @admin_export_commissions_title.
  ///
  /// In en, this message translates to:
  /// **'Export commission records'**
  String get admin_export_commissions_title;

  /// No description provided for @admin_no_commissions.
  ///
  /// In en, this message translates to:
  /// **'No commission records recorded'**
  String get admin_no_commissions;

  /// No description provided for @admin_commissions_desc.
  ///
  /// In en, this message translates to:
  /// **'Commissions are recorded according to approved decisions (manual entry per agreement)'**
  String get admin_commissions_desc;

  /// No description provided for @admin_registered_property.
  ///
  /// In en, this message translates to:
  /// **'Registered property'**
  String get admin_registered_property;

  /// No description provided for @admin_liable_party.
  ///
  /// In en, this message translates to:
  /// **'Liable party'**
  String get admin_liable_party;

  /// No description provided for @admin_settlement_method.
  ///
  /// In en, this message translates to:
  /// **'Settlement method'**
  String get admin_settlement_method;

  /// No description provided for @admin_awaiting_collection.
  ///
  /// In en, this message translates to:
  /// **'Awaiting collection'**
  String get admin_awaiting_collection;

  /// No description provided for @admin_status_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get admin_status_paid;

  /// No description provided for @admin_status_due.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get admin_status_due;

  /// No description provided for @admin_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get admin_status_cancelled;

  /// No description provided for @admin_commission_modal_title.
  ///
  /// In en, this message translates to:
  /// **'Add a manual commission record'**
  String get admin_commission_modal_title;

  /// No description provided for @admin_commission_property_title.
  ///
  /// In en, this message translates to:
  /// **'Property title or ID *'**
  String get admin_commission_property_title;

  /// No description provided for @admin_commission_property_hint.
  ///
  /// In en, this message translates to:
  /// **'Example: Bayt Bos villa'**
  String get admin_commission_property_hint;

  /// No description provided for @admin_commission_liable.
  ///
  /// In en, this message translates to:
  /// **'Party liable for the commission *'**
  String get admin_commission_liable;

  /// No description provided for @admin_liable_both.
  ///
  /// In en, this message translates to:
  /// **'Both (seller and buyer)'**
  String get admin_liable_both;

  /// No description provided for @admin_liable_seller.
  ///
  /// In en, this message translates to:
  /// **'Seller only'**
  String get admin_liable_seller;

  /// No description provided for @admin_liable_buyer.
  ///
  /// In en, this message translates to:
  /// **'Buyer only'**
  String get admin_liable_buyer;

  /// No description provided for @admin_seller_amount.
  ///
  /// In en, this message translates to:
  /// **'Seller amount'**
  String get admin_seller_amount;

  /// No description provided for @admin_buyer_amount.
  ///
  /// In en, this message translates to:
  /// **'Buyer amount'**
  String get admin_buyer_amount;

  /// No description provided for @admin_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get admin_currency;

  /// No description provided for @admin_commission_notes.
  ///
  /// In en, this message translates to:
  /// **'Commission reason and agreement notes'**
  String get admin_commission_notes;

  /// No description provided for @admin_save_record.
  ///
  /// In en, this message translates to:
  /// **'Save record'**
  String get admin_save_record;

  /// No description provided for @admin_reports_list_title.
  ///
  /// In en, this message translates to:
  /// **'Violating listing reports'**
  String get admin_reports_list_title;

  /// No description provided for @admin_no_reports.
  ///
  /// In en, this message translates to:
  /// **'No violation reports at the moment'**
  String get admin_no_reports;

  /// No description provided for @admin_no_reports_desc.
  ///
  /// In en, this message translates to:
  /// **'All published listings are compliant and no violations have been reported.'**
  String get admin_no_reports_desc;

  /// No description provided for @admin_no_users.
  ///
  /// In en, this message translates to:
  /// **'No user accounts found'**
  String get admin_no_users;

  /// No description provided for @admin_details_label.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get admin_details_label;

  /// No description provided for @admin_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get admin_none;

  /// No description provided for @admin_verified_closed.
  ///
  /// In en, this message translates to:
  /// **'Verified and closed'**
  String get admin_verified_closed;

  /// No description provided for @admin_process.
  ///
  /// In en, this message translates to:
  /// **'Process'**
  String get admin_process;

  /// No description provided for @admin_encrypted_section_title.
  ///
  /// In en, this message translates to:
  /// **'Encrypted, protected section for the General Manager only'**
  String get admin_encrypted_section_title;

  /// No description provided for @admin_encrypted_section_desc.
  ///
  /// In en, this message translates to:
  /// **'Under security and encryption policies, user data is visible only to the General Manager (M. Mohammed Al-Saqqaf) to ensure full privacy.'**
  String get admin_encrypted_section_desc;

  /// No description provided for @admin_users_list_title.
  ///
  /// In en, this message translates to:
  /// **'User account registry (encrypted and protected data)'**
  String get admin_users_list_title;

  /// No description provided for @admin_gm_permissions.
  ///
  /// In en, this message translates to:
  /// **'General Manager permissions'**
  String get admin_gm_permissions;

  /// No description provided for @admin_data_protection.
  ///
  /// In en, this message translates to:
  /// **'Data protection: passwords and sensitive details are encrypted with the standard encryption system, and the General Manager only sees the user\'s name and account.'**
  String get admin_data_protection;

  /// No description provided for @admin_account_label.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get admin_account_label;

  /// No description provided for @admin_created_at.
  ///
  /// In en, this message translates to:
  /// **'Creation date'**
  String get admin_created_at;

  /// No description provided for @admin_encrypted_protected.
  ///
  /// In en, this message translates to:
  /// **'Encrypted & protected'**
  String get admin_encrypted_protected;

  /// No description provided for @admin_section_users.
  ///
  /// In en, this message translates to:
  /// **'User registry'**
  String get admin_section_users;

  /// No description provided for @admin_pdf_preparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing and printing a full PDF report for section:'**
  String get admin_pdf_preparing;

  /// No description provided for @admin_day_monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get admin_day_monday;

  /// No description provided for @admin_day_tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get admin_day_tuesday;

  /// No description provided for @admin_day_wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get admin_day_wednesday;

  /// No description provided for @admin_day_thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get admin_day_thursday;

  /// No description provided for @admin_day_friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get admin_day_friday;

  /// No description provided for @admin_day_saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get admin_day_saturday;

  /// No description provided for @admin_day_sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get admin_day_sunday;

  /// No description provided for @admin_month_january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get admin_month_january;

  /// No description provided for @admin_month_february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get admin_month_february;

  /// No description provided for @admin_month_march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get admin_month_march;

  /// No description provided for @admin_month_april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get admin_month_april;

  /// No description provided for @admin_month_may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get admin_month_may;

  /// No description provided for @admin_month_june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get admin_month_june;

  /// No description provided for @admin_month_july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get admin_month_july;

  /// No description provided for @admin_month_august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get admin_month_august;

  /// No description provided for @admin_month_september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get admin_month_september;

  /// No description provided for @admin_month_october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get admin_month_october;

  /// No description provided for @admin_month_november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get admin_month_november;

  /// No description provided for @admin_month_december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get admin_month_december;

  /// No description provided for @admin_pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get admin_pm;

  /// No description provided for @admin_am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get admin_am;

  /// No description provided for @admin_sanaa_time.
  ///
  /// In en, this message translates to:
  /// **'(Sana\'a time)'**
  String get admin_sanaa_time;

  /// No description provided for @admin_col_property_id.
  ///
  /// In en, this message translates to:
  /// **'Property ID'**
  String get admin_col_property_id;

  /// No description provided for @admin_col_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get admin_col_address;

  /// No description provided for @admin_col_deal.
  ///
  /// In en, this message translates to:
  /// **'Deal'**
  String get admin_col_deal;

  /// No description provided for @admin_col_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get admin_col_city;

  /// No description provided for @admin_col_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get admin_col_price;

  /// No description provided for @admin_col_request_id.
  ///
  /// In en, this message translates to:
  /// **'Request ID'**
  String get admin_col_request_id;

  /// No description provided for @admin_col_tenant.
  ///
  /// In en, this message translates to:
  /// **'Tenant'**
  String get admin_col_tenant;

  /// No description provided for @admin_col_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get admin_col_phone;

  /// No description provided for @admin_col_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get admin_col_start_date;

  /// No description provided for @admin_col_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get admin_col_id;

  /// No description provided for @admin_col_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get admin_col_amount;

  /// No description provided for @admin_col_settlement_status.
  ///
  /// In en, this message translates to:
  /// **'Settlement status'**
  String get admin_col_settlement_status;

  /// No description provided for @admin_col_report_reason.
  ///
  /// In en, this message translates to:
  /// **'Report reason'**
  String get admin_col_report_reason;

  /// No description provided for @admin_col_report_date.
  ///
  /// In en, this message translates to:
  /// **'Report date'**
  String get admin_col_report_date;

  /// No description provided for @admin_status_resolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get admin_status_resolved;

  /// No description provided for @admin_col_number.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get admin_col_number;

  /// No description provided for @admin_col_username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get admin_col_username;

  /// No description provided for @admin_col_account_email.
  ///
  /// In en, this message translates to:
  /// **'Account (email)'**
  String get admin_col_account_email;

  /// No description provided for @admin_col_encryption_status.
  ///
  /// In en, this message translates to:
  /// **'Encryption status'**
  String get admin_col_encryption_status;

  /// No description provided for @admin_encrypted_protected_pdf.
  ///
  /// In en, this message translates to:
  /// **'🔒 Encrypted & protected'**
  String get admin_encrypted_protected_pdf;

  /// No description provided for @admin_pdf_bismillah.
  ///
  /// In en, this message translates to:
  /// **'In the name of Allah, the Most Gracious, the Most Merciful'**
  String get admin_pdf_bismillah;

  /// No description provided for @admin_pdf_republic.
  ///
  /// In en, this message translates to:
  /// **'Republic of Yemen — Yemen Real Estate Portal'**
  String get admin_pdf_republic;

  /// No description provided for @admin_pdf_report_header.
  ///
  /// In en, this message translates to:
  /// **'General Administration — Official comprehensive report'**
  String get admin_pdf_report_header;

  /// No description provided for @admin_pdf_section.
  ///
  /// In en, this message translates to:
  /// **'Section'**
  String get admin_pdf_section;

  /// No description provided for @admin_pdf_issuer.
  ///
  /// In en, this message translates to:
  /// **'Issued by: General Manager (M. Mohammed Al-Saqqaf)'**
  String get admin_pdf_issuer;

  /// No description provided for @admin_pdf_day_label.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get admin_pdf_day_label;

  /// No description provided for @admin_pdf_date_label.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get admin_pdf_date_label;

  /// No description provided for @admin_pdf_month_label.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get admin_pdf_month_label;

  /// No description provided for @admin_pdf_year_label.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get admin_pdf_year_label;

  /// No description provided for @admin_pdf_year_suffix.
  ///
  /// In en, this message translates to:
  /// **'AD'**
  String get admin_pdf_year_suffix;

  /// No description provided for @admin_pdf_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get admin_pdf_time_label;

  /// No description provided for @admin_pdf_total_items.
  ///
  /// In en, this message translates to:
  /// **'Total section items'**
  String get admin_pdf_total_items;

  /// No description provided for @admin_pdf_data_status.
  ///
  /// In en, this message translates to:
  /// **'Data status: approved and updated in real time'**
  String get admin_pdf_data_status;

  /// No description provided for @admin_pdf_no_data.
  ///
  /// In en, this message translates to:
  /// **'No data recorded currently'**
  String get admin_pdf_no_data;

  /// No description provided for @admin_pdf_copyright.
  ///
  /// In en, this message translates to:
  /// **'Hiba Soft — All rights reserved © 2026'**
  String get admin_pdf_copyright;

  /// No description provided for @admin_pdf_doc_footer.
  ///
  /// In en, this message translates to:
  /// **'Official administrative document — encrypted and certified'**
  String get admin_pdf_doc_footer;

  /// No description provided for @admin_report_filename_prefix.
  ///
  /// In en, this message translates to:
  /// **'report_'**
  String get admin_report_filename_prefix;

  /// No description provided for @admin_pdf_export_success.
  ///
  /// In en, this message translates to:
  /// **'The PDF report was exported successfully'**
  String get admin_pdf_export_success;

  /// No description provided for @admin_pdf_saved_prefix.
  ///
  /// In en, this message translates to:
  /// **'The comprehensive report for section \"'**
  String get admin_pdf_saved_prefix;

  /// No description provided for @admin_pdf_saved_suffix.
  ///
  /// In en, this message translates to:
  /// **'\" has been saved, including the day, date, month, year and exact time in Sana\'a.'**
  String get admin_pdf_saved_suffix;

  /// No description provided for @admin_pdf_file_name.
  ///
  /// In en, this message translates to:
  /// **'📁 File name:'**
  String get admin_pdf_file_name;

  /// No description provided for @admin_pdf_save_path.
  ///
  /// In en, this message translates to:
  /// **'📍 Saved path on device:'**
  String get admin_pdf_save_path;

  /// No description provided for @admin_copy_path.
  ///
  /// In en, this message translates to:
  /// **'Copy path'**
  String get admin_copy_path;

  /// No description provided for @admin_path_copied.
  ///
  /// In en, this message translates to:
  /// **'File path copied to clipboard'**
  String get admin_path_copied;

  /// No description provided for @admin_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get admin_ok;

  /// No description provided for @admin_export_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export the report'**
  String get admin_export_failed;

  /// No description provided for @admin_copy_data.
  ///
  /// In en, this message translates to:
  /// **'Copy data'**
  String get admin_copy_data;

  /// No description provided for @admin_csv_copied.
  ///
  /// In en, this message translates to:
  /// **'CSV data copied to clipboard successfully'**
  String get admin_csv_copied;

  /// No description provided for @admin_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get admin_close;

  /// No description provided for @contract_auth_prompt_message.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get contract_auth_prompt_message;

  /// No description provided for @contract_clauses_saved.
  ///
  /// In en, this message translates to:
  /// **'Contract clauses saved and updated successfully'**
  String get contract_clauses_saved;

  /// No description provided for @contract_bismillah.
  ///
  /// In en, this message translates to:
  /// **'In the name of Allah, the Most Gracious, the Most Merciful'**
  String get contract_bismillah;

  /// No description provided for @contract_republic.
  ///
  /// In en, this message translates to:
  /// **'Republic of Yemen'**
  String get contract_republic;

  /// No description provided for @contract_edit_date.
  ///
  /// In en, this message translates to:
  /// **'Draft date:'**
  String get contract_edit_date;

  /// No description provided for @contract_first_party.
  ///
  /// In en, this message translates to:
  /// **'First party (lessor / owner):'**
  String get contract_first_party;

  /// No description provided for @contract_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone:'**
  String get contract_phone;

  /// No description provided for @contract_address.
  ///
  /// In en, this message translates to:
  /// **'Address:'**
  String get contract_address;

  /// No description provided for @contract_second_party.
  ///
  /// In en, this message translates to:
  /// **'Second party (tenant):'**
  String get contract_second_party;

  /// No description provided for @contract_id_card_number.
  ///
  /// In en, this message translates to:
  /// **'Personal ID card no.:'**
  String get contract_id_card_number;

  /// No description provided for @contract_tenant_id_label.
  ///
  /// In en, this message translates to:
  /// **'Personal ID card / identity number *'**
  String get contract_tenant_id_label;

  /// No description provided for @contract_leased_property.
  ///
  /// In en, this message translates to:
  /// **'Leased property:'**
  String get contract_leased_property;

  /// No description provided for @contract_property_in_governorate.
  ///
  /// In en, this message translates to:
  /// **'Property located in governorate of'**
  String get contract_property_in_governorate;

  /// No description provided for @contract_district_label.
  ///
  /// In en, this message translates to:
  /// **'- District:'**
  String get contract_district_label;

  /// No description provided for @contract_specifications.
  ///
  /// In en, this message translates to:
  /// **'Specifications:'**
  String get contract_specifications;

  /// No description provided for @contract_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions of the agreement:'**
  String get contract_terms_title;

  /// No description provided for @contract_clause1_title.
  ///
  /// In en, this message translates to:
  /// **'Contract term:'**
  String get contract_clause1_title;

  /// No description provided for @contract_starts_from_date.
  ///
  /// In en, this message translates to:
  /// **'starting from'**
  String get contract_starts_from_date;

  /// No description provided for @contract_until_date.
  ///
  /// In en, this message translates to:
  /// **'until'**
  String get contract_until_date;

  /// No description provided for @contract_non_renewable_plain.
  ///
  /// In en, this message translates to:
  /// **'Not renewable except at the request and with the written consent of the first party.'**
  String get contract_non_renewable_plain;

  /// No description provided for @contract_auto_renew_plain.
  ///
  /// In en, this message translates to:
  /// **'Renews automatically unless either party notifies the other one month in advance.'**
  String get contract_auto_renew_plain;

  /// No description provided for @contract_clause2_title.
  ///
  /// In en, this message translates to:
  /// **'Agreed rent:'**
  String get contract_clause2_title;

  /// No description provided for @contract_amount_of.
  ///
  /// In en, this message translates to:
  /// **'an amount of'**
  String get contract_amount_of;

  /// No description provided for @contract_paid.
  ///
  /// In en, this message translates to:
  /// **'payable'**
  String get contract_paid;

  /// No description provided for @contract_clause3_title.
  ///
  /// In en, this message translates to:
  /// **'Security deposit / insurance amount:'**
  String get contract_clause3_title;

  /// No description provided for @contract_deposit_return.
  ///
  /// In en, this message translates to:
  /// **'Paid to the lessor and returned to the tenant upon expiry of the contract and handover of the property in its original condition.'**
  String get contract_deposit_return;

  /// No description provided for @contract_clause4_title.
  ///
  /// In en, this message translates to:
  /// **'Utility bills:'**
  String get contract_clause4_title;

  /// No description provided for @contract_clause5_title.
  ///
  /// In en, this message translates to:
  /// **'Maintenance and use:'**
  String get contract_clause5_title;

  /// No description provided for @contract_clause6_title.
  ///
  /// In en, this message translates to:
  /// **'Prohibition of subletting:'**
  String get contract_clause6_title;

  /// No description provided for @contract_sublease_ban_text.
  ///
  /// In en, this message translates to:
  /// **'This contract is personal to the tenant, who may not assign, transfer or sublet it in whole or in part.'**
  String get contract_sublease_ban_text;

  /// No description provided for @contract_clause7_title.
  ///
  /// In en, this message translates to:
  /// **'Late payment:'**
  String get contract_clause7_title;

  /// No description provided for @contract_clause8_title.
  ///
  /// In en, this message translates to:
  /// **'Additional special conditions from the lessor:'**
  String get contract_clause8_title;

  /// No description provided for @contract_owner_signature.
  ///
  /// In en, this message translates to:
  /// **'Signature of the first party (lessor): .....................'**
  String get contract_owner_signature;

  /// No description provided for @contract_tenant_signature.
  ///
  /// In en, this message translates to:
  /// **'Signature of the second party (tenant): .....................'**
  String get contract_tenant_signature;

  /// No description provided for @contract_witnesses_line.
  ///
  /// In en, this message translates to:
  /// **'First witness: .....................    Second witness: .....................'**
  String get contract_witnesses_line;

  /// No description provided for @contract_text_copied.
  ///
  /// In en, this message translates to:
  /// **'The full contract text was copied to the clipboard; you can paste and print it in any application'**
  String get contract_text_copied;

  /// No description provided for @contract_default_title.
  ///
  /// In en, this message translates to:
  /// **'Legal and Sharia-compliant lease contract'**
  String get contract_default_title;

  /// No description provided for @contract_first_party_pdf.
  ///
  /// In en, this message translates to:
  /// **'First party (lessor/owner):'**
  String get contract_first_party_pdf;

  /// No description provided for @contract_id_number.
  ///
  /// In en, this message translates to:
  /// **'ID no.:'**
  String get contract_id_number;

  /// No description provided for @contract_tenant_phone.
  ///
  /// In en, this message translates to:
  /// **'Tenant phone:'**
  String get contract_tenant_phone;

  /// No description provided for @contract_residence.
  ///
  /// In en, this message translates to:
  /// **'Place of residence:'**
  String get contract_residence;

  /// No description provided for @contract_start_date.
  ///
  /// In en, this message translates to:
  /// **'Start date:'**
  String get contract_start_date;

  /// No description provided for @contract_pdf_terms_title.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions of the agreement:'**
  String get contract_pdf_terms_title;

  /// No description provided for @contract_renew_by_mutual_consent.
  ///
  /// In en, this message translates to:
  /// **'Renews by mutual consent of both parties.'**
  String get contract_renew_by_mutual_consent;

  /// No description provided for @contract_monthly_rent_agreed.
  ///
  /// In en, this message translates to:
  /// **'Agreed monthly rent:'**
  String get contract_monthly_rent_agreed;

  /// No description provided for @contract_pdf_rent_tail.
  ///
  /// In en, this message translates to:
  /// **'in advance with official receipts; a two-week delay voids the contract.'**
  String get contract_pdf_rent_tail;

  /// No description provided for @contract_personal_clause.
  ///
  /// In en, this message translates to:
  /// **'This contract is personal between the above parties and was made with their full conviction and consent; it is not subject to any terms harmful to the lessor.'**
  String get contract_personal_clause;

  /// No description provided for @contract_tenant_acknowledgement.
  ///
  /// In en, this message translates to:
  /// **'The tenant acknowledges receiving the leased property in sound condition and undertakes to maintain it inside and out, and bears responsibility for any damage or defect occurring to the leased property.'**
  String get contract_tenant_acknowledgement;

  /// No description provided for @contract_no_transfer_clause.
  ///
  /// In en, this message translates to:
  /// **'The contract is personal to the tenant named above; it may not be assigned to others, whether covertly or openly, and no transfer of tenancy is permitted.'**
  String get contract_no_transfer_clause;

  /// No description provided for @contract_liability_clause.
  ///
  /// In en, this message translates to:
  /// **'The lessor is not liable for any damage or risks to lives or assets for any reason, including fire, rain, floods or theft.'**
  String get contract_liability_clause;

  /// No description provided for @contract_deposit_title.
  ///
  /// In en, this message translates to:
  /// **'Deposit and insurance:'**
  String get contract_deposit_title;

  /// No description provided for @contract_deposit_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Security deposit and insurance:'**
  String get contract_deposit_screen_title;

  /// No description provided for @contract_paid_amount.
  ///
  /// In en, this message translates to:
  /// **'paid an amount of'**
  String get contract_paid_amount;

  /// No description provided for @contract_deposit_tail.
  ///
  /// In en, this message translates to:
  /// **'as a security deposit refunded upon handover of the property in its original condition.'**
  String get contract_deposit_tail;

  /// No description provided for @contract_owner_signature_short.
  ///
  /// In en, this message translates to:
  /// **'Lessor signature (first party)'**
  String get contract_owner_signature_short;

  /// No description provided for @contract_tenant_signature_short.
  ///
  /// In en, this message translates to:
  /// **'Tenant signature (second party)'**
  String get contract_tenant_signature_short;

  /// No description provided for @contract_witness_short.
  ///
  /// In en, this message translates to:
  /// **'First / second witness'**
  String get contract_witness_short;

  /// No description provided for @contract_portal_name_suffix.
  ///
  /// In en, this message translates to:
  /// **'— Yemen Real Estate Portal'**
  String get contract_portal_name_suffix;

  /// No description provided for @contract_pdf_saved_title.
  ///
  /// In en, this message translates to:
  /// **'Contract PDF saved'**
  String get contract_pdf_saved_title;

  /// No description provided for @contract_pdf_saved_body_before.
  ///
  /// In en, this message translates to:
  /// **'The official contract PDF has been saved successfully on your device:\n\n📂 Path:'**
  String get contract_pdf_saved_body_before;

  /// No description provided for @contract_pdf_saved_body_after.
  ///
  /// In en, this message translates to:
  /// **'You can now send it via WhatsApp, print it, or open it with a file manager (Downloads).'**
  String get contract_pdf_saved_body_after;

  /// No description provided for @contract_copy_text.
  ///
  /// In en, this message translates to:
  /// **'Copy contract text'**
  String get contract_copy_text;

  /// No description provided for @contract_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get contract_cancel;

  /// No description provided for @contract_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get contract_ok;

  /// No description provided for @contract_pdf_save_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the PDF file'**
  String get contract_pdf_save_error;

  /// No description provided for @contract_app_bar_title.
  ///
  /// In en, this message translates to:
  /// **'Contract preview and customization'**
  String get contract_app_bar_title;

  /// No description provided for @contract_edit_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit and customize clauses'**
  String get contract_edit_tooltip;

  /// No description provided for @contract_save_pdf.
  ///
  /// In en, this message translates to:
  /// **'Save contract PDF'**
  String get contract_save_pdf;

  /// No description provided for @contract_edit_clauses.
  ///
  /// In en, this message translates to:
  /// **'Edit clauses'**
  String get contract_edit_clauses;

  /// No description provided for @contract_print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get contract_print;

  /// No description provided for @contract_number.
  ///
  /// In en, this message translates to:
  /// **'Contract no.:'**
  String get contract_number;

  /// No description provided for @contract_fill_intro_title.
  ///
  /// In en, this message translates to:
  /// **'Fill in and write the contract details directly'**
  String get contract_fill_intro_title;

  /// No description provided for @contract_fill_intro_body.
  ///
  /// In en, this message translates to:
  /// **'Tap here or any field to enter the tenant and lessor names, ID numbers, amounts and contract terms so they appear printed in the PDF without blank spaces'**
  String get contract_fill_intro_body;

  /// No description provided for @contract_fill_fields.
  ///
  /// In en, this message translates to:
  /// **'Fill in fields'**
  String get contract_fill_fields;

  /// No description provided for @contract_section_parties.
  ///
  /// In en, this message translates to:
  /// **'First: Contract parties'**
  String get contract_section_parties;

  /// No description provided for @contract_first_party_box.
  ///
  /// In en, this message translates to:
  /// **'First party (lessor / owner):'**
  String get contract_first_party_box;

  /// No description provided for @contract_section_property.
  ///
  /// In en, this message translates to:
  /// **'Second: Leased property details and location'**
  String get contract_section_property;

  /// No description provided for @contract_approx_area_prefix.
  ///
  /// In en, this message translates to:
  /// **'with an approximate area of'**
  String get contract_approx_area_prefix;

  /// No description provided for @contract_sqm_unit.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get contract_sqm_unit;

  /// No description provided for @contract_section_clauses.
  ///
  /// In en, this message translates to:
  /// **'Third: Legal and Sharia-compliant terms and conditions'**
  String get contract_section_clauses;

  /// No description provided for @contract_clause1_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Contract term and effective date:'**
  String get contract_clause1_screen_title;

  /// No description provided for @contract_duration_label.
  ///
  /// In en, this message translates to:
  /// **'Contract term'**
  String get contract_duration_label;

  /// No description provided for @contract_ends_on_date.
  ///
  /// In en, this message translates to:
  /// **'and ending on'**
  String get contract_ends_on_date;

  /// No description provided for @contract_non_renewable_screen.
  ///
  /// In en, this message translates to:
  /// **'It is not renewable except at the request and with the express written consent of the first party.'**
  String get contract_non_renewable_screen;

  /// No description provided for @contract_renewable_by_consent.
  ///
  /// In en, this message translates to:
  /// **'Renewable by mutual consent of both parties.'**
  String get contract_renewable_by_consent;

  /// No description provided for @contract_clause2_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Rental value and payment method:'**
  String get contract_clause2_screen_title;

  /// No description provided for @contract_agreed_monthly_value.
  ///
  /// In en, this message translates to:
  /// **'The parties agreed on a monthly rent of'**
  String get contract_agreed_monthly_value;

  /// No description provided for @contract_receipt_tail.
  ///
  /// In en, this message translates to:
  /// **'with signed payment receipts.'**
  String get contract_receipt_tail;

  /// No description provided for @contract_deposit_preamble.
  ///
  /// In en, this message translates to:
  /// **'The second party pays a security and insurance amount of'**
  String get contract_deposit_preamble;

  /// No description provided for @contract_deposit_screen_tail.
  ///
  /// In en, this message translates to:
  /// **'held by the first party as a deposit for maintenance, cleanliness and bill payment, and refunded to the tenant upon vacating in sound condition.'**
  String get contract_deposit_screen_tail;

  /// No description provided for @contract_utilities_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Utility and consumption bills:'**
  String get contract_utilities_screen_title;

  /// No description provided for @contract_bears_utilities.
  ///
  /// In en, this message translates to:
  /// **'shall bear'**
  String get contract_bears_utilities;

  /// No description provided for @contract_utilities_tail.
  ///
  /// In en, this message translates to:
  /// **'all electricity, water, cleaning and communication charges related to the leased property throughout the lease term.'**
  String get contract_utilities_tail;

  /// No description provided for @contract_maintenance_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Property care and maintenance:'**
  String get contract_maintenance_screen_title;

  /// No description provided for @contract_no_alterations.
  ///
  /// In en, this message translates to:
  /// **'The tenant may not make any openings or alterations to the building without prior written permission.'**
  String get contract_no_alterations;

  /// No description provided for @contract_sublease_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Prohibition of subletting or transferring tenancy:'**
  String get contract_sublease_screen_title;

  /// No description provided for @contract_sublease_ban_screen_text.
  ///
  /// In en, this message translates to:
  /// **'This contract is personal to the tenant only; they may not assign it to others in whole or in part, whether by subletting or transferring tenancy.'**
  String get contract_sublease_ban_screen_text;

  /// No description provided for @contract_termination_title.
  ///
  /// In en, this message translates to:
  /// **'Contract termination and vacating the property:'**
  String get contract_termination_title;

  /// No description provided for @contract_extra_clauses_title.
  ///
  /// In en, this message translates to:
  /// **'Additional special conditions from the lessor:'**
  String get contract_extra_clauses_title;

  /// No description provided for @contract_section_signatures.
  ///
  /// In en, this message translates to:
  /// **'Fourth: Acknowledgement and signatures'**
  String get contract_section_signatures;

  /// No description provided for @contract_witness1.
  ///
  /// In en, this message translates to:
  /// **'First witness'**
  String get contract_witness1;

  /// No description provided for @contract_witness2.
  ///
  /// In en, this message translates to:
  /// **'Second witness'**
  String get contract_witness2;

  /// No description provided for @contract_footer_notice.
  ///
  /// In en, this message translates to:
  /// **'Official document issued by the Yemen Real Estate Portal — Hiba Soft © 2026'**
  String get contract_footer_notice;

  /// No description provided for @contract_write_edit.
  ///
  /// In en, this message translates to:
  /// **'Write / edit'**
  String get contract_write_edit;

  /// No description provided for @contract_name_label.
  ///
  /// In en, this message translates to:
  /// **'Name:'**
  String get contract_name_label;

  /// No description provided for @contract_identity_label.
  ///
  /// In en, this message translates to:
  /// **'ID / card:'**
  String get contract_identity_label;

  /// No description provided for @contract_signature_stamp.
  ///
  /// In en, this message translates to:
  /// **'Signature / fingerprint: ...................'**
  String get contract_signature_stamp;

  /// No description provided for @contract_sheet_title.
  ///
  /// In en, this message translates to:
  /// **'Fill in and edit contract details'**
  String get contract_sheet_title;

  /// No description provided for @contract_tab_parties.
  ///
  /// In en, this message translates to:
  /// **'Tenant and lessor'**
  String get contract_tab_parties;

  /// No description provided for @contract_tab_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms and finances'**
  String get contract_tab_terms;

  /// No description provided for @contract_tenant_section_title.
  ///
  /// In en, this message translates to:
  /// **'Second party (tenant) - fill in the blanks'**
  String get contract_tenant_section_title;

  /// No description provided for @contract_tenant_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full tenant name *'**
  String get contract_tenant_name_label;

  /// No description provided for @contract_tenant_name_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mohammed Abdullah Al-Ahdal'**
  String get contract_tenant_name_hint;

  /// No description provided for @contract_id_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 01010023456'**
  String get contract_id_hint;

  /// No description provided for @contract_contact_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number *'**
  String get contract_contact_phone_label;

  /// No description provided for @contract_tenant_address_label.
  ///
  /// In en, this message translates to:
  /// **'Current address and place of residence'**
  String get contract_tenant_address_label;

  /// No description provided for @contract_tenant_address_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sanaa - Al-Asbahi'**
  String get contract_tenant_address_hint;

  /// No description provided for @contract_owner_section_title.
  ///
  /// In en, this message translates to:
  /// **'First party (lessor / owner)'**
  String get contract_owner_section_title;

  /// No description provided for @contract_owner_name_label.
  ///
  /// In en, this message translates to:
  /// **'Lessor / owner name *'**
  String get contract_owner_name_label;

  /// No description provided for @contract_owner_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Full four-part name of the owner'**
  String get contract_owner_name_hint;

  /// No description provided for @contract_owner_id_label.
  ///
  /// In en, this message translates to:
  /// **'Lessor personal ID number'**
  String get contract_owner_id_label;

  /// No description provided for @contract_id_number_hint.
  ///
  /// In en, this message translates to:
  /// **'ID number'**
  String get contract_id_number_hint;

  /// No description provided for @contract_owner_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Lessor phone *'**
  String get contract_owner_phone_label;

  /// No description provided for @contract_contact_phone_hint.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get contract_contact_phone_hint;

  /// No description provided for @contract_owner_address_label.
  ///
  /// In en, this message translates to:
  /// **'Registered lessor address'**
  String get contract_owner_address_label;

  /// No description provided for @contract_owner_address_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Sanaa - Hadda'**
  String get contract_owner_address_hint;

  /// No description provided for @contract_formal_title_label.
  ///
  /// In en, this message translates to:
  /// **'Official contract title'**
  String get contract_formal_title_label;

  /// No description provided for @contract_rent_amount_label.
  ///
  /// In en, this message translates to:
  /// **'Rent amount'**
  String get contract_rent_amount_label;

  /// No description provided for @contract_deposit_label.
  ///
  /// In en, this message translates to:
  /// **'Security deposit and insurance'**
  String get contract_deposit_label;

  /// No description provided for @contract_duration_hint.
  ///
  /// In en, this message translates to:
  /// **'One full year'**
  String get contract_duration_hint;

  /// No description provided for @contract_start_date_label.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get contract_start_date_label;

  /// No description provided for @contract_end_date_label.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get contract_end_date_label;

  /// No description provided for @contract_non_renewable_switch_title.
  ///
  /// In en, this message translates to:
  /// **'Non-renewable except at the owner\'s request and with their consent'**
  String get contract_non_renewable_switch_title;

  /// No description provided for @contract_non_renewable_switch_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Protects the lessor\'s right to decide whether to renew'**
  String get contract_non_renewable_switch_subtitle;

  /// No description provided for @contract_sublease_switch_title.
  ///
  /// In en, this message translates to:
  /// **'Strictly prohibit subletting or transferring tenancy'**
  String get contract_sublease_switch_title;

  /// No description provided for @contract_sublease_switch_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevents the tenant from handing the property to another person without the owner\'s written consent'**
  String get contract_sublease_switch_subtitle;

  /// No description provided for @contract_utilities_label.
  ///
  /// In en, this message translates to:
  /// **'Utility bill responsibility (electricity, water)'**
  String get contract_utilities_label;

  /// No description provided for @contract_maintenance_label.
  ///
  /// In en, this message translates to:
  /// **'Maintenance terms and property handover'**
  String get contract_maintenance_label;

  /// No description provided for @contract_late_policy_label.
  ///
  /// In en, this message translates to:
  /// **'Late payment and termination clause'**
  String get contract_late_policy_label;

  /// No description provided for @contract_extra_owner_clauses_title.
  ///
  /// In en, this message translates to:
  /// **'Additional special conditions from the owner:'**
  String get contract_extra_owner_clauses_title;

  /// No description provided for @contract_custom_clause_hint.
  ///
  /// In en, this message translates to:
  /// **'Write a custom clause (e.g. no smoking indoors)...'**
  String get contract_custom_clause_hint;

  /// No description provided for @contract_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get contract_add;

  /// No description provided for @contract_save_template_title.
  ///
  /// In en, this message translates to:
  /// **'Save this contract as a default template for my future properties'**
  String get contract_save_template_title;

  /// No description provided for @contract_save_template_subtitle.
  ///
  /// In en, this message translates to:
  /// **'When enabled, these terms will be applied automatically when adding any new listing'**
  String get contract_save_template_subtitle;

  /// No description provided for @contract_save_apply.
  ///
  /// In en, this message translates to:
  /// **'Save and apply changes'**
  String get contract_save_apply;

  /// No description provided for @contract_pdf_filename.
  ///
  /// In en, this message translates to:
  /// **'lease_contract'**
  String get contract_pdf_filename;

  /// No description provided for @dash_add_listing_now.
  ///
  /// In en, this message translates to:
  /// **'Add Your Listing Now'**
  String get dash_add_listing_now;

  /// No description provided for @dash_add_property_free.
  ///
  /// In en, this message translates to:
  /// **'Add Your Property for Free'**
  String get dash_add_property_free;

  /// No description provided for @dash_add_property_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get dash_add_property_prompt;

  /// No description provided for @dash_add_property_tooltip.
  ///
  /// In en, this message translates to:
  /// **'Add your property'**
  String get dash_add_property_tooltip;

  /// No description provided for @dash_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get dash_all;

  /// No description provided for @dash_all_governorates.
  ///
  /// In en, this message translates to:
  /// **'All Governorates'**
  String get dash_all_governorates;

  /// No description provided for @dash_all_governorates_show_all.
  ///
  /// In en, this message translates to:
  /// **'All Yemeni Governorates (Show All)'**
  String get dash_all_governorates_show_all;

  /// No description provided for @dash_cta_desc_desktop.
  ///
  /// In en, this message translates to:
  /// **'Post your ad on the Yemen Real Estate portal with instant self-review and direct communication with clients.'**
  String get dash_cta_desc_desktop;

  /// No description provided for @dash_cta_desc_mobile.
  ///
  /// In en, this message translates to:
  /// **'Post your ad for free on the Yemen Real Estate portal and connect directly with thousands of property seekers.'**
  String get dash_cta_desc_mobile;

  /// No description provided for @dash_cta_title.
  ///
  /// In en, this message translates to:
  /// **'Do you have a property you want to sell or rent?'**
  String get dash_cta_title;

  /// No description provided for @dash_districts_of_gov.
  ///
  /// In en, this message translates to:
  /// **'Districts and areas of'**
  String get dash_districts_of_gov;

  /// No description provided for @dash_empty_section_description.
  ///
  /// In en, this message translates to:
  /// **'Check back for newly added listings or browse the other sections'**
  String get dash_empty_section_description;

  /// No description provided for @dash_empty_section_title.
  ///
  /// In en, this message translates to:
  /// **'No properties in this section yet'**
  String get dash_empty_section_title;

  /// No description provided for @dash_featured_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Trusted and featured properties across Yemen'**
  String get dash_featured_subtitle;

  /// No description provided for @dash_featured_title.
  ///
  /// In en, this message translates to:
  /// **'Featured Properties'**
  String get dash_featured_title;

  /// No description provided for @dash_for_rent_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Residential apartments and commercial spaces ready for rent'**
  String get dash_for_rent_subtitle;

  /// No description provided for @dash_for_rent_title.
  ///
  /// In en, this message translates to:
  /// **'Latest Properties for Rent'**
  String get dash_for_rent_title;

  /// No description provided for @dash_for_sale_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Apartments, villas, and land offered for direct sale'**
  String get dash_for_sale_subtitle;

  /// No description provided for @dash_for_sale_title.
  ///
  /// In en, this message translates to:
  /// **'Latest Properties for Sale'**
  String get dash_for_sale_title;

  /// No description provided for @dash_governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get dash_governorate;

  /// No description provided for @dash_hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Thousands of apartments, villas, land, and commercial shops for sale or rent directly from owners'**
  String get dash_hero_subtitle;

  /// No description provided for @dash_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Find Your Dream Property in Yemen'**
  String get dash_hero_title;

  /// No description provided for @dash_loading_featured.
  ///
  /// In en, this message translates to:
  /// **'Loading featured properties...'**
  String get dash_loading_featured;

  /// No description provided for @dash_loading_for_rent.
  ///
  /// In en, this message translates to:
  /// **'Loading rental properties...'**
  String get dash_loading_for_rent;

  /// No description provided for @dash_loading_for_sale.
  ///
  /// In en, this message translates to:
  /// **'Loading properties for sale...'**
  String get dash_loading_for_sale;

  /// No description provided for @dash_location_dialog_message.
  ///
  /// In en, this message translates to:
  /// **'Allowing access to your location shows the nearest properties on the map and in the list. You can change this later in Settings.'**
  String get dash_location_dialog_message;

  /// No description provided for @dash_location_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Find properties near you'**
  String get dash_location_dialog_title;

  /// No description provided for @dash_location_no_thanks.
  ///
  /// In en, this message translates to:
  /// **'No, thanks'**
  String get dash_location_no_thanks;

  /// No description provided for @dash_location_use_my_location.
  ///
  /// In en, this message translates to:
  /// **'Use my location'**
  String get dash_location_use_my_location;

  /// No description provided for @dash_nearby_fallback_count.
  ///
  /// In en, this message translates to:
  /// **'properties near Ibb (default)'**
  String get dash_nearby_fallback_count;

  /// No description provided for @dash_nearby_in_range_count.
  ///
  /// In en, this message translates to:
  /// **'properties in range'**
  String get dash_nearby_in_range_count;

  /// No description provided for @dash_nearby_title.
  ///
  /// In en, this message translates to:
  /// **'Properties near you'**
  String get dash_nearby_title;

  /// No description provided for @dash_no_nearby_properties.
  ///
  /// In en, this message translates to:
  /// **'No properties within range. Adjust the radius in Settings.'**
  String get dash_no_nearby_properties;

  /// No description provided for @dash_or_select_specific_district.
  ///
  /// In en, this message translates to:
  /// **'Or choose a specific district / area:'**
  String get dash_or_select_specific_district;

  /// No description provided for @dash_properties_for_rent.
  ///
  /// In en, this message translates to:
  /// **'Properties for Rent'**
  String get dash_properties_for_rent;

  /// No description provided for @dash_properties_for_sale.
  ///
  /// In en, this message translates to:
  /// **'Properties for Sale'**
  String get dash_properties_for_sale;

  /// No description provided for @dash_search_button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get dash_search_button;

  /// No description provided for @dash_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by district, city, or keywords (e.g. apartment in Hadda)...'**
  String get dash_search_hint;

  /// No description provided for @dash_search_in_gov_prefix.
  ///
  /// In en, this message translates to:
  /// **'Search in'**
  String get dash_search_in_gov_prefix;

  /// No description provided for @dash_search_in_gov_suffix.
  ///
  /// In en, this message translates to:
  /// **'(e.g. Hadda district, apartment)...'**
  String get dash_search_in_gov_suffix;

  /// No description provided for @dash_select_governorate_title.
  ///
  /// In en, this message translates to:
  /// **'Choose a Yemeni governorate to view properties'**
  String get dash_select_governorate_title;

  /// No description provided for @dash_show_all_gov_properties.
  ///
  /// In en, this message translates to:
  /// **'View all properties in'**
  String get dash_show_all_gov_properties;

  /// No description provided for @dash_trusted_platform.
  ///
  /// In en, this message translates to:
  /// **'Yemen\'s trusted real estate platform'**
  String get dash_trusted_platform;

  /// No description provided for @dash_view_all.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get dash_view_all;

  /// No description provided for @dash_view_map.
  ///
  /// In en, this message translates to:
  /// **'View map'**
  String get dash_view_map;

  /// No description provided for @dash_yemen_map.
  ///
  /// In en, this message translates to:
  /// **'Yemen Map'**
  String get dash_yemen_map;

  /// No description provided for @fav_empty_action.
  ///
  /// In en, this message translates to:
  /// **'Browse properties now'**
  String get fav_empty_action;

  /// No description provided for @fav_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'You can add any property to your list by tapping the heart icon on its card'**
  String get fav_empty_desc;

  /// No description provided for @fav_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No properties in favorites'**
  String get fav_empty_title;

  /// No description provided for @fav_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading favorites list...'**
  String get fav_loading;

  /// No description provided for @fav_login_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get fav_login_required;

  /// No description provided for @fav_signup_or_login.
  ///
  /// In en, this message translates to:
  /// **'Sign Up or Log In'**
  String get fav_signup_or_login;

  /// No description provided for @fav_signup_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get fav_signup_prompt;

  /// No description provided for @fav_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Properties you saved for quick access and comparison.'**
  String get fav_subtitle;

  /// No description provided for @fav_title.
  ///
  /// In en, this message translates to:
  /// **'Favorite Properties'**
  String get fav_title;

  /// No description provided for @myprops_add_new.
  ///
  /// In en, this message translates to:
  /// **'Add New Property'**
  String get myprops_add_new;

  /// No description provided for @myprops_add_property.
  ///
  /// In en, this message translates to:
  /// **'Add a Property'**
  String get myprops_add_property;

  /// No description provided for @myprops_added_on.
  ///
  /// In en, this message translates to:
  /// **'Added on:'**
  String get myprops_added_on;

  /// No description provided for @myprops_archive.
  ///
  /// In en, this message translates to:
  /// **'Archive listing'**
  String get myprops_archive;

  /// No description provided for @myprops_contract.
  ///
  /// In en, this message translates to:
  /// **'Generate and print contract'**
  String get myprops_contract;

  /// No description provided for @myprops_delete_permanent.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get myprops_delete_permanent;

  /// No description provided for @myprops_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit listing'**
  String get myprops_edit;

  /// No description provided for @myprops_empty_action.
  ///
  /// In en, this message translates to:
  /// **'Add your first property'**
  String get myprops_empty_action;

  /// No description provided for @myprops_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Post your first property now for free and start receiving inquiries directly'**
  String get myprops_empty_desc;

  /// No description provided for @myprops_empty_title.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t listed any property yet'**
  String get myprops_empty_title;

  /// No description provided for @myprops_hide.
  ///
  /// In en, this message translates to:
  /// **'Hide listing'**
  String get myprops_hide;

  /// No description provided for @myprops_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your properties...'**
  String get myprops_loading;

  /// No description provided for @myprops_login_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get myprops_login_required;

  /// No description provided for @myprops_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get myprops_preview;

  /// No description provided for @myprops_republish.
  ///
  /// In en, this message translates to:
  /// **'Republish'**
  String get myprops_republish;

  /// No description provided for @myprops_signup_or_login.
  ///
  /// In en, this message translates to:
  /// **'Sign Up or Log In'**
  String get myprops_signup_or_login;

  /// No description provided for @myprops_signup_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get myprops_signup_prompt;

  /// No description provided for @myprops_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your properties, track views, and update their status.'**
  String get myprops_subtitle;

  /// No description provided for @myprops_title.
  ///
  /// In en, this message translates to:
  /// **'My Listed Properties'**
  String get myprops_title;

  /// No description provided for @myprops_view.
  ///
  /// In en, this message translates to:
  /// **'View listing'**
  String get myprops_view;

  /// No description provided for @myprops_views.
  ///
  /// In en, this message translates to:
  /// **'Views:'**
  String get myprops_views;

  /// No description provided for @myprops_yemen_map.
  ///
  /// In en, this message translates to:
  /// **'Yemen Map'**
  String get myprops_yemen_map;

  /// No description provided for @prof_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get prof_admin;

  /// No description provided for @prof_admin_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage properties, users, commissions, and reports'**
  String get prof_admin_subtitle;

  /// No description provided for @prof_admin_title.
  ///
  /// In en, this message translates to:
  /// **'Admin & Control Panel'**
  String get prof_admin_title;

  /// No description provided for @prof_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get prof_cancel;

  /// No description provided for @prof_edit_account.
  ///
  /// In en, this message translates to:
  /// **'Edit Account Details'**
  String get prof_edit_account;

  /// No description provided for @prof_favorites_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Quick access to properties you saved earlier'**
  String get prof_favorites_subtitle;

  /// No description provided for @prof_favorites_title.
  ///
  /// In en, this message translates to:
  /// **'Favorite Properties List'**
  String get prof_favorites_title;

  /// No description provided for @prof_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get prof_full_name;

  /// No description provided for @prof_full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get prof_full_name_hint;

  /// No description provided for @prof_full_name_required.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get prof_full_name_required;

  /// No description provided for @prof_login_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get prof_login_required;

  /// No description provided for @prof_manage_activities.
  ///
  /// In en, this message translates to:
  /// **'Manage My Real Estate Activity'**
  String get prof_manage_activities;

  /// No description provided for @prof_member_since.
  ///
  /// In en, this message translates to:
  /// **'Member since:'**
  String get prof_member_since;

  /// No description provided for @prof_my_listings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Review published listings and drafts, edit or hide them'**
  String get prof_my_listings_subtitle;

  /// No description provided for @prof_my_listings_title.
  ///
  /// In en, this message translates to:
  /// **'My Listed Properties'**
  String get prof_my_listings_title;

  /// No description provided for @prof_my_requests_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track the status and details of rental requests sent to owners'**
  String get prof_my_requests_subtitle;

  /// No description provided for @prof_my_requests_title.
  ///
  /// In en, this message translates to:
  /// **'Submitted Rental Requests'**
  String get prof_my_requests_title;

  /// No description provided for @prof_no_phone.
  ///
  /// In en, this message translates to:
  /// **'No phone number set'**
  String get prof_no_phone;

  /// No description provided for @prof_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone Number *'**
  String get prof_phone_required;

  /// No description provided for @prof_save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get prof_save_changes;

  /// No description provided for @prof_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get prof_sign_out;

  /// No description provided for @prof_signup_or_login.
  ///
  /// In en, this message translates to:
  /// **'Sign Up or Log In'**
  String get prof_signup_or_login;

  /// No description provided for @prof_signup_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get prof_signup_prompt;

  /// No description provided for @prof_super_admin.
  ///
  /// In en, this message translates to:
  /// **'Super Admin'**
  String get prof_super_admin;

  /// No description provided for @prof_update_failure.
  ///
  /// In en, this message translates to:
  /// **'Could not update data'**
  String get prof_update_failure;

  /// No description provided for @prof_update_success.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get prof_update_success;

  /// No description provided for @req_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get req_close;

  /// No description provided for @req_desired_start_date.
  ///
  /// In en, this message translates to:
  /// **'Desired Move-in Date (optional)'**
  String get req_desired_start_date;

  /// No description provided for @req_empty_action.
  ///
  /// In en, this message translates to:
  /// **'Browse rental properties'**
  String get req_empty_action;

  /// No description provided for @req_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Browse available rentals and send a preliminary rental request'**
  String get req_empty_desc;

  /// No description provided for @req_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No previous rental requests'**
  String get req_empty_title;

  /// No description provided for @req_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'An error occurred:'**
  String get req_error_prefix;

  /// No description provided for @req_follow_my_requests.
  ///
  /// In en, this message translates to:
  /// **'Track My Requests'**
  String get req_follow_my_requests;

  /// No description provided for @req_form_title.
  ///
  /// In en, this message translates to:
  /// **'Request to Rent a Property'**
  String get req_form_title;

  /// No description provided for @req_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get req_full_name;

  /// No description provided for @req_full_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get req_full_name_hint;

  /// No description provided for @req_full_name_required.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get req_full_name_required;

  /// No description provided for @req_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading your requests...'**
  String get req_loading;

  /// No description provided for @req_login_required.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get req_login_required;

  /// No description provided for @req_not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get req_not_specified;

  /// No description provided for @req_notes_hint.
  ///
  /// In en, this message translates to:
  /// **'Mention any questions, preferred rental term, or family size...'**
  String get req_notes_hint;

  /// No description provided for @req_notes_label.
  ///
  /// In en, this message translates to:
  /// **'Additional notes or special requests'**
  String get req_notes_label;

  /// No description provided for @req_owner_admin_reply.
  ///
  /// In en, this message translates to:
  /// **'Owner/Admin reply:'**
  String get req_owner_admin_reply;

  /// No description provided for @req_phone_example_prefix.
  ///
  /// In en, this message translates to:
  /// **'Example:'**
  String get req_phone_example_prefix;

  /// No description provided for @req_phone_required.
  ///
  /// In en, this message translates to:
  /// **'Contact Phone Number *'**
  String get req_phone_required;

  /// No description provided for @req_pick_date_hint.
  ///
  /// In en, this message translates to:
  /// **'Pick the expected move-in date'**
  String get req_pick_date_hint;

  /// No description provided for @req_property_fallback.
  ///
  /// In en, this message translates to:
  /// **'Property for rent'**
  String get req_property_fallback;

  /// No description provided for @req_reference_number.
  ///
  /// In en, this message translates to:
  /// **'Request reference number:'**
  String get req_reference_number;

  /// No description provided for @req_requested_start.
  ///
  /// In en, this message translates to:
  /// **'Requested start date:'**
  String get req_requested_start;

  /// No description provided for @req_sent_on.
  ///
  /// In en, this message translates to:
  /// **'Sent on:'**
  String get req_sent_on;

  /// No description provided for @req_signup_or_login.
  ///
  /// In en, this message translates to:
  /// **'Sign Up or Log In'**
  String get req_signup_or_login;

  /// No description provided for @req_signup_prompt.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get req_signup_prompt;

  /// No description provided for @req_submit.
  ///
  /// In en, this message translates to:
  /// **'Send Rental Request Now'**
  String get req_submit;

  /// No description provided for @req_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track the status of your requests and inquiries for rental properties.'**
  String get req_subtitle;

  /// No description provided for @req_success.
  ///
  /// In en, this message translates to:
  /// **'Rental request received successfully'**
  String get req_success;

  /// No description provided for @req_success_note.
  ///
  /// In en, this message translates to:
  /// **'Note: This request is only an inquiry and a preliminary rental interest; it is not a formal contract or a final booking.'**
  String get req_success_note;

  /// No description provided for @req_title.
  ///
  /// In en, this message translates to:
  /// **'My Rental Requests'**
  String get req_title;

  /// No description provided for @req_view_property.
  ///
  /// In en, this message translates to:
  /// **'View Property'**
  String get req_view_property;

  /// No description provided for @req_your_notes.
  ///
  /// In en, this message translates to:
  /// **'Your notes:'**
  String get req_your_notes;

  /// No description provided for @set_add_property_style.
  ///
  /// In en, this message translates to:
  /// **'Add Property button'**
  String get set_add_property_style;

  /// No description provided for @set_asset_count_positive_only.
  ///
  /// In en, this message translates to:
  /// **'Only show count when there are properties'**
  String get set_asset_count_positive_only;

  /// No description provided for @set_asset_count_visibility.
  ///
  /// In en, this message translates to:
  /// **'Property count'**
  String get set_asset_count_visibility;

  /// No description provided for @set_current_location.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get set_current_location;

  /// No description provided for @set_default_ibb.
  ///
  /// In en, this message translates to:
  /// **'Ibb (default)'**
  String get set_default_ibb;

  /// No description provided for @set_display.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get set_display;

  /// No description provided for @set_location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get set_location;

  /// No description provided for @set_reset_location.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get set_reset_location;

  /// No description provided for @set_retry_location.
  ///
  /// In en, this message translates to:
  /// **'Retry permission'**
  String get set_retry_location;

  /// No description provided for @set_search_radius.
  ///
  /// In en, this message translates to:
  /// **'Search radius'**
  String get set_search_radius;

  /// No description provided for @set_search_radius_hint.
  ///
  /// In en, this message translates to:
  /// **'Controls which listings appear in Home → Properties near you.'**
  String get set_search_radius_hint;

  /// No description provided for @set_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get set_currency;

  /// No description provided for @set_currency_yer.
  ///
  /// In en, this message translates to:
  /// **'Yemeni Rial (ر.ي)'**
  String get set_currency_yer;

  /// No description provided for @set_currency_sar.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal (ر.س)'**
  String get set_currency_sar;

  /// No description provided for @set_currency_usd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (\$)'**
  String get set_currency_usd;

  /// No description provided for @set_distance_unit.
  ///
  /// In en, this message translates to:
  /// **'Distance unit'**
  String get set_distance_unit;

  /// No description provided for @set_distance_unit_km.
  ///
  /// In en, this message translates to:
  /// **'Kilometers (km)'**
  String get set_distance_unit_km;

  /// No description provided for @set_distance_unit_miles.
  ///
  /// In en, this message translates to:
  /// **'Miles (mi)'**
  String get set_distance_unit_miles;

  /// No description provided for @set_text_size.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get set_text_size;

  /// No description provided for @set_text_size_small.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get set_text_size_small;

  /// No description provided for @set_text_size_medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get set_text_size_medium;

  /// No description provided for @set_text_size_large.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get set_text_size_large;

  /// No description provided for @set_default_map_view.
  ///
  /// In en, this message translates to:
  /// **'Default map view'**
  String get set_default_map_view;

  /// No description provided for @set_default_map_view_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get set_default_map_view_map;

  /// No description provided for @set_default_map_view_list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get set_default_map_view_list;

  /// No description provided for @map_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get map_all;

  /// No description provided for @map_all_deals.
  ///
  /// In en, this message translates to:
  /// **'All (sale and rent)'**
  String get map_all_deals;

  /// No description provided for @map_all_deals_short.
  ///
  /// In en, this message translates to:
  /// **'All (sale/rent)'**
  String get map_all_deals_short;

  /// No description provided for @map_all_districts_in.
  ///
  /// In en, this message translates to:
  /// **'All districts in'**
  String get map_all_districts_in;

  /// No description provided for @map_all_governorates.
  ///
  /// In en, this message translates to:
  /// **'All governorates 🇾🇪'**
  String get map_all_governorates;

  /// No description provided for @map_all_governorates_plain.
  ///
  /// In en, this message translates to:
  /// **'All governorates'**
  String get map_all_governorates_plain;

  /// No description provided for @map_all_property_types.
  ///
  /// In en, this message translates to:
  /// **'All property types'**
  String get map_all_property_types;

  /// No description provided for @map_all_types.
  ///
  /// In en, this message translates to:
  /// **'All types'**
  String get map_all_types;

  /// No description provided for @map_apply_filter.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get map_apply_filter;

  /// No description provided for @map_apply_filters.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get map_apply_filters;

  /// No description provided for @map_approximate_location_prefix.
  ///
  /// In en, this message translates to:
  /// **'Approximate location based on the center of'**
  String get map_approximate_location_prefix;

  /// No description provided for @map_area_label.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get map_area_label;

  /// No description provided for @map_area_sqm.
  ///
  /// In en, this message translates to:
  /// **'m² area'**
  String get map_area_sqm;

  /// No description provided for @map_back_home.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get map_back_home;

  /// No description provided for @map_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'bedrooms'**
  String get map_bedrooms;

  /// No description provided for @map_call.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get map_call;

  /// No description provided for @map_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get map_cancel;

  /// No description provided for @map_cancel_draw.
  ///
  /// In en, this message translates to:
  /// **'Cancel drawing'**
  String get map_cancel_draw;

  /// No description provided for @map_check_availability.
  ///
  /// In en, this message translates to:
  /// **'Check availability'**
  String get map_check_availability;

  /// No description provided for @map_clear_draw.
  ///
  /// In en, this message translates to:
  /// **'Clear drawing'**
  String get map_clear_draw;

  /// No description provided for @map_clear_search.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get map_clear_search;

  /// No description provided for @map_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get map_close;

  /// No description provided for @map_cluster_properties_title.
  ///
  /// In en, this message translates to:
  /// **'Properties at this location'**
  String get map_cluster_properties_title;

  /// No description provided for @map_cluster_property_unit.
  ///
  /// In en, this message translates to:
  /// **'properties'**
  String get map_cluster_property_unit;

  /// No description provided for @map_currency_sar.
  ///
  /// In en, this message translates to:
  /// **'SAR'**
  String get map_currency_sar;

  /// No description provided for @map_currency_yer.
  ///
  /// In en, this message translates to:
  /// **'YER'**
  String get map_currency_yer;

  /// No description provided for @map_deal_type.
  ///
  /// In en, this message translates to:
  /// **'Deal type'**
  String get map_deal_type;

  /// No description provided for @map_deal_type_search.
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get map_deal_type_search;

  /// No description provided for @map_directions.
  ///
  /// In en, this message translates to:
  /// **'Directions to the property'**
  String get map_directions;

  /// No description provided for @map_directions_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Directions to the property via Google Maps'**
  String get map_directions_google_maps;

  /// No description provided for @map_district_in.
  ///
  /// In en, this message translates to:
  /// **'District in'**
  String get map_district_in;

  /// No description provided for @map_draw_area.
  ///
  /// In en, this message translates to:
  /// **'Draw area'**
  String get map_draw_area;

  /// No description provided for @map_draw_filter_active.
  ///
  /// In en, this message translates to:
  /// **'Search limited to drawn area'**
  String get map_draw_filter_active;

  /// No description provided for @map_draw_instruction.
  ///
  /// In en, this message translates to:
  /// **'Touch and drag on the map to draw the area you\'re looking for'**
  String get map_draw_instruction;

  /// No description provided for @map_draw_search_area.
  ///
  /// In en, this message translates to:
  /// **'Draw search area'**
  String get map_draw_search_area;

  /// No description provided for @map_exact_gps_only.
  ///
  /// In en, this message translates to:
  /// **'Exact GPS coordinates only'**
  String get map_exact_gps_only;

  /// No description provided for @map_exact_location.
  ///
  /// In en, this message translates to:
  /// **'Exact location pinned on the map'**
  String get map_exact_location;

  /// No description provided for @map_filter_hint.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the filters or using less specific keywords'**
  String get map_filter_hint;

  /// No description provided for @map_filter_results.
  ///
  /// In en, this message translates to:
  /// **'Filter results'**
  String get map_filter_results;

  /// No description provided for @map_filter_title.
  ///
  /// In en, this message translates to:
  /// **'Filter properties on the map'**
  String get map_filter_title;

  /// No description provided for @map_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get map_filters;

  /// No description provided for @map_filters_active.
  ///
  /// In en, this message translates to:
  /// **'Filters ✓'**
  String get map_filters_active;

  /// No description provided for @map_final_purchase_price.
  ///
  /// In en, this message translates to:
  /// **'Official final purchase price'**
  String get map_final_purchase_price;

  /// No description provided for @map_for_rent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get map_for_rent;

  /// No description provided for @map_for_sale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get map_for_sale;

  /// No description provided for @map_governorate.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get map_governorate;

  /// No description provided for @map_governorate_search.
  ///
  /// In en, this message translates to:
  /// **'Governorate'**
  String get map_governorate_search;

  /// No description provided for @map_hide_approximate.
  ///
  /// In en, this message translates to:
  /// **'Hide properties with approximate locations'**
  String get map_hide_approximate;

  /// No description provided for @map_load_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the map. You can use the alternative view.'**
  String get map_load_error;

  /// No description provided for @map_loading_map.
  ///
  /// In en, this message translates to:
  /// **'Loading map...'**
  String get map_loading_map;

  /// No description provided for @map_loading_search.
  ///
  /// In en, this message translates to:
  /// **'Searching the database...'**
  String get map_loading_search;

  /// No description provided for @map_location_missing_message.
  ///
  /// In en, this message translates to:
  /// **'This property isn\'t pinned on the map yet. Please contact the owner to confirm its location.'**
  String get map_location_missing_message;

  /// No description provided for @map_main_menu.
  ///
  /// In en, this message translates to:
  /// **'Main menu'**
  String get map_main_menu;

  /// No description provided for @map_maps_open_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open Google Maps. Make sure the app is installed or that you\'re online.'**
  String get map_maps_open_error;

  /// No description provided for @map_max_price.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get map_max_price;

  /// No description provided for @map_million_abbr.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get map_million_abbr;

  /// No description provided for @map_min_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Minimum bedrooms'**
  String get map_min_bedrooms;

  /// No description provided for @map_min_price.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get map_min_price;

  /// No description provided for @map_no_map_properties.
  ///
  /// In en, this message translates to:
  /// **'No properties to show on the map'**
  String get map_no_map_properties;

  /// No description provided for @map_no_matching_properties.
  ///
  /// In en, this message translates to:
  /// **'No matching properties found'**
  String get map_no_matching_properties;

  /// No description provided for @map_no_max.
  ///
  /// In en, this message translates to:
  /// **'No limit'**
  String get map_no_max;

  /// No description provided for @map_no_properties_area_hint.
  ///
  /// In en, this message translates to:
  /// **'Try changing the search area or clearing the filters to see properties in other Yemeni governorates.'**
  String get map_no_properties_area_hint;

  /// No description provided for @map_no_properties_in_area.
  ///
  /// In en, this message translates to:
  /// **'No matching properties in this area'**
  String get map_no_properties_in_area;

  /// No description provided for @map_offline_atlas_hint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or use the mouse to zoom in and out'**
  String get map_offline_atlas_hint;

  /// No description provided for @map_offline_atlas_title.
  ///
  /// In en, this message translates to:
  /// **'Official Map of the Republic of Yemen (Offline)'**
  String get map_offline_atlas_title;

  /// No description provided for @map_one_bedroom.
  ///
  /// In en, this message translates to:
  /// **'One bedroom'**
  String get map_one_bedroom;

  /// No description provided for @map_or_more.
  ///
  /// In en, this message translates to:
  /// **'or more'**
  String get map_or_more;

  /// No description provided for @map_per_month.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get map_per_month;

  /// No description provided for @map_price_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get map_price_from;

  /// No description provided for @map_price_range.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get map_price_range;

  /// No description provided for @map_price_range_search.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get map_price_range_search;

  /// No description provided for @map_price_to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get map_price_to;

  /// No description provided for @map_properties_available.
  ///
  /// In en, this message translates to:
  /// **'properties available'**
  String get map_properties_available;

  /// No description provided for @map_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get map_property_type;

  /// No description provided for @map_property_type_search.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get map_property_type_search;

  /// No description provided for @map_rent_discount.
  ///
  /// In en, this message translates to:
  /// **'Special rent discount'**
  String get map_rent_discount;

  /// No description provided for @map_rent_only.
  ///
  /// In en, this message translates to:
  /// **'Rent only'**
  String get map_rent_only;

  /// No description provided for @map_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get map_reset;

  /// No description provided for @map_reset_filters.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get map_reset_filters;

  /// No description provided for @map_reset_filters_action.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get map_reset_filters_action;

  /// No description provided for @map_result_property_unit.
  ///
  /// In en, this message translates to:
  /// **'properties'**
  String get map_result_property_unit;

  /// No description provided for @map_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get map_retry;

  /// No description provided for @map_sale_discount.
  ///
  /// In en, this message translates to:
  /// **'Special sale discount'**
  String get map_sale_discount;

  /// No description provided for @map_sale_only.
  ///
  /// In en, this message translates to:
  /// **'Sale only'**
  String get map_sale_only;

  /// No description provided for @map_search_button.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get map_search_button;

  /// No description provided for @map_search_found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get map_search_found;

  /// No description provided for @map_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search by governorate, neighborhood, or property name...'**
  String get map_search_hint;

  /// No description provided for @map_search_hint_main.
  ///
  /// In en, this message translates to:
  /// **'Search by address, neighborhood, or keywords...'**
  String get map_search_hint_main;

  /// No description provided for @map_search_list_view.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get map_search_list_view;

  /// No description provided for @map_search_map_view.
  ///
  /// In en, this message translates to:
  /// **'Property map'**
  String get map_search_map_view;

  /// No description provided for @map_search_property_unit.
  ///
  /// In en, this message translates to:
  /// **'properties'**
  String get map_search_property_unit;

  /// No description provided for @map_search_results.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get map_search_results;

  /// No description provided for @map_search_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get map_search_settings;

  /// No description provided for @map_search_this_area.
  ///
  /// In en, this message translates to:
  /// **'Search this area'**
  String get map_search_this_area;

  /// No description provided for @map_show_all_governorates.
  ///
  /// In en, this message translates to:
  /// **'Show all Yemeni governorates'**
  String get map_show_all_governorates;

  /// No description provided for @map_show_list.
  ///
  /// In en, this message translates to:
  /// **'Show list'**
  String get map_show_list;

  /// No description provided for @map_show_map.
  ///
  /// In en, this message translates to:
  /// **'Show map'**
  String get map_show_map;

  /// No description provided for @map_sort_by.
  ///
  /// In en, this message translates to:
  /// **'Sort by: '**
  String get map_sort_by;

  /// No description provided for @map_sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get map_sort_newest;

  /// No description provided for @map_sort_price_asc.
  ///
  /// In en, this message translates to:
  /// **'Price: lowest first'**
  String get map_sort_price_asc;

  /// No description provided for @map_sort_price_desc.
  ///
  /// In en, this message translates to:
  /// **'Price: highest first'**
  String get map_sort_price_desc;

  /// No description provided for @map_switch_to_satellite.
  ///
  /// In en, this message translates to:
  /// **'Switch to satellite view'**
  String get map_switch_to_satellite;

  /// No description provided for @map_switch_to_streets.
  ///
  /// In en, this message translates to:
  /// **'Switch to street map'**
  String get map_switch_to_streets;

  /// No description provided for @map_thousand_abbr.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get map_thousand_abbr;

  /// No description provided for @map_total_monthly_price.
  ///
  /// In en, this message translates to:
  /// **'Total monthly price'**
  String get map_total_monthly_price;

  /// No description provided for @map_two_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Two bedrooms'**
  String get map_two_bedrooms;

  /// No description provided for @map_type_apartment.
  ///
  /// In en, this message translates to:
  /// **'Apartments'**
  String get map_type_apartment;

  /// No description provided for @map_type_building.
  ///
  /// In en, this message translates to:
  /// **'Buildings'**
  String get map_type_building;

  /// No description provided for @map_type_land.
  ///
  /// In en, this message translates to:
  /// **'Land'**
  String get map_type_land;

  /// No description provided for @map_type_office.
  ///
  /// In en, this message translates to:
  /// **'Offices'**
  String get map_type_office;

  /// No description provided for @map_type_shop.
  ///
  /// In en, this message translates to:
  /// **'Shops'**
  String get map_type_shop;

  /// No description provided for @map_type_villa.
  ///
  /// In en, this message translates to:
  /// **'Villas & houses'**
  String get map_type_villa;

  /// No description provided for @map_view_details.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get map_view_details;

  /// No description provided for @map_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get map_whatsapp;

  /// No description provided for @map_whatsapp_prefix.
  ///
  /// In en, this message translates to:
  /// **'Assalamu alaikum, regarding the property listed on the Yemen Real Estate Portal'**
  String get map_whatsapp_prefix;

  /// No description provided for @map_yemen_atlas.
  ///
  /// In en, this message translates to:
  /// **'Map of Yemen 🇾🇪'**
  String get map_yemen_atlas;

  /// No description provided for @addprop_verified_login_required.
  ///
  /// In en, this message translates to:
  /// **'You must sign in with an email-verified account to publish properties.'**
  String get addprop_verified_login_required;

  /// No description provided for @addprop_ownership_pledge_required.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the ownership pledge to continue.'**
  String get addprop_ownership_pledge_required;

  /// No description provided for @addprop_self_review_title.
  ///
  /// In en, this message translates to:
  /// **'Self-review of the listing'**
  String get addprop_self_review_title;

  /// No description provided for @addprop_review_intro.
  ///
  /// In en, this message translates to:
  /// **'Please review your listing details carefully before publishing:'**
  String get addprop_review_intro;

  /// No description provided for @addprop_review_title_label.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addprop_review_title_label;

  /// No description provided for @addprop_review_deal_type_label.
  ///
  /// In en, this message translates to:
  /// **'Deal type'**
  String get addprop_review_deal_type_label;

  /// No description provided for @addprop_review_price_label.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addprop_review_price_label;

  /// No description provided for @addprop_review_area_label.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get addprop_review_area_label;

  /// No description provided for @addprop_review_location_label.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get addprop_review_location_label;

  /// No description provided for @addprop_review_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Advertiser phone'**
  String get addprop_review_phone_label;

  /// No description provided for @addprop_review_status_label.
  ///
  /// In en, this message translates to:
  /// **'Publishing status'**
  String get addprop_review_status_label;

  /// No description provided for @addprop_status_private_draft.
  ///
  /// In en, this message translates to:
  /// **'Private draft'**
  String get addprop_status_private_draft;

  /// No description provided for @addprop_status_instant_publish.
  ///
  /// In en, this message translates to:
  /// **'Instant publish (admin account)'**
  String get addprop_status_instant_publish;

  /// No description provided for @addprop_status_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Publish request under review'**
  String get addprop_status_pending_review;

  /// No description provided for @addprop_admin_publish_note.
  ///
  /// In en, this message translates to:
  /// **'As the general administrator, this property will be published directly on the platform.'**
  String get addprop_admin_publish_note;

  /// No description provided for @addprop_review_policy_note.
  ///
  /// In en, this message translates to:
  /// **'Under the approved publishing policy, your listing is sent to management (General Manager: Mohammed Al-Saqqaf) for review and approval before it appears publicly.'**
  String get addprop_review_policy_note;

  /// No description provided for @addprop_edit_data.
  ///
  /// In en, this message translates to:
  /// **'Edit details'**
  String get addprop_edit_data;

  /// No description provided for @addprop_save_draft.
  ///
  /// In en, this message translates to:
  /// **'Save as draft'**
  String get addprop_save_draft;

  /// No description provided for @addprop_confirm_publish.
  ///
  /// In en, this message translates to:
  /// **'Confirm and publish listing'**
  String get addprop_confirm_publish;

  /// No description provided for @addprop_submit_request.
  ///
  /// In en, this message translates to:
  /// **'Submit publish request'**
  String get addprop_submit_request;

  /// No description provided for @addprop_confirm_email_required.
  ///
  /// In en, this message translates to:
  /// **'You must confirm your email address before publishing the property.'**
  String get addprop_confirm_email_required;

  /// No description provided for @addprop_published_success.
  ///
  /// In en, this message translates to:
  /// **'Listing published successfully on the Yemen Real Estate Portal'**
  String get addprop_published_success;

  /// No description provided for @addprop_request_sent_success.
  ///
  /// In en, this message translates to:
  /// **'Publish request sent successfully; it is under management review for approval.'**
  String get addprop_request_sent_success;

  /// No description provided for @addprop_draft_saved_success.
  ///
  /// In en, this message translates to:
  /// **'Listing draft saved successfully'**
  String get addprop_draft_saved_success;

  /// No description provided for @addprop_save_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving the listing'**
  String get addprop_save_error;

  /// No description provided for @addprop_login_required_title.
  ///
  /// In en, this message translates to:
  /// **'Sign-in required'**
  String get addprop_login_required_title;

  /// No description provided for @addprop_login_required_desc.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get addprop_login_required_desc;

  /// No description provided for @addprop_login_required_action.
  ///
  /// In en, this message translates to:
  /// **'Create an account or sign in'**
  String get addprop_login_required_action;

  /// No description provided for @addprop_new_title.
  ///
  /// In en, this message translates to:
  /// **'Add a new property listing'**
  String get addprop_new_title;

  /// No description provided for @addprop_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit property details'**
  String get addprop_edit_title;

  /// No description provided for @addprop_intro.
  ///
  /// In en, this message translates to:
  /// **'Enter accurate property details to reach interested buyers efficiently.'**
  String get addprop_intro;

  /// No description provided for @addprop_section_basic_info.
  ///
  /// In en, this message translates to:
  /// **'Listing and deal information'**
  String get addprop_section_basic_info;

  /// No description provided for @addprop_title_label.
  ///
  /// In en, this message translates to:
  /// **'Listing title *'**
  String get addprop_title_label;

  /// No description provided for @addprop_title_field_name.
  ///
  /// In en, this message translates to:
  /// **'Listing title'**
  String get addprop_title_field_name;

  /// No description provided for @addprop_title_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Apartment for sale in Hadda with deluxe finishing and a strategic location'**
  String get addprop_title_hint;

  /// No description provided for @addprop_deal_type_label.
  ///
  /// In en, this message translates to:
  /// **'Deal type *'**
  String get addprop_deal_type_label;

  /// No description provided for @addprop_deal_sale.
  ///
  /// In en, this message translates to:
  /// **'For sale'**
  String get addprop_deal_sale;

  /// No description provided for @addprop_deal_rent.
  ///
  /// In en, this message translates to:
  /// **'For rent'**
  String get addprop_deal_rent;

  /// No description provided for @addprop_property_type_label.
  ///
  /// In en, this message translates to:
  /// **'Property type *'**
  String get addprop_property_type_label;

  /// No description provided for @addprop_section_price_area.
  ///
  /// In en, this message translates to:
  /// **'Price and area'**
  String get addprop_section_price_area;

  /// No description provided for @addprop_price_label.
  ///
  /// In en, this message translates to:
  /// **'Asking price *'**
  String get addprop_price_label;

  /// No description provided for @addprop_price_field_name.
  ///
  /// In en, this message translates to:
  /// **'Asking price'**
  String get addprop_price_field_name;

  /// No description provided for @addprop_price_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50000000'**
  String get addprop_price_hint;

  /// No description provided for @addprop_currency_label.
  ///
  /// In en, this message translates to:
  /// **'Currency *'**
  String get addprop_currency_label;

  /// No description provided for @addprop_area_label.
  ///
  /// In en, this message translates to:
  /// **'Total area (m²) *'**
  String get addprop_area_label;

  /// No description provided for @addprop_area_field_name.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get addprop_area_field_name;

  /// No description provided for @addprop_area_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 180'**
  String get addprop_area_hint;

  /// No description provided for @addprop_bedrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Number of rooms'**
  String get addprop_bedrooms_label;

  /// No description provided for @addprop_na_hint.
  ///
  /// In en, this message translates to:
  /// **'0 if not applicable'**
  String get addprop_na_hint;

  /// No description provided for @addprop_bathrooms_label.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get addprop_bathrooms_label;

  /// No description provided for @addprop_section_location.
  ///
  /// In en, this message translates to:
  /// **'Geographic location'**
  String get addprop_section_location;

  /// No description provided for @addprop_governorate_label.
  ///
  /// In en, this message translates to:
  /// **'Governorate *'**
  String get addprop_governorate_label;

  /// No description provided for @addprop_district_label.
  ///
  /// In en, this message translates to:
  /// **'District or neighborhood *'**
  String get addprop_district_label;

  /// No description provided for @addprop_district_field_name.
  ///
  /// In en, this message translates to:
  /// **'Neighborhood or district'**
  String get addprop_district_field_name;

  /// No description provided for @addprop_district_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Hadda, Bayt Bous, Al-Ma\'la...'**
  String get addprop_district_hint;

  /// No description provided for @addprop_common_districts_intro.
  ///
  /// In en, this message translates to:
  /// **'Popular neighborhoods and districts in'**
  String get addprop_common_districts_intro;

  /// No description provided for @addprop_common_districts_quick_pick.
  ///
  /// In en, this message translates to:
  /// **'(tap for quick selection):'**
  String get addprop_common_districts_quick_pick;

  /// No description provided for @addprop_address_details_label.
  ///
  /// In en, this message translates to:
  /// **'Address details and nearby landmarks'**
  String get addprop_address_details_label;

  /// No description provided for @addprop_address_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Near Al-Rawishan roundabout - Street 14'**
  String get addprop_address_hint;

  /// No description provided for @addprop_map_picker_label.
  ///
  /// In en, this message translates to:
  /// **'Pinpoint the location on the map (tap the map to set the place):'**
  String get addprop_map_picker_label;

  /// No description provided for @addprop_location_pinned.
  ///
  /// In en, this message translates to:
  /// **'Location pinned:'**
  String get addprop_location_pinned;

  /// No description provided for @addprop_map_tap_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap any point on the map to set the exact property location'**
  String get addprop_map_tap_hint;

  /// No description provided for @addprop_sqm_unit.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get addprop_sqm_unit;

  /// No description provided for @addprop_section_description_photos.
  ///
  /// In en, this message translates to:
  /// **'Description and photos'**
  String get addprop_section_description_photos;

  /// No description provided for @addprop_description_label.
  ///
  /// In en, this message translates to:
  /// **'Full property description *'**
  String get addprop_description_label;

  /// No description provided for @addprop_description_field_name.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get addprop_description_field_name;

  /// No description provided for @addprop_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Include the property details, features, finishes, entrances, and available services...'**
  String get addprop_description_hint;

  /// No description provided for @addprop_photos_label.
  ///
  /// In en, this message translates to:
  /// **'Property photos (maximum 5 MB per image)'**
  String get addprop_photos_label;

  /// No description provided for @addprop_add_photos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addprop_add_photos;

  /// No description provided for @addprop_no_images_hint.
  ///
  /// In en, this message translates to:
  /// **'No photos selected yet. You can add photos to attract more buyers.'**
  String get addprop_no_images_hint;

  /// No description provided for @addprop_section_contact_pledge.
  ///
  /// In en, this message translates to:
  /// **'Contact details and pledge'**
  String get addprop_section_contact_pledge;

  /// No description provided for @addprop_phone_label.
  ///
  /// In en, this message translates to:
  /// **'Contact phone number *'**
  String get addprop_phone_label;

  /// No description provided for @addprop_whatsapp_label.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp number'**
  String get addprop_whatsapp_label;

  /// No description provided for @addprop_whatsapp_hint.
  ///
  /// In en, this message translates to:
  /// **'Optional for quick contact'**
  String get addprop_whatsapp_hint;

  /// No description provided for @addprop_pledge_text.
  ///
  /// In en, this message translates to:
  /// **'I affirm and pledge that all data and information in this listing is accurate, and that I hold the legal and lawful right to market or publish it.'**
  String get addprop_pledge_text;

  /// No description provided for @addprop_section_contract.
  ///
  /// In en, this message translates to:
  /// **'Customize and print the Yemen property contract'**
  String get addprop_section_contract;

  /// No description provided for @addprop_contract_intro.
  ///
  /// In en, this message translates to:
  /// **'You can customize the contract terms and save your approved template to print and notarize when the deal is completed with the tenant or buyer.'**
  String get addprop_contract_intro;

  /// No description provided for @addprop_customize_contract.
  ///
  /// In en, this message translates to:
  /// **'Customize contract clauses and print'**
  String get addprop_customize_contract;

  /// No description provided for @addprop_preview_publish.
  ///
  /// In en, this message translates to:
  /// **'Preview and publish listing'**
  String get addprop_preview_publish;

  /// No description provided for @detail_reason_inaccurate.
  ///
  /// In en, this message translates to:
  /// **'Inaccurate or misleading information'**
  String get detail_reason_inaccurate;

  /// No description provided for @detail_reason_price.
  ///
  /// In en, this message translates to:
  /// **'Price does not match the market'**
  String get detail_reason_price;

  /// No description provided for @detail_reason_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate property or already sold'**
  String get detail_reason_duplicate;

  /// No description provided for @detail_reason_images.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate or mismatched photos'**
  String get detail_reason_images;

  /// No description provided for @detail_reason_fraud.
  ///
  /// In en, this message translates to:
  /// **'Impersonation or fraud'**
  String get detail_reason_fraud;

  /// No description provided for @detail_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get detail_reason_other;

  /// No description provided for @detail_report_title.
  ///
  /// In en, this message translates to:
  /// **'Report a violating listing'**
  String get detail_report_title;

  /// No description provided for @detail_report_intro.
  ///
  /// In en, this message translates to:
  /// **'Help us keep the platform trustworthy by reporting any violation.'**
  String get detail_report_intro;

  /// No description provided for @detail_report_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Report reason *'**
  String get detail_report_reason_label;

  /// No description provided for @detail_report_details_label.
  ///
  /// In en, this message translates to:
  /// **'Additional details (optional)'**
  String get detail_report_details_label;

  /// No description provided for @detail_report_details_hint.
  ///
  /// In en, this message translates to:
  /// **'Describe the reason in detail...'**
  String get detail_report_details_hint;

  /// No description provided for @detail_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get detail_cancel;

  /// No description provided for @detail_report_submitted.
  ///
  /// In en, this message translates to:
  /// **'Your report was received successfully and will be reviewed by the management team.'**
  String get detail_report_submitted;

  /// No description provided for @detail_submit_report.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get detail_submit_report;

  /// No description provided for @detail_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading property details...'**
  String get detail_loading;

  /// No description provided for @detail_browse_properties.
  ///
  /// In en, this message translates to:
  /// **'Browse available properties'**
  String get detail_browse_properties;

  /// No description provided for @detail_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get detail_home;

  /// No description provided for @detail_properties.
  ///
  /// In en, this message translates to:
  /// **'Properties'**
  String get detail_properties;

  /// No description provided for @detail_auth_prompt_message.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get detail_auth_prompt_message;

  /// No description provided for @detail_view_image.
  ///
  /// In en, this message translates to:
  /// **'View image'**
  String get detail_view_image;

  /// No description provided for @detail_publish_date.
  ///
  /// In en, this message translates to:
  /// **'Published on:'**
  String get detail_publish_date;

  /// No description provided for @detail_send_rental_request.
  ///
  /// In en, this message translates to:
  /// **'Send rental request'**
  String get detail_send_rental_request;

  /// No description provided for @detail_contract_preview.
  ///
  /// In en, this message translates to:
  /// **'Preview, customize and print the contract'**
  String get detail_contract_preview;

  /// No description provided for @detail_report_action.
  ///
  /// In en, this message translates to:
  /// **'Report a violation'**
  String get detail_report_action;

  /// No description provided for @detail_link_copied.
  ///
  /// In en, this message translates to:
  /// **'Property link copied for sharing'**
  String get detail_link_copied;

  /// No description provided for @detail_share_ad.
  ///
  /// In en, this message translates to:
  /// **'Share listing'**
  String get detail_share_ad;

  /// No description provided for @detail_total_area.
  ///
  /// In en, this message translates to:
  /// **'Total area'**
  String get detail_total_area;

  /// No description provided for @detail_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get detail_property_type;

  /// No description provided for @detail_bedrooms.
  ///
  /// In en, this message translates to:
  /// **'Number of bedrooms'**
  String get detail_bedrooms;

  /// No description provided for @detail_rooms_unit.
  ///
  /// In en, this message translates to:
  /// **'rooms'**
  String get detail_rooms_unit;

  /// No description provided for @detail_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'Bathrooms'**
  String get detail_bathrooms;

  /// No description provided for @detail_bathrooms_unit.
  ///
  /// In en, this message translates to:
  /// **'bathrooms'**
  String get detail_bathrooms_unit;

  /// No description provided for @detail_views_unit.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get detail_views_unit;

  /// No description provided for @detail_publishing_method.
  ///
  /// In en, this message translates to:
  /// **'Publishing method'**
  String get detail_publishing_method;

  /// No description provided for @detail_self_review_published.
  ///
  /// In en, this message translates to:
  /// **'Self-declared review'**
  String get detail_self_review_published;

  /// No description provided for @detail_description_title.
  ///
  /// In en, this message translates to:
  /// **'Property details and description'**
  String get detail_description_title;

  /// No description provided for @detail_map_section_title.
  ///
  /// In en, this message translates to:
  /// **'Property location on the map'**
  String get detail_map_section_title;

  /// No description provided for @detail_open_full_map.
  ///
  /// In en, this message translates to:
  /// **'Open the full interactive map'**
  String get detail_open_full_map;

  /// No description provided for @detail_directions_google_maps.
  ///
  /// In en, this message translates to:
  /// **'Directions (Google Maps)'**
  String get detail_directions_google_maps;

  /// No description provided for @detail_views_label.
  ///
  /// In en, this message translates to:
  /// **'View count'**
  String get detail_views_label;

  /// No description provided for @map_load_more.
  ///
  /// In en, this message translates to:
  /// **'Load more properties'**
  String get map_load_more;

  /// No description provided for @sh_header_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get sh_header_settings;

  /// No description provided for @sh_header_add_property.
  ///
  /// In en, this message translates to:
  /// **'Add your property'**
  String get sh_header_add_property;

  /// No description provided for @sh_header_add_property_free.
  ///
  /// In en, this message translates to:
  /// **'Add your property for free'**
  String get sh_header_add_property_free;

  /// No description provided for @sh_auth_prompt_message.
  ///
  /// In en, this message translates to:
  /// **'To complete this action, please create an account and verify your email first.'**
  String get sh_auth_prompt_message;

  /// No description provided for @sh_nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get sh_nav_home;

  /// No description provided for @sh_nav_my_properties.
  ///
  /// In en, this message translates to:
  /// **'My Properties'**
  String get sh_nav_my_properties;

  /// No description provided for @sh_manage_properties_prompt.
  ///
  /// In en, this message translates to:
  /// **'To manage your properties, please sign in first.'**
  String get sh_manage_properties_prompt;

  /// No description provided for @sh_brand_name.
  ///
  /// In en, this message translates to:
  /// **'Yemen Real Estate Portal'**
  String get sh_brand_name;

  /// No description provided for @sh_drawer_admin_greeting.
  ///
  /// In en, this message translates to:
  /// **'General Manager Dashboard'**
  String get sh_drawer_admin_greeting;

  /// No description provided for @sh_drawer_user_greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your account'**
  String get sh_drawer_user_greeting;

  /// No description provided for @sh_drawer_tagline.
  ///
  /// In en, this message translates to:
  /// **'Yemen\'s leading real estate platform'**
  String get sh_drawer_tagline;

  /// No description provided for @sh_drawer_map_title.
  ///
  /// In en, this message translates to:
  /// **'Property map'**
  String get sh_drawer_map_title;

  /// No description provided for @sh_drawer_map_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Search by price directly on the map of Yemen'**
  String get sh_drawer_map_subtitle;

  /// No description provided for @sh_drawer_search.
  ///
  /// In en, this message translates to:
  /// **'Search properties'**
  String get sh_drawer_search;

  /// No description provided for @sh_drawer_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorite properties'**
  String get sh_drawer_favorites;

  /// No description provided for @sh_drawer_my_properties.
  ///
  /// In en, this message translates to:
  /// **'My listed properties'**
  String get sh_drawer_my_properties;

  /// No description provided for @sh_drawer_my_requests.
  ///
  /// In en, this message translates to:
  /// **'Rental requests'**
  String get sh_drawer_my_requests;

  /// No description provided for @sh_drawer_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get sh_drawer_profile;

  /// No description provided for @sh_drawer_admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin dashboard'**
  String get sh_drawer_admin_panel;

  /// No description provided for @sh_logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get sh_logout;

  /// No description provided for @sh_login_register.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Create account'**
  String get sh_login_register;

  /// No description provided for @sh_drawer_initial_fallback.
  ///
  /// In en, this message translates to:
  /// **'U'**
  String get sh_drawer_initial_fallback;

  /// No description provided for @sh_nav_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get sh_nav_search;

  /// No description provided for @sh_nav_map.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get sh_nav_map;

  /// No description provided for @sh_nav_search_map.
  ///
  /// In en, this message translates to:
  /// **'Search & Map'**
  String get sh_nav_search_map;

  /// No description provided for @sh_nav_favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get sh_nav_favorites;

  /// No description provided for @sh_rail_my_properties.
  ///
  /// In en, this message translates to:
  /// **'My properties'**
  String get sh_rail_my_properties;

  /// No description provided for @sh_rail_admin.
  ///
  /// In en, this message translates to:
  /// **'Admin panel'**
  String get sh_rail_admin;

  /// No description provided for @sh_rail_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in / Register'**
  String get sh_rail_login;

  /// No description provided for @sh_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get sh_back;

  /// No description provided for @sh_footer_republic.
  ///
  /// In en, this message translates to:
  /// **'Republic of Yemen'**
  String get sh_footer_republic;

  /// No description provided for @sh_footer_tagline_desktop.
  ///
  /// In en, this message translates to:
  /// **'The leading national platform for buying, selling, and renting properties across all Yemeni governorates, with trusted and direct connections between advertisers and seekers.'**
  String get sh_footer_tagline_desktop;

  /// No description provided for @sh_footer_quick_links.
  ///
  /// In en, this message translates to:
  /// **'Quick links'**
  String get sh_footer_quick_links;

  /// No description provided for @sh_footer_properties_sale.
  ///
  /// In en, this message translates to:
  /// **'Properties for sale'**
  String get sh_footer_properties_sale;

  /// No description provided for @sh_footer_properties_rent.
  ///
  /// In en, this message translates to:
  /// **'Properties for rent'**
  String get sh_footer_properties_rent;

  /// No description provided for @sh_footer_add_listing.
  ///
  /// In en, this message translates to:
  /// **'Post your listing for free'**
  String get sh_footer_add_listing;

  /// No description provided for @sh_footer_my_account.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get sh_footer_my_account;

  /// No description provided for @sh_footer_my_listings.
  ///
  /// In en, this message translates to:
  /// **'My listings'**
  String get sh_footer_my_listings;

  /// No description provided for @sh_footer_contact.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get sh_footer_contact;

  /// No description provided for @sh_footer_tagline_mobile.
  ///
  /// In en, this message translates to:
  /// **'Yemen Real Estate Portal — your trusted platform for renting, buying, and selling properties in Yemen.'**
  String get sh_footer_tagline_mobile;

  /// No description provided for @sh_auth_login_required.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get sh_auth_login_required;

  /// No description provided for @sh_auth_info_note.
  ///
  /// In en, this message translates to:
  /// **'Browsing properties and services is free for guests, while protected actions require an email-verified account to safeguard your rights.'**
  String get sh_auth_info_note;

  /// No description provided for @sh_login.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get sh_login;

  /// No description provided for @sh_auth_register_new.
  ///
  /// In en, this message translates to:
  /// **'Create a new account'**
  String get sh_auth_register_new;

  /// No description provided for @sh_auth_continue_guest.
  ///
  /// In en, this message translates to:
  /// **'Continue browsing as a guest'**
  String get sh_auth_continue_guest;

  /// No description provided for @sh_error_unexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get sh_error_unexpected;

  /// No description provided for @sh_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sh_retry;

  /// No description provided for @sh_property_featured.
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get sh_property_featured;

  /// No description provided for @sh_property_rooms.
  ///
  /// In en, this message translates to:
  /// **'rooms'**
  String get sh_property_rooms;

  /// No description provided for @sh_property_bathrooms.
  ///
  /// In en, this message translates to:
  /// **'bathrooms'**
  String get sh_property_bathrooms;

  /// No description provided for @sh_contact_unavailable.
  ///
  /// In en, this message translates to:
  /// **'Direct contact details are not available for this listing at the moment.'**
  String get sh_contact_unavailable;

  /// No description provided for @sh_contact_whatsapp.
  ///
  /// In en, this message translates to:
  /// **'Chat on WhatsApp'**
  String get sh_contact_whatsapp;

  /// No description provided for @sh_contact_call.
  ///
  /// In en, this message translates to:
  /// **'Call now'**
  String get sh_contact_call;

  /// No description provided for @sh_contact_whatsapp_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open WhatsApp. Please make sure it\'s installed or call instead.'**
  String get sh_contact_whatsapp_error;

  /// No description provided for @sh_contact_call_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start the phone call. Phone number:'**
  String get sh_contact_call_error_prefix;

  /// No description provided for @sh_router_not_found.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get sh_router_not_found;

  /// No description provided for @sh_router_404_title.
  ///
  /// In en, this message translates to:
  /// **'Sorry, the page you requested doesn\'t exist (404)'**
  String get sh_router_404_title;

  /// No description provided for @sh_router_404_description.
  ///
  /// In en, this message translates to:
  /// **'Check the link or return to the home page'**
  String get sh_router_404_description;

  /// No description provided for @sh_router_404_action.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get sh_router_404_action;

  /// No description provided for @sh_router_select_property.
  ///
  /// In en, this message translates to:
  /// **'Please select a property first'**
  String get sh_router_select_property;

  /// No description provided for @sh_deferred_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get sh_deferred_loading;

  /// No description provided for @sh_deferred_error.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load this screen.'**
  String get sh_deferred_error;

  /// No description provided for @sh_deferred_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get sh_deferred_retry;

  /// No description provided for @sh_back_exit_snackbar.
  ///
  /// In en, this message translates to:
  /// **'Press again to exit the app'**
  String get sh_back_exit_snackbar;

  /// No description provided for @sys_rate_limit.
  ///
  /// In en, this message translates to:
  /// **'Too many requests recently. Please wait one minute before requesting another confirmation email to avoid being blocked.'**
  String get sys_rate_limit;

  /// No description provided for @sys_email_not_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Your email address has not been confirmed yet. Please open your inbox and click the activation link to continue.'**
  String get sys_email_not_confirmed;

  /// No description provided for @sys_link_expired.
  ///
  /// In en, this message translates to:
  /// **'The activation link has expired or has already been used. Please request a new link.'**
  String get sys_link_expired;

  /// No description provided for @sys_user_exists.
  ///
  /// In en, this message translates to:
  /// **'This email address is already registered. Please sign in instead of creating a new account.'**
  String get sys_user_exists;

  /// No description provided for @sys_invalid_credentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password.'**
  String get sys_invalid_credentials;

  /// No description provided for @sys_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get sys_weak_password;

  /// No description provided for @sys_network_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get sys_network_error;

  /// No description provided for @sys_session_expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sys_session_expired;

  /// No description provided for @sys_permission_denied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to perform this action.'**
  String get sys_permission_denied;

  /// No description provided for @sys_unknown_error.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while processing the request. Please try again later.'**
  String get sys_unknown_error;

  /// No description provided for @sys_required_field.
  ///
  /// In en, this message translates to:
  /// **'Please enter {fieldName}'**
  String sys_required_field(Object fieldName);

  /// No description provided for @sys_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get sys_required;

  /// No description provided for @sys_enter_email.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address'**
  String get sys_enter_email;

  /// No description provided for @sys_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get sys_invalid_email;

  /// No description provided for @sys_enter_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get sys_enter_password;

  /// No description provided for @sys_weak_password_long.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 letters or numbers to keep your account secure'**
  String get sys_weak_password_long;

  /// No description provided for @sys_enter_phone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a contact phone number'**
  String get sys_enter_phone;

  /// No description provided for @sys_invalid_phone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number (example: 770000000)'**
  String get sys_invalid_phone;

  /// No description provided for @sys_positive_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive number'**
  String get sys_positive_number;

  /// No description provided for @sys_non_negative_number.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number (0 or more)'**
  String get sys_non_negative_number;

  /// No description provided for @sys_login_failed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get sys_login_failed;

  /// No description provided for @sys_signup_failed.
  ///
  /// In en, this message translates to:
  /// **'Account creation failed'**
  String get sys_signup_failed;

  /// No description provided for @sys_enter_email_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address first'**
  String get sys_enter_email_first;

  /// No description provided for @sys_resend_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait {remaining} seconds before requesting another activation link to avoid duplicate requests.'**
  String sys_resend_wait(Object remaining);

  /// No description provided for @sys_property_not_found.
  ///
  /// In en, this message translates to:
  /// **'Property not found'**
  String get sys_property_not_found;

  /// No description provided for @sys_image_too_large.
  ///
  /// In en, this message translates to:
  /// **'Image size exceeds the allowed limit (5 MB)'**
  String get sys_image_too_large;

  /// No description provided for @sys_unsupported_image_format.
  ///
  /// In en, this message translates to:
  /// **'Unsupported image format. Supported formats: JPG, PNG, WEBP'**
  String get sys_unsupported_image_format;

  /// No description provided for @sys_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image: {error}'**
  String sys_upload_failed(Object error);

  /// No description provided for @misc_whatsapp_inquiry.
  ///
  /// In en, this message translates to:
  /// **'Hello, regarding the property listed on Yemen Real Estate Portal: \"{propertyTitle}\" (ID: {propertyId}), I would like to ask about the details.'**
  String misc_whatsapp_inquiry(Object propertyId, Object propertyTitle);

  /// No description provided for @misc_area_unit.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get misc_area_unit;

  /// No description provided for @misc_verified_advertiser.
  ///
  /// In en, this message translates to:
  /// **'Verified advertiser'**
  String get misc_verified_advertiser;

  /// No description provided for @csv_id.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get csv_id;

  /// No description provided for @csv_property_title.
  ///
  /// In en, this message translates to:
  /// **'Property title'**
  String get csv_property_title;

  /// No description provided for @csv_deal_type.
  ///
  /// In en, this message translates to:
  /// **'Deal type'**
  String get csv_deal_type;

  /// No description provided for @csv_property_type.
  ///
  /// In en, this message translates to:
  /// **'Property type'**
  String get csv_property_type;

  /// No description provided for @csv_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get csv_city;

  /// No description provided for @csv_district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get csv_district;

  /// No description provided for @csv_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get csv_price;

  /// No description provided for @csv_currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get csv_currency;

  /// No description provided for @csv_area.
  ///
  /// In en, this message translates to:
  /// **'Area (m²)'**
  String get csv_area;

  /// No description provided for @csv_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get csv_status;

  /// No description provided for @csv_publish_date.
  ///
  /// In en, this message translates to:
  /// **'Publish date'**
  String get csv_publish_date;

  /// No description provided for @csv_contact_phone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get csv_contact_phone;

  /// No description provided for @csv_request_number.
  ///
  /// In en, this message translates to:
  /// **'Request number'**
  String get csv_request_number;

  /// No description provided for @csv_tenant_name.
  ///
  /// In en, this message translates to:
  /// **'Tenant name'**
  String get csv_tenant_name;

  /// No description provided for @csv_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get csv_phone;

  /// No description provided for @csv_requested_start.
  ///
  /// In en, this message translates to:
  /// **'Requested start date'**
  String get csv_requested_start;

  /// No description provided for @csv_admin_notes.
  ///
  /// In en, this message translates to:
  /// **'Admin notes'**
  String get csv_admin_notes;

  /// No description provided for @csv_request_date.
  ///
  /// In en, this message translates to:
  /// **'Request date'**
  String get csv_request_date;

  /// No description provided for @csv_liable_party.
  ///
  /// In en, this message translates to:
  /// **'Liable party'**
  String get csv_liable_party;

  /// No description provided for @csv_seller_amount.
  ///
  /// In en, this message translates to:
  /// **'Seller amount'**
  String get csv_seller_amount;

  /// No description provided for @csv_buyer_amount.
  ///
  /// In en, this message translates to:
  /// **'Buyer amount'**
  String get csv_buyer_amount;

  /// No description provided for @csv_total_commission.
  ///
  /// In en, this message translates to:
  /// **'Total commission'**
  String get csv_total_commission;

  /// No description provided for @csv_settlement_status.
  ///
  /// In en, this message translates to:
  /// **'Settlement status'**
  String get csv_settlement_status;

  /// No description provided for @csv_settlement_method.
  ///
  /// In en, this message translates to:
  /// **'Settlement method'**
  String get csv_settlement_method;

  /// No description provided for @csv_registration_date.
  ///
  /// In en, this message translates to:
  /// **'Registration date'**
  String get csv_registration_date;

  /// No description provided for @csv_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get csv_notes;

  /// No description provided for @misc_owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get misc_owner;

  /// No description provided for @misc_listed_property.
  ///
  /// In en, this message translates to:
  /// **'Listed property'**
  String get misc_listed_property;

  /// No description provided for @misc_user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get misc_user;

  /// No description provided for @dash_map_cta_title.
  ///
  /// In en, this message translates to:
  /// **'Explore Yemeni properties on the interactive map 🇾🇪'**
  String get dash_map_cta_title;

  /// No description provided for @dash_map_cta_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Browse prices and locations directly in Sanaa, Ibb, Taiz, and all governorates'**
  String get dash_map_cta_subtitle;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
