import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart'
    deferred as admin;
import '../features/auth/presentation/auth_callback_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/my_properties_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/properties/presentation/add_edit_property_screen.dart';
import '../features/properties/presentation/property_detail_screen.dart';
import '../features/property_requests/presentation/my_rental_requests_screen.dart';
import '../features/map/presentation/yemen_map_screen.dart' deferred as map;
import '../features/contracts/presentation/contract_preview_screen.dart';
import '../core/l10n/context_l10n.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme_scope.dart';
import '../features/map/presentation/map_screen_args.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/saved_searches/presentation/saved_searches_screen.dart';
import '../models/property.dart';
import '../shared/widgets/deferred_screen.dart';
import '../shared/widgets/empty_state_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// سجل تنقل التطبيق للرجوع (آخر مسار + المسارات السابقة التي زارتها).
final List<String> appBackNavigationHistory = <String>['/'];

/// آخر وقت الضغط على زر الرجوع (لمك الم الضغطين المتتاليين للخروج).
DateTime? appLastBackPressTime;

/// هل المسار المعطى إحدى شاشات التسجيل/الدخول/استعادة كلمة المرور؟
///
/// عند فتح هذه الشاشات من داخل التطبيق تُدفع فوق الشاشة الحالية (push)،
/// فيملك المعالج سجل حقيقياً يعود إليه. أما إذا كانت أول صفحة في التطبيق
/// (رابط مباشر/فتحة باردة) فلا يوجد ما يُ-pop، وتُعامل كجذرة: الضغط مرة
/// يُظهر تنبيه الخروج، والضغط مرتين متتاليتين يخرج من التطبيق.
bool isAuthFlowLocation(String location) {
  final path = location.split('?').first;
  return path == '/login' ||
      path == '/register' ||
      path == '/forgot-password' ||
      path == '/login-callback' ||
      path == '/auth-callback';
}

