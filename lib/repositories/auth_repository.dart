import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../core/l10n/app_strings.dart';

class AuthRepository {
  final SupabaseClient? _client = SupabaseService.client;
  static DateTime? _lastResendTime;

  /// Dynamic email redirect URL based on platform
  static String getEmailRedirectUrl() {
    if (kIsWeb) {
      final origin = Uri.base.origin;
      return '$origin/login-callback';
    }
    return 'yemenreal://login-callback';
  }

  /// Check current active user profile
  Future<UserProfile?> getCurrentUser() async {
    if (AppConfig.isDemoMode || _client == null) {
      return SupabaseService.demoCurrentUser;
    }

    final user = _client.auth.currentUser;
    if (user == null) return null;
    // Unverified users are not considered to have an active authenticated session
    if (user.emailConfirmedAt == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }

      // If profile does not exist yet in DB, safely insert it once (upsert with DO NOTHING)
      final fullName = user.userMetadata?['full_name'] as String? ?? tr.misc_user;
      final phone = user.userMetadata?['phone'] as String?;
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'phone': phone,
          'role': AppConstants.roleUser,
        }, onConflict: 'id');
      } catch (_) {
        // Table trigger might have handled it concurrently
      }

      return UserProfile(
        id: user.id,
        fullName: fullName,
        phone: phone,
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Sign in with email and password
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (AppConfig.isDemoMode || _client == null) {
      if (cleanEmail == 'mo772522233@gmail.com' ||
          cleanEmail.contains('admin')) {
        SupabaseService.demoCurrentUser = UserProfile(
          id: 'admin-mohammed-saqqaf',
          fullName: 'م/محمد السقاف',
          email: 'mo772522233@gmail.com',
          phone: '+967772522233',
          role: AppConstants.roleSuperAdmin,
          isVerified: true,
          createdAt: DateTime.now(),
        );
        return SupabaseService.demoCurrentUser!;
      }

      final existing = SupabaseService.demoUsers
          .cast<UserProfile?>()
          .firstWhere(
            (u) => u?.email?.toLowerCase() == cleanEmail,
            orElse: () => null,
          );

      // Block unverified user from logging in
      if (existing != null && !existing.isVerified) {
        throw AppException(
          tr.sys_email_not_confirmed,
          code: 'email_not_confirmed',
        );
      }

      SupabaseService.demoCurrentUser =
          existing ??
          UserProfile(
            id: 'user-${DateTime.now().millisecondsSinceEpoch}',
            fullName: cleanEmail.split('@').first,
            email: cleanEmail,
            phone: '+967770000000',
            role: AppConstants.roleUser,
            isVerified: true,
            createdAt: DateTime.now(),
          );
      return SupabaseService.demoCurrentUser!;
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: cleanEmail,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AppException(tr.sys_login_failed, code: 'invalid_credentials');
      }

      // Enforce email confirmation check on Supabase response
      if (user.emailConfirmedAt == null) {
        await _client.auth.signOut();
        throw AppException(
          tr.sys_email_not_confirmed,
          code: 'email_not_confirmed',
        );
      }

      final profile = await getCurrentUser();
      if (profile != null) {
        return profile;
      }

      return UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ?? tr.misc_user,
        email: user.email ?? cleanEmail,
        phone: user.userMetadata?['phone'] as String?,
        role: AppConstants.roleUser,
        isVerified: true,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Register new user account
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (AppConfig.isDemoMode || _client == null) {
      final exists = SupabaseService.demoUsers.any(
        (u) => u.email?.toLowerCase() == cleanEmail,
      );
      if (exists) {
        throw AppException(
          tr.sys_user_exists,
          code: 'user_already_exists',
        );
      }

      final newUser = UserProfile(
        id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        email: cleanEmail,
        phone: phone,
        role: AppConstants.roleUser,
        isVerified: false, // Requires email confirmation
        createdAt: DateTime.now(),
      );
      SupabaseService.demoUsers.insert(0, newUser);
      // Strictly do NOT set as active authenticated user
      return newUser;
    }

    try {
      final redirectUrl = getEmailRedirectUrl();
      final response = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
        emailRedirectTo: redirectUrl,
      );

      final user = response.user;
      if (user == null) {
        throw AppException(tr.sys_signup_failed);
      }

      // Check if user already exists in Supabase (identities will be empty on duplicate signup)
      if (user.identities != null && user.identities!.isEmpty) {
        throw AppException(
          tr.sys_user_exists,
          code: 'user_already_exists',
        );
      }

      final isConfirmed = user.emailConfirmedAt != null;
      final newUser = UserProfile(
        id: user.id,
        fullName: fullName,
        email: user.email ?? cleanEmail,
        phone: phone,
        role: AppConstants.roleUser,
        isVerified: isConfirmed,
        createdAt: DateTime.now(),
      );
      return newUser;
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Resend confirmation email with cooldown throttling
  Future<void> resendConfirmationEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) {
      throw AppException(
        tr.sys_enter_email_first,
        code: 'invalid_email',
      );
    }

    if (_lastResendTime != null) {
      final diff = DateTime.now().difference(_lastResendTime!);
      if (diff.inSeconds < 60) {
        final remaining = 60 - diff.inSeconds;
        throw AppException(
          tr.sys_resend_wait(remaining),
          code: 'rate_limit',
        );
      }
    }

    if (AppConfig.isDemoMode || _client == null) {
      _lastResendTime = DateTime.now();
      return;
    }

    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: cleanEmail,
        emailRedirectTo: getEmailRedirectUrl(),
      );
      _lastResendTime = DateTime.now();
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Verify user email (for testing or direct verification callback)
  Future<void> verifyUserEmail(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (AppConfig.isDemoMode || _client == null) {
      final idx = SupabaseService.demoUsers.indexWhere(
        (u) => u.email?.toLowerCase() == cleanEmail,
      );
      if (idx != -1) {
        SupabaseService.demoUsers[idx] = SupabaseService.demoUsers[idx]
            .copyWith(isVerified: true);
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (AppConfig.isDemoMode || _client == null) {
      SupabaseService.demoCurrentUser = null;
      return;
    }
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    if (AppConfig.isDemoMode || _client == null) {
      return;
    }
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Update user profile
  Future<UserProfile> updateProfile({
    required String userId,
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (AppConfig.isDemoMode || _client == null) {
      if (SupabaseService.demoCurrentUser != null) {
        SupabaseService.demoCurrentUser = SupabaseService.demoCurrentUser!
            .copyWith(fullName: fullName, phone: phone, avatarUrl: avatarUrl);
      }
      return SupabaseService.demoCurrentUser!;
    }

    try {
      final data = await _client
          .from('profiles')
          .update({
            'full_name': fullName,
            'phone': phone,
            if (avatarUrl != null) 'avatar_url': avatarUrl,
          })
          .eq('id', userId)
          .select()
          .single();

      return UserProfile.fromJson(data);
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }
}
