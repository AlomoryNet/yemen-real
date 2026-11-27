import 'package:flutter/material.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/responsive.dart';

/// Landing-page trust section.
///
/// Sits after the property feeds and before the publisher CTA. The section
/// answers "why use this portal?" with a compact stat strip and four value
/// pillars; it uses semantic colour roles so it stays legible in light/dark
/// and at any text scale.
class HomeTrustSection extends StatelessWidget {
  const HomeTrustSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isMobile = Responsive.isMobile(context);

    final stats = <_TrustStat>[
      _TrustStat(
        Icons.apartment_outlined,
        '440+',
        l10n.landing_stat_properties,
      ),
      _TrustStat(
        Icons.location_on_outlined,
        '22',
        l10n.landing_stat_governorates,
      ),
      _TrustStat(
        Icons.account_tree_outlined,
        '103',
        l10n.landing_stat_districts,
      ),
      _TrustStat(Icons.verified_outlined, '0', l10n.landing_stat_free),
    ];

    final pillars = <_TrustPillar>[
      _TrustPillar(
        Icons.verified_outlined,
        l10n.landing_trust_verified_title,
        l10n.landing_trust_verified_desc,
      ),
      _TrustPillar(
        Icons.map_outlined,
        l10n.landing_trust_map_title,
        l10n.landing_trust_map_desc,
      ),
      _TrustPillar(
        Icons.chat_bubble_outline,
        l10n.landing_trust_direct_title,
        l10n.landing_trust_direct_desc,
      ),
      _TrustPillar(
        Icons.support_agent_outlined,
        l10n.landing_trust_support_title,
        l10n.landing_trust_support_desc,
      ),
    ];

    return Container(
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        isMobile ? 28 : 40,
        20,
        isMobile ? 28 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: Responsive.contentMaxWidth(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  l10n.landing_eyebrow,
                  style: AppFonts.cairo(
                    textStyle: theme.textTheme.labelMedium,
                    color: scheme.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.landing_trust_title,
                style: AppFonts.cairo(
                  textStyle: isMobile
                      ? theme.textTheme.headlineSmall
                      : theme.textTheme.headlineMedium,
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.landing_trust_subtitle,
                style: AppFonts.cairo(
                  textStyle: theme.textTheme.bodyMedium,
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildStats(context, stats),
              const SizedBox(height: 20),
              _buildPillars(context, pillars),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStats(BuildContext context, List<_TrustStat> stats) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 4 : 2;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats
              .map(
                (stat) => SizedBox(
                  width: width.clamp(0.0, double.infinity),
                  child: Container(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            stat.icon,
                            size: 20,
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stat.value,
                                style: AppFonts.cairo(
                                  textStyle: theme.textTheme.titleLarge,
                                  color: scheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                stat.label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppFonts.cairo(
                                  textStyle: theme.textTheme.bodySmall,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildPillars(BuildContext context, List<_TrustPillar> pillars) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 600
            ? 2
            : 1;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: pillars
              .map(
                (pillar) => SizedBox(
                  width: width.clamp(0.0, double.infinity),
                  child: Container(
                    padding: EdgeInsetsDirectional.fromSTEB(16, 18, 16, 18),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: scheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            pillar.icon,
                            size: 22,
                            color: scheme.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          pillar.title,
                          style: AppFonts.cairo(
                            textStyle: theme.textTheme.titleMedium,
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pillar.description,
                          style: AppFonts.cairo(
                            textStyle: theme.textTheme.bodySmall,
                            color: scheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _TrustStat {
  const _TrustStat(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}

class _TrustPillar {
  const _TrustPillar(this.icon, this.title, this.description);

  final IconData icon;
  final String title;
  final String description;
}
