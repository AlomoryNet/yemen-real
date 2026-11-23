import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_prompt_dialog.dart';

/// Material 3 Expressive bottom navigation bar:
/// - 2 tabs: الرئيسية (Dashboard) + ممتلكاتي (My Properties)
/// - 72dp tall tonal surface, no hairline shadow
/// - Pill-shaped active indicator (64×32) that stretches in, filled icons
/// - Always-visible labels
class AppBottomNavBar extends ConsumerWidget {
  final String currentRoute;

  const AppBottomNavBar({super.key, required this.currentRoute});

  int _getIndex() {
    if (currentRoute == '/' || currentRoute.startsWith('/map')) {
      return 0; // الرئيسية (dashboard is the landing tab)
    }
    if (currentRoute.startsWith('/my-properties')) return 1; // عقاراتي
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentIndex = _getIndex();

    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              Expanded(
                child: _NavDestination(
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: context.l10n.sh_nav_home,
                  isSelected: currentIndex == 0,
                  onTap: () => _go(context, currentIndex, 0, '/'),
                ),
              ),
              Expanded(
                child: _NavDestination(
                  icon: Icons.apartment_outlined,
                  selectedIcon: Icons.apartment_rounded,
                  label: context.l10n.sh_nav_my_properties,
                  isSelected: currentIndex == 1,
                  onTap: () {
                    if (currentIndex == 1) return;
                    if (!authState.isAuthenticated) {
                      AuthPromptDialog.show(
                        context,
                        message: context.l10n.sh_manage_properties_prompt,
                        redirectTo: '/my-properties',
                      );
                    } else {
                      context.go('/my-properties');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, int currentIndex, int target, String route) {
    if (currentIndex == target) return;
    context.go(route);
  }
}

class _NavDestination extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark;
    final activeColor = AppColors.primaryInk; // bright teal in dark mode
    final inactiveColor = isDark
        ? AppColors.textMuted // lighter muted gray on dark surface
        : const Color(0xFF667085);
    final pillFill = isDark
        ? AppColors.primaryMuted.withAlpha(120) // lighter in dark
        : AppColors.primaryMuted;

    return InkResponse(
      onTap: onTap,
      radius: 34,
      splashColor: AppColors.primaryMuted.withAlpha(160),
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // M3 Expressive pill indicator — stretches horizontally when active
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: isSelected ? 62 : 34,
            height: 32,
            decoration: BoxDecoration(
              color: isSelected ? pillFill : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: 23,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
