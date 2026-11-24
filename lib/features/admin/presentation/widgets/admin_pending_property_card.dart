import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/property.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/property_provider.dart';

/// Approval card used by the admin moderation queue.
class AdminPendingPropertyCard extends ConsumerStatefulWidget {
  const AdminPendingPropertyCard({super.key, required this.property});

  final Property property;

  @override
  ConsumerState<AdminPendingPropertyCard> createState() =>
      _AdminPendingPropertyCardState();
}

class _AdminPendingPropertyCardState
    extends ConsumerState<AdminPendingPropertyCard> {
  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final isRent = p.dealType == AppConstants.dealRent;
    final primaryImg =
        p.primaryImageUrl ??
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image Thumbnail + Main Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: CachedNetworkImage(
                    imageUrl: primaryImg,
                    fit: BoxFit.cover,
                    memCacheWidth: 180,
                    placeholder: (_, __) => Container(
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.apartment,
                        size: 32,
                        color: AppColors.textMuted,
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.apartment,
                        size: 32,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRent
                                ? context.l10n.admin_for_rent
                                : context.l10n.admin_for_sale,
                            style: GoogleFonts.cairo(
                              color: AppColors.textLight,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.propertyType?.nameAr ?? p.propertyTypeId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            Formatters.formatCurrency(p.price, p.currency),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${p.city} - ${p.district}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.square_foot,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${p.areaSqm} ${context.l10n.admin_sqm}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (p.bedrooms > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${p.bedrooms} ${context.l10n.admin_rooms}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Owner & Submission Info Panel
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 16, color: AppColors.primaryInk),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${context.l10n.admin_listing_owner}: ${p.owner?.fullName ?? context.l10n.admin_platform_user}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.primaryInk),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          p.contactPhone.isNotEmpty
                              ? p.contactPhone
                              : (p.owner?.phone ?? '-'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          Formatters.formatDate(p.createdAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Approve & Publish vs Reject vs View Details
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(
                  context.l10n.admin_approve_publish,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => _handleApproveProperty(context, p),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(
                  context.l10n.admin_reject_request,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => _handleRejectPropertyDialog(context, p),
              ),
              TextButton.icon(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(
                  context.l10n.admin_view_full_details,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => context.push('/property/${p.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleApproveProperty(
    BuildContext context,
    Property prop,
  ) async {
    try {
      final repo = ref.read(propertyRepositoryProvider);
      await repo.approvePropertyPublishing(prop.id);
      ref.refresh(pendingPropertiesProvider);
      ref.refresh(adminStatsProvider);
      ref.refresh(searchPropertiesProvider);
      ref.refresh(allMapPropertiesProvider);
      ref.refresh(propertiesForSaleProvider);
      ref.refresh(propertiesForRentProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.admin_approved_prefix}${prop.title}${context.l10n.admin_approved_suffix}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.admin_approve_failed}: ${e.toString()}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectPropertyDialog(
    BuildContext context,
    Property prop,
  ) async {
    final reasonController = TextEditingController(
      text: context.l10n.admin_default_reject_reason,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              context.l10n.admin_reject_dialog_title,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.admin_reject_reason_prompt,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.cairo(fontSize: 13),
              decoration: InputDecoration(
                hintText: context.l10n.admin_reject_hint,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.admin_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.textLight,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.admin_confirm_reject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(propertyRepositoryProvider);
        await repo.rejectPropertyPublishing(
          prop.id,
          reasonController.text.trim(),
        );
        ref.refresh(pendingPropertiesProvider);
        ref.refresh(adminStatsProvider);
        ref.refresh(searchPropertiesProvider);
        ref.refresh(allMapPropertiesProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.admin_reject_saved,
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${context.l10n.admin_reject_failed}: ${e.toString()}',
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
