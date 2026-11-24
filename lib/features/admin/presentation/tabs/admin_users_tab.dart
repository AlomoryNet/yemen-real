import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';

import '../widgets/admin_paged_list.dart';

class AdminUsersTab extends ConsumerWidget {
  const AdminUsersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authProvider).user;
    final bool isSuperAdmin =
        authUser?.role == AppConstants.roleSuperAdmin ||
        authUser?.email == 'mo772522233@gmail.com' ||
        authUser?.id == 'admin-mohammed-saqqaf';

    if (!isSuperAdmin) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 54,
                  color: AppColors.error,
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.admin_encrypted_section_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.admin_encrypted_section_desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final usersAsync = ref.watch(allUsersProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: AppColors.primaryInk,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          context.l10n.admin_users_list_title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 14, color: Colors.green),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            context.l10n.admin_gm_permissions,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.admin_data_protection,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  return AdminPagedList(
                    items: users,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, u, index) {
                      final accountEmail =
                          u.email ??
                          (u.phone != null && u.phone!.isNotEmpty
                              ? u.phone!
                              : u.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryMuted,
                          child: Text(
                            u.fullName.isNotEmpty ? u.fullName[0] : 'U',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                        title: Text(
                          u.fullName,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_account_label}: $accountEmail • ${context.l10n.admin_created_at}: ${u.createdAt.toString().split(' ').first}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: AppColors.primaryInk,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.admin_encrypted_protected,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
