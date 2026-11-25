import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../repositories/commission_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_badge.dart';

import '../widgets/admin_dialogs.dart';
import '../widgets/admin_paged_list.dart';

class AdminCommissionsTab extends ConsumerWidget {
  const AdminCommissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissionsPaginator = ref.watch(adminCommissionsPaginatorProvider);

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
                    context.l10n.admin_commissions_list_title,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(context.l10n.admin_add_commission),
                      onPressed: () => AdminCommissionDialog.show(context, ref),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('CSV'),
                      onPressed: () async {
                        // Export providers are intentionally separate from the
                        // paginator so the CSV contains every commission.
                        final list = await ref.read(
                          adminCommissionsProvider.future,
                        );
                        if (!context.mounted) return;
                        final csvData = ref
                            .read(adminRepositoryProvider)
                            .exportCommissionsToCsv(list);
                        AdminCsvDialog.show(
                          context,
                          context.l10n.admin_export_commissions_title,
                          csvData,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: commissionsPaginator.when(
                data: (page) {
                  final commissions = page.items;
                  if (commissions.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.receipt_long,
                      title: context.l10n.admin_no_commissions,
                      description: context.l10n.admin_commissions_desc,
                    );
                  }
                  return AdminPagedList(
                    items: commissions,
                    hasMore: page.hasMore,
                    isLoadingMore: page.isLoadingMore,
                    onLoadMore: ref
                        .read(adminCommissionsPaginatorProvider.notifier)
                        .loadMore,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, c, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.accentLight,
                          child: Icon(
                            Icons.monetization_on,
                            color: AppColors.accentDark,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${Formatters.formatCurrency(c.totalAmount, c.currency)} - ${c.propertyTitle ?? context.l10n.admin_registered_property}',
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_liable_party}: ${AppConstants.getLiablePartyNameAr(c.liableParty)} • ${context.l10n.admin_settlement_method}: ${c.settlementMethod ?? context.l10n.admin_awaiting_collection}',
                          style: AppFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.commission(c.settlementStatus),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (newStatus) async {
                                await CommissionRepository()
                                    .updateCommissionStatus(
                                      commissionId: c.id,
                                      status: newStatus,
                                    );
                                await ref
                                    .read(
                                      adminCommissionsPaginatorProvider
                                          .notifier,
                                    )
                                    .reload();
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: AppConstants.commStatusPaid,
                                  child: Text(context.l10n.admin_status_paid),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.commStatusDue,
                                  child: Text(context.l10n.admin_status_due),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.commStatusCancelled,
                                  child: Text(
                                    context.l10n.admin_status_cancelled,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
