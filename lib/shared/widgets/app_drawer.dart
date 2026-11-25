import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

/// M3-flavoured drawer: profile header with avatar, highlighted map card,
/// navigation tiles with tonal icon containers, prominent account action.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  /// Destinations that own the navigation stack. Opening one of these resets
  /// the stack to that root; Profile stays a pushed page with a back affordance.
  static const Set<String> rootRoutes = {
    '/',
    '/map',
    '/my-properties',
    '/admin',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final logoutColor = Theme.of(context).colorScheme.error;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile / Brand Header ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  // Avatar: user initials or brand mark
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.textLight.withAlpha(28),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.textLight.withAlpha(70),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: user != null
                          ? Text(
                              _initial(context, user.fullName),
                              style: AppFonts.cairo(
                                color: AppColors.textLight,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const Icon(
                              Icons.apartment_rounded,
                              color: AppColors.textLight,
                              size: 26,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user != null
                              ? user.fullName
                              : context.l10n.sh_brand_name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            color: AppColors.textLight,
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user != null
                              ? (user.isAdmin
                                    ? context.l10n.sh_drawer_admin_greeting
                                    : context.l10n.sh_drawer_user_greeting)
                              : context.l10n.sh_drawer_tagline,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            color: AppColors.textLight.withAlpha(205),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Navigation Tiles ───────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                children: [
                  _buildDrawerTile(
                    context,
                    icon: Icons.home_rounded,
                    tint: AppColors.primaryInk,
                    title: context.l10n.sh_nav_home,
                    route: '/',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.search_rounded,
                    tint: AppColors.infoInk,
                    title: context.l10n.sh_drawer_search,
                    route: '/map',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.favorite_rounded,
                    tint: AppColors.errorInk,
                    title: context.l10n.sh_drawer_favorites,
                    route: '/favorites',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.add_home_rounded,
                    tint: AppColors.accentInk,
                    title: context.l10n.sh_header_add_property_free,
                    route: '/add-property',
                  ),
                  if (authState.isAuthenticated) ...[
                    const SizedBox(height: 4),
                    Divider(color: AppColors.divider, height: 12),
                    _buildDrawerTile(
                      context,
                      icon: Icons.holiday_village_rounded,
                      tint: AppColors.successInk,
                      title: context.l10n.sh_drawer_my_properties,
                      route: '/my-properties',
                    ),
                    _buildDrawerTile(
                      context,
                      icon: Icons.assignment_rounded,
                      tint: AppColors.violetInk,
                      title: context.l10n.sh_drawer_my_requests,
                      route: '/my-requests',
                    ),
                    _buildDrawerTile(
                      context,
                      icon: Icons.person_rounded,
                      tint: AppColors.textSecondary,
                      title: context.l10n.sh_drawer_profile,
                      route: '/profile',
                    ),
                  ],
                  if (authState.isAdmin) ...[
                    const SizedBox(height: 4),
                    Divider(color: AppColors.divider, height: 12),
                    _buildDrawerTile(
                      context,
                      icon: Icons.admin_panel_settings_rounded,
                      tint: AppColors.warningInk,
                      title: context.l10n.sh_drawer_admin_panel,
                      route: '/admin',
                    ),
                  ],
                ],
              ),
            ),

            Divider(color: AppColors.divider, height: 1),

            // ── Account Action ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: authState.isAuthenticated
                        ? OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: logoutColor,
                              side: BorderSide(
                                color: logoutColor,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.logout_rounded, size: 19),
                            label: Text(
                              context.l10n.sh_logout,
                              style: AppFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () async {
                              Navigator.pop(context);
                              await ref.read(authProvider.notifier).signOut();
                              if (context.mounted) context.go('/');
                            },
                          )
                        : ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textLight,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.login_rounded, size: 19),
                            label: Text(
                              context.l10n.sh_login_register,
                              style: AppFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              context.go('/login');
                            },
                          ),
                  ),
                  // Settings sits below the account action for everyone:
                  // authenticated users see it under logout, guests under the
                  // login CTA (the header/search gear was removed by design).
                  const SizedBox(height: 4),
                  _buildDrawerTile(
                    context,
                    icon: Icons.settings_rounded,
                    tint: AppColors.textSecondary,
                    title: context.l10n.sh_header_settings,
                    route: '/settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initial(BuildContext context, String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return context.l10n.sh_drawer_initial_fallback;
    return trimmed.characters.first.toUpperCase();
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required Color tint,
    required String title,
    required String route,
  }) {
    final currentRoute = GoRouterState.of(context).uri.path;
    final selected =
        currentRoute == route ||
        (route != '/' && currentRoute.startsWith('$route/'));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: selected
            ? AppColors.primaryMuted.withAlpha(105)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context);
            if (rootRoutes.contains(route)) {
              context.go(route);
            } else {
              context.push(route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: tint.withAlpha(AppColors.isDark ? 56 : 26),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: tint, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      color: selected
                          ? AppColors.primaryInk
                          : AppColors.textPrimary,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_left_rounded,
                  color: selected ? AppColors.primaryInk : AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
