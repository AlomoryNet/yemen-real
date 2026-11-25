import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import '../../core/theme/app_colors.dart';
import 'skeleton_loader.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  /// List/detail surfaces use a content-shaped skeleton; compact controls and
  /// short-lived operations keep the default spinner.
  final bool skeleton;

  const LoadingView({super.key, this.message, this.skeleton = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (skeleton)
              const SkeletonLoader()
            else
              CircularProgressIndicator(
                color: AppColors.primaryInk,
                strokeWidth: 2.5,
              ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
