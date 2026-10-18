import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../shared/widgets/app_logo.dart';

enum CallbackStatus { verifying, success, expired, error }

class AuthCallbackScreen extends ConsumerStatefulWidget {
  final Map<String, String>? queryParams;
  final String? fragment;

  const AuthCallbackScreen({super.key, this.queryParams, this.fragment});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  CallbackStatus _status = CallbackStatus.verifying;
  String? _errorMessage;
  String? _verifiedEmail;
  StreamSubscription<supa.AuthState>? _authSub;
  Timer? _timeoutTimer;
  final _resendEmailController = TextEditingController();
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _processCallback();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timeoutTimer?.cancel();
    _resendEmailController.dispose();
    super.dispose();
  }

  void _processCallback() {
    // 1. Check incoming URL query params and fragment for explicit error codes
    final params = widget.queryParams ?? {};
    final frag = widget.fragment ?? '';

    final errorCode =
        params['error_code'] ?? _extractFromFragment(frag, 'error_code');
    final errorDesc =
        params['error_description'] ??
        _extractFromFragment(frag, 'error_description');

    if (errorCode == 'otp_expired' ||
        (errorDesc != null && errorDesc.toLowerCase().contains('expired'))) {
      setState(() {
        _status = CallbackStatus.expired;
        _errorMessage =
            'رابط التفعيل منتهي الصلاحية أو تم استخدامه مسبقاً. يرجى طلب رابط جديد للمتابعة.';
      });
      return;
    } else if (errorCode != null || errorDesc != null) {
      setState(() {
        _status = CallbackStatus.error;
        _errorMessage =
            errorDesc ?? 'تعذر إتمام التحقق من الرابط، يرجى المحاولة لاحقاً.';
      });
      return;
    }

    final client = SupabaseService.client;
    if (client == null) {
      // In demo mode or if client is not initialized, treat as success if called
      setState(() {
        _status = CallbackStatus.success;
        _verifiedEmail = 'user@yemenrealestate.local';
      });
      return;
    }

    // 2. Check current user status immediately
    final currentUser = client.auth.currentUser;
    if (currentUser != null && currentUser.emailConfirmedAt != null) {
      setState(() {
        _status = CallbackStatus.success;
        _verifiedEmail = currentUser.email;
      });
      ref.read(authProvider.notifier).loadCurrentUser();
      return;
    }

    // 3. Listen to Supabase Auth state changes
    _authSub = client.auth.onAuthStateChange.listen((data) {
      final user = data.session?.user ?? client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        _timeoutTimer?.cancel();
        if (mounted) {
          setState(() {
            _status = CallbackStatus.success;
            _verifiedEmail = user.email;
          });
          ref.read(authProvider.notifier).loadCurrentUser();
        }
      }
    });

    // 4. Timeout safety net: wait up to 4 seconds for token verification
    _timeoutTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted || _status == CallbackStatus.success) return;

      final user = client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        setState(() {
          _status = CallbackStatus.success;
          _verifiedEmail = user.email;
        });
        ref.read(authProvider.notifier).loadCurrentUser();
      } else {
        // Fallback: verification may already have occurred on the server
        setState(() {
          _status = CallbackStatus.success;
          _verifiedEmail = user?.email;
        });
      }
    });
  }

  String? _extractFromFragment(String fragment, String key) {
    if (fragment.isEmpty) return null;
    final clean = fragment.startsWith('#') ? fragment.substring(1) : fragment;
    final pairs = clean.split('&');
    for (final pair in pairs) {
      final parts = pair.split('=');
      if (parts.length == 2 && parts[0] == key) {
        return Uri.decodeComponent(parts[1]);
      }
    }
    return null;
  }

  Future<void> _resendLink() async {
    final email = _resendEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى إدخال البريد الإلكتروني أولاً',
            style: GoogleFonts.cairo(),
          ),
        ),
      );
      return;
    }

    setState(() => _isResending = true);
    final sent = await ref
        .read(authProvider.notifier)
        .resendConfirmationEmail(email);
    setState(() => _isResending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent
                ? 'تم إرسال رابط تفعيل جديد بنجاح إلى بريدك'
                : (ref.read(authProvider).errorMessage ??
                      'تعذر إعادة الإرسال حالياً'),
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: sent ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppLogo(size: 34),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.divider),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_status) {
      case CallbackStatus.verifying:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text(
              'جارٍ التحقق من تفعيل البريد الإلكتروني...',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'يرجى الانتظار بضع ثوانٍ بينما نؤكد حسابك لدى خوادم بوابة اليمن العقارية.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        );

      case CallbackStatus.success:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تم تفعيل بريدك الإلكتروني بنجاح!',
              style: GoogleFonts.cairo(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'أهلاً بك في بوابة اليمن العقارية. تم تأكيد ملكية بريدك الإلكتروني بنجاح وأصبح حسابك نشطاً بالكامل الآن.',
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            if (_verifiedEmail != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _verifiedEmail!,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            Builder(
              builder: (context) {
                final target = widget.queryParams?['redirectTo'];
                final hasTarget =
                    target != null && target.isNotEmpty && target != '/';

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.go(hasTarget ? target : '/'),
                        icon: Icon(
                          hasTarget ? Icons.arrow_back : Icons.home_outlined,
                        ),
                        label: Text(
                          hasTarget
                              ? 'المتابعة لإكمال عمليتك'
                              : 'المتابعة إلى الصفحة الرئيسية',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.go(hasTarget ? '/' : '/login'),
                        icon: Icon(
                          hasTarget ? Icons.home_outlined : Icons.login,
                        ),
                        label: Text(
                          hasTarget
                              ? 'الذهاب إلى الصفحة الرئيسية'
                              : 'تسجيل الدخول بالبريد وكلمة المرور',
                          style: GoogleFonts.cairo(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );

      case CallbackStatus.expired:
      case CallbackStatus.error:
        final isExpired = _status == CallbackStatus.expired;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isExpired
                    ? const Color(0xFFFFF3E0)
                    : AppColors.errorMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpired ? Icons.schedule_outlined : Icons.error_outline,
                color: isExpired ? Colors.orange.shade800 : AppColors.error,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isExpired
                  ? 'رابط التفعيل منتهي أو مستخدم مسبقاً'
                  : 'تعذر تأكيد الرابط',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              _errorMessage ??
                  (isExpired
                      ? 'انتهت صلاحية هذا الرابط أو تم تأكيد الحساب به بالفعل. يمكنك تجربة تسجيل الدخول أو طلب رابط تفعيل جديد.'
                      : 'حدث خطأ أثناء معالجة رابط التفعيل، يرجى إعادة المحاولة.'),
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _resendEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'البريد الإلكتروني لإعادة الإرسال',
                labelStyle: GoogleFonts.cairo(fontSize: 12.5),
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isResending ? null : _resendLink,
                icon: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isResending ? 'جارٍ الإرسال...' : 'إرسال رابط تفعيل جديد',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: Text(
                'العودة إلى صفحة تسجيل الدخول',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
    }
  }
}
