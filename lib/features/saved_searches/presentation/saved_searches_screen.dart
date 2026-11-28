import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/saved_search.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/saved_search_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../map/presentation/map_screen_args.dart';

class SavedSearchesScreen extends ConsumerWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppHeader(
          title: context.l10n.saved_searches_title,
          showBack: true,
        ),
        drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
              icon: Icons.bookmark_border,
              title: context.l10n.saved_search_login_required,
              description: context.l10n.saved_searches_subtitle,
              actionText: context.l10n.fav_signup_or_login,
              onAction: () => AuthPromptDialog.show(
                context,
                message: context.l10n.saved_search_login_required,
                redirectTo: '/saved-searches',
              ),
            ),
          ),
        ),
      );
    }

    final searchesAsync = ref.watch(savedSearchesProvider);

    return Scaffold(
      appBar: AppHeader(
        title: context.l10n.saved_searches_title,
        showBack: true,
      ),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      body: AppPageBody(
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
                        Text(
                          context.l10n.saved_searches_title,
                          style: AppFonts.cairo(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          context.l10n.saved_searches_subtitle,
                          style: AppFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        searchesAsync.when(
                          loading: () => const LoadingView(),
                          error: (error, _) => ErrorView(
                            message: error.toString(),
                            title: context.l10n.saved_search_load_error,
                            onRetry: () => ref
                                .read(savedSearchesProvider.notifier)
                                .loadSavedSearches(),
                          ),
                          data: (searches) {
                            if (searches.isEmpty) {
                              return EmptyStateView(
                                icon: Icons.bookmark_add_outlined,
                                title: context.l10n.saved_search_empty_title,
                                description:
                                    context.l10n.saved_search_empty_description,
                                actionText: context.l10n.sh_drawer_search,
                                onAction: () => context.go('/map'),
                              );
                            }
                            return Column(
                              children: [
                                for (final search in searches)
                                  _SavedSearchCard(search: search),
                              ],
                            );
                          },
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
    );
  }
}

class _SavedSearchCard extends ConsumerWidget {
  const _SavedSearchCard({required this.search});

  final SavedSearch search;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryMuted,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    color: AppColors.primaryInk,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        search.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _summary(context, search),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.saved_search_delete,
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Material(
              type: MaterialType.transparency,
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: search.notify,
                title: Text(
                  l10n.saved_search_notify,
                  style: AppFonts.cairo(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                onChanged: (value) => ref
                    .read(savedSearchesProvider.notifier)
                    .setNotify(search.id, value),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rename(context, ref),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(l10n.saved_search_rename),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/map',
                      extra: MapScreenArgs.fromSavedSearch(search),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(l10n.saved_search_open),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _summary(BuildContext context, SavedSearch search) {
    final l10n = context.l10n;
    final query = search.query;
    final parts = <String>[
      if (query.dealType == 'sale') l10n.map_sale_only,
      if (query.dealType == 'rent') l10n.map_rent_only,
      if (query.governorate != null && query.governorate!.isNotEmpty)
        query.governorate!,
      if (query.district != null && query.district!.isNotEmpty) query.district!,
      if (query.propertyTypeId != null) _typeLabel(context, query.propertyTypeId!),
      if (query.minBedrooms != null) '${query.minBedrooms}+',
      if (query.onlyFeatured) l10n.saved_search_featured_only,
    ];
    return parts.isEmpty ? l10n.saved_search_summary_all : parts.join(' · ');
  }

  String _typeLabel(BuildContext context, String id) {
    final l10n = context.l10n;
    switch (id) {
      case 'apartment':
        return l10n.map_type_apartment;
      case 'villa':
        return l10n.map_type_villa;
      case 'shop':
        return l10n.map_type_shop;
      case 'land':
        return l10n.map_type_land;
      case 'building':
        return l10n.map_type_building;
      case 'office':
        return l10n.map_type_office;
      default:
        return id;
    }
  }

  Future<void> _rename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: search.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.saved_search_rename),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: context.l10n.saved_search_name_label,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.saved_search_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.saved_search_save_action),
          ),
        ],
      ),
    );
    final name = controller.text.trim();
    controller.dispose();
    if (confirmed != true || name.isEmpty) return;
    await ref.read(savedSearchesProvider.notifier).rename(search.id, name);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.saved_search_delete),
        content: Text(context.l10n.saved_search_delete_confirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.saved_search_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.l10n.saved_search_delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref
        .read(savedSearchesProvider.notifier)
        .deleteSavedSearch(search.id);
  }
}
