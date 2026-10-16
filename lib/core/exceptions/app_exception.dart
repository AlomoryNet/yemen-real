class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  factory AppException.fromSupabase(dynamic error) {
    final rawMessage = error.toString().toLowerCase();

    if (rawMessage.contains('invalid login credentials') ||
        rawMessage.contains('invalid_credentials')) {
      return AppException('البريد الإلكتروني أو كلمة المرور غير صحيحة');
    }
    if (rawMessage.contains('user already registered') ||
        rawMessage.contains('user_already_exists')) {
      return AppException('هذا البريد الإلكتروني مسجل بالفعل');
    }
    if (rawMessage.contains('network') ||
        rawMessage.contains('connection refused') ||
        rawMessage.contains('failed host lookup')) {
      return AppException(
        'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.',
      );
    }
    if (rawMessage.contains('jwt') || rawMessage.contains('token expired')) {
      return AppException('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.');
    }
    if (rawMessage.contains('permission denied') ||
        rawMessage.contains('row-level security')) {
      return AppException('ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء.');
    }

    return AppException('حدث خطأ أثناء معالجة الطلب، يرجى المحاولة لاحقاً.');
  }
}
