import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';

/// Dashboard hero: branding plus a single search field and one filter button.
///
/// All filtering controls live in the shared filter sheet opened by
/// [onFilterRequested], so the hero stays compact regardless of how many
/// governorates, districts or property types are available.
class HomeHeroSection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withAlpha(120)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.dash_trusted_platform,
                      style: GoogleFonts.cairo(
                        color: AppColors.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.dash_hero_title,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: Responsive.isMobile(context) ? 26 : 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.dash_hero_subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: Responsive.isMobile(context) ? 13 : 16,
                  color: AppColors.textLight.withAlpha(210),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 560;

                    return Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: l10n.dash_search_hint,
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColors.primaryInk,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    BorderSide(color: AppColors.border),
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
                          label: Text('$activeFilterCount'),
                          backgroundColor: AppColors.accent,
                          child: FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primaryMuted,
                              foregroundColor: AppColors.primaryInk,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: onFilterRequested,
                            icon: const Icon(Icons.tune_rounded, size: 18),
                            label: compact
                                ? const SizedBox.shrink()
                                : Text(l10n.map_filters),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          onPressed: onSearchSubmit,
                          icon: const Icon(Icons.search, size: 18),
                          label: compact
                              ? const SizedBox.shrink()
                              : Text(l10n.dash_search_button),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
              _buildMapBanner(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapBanner(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/map'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(50)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.map_rounded,
                color: Colors.white,
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
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    context.l10n.dash_map_cta_subtitle,
                    style: GoogleFonts.cairo(
                      color: AppColors.textLight.withAlpha(210),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
