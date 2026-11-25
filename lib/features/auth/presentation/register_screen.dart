import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (success && mounted) {
      final userEmail = _emailController.text.trim();
      bool isResending = false;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  color: AppColors.primaryInk,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.l10n.register_confirm_title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.register_confirm_message,
                    style: AppFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryInk.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: AppColors.primaryInk, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.cairo(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.register_open_inbox,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warningFill,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.warningInk.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warningInk,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.register_warning,
                            style: AppFonts.cairo(
                              fontSize: 11.5,
                              color: AppColors.warningInk,
                              fontWeight: FontWeight.w600,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: isResending
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final l10n = context.l10n;
                              setDialogState(() => isResending = true);
                              final resent = await ref
                                  .read(authProvider.notifier)
                                  .resendConfirmationEmail(userEmail);
                              setDialogState(() => isResending = false);
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    resent
                                        ? l10n.register_resend_success
                                        : (ref.read(authProvider).errorMessage ??
                                              l10n.register_resend_failed),
                                    style: AppFonts.cairo(),
                                  ),
                                  backgroundColor: resent
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              );
                            },
                      icon: isResending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.refresh,
                              size: 18,
                              color: AppColors.primaryInk,
                            ),
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 230),
                        child: Text(
                          isResending
                              ? context.l10n.register_resending
                              : context.l10n.register_resend_prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  Navigator.of(ctx).pop();
                  router.go('/');
                },
                child: Text(
                  context.l10n.register_browse_guest,
                  style: AppFonts.cairo(color: AppColors.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final router = GoRouter.of(context);
                  final redirectTo = GoRouterState.of(
                    context,
                  ).uri.queryParameters['redirectTo'];
                  Navigator.of(ctx).pop();
                  final uri = Uri(
                    path: '/login',
                    queryParameters: {
                      if (redirectTo != null) 'redirectTo': redirectTo,
                    },
                  );
                  router.pushReplacement(uri.toString());
                },
                child: Text(
                  context.l10n.register_go_login,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final routerState = GoRouterState.of(context);
    final reason = routerState.uri.queryParameters['reason'];

    return AuthFormScaffold(
      title: context.l10n.register_title,
      subtitle: context.l10n.register_subtitle,
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
                tone: AuthInfoTone.error,
                icon: Icons.error_outline,
                message: authState.errorMessage!,
                actionLabel: authState.errorCode == 'user_already_exists'
                    ? context.l10n.register_go_login_now
                    : null,
                actionIcon: Icons.login,
                onAction: authState.errorCode == 'user_already_exists'
                    ? () => context.pushReplacement('/login')
                    : null,
              ),
              const SizedBox(height: 16),
            ],

            AuthField(
              label: context.l10n.register_full_name_required,
              child: TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                validator: (val) => Validators.requiredField(
                  val,
                  context.l10n.register_full_name,
                ),
                decoration: InputDecoration(
                  hintText: context.l10n.register_name_hint,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ),
            const SizedBox(height: 14),

            AuthField(
              label: context.l10n.register_email_required,
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
            const SizedBox(height: 14),

            AuthField(
              label: context.l10n.register_phone_required,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
                decoration: InputDecoration(
                  hintText: context.l10n.register_phone_hint,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
            ),
            const SizedBox(height: 14),

            AuthField(
              label: context.l10n.register_password_required,
              child: TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                validator: Validators.password,
                decoration: InputDecoration(
                  hintText: context.l10n.register_password_hint,
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
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 24),

            AuthPrimaryButton(
              label: context.l10n.register_submit,
              loading: authState.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: 12),

            AuthSwitchLink(
              prompt: context.l10n.register_have_account,
              action: context.l10n.register_login_link,
              onPressed: () => context.pushReplacement('/login'),
            ),
          ],
        ),
      ),
    );
  }
}
