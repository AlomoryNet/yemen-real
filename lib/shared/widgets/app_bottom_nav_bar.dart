import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_prompt_dialog.dart';

class AppBottomNavBar extends ConsumerWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  int _getIndex() {
    if (currentRoute == '/') return 0;
    if (currentRoute.startsWith('/search')) return 1;
    if (currentRoute.startsWith('/map')) return 2;
    if (currentRoute.startsWith('/my-properties')) return 3;
    if (currentRoute.startsWith('/profile') || currentRoute.startsWith('/login')) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentIndex = _getIndex();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        border: const Border(
          top: BorderSide(color: AppColors.divider, width: 0.8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: NavigationBar(
          height: 64,
          elevation: 0,
          backgroundColor: Colors.white,
          selectedIndex: currentIndex,
          indicatorColor: const Color(0xFF0F766E).withAlpha(25),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (index) {
            if (index == currentIndex) return;

            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/search');
                break;
              case 2:
                context.go('/map');
                break;
              case 3:
                if (!authState.isAuthenticated) {
                  AuthPromptDialog.show(
                    context,
                    message:
                        'لإدارة وتصفح عقاراتك، يرجى تسجيل الدخول أو إنشاء حساب جديد أولاً.',
                    redirectTo: '/my-properties',
                  );
                } else {
                  context.go('/my-properties');
                }
                break;
              case 4:
                if (!authState.isAuthenticated) {
                  context.go('/login');
                } else {
                  context.go('/profile');
                }
                break;
            }
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(
                Icons.home_rounded,
                color: Color(0xFF0F766E),
              ),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: const Icon(Icons.search_rounded),
              selectedIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF0F766E),
              ),
              label: 'البحث',
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              selectedIcon: const Icon(
                Icons.map_rounded,
                color: Color(0xFF0F766E),
              ),
              label: 'الخريطة',
            ),
            NavigationDestination(
              icon: const Icon(Icons.apartment_outlined),
              selectedIcon: const Icon(
                Icons.apartment_rounded,
                color: Color(0xFF0F766E),
              ),
              label: 'عقاراتي',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(
                Icons.person_rounded,
                color: Color(0xFF0F766E),
              ),
              label: authState.isAuthenticated ? 'حسابي' : 'الدخول',
            ),
          ],
        ),
      ),
    );
  }
}
