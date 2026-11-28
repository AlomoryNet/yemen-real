import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/notification_item.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppHeader(
          title: context.l10n.notifications,
          showBack: true,
        ),
        drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
              icon: Icons.notifications_none,
              title: context.l10n.notifications_login_required,
              description: context.l10n.notifications_empty_description,
              actionText: context.l10n.fav_signup_or_login,
              onAction: () => AuthPromptDialog.show(
                context,
                message: context.l10n.notifications_login_required,
                redirectTo: '/notifications',
              ),
            ),
          ),
        ),
      );
    }

    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppHeader(
        title: context.l10n.notifications,
        showBack: true,
      ),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      body: AppPageBody(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.l10n.notifications,
                                style: AppFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(notificationsProvider.notifier)
                                  .markAllAsRead(),
                              icon: const Icon(Icons.done_all_rounded, size: 18),
                              label: Text(
                                context.l10n.notifications_mark_all_read,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        notificationsAsync.when(
                          loading: () => const LoadingView(),
                          error: (error, _) => ErrorView(
                            message: error.toString(),
                            title: context.l10n.notifications_load_error,
                            onRetry: () => ref
                                .read(notificationsProvider.notifier)
                                .loadNotifications(),
                          ),
                          data: (items) {
                            if (items.isEmpty) {
                              return EmptyStateView(
                                icon: Icons.notifications_none,
                                title: context.l10n.notifications_empty_title,
                                description:
                                    context.l10n.notifications_empty_description,
                              );
                            }
                            return Column(
                              children: [
                                for (final item in items)
                                  _NotificationTile(item: item),
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

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.item});

  final NotificationItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              item.isRead ? AppColors.surfaceVariant : AppColors.primaryMuted,
          child: Icon(
            item.isRead
                ? Icons.notifications_none
                : Icons.notifications_active_outlined,
            color: item.isRead ? AppColors.textMuted : AppColors.primaryInk,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppFonts.cairo(
            fontSize: 14,
            fontWeight:
                item.isRead ? FontWeight.w600 : FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item.body,
              style: AppFonts.cairo(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.createdAt.toLocal().toString().split('.').first,
              style: AppFonts.cairo(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        onTap: () async {
          await ref
              .read(notificationsProvider.notifier)
              .markAsRead(item.id);
          final link = item.link;
          if (link != null && link.isNotEmpty && context.mounted) {
            context.push(link);
          }
        },
      ),
    );
  }
}
