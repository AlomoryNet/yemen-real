import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/settings_provider.dart';

/// Dashboard hero: branding plus a single search field and one filter button.
///
/// On wide windows the copy and the search surface sit side-by-side, which
/// gives the landing page a clear reading order without duplicating actions.
/// Compact windows keep the stacked layout so the search stays thumb-reachable.
/// All filtering controls live in the shared filter sheet opened by
/// [onFilterRequested].
class HomeHeroSection extends ConsumerWidget {
  const HomeHeroSection({
    super.key,
    required this.searchController,
    required this.onSearchSubmit,
    required this.onFilterRequested,
    required this.activeFilterCount,
  });

  final TextEditingController searchController;
  final VoidCallback onSearchSubmit;
  final VoidCallback onFilterRequested;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useOutlinedAdd =
        ref.watch(settingsProvider).addPropertyStyle == 'outlined';
    final isMobile = Responsive.isMobile(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isMobile ? 36 : 52,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.isDesktop(context) ? 1180 : 860,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (!wide) {
                return Column(
                  children: [
                    _buildTrustBadge(context),
                    const SizedBox(height: 16),
                    _buildHeadline(context, centered: true, compact: isMobile),
                    const SizedBox(height: 28),
                    _buildSearchCard(context),
                    const SizedBox(height: 14),
                    useOutlinedAdd
                        ? _buildAddPropertyBanner(context)
                        : _buildMapBanner(context),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTrustBadge(context),
                        const SizedBox(height: 18),
                        _buildHeadline(
                          context,
                          centered: false,
                          compact: false,
                        ),
                        const SizedBox(height: 20),
                        _buildHeroProof(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _buildSearchCard(context),
                        const SizedBox(height: 14),
                        useOutlinedAdd
                            ? _buildAddPropertyBanner(context)
                            : _buildMapBanner(context),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 16, color: AppColors.accentLight),
          const SizedBox(width: 6),
          Text(
            l10n.dash_trusted_platform,
            style: AppFonts.cairo(
              color: AppColors.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadline(
    BuildContext context, {
    required bool centered,
    required bool compact,
  }) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final alignment = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          l10n.dash_hero_title,
          textAlign: alignment,
          style: AppFonts.cairo(
            textStyle: theme.textTheme.displaySmall,
            fontSize: compact ? 26 : (centered ? 38 : 42),
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
            height: 1.22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.dash_hero_subtitle,
          textAlign: alignment,
          style: AppFonts.cairo(
            fontSize: compact ? 13 : 16,
            color: AppColors.textLight.withAlpha(210),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroProof(BuildContext context) {
    final l10n = context.l10n;
    final items = <_HeroProof>[
      _HeroProof(Icons.verified_outlined, l10n.landing_trust_verified_title),
      _HeroProof(
        Icons.location_on_outlined,
        l10n.landing_stat_governorates_label,
      ),
      _HeroProof(Icons.chat_bubble_outline, l10n.landing_trust_direct_title),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: items
          .map(
            (item) => Container(
              padding: EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(24),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.accent.withAlpha(90)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.icon, size: 16, color: AppColors.accentLight),
                  const SizedBox(width: 6),
                  Text(
                    item.label,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSearchCard(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 420;

          return Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: l10n.dash_search_hint,
                    prefixIcon: Icon(Icons.search, color: AppColors.primaryInk),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => onSearchSubmit(),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: activeFilterCount > 0,
                label: Text(
                  '$activeFilterCount',
                  style: AppFonts.cairo(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onAccent,
                  ),
                ),
                backgroundColor: AppColors.accent,
                child: compact
                    ? FilledButton.tonal(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryMuted,
                          foregroundColor: AppColors.primaryInk,
                          minimumSize: const Size(48, 48),
                          padding: EdgeInsets.zero,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: onFilterRequested,
                        child: const Icon(Icons.tune_rounded, size: 18),
                      )
                    : FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryMuted,
                          foregroundColor: AppColors.primaryInk,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: onFilterRequested,
                        icon: const Icon(Icons.tune_rounded, size: 18),
                        label: Text(l10n.map_filters),
                      ),
              ),
              const SizedBox(width: 8),
              compact
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        minimumSize: const Size(48, 48),
                        padding: EdgeInsets.zero,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: onSearchSubmit,
                      child: const Icon(Icons.search, size: 18),
                    )
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: onSearchSubmit,
                      icon: const Icon(Icons.search, size: 18),
                      label: Text(l10n.dash_search_button),
                    ),
            ],
          );
        },
      ),
    );
  }

  /// When Settings → "Outline button on Home" is selected, the hero CTA
  /// becomes the primary add-property action instead of the map shortcut.
  Widget _buildAddPropertyBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          OutlinedButton.icon(
            key: const ValueKey('home_add_property_outlined'),
            onPressed: () => context.push('/add-property'),
            icon: const Icon(Icons.add_home_outlined, size: 18),
            label: Text(context.l10n.dash_add_listing_now),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryInk,
              side: BorderSide(color: AppColors.primaryInk),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.dash_add_property_prompt,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(color: AppColors.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildMapBanner(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/map'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(238),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.map_rounded,
                color: AppColors.primaryInk,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.dash_map_cta_title,
                    style: AppFonts.cairo(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    context.l10n.dash_map_cta_subtitle,
                    style: AppFonts.cairo(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primaryInk,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroProof {
  const _HeroProof(this.icon, this.label);

  final IconData icon;
  final String label;
}
