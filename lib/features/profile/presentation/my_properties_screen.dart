import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

class MyPropertiesScreen extends ConsumerWidget {
  const MyPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: const AppHeader(),
        drawer: Responsive.isDesktop(context)
            ? null
            : const AppDrawer(),
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
    final myPropertiesAsync = ref.watch(userPropertiesProvider(userId));

    return Scaffold(
      appBar: const AppHeader(),
      drawer: Responsive.isDesktop(context)
          ? null
          : const AppDrawer(),
      bottomNavigationBar: Responsive.isDesktop(context)
          ? null
          : const AppBottomNavBar(currentRoute: '/my-properties'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          context.l10n.myprops_add_new,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.push('/add-property'),
      ),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.myprops_title,
                                  style: GoogleFonts.cairo(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  context.l10n.myprops_subtitle,
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.map_rounded, size: 18),
                                label: Text(
                                  context.l10n.myprops_yemen_map,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () => context.push('/map'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                ),
                                icon: const Icon(Icons.add_home_outlined, size: 18),
                                label: Text(
                                  context.l10n.myprops_add_property,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () => context.push('/add-property'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      myPropertiesAsync.when(
                        data: (properties) {
                          if (properties.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.apartment_outlined,
                              title: context.l10n.myprops_empty_title,
                              description:
                                  context.l10n.myprops_empty_desc,
                              actionText: context.l10n.myprops_empty_action,
                              onAction: () => context.push('/add-property'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: properties.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final prop = properties[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: AppColors.divider,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Row(
                                              children: [
                                                StatusBadge.dealType(
                                                  prop.dealType,
                                                ),
                                                const SizedBox(width: 8),
                                                StatusBadge.propertyStatus(
                                                  prop.status,
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'contract',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .description_outlined,
                                                      size: 18,
                                                      color: AppColors.primaryInk,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(context.l10n.myprops_contract),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'edit',
                                                child: Text(context.l10n.myprops_edit),
                                              ),
                                              PopupMenuItem(
                                                value: 'view',
                                                child: Text(context.l10n.myprops_view),
                                              ),
                                              PopupMenuItem(
                                                value:
                                                    prop.status ==
                                                        AppConstants
                                                            .statusPublished
                                                    ? 'hide'
                                                    : 'publish',
                                                child: Text(
                                                  prop.status ==
                                                          AppConstants
                                                              .statusPublished
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
                                                  style: TextStyle(
                                                    color: AppColors.error,
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onSelected: (action) async {
                                              final repo = ref.read(
                                                propertyRepositoryProvider,
                                              );
                                              if (action == 'contract') {
                                                context.push(
                                                  '/contract',
                                                  extra: prop,
                                                );
                                              } else if (action == 'edit') {
                                                context.push(
                                                  '/add-property',
                                                  extra: prop,
                                                );
                                              } else if (action == 'view') {
                                                context.push(
                                                  '/property/${prop.id}',
                                                );
                                              } else if (action == 'hide') {
                                                await repo.updatePropertyStatus(
                                                  prop.id,
                                                  AppConstants.statusHidden,
                                                );
                                                ref.refresh(
                                                  userPropertiesProvider(
                                                    userId,
                                                  ),
                                                );
                                              } else if (action == 'publish') {
                                                await repo.updatePropertyStatus(
                                                  prop.id,
                                                  AppConstants.statusPublished,
                                                );
                                                ref.refresh(
                                                  userPropertiesProvider(
                                                    userId,
                                                  ),
                                                );
                                              } else if (action == 'archive') {
                                                await repo.updatePropertyStatus(
                                                  prop.id,
                                                  AppConstants.statusArchived,
                                                );
                                                ref.refresh(
                                                  userPropertiesProvider(
                                                    userId,
                                                  ),
                                                );
                                              } else if (action == 'delete') {
                                                await repo.deleteProperty(
                                                  prop.id,
                                                );
                                                ref.refresh(
                                                  userPropertiesProvider(
                                                    userId,
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        prop.title,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${prop.city} - ${prop.district} • ${Formatters.formatArea(prop.areaSqm)} • ${Formatters.formatCurrency(prop.price, prop.currency)}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${context.l10n.myprops_views} ${prop.viewsCount} • ${context.l10n.myprops_added_on} ${Formatters.formatDate(prop.createdAt)}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/property/${prop.id}',
                                            ),
                                            child: Text(context.l10n.myprops_preview),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            LoadingView(message: context.l10n.myprops_loading),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () =>
                              ref.refresh(userPropertiesProvider(userId)),
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
    );
  }
}
