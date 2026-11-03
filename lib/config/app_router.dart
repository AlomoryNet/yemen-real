import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
import '../features/auth/presentation/auth_callback_screen.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/favorites/presentation/favorites_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/profile/presentation/my_properties_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/properties/presentation/add_edit_property_screen.dart';
import '../features/properties/presentation/property_detail_screen.dart';
import '../features/property_requests/presentation/my_rental_requests_screen.dart';
import '../features/map/presentation/yemen_map_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/contracts/presentation/contract_preview_screen.dart';
import '../models/property.dart';
import '../shared/widgets/empty_state_view.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('الصفحة غير موجودة')),
    body: Center(
      child: EmptyStateView(
        icon: Icons.error_outline,
        title: 'عفواً، الصفحة المطلوبة غير موجودة (404)',
        description: 'تأكد من صحة الرابط أو عد إلى الصفحة الرئيسية',
        actionText: 'العودة للرئيسية',
        onAction: () => context.go('/'),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/search',
      name: 'search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/map',
      name: 'map',
      builder: (context, state) => const YemenMapScreen(),
    ),
    GoRoute(
      path: '/property/:id',
      name: 'property-detail',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return PropertyDetailScreen(propertyId: id);
      },
    ),
    GoRoute(
      path: '/add-property',
      name: 'add-property',
      builder: (context, state) {
        final extra = state.extra;
        final prop = extra is Property ? extra : null;
        return AddEditPropertyScreen(propertyToEdit: prop);
      },
    ),
    GoRoute(
      path: '/contract',
      name: 'contract',
      builder: (context, state) {
        final extra = state.extra;
        if (extra is Property) {
          return ContractPreviewScreen(property: extra);
        }
        return const Scaffold(
          body: Center(child: Text('يرجى تحديد العقار أولاً')),
        );
      },
    ),
    GoRoute(
      path: '/my-properties',
      name: 'my-properties',
      builder: (context, state) => const MyPropertiesScreen(),
    ),
    GoRoute(
      path: '/my-requests',
      name: 'my-requests',
      builder: (context, state) => const MyRentalRequestsScreen(),
    ),
    GoRoute(
      path: '/favorites',
      name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
    ),
    GoRoute(
      path: '/login-callback',
      name: 'login-callback',
      builder: (context, state) => AuthCallbackScreen(
        queryParams: state.uri.queryParameters,
        fragment: state.uri.fragment,
      ),
    ),
    GoRoute(
      path: '/auth-callback',
      name: 'auth-callback',
      builder: (context, state) => AuthCallbackScreen(
        queryParams: state.uri.queryParameters,
        fragment: state.uri.fragment,
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

class _GlobalAppBackHandlerState extends State<GlobalAppBackHandler>
    with WidgetsBindingObserver {
  DateTime? _lastBackPressTime;
  final List<String> _navigationHistory = ['/'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouter.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    try {
      final location = appRouter.routerDelegate.currentConfiguration.uri.toString();
      if (_navigationHistory.isEmpty || _navigationHistory.last != location) {
        _navigationHistory.add(location);
        if (_navigationHistory.length > 40) {
          _navigationHistory.removeAt(0);
        }
      }
    } catch (_) {}
  }

  @override
  Future<bool> didPopRoute() async {
    return await _handleBackPress();
  }

  Future<bool> _handleBackPress() async {
    // 1. فحص ما إذا كان هناك ديالوج أو قائمة منبثقة أو صفحة تم فتحها بـ push يمكن الرجوع منها
    final nav = rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }

    // 2. التحقق من مسار الشاشة الحالية
    String currentLocation = '/';
    try {
      currentLocation = appRouter.routerDelegate.currentConfiguration.uri.toString();
    } catch (_) {}

    // 3. إذا لم تكن في الصفحة الرئيسية، ارجع خطوة واحدة إلى الخلف!
    if (currentLocation != '/' && currentLocation.isNotEmpty) {
      // إزالة المسار الحالي من سجل التنقل
      while (_navigationHistory.isNotEmpty &&
          _navigationHistory.last == currentLocation) {
        _navigationHistory.removeLast();
      }

      if (_navigationHistory.isNotEmpty && _navigationHistory.last != currentLocation) {
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
    final isDouble = _lastBackPressTime != null &&
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
              'اضغط مرة أخرى للخروج من التطبيق',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF134E4A),
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
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress();
      },
      child: widget.child,
    );
  }
}

/// موزع زر الرجوع الجذري للتطبيق (Root Back Button Dispatcher)
/// يعترض ضغطات زر الرجوع الصلبة والبرمجية من نظام أندرويد على مستوى نظام التشغيل
class AppRootBackButtonDispatcher extends RootBackButtonDispatcher {
  DateTime? _lastBackPressTime;
  final List<String> _history = ['/'];

  AppRootBackButtonDispatcher() {
    appRouter.routerDelegate.addListener(_onRouteChanged);
  }

  void _onRouteChanged() {
    try {
      final loc = appRouter.routerDelegate.currentConfiguration.uri.toString();
      if (_history.isEmpty || _history.last != loc) {
        _history.add(loc);
        if (_history.length > 50) _history.removeAt(0);
      }
    } catch (_) {}
  }

  @override
  Future<bool> didPopRoute() async {
    // 1. فحص وجود حوار منبثق أو شاشة فرعية يمكن إغلاقها بـ pop
    final nav = rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }

    // 2. فحص مسار الشاشة الحالية
    String loc = '/';
    try {
      loc = appRouter.routerDelegate.currentConfiguration.uri.toString();
    } catch (_) {}

    // 3. إذا لم تكن في الصفحة الرئيسية، عد خطوة واحدة إلى الخلف!
    if (loc != '/' && loc.isNotEmpty) {
      while (_history.isNotEmpty && _history.last == loc) {
        _history.removeLast();
      }
      if (_history.isNotEmpty && _history.last != loc) {
        final target = _history.removeLast();
        appRouter.go(target);
      } else {
        appRouter.go('/');
      }
      return true;
    }

    // 4. في الصفحة الرئيسية ('/'): ضغط مزدوج للخروج
    final now = DateTime.now();
    final isDouble = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2);

    if (isDouble) {
      await SystemNavigator.pop();
      return true;
    } else {
      _lastBackPressTime = now;
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        final messenger = ScaffoldMessenger.maybeOf(ctx);
        if (messenger != null) {
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                'اضغط مرة أخرى للخروج من التطبيق',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: const Color(0xFF134E4A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          );
        }
      }
      return true;
    }
  }
}

final AppRootBackButtonDispatcher appBackButtonDispatcher = AppRootBackButtonDispatcher();

