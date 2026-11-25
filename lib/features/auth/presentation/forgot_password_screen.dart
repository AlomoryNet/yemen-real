import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import 'widgets/auth_ui.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    final success = await ref
        .read(authProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isSending = false;
      _sent = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: context.l10n.forgot_title,
      subtitle:
          _sent ? context.l10n.forgot_check_inbox : context.l10n.forgot_instructions,
      child: _sent ? _buildSentView(context) : _buildFormView(context),
    );
  }

  Widget _buildSentView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.successFill,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mark_email_read_outlined,
            size: 34,
            color: AppColors.successInk,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          context.l10n.forgot_link_sent,
          textAlign: TextAlign.center,
          style: AppFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 20),
        AuthPrimaryButton(
          label: context.l10n.forgot_back_to_login,
          icon: Icons.login,
          onPressed: () => context.pushReplacement('/login'),
        ),
      ],
    );
  }

  Widget _buildFormView(BuildContext context) {
    final authState = ref.watch(authProvider);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (authState.errorMessage != null) ...[
            AuthInfoBanner(
              tone: AuthInfoTone.error,
              icon: Icons.error_outline,
              message: authState.errorMessage!,
            ),
            const SizedBox(height: 16),
          ],

          AuthField(
            label: context.l10n.forgot_email,
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              decoration: const InputDecoration(
                hintText: 'name@example.com',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              onFieldSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(height: 24),

          AuthPrimaryButton(
            label: context.l10n.forgot_send_link,
            loading: _isSending,
            onPressed: _submit,
          ),
          const SizedBox(height: 12),

          Center(
            child: TextButton.icon(
              onPressed: () => context.pushReplacement('/login'),
              icon: const Icon(Icons.login, size: 17),
              label: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 240),
                child: Text(
                  context.l10n.forgot_return_to_login,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryInk,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
