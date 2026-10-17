class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  factory AppException.fromSupabase(dynamic error) {
    final rawMessage = error.toString().toLowerCase();

    if (rawMessage.contains('email not confirmed') ||
        rawMessage.contains('email_not_confirmed')) {
      return AppException(
        'البريد الإلكتروني لم يتم تأكيده بعد. يرجى فتح بريدك الإلكتروني والضغط على رابط التفعيل للمتابعة.',
        code: 'email_not_confirmed',
      );
    }
    if (rawMessage.contains('over_email_send_rate_limit') ||
        rawMessage.contains('rate limit') ||
        rawMessage.contains('too many requests')) {
      return AppException(
        'تم إرسال رابط مؤخراً، يرجى الانتظار دقيقة واحدة قبل طلب إعادة الإرسال.',
        code: 'rate_limit',
      );
    }
    if (rawMessage.contains('invalid login credentials') ||
        rawMessage.contains('invalid_credentials')) {
      return AppException('البريد الإلكتروني أو كلمة المرور غير صحيحة', code: 'invalid_credentials');
    }
    if (rawMessage.contains('user already registered') ||
        rawMessage.contains('user_already_exists')) {
      return AppException('هذا البريد الإلكتروني مسجل بالفعل', code: 'user_already_exists');
    }
    if (rawMessage.contains('password') && (rawMessage.contains('least') || rawMessage.contains('weak') || rawMessage.contains('short'))) {
      return AppException('كلمة المرور يجب ألا تقل عن 8 خانات.', code: 'weak_password');
    }
    if (rawMessage.contains('expired') || rawMessage.contains('otp_expired')) {
      return AppException('انتهت صلاحية رابط التفعيل، يرجى طلب إعادة إرسال رابط جديد.', code: 'link_expired');
    }
    if (rawMessage.contains('network') ||
        rawMessage.contains('connection refused') ||
        rawMessage.contains('failed host lookup')) {
      return AppException(
        'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.',
        code: 'network_error',
      );
    }
    if (rawMessage.contains('jwt') || rawMessage.contains('token expired')) {
      return AppException('انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.', code: 'session_expired');
    }
    if (rawMessage.contains('permission denied') ||
        rawMessage.contains('row-level security')) {
      return AppException('ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء.', code: 'permission_denied');
    }

    return AppException('حدث خطأ أثناء معالجة الطلب، يرجى المحاولة لاحقاً.');
  }
}
