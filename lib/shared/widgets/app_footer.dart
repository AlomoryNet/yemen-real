import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import 'app_logo.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    // Footer is desktop-only. On mobile/tablet the drawer + bottom nav carry
    // navigation, so the footer is hidden entirely (no dead space/links).
    if (!Responsive.isDesktop(context)) return const SizedBox.shrink();
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
                    context.l10n.admin_pdf_copyright,
                    style: AppFonts.cairo(
                      color: AppColors.accentLight,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    context.l10n.sh_footer_republic,
                    style: AppFonts.cairo(
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
                context.l10n.sh_footer_tagline_desktop,
                style: AppFonts.cairo(
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
                context.l10n.sh_footer_quick_links,
                style: AppFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFooterLink(
                context,
                context.l10n.sh_footer_properties_sale,
                '/map',
              ),
              _buildFooterLink(
                context,
                context.l10n.sh_footer_properties_rent,
                '/map',
              ),
              _buildFooterLink(
                context,
                context.l10n.sh_footer_add_listing,
                '/add-property',
              ),
              _buildFooterLink(
                context,
                context.l10n.sh_drawer_map_title,
                '/map',
              ),
            ],
          ),
        ),

        // Column 3: Account links
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sh_footer_my_account,
                style: AppFonts.cairo(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildFooterLink(context, context.l10n.sh_drawer_profile, '/profile'),
              _buildFooterLink(
                context,
                context.l10n.sh_footer_my_listings,
                '/my-properties',
              ),
              _buildFooterLink(
                context,
                context.l10n.sh_drawer_my_requests,
                '/my-requests',
              ),
              _buildFooterLink(
                context,
                context.l10n.sh_drawer_favorites,
                '/favorites',
              ),
            ],
          ),
        ),

        // Column 4: Contact info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.sh_footer_contact,
                style: AppFonts.cairo(
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
                    style: AppFonts.cairo(
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
                    style: AppFonts.cairo(
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
          context.l10n.sh_footer_tagline_mobile,
          style: AppFonts.cairo(
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
            _buildFooterLink(
              context,
              context.l10n.sh_footer_properties_sale,
              '/map',
            ),
            _buildFooterLink(
              context,
              context.l10n.sh_footer_properties_rent,
              '/map',
            ),
            _buildFooterLink(context, context.l10n.sh_drawer_map_title, '/map'),
            _buildFooterLink(
              context,
              context.l10n.sh_footer_my_account,
              '/profile',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooterLink(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Text(
            title,
            style: AppFonts.cairo(
              color: AppColors.textLight.withAlpha(220),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
