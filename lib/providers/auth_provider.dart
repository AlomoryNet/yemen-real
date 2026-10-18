import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/exceptions/app_exception.dart';
import '../models/user_profile.dart';
import '../repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? errorMessage;
  final String? errorCode;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.errorCode,
  });

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.isAdmin ?? false;

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    String? errorCode,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState(isLoading: true)) {
    loadCurrentUser();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.getCurrentUser();
      state = state.copyWith(user: user, isLoading: false, clearError: true);
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
        errorCode: appEx.code,
      );
    }
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signIn(email: email, password: password);
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
        errorCode: appEx.code,
        clearUser: true,
      );
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _repository.signUp(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );
      // If user requires confirmation, do NOT establish an authenticated session
      if (user.isVerified) {
        state = state.copyWith(user: user, isLoading: false, clearError: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          clearUser: true,
          clearError: true,
        );
      }
      return true;
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
        errorCode: appEx.code,
      );
      return false;
    }
  }

  Future<bool> resendConfirmationEmail(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resendConfirmationEmail(email);
      state = state.copyWith(isLoading: false, clearError: true);
      return true;
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
        errorCode: appEx.code,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _repository.signOut();
    state = AuthState(user: null, isLoading: false);
  }

  Future<bool> updateProfile({
    required String fullName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (state.user == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updated = await _repository.updateProfile(
        userId: state.user!.id,
        fullName: fullName,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      state = state.copyWith(user: updated, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        isLoading: false,
        errorMessage: appEx.message,
        errorCode: appEx.code,
      );
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(clearError: true);
    try {
      await _repository.sendPasswordReset(email);
      return true;
    } catch (e) {
      final appEx = e is AppException ? e : AppException.fromSupabase(e);
      state = state.copyWith(
        errorMessage: appEx.message,
        errorCode: appEx.code,
      );
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
