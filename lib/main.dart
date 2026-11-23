import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_router.dart';
import 'core/constants/app_constants.dart';
import 'core/l10n/app_locale.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart' hide AuthState;
import 'providers/settings_provider.dart';
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

class _YemenRealEstateAppState extends ConsumerState<YemenRealEstateApp>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Keep the static `AppColors.isDark` mirror in sync when the OS brightness
  /// changes while `themeMode` is `system`. Without this, MaterialApp picks up
  /// the system theme but `AppColors.isDark` stays stale, leaving some screens
  /// stuck in the previous brightness.
  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    final settings = ref.read(settingsProvider);
    if (settings.themeMode == ThemeMode.system) {
      AppColors.isDark =
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    // Mirror locale for data-layer helpers that have no BuildContext.
    AppLocale.current = settings.locale;

    // Mirror the effective brightness so the semantic color tokens used by
    // screens (text, surfaces, dividers, teal ink) stay readable in dark mode.
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final effectiveBrightness = settings.themeMode == ThemeMode.system
        ? systemBrightness
        : (settings.themeMode == ThemeMode.dark
            ? Brightness.dark
            : Brightness.light);
    AppColors.isDark = effectiveBrightness == Brightness.dark;

    return MaterialApp.router(
      title: AppConstants.appNameAr,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // Routing
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      builder: (context, child) => GlobalAppBackHandler(
        child: GestureDetector(
          // Tap anywhere outside the focused field (and on non-interactive
          // surfaces) dismisses the keyboard — standard mobile behaviour.
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification) {
                FocusManager.instance.primaryFocus?.unfocus();
              }
              return false; // let other listeners (e.g. scroll controllers) see it
            },
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),

      // Localization — Arabic-first (Yemen), switchable at runtime from Settings.
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
