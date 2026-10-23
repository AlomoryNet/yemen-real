import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

/// Last back-press time — used for double-back-to-exit on home
DateTime? _lastBackPress;

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
      builder: (context, state) => const _BackHandlerWrapper(child: HomeScreen()),
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

/// يلتف حول الصفحة الرئيسية لمنع الخروج عند ضغطة رجوع واحدة.
/// الضغطة الأولى: snackbar "اضغط مرة أخرى للخروج"
/// الضغطة الثانية خلال ثانيتين: خروج فعلي
class _BackHandlerWrapper extends StatelessWidget {
  final Widget child;
  const _BackHandlerWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final now = DateTime.now();
        final isDouble = _lastBackPress != null &&
            now.difference(_lastBackPress!) < const Duration(seconds: 2);
        if (isDouble) {
          // خروج فعلي
          // ignore: deprecated_member_use
          await Future.delayed(Duration.zero);
          if (context.mounted) {
            Navigator.of(rootNavigatorKey.currentContext!).pop();
          }
        } else {
          _lastBackPress = now;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text(
                  'اضغط مرة أخرى للخروج من التطبيق',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                duration: const Duration(seconds: 2),
                backgroundColor: const Color(0xFF134E4A),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        }
      },
      child: child,
    );
  }
}
