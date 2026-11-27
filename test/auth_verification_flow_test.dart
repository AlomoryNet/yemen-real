import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import 'package:yemen_real_estate_portal/config/app_config.dart';
import 'package:yemen_real_estate_portal/core/exceptions/app_exception.dart';
import 'package:yemen_real_estate_portal/features/auth/presentation/auth_callback_screen.dart';
import 'package:yemen_real_estate_portal/models/user_profile.dart';
import 'package:yemen_real_estate_portal/providers/auth_provider.dart';
import 'package:yemen_real_estate_portal/repositories/auth_repository.dart';
import 'package:yemen_real_estate_portal/shared/widgets/auth_prompt_dialog.dart';

void main() {
  setUp(() {
    AppConfig.setForceDemoModeForTesting(true);
  });

  group('1. AppException Supabase Error Distinction Tests', () {
    test(
      'Correctly identifies invalid credentials error without confusing with email',
      () {
        final authEx = const supa.AuthException(
          'Invalid login credentials',
          statusCode: '400',
        );
        final appEx = AppException.fromSupabase(authEx);

        expect(appEx.code, equals('invalid_credentials'));
        expect(appEx.message, contains('غير صحيحة'));
        expect(
          appEx.message,
          equals('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
        );
      },
    );

    test(
      'Correctly identifies unconfirmed email error with email_not_confirmed code',
      () {
        final authEx = const supa.AuthException(
          'Email not confirmed',
          statusCode: '400',
        );
        final appEx = AppException.fromSupabase(authEx);

        expect(appEx.code, equals('email_not_confirmed'));
        expect(appEx.message, contains('لم يتم تأكيده'));
      },
    );

    test('Correctly identifies expired or already used OTP link', () {
      final authEx = const supa.AuthException(
        'Email link is invalid or has expired',
        statusCode: '403',
      );
      final appEx = AppException.fromSupabase(authEx);

      expect(appEx.code, equals('link_expired'));
      expect(appEx.message, contains('منتهي الصلاحية'));
    });

    test('Correctly identifies duplicate user registration error', () {
      final authEx = const supa.AuthException(
        'User already registered',
        statusCode: '422',
      );
      final appEx = AppException.fromSupabase(authEx);

      expect(appEx.code, equals('user_already_exists'));
      expect(appEx.message, contains('مسجل بالفعل'));
    });

    test('Correctly identifies rate limit error', () {
      final authEx = const supa.AuthException(
        'over_email_send_rate_limit: email rate limit exceeded',
        statusCode: '429',
      );
      final appEx = AppException.fromSupabase(authEx);

      expect(appEx.code, equals('rate_limit'));
      expect(appEx.message, contains('الانتظار'));
    });

    test('Correctly identifies connection/network failure error', () {
      final error = Exception(
        'Failed host lookup: https://<supabase-project>.supabase.co connection refused',
      );
      final appEx = AppException.fromSupabase(error);

      expect(appEx.code, equals('network_error'));
      expect(appEx.message, contains('تعذر الاتصال بالخادم'));
    });
  });

  group('2. Registration & Email Verification Lifecycle Tests', () {
    final repo = AuthRepository();

    test('Mobile deep link redirect URL is formatted correctly', () {
      final url = AuthRepository.getEmailRedirectUrl();
      expect(url, equals('yemenreal://login-callback'));
    });

    test(
      'signUp creates unverified user and prevents establishing active session',
      () async {
        final uniqueEmail =
            'test.verify.${DateTime.now().microsecondsSinceEpoch}@example.com';
        final user = await repo.signUp(
          email: uniqueEmail,
          password: 'Password123!',
          fullName: 'مستخدم تجريبي جديد',
          phone: '+967771122334',
        );

        expect(user.email, equals(uniqueEmail));
        expect(user.isVerified, isFalse);

        // Verify unverified user cannot log in
        expect(
          () async =>
              await repo.signIn(email: uniqueEmail, password: 'Password123!'),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              equals('email_not_confirmed'),
            ),
          ),
        );
      },
    );

    test(
      'signUp prevents creating duplicate accounts with existing email',
      () async {
        const email = 'existing.user@example.com';
        await repo.signUp(
          email: email,
          password: 'Password123!',
          fullName: 'مستخدم موجود',
          phone: '+967771122334',
        );

        // Attempting to register again with same email must fail with user_already_exists
        expect(
          () async => await repo.signUp(
            email: email,
            password: 'Password123!',
            fullName: 'مستخدم مكرر',
            phone: '+967771122334',
          ),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              equals('user_already_exists'),
            ),
          ),
        );
      },
    );

    test('User can sign in successfully once email is verified', () async {
      final email =
          'verified.user.${DateTime.now().microsecondsSinceEpoch}@example.com';
      await repo.signUp(
        email: email,
        password: 'SecurePassword123!',
        fullName: 'مستخدم مؤكد',
        phone: '+967771122999',
      );

      // Simulate email verification callback
      await repo.verifyUserEmail(email);

      // Now sign in should succeed
      final user = await repo.signIn(
        email: email,
        password: 'SecurePassword123!',
      );
      expect(user.isVerified, isTrue);
      expect(user.email, equals(email));
    });

    test(
      'Resend confirmation email succeeds and throttles rapid repeated requests',
      () async {
        const email = 'cooldown.user@example.com';

        // First call should succeed
        await repo.resendConfirmationEmail(email);

        // Immediate second call should be caught by rate limiting cooldown
        expect(
          () async => await repo.resendConfirmationEmail(email),
          throwsA(
            isA<AppException>().having(
              (e) => e.code,
              'code',
              equals('rate_limit'),
            ),
          ),
        );
      },
    );
  });

  group('3. AuthState & Error Code Handling Tests', () {
    test('AuthState carries errorCode properly and distinguishes errors', () {
      final state = AuthState(
        isLoading: false,
        errorMessage: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        errorCode: 'invalid_credentials',
      );

      expect(state.errorCode, equals('invalid_credentials'));
      expect(state.errorMessage, contains('غير صحيحة'));

      final unconfirmedState = state.copyWith(
        errorMessage: 'البريد الإلكتروني لم يتم تأكيده بعد.',
        errorCode: 'email_not_confirmed',
      );

      expect(unconfirmedState.errorCode, equals('email_not_confirmed'));
    });
  });

  group('4. AuthCallbackScreen Deep Link UI Tests', () {
    testWidgets('Renders success screen when email verification is confirmed', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: AuthCallbackScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('تأكيد البريد الإلكتروني'), findsOneWidget);
      expect(find.text('تم تفعيل بريدك الإلكتروني بنجاح!'), findsOneWidget);
      expect(find.text('المتابعة إلى الصفحة الرئيسية'), findsOneWidget);
      expect(find.text('ممتلكاتي'), findsOneWidget);
      expect(find.text('تسجيل الدخول بالبريد وكلمة المرور'), findsNothing);
    });

    testWidgets(
      'Renders success screen with redirectTo target button when redirectTo is passed',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: AuthCallbackScreen(
                queryParams: {'redirectTo': '/add-property'},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('تأكيد البريد الإلكتروني'), findsOneWidget);
        expect(find.text('تم تفعيل بريدك الإلكتروني بنجاح!'), findsOneWidget);
        expect(find.text('المتابعة لإكمال عمليتك'), findsOneWidget);
        expect(find.text('الذهاب إلى الصفحة الرئيسية'), findsOneWidget);
      },
    );

    testWidgets(
      'Renders expired link state when otp_expired error query param is received',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: Locale('ar', 'YE'), home: AuthCallbackScreen(
                queryParams: {'error_code': 'otp_expired'},
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('تأكيد البريد الإلكتروني'), findsOneWidget);
        expect(
          find.text('رابط التفعيل منتهي أو مستخدم مسبقاً'),
          findsOneWidget,
        );
        expect(find.text('إرسال رابط تفعيل جديد'), findsOneWidget);
        expect(find.text('العودة إلى صفحة تسجيل الدخول'), findsOneWidget);
      },
    );
  });

  group('5. Guest Mode & AuthPromptDialog Verification Tests', () {
    testWidgets(
      'AuthPromptDialog displays exact required Arabic message and action buttons',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: const Locale('ar', 'YE'), home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AuthPromptDialog.show(
                  context,
                  message:
                      'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
                  redirectTo: '/add-property',
                ),
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('تسجيل الدخول مطلوب'), findsOneWidget);
        expect(
          find.text(
            'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
          ),
          findsOneWidget,
        );
        expect(find.text('إنشاء حساب جديد'), findsOneWidget);
        expect(find.text('تسجيل الدخول'), findsOneWidget);
        expect(find.text('متابعة التصفح كزائر'), findsOneWidget);
      },
    );

    test('Guest is unauthenticated by default and has no admin privileges', () {
      final guestState = AuthState(user: null);
      expect(guestState.isAuthenticated, isFalse);
      expect(guestState.isAdmin, isFalse);
    });

    test(
      'Admin role is restricted strictly to users with admin/super_admin role',
      () {
        final regularUser = AuthState(
          user: UserProfile(
            id: 'user-1',
            fullName: 'مستخدم عادي',
            role: 'user',
            isVerified: true,
            createdAt: DateTime.now(),
          ),
        );
        expect(regularUser.isAuthenticated, isTrue);
        expect(regularUser.isAdmin, isFalse);

        final adminUser = AuthState(
          user: UserProfile(
            id: 'admin-1',
            fullName: 'مسؤول النظام',
            role: 'super_admin',
            isVerified: true,
            createdAt: DateTime.now(),
          ),
        );
        expect(adminUser.isAuthenticated, isTrue);
        expect(adminUser.isAdmin, isTrue);
      },
    );
  });
}

