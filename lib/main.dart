import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

  // All typography uses the bundled variable Cairo font via AppFonts. Fail fast
  // instead of silently downloading a font if a future screen forgets to use it.
  GoogleFonts.config.allowRuntimeFetching = false;

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

  /// معالجة الضغط على زر الرجوع (Back) من نخبة التطبيق.
  ///
  /// المسار: نظام التشغيل → الـ engine → WidgetsBinding.handlePopRoute →
  /// هذه المستخدمة هنا أولاً (قبل المسارات الأخرى المتاحة للـ dispatcher) →
  /// إذا عُدِمنا الـ handling هنا، تستمر التسلسلات الأخرى (WidgetsApp /
  /// GoRouter BackButtonDispatcher / Navigator) وقد تصل إلى
  /// SystemNavigator.pop() وتُخرج التطبيق بدل معالجة مسارياً.
  ///
  /// تُستدعى هذه الطريقة عند كل ظهور لـ back؛ نعالج عبر السياسة المشتركة
  /// `appBackPress` (إغلاق overlay/عودة تاريخ/سياسة خروج الجذرة) ونثبت
  /// المعالجة هنا (نرجع `true`) حتى لا يُترك الظهور للـ default.
  @override
  Future<bool> didPopRoute() async {
    final nav = rootNavigatorKey.currentState;
    String currentLocation = '/';
    try {
      currentLocation = appRouter.routerDelegate.currentConfiguration.uri
          .toString();
    } catch (_) {}
    final result = await appBackPress(
      currentLocation: currentLocation,
      nav: nav,
      navigationHistory: appBackNavigationHistory,
      context: context,
      lastBackPressTime: appLastBackPressTime,
    );
    final handled = result.handled;
    final newLastBackPressTime = result.lastBackPressTime;
    appLastBackPressTime = newLastBackPressTime;
    return handled;
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
      title: AppLocale.isArabic
          ? AppConstants.appNameAr
          : AppConstants.appNameEn,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // Routing
      routeInformationProvider: appRouter.routeInformationProvider,
      routeInformationParser: appRouter.routeInformationParser,
      routerDelegate: appRouter.routerDelegate,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(settings.textScaleFactor)),
        child: GlobalAppBackHandler(
          child: GestureDetector(
            // Tap anywhere outside the focused field (and on non-interactive
            // surfaces) dismisses the keyboard — standard mobile behaviour.
            // Only receive taps that no interactive child (e.g. a TextField)
            // consumed. `translucent` also fired for taps *on* fields, so
            // focusing the bottom register fields instantly unfocused them and
            // hid the keyboard.
            behavior: HitTestBehavior.deferToChild,
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: FocusTraversalGroup(
              // Explicit reading-order traversal gives web/desktop keyboard
              // users a deterministic tab order through every route.
              policy: ReadingOrderTraversalPolicy(),
              child: child ?? const SizedBox.shrink(),
            ),
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
