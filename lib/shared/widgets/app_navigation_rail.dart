import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

/// Persistent expanded navigation rail for desktop / large windows.
///
/// Replaces both the desktop header links and the drawer on expanded
/// breakpoints (Material 3 Expressive guidance: expanded rail > drawer for
/// desktop). Account access also lives here so the app bar never carries
/// auth actions.
class AppNavigationRail extends ConsumerWidget {
  const AppNavigationRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final destinations = <_RailItem>[
      _RailItem(
        context.l10n.sh_nav_home,
        Icons.home_outlined,
        Icons.home_rounded,
        '/',
      ),
      // One destination for the integrated search + map experience.
      // Search results and the floating map card both live inside /map, so a
      // second rail item was only duplicating the route and breaking the
      // selected-state calculation.
      _RailItem(
        context.l10n.sh_nav_search_map,
        Icons.explore_outlined,
        Icons.explore_rounded,
        '/map',
      ),
      _RailItem(
        context.l10n.sh_nav_favorites,
        Icons.favorite_border_rounded,
        Icons.favorite_rounded,
        '/favorites',
      ),
      _RailItem(
        context.l10n.sh_header_settings,
        Icons.settings_outlined,
        Icons.settings_rounded,
        '/settings',
      ),
      if (authState.isAuthenticated) ...[
        _RailItem(
          context.l10n.sh_rail_my_properties,
          Icons.apartment_outlined,
          Icons.apartment_rounded,
          '/my-properties',
        ),
        _RailItem(
          context.l10n.sh_drawer_saved_searches,
          Icons.bookmark_border,
          Icons.bookmark,
          '/saved-searches',
        ),
        _RailItem(
          context.l10n.sh_drawer_notifications,
          Icons.notifications_none_rounded,
          Icons.notifications_rounded,
          '/notifications',
        ),
        _RailItem(
          context.l10n.sh_drawer_my_requests,
          Icons.assignment_outlined,
          Icons.assignment_rounded,
          '/my-requests',
        ),
        _RailItem(
          context.l10n.sh_drawer_profile,
          Icons.person_outline_rounded,
          Icons.person_rounded,
          '/profile',
        ),
      ],
      if (authState.isAdmin)
        _RailItem(
          context.l10n.sh_rail_admin,
          Icons.admin_panel_settings_outlined,
          Icons.admin_panel_settings_rounded,
          '/admin',
        ),
    ];

    final route = GoRouterState.of(context).uri.path;
    var selectedIndex = 0;
    var bestMatchLength = -1;
    for (var i = 0; i < destinations.length; i++) {
      final destinationRoute = destinations[i].route;
      final matches =
          route == destinationRoute || route.startsWith('$destinationRoute/');
      if (matches && destinationRoute.length > bestMatchLength) {
        selectedIndex = i;
        bestMatchLength = destinationRoute.length;
      }
    }

    return NavigationRail(
      backgroundColor: AppColors.surface,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => context.go(destinations[index].route),
      extended: true,
      trailingAtBottom: true,
      selectedIconTheme: IconThemeData(color: AppColors.primaryInk),
      unselectedIconTheme: IconThemeData(color: AppColors.textSecondary),
      selectedLabelTextStyle: AppFonts.cairo(
        color: AppColors.primaryInk,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      unselectedLabelTextStyle: AppFonts.cairo(
        color: AppColors.textSecondary,
        fontSize: 12,
      ),
      destinations: [
        for (final item in destinations)
          NavigationRailDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.selectedIcon),
            label: Text(item.label),
          ),
      ],
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(height: 24),
          Divider(color: AppColors.divider),
          if (authState.isAuthenticated && user != null) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => context.push('/profile'),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      size: 20,
                      color: AppColors.primaryInk,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.fullName.split(' ').first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/');
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                context.l10n.sh_logout,
                style: AppFonts.cairo(fontSize: 12),
              ),
            ),
          ] else
            TextButton.icon(
              // Keep the current destination underneath so Android Back
              // returns here instead of treating Login as a new root.
              onPressed: () => context.push('/login'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryInk,
                alignment: AlignmentDirectional.centerStart,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              icon: const Icon(Icons.login_rounded, size: 18),
              label: Text(
                context.l10n.sh_rail_login,
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RailItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;

  const _RailItem(this.label, this.icon, this.selectedIcon, this.route);
}
