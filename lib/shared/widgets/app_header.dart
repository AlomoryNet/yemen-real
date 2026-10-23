import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import 'app_drawer.dart';
import 'app_logo.dart';
import 'auth_prompt_dialog.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 12 : 20,
            vertical: 8,
          ),
          child: Row(
            children: [
              // Drawer menu button on mobile
              if (!isDesktop)
                Builder(
                  builder: (scaffoldContext) => IconButton(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.primary,
                      size: 26,
                    ),
                    tooltip: 'القائمة الجانبية',
                    onPressed: () {
                      final scaffoldState = Scaffold.maybeOf(scaffoldContext);
                      if (scaffoldState != null && scaffoldState.hasDrawer) {
                        scaffoldState.openDrawer();
                      } else {
                        showModalBottomSheet(
                          context: scaffoldContext,
                          isScrollControlled: true,
                          builder: (ctx) => const AppDrawer(),
                        );
                      }
                    },
                  ),
                ),

              // Logo
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(8),
                child: AppLogo(size: isMobile ? 30 : 38, showText: !isMobile),
              ),

              // Desktop Navigation Links
              if (isDesktop) ...[
                const SizedBox(width: 18),
                _buildNavLink(context, 'الرئيسية', '/'),
                _buildNavLink(
                  context,
                  'خريطة اليمن',
                  '/map',
                  isHighlight: true,
                ),
                _buildNavLink(context, 'بحث العقارات', '/search'),
                _buildNavLink(context, 'المفضلة', '/favorites'),
                if (authState.isAuthenticated) ...[
                  _buildNavLink(context, 'عقاراتي', '/my-properties'),
                  _buildNavLink(context, 'طلبات الاستئجار', '/my-requests'),
                ],
                if (authState.isAdmin)
                  _buildNavLink(
                    context,
                    'لوحة الإدارة',
                    '/admin',
                    isHighlight: true,
                  ),
                const SizedBox(width: 8),
              ],

              // Clean Spacer that pushes actions to the left in RTL
              const Spacer(),

              // Action Buttons: Yemen Map Button & Add Property Button side-by-side
              // 1. Yemen Map Button (Zillow / Portal Blue)
              ElevatedButton.icon(
                key: const ValueKey('header_map_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D6EFD), // Harmonious Royal Blue
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 14,
                    vertical: isMobile ? 6 : 10,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                icon: const Icon(Icons.map_rounded, size: 16),
                label: Text(
                  isMobile ? 'الخريطة' : 'الخريطة العقارية',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
                onPressed: () {
                  final currentUri = GoRouterState.of(context).uri.toString();
                  if (currentUri != '/map') {
                    context.push('/map');
                  }
                },
              ),
              SizedBox(width: isMobile ? 6 : 8),

              // 2. Add Property Button (Accent Orange)
              ElevatedButton.icon(
                key: const ValueKey('header_add_property_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 8 : 14,
                    vertical: isMobile ? 6 : 10,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 1,
                ),
                icon: const Icon(Icons.add_home_outlined, size: 16),
                label: Text(
                  isMobile ? 'إضافة' : 'أضف عقارك',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 12 : 13,
                  ),
                ),
                onPressed: () {
                  if (!authState.isAuthenticated) {
                    AuthPromptDialog.show(
                      context,
                      message:
                          'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
                      redirectTo: '/add-property',
                    );
                    return;
                  }
                  context.push('/add-property');
                },
              ),

              // Language Switcher (Desktop & Tablet only; mobile switches in Drawer to prevent header overflow)
              if (!isMobile) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () {
                    ref.read(localeProvider.notifier).toggleLocale();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.language,
                          size: 15,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          ref.watch(localeProvider).languageCode == 'ar'
                              ? 'EN'
                              : 'عربي',
                          style: GoogleFonts.cairo(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              SizedBox(width: isMobile ? 6 : 10),

              // Auth Profile / Login
              if (authState.isAuthenticated)
                PopupMenuButton<String>(
                  offset: const Offset(0, 48),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.account_circle,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          authState.user?.fullName.split(' ').first ?? 'حسابي',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person_outline, size: 18),
                          const SizedBox(width: 8),
                          Text('الملف الشخصي', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'my_properties',
                      child: Row(
                        children: [
                          const Icon(Icons.apartment_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('عقاراتي المعلنة', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'my_requests',
                      child: Row(
                        children: [
                          const Icon(Icons.assignment_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('طلبات الاستئجار', style: GoogleFonts.cairo()),
                        ],
                      ),
                    ),
                    if (authState.isAdmin)
                      PopupMenuItem(
                        value: 'admin',
                        child: Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 18,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'لوحة الإدارة',
                              style: GoogleFonts.cairo(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            size: 18,
                            color: AppColors.error,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.cairo(color: AppColors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case 'profile':
                        context.push('/profile');
                        break;
                      case 'my_properties':
                        context.push('/my-properties');
                        break;
                      case 'my_requests':
                        context.push('/my-requests');
                        break;
                      case 'admin':
                        context.push('/admin');
                        break;
                      case 'logout':
                        ref.read(authProvider.notifier).signOut();
                        context.go('/');
                        break;
                    }
                  },
                )
              else if (isMobile)
                IconButton(
                  tooltip: 'تسجيل الدخول',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  onPressed: () => context.push('/login'),
                )
              else
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'دخول / تسجيل',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () => context.push('/login'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavLink(
    BuildContext context,
    String title,
    String path, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: TextButton(
        onPressed: () => context.go(path),
        style: TextButton.styleFrom(
          foregroundColor: isHighlight
              ? AppColors.accentDark
              : AppColors.textPrimary,
        ),
        child: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
