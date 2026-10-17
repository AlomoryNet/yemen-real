import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'app_logo.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryDark,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Responsive(
                mobile: _buildMobileContent(context),
                desktop: _buildDesktopContent(context),
              ),
              const SizedBox(height: 32),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    AppConstants.copyrightNoticeAr,
                    style: GoogleFonts.cairo(
                      color: AppColors.accentLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'الجمهورية اليمنية',
                    style: GoogleFonts.cairo(
                      color: AppColors.textLight.withAlpha(200),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Column 1: Brand & Tagline
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppLogo(size: 38, isDark: true),
              const SizedBox(height: 14),
              Text(
                'المنصة الوطنية الرائدة لخدمات بيع وشراء وتأجير العقارات في كافة المحافظات اليمنية، بطرق موثوقة ومباشرة بين المعلن والباحث.',
                style: GoogleFonts.cairo(
                  color: AppColors.textLight.withAlpha(190),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        // Column 2: Quick Links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'روابط سريعة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFooterLink('عقارات للبيع'),
              _buildFooterLink('عقارات للإيجار'),
              _buildFooterLink('أضف إعلانك مجاناً'),
              _buildFooterLink('العقارات المميزة'),
            ],
          ),
        ),

        // Column 3: Legal & Trust
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الأمان والسياسات',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFooterLink('شروط الاستخدام'),
              _buildFooterLink('سياسة الخصوصية'),
              _buildFooterLink('آلية مراجعة ونشر الإعلانات'),
              _buildFooterLink('سياسة احتساب العمولة الإدارية'),
            ],
          ),
        ),

        // Column 4: Contact info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تواصل معنا',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.phone,
                    size: 16,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+967 770 000 000',
                    style: GoogleFonts.outfit(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: AppColors.accentLight,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'support@yemenrealestate.local',
                    style: GoogleFonts.outfit(
                      color: AppColors.textLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 36, isDark: true),
        const SizedBox(height: 12),
        Text(
          'بوابة اليمن العقارية — منصتك الموثوقة لاستئجار وشراء وبيع العقارات في اليمن.',
          style: GoogleFonts.cairo(
            color: AppColors.textLight.withAlpha(190),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildFooterLink('عقارات للبيع'),
            _buildFooterLink('عقارات للإيجار'),
            _buildFooterLink('الشروط والأحكام'),
            _buildFooterLink('سياسة الخصوصية'),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          color: AppColors.textLight.withAlpha(200),
          fontSize: 13,
        ),
      ),
    );
  }
}
