import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/context_l10n.dart';
import '../../../../models/property_image.dart';

/// Self-contained image carousel for the property detail screen.
///
/// Keeping the active page state here prevents a thumbnail tap from rebuilding
/// the rest of the detail page, including the embedded map.
class PropertyImageGallery extends StatefulWidget {
  final List<PropertyImage> images;

  const PropertyImageGallery({super.key, required this.images});

  @override
  State<PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<PropertyImageGallery> {
  late final PageController _pageController = PageController();
  int _activeIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectImage(int index) {
    if (index < 0 || index >= widget.images.length) return;
    setState(() => _activeIndex = index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final colors = Theme.of(context).colorScheme;
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    final mainCacheWidth = (MediaQuery.sizeOf(context).width * devicePixelRatio)
        .clamp(360.0, 1400.0)
        .round();
    final thumbCacheWidth = (90 * devicePixelRatio).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: images.isEmpty
                ? _placeholder(colors)
                : PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (index) =>
                        setState(() => _activeIndex = index),
                    itemBuilder: (context, index) => CachedNetworkImage(
                      imageUrl: images[index].imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: mainCacheWidth,
                      placeholder: (_, __) => _placeholder(colors),
                      errorWidget: (_, __, ___) => _placeholder(colors),
                    ),
                  ),
          ),
        ),
        if (images.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final isSelected = index == _activeIndex;
                return Tooltip(
                  message: '${context.l10n.detail_view_image} ${index + 1}',
                  child: InkWell(
                    onTap: () => _selectImage(index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outlineVariant,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CachedNetworkImage(
                        imageUrl: images[index].imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: thumbCacheWidth,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.apartment_outlined,
          size: 60,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}
