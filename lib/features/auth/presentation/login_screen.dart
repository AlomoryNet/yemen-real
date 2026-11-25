import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Purge any legacy email
      final legacy = prefs.getString('saved_login_email');
      if (legacy != null && legacy.contains('mohammed.f.saqqaf')) {
        await prefs.remove('saved_login_email');
      }
      final remember = prefs.getBool('remember_me') ?? false;
      final savedEmail = prefs.getString('saved_login_email');
      if (remember && savedEmail != null && savedEmail.isNotEmpty) {
        if (mounted) {
          setState(() {
            _rememberMe = true;
            _emailController.text = savedEmail;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _resendVerification() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.login_enter_email_first,
            style: AppFonts.cairo(),
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
                ? context.l10n.login_verification_resent
                : (ref.read(authProvider).errorMessage ??
                      context.l10n.login_resend_failed),
            style: AppFonts.cairo(),
          ),
          backgroundColor: sent ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .signIn(_emailController.text.trim(), _passwordController.text);

    if (success && mounted) {
      try {
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setBool('remember_me', true);
          await prefs.setString(
            'saved_login_email',
            _emailController.text.trim(),
          );
        } else {
          await prefs.setBool('remember_me', false);
          await prefs.remove('saved_login_email');
        }
      } catch (_) {}

      if (!mounted) return;

      final redirectTo = GoRouterState.of(
        context,
      ).uri.queryParameters['redirectTo'];
      if (redirectTo != null && redirectTo.isNotEmpty) {
        context.go(redirectTo);
      } else {
        context.go('/');
      }
    }
  }

  void _fillDemoAdmin() {
    _emailController.text = 'mo772522233@gmail.com';
    _passwordController.text = 'Demo@2026';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.login_demo_admin_filled,
          style: AppFonts.cairo(),
        ),
        backgroundColor: AppColors.primaryDark,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _fillDemoUser() {
    _emailController.text = 'user@yemenrealestate.local';
    _passwordController.text = 'Demo@2026';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.login_demo_user_filled,
          style: AppFonts.cairo(),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.login_title,
          style: AppFonts.cairo(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.divider),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.login_title,
                        style: AppFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.login_subtitle,
                        style: AppFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Builder(
                        builder: (context) {
                          final reason = GoRouterState.of(
                            context,
                          ).uri.queryParameters['reason'];
                          if (reason == null || reason.isEmpty)
                            return const SizedBox.shrink();
                          return Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMuted,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppColors.primaryInk,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    reason,
                                    style: AppFonts.cairo(
                                      color: AppColors.primaryDark,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      if (authState.errorMessage != null) ...[
                        Builder(
                          builder: (context) {
                            final isUnconfirmed =
                                authState.errorCode == 'email_not_confirmed';
                            final isExpired =
                                authState.errorCode == 'link_expired';
                            final isRateLimited =
                                authState.errorCode == 'rate_limit';
                            final isNetwork =
                                authState.errorCode == 'network_error';
                            final isCreds =
                                authState.errorCode == 'invalid_credentials';

                            Color boxBg = AppColors.errorMuted;
                            Color borderColor = AppColors.error.withOpacity(
                              0.3,
                            );
                            Color textColor = AppColors.error;
                            IconData iconData = Icons.error_outline;

                            if (isUnconfirmed) {
                              boxBg = AppColors.warningMuted;
                              borderColor = AppColors.warning.withValues(
                                alpha: 0.3,
                              );
                              textColor = AppColors.accentInk;
                              iconData = Icons.mark_email_unread_outlined;
                            } else if (isExpired || isRateLimited) {
                              boxBg = AppColors.warningMuted;
                              borderColor = AppColors.warning.withValues(
                                alpha: 0.3,
                              );
                              textColor = AppColors.accentInk;
                              iconData = isRateLimited
                                  ? Icons.timer_outlined
                                  : Icons.schedule_outlined;
                            } else if (isCreds) {
                              iconData = Icons.lock_outline;
                            } else if (isNetwork) {
                              iconData = Icons.wifi_off_outlined;
                            }

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: boxBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        iconData,
                                        color: textColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authState.errorMessage!,
                                          style: AppFonts.cairo(
                                            color: textColor,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isUnconfirmed || isExpired) ...[
                                    const SizedBox(height: 8),
                                    Divider(height: 1, color: borderColor),
                                    const SizedBox(height: 6),
                                    SizedBox(
                                      width: double.infinity,
                                      child: TextButton.icon(
                                        onPressed: _isResending
                                            ? null
                                            : _resendVerification,
                                        icon: _isResending
                                            ? const SizedBox(
                                                width: 14,
                                                height: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Icon(
                                                Icons.send_rounded,
                                                size: 16,
                                              ),
                                        label: Text(
                                          _isResending
                                              ? context.l10n.login_sending
                                              : context.l10n.login_resend_now,
                                          style: AppFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryDark,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email Field
                      Text(
                        context.l10n.login_email,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: Validators.email,
                        decoration: const InputDecoration(
                          hintText: 'name@example.com',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      Text(
                        context.l10n.login_password,
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: Validators.password,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? context.l10n.auth_show_password
                                : context.l10n.auth_hide_password,
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 8),

                      // Remember Me & Forgot Password Row
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                          ),
                          Flexible(
                            child: Text(
                              context.l10n.login_remember_me,
                              maxLines: 2,
                              style: AppFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => context.push('/forgot-password'),
                            child: Text(
                              context.l10n.login_forgot_password,
                              style: AppFonts.cairo(
                                fontSize: 12,
                                color: AppColors.primaryInk,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textLight,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: authState.isLoading ? null : _submit,
                          child: authState.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: AppColors.textLight,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  context.l10n.login_submit,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textLight,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Switch to Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              context.l10n.login_no_account,
                              maxLines: 2,
                              style: AppFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Flexible(
                            child: TextButton(
                              onPressed: () {
                                final redirectTo = GoRouterState.of(
                                  context,
                                ).uri.queryParameters['redirectTo'];
                                final reason = GoRouterState.of(
                                  context,
                                ).uri.queryParameters['reason'];
                                final uri = Uri(
                                  path: '/register',
                                  queryParameters: {
                                    if (redirectTo != null)
                                      'redirectTo': redirectTo,
                                    if (reason != null) 'reason': reason,
                                  },
                                );
                                // Replace the auth page instead of stacking
                                // login↔register toggles, while preserving the
                                // app screen underneath for Android Back.
                                context.pushReplacement(uri.toString());
                              },
                              child: Text(
                                context.l10n.login_create_account,
                                style: AppFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryInk,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Center(
                        child: TextButton.icon(
                          onPressed: _isResending ? null : _resendVerification,
                          icon: const Icon(
                            Icons.mark_email_unread_outlined,
                            size: 16,
                          ),
                          label: Text(
                            context.l10n.login_resend_prompt,
                            style: AppFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                      const Divider(height: 28),

                      // Demo Quick Fill Helpers
                      Text(
                        context.l10n.login_quick_demo,
                        style: AppFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _fillDemoAdmin,
                              child: Text(
                                context.l10n.login_demo_admin,
                                style: AppFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              onPressed: _fillDemoUser,
                              child: Text(
                                context.l10n.login_demo_user,
                                style: AppFonts.cairo(fontSize: 11),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
