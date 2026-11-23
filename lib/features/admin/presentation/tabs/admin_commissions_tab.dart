import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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

class AdminCommissionsTab extends ConsumerWidget {
  const AdminCommissionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commissionsAsync = ref.watch(adminCommissionsProvider);

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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
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
                      onPressed: () {
                        final list = commissionsAsync.value ?? [];
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
              child: commissionsAsync.when(
                data: (commissions) {
                  if (commissions.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.receipt_long,
                      title: context.l10n.admin_no_commissions,
                      description: context.l10n.admin_commissions_desc,
                    );
                  }
                  return ListView.separated(
                    itemCount: commissions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = commissions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accentLight,
                          child: const Icon(
                            Icons.monetization_on,
                            color: AppColors.accentDark,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${Formatters.formatCurrency(c.totalAmount, c.currency)} - ${c.propertyTitle ?? context.l10n.admin_registered_property}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_liable_party}: ${AppConstants.getLiablePartyNameAr(c.liableParty)} • ${context.l10n.admin_settlement_method}: ${c.settlementMethod ?? context.l10n.admin_awaiting_collection}',
                          style: GoogleFonts.cairo(fontSize: 12),
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
                                ref.refresh(adminCommissionsProvider);
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
