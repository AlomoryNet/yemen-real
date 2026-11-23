import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../l10n/app_locale.dart';
import '../l10n/app_strings.dart';

class Formatters {
  // Cache per locale so switching language in Settings takes effect
  // immediately without re-creating formatters on every call.
  static final Map<String, NumberFormat> _currencyFormats = {};
  static final Map<String, NumberFormat> _decimalFormats = {};
  static final Map<String, DateFormat> _dateFormats = {};
  static final Map<String, DateFormat> _dateTimeFormats = {};

  static String get _intlLocale => AppLocale.isArabic ? 'ar' : 'en';
  static NumberFormat get _currencyFormat => _currencyFormats.putIfAbsent(
    _intlLocale,
    () => NumberFormat('#,##0', _intlLocale),
  );
  static NumberFormat get _decimalFormat => _decimalFormats.putIfAbsent(
    _intlLocale,
    () => NumberFormat('#,##0.##', _intlLocale),
  );
  static DateFormat get _dateFormat => _dateFormats.putIfAbsent(
    _intlLocale,
    () => DateFormat('yyyy/MM/dd', _intlLocale),
  );
  static DateFormat get _dateTimeFormat => _dateTimeFormats.putIfAbsent(
    _intlLocale,
    () => DateFormat('yyyy/MM/dd HH:mm', _intlLocale),
  );

  static String formatCurrency(num amount, String currencyCode) {
    final formattedAmount = _currencyFormat.format(amount);
    final currencyName = AppConstants.getCurrencyNameAr(currencyCode);
    return '$formattedAmount $currencyName';
  }

  static String formatArea(num area) {
    final formatted = _decimalFormat.format(area);
    return '$formatted ${tr.misc_area_unit}';
  }

  static String formatDate(DateTime? date) {
    if (date == null) return '-';
    return _dateFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return _dateTimeFormat.format(date);
  }

  /// Clean and format Yemeni phone numbers (e.g. 770000000 -> +967770000000)
  static String formatPhoneForDialing(String rawPhone) {
    String clean = rawPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (clean.startsWith('00967')) {
      clean = '+967${clean.substring(5)}';
    } else if (clean.startsWith('967')) {
      clean = '+$clean';
    } else if (clean.startsWith('0') && clean.length == 10) {
      clean = '+967${clean.substring(1)}';
    } else if (!clean.startsWith('+') && clean.length == 9) {
      clean = '+967$clean';
    }
    return clean;
  }

  /// Format phone for WhatsApp link (digits only without + or leading zeros)
  static String formatPhoneForWhatsApp(String rawPhone) {
    String clean = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('00967')) {
      clean = clean.substring(2);
    } else if (clean.startsWith('0') && clean.length == 10) {
      clean = '967${clean.substring(1)}';
    } else if (clean.length == 9) {
      clean = '967$clean';
    }
    return clean;
  }
}
