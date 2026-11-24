import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';

import '../services/admin_pdf_service.dart';
import 'tabs/admin_commissions_tab.dart';
import 'tabs/admin_properties_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_requests_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'widgets/admin_pending_properties.dart';
import 'widgets/admin_stats.dart';

/// Admin shell.
///
/// The screen keeps the auth guard, title, statistics, moderation queue and
/// the five-tab layout. Each section lives in its own file under `tabs/` or
/// `widgets/` so the /admin route remains unchanged while the code stays
/// maintainable.
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated || !authState.isAdmin) {
      return Scaffold(
        appBar: AppHeader(title: context.l10n.admin_dashboard, showBack: true),
        drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
              icon: Icons.gpp_bad_outlined,
              title: context.l10n.admin_restricted_title,
              description: context.l10n.admin_restricted_desc,
              actionText: context.l10n.admin_back_home,
              onAction: () => context.go('/'),
            ),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: AppHeader(title: context.l10n.admin_dashboard, showBack: true),
      drawer: Responsive.isDesktop(context) ? null : const AppDrawer(),
      body: AppPageBody(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        const SizedBox(height: 24),
                        statsAsync.when(
                          data: (stats) => AdminStatsGrid(stats: stats),
                          loading: () => LoadingView(
                            message: context.l10n.admin_loading_stats,
                          ),
                          error: (err, _) => ErrorView(
                            message: err.toString(),
                            onRetry: () => ref.refresh(adminStatsProvider),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const AdminPendingPropertiesSection(),
                        const SizedBox(height: 28),
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TabBar(
                                controller: _tabController,
                                isScrollable: true,
                                tabAlignment: TabAlignment.start,
                                labelColor: AppColors.primaryInk,
                                unselectedLabelColor: AppColors.textSecondary,
                                indicatorColor: AppColors.primary,
                                labelStyle: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                                tabs: [
                                  Tab(
                                    icon: const Icon(Icons.apartment, size: 18),
                                    text: context.l10n.admin_tab_properties,
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.assignment, size: 18),
                                    text: context.l10n.admin_tab_requests,
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.monetization_on,
                                        size: 18),
                                    text: context.l10n.admin_tab_commissions,
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.flag, size: 18),
                                    text: context.l10n.admin_tab_reports,
                                  ),
                                  Tab(
                                    icon: const Icon(Icons.people, size: 18),
                                    text: context.l10n.admin_tab_users,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textLight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              onPressed: () => AdminPdfService.exportCurrentSection(
                                context,
                                ref,
                                sectionIndex: _tabController.index,
                              ),
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: Text(
                                context.l10n.admin_print_pdf,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 650,
                          child: TabBarView(
                            controller: _tabController,
                            children: const [
                              AdminPropertiesTab(),
                              AdminRequestsTab(),
                              AdminCommissionsTab(),
                              AdminReportsTab(),
                              AdminUsersTab(),
                            ],
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

  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.primaryInk,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.l10n.admin_title,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.admin_subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentLight.withAlpha(140),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            context.l10n.admin_general_manager,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.accentDark,
            ),
          ),
        ),
      ],
    );
  }
}
