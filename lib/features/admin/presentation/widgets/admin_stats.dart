import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../repositories/admin_repository.dart';

class AdminStatsGrid extends StatelessWidget {
  const AdminStatsGrid({super.key, required this.stats});

  final AdminDashboardStats stats;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.8,
          children: [
            AdminStatCard(
              context.l10n.admin_total_properties,
              '${stats.totalProperties}',
              Icons.apartment,
              AppColors.primary,
            ),
            AdminStatCard(
              context.l10n.admin_published_properties,
              '${stats.publishedProperties}',
              Icons.check_circle_outline,
              AppColors.success,
            ),
            AdminStatCard(
              context.l10n.admin_pending_review,
              '${stats.pendingProperties}',
              Icons.rate_review_outlined,
              Colors.amber.shade800,
            ),
            AdminStatCard(
              context.l10n.admin_total_users,
              '${stats.totalUsers}',
              Icons.people_outline,
              AppColors.primaryDark,
            ),
            AdminStatCard(
              context.l10n.admin_commission_records,
              '${stats.totalCommissions}',
              Icons.receipt_long,
              AppColors.accent,
            ),
          ],
        );
      },
    );
  }
}

class AdminStatCard extends StatelessWidget {
  const AdminStatCard(
    this.title,
    this.value,
    this.icon,
    this.color, {
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
