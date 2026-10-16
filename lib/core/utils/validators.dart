class Validators {
  static String? requiredField(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'يرجى إدخال $fieldName' : 'هذا الحقل مطلوب';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن لا تقل كلمة المرور عن 6 أحرف أو أرقام';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'يرجى إدخال رقم الهاتف للتواصل';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 9 || clean.length > 14) {
      return 'رقم الهاتف غير صحيح (مثال: 770000000)';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null ? 'يرجى إدخال $fieldName' : 'هذا الحقل مطلوب';
    }
    final numValue = num.tryParse(value.trim());
    if (numValue == null || numValue <= 0) {
      return 'يرجى إدخال رقم موجب صحيح';
    }
    return null;
  }

  static String? nonNegativeNumber(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional if empty
    }
    final numValue = num.tryParse(value.trim());
    if (numValue == null || numValue < 0) {
      return 'يرجى إدخال رقم صحيح (0 أو أكثر)';
    }
    return null;
  }
}
