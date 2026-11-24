import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

class HomePublisherCta extends StatelessWidget {
  const HomePublisherCta({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Responsive(
        mobile: Column(
          children: [
            Text(
              context.l10n.dash_cta_title,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.dash_cta_desc_mobile,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: Text(
                    context.l10n.dash_yemen_map,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/map'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_home_outlined, size: 18),
                  label: Text(
                    context.l10n.dash_add_listing_now,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/add-property'),
                ),
              ],
            ),
          ],
        ),
        desktop: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dash_cta_title,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.l10n.dash_cta_desc_desktop,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.map_rounded),
                  label: Text(
                    context.l10n.dash_yemen_map,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/map'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.add_home_outlined),
                  label: Text(
                    context.l10n.dash_add_listing_now,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => context.push('/add-property'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}