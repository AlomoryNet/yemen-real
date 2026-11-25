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
      backgroundColor: isRent ? AppColors.infoMuted : AppColors.primaryMuted,
      // primaryInk stays readable in dark mode (bright teal vs. deep teal).
      textColor: isRent
          ? (AppColors.isDark ? const Color(0xFF38BDF8) : AppColors.info)
          : AppColors.primaryInk,
      icon: isRent ? Icons.key_outlined : Icons.sell_outlined,
    );
  }

  factory StatusBadge.propertyStatus(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case AppConstants.statusPublished:
        bg = AppColors.successMuted;
        fg = AppColors.success;
        break;
      case AppConstants.statusPending:
        bg = AppColors.warningMuted;
        fg = AppColors.accentInk;
        break;
      case AppConstants.statusDraft:
        bg = AppColors.surfaceVariant;
        fg = AppColors.textSecondary;
        break;
      case AppConstants.statusHidden:
        bg = AppColors.warningMuted;
        fg = AppColors.warning;
        break;
      case AppConstants.statusArchived:
      case AppConstants.statusRejected:
        bg = AppColors.errorMuted;
        fg = AppColors.error;
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
        bg = AppColors.infoMuted;
        fg = AppColors.info;
        break;
      case AppConstants.reqStatusUnderReview:
        bg = AppColors.warningMuted;
        fg = AppColors.warning;
        break;
      case AppConstants.reqStatusContacted:
        bg = AppColors.primaryMuted;
        fg = AppColors.primary;
        break;
      case AppConstants.reqStatusProvisionallyAccepted:
      case AppConstants.reqStatusCompleted:
        bg = AppColors.successMuted;
        fg = AppColors.success;
        break;
      case AppConstants.reqStatusRejected:
      case AppConstants.reqStatusCancelled:
        bg = AppColors.errorMuted;
        fg = AppColors.error;
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
        bg = AppColors.successMuted;
        fg = AppColors.success;
        break;
      case AppConstants.commStatusDue:
        bg = AppColors.warningMuted;
        fg = AppColors.warning;
        break;
      case AppConstants.commStatusCancelled:
        bg = AppColors.errorMuted;
        fg = AppColors.error;
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
