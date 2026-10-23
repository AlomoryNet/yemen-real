import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_prompt_dialog.dart';

class AppBottomNavBar extends ConsumerWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  int _getIndex() {
    if (currentRoute == '/') return 0;                                           // الرئيسية
    if (currentRoute.startsWith('/search')) return 1;                           // البحث
    if (currentRoute.startsWith('/map')) return 2;                              // الخريطة
    if (currentRoute.startsWith('/my-properties')) return 3;                    // عقاراتي
    if (currentRoute.startsWith('/profile') || currentRoute.startsWith('/login')) return 4; // الدخول / حسابي
    return -1;
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
            color: Colors.black.withAlpha(14),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 0 — الرئيسية (أقصى اليمين في RTL)
              _NavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'الرئيسية',
                isSelected: currentIndex == 0,
                onTap: () {
                  if (currentIndex == 0) return;
                  context.go('/');
                },
              ),
              // 1 — البحث
              _NavItem(
                icon: Icons.search_rounded,
                selectedIcon: Icons.search_rounded,
                label: 'البحث',
                isSelected: currentIndex == 1,
                onTap: () {
                  if (currentIndex == 1) return;
                  context.go('/search');
                },
              ),
              // 2 — الخريطة (زر تفاعلي مميز في الوسط)
              _NavItemCenter(
                icon: Icons.map_rounded,
                label: 'الخريطة',
                isSelected: currentIndex == 2,
                onTap: () {
                  if (currentIndex == 2) return;
                  context.go('/map');
                },
              ),
              // 3 — عقاراتي
              _NavItem(
                icon: Icons.apartment_outlined,
                selectedIcon: Icons.apartment_rounded,
                label: 'عقاراتي',
                isSelected: currentIndex == 3,
                onTap: () {
                  if (currentIndex == 3) return;
                  if (!authState.isAuthenticated) {
                    AuthPromptDialog.show(
                      context,
                      message: 'لإدارة عقاراتك، يرجى تسجيل الدخول أولاً.',
                      redirectTo: '/my-properties',
                    );
                  } else {
                    context.go('/my-properties');
                  }
                },
              ),
              // 4 — الدخول / حسابي (أقصى اليسار في RTL)
              _NavItem(
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                label: authState.isAuthenticated ? 'حسابي' : 'الدخول',
                isSelected: currentIndex == 4,
                onTap: () {
                  if (currentIndex == 4) return;
                  if (!authState.isAuthenticated) {
                    context.go('/login');
                  } else {
                    context.go('/profile');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── زر تنقل عادي ─────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : const Color(0xFF94A3B8);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primaryMuted,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? selectedIcon : icon,
                key: ValueKey(isSelected),
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── زر الخريطة المميز في الوسط ───────────────────────────────────────────────
class _NavItemCenter extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemCenter({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primaryMuted,
                shape: BoxShape.circle,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(80),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
