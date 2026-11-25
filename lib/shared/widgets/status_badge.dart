import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.dealType(String dealType) {
    final isRent = dealType == AppConstants.dealRent;
    return StatusBadge(
      text: AppConstants.getDealTypeNameAr(dealType),
      backgroundColor: isRent ? AppColors.infoFill : AppColors.primaryFill,
      textColor: isRent ? AppColors.infoInk : AppColors.primaryInk,
      icon: isRent ? Icons.key_outlined : Icons.sell_outlined,
    );
  }

  factory StatusBadge.propertyStatus(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case AppConstants.statusPublished:
        bg = AppColors.successFill;
        fg = AppColors.successInk;
        break;
      case AppConstants.statusPending:
        bg = AppColors.warningFill;
        fg = AppColors.warningInk;
        break;
      case AppConstants.statusDraft:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
        break;
      case AppConstants.statusHidden:
        bg = AppColors.warningFill;
        fg = AppColors.warningInk;
        break;
      case AppConstants.statusArchived:
      case AppConstants.statusRejected:
        bg = AppColors.errorFill;
        fg = AppColors.errorInk;
        break;
      default:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
    }

    return StatusBadge(
      text: AppConstants.getPropertyStatusNameAr(status),
      backgroundColor: bg,
      textColor: fg,
    );
  }

  factory StatusBadge.rentalRequest(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case AppConstants.reqStatusNew:
        bg = AppColors.infoFill;
        fg = AppColors.infoInk;
        break;
      case AppConstants.reqStatusUnderReview:
        bg = AppColors.warningFill;
        fg = AppColors.warningInk;
        break;
      case AppConstants.reqStatusContacted:
        bg = AppColors.primaryFill;
        fg = AppColors.primaryInk;
        break;
      case AppConstants.reqStatusProvisionallyAccepted:
      case AppConstants.reqStatusCompleted:
        bg = AppColors.successFill;
        fg = AppColors.successInk;
        break;
      case AppConstants.reqStatusRejected:
      case AppConstants.reqStatusCancelled:
        bg = AppColors.errorFill;
        fg = AppColors.errorInk;
        break;
      default:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
    }

    return StatusBadge(
      text: AppConstants.getRentalRequestStatusNameAr(status),
      backgroundColor: bg,
      textColor: fg,
    );
  }

  factory StatusBadge.commission(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case AppConstants.commStatusPaid:
        bg = AppColors.successFill;
        fg = AppColors.successInk;
        break;
      case AppConstants.commStatusDue:
        bg = AppColors.warningFill;
        fg = AppColors.warningInk;
        break;
      case AppConstants.commStatusCancelled:
        bg = AppColors.errorFill;
        fg = AppColors.errorInk;
        break;
      default:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
    }

    return StatusBadge(
      text: AppConstants.getCommissionStatusNameAr(status),
      backgroundColor: bg,
      textColor: fg,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
