import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/property_provider.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';

import 'admin_pending_property_card.dart';

/// Dedicated moderation queue for properties waiting for publish approval.
class AdminPendingPropertiesSection extends ConsumerStatefulWidget {
  const AdminPendingPropertiesSection({super.key});

  @override
  ConsumerState<AdminPendingPropertiesSection> createState() =>
      _AdminPendingPropertiesSectionState();
}

class _AdminPendingPropertiesSectionState
    extends ConsumerState<AdminPendingPropertiesSection> {
  // Moderation cards are heavy; render a bounded page and extend on demand.
  static const int _pageSize = 6;
  int _visibleCount = _pageSize;

  @override
  Widget build(BuildContext context) {
    ref.listen(pendingPropertiesProvider, (_, __) {
      if (mounted) setState(() => _visibleCount = _pageSize);
    });

    final pendingAsync = ref.watch(pendingPropertiesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningFill,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.rate_review_rounded,
                    color: AppColors.warningInk,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              context.l10n.admin_pending_title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: pendingAsync.maybeWhen(
                              data: (list) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: list.isNotEmpty
                                      ? AppColors.accent
                                      : AppColors.success,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  list.isNotEmpty
                                      ? '${list.length} ${context.l10n.admin_awaiting_review}'
                                      : context.l10n.admin_review_complete,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppFonts.cairo(
                                    color: AppColors.onAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        context.l10n.admin_pending_desc,
                        style: AppFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.admin_refresh_requests,
                  icon: Icon(Icons.refresh, color: AppColors.primaryInk),
                  onPressed: () {
                    ref.refresh(pendingPropertiesProvider);
                    ref.refresh(adminStatsProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Section Body
            pendingAsync.when(
              data: (pendingList) {
                if (pendingList.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.check_circle_outline,
                    title: context.l10n.admin_no_pending,
                  );
                }

                final visible = pendingList.length > _visibleCount
                    ? pendingList.sublist(0, _visibleCount)
                    : pendingList;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visible.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return AdminPendingPropertyCard(
                          property: visible[index],
                        );
                      },
                    ),
                    if (pendingList.length > _visibleCount)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() {
                              _visibleCount = (_visibleCount + _pageSize).clamp(
                                0,
                                pendingList.length,
                              );
                            }),
                            icon: const Icon(Icons.expand_more_rounded),
                            label: Text(context.l10n.map_load_more),
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => LoadingView(
                message: context.l10n.admin_loading_pending,
                skeleton: true,
              ),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(pendingPropertiesProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
