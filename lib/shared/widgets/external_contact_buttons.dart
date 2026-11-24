import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../services/external_communication_service.dart';

class ExternalContactButtons extends StatelessWidget {
  final String contactPhone;
  final String? contactWhatsapp;
  final String propertyTitle;
  final String propertyId;

  const ExternalContactButtons({
    super.key,
    required this.contactPhone,
    this.contactWhatsapp,
    required this.propertyTitle,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhone = contactPhone.trim().isNotEmpty;
    final hasWhatsapp =
        (contactWhatsapp != null && contactWhatsapp!.trim().isNotEmpty) ||
        hasPhone;
    final whatsappNumber =
        (contactWhatsapp != null && contactWhatsapp!.trim().isNotEmpty)
        ? contactWhatsapp!
        : contactPhone;

    if (!hasPhone && !hasWhatsapp) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 18,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                context.l10n.sh_contact_unavailable,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        // WhatsApp Button
        if (hasWhatsapp)
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline, size: 20),
              label: Text(
                context.l10n.sh_contact_whatsapp,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final success = await ExternalCommunicationService.openWhatsApp(
                  phoneNumber: whatsappNumber,
                  propertyTitle: propertyTitle,
                  propertyId: propertyId,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.sh_contact_whatsapp_error,
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),

        if (hasWhatsapp && hasPhone) const SizedBox(width: 12),

        // Phone Call Button
        if (hasPhone)
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryInk,
                side: BorderSide(color: AppColors.primaryInk, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.phone_outlined, size: 20),
              label: Text(
                context.l10n.sh_contact_call,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                final success =
                    await ExternalCommunicationService.makePhoneCall(
                      contactPhone,
                    );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${context.l10n.sh_contact_call_error_prefix} $contactPhone',
                        style: GoogleFonts.cairo(),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
      ],
    );
  }
}
