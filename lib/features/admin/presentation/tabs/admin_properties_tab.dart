import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../repositories/property_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_badge.dart';

import '../widgets/admin_dialogs.dart';
import '../widgets/admin_paged_list.dart';

class AdminPropertiesTab extends ConsumerWidget {
  const AdminPropertiesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(searchPropertiesProvider);

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
                    context.l10n.admin_properties_list_title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(context.l10n.admin_export_csv),
                  onPressed: () {
                    final list = searchAsync.value ?? [];
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportPropertiesToCsv(list);
                    AdminCsvDialog.show(
                      context,
                      context.l10n.admin_export_properties_title,
                      csvData,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: searchAsync.when(
                data: (properties) {
                  if (properties.isEmpty) {
                    return EmptyStateView(
                      title: context.l10n.admin_no_properties,
                    );
                  }
                  return AdminPagedList(
                    items: properties,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, p, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryMuted,
                          child: Icon(
                            p.isForRent ? Icons.key : Icons.sell,
                            color: AppColors.primaryInk,
                            size: 18,
                          ),
                        ),
                        isThreeLine: true,
                        title: Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${p.city} - ${p.district} • ${Formatters.formatCurrency(p.price, p.currency)} • ${context.l10n.admin_status_label}: ${AppConstants.getPropertyStatusNameAr(p.status)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.propertyStatus(p.status),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (action) async {
                                final repo = PropertyRepository();
                                if (action == 'approve') {
                                  await repo.approvePropertyPublishing(p.id);
                                } else if (action == 'reject') {
                                  await repo.rejectPropertyPublishing(
                                    p.id,
                                    context.l10n.admin_rejected_by_admin_review,
                                  );
                                } else if (action == 'hide') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusHidden,
                                  );
                                } else if (action == 'publish') {
                                  await repo.approvePropertyPublishing(p.id);
                                } else if (action == 'archive') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusArchived,
                                  );
                                } else if (action == 'delete') {
                                  await repo.deleteProperty(p.id);
                                }
                                ref.refresh(searchPropertiesProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                if (p.status == AppConstants.statusPending) ...[
                                  PopupMenuItem(
                                    value: 'approve',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          context
                                              .l10n
                                              .admin_approve_publish_menu,
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'reject',
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.cancel_outlined,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(context.l10n.admin_reject_request),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  PopupMenuItem(
                                    value:
                                        p.status == AppConstants.statusPublished
                                        ? 'hide'
                                        : 'publish',
                                    child: Text(
                                      p.status == AppConstants.statusPublished
                                          ? context.l10n.admin_hide_listing
                                          : context.l10n.admin_republish,
                                    ),
                                  ),
                                ],
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Text(context.l10n.admin_archive),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    context.l10n.admin_delete_permanent,
                                    style: const TextStyle(
                                      color: AppColors.error,
                                    ),
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
