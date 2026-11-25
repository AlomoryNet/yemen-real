import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

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
    final routerState = GoRouterState.of(context);
    final reason = routerState.uri.queryParameters['reason'];

    final isUnconfirmed = authState.errorCode == 'email_not_confirmed';
    final isExpired = authState.errorCode == 'link_expired';
    final isRateLimited = authState.errorCode == 'rate_limit';
    final isNetwork = authState.errorCode == 'network_error';
    final isCreds = authState.errorCode == 'invalid_credentials';
    final isWarning = isUnconfirmed || isExpired || isRateLimited;
    final canResend = isUnconfirmed || isExpired;

    final errorIcon = isUnconfirmed
        ? Icons.mark_email_unread_outlined
        : isExpired
        ? Icons.schedule_outlined
        : isRateLimited
        ? Icons.timer_outlined
        : isCreds
        ? Icons.lock_outline
        : isNetwork
        ? Icons.wifi_off_outlined
        : Icons.error_outline;

    return AuthFormScaffold(
      title: context.l10n.login_title,
      subtitle: context.l10n.login_subtitle,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reason != null && reason.isNotEmpty) ...[
              AuthInfoBanner(
                tone: AuthInfoTone.info,
                icon: Icons.info_outline,
                message: reason,
              ),
              const SizedBox(height: 16),
            ],
            if (authState.errorMessage != null) ...[
              AuthInfoBanner(
                tone: isWarning ? AuthInfoTone.warning : AuthInfoTone.error,
                icon: errorIcon,
                message: authState.errorMessage!,
                actionLabel: canResend
                    ? (_isResending
                          ? context.l10n.login_sending
                          : context.l10n.login_resend_now)
                    : null,
                actionIcon: Icons.send_rounded,
                onAction: canResend ? _resendVerification : null,
                actionLoading: _isResending,
              ),
              const SizedBox(height: 16),
            ],

            AuthField(
              label: context.l10n.login_email,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                decoration: const InputDecoration(
                  hintText: 'name@example.com',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
            ),
            const SizedBox(height: 16),

            AuthField(
              label: context.l10n.login_password,
              child: TextFormField(
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
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: (val) =>
                      setState(() => _rememberMe = val ?? false),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    context.l10n.login_remember_me,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => context.push('/forgot-password'),
                  child: Text(
                    context.l10n.login_forgot_password,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryInk,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            AuthPrimaryButton(
              label: context.l10n.login_submit,
              loading: authState.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),

            AuthSwitchLink(
              prompt: context.l10n.login_no_account,
              action: context.l10n.login_create_account,
              onPressed: () {
                final redirectTo = routerState.uri.queryParameters['redirectTo'];
                final reasonParam = routerState.uri.queryParameters['reason'];
                final uri = Uri(
                  path: '/register',
                  queryParameters: {
                    if (redirectTo != null) 'redirectTo': redirectTo,
                    if (reasonParam != null) 'reason': reasonParam,
                  },
                );
                // Replace the auth page instead of stacking login↔register
                // toggles, while preserving the app screen underneath for Back.
                context.pushReplacement(uri.toString());
              },
            ),

            Center(
              child: TextButton(
                onPressed: _isResending ? null : _resendVerification,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Text(
                    context.l10n.login_resend_prompt,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            const Divider(height: 28),

            Text(
              context.l10n.login_quick_demo,
              style: AppFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              children: [
                AuthSecondaryButton(
                  label: context.l10n.login_demo_admin,
                  icon: Icons.admin_panel_settings_outlined,
                  onPressed: _fillDemoAdmin,
                ),
                const SizedBox(height: 8),
                AuthSecondaryButton(
                  label: context.l10n.login_demo_user,
                  icon: Icons.person_outline,
                  onPressed: _fillDemoUser,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
