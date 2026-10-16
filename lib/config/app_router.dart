import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/admin/presentation/admin_dashboard_screen.dart';
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
import '../features/search/presentation/search_screen.dart';
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
  ],
);
