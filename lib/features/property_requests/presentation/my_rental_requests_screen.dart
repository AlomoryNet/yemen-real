import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rental_request_provider.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

class MyRentalRequestsScreen extends ConsumerWidget {
  const MyRentalRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: AppHeader(title: context.l10n.my_requests, showBack: true),
        drawer: Responsive.isDesktop(context)
            ? null
            : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
            icon: Icons.assignment_outlined,
            title: context.l10n.req_login_required,
            description: context.l10n.req_signup_prompt,
            actionText: context.l10n.req_signup_or_login,
            onAction: () => AuthPromptDialog.show(
              context,
              message: context.l10n.req_signup_prompt,
              redirectTo: '/my-requests',
            ),
          ),
          ),
        ),
      );
    }

    final requestsAsync = ref.watch(userRentalRequestsProvider);

    return Scaffold(
      appBar: AppHeader(title: context.l10n.my_requests, showBack: true),
      drawer: Responsive.isDesktop(context)
          ? null
          : const AppDrawer(),
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
                      Text(
                        context.l10n.req_title,
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.req_subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      requestsAsync.when(
                        data: (requests) {
                          if (requests.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.assignment_outlined,
                              title: context.l10n.req_empty_title,
                              description: context.l10n.req_empty_desc,
                              actionText: context.l10n.req_empty_action,
                              onAction: () => context.push('/map'),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: requests.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final req = requests[index];
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
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              req.requestNumber,
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryInk,
                                              ),
                                            ),
                                          ),
                                          StatusBadge.rentalRequest(req.status),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        req.propertyTitle ??
                                            context.l10n.req_property_fallback,
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              '${context.l10n.req_requested_start} ${req.requestedStartDate != null ? Formatters.formatDate(req.requestedStartDate) : context.l10n.req_not_specified}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (req.notes != null &&
                                          req.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          '${context.l10n.req_your_notes} ${req.notes}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                      if (req.adminNotes != null &&
                                          req.adminNotes!.isNotEmpty) ...[
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.infoMuted,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: AppColors.info,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  '${context.l10n.req_owner_admin_reply} ${req.adminNotes}',
                                                  style: GoogleFonts.cairo(
                                                    fontSize: 12,
                                                    color: AppColors.info,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${context.l10n.req_sent_on} ${Formatters.formatDateTime(req.createdAt)}',
                                              style: GoogleFonts.cairo(
                                                fontSize: 11,
                                                color: AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/property/${req.propertyId}',
                                            ),
                                            child: Text(context.l10n.req_view_property),
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
                            LoadingView(message: context.l10n.req_loading),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () =>
                              ref.refresh(userRentalRequestsProvider),
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
