import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import '../core/constants/app_constants.dart';
import '../core/exceptions/app_exception.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';

class AuthRepository {
  final SupabaseClient? _client = SupabaseService.client;

  /// Check current active user profile
  Future<UserProfile?> getCurrentUser() async {
    if (EnvConfig.isDemoMode || _client == null) {
      return SupabaseService.demoCurrentUser;
    }

    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        return UserProfile.fromJson(data);
      }
      return UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ?? 'مستخدم',
        phone: user.userMetadata?['phone'] as String?,
        role: AppConstants.roleUser,
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
    if (EnvConfig.isDemoMode || _client == null) {
      if (email.contains('admin')) {
        SupabaseService.demoCurrentUser = UserProfile(
          id: 'demo-admin-1',
          fullName: 'مدير المنصة',
          phone: '+967770000000',
          role: AppConstants.roleSuperAdmin,
          isVerified: true,
          createdAt: DateTime.now(),
        );
      } else {
        SupabaseService.demoCurrentUser = UserProfile(
          id: 'demo-user-1',
          fullName: 'مستخدم تجريبي',
          phone: '+967771234567',
          role: AppConstants.roleUser,
          isVerified: true,
          createdAt: DateTime.now(),
        );
      }
      return SupabaseService.demoCurrentUser!;
    }

    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AppException('فشل تسجيل الدخول');
      }

      final profile = await getCurrentUser();
      return profile ??
          UserProfile(
            id: user.id,
            fullName: user.userMetadata?['full_name'] as String? ?? 'مستخدم',
            phone: user.userMetadata?['phone'] as String?,
            role: AppConstants.roleUser,
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
    if (EnvConfig.isDemoMode || _client == null) {
      SupabaseService.demoCurrentUser = UserProfile(
        id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        fullName: fullName,
        phone: phone,
        role: AppConstants.roleUser,
        isVerified: false,
        createdAt: DateTime.now(),
      );
      return SupabaseService.demoCurrentUser!;
    }

    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );

      final user = response.user;
      if (user == null) {
        throw AppException('فشل إنشاء الحساب');
      }

      // Profile is auto-created by trigger on auth.users in PostgreSQL
      return UserProfile(
        id: user.id,
        fullName: fullName,
        phone: phone,
        role: AppConstants.roleUser,
        isVerified: false,
        createdAt: DateTime.now(),
      );
    } catch (e) {
      throw AppException.fromSupabase(e);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    if (EnvConfig.isDemoMode || _client == null) {
      SupabaseService.demoCurrentUser = null;
      return;
    }
    await _client.auth.signOut();
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    if (EnvConfig.isDemoMode || _client == null) {
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
    if (EnvConfig.isDemoMode || _client == null) {
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