/// شريط تنبيه الخروج.
///
/// Flutter يعرّف الـ SnackBar كرسالة قصيرة تظهر أسفل الشاشة، ويضع
/// `SnackBarBehavior.fixed` عند الحافة السفلية (فوق شريط التنقل إن وُجد).
/// نستخدم `fixed` بلا `margin` هنا حتى لا يرتفع التنبيه إلى منتصف الشاشة
/// بسبب سلوك `floating`/هوامش إضافية.
SnackBar exitInfoSnackBar({required String message}) {
  return SnackBar(
    content: Text(
      message,
      textAlign: TextAlign.center,
      style: AppFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
    ),
    duration: const Duration(seconds: 2),
    backgroundColor: AppColors.primary,
    behavior: SnackBarBehavior.fixed,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

/// مركزية سياسة الرجوع (Back) عبر التطبيق.
///
/// تُستدعى من [GlobalAppBackHandler] (الذي يستمع عبر PopScope داخل الـ
/// MaterialApp) ومن مسار `WidgetsBindingObserver.didPopRoute` الخاص بواجهة
/// التطبيق، بحيث لا يلغي أي منهما الآخر المعالجة الافتراضية للـ back على
/// Android (والتي كانت تُخرج من التطبيق بدل معالجة مسارياً).
///
/// الخطوات:
/// 1. إغلاق الـ overlay/الشاشة المدعومة popup إن وُجدت.
/// 2. العودة خطوة واحدة للخلف عبر سجل التنقل للشاشات المدعومة.
/// 3. سياسة الخروج من الجذرة (أو شاشة دخول بلا سجل): تنبيه ثم خروج مزدوج.
///
/// يعيد `handled: true` دائماً لأن المُستدعٍ هو من يقرر كيف يُعالَج الـ back.
Future<({bool handled, DateTime? lastBackPressTime})> appBackPress({
  required String currentLocation,
  required NavigatorState? nav,
  required List<String> navigationHistory,
  required BuildContext context,
  required DateTime? lastBackPressTime,
}) async {
  final isAuthFlow = isAuthFlowLocation(currentLocation);
  final isRoot =
      currentLocation == '/' || currentLocation.isEmpty || isAuthFlow;
  // `canPop` is the reliable signal for a real Navigator stack: root has no
  // route to pop, while a pushed auth screen/dialog/bottom sheet always does.
  final canPopOverlay = nav != null && nav.canPop();
  if (canPopOverlay) {
    nav.pop();
    return (handled: true, lastBackPressTime: lastBackPressTime);
  }

  if (!isRoot) {
    final history = List<String>.from(navigationHistory);
    while (history.isNotEmpty && history.last == currentLocation) {
      history.removeLast();
    }
    if (history.isNotEmpty && history.last != currentLocation) {
      final target = history.removeLast();
      appRouter.go(target);
    } else {
      // العودة إلى الصفحة الرئيسية كخيار افتراضي آمن
      appRouter.go('/');
    }
    return (handled: true, lastBackPressTime: lastBackPressTime);
  }

  // الجذرة / شاشة دخول: تنبيه مرة واحدة، وخروج بتكرار الضغطين.
  final now = DateTime.now();
  final isDouble =
      lastBackPressTime != null &&
      now.difference(lastBackPressTime) < const Duration(seconds: 2);
  if (isDouble) {
    await SystemNavigator.pop();
    return (handled: true, lastBackPressTime: lastBackPressTime);
  }
  final ctx = rootNavigatorKey.currentContext ?? context;
  final messenger = ScaffoldMessenger.maybeOf(ctx);
  if (messenger != null) {
    messenger.removeCurrentSnackBar();
    messenger.showSnackBar(
      exitInfoSnackBar(message: ctx.l10n.sh_back_exit_snackbar),
    );
  }
  return (handled: true, lastBackPressTime: now);
}

/// Fade-through page used for bottom-nav / rail destinations.
///
/// Sliding in from the side would imply a hierarchical push, which is wrong
/// for peer tab destinations (Material 3 switches destinations with a fast
/// fade-through instead). Keeping this subtle avoids the "web page" feel.
CustomTransitionPage<void> _tabPage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: AppThemeScope(child: child),
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final fadeOut = CurvedAnimation(
        parent: secondaryAnimation,
        curve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: fade.drive(Tween<double>(begin: 0.25, end: 1)),
        child: FadeTransition(
          opacity: fadeOut.drive(Tween<double>(begin: 1, end: 0.25)),
          child: child,
        ),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.sh_router_not_found)),
    body: Center(
      child: EmptyStateView(
        icon: Icons.error_outline,
        title: context.l10n.sh_router_404_title,
        description: context.l10n.sh_router_404_description,
        actionText: context.l10n.sh_router_404_action,
        onAction: () => context.go('/'),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) =>
          _tabPage(context, state, const HomeScreen()),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      pageBuilder: (context, state) {
        final extra = state.extra;
        // Dashboard CTAs pass filter values; plain bool keeps the original
        // list/map entry behaviour (dashboard FAB / nearby section).
        return _tabPage(
          context,
          state,
          DeferredScreen(
            load: () async => map.loadLibrary(),
            builder: () => map.YemenMapScreen(
              initialListView: extra is MapScreenArgs
                  ? extra.initialListView
                  : (extra is bool ? extra : false),
              initialFilters: extra is MapScreenArgs ? extra : null,
            ),
            loadingText: context.l10n.sh_deferred_loading,
            errorText: context.l10n.sh_deferred_error,
            retryText: context.l10n.sh_deferred_retry,
          ),
        );
      },
    ),
    GoRoute(
      path: '/property/:id',
      name: 'property-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return AppThemeScope(child: PropertyDetailScreen(propertyId: id));
      },
    ),
    GoRoute(
      path: '/add-property',
      name: 'add-property',
      builder: (context, state) {
        final extra = state.extra;
        final prop = extra is Property ? extra : null;
        return AppThemeScope(
          child: AddEditPropertyScreen(propertyToEdit: prop),
        );
      },
    ),
    GoRoute(
      path: '/contract',
      name: 'contract',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Property) {
          return AppThemeScope(child: ContractPreviewScreen(property: extra));
        }
        return AppThemeScope(
          child: Scaffold(
            body: Center(child: Text(context.l10n.sh_router_select_property)),
          ),
        );
      },
    ),
    GoRoute(
      path: '/my-properties',
      name: 'my-properties',
      pageBuilder: (context, state) =>
          _tabPage(context, state, const MyPropertiesScreen()),
    ),
    GoRoute(
      path: '/my-requests',
      name: 'my-requests',
      builder: (context, state) =>
          AppThemeScope(child: const MyRentalRequestsScreen()),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) =>
          AppThemeScope(child: const FavoritesScreen()),
    ),
    GoRoute(
      path: '/saved-searches',
      name: 'saved-searches',
      builder: (context, state) =>
          AppThemeScope(child: const SavedSearchesScreen()),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) =>
          AppThemeScope(child: const NotificationsScreen()),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => AppThemeScope(child: const ProfileScreen()),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => AppThemeScope(child: const SettingsScreen()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => AppThemeScope(child: const LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => AppThemeScope(child: const RegisterScreen()),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) =>
          AppThemeScope(child: const ForgotPasswordScreen()),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => AppThemeScope(
        child: DeferredScreen(
          load: () async => admin.loadLibrary(),
          builder: () => admin.AdminDashboardScreen(),
          loadingText: context.l10n.sh_deferred_loading,
          errorText: context.l10n.sh_deferred_error,
          retryText: context.l10n.sh_deferred_retry,
        ),
      ),
    ),
    GoRoute(
      path: '/login-callback',
      name: 'login-callback',
      builder: (context, state) => AppThemeScope(
        child: AuthCallbackScreen(
          queryParams: state.uri.queryParameters,
          fragment: state.uri.fragment,
        ),
      ),
    ),
    GoRoute(
      path: '/auth-callback',
      name: 'auth-callback',
      builder: (context, state) => AppThemeScope(
        child: AuthCallbackScreen(
          queryParams: state.uri.queryParameters,
          fragment: state.uri.fragment,
        ),
      ),
    ),
  ],
);

