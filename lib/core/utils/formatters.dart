import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat('#,##0', 'ar');
  static final NumberFormat _decimalFormat = NumberFormat('#,##0.##', 'ar');
  static final DateFormat _dateFormat = DateFormat('yyyy/MM/dd', 'ar');
  static final DateFormat _dateTimeFormat = DateFormat(
    'yyyy/MM/dd HH:mm',
    'ar',
  );

  static String formatCurrency(num amount, String currencyCode) {
    final formattedAmount = _currencyFormat.format(amount);
    final currencyName = AppConstants.getCurrencyNameAr(currencyCode);
    return '$formattedAmount $currencyName';
  }

  static String formatArea(num area) {
    final formatted = _decimalFormat.format(area);
    return '$formatted م²';
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
