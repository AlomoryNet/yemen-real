import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart' hide AuthState;
import 'providers/locale_provider.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase backend service with graceful fallback
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: YemenRealEstateApp()));
}

class YemenRealEstateApp extends ConsumerStatefulWidget {
  const YemenRealEstateApp({super.key});

  @override
  ConsumerState<YemenRealEstateApp> createState() => _YemenRealEstateAppState();
}

class _YemenRealEstateAppState extends ConsumerState<YemenRealEstateApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for Supabase Deep Link & Email verification callbacks
    final client = SupabaseService.client;
    if (client != null) {
      _authSubscription = client.auth.onAuthStateChange.listen((data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn ||
            event == AuthChangeEvent.userUpdated ||
            event == AuthChangeEvent.tokenRefreshed) {
          ref.read(authProvider.notifier).loadCurrentUser();
        } else if (event == AuthChangeEvent.signedOut) {
          ref.read(authProvider.notifier).loadCurrentUser();
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: currentLocale.languageCode == 'ar'
          ? AppConstants.appNameAr
          : AppConstants.appNameEn,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,

      // Routing
      routerConfig: appRouter,

      // Localization
      locale: currentLocale,
      supportedLocales: const [
        Locale('ar', 'YE'),
        Locale('ar', ''),
        Locale('en', 'US'),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
