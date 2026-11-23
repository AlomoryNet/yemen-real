import '../l10n/app_strings.dart';
class Validators {
  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? tr.sys_required_field(fieldName) : tr.sys_required;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr.sys_enter_email;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return tr.sys_invalid_email;
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return tr.sys_enter_password;
    }
    if (value.length < 8) {
      return tr.sys_weak_password_long;
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return tr.sys_enter_phone;
    }
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 9 || clean.length > 14) {
      return tr.sys_invalid_phone;
    }
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? tr.sys_required_field(fieldName) : tr.sys_required;
    }
    final numValue = num.tryParse(value.trim());
    if (numValue == null || numValue <= 0) {
      return tr.sys_positive_number;
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional if empty
    }
    final numValue = num.tryParse(value.trim());
    if (numValue == null || numValue < 0) {
      return tr.sys_non_negative_number;
    }
    return null;
  }
}
