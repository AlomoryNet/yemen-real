import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../models/property.dart';
import 'empty_state_view.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'property_card.dart';

/// Reusable dashboard section: a titled category with a real item count, a
/// small, bounded preview of its properties and a "view all" action.
///
/// The preview is capped at [maxItems] (four by default) so long category lists
/// never inflate the dashboard widget tree. The full list is still used for
/// [countText] and for the destination chosen by [onViewAll].
class PropertyCategorySection extends StatelessWidget {
  const PropertyCategorySection({
    super.key,
    required this.title,
    required this.subtitle,
    this.countText,
    required this.properties,
    required this.onViewAll,
    this.icon = Icons.apartment_rounded,
    this.emptyMessage,
    this.maxItems = 4,
    this.isLoading = false,
    this.loadingMessage,
    this.errorMessage,
    this.onRetry,
    this.viewAllLabel,
  });

  factory PropertyCategorySection.loading({
    Key? key,
    required String title,
    required String subtitle,
    required VoidCallback onViewAll,
    IconData icon = Icons.apartment_rounded,
    String? loadingMessage,
  }) {
    return PropertyCategorySection(
      key: key,
      title: title,
      subtitle: subtitle,
      properties: const <Property>[],
      onViewAll: onViewAll,
      icon: icon,
      isLoading: true,
      loadingMessage: loadingMessage,
    );
  }

  factory PropertyCategorySection.error({
    Key? key,
    required String title,
    required String subtitle,
    required VoidCallback onViewAll,
    required String message,
    required VoidCallback onRetry,
    IconData icon = Icons.apartment_rounded,
  }) {
    return PropertyCategorySection(
      key: key,
      title: title,
      subtitle: subtitle,
      properties: const <Property>[],
      onViewAll: onViewAll,
      icon: icon,
      errorMessage: message,
      onRetry: onRetry,
    );
  }

  final String title;
  final String subtitle;
  final String? countText;
  final List<Property> properties;
  final VoidCallback onViewAll;
  final IconData icon;
  final String? emptyMessage;
  final int maxItems;
  final bool isLoading;
  final String? loadingMessage;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final String? viewAllLabel;

  @override
  Widget build(BuildContext context) {
    final shown = properties.take(maxItems).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryInk, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    if (countText != null && countText!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          countText!,
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryInk,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onViewAll,
                icon: const Icon(Icons.arrow_back, size: 16),
                label: Text(viewAllLabel ?? context.l10n.dash_view_all),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            LoadingView(message: loadingMessage)
          else if (errorMessage != null)
            ErrorView(
              message: errorMessage!,
              onRetry: onRetry,
            )
          else if (shown.isEmpty)
            EmptyStateView(
              title: emptyMessage ?? context.l10n.dash_empty_section_title,
              description: context.l10n.dash_empty_section_description,
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final columns = constraints.maxWidth >= 900
                    ? 3
                    : constraints.maxWidth >= 600
                        ? 2
                        : 1;
                final cardWidth = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: shown
                      .map(
                        (property) => SizedBox(
                          width: cardWidth.clamp(0.0, double.infinity),
                          child: PropertyCard(property: property),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}
