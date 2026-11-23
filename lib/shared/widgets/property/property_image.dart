import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/property_text_styles.dart';

/// Branded placeholder used whenever a property has no usable image.
class PropertyImagePlaceholder extends StatelessWidget {
  const PropertyImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.apartment, size: 44, color: AppColors.textMuted),
            const SizedBox(height: 6),
            Text(
              context.l10n.sh_brand_name,
              style: PropertyTextStyles.muted(size: 11),
            ),
          ],
        ),
      ),
    );
  }
}

/// The single image renderer for every property surface.
class PropertyImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final int? memCacheWidth;

  const PropertyImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.memCacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const PropertyImagePlaceholder();
    }
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      placeholder: (_, __) => Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (_, __, ___) => const PropertyImagePlaceholder(),
    );
  }
}

/// Image carousel used by the floating map card.
///
/// Badges and the favorite/close controls are supplied by the caller so the
/// card shell owns positioning while the shared widgets own appearance.
class PropertyImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;
  final Widget? topStart;
  final Widget? topEnd;
  final bool showDots;

  const PropertyImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 155,
    this.initialIndex = 0,
    this.onIndexChanged,
    this.topStart,
    this.topEnd,
    this.showDots = true,
  });

  @override
  State<PropertyImageCarousel> createState() => _PropertyImageCarouselState();
}

class _PropertyImageCarouselState extends State<PropertyImageCarousel> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    final count = widget.imageUrls.length;
    _current = count == 0
        ? 0
        : widget.initialIndex.clamp(0, count - 1).toInt();
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;
    return Stack(
      children: [
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: images.isEmpty
              ? const PropertyImagePlaceholder()
              : PageView.builder(
                  controller: _controller,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _current = index);
                    widget.onIndexChanged?.call(index);
                  },
                  itemBuilder: (context, index) => PropertyImage(
                    imageUrl: images[index],
                    memCacheWidth: 900,
                  ),
                ),
        ),
        if (widget.topStart != null)
          Positioned(top: 10, right: 10, child: widget.topStart!),
        if (widget.topEnd != null)
          Positioned(top: 10, left: 10, child: widget.topEnd!),
        if (widget.showDots && images.length > 1)
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length.clamp(0, 6), (index) {
                final active = index == _current;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: active ? 14 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.textLight.withAlpha(active ? 255 : 130),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
