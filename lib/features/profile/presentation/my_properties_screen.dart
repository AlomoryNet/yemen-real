import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/property_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../models/user_property_stats.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/property_card.dart';

/// Owner's property tab.
///
/// Uses the same [PropertyCard] family as the dashboard, map and favorites so
/// the listing surface feels familiar everywhere. Only the management menu and
/// the owner-metrics footer are specific to this screen.
class MyPropertiesScreen extends ConsumerStatefulWidget {
  const MyPropertiesScreen({super.key});

  @override
  ConsumerState<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends ConsumerState<MyPropertiesScreen> {
  /// Empty = all deals. Mirrors the shared filter sheet convention.
  String _dealFilter = '';

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: const AppHeader(),
        drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
        bottomNavigationBar: Responsive.isDesktop(context)
            ? null
            : const AppBottomNavBar(currentRoute: '/my-properties'),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
              icon: Icons.apartment,
              title: context.l10n.myprops_login_required,
              description: context.l10n.myprops_signup_prompt,
              actionText: context.l10n.myprops_signup_or_login,
              onAction: () => AuthPromptDialog.show(
                context,
                message: context.l10n.myprops_signup_prompt,
                redirectTo: '/my-properties',
              ),
            ),
          ),
        ),
      );
    }

    final userId = authState.user!.id;
    final myPropertiesAsync = ref.watch(
      userPropertiesPaginatorProvider(userId),
    );

    return Scaffold(
      appBar: const AppHeader(),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : const AppBottomNavBar(currentRoute: '/my-properties'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        icon: const Icon(Icons.add),
        label: Text(
          context.l10n.myprops_add_new,
          style: PropertyTextStyles.badge(size: 13),
        ),
        onPressed: () => context.push('/add-property'),
      ),
      body: AppPageBody(
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification &&
                notification.metrics.extentAfter < 400) {
              final page = myPropertiesAsync.value;
              if (page != null && page.hasMore && !page.isLoadingMore) {
                ref
                    .read(userPropertiesPaginatorProvider(userId).notifier)
                    .loadMore();
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 30,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPageHeader(),
                          const SizedBox(height: 20),
                          myPropertiesAsync.when(
                            data: (page) {
                              final properties = page.properties;
                              if (properties.isEmpty && page.stats.total == 0) {
                                return EmptyStateView(
                                  icon: Icons.apartment_outlined,
                                  title: context.l10n.myprops_empty_title,
                                  description: context.l10n.myprops_empty_desc,
                                  actionText: context.l10n.myprops_empty_action,
                                  onAction: () => context.push('/add-property'),
                                );
                              }

                              final visibleProperties = _dealFilter.isEmpty
                                  ? properties
                                  : properties
                                        .where((p) => p.dealType == _dealFilter)
                                        .toList();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildStats(page.stats),
                                  const SizedBox(height: 16),
                                  _buildDealFilter(),
                                  const SizedBox(height: 16),
                                  if (visibleProperties.isEmpty)
                                    EmptyStateView(
                                      icon: Icons.filter_alt_off_outlined,
                                      title: context.l10n.admin_no_properties,
                                      description:
                                          context.l10n.map_all_deals_short,
                                      actionText: context.l10n.filter_reset,
                                      onAction: () =>
                                          setState(() => _dealFilter = ''),
                                    )
                                  else ...[
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: visibleProperties.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 14),
                                      itemBuilder: (context, index) =>
                                          _buildPropertyCard(
                                            visibleProperties[index],
                                            userId,
                                          ),
                                    ),
                                    if (page.hasMore)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: Center(
                                          child: OutlinedButton.icon(
                                            onPressed: page.isLoadingMore
                                                ? null
                                                : () => ref
                                                      .read(
                                                        userPropertiesPaginatorProvider(
                                                          userId,
                                                        ).notifier,
                                                      )
                                                      .loadMore(),
                                            icon: page.isLoadingMore
                                                ? const SizedBox(
                                                    width: 16,
                                                    height: 16,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : const Icon(
                                                    Icons.expand_more_rounded,
                                                  ),
                                            label: Text(
                                              context.l10n.map_load_more,
                                              style: PropertyTextStyles.badge(
                                                size: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ],
                              );
                            },
                            loading: () => LoadingView(
                              message: context.l10n.myprops_loading,
                            ),
                            error: (err, _) => ErrorView(
                              message: err.toString(),
                              onRetry: () => ref
                                  .read(
                                    userPropertiesPaginatorProvider(
                                      userId,
                                    ).notifier,
                                  )
                                  .loadFirstPage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.myprops_title,
                style: PropertyTextStyles.title(size: 22),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.myprops_subtitle,
                style: PropertyTextStyles.meta(size: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          style: FilledButton.styleFrom(
            foregroundColor: AppColors.primaryInk,
            backgroundColor: AppColors.surfaceVariant,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.map_rounded, size: 18),
          label: Text(
            context.l10n.myprops_yemen_map,
            style: PropertyTextStyles.chip(),
          ),
          onPressed: () => context.push('/map'),
        ),
      ],
    );
  }

  Widget _buildStats(UserPropertyStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 620;
        final tiles = [
          _statTile(
            icon: Icons.apartment_outlined,
            value: stats.total,
            label: context.l10n.admin_total_properties,
          ),
          _statTile(
            icon: Icons.check_circle_outline,
            value: stats.published,
            label: context.l10n.status_published,
          ),
          _statTile(
            icon: Icons.schedule_outlined,
            value: stats.pending,
            label: context.l10n.status_pending,
          ),
        ];

        return isWide
            ? Row(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: tiles[i]),
                  ],
                ],
              )
            : Column(
                children: [
                  for (var i = 0; i < tiles.length; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    tiles[i],
                  ],
                ],
              );
      },
    );
  }

  Widget _statTile({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryInk),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value.toString(),
                  style: PropertyTextStyles.price(size: 16),
                ),
                Text(
                  label,
                  style: PropertyTextStyles.muted(size: 10.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealFilter() {
    final filters = <(String value, String label)>[
      ('', context.l10n.map_all_deals_short),
      (AppConstants.dealSale, context.l10n.map_for_sale),
      (AppConstants.dealRent, context.l10n.map_for_rent),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            ChoiceChip(
              label: Text(
                filter.$2,
                style: PropertyTextStyles.chip(size: 11.5).copyWith(
                  color: _dealFilter == filter.$1
                      ? AppColors.primaryInk
                      : AppColors.textSecondary,
                ),
              ),
              selected: _dealFilter == filter.$1,
              showCheckmark: false,
              selectedColor: AppColors.primary.withAlpha(28),
              backgroundColor: AppColors.surfaceVariant,
              side: BorderSide(
                color: _dealFilter == filter.$1
                    ? AppColors.primary
                    : AppColors.divider,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (_) => setState(() => _dealFilter = filter.$1),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Property prop, String userId) {
    return PropertyCard(
      property: prop,
      layout: PropertyCardLayout.management,
      onTap: () => context.push('/property/${prop.id}'),
      trailing: _buildPropertyMenu(prop, userId),
      footer: Row(
        children: [
          Expanded(
            child: Text(
              '${context.l10n.myprops_views} ${prop.viewsCount} • '
              '${context.l10n.myprops_added_on} ${Formatters.formatDate(prop.createdAt)}',
              style: PropertyTextStyles.muted(size: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () => context.push('/property/${prop.id}'),
            child: Text(
              context.l10n.myprops_preview,
              style: PropertyTextStyles.caption(),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<String> _buildPropertyMenu(Property prop, String userId) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.myprops_edit,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'contract',
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 18,
                color: AppColors.primaryInk,
              ),
              const SizedBox(width: 8),
              Text(context.l10n.myprops_contract),
            ],
          ),
        ),
        PopupMenuItem(value: 'edit', child: Text(context.l10n.myprops_edit)),
        PopupMenuItem(value: 'view', child: Text(context.l10n.myprops_view)),
        PopupMenuItem(
          value: prop.status == AppConstants.statusPublished
              ? 'hide'
              : 'publish',
          child: Text(
            prop.status == AppConstants.statusPublished
                ? context.l10n.myprops_hide
                : context.l10n.myprops_republish,
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Text(context.l10n.myprops_archive),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            context.l10n.myprops_delete_permanent,
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      ],
      onSelected: (action) => _handlePropertyAction(action, prop, userId),
    );
  }

  Future<void> _handlePropertyAction(
    String action,
    Property prop,
    String userId,
  ) async {
    if (action == 'contract') {
      context.push('/contract', extra: prop);
      return;
    }
    if (action == 'edit') {
      context.push('/add-property', extra: prop);
      return;
    }
    if (action == 'view') {
      context.push('/property/${prop.id}');
      return;
    }

    final repo = ref.read(propertyRepositoryProvider);
    if (action == 'hide') {
      await repo.updatePropertyStatus(prop.id, AppConstants.statusHidden);
    } else if (action == 'publish') {
      await repo.updatePropertyStatus(prop.id, AppConstants.statusPublished);
    } else if (action == 'archive') {
      await repo.updatePropertyStatus(prop.id, AppConstants.statusArchived);
    } else if (action == 'delete') {
      await repo.deleteProperty(prop.id);
    }
    ref.read(userPropertiesPaginatorProvider(userId).notifier).loadFirstPage();
  }
}
