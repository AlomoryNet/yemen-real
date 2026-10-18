import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;

  factory AppException.fromSupabase(dynamic error) {
    if (error is AppException) return error;

    String? code;
    String rawMessage = error.toString().toLowerCase();

    if (error is AuthException) {
      code = error.code?.toLowerCase();
      rawMessage =
          '${error.message} ${error.code ?? ''} ${error.statusCode ?? ''}'
              .toLowerCase();
    }

    // 1. Rate limiting
    if (code == 'over_email_send_rate_limit' ||
        code == 'over_request_rate_limit' ||
        rawMessage.contains('over_email_send_rate_limit') ||
        rawMessage.contains('rate limit') ||
        rawMessage.contains('too many requests') ||
        rawMessage.contains('429')) {
      return AppException(
        'تم إرسال عدة طلبات مؤخراً. يرجى الانتظار دقيقة واحدة قبل طلب إعادة الإرسال لمنع الحظر.',
        code: 'rate_limit',
      );
    }

    // 2. Email not confirmed
    if (code == 'email_not_confirmed' ||
        rawMessage.contains('email not confirmed') ||
        rawMessage.contains('email_not_confirmed')) {
      return AppException(
        'البريد الإلكتروني لم يتم تأكيده بعد. يرجى فتح بريدك الإلكتروني والضغط على رابط التفعيل للمتابعة.',
        code: 'email_not_confirmed',
      );
    }

    // 3. Link or token expired / already used
    if (code == 'otp_expired' ||
        code == 'flow_state_not_found' ||
        rawMessage.contains('otp_expired') ||
        rawMessage.contains('token has expired') ||
        rawMessage.contains('link is invalid or has expired') ||
        rawMessage.contains('flow_state_not_found') ||
        rawMessage.contains('expired')) {
      return AppException(
        'رابط التفعيل منتهي الصلاحية أو تم استخدامه مسبقاً. يرجى طلب رابط جديد.',
        code: 'link_expired',
      );
    }

    // 4. User already registered
    if (code == 'user_already_exists' ||
        rawMessage.contains('user already registered') ||
        rawMessage.contains('user_already_exists') ||
        rawMessage.contains('already exists')) {
      return AppException(
        'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد.',
        code: 'user_already_exists',
      );
    }

    // 5. Invalid credentials (wrong email or password)
    if (code == 'invalid_credentials' ||
        rawMessage.contains('invalid login credentials') ||
        rawMessage.contains('invalid_credentials')) {
      return AppException(
        'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        code: 'invalid_credentials',
      );
    }

    // 6. Weak password
    if (code == 'weak_password' ||
        (rawMessage.contains('password') &&
            (rawMessage.contains('least') ||
                rawMessage.contains('weak') ||
                rawMessage.contains('short')))) {
      return AppException(
        'كلمة المرور يجب ألا تقل عن 8 خانات.',
        code: 'weak_password',
      );
    }

    // 7. Network / connection issues
    if (rawMessage.contains('network') ||
        rawMessage.contains('connection refused') ||
        rawMessage.contains('failed host lookup') ||
        rawMessage.contains('socketexception') ||
        rawMessage.contains('clientexception') ||
        rawMessage.contains('handshake') ||
        rawMessage.contains('connection timed out')) {
      return AppException(
        'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
        code: 'network_error',
      );
    }

    // 8. Session expired
    if (rawMessage.contains('jwt') || rawMessage.contains('token expired')) {
      return AppException(
        'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.',
        code: 'session_expired',
      );
    }

    // 9. Row level security / permission denied
    if (rawMessage.contains('permission denied') ||
        rawMessage.contains('row-level security')) {
      return AppException(
        'ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء.',
        code: 'permission_denied',
      );
    }

    return AppException(
      'حدث خطأ أثناء معالجة الطلب، يرجى المحاولة لاحقاً.',
      code: 'unknown_error',
      details: error,
    );
  }
}
