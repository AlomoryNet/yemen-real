import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Lightweight placeholder cards shown while a list or detail view loads.
///
/// This is intentionally static (no repeating animation): it communicates the
/// shape of the incoming content without adding a ticker to every scrollable
/// screen or making widget tests wait on an endless shimmer loop.
class SkeletonLoader extends StatelessWidget {
  final int cards;
  final double imageHeight;

  const SkeletonLoader({super.key, this.cards = 2, this.imageHeight = 90});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < cards; index++)
            Padding(
              padding: EdgeInsets.only(bottom: index == cards - 1 ? 0 : 12),
              child: _SkeletonCard(imageHeight: imageHeight),
            ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double imageHeight;

  const _SkeletonCard({required this.imageHeight});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: imageHeight + 80,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: imageHeight, color: AppColors.surfaceVariant),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SkeletonBar(widthFactor: 0.72, height: 13),
                const SizedBox(height: 9),
                _SkeletonBar(widthFactor: 0.48, height: 11),
                const SizedBox(height: 9),
                _SkeletonBar(widthFactor: 0.35, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBar extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _SkeletonBar({required this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.divider.withAlpha(110),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
