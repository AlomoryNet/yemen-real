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
import '../models/property.dart';
import '../shared/widgets/deferred_screen.dart';
import '../shared/widgets/empty_state_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

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
  DateTime? _lastBackPressTime;
  final List<String> _navigationHistory = ['/'];

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
      if (_navigationHistory.isEmpty || _navigationHistory.last != location) {
        _navigationHistory.add(location);
        if (_navigationHistory.length > 40) {
          _navigationHistory.removeAt(0);
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

    // 2. ديالوج/قائمة منبثقة فوق أي شاشة: تُغلق أولاً ولا يُلمس المسار.
    //    على الجذر لا نعتبر صفحة GoRouter نفسها قابلة للإغلاق.
    final isRoot = currentLocation == '/' || currentLocation.isEmpty;
    final canPopOverlay =
        nav != null && nav.canPop() && (!isRoot || nav.widget.pages.length > 1);
    if (canPopOverlay) {
      nav.pop();
      return true;
    }

    // 3. إذا لم تكن في الصفحة الرئيسية، ارجع خطوة واحدة إلى الخلف!
    if (!isRoot) {
      _lastBackPressTime = null;
      // إزالة المسار الحالي من سجل التنقل
      while (_navigationHistory.isNotEmpty &&
          _navigationHistory.last == currentLocation) {
        _navigationHistory.removeLast();
      }

      if (_navigationHistory.isNotEmpty &&
          _navigationHistory.last != currentLocation) {
        final target = _navigationHistory.removeLast();
        appRouter.go(target);
      } else {
        // العودة إلى الصفحة الرئيسية كخيار افتراضي آمن
        appRouter.go('/');
      }
      return true;
    }

    // 4. إذا كنت في الصفحة الرئيسية ('/')
    // الضغط مرة واحدة: إشعار
    // الضغط مرتين متتاليتين خلال ثانيتين: خروج من التطبيق
    final now = DateTime.now();
    final isDouble =
        _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);

    if (isDouble) {
      await SystemNavigator.pop();
      return true;
    } else {
      _lastBackPressTime = now;
      final ctx = rootNavigatorKey.currentContext ?? context;
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      if (messenger != null) {
        messenger.removeCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              ctx.l10n.sh_back_exit_snackbar,
              textAlign: TextAlign.center,
              style: AppFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        );
      }
      return true;
    }
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
