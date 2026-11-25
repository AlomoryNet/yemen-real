import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../repositories/report_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';

import '../widgets/admin_paged_list.dart';

class AdminReportsTab extends ConsumerWidget {
  const AdminReportsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsPaginator = ref.watch(adminReportsPaginatorProvider);

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
                  child: Text(
                    context.l10n.admin_reports_list_title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: reportsPaginator.when(
                data: (page) {
                  final reports = page.items;
                  if (reports.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.check_circle_outline,
                      title: context.l10n.admin_no_reports,
                      description: context.l10n.admin_no_reports_desc,
                    );
                  }
                  return AdminPagedList(
                    items: reports,
                    hasMore: page.hasMore,
                    isLoadingMore: page.isLoadingMore,
                    onLoadMore: ref
                        .read(adminReportsPaginatorProvider.notifier)
                        .loadMore,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, rep, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.errorMuted,
                          child: Icon(
                            Icons.flag,
                            color: AppColors.error,
                            size: 18,
                          ),
                        ),
                        isThreeLine: true,
                        title: Text(
                          rep.reason,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_details_label}: ${rep.details ?? context.l10n.admin_none} • ${context.l10n.admin_status_label}: ${rep.status}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final authUser = ref.read(authProvider).user;
                                await ReportRepository().updateReportStatus(
                                  reportId: rep.id,
                                  status: 'resolved',
                                  adminActionTaken:
                                      context.l10n.admin_verified_closed,
                                  adminId: authUser?.id,
                                );
                                await ref
                                    .read(
                                      adminReportsPaginatorProvider.notifier,
                                    )
                                    .reload();
                                ref.refresh(adminStatsProvider);
                              },
                              child: Text(context.l10n.admin_process),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(skeleton: true),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
