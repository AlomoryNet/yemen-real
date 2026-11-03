import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.apartment_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بوابة اليمن العقارية',
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user != null
                              ? (user.isAdmin ? 'لوحة تحكم المدير العام' : user.fullName)
                              : 'المنصة العقارية الأولى في اليمن',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            color: Colors.white.withAlpha(210),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Prominent Map Button (Special Highlighted Section)
            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                leading: const Icon(
                  Icons.map_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                title: Text(
                  'الخريطة العقارية',
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'بحث تفاعلي بالأسعار على خريطة اليمن',
                  style: GoogleFonts.cairo(
                    color: Colors.white.withAlpha(220),
                    fontSize: 11,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'تفاعلية 🇾🇪',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/map');
                },
              ),
            ),

            const Divider(height: 1),

            // Navigation Links
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerTile(
                    context,
                    icon: Icons.home_outlined,
                    title: 'الرئيسية',
                    route: '/',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.search_rounded,
                    title: 'البحث عن العقارات',
                    route: '/search',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.favorite_border_rounded,
                    title: 'العقارات المفضلة',
                    route: '/favorites',
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.add_home_outlined,
                    title: 'أضف عقارك مجاناً',
                    route: '/add-property',
                    color: AppColors.accent,
                  ),
                  _buildDrawerTile(
                    context,
                    icon: Icons.map_rounded,
                    title: 'خريطة اليمن العقارية',
                    route: '/map',
                    color: const Color(0xFF0D6EFD),
                  ),

                  if (authState.isAuthenticated) ...[
                    const Divider(height: 16),
                    _buildDrawerTile(
                      context,
                      icon: Icons.holiday_village_outlined,
                      title: 'عقاراتي المعروضة',
                      route: '/my-properties',
                    ),
                    _buildDrawerTile(
                      context,
                      icon: Icons.assignment_outlined,
                      title: 'طلبات الاستئجار',
                      route: '/my-requests',
                    ),
                    _buildDrawerTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'الملف الشخصي',
                      route: '/profile',
                    ),
                  ],

                  if (authState.isAdmin) ...[
                    const Divider(height: 16),
                    _buildDrawerTile(
                      context,
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'لوحة الإدارة الشاملة',
                      route: '/admin',
                      color: Colors.amber.shade800,
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Auth Action at Bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: authState.isAuthenticated
                  ? OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        'تسجيل الخروج',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
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
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.login, size: 18),
                      label: Text(
                        'تسجيل الدخول / إنشاء حساب',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/login');
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    Color? color,
  }) {
    final effectiveColor = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: effectiveColor, size: 22),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: effectiveColor,
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        context.push(route);
      },
    );
  }
}