/// معالج الرجوع العام للتطبيق (Global App Back Handler):
/// 1. من أي شاشة غير الرئيسية: الضغط مرة واحدة يعود خطوة واحدة إلى الخلف (أو للرئيسية).
/// 2. من الصفحة الرئيسية: الضغط مرة واحدة يُظهر تنبيه "اضغط مرة أخرى للخروج"، والضغط مرتين متتاليتين يخرج من التطبيق.
class GlobalAppBackHandler extends StatefulWidget {
  final Widget child;
  const GlobalAppBackHandler({super.key, required this.child});

  @override
  State<GlobalAppBackHandler> createState() => _GlobalAppBackHandlerState();
}

class _GlobalAppBackHandlerState extends State<GlobalAppBackHandler> {
  @override
  void initState() {
    super.initState();
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    try {
      final location = appRouter.routerDelegate.currentConfiguration.uri
          .toString();
      if (appBackNavigationHistory.isEmpty ||
          appBackNavigationHistory.last != location) {
        appBackNavigationHistory.add(location);
        if (appBackNavigationHistory.length > 40) {
          appBackNavigationHistory.removeAt(0);
        }
      }
    } catch (_) {}
  }

  Future<bool> _handleBackPress() async {
    final nav = rootNavigatorKey.currentState;

    // 1. التحقق من مسار الشاشة الحالية قبل أي محاولة pop، لأن pop على الجذر
    //    يغلق التطبيق مباشرة بدل إظهار تنبيه "اضغط مرة أخرى للخروج".
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBackPress();
      },
      child: widget.child,
    );
  }
}
