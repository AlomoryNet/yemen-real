import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/supabase_service.dart';
import 'widgets/auth_ui.dart';

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
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isResending = false;
  bool _isRecovery = false;
  bool _isSavingPassword = false;
  bool _passwordSaved = false;

  @override
  void initState() {
    super.initState();
    // Localizations are inherited widgets, so they are not available until
    // after the first build. Defer callback processing by one frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_processCallback(context));
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _timeoutTimer?.cancel();
    _resendEmailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _processCallback(BuildContext context) async {
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
        _errorMessage = context.l10n.callback_expired_message;
      });
      return;
    } else if (errorCode != null || errorDesc != null) {
      setState(() {
        _status = CallbackStatus.error;
        _errorMessage = errorDesc ?? context.l10n.callback_link_error;
      });
      return;
    }

    final client = SupabaseService.client;
    final isRecovery = _hasParamValue(params, frag, 'type', 'recovery');

    if (isRecovery && client != null) {
      // supabase_flutter consumes the same deep link and establishes a
      // recovery session. Give it a moment before showing the password form.
      setState(() {
        _isRecovery = true;
        _status = CallbackStatus.verifying;
      });
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      await _showRecoveryFormForCurrentUser(client);
      return;
    }

    // Supabase's PKCE recovery links contain only `code` — the `type=recovery`
    // marker lives in the code verifier, which gotrue consumes before this
    // screen opens. Watch the auth event it emits so a reset link shows the
    // password form instead of the generic verification-success screen.
    if (client != null && _hasParam(params, frag, 'code')) {
      final isPasswordRecovery = await _waitForPasswordRecoveryEvent(client);
      if (!mounted) return;
      if (isPasswordRecovery) {
        setState(() {
          _isRecovery = true;
          _status = CallbackStatus.verifying;
        });
        await _showRecoveryFormForCurrentUser(client);
        return;
      }
    }

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

  bool _hasParam(Map<String, String> params, String fragment, String key) {
    return params.containsKey(key) ||
        _extractFromFragment(fragment, key) != null;
  }

  bool _hasParamValue(
    Map<String, String> params,
    String fragment,
    String key,
    String value,
  ) {
    return params[key] == value ||
        _extractFromFragment(fragment, key) == value;
  }

  /// PKCE recovery links expose only a `code`; gotrue remembers the intent via
  /// the stored code verifier and emits `passwordRecovery` when it exchanges
  /// the code. `onAuthStateChange` is a BehaviorSubject, so a late subscriber
  /// still sees that event.
  Future<bool> _waitForPasswordRecoveryEvent(
    supa.SupabaseClient client,
  ) async {
    final completer = Completer<bool>();
    final sub = client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == supa.AuthChangeEvent.passwordRecovery &&
            !completer.isCompleted) {
          completer.complete(true);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    try {
      return await completer.future.timeout(
        const Duration(milliseconds: 800),
        onTimeout: () => false,
      );
    } finally {
      await sub.cancel();
    }
  }

  Future<void> _showRecoveryFormForCurrentUser(
    supa.SupabaseClient client,
  ) async {
    final recoveryUser = client.auth.currentUser;
    if (recoveryUser == null) {
      setState(() {
        _status = CallbackStatus.error;
        _errorMessage = context.l10n.reset_password_failed;
      });
      return;
    }
    setState(() {
      _status = CallbackStatus.success;
      _verifiedEmail = recoveryUser.email;
    });
  }

  Future<void> _resendLink() async {
    final email = _resendEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.callback_enter_email_first,
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
    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? context.l10n.callback_resend_success
              : (ref.read(authProvider).errorMessage ??
                  context.l10n.callback_resend_failed),
          style: AppFonts.cairo(color: AppColors.textLight),
        ),
        backgroundColor: sent ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _saveNewPassword() async {
    final password = _newPasswordController.text;
    final confirmation = _confirmPasswordController.text;

    if (password.trim().isEmpty) {
      setState(() => _errorMessage = context.l10n.reset_password_empty);
      return;
    }
    if (password.length < 8) {
      setState(() => _errorMessage = context.l10n.reset_password_short);
      return;
    }
    if (password != confirmation) {
      setState(() => _errorMessage = context.l10n.reset_password_mismatch);
      return;
    }

    final client = SupabaseService.client;
    if (client == null) {
      setState(() => _errorMessage = context.l10n.reset_password_failed);
      return;
    }

    setState(() {
      _isSavingPassword = true;
      _errorMessage = null;
    });
    try {
      await client.auth.updateUser(
        supa.UserAttributes(password: password),
      );
      await client.auth.signOut();
      if (!mounted) return;
      setState(() {
        _isSavingPassword = false;
        _passwordSaved = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSavingPassword = false;
        _errorMessage = context.l10n.reset_password_failed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.callback_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsetsDirectional.fromSTEB(16, 20, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                color: colorScheme.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: AppColors.divider),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(24, 28, 24, 24),
                  child: _buildContent(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isRecovery && _status == CallbackStatus.success) {
      return _passwordSaved
          ? _buildRecoverySuccess(context)
          : _buildRecoveryForm(context);
    }
    switch (_status) {
      case CallbackStatus.verifying:
        return _buildVerifying(context);
      case CallbackStatus.success:
        return _buildSuccess(context);
      case CallbackStatus.expired:
      case CallbackStatus.error:
        return _buildProblem(context);
    }
  }

  Widget _statusBadge({
    required IconData icon,
    required Color fill,
    required Color ink,
  }) {
    return ExcludeSemantics(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
        child: Icon(icon, color: ink, size: 40),
      ),
    );
  }

  Widget _buildRecoveryForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusBadge(
          icon: Icons.lock_reset_rounded,
          fill: AppColors.primaryFill,
          ink: AppColors.primaryInk,
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.reset_password_title,
          style: AppFonts.cairo(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.reset_password_instructions,
          style: AppFonts.cairo(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (_verifiedEmail != null) ...[
          const SizedBox(height: 16),
          _emailChip(context, _verifiedEmail!),
        ],
        const SizedBox(height: 24),
        AuthField(
          label: context.l10n.reset_password_new,
          child: TextField(
            controller: _newPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ),
        const SizedBox(height: 16),
        AuthField(
          label: context.l10n.reset_password_confirm,
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_saveNewPassword()),
            decoration: const InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: AppFonts.cairo(
              fontSize: 12.5,
              color: AppColors.errorInk,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 24),
        AuthPrimaryButton(
          label: context.l10n.reset_password_save,
          icon: Icons.save_outlined,
          loading: _isSavingPassword,
          onPressed: _isSavingPassword
              ? null
              : () => unawaited(_saveNewPassword()),
        ),
      ],
    );
  }

  Widget _buildRecoverySuccess(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _statusBadge(
          icon: Icons.check_circle_rounded,
          fill: AppColors.successFill,
          ink: AppColors.successInk,
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.reset_password_success,
          style: AppFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        AuthPrimaryButton(
          label: context.l10n.reset_password_continue,
          icon: Icons.login,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }

  Widget _buildVerifying(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        Semantics(
          label: context.l10n.callback_verifying,
          child: SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primaryInk,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.callback_verifying,
          style: AppFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.callback_waiting,
          style: AppFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final target = widget.queryParams?['redirectTo'];
    final hasTarget = target != null && target.isNotEmpty && target != '/';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _statusBadge(
          icon: Icons.check_circle_rounded,
          fill: AppColors.successFill,
          ink: AppColors.successInk,
        ),
        const SizedBox(height: 20),
        Text(
          context.l10n.callback_success_title,
          style: AppFonts.cairo(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Text(
          context.l10n.callback_success_message,
          style: AppFonts.cairo(
            fontSize: 13.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        if (_verifiedEmail != null) ...[
          const SizedBox(height: 18),
          _emailChip(context, _verifiedEmail!),
        ],
        const SizedBox(height: 28),
        AuthPrimaryButton(
          label: hasTarget
              ? context.l10n.callback_continue_operation
              : context.l10n.callback_continue_home,
          icon: hasTarget ? Icons.arrow_forward : Icons.home_outlined,
          onPressed: () => context.go(hasTarget ? target : '/'),
        ),
        const SizedBox(height: 10),
        AuthSecondaryButton(
          label: hasTarget
              ? context.l10n.callback_go_home
              : context.l10n.sh_nav_my_properties,
          icon: hasTarget ? Icons.home_outlined : Icons.apartment_outlined,
          onPressed: () => context.go(hasTarget ? '/' : '/my-properties'),
        ),
      ],
    );
  }

  Widget _emailChip(BuildContext context, String email) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.primaryFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryInk.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.email_outlined, size: 18, color: AppColors.primaryInk),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              email,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryInk,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProblem(BuildContext context) {
    final isExpired = _status == CallbackStatus.expired;
    final fill = isExpired ? AppColors.warningFill : AppColors.errorFill;
    final ink = isExpired ? AppColors.warningInk : AppColors.errorInk;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _statusBadge(
          icon: isExpired ? Icons.schedule_outlined : Icons.error_outline,
          fill: fill,
          ink: ink,
        ),
        const SizedBox(height: 20),
        Text(
          isExpired
              ? context.l10n.callback_expired_title
              : context.l10n.callback_cannot_confirm,
          style: AppFonts.cairo(
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
                  ? context.l10n.callback_expired_fallback
                  : context.l10n.callback_error_fallback),
          style: AppFonts.cairo(
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
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _resendLink(),
          decoration: InputDecoration(
            labelText: context.l10n.callback_resend_email_label,
            labelStyle: AppFonts.cairo(fontSize: 12.5),
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: AppColors.surfaceVariant,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primaryInk, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        AuthPrimaryButton(
          label: context.l10n.callback_send_new_link,
          icon: Icons.send_rounded,
          loading: _isResending,
          onPressed: _resendLink,
        ),
        const SizedBox(height: 10),
        AuthSecondaryButton(
          label: context.l10n.callback_back_login,
          icon: Icons.login,
          onPressed: () => context.go('/login'),
        ),
      ],
    );
  }
}
