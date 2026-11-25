import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../repositories/commission_repository.dart';

/// Shared CSV preview/copy dialog used by the admin tabs.
class AdminCsvDialog {
  static void show(BuildContext context, String title, String csvContent) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(title, style: AppFonts.cairo(fontWeight: FontWeight.bold)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 350),
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text(context.l10n.admin_copy_data, style: AppFonts.cairo()),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.admin_csv_copied,
                    style: AppFonts.cairo(),
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.admin_close),
          ),
        ],
      ),
    );
  }
}

/// Manual commission registration dialog.
class AdminCommissionDialog {
  static void show(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final sellerAmountController = TextEditingController(text: '0');
    final buyerAmountController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String liableParty = AppConstants.liableBoth;
    String currency = AppConstants.currencyUsd;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(
            context.l10n.admin_commission_modal_title,
            style: AppFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.admin_commission_property_title,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: context.l10n.admin_commission_property_hint,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_commission_liable,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: liableParty,
                    items: [
                      DropdownMenuItem(
                        value: AppConstants.liableBoth,
                        child: Text(context.l10n.admin_liable_both),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableSeller,
                        child: Text(context.l10n.admin_liable_seller),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableBuyer,
                        child: Text(context.l10n.admin_liable_buyer),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => liableParty = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.admin_seller_amount,
                              style: AppFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: sellerAmountController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.admin_buyer_amount,
                              style: AppFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: buyerAmountController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_currency,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currency,
                    items: AppConstants.supportedCurrencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(AppConstants.getCurrencyNameAr(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => currency = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_commission_notes,
                    style: AppFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(controller: notesController, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.admin_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final sAmount =
                    double.tryParse(sellerAmountController.text) ?? 0;
                final bAmount =
                    double.tryParse(buyerAmountController.text) ?? 0;
                final total = sAmount + bAmount;

                final authUser = ref.read(authProvider).user;
                await CommissionRepository().createCommission(
                  propertyId: 'manual-prop',
                  propertyTitle: titleController.text.trim().isNotEmpty
                      ? titleController.text.trim()
                      : context.l10n.admin_registered_property,
                  liableParty: liableParty,
                  sellerAmount: sAmount,
                  buyerAmount: bAmount,
                  totalAmount: total,
                  currency: currency,
                  reasonAndNotes: notesController.text.trim(),
                  adminUserId: authUser?.id,
                );

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                await ref
                    .read(adminCommissionsPaginatorProvider.notifier)
                    .reload();
                ref.refresh(adminStatsProvider);
              },
              child: Text(context.l10n.admin_save_record),
            ),
          ],
        ),
      ),
    );
  }
}
