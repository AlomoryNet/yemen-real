import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../providers/auth_provider.dart';
import 'app_logo.dart';

class AppHeader extends ConsumerWidget implements PreferredSizeWidget {
  const AppHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              // Logo
              InkWell(
                onTap: () => context.go('/'),
                borderRadius: BorderRadius.circular(8),
                child: const AppLogo(size: 38),
              ),

              const Spacer(),

              // Desktop Navigation Links
              if (isDesktop) ...[
                _buildNavLink(context, 'الرئيسية', '/'),
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
                const SizedBox(width: 16),
              ],

              // Add Property Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add_home_outlined, size: 18),
                label: Text(
                  'أضف عقارك',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                onPressed: () {
                  if (!authState.isAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'يرجى تسجيل الدخول أو إنشاء حساب لنشر عقارك',
                          style: GoogleFonts.cairo(),
                        ),
                        action: SnackBarAction(
                          label: 'دخول',
                          onPressed: () => context.push('/login'),
                        ),
                      ),
                    );
                    context.push('/login');
                    return;
                  }
                  context.push('/add-property');
                },
              ),

              const SizedBox(width: 12),

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
