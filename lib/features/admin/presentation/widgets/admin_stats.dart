import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

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
          childAspectRatio: constraints.maxWidth < 600 ? 1.35 : 1.6,
          children: [
            AdminStatCard(
              context.l10n.admin_total_properties,
              '${stats.totalProperties}',
              Icons.apartment,
              AppColors.primaryInk,
            ),
            AdminStatCard(
              context.l10n.admin_published_properties,
              '${stats.publishedProperties}',
              Icons.check_circle_outline,
              AppColors.successInk,
            ),
            AdminStatCard(
              context.l10n.admin_pending_review,
              '${stats.pendingProperties}',
              Icons.rate_review_outlined,
              AppColors.warningInk,
            ),
            AdminStatCard(
              context.l10n.admin_total_users,
              '${stats.totalUsers}',
              Icons.people_outline,
              AppColors.primaryInk,
            ),
            AdminStatCard(
              context.l10n.admin_commission_records,
              '${stats.totalCommissions}',
              Icons.receipt_long,
              AppColors.accentInk,
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
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(AppColors.isDark ? 52 : 28),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: AppFonts.cairo(
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
