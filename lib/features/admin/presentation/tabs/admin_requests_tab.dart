import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/rental_request_provider.dart';
import '../../../../repositories/rental_request_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/status_badge.dart';

import '../widgets/admin_dialogs.dart';
import '../widgets/admin_paged_list.dart';

class AdminRequestsTab extends ConsumerWidget {
  const AdminRequestsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsPaginator = ref.watch(allRentalRequestsPaginatorProvider);

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
                    context.l10n.admin_requests_list_title,
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
                  onPressed: () async {
                    // Export providers are intentionally separate from the
                    // paginator so the CSV contains every rental request.
                    final list = await ref.read(
                      allRentalRequestsProvider.future,
                    );
                    if (!context.mounted) return;
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportRentalRequestsToCsv(list);
                    AdminCsvDialog.show(
                      context,
                      context.l10n.admin_export_requests_title,
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
              child: requestsPaginator.when(
                data: (page) {
                  final requests = page.items;
                  if (requests.isEmpty) {
                    return EmptyStateView(
                      title: context.l10n.admin_no_requests,
                    );
                  }
                  return AdminPagedList(
                    items: requests,
                    hasMore: page.hasMore,
                    isLoadingMore: page.isLoadingMore,
                    onLoadMore: ref
                        .read(allRentalRequestsPaginatorProvider.notifier)
                        .loadMore,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, req, index) {
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.infoMuted,
                          child: Icon(
                            Icons.assignment,
                            color: AppColors.info,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${req.requestNumber} - ${req.fullName}',
                          style: AppFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_phone_label}: ${req.phone} • ${context.l10n.admin_property_label}: ${req.propertyTitle ?? req.propertyId}',
                          style: AppFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.rentalRequest(req.status),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (newStatus) async {
                                await RentalRequestRepository()
                                    .updateRentalRequestStatus(
                                      requestId: req.id,
                                      status: newStatus,
                                    );
                                await ref
                                    .read(
                                      allRentalRequestsPaginatorProvider
                                          .notifier,
                                    )
                                    .reload();
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: AppConstants.reqStatusUnderReview,
                                  child: Text(
                                    context.l10n.admin_status_under_review,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusContacted,
                                  child: Text(
                                    context.l10n.admin_status_contacted,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: AppConstants
                                      .reqStatusProvisionallyAccepted,
                                  child: Text(
                                    context.l10n.admin_status_provisional,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusRejected,
                                  child: Text(
                                    context.l10n.admin_status_rejected,
                                  ),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusCompleted,
                                  child: Text(
                                    context.l10n.admin_status_completed,
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
