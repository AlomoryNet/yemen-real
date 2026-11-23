import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/context_l10n.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/rental_request_provider.dart';
import '../../../repositories/admin_repository.dart';
import '../../../repositories/commission_repository.dart';
import '../../../repositories/property_repository.dart';
import '../../../repositories/rental_request_repository.dart';
import '../../../repositories/report_repository.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../models/property.dart';

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

    // Security check: Only admins can access this screen
    if (!authState.isAuthenticated || !authState.isAdmin) {
      return Scaffold(
        appBar: const AppHeader(title: 'لوحة الإدارة', showBack: true),
        drawer: Responsive.isDesktop(context)
            ? null
            : const AppDrawer(),
        body: AppPageBody(
          child: Center(
            child: EmptyStateView(
            icon: Icons.gpp_bad_outlined,
            title: context.l10n.admin_restricted_title,
            description:
                context.l10n.admin_restricted_desc,
            actionText: context.l10n.admin_back_home,
            onAction: () => context.go('/'),
          ),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: const AppHeader(title: 'لوحة الإدارة', showBack: true),
      drawer: Responsive.isDesktop(context)
          ? null
          : const AppDrawer(),
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
                      // Admin Title & Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
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
                                  Text(
                                    context.l10n.admin_title,
                                    style: GoogleFonts.cairo(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
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
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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
                      ),
                      const SizedBox(height: 24),

                      // Statistics Overview Grid
                      statsAsync.when(
                        data: (stats) => _buildStatsGrid(context, stats),
                        loading: () => LoadingView(
                          message: context.l10n.admin_loading_stats,
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(adminStatsProvider),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Dedicated Section: Properties Awaiting Approval
                      _buildPendingPropertiesSection(context),

                      const SizedBox(height: 28),

                      // Tabs for Admin Sections & Print PDF Button
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
                                  icon: Icon(Icons.apartment, size: 18),
                                  text: context.l10n.admin_tab_properties,
                                ),
                                Tab(
                                  icon: Icon(Icons.assignment, size: 18),
                                  text: context.l10n.admin_tab_requests,
                                ),
                                Tab(
                                  icon: Icon(Icons.monetization_on, size: 18),
                                  text: context.l10n.admin_tab_commissions,
                                ),
                                Tab(
                                  icon: Icon(Icons.flag, size: 18),
                                  text: context.l10n.admin_tab_reports,
                                ),
                                Tab(
                                  icon: Icon(Icons.people, size: 18),
                                  text: context.l10n.admin_tab_users,
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () => _exportCurrentSectionToPdf(context),
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

                      // Tab Views
                      SizedBox(
                        height: 650,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildPropertiesTab(context),
                            _buildRequestsTab(context),
                            _buildCommissionsTab(context),
                            _buildReportsTab(context),
                            _buildUsersTab(context),
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

  Widget _buildStatsGrid(BuildContext context, AdminDashboardStats stats) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 900) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.8,
          children: [
            _buildStatCard(
              context.l10n.admin_total_properties,
              '${stats.totalProperties}',
              Icons.apartment,
              AppColors.primary,
            ),
            _buildStatCard(
              context.l10n.admin_published_properties,
              '${stats.publishedProperties}',
              Icons.check_circle_outline,
              AppColors.success,
            ),
            _buildStatCard(
              context.l10n.admin_pending_review,
              '${stats.pendingProperties}',
              Icons.rate_review_outlined,
              Colors.amber.shade800,
            ),
            _buildStatCard(
              context.l10n.admin_total_users,
              '${stats.totalUsers}',
              Icons.people_outline,
              AppColors.primaryDark,
            ),
            _buildStatCard(
              context.l10n.admin_commission_records,
              '${stats.totalCommissions}',
              Icons.receipt_long,
              AppColors.accent,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    value,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Dedicated Section: Properties Awaiting Approval
  // ===========================================================================
  Widget _buildPendingPropertiesSection(BuildContext context) {
    final pendingAsync = ref.watch(pendingPropertiesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.amber.shade300, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.rate_review_rounded,
                    color: Colors.amber.shade900,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            context.l10n.admin_pending_title,
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          pendingAsync.maybeWhen(
                            data: (list) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: list.isNotEmpty
                                    ? Colors.amber.shade800
                                    : AppColors.success,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                list.isNotEmpty
                                    ? '${list.length} ${context.l10n.admin_awaiting_review}'
                                    : context.l10n.admin_review_complete,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            orElse: () => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      Text(
                        context.l10n.admin_pending_desc,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.l10n.admin_refresh_requests,
                  icon: Icon(Icons.refresh, color: AppColors.primaryInk),
                  onPressed: () {
                    ref.refresh(pendingPropertiesProvider);
                    ref.refresh(adminStatsProvider);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),

            // Section Body
            pendingAsync.when(
              data: (pendingList) {
                if (pendingList.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.success,
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.admin_no_pending,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final p = pendingList[index];
                    return _buildPendingPropertyCard(context, p);
                  },
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: LoadingView(
                    message: context.l10n.admin_loading_pending,
                  ),
                ),
              ),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.refresh(pendingPropertiesProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPropertyCard(BuildContext context, Property p) {
    final isRent = p.dealType == AppConstants.dealRent;
    final primaryImg = p.primaryImageUrl ??
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Image Thumbnail + Main Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: Image.network(
                    primaryImg,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.surfaceVariant,
                      child: Icon(
                        Icons.apartment,
                        size: 32,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isRent
                                ? const Color(0xFF0D9488)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRent ? context.l10n.admin_for_rent : context.l10n.admin_for_sale,
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.propertyType?.nameAr ?? p.propertyTypeId,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          Formatters.formatCurrency(p.price, p.currency),
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryInk,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${p.city} - ${p.district}',
                          style: GoogleFonts.cairo(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.square_foot,
                          size: 15,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${p.areaSqm} ${context.l10n.admin_sqm}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (p.bedrooms > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '• ${p.bedrooms} ${context.l10n.admin_rooms}',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Owner & Submission Info Panel
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withAlpha(100),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.primaryInk,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${context.l10n.admin_listing_owner}: ${p.owner?.fullName ?? context.l10n.admin_platform_user}',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: 16,
                        color: AppColors.primaryInk,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        p.contactPhone.isNotEmpty
                            ? p.contactPhone
                            : (p.owner?.phone ?? '-'),
                        style: GoogleFonts.cairo(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        Formatters.formatDate(p.createdAt),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Action Buttons: Approve & Publish vs Reject vs View Details
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.check_circle, size: 18),
                label: Text(
                  context.l10n.admin_approve_publish,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => _handleApproveProperty(context, p),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(
                  context.l10n.admin_reject_request,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => _handleRejectPropertyDialog(context, p),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.visibility_outlined, size: 18),
                label: Text(
                  context.l10n.admin_view_full_details,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
                onPressed: () => context.push('/property/${p.id}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleApproveProperty(BuildContext context, Property prop) async {
    try {
      final repo = ref.read(propertyRepositoryProvider);
      await repo.approvePropertyPublishing(prop.id);
      ref.refresh(pendingPropertiesProvider);
      ref.refresh(adminStatsProvider);
      ref.refresh(searchPropertiesProvider);
      ref.refresh(allMapPropertiesProvider);
      ref.refresh(propertiesForSaleProvider);
      ref.refresh(propertiesForRentProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.admin_approved_prefix}${prop.title}${context.l10n.admin_approved_suffix}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.admin_approve_failed}: ${e.toString()}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectPropertyDialog(BuildContext context, Property prop) async {
    final reasonController = TextEditingController(
      text: context.l10n.admin_default_reject_reason,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.cancel, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Text(
              context.l10n.admin_reject_dialog_title,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.admin_reject_reason_prompt,
              style: GoogleFonts.cairo(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: GoogleFonts.cairo(fontSize: 13),
              decoration: InputDecoration(
                hintText: context.l10n.admin_reject_hint,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.admin_cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.admin_confirm_reject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repo = ref.read(propertyRepositoryProvider);
        await repo.rejectPropertyPublishing(
          prop.id,
          reasonController.text.trim(),
        );
        ref.refresh(pendingPropertiesProvider);
        ref.refresh(adminStatsProvider);
        ref.refresh(searchPropertiesProvider);
        ref.refresh(allMapPropertiesProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.l10n.admin_reject_saved,
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${context.l10n.admin_reject_failed}: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }


  // ===========================================================================
  // 1. Properties Management Tab
  // ===========================================================================
  Widget _buildPropertiesTab(BuildContext context) {
    final searchAsync = ref.watch(searchPropertiesProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.admin_properties_list_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(context.l10n.admin_export_csv),
                  onPressed: () {
                    final list = searchAsync.value ?? [];
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportPropertiesToCsv(list);
                    _showCsvDialog(context, context.l10n.admin_export_properties_title, csvData);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: searchAsync.when(
                data: (properties) {
                  if (properties.isEmpty) {
                    return EmptyStateView(title: context.l10n.admin_no_properties);
                  }
                  return ListView.separated(
                    itemCount: properties.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final p = properties[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryMuted,
                          child: Icon(
                            p.isForRent ? Icons.key : Icons.sell,
                            color: AppColors.primaryInk,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          p.title,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${p.city} - ${p.district} • ${Formatters.formatCurrency(p.price, p.currency)} • ${context.l10n.admin_status_label}: ${AppConstants.getPropertyStatusNameAr(p.status)}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.propertyStatus(p.status),
                            if (p.status == AppConstants.statusPending) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: context.l10n.admin_approve_tooltip,
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  final repo = PropertyRepository();
                                  await repo.approvePropertyPublishing(p.id);
                                  ref.refresh(searchPropertiesProvider);
                                  ref.refresh(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.admin_approved_by_admin,
                                          style: GoogleFonts.cairo(),
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: context.l10n.admin_reject_request,
                                icon: const Icon(
                                  Icons.cancel,
                                  color: AppColors.error,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  final repo = PropertyRepository();
                                  await repo.rejectPropertyPublishing(
                                    p.id,
                                    context.l10n.admin_rejected_by_admin_review,
                                  );
                                  ref.refresh(searchPropertiesProvider);
                                  ref.refresh(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.l10n.admin_rejected_status_updated,
                                          style: GoogleFonts.cairo(),
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (action) async {
                                final repo = PropertyRepository();
                                if (action == 'approve') {
                                  await repo.approvePropertyPublishing(p.id);
                                } else if (action == 'reject') {
                                  await repo.rejectPropertyPublishing(
                                    p.id,
                                    context.l10n.admin_rejected_by_admin_review,
                                  );
                                } else if (action == 'hide') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusHidden,
                                  );
                                } else if (action == 'publish') {
                                  await repo.approvePropertyPublishing(p.id);
                                } else if (action == 'archive') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusArchived,
                                  );
                                } else if (action == 'delete') {
                                  await repo.deleteProperty(p.id);
                                }
                                ref.refresh(searchPropertiesProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                if (p.status == AppConstants.statusPending) ...[
                                  PopupMenuItem(
                                    value: 'approve',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(context.l10n.admin_approve_publish_menu),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'reject',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text(context.l10n.admin_reject_request),
                                      ],
                                    ),
                                  ),
                                ] else ...[
                                  PopupMenuItem(
                                    value:
                                        p.status == AppConstants.statusPublished
                                        ? 'hide'
                                        : 'publish',
                                    child: Text(
                                      p.status == AppConstants.statusPublished
                                          ? context.l10n.admin_hide_listing
                                          : context.l10n.admin_republish,
                                    ),
                                  ),
                                ],
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Text(context.l10n.admin_archive),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    context.l10n.admin_delete_permanent,
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. Rental Requests Tab
  // ===========================================================================
  Widget _buildRequestsTab(BuildContext context) {
    final requestsAsync = ref.watch(allRentalRequestsProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.admin_requests_list_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: const Icon(Icons.download, size: 16),
                  label: Text(context.l10n.admin_export_csv),
                  onPressed: () {
                    final list = requestsAsync.value ?? [];
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportRentalRequestsToCsv(list);
                    _showCsvDialog(context, context.l10n.admin_export_requests_title, csvData);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: requestsAsync.when(
                data: (requests) {
                  if (requests.isEmpty) {
                    return EmptyStateView(
                      title: context.l10n.admin_no_requests,
                    );
                  }
                  return ListView.separated(
                    itemCount: requests.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final req = requests[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.infoMuted,
                          child: const Icon(
                            Icons.assignment,
                            color: AppColors.info,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${req.requestNumber} - ${req.fullName}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_phone_label}: ${req.phone} • ${context.l10n.admin_property_label}: ${req.propertyTitle ?? req.propertyId}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.rentalRequest(req.status),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (newStatus) async {
                                await RentalRequestRepository()
                                    .updateRentalRequestStatus(
                                      requestId: req.id,
                                      status: newStatus,
                                    );
                                ref.refresh(allRentalRequestsProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: AppConstants.reqStatusUnderReview,
                                  child: Text(context.l10n.admin_status_under_review),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusContacted,
                                  child: Text(context.l10n.admin_status_contacted),
                                ),
                                PopupMenuItem(
                                  value: AppConstants
                                      .reqStatusProvisionallyAccepted,
                                  child: Text(context.l10n.admin_status_provisional),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusRejected,
                                  child: Text(context.l10n.admin_status_rejected),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.reqStatusCompleted,
                                  child: Text(context.l10n.admin_status_completed),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 3. Commissions Tab (Manual entry, liable: both/seller/buyer)
  // ===========================================================================
  Widget _buildCommissionsTab(BuildContext context) {
    final commissionsAsync = ref.watch(adminCommissionsProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.admin_commissions_list_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(context.l10n.admin_add_commission),
                      onPressed: () => _showAddCommissionModal(context),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('CSV'),
                      onPressed: () {
                        final list = commissionsAsync.value ?? [];
                        final csvData = ref
                            .read(adminRepositoryProvider)
                            .exportCommissionsToCsv(list);
                        _showCsvDialog(
                          context,
                          context.l10n.admin_export_commissions_title,
                          csvData,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: commissionsAsync.when(
                data: (commissions) {
                  if (commissions.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.receipt_long,
                      title: context.l10n.admin_no_commissions,
                      description: context.l10n.admin_commissions_desc,
                    );
                  }
                  return ListView.separated(
                    itemCount: commissions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final c = commissions[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.accentLight,
                          child: const Icon(
                            Icons.monetization_on,
                            color: AppColors.accentDark,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          '${Formatters.formatCurrency(c.totalAmount, c.currency)} - ${c.propertyTitle ?? context.l10n.admin_registered_property}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_liable_party}: ${AppConstants.getLiablePartyNameAr(c.liableParty)} • ${context.l10n.admin_settlement_method}: ${c.settlementMethod ?? context.l10n.admin_awaiting_collection}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.commission(c.settlementStatus),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (newStatus) async {
                                await CommissionRepository()
                                    .updateCommissionStatus(
                                      commissionId: c.id,
                                      status: newStatus,
                                    );
                                ref.refresh(adminCommissionsProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: AppConstants.commStatusPaid,
                                  child: Text(context.l10n.admin_status_paid),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.commStatusDue,
                                  child: Text(context.l10n.admin_status_due),
                                ),
                                PopupMenuItem(
                                  value: AppConstants.commStatusCancelled,
                                  child: Text(context.l10n.admin_status_cancelled),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Add Commission Modal
  void _showAddCommissionModal(BuildContext context) {
    final titleController = TextEditingController();
    final sellerAmountController = TextEditingController(text: '0');
    final buyerAmountController = TextEditingController(text: '0');
    final notesController = TextEditingController();
    String liableParty = AppConstants.liableBoth;
    String currency = AppConstants.currencyUsd;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: Text(
            context.l10n.admin_commission_modal_title,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.admin_commission_property_title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: context.l10n.admin_commission_property_hint,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_commission_liable,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: liableParty,
                    items: [
                      DropdownMenuItem(
                        value: AppConstants.liableBoth,
                        child: Text(context.l10n.admin_liable_both),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableSeller,
                        child: Text(context.l10n.admin_liable_seller),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableBuyer,
                        child: Text(context.l10n.admin_liable_buyer),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setModalState(() => liableParty = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.admin_seller_amount,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: sellerAmountController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.admin_buyer_amount,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: buyerAmountController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_currency,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: currency,
                    items: AppConstants.supportedCurrencies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c,
                            child: Text(AppConstants.getCurrencyNameAr(c)),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => currency = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Text(
                    context.l10n.admin_commission_notes,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(controller: notesController, maxLines: 2),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(context.l10n.admin_cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final sAmount =
                    double.tryParse(sellerAmountController.text) ?? 0;
                final bAmount =
                    double.tryParse(buyerAmountController.text) ?? 0;
                final total = sAmount + bAmount;

                final authUser = ref.read(authProvider).user;
                await CommissionRepository().createCommission(
                  propertyId: 'manual-prop',
                  propertyTitle: titleController.text.trim().isNotEmpty
                      ? titleController.text.trim()
                      : context.l10n.admin_registered_property,
                  liableParty: liableParty,
                  sellerAmount: sAmount,
                  buyerAmount: bAmount,
                  totalAmount: total,
                  currency: currency,
                  reasonAndNotes: notesController.text.trim(),
                  adminUserId: authUser?.id,
                );

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                ref.refresh(adminCommissionsProvider);
                ref.refresh(adminStatsProvider);
              },
              child: Text(context.l10n.admin_save_record),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 4. Reports Tab (Violating Ads Moderation)
  // ===========================================================================
  Widget _buildReportsTab(BuildContext context) {
    final reportsAsync = ref.watch(adminReportsProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.admin_reports_list_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Expanded(
              child: reportsAsync.when(
                data: (reports) {
                  if (reports.isEmpty) {
                    return EmptyStateView(
                      icon: Icons.check_circle_outline,
                      title: context.l10n.admin_no_reports,
                      description: context.l10n.admin_no_reports_desc,
                    );
                  }
                  return ListView.separated(
                    itemCount: reports.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final rep = reports[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.errorMuted,
                          child: const Icon(
                            Icons.flag,
                            color: AppColors.error,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          rep.reason,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_details_label}: ${rep.details ?? context.l10n.admin_none} • ${context.l10n.admin_status_label}: ${rep.status}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                              onPressed: () async {
                                final authUser = ref.read(authProvider).user;
                                await ReportRepository().updateReportStatus(
                                  reportId: rep.id,
                                  status: 'resolved',
                                  adminActionTaken: context.l10n.admin_verified_closed,
                                  adminId: authUser?.id,
                                );
                                ref.refresh(adminReportsProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              child: Text(context.l10n.admin_process),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // 5. Users Tab (Encrypted Privacy Protection - Super Admin Exclusive)
  // ===========================================================================
  Widget _buildUsersTab(BuildContext context) {
    final authUser = ref.watch(authProvider).user;
    final bool isSuperAdmin =
        authUser?.role == AppConstants.roleSuperAdmin ||
        authUser?.email == 'mo772522233@gmail.com' ||
        authUser?.id == 'admin-mohammed-saqqaf';

    if (!isSuperAdmin) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 54,
                  color: AppColors.error,
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.admin_encrypted_section_title,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.admin_encrypted_section_desc,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final usersAsync = ref.watch(allUsersProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryInk,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      context.l10n.admin_users_list_title,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.admin_gm_permissions,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.admin_data_protection,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: Colors.green.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      final accountEmail =
                          u.email ??
                          (u.phone != null && u.phone!.isNotEmpty
                              ? u.phone!
                              : u.id);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryMuted,
                          child: Text(
                            u.fullName.isNotEmpty ? u.fullName[0] : 'U',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryInk,
                            ),
                          ),
                        ),
                        title: Text(
                          u.fullName,
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          '${context.l10n.admin_account_label}: $accountEmail • ${context.l10n.admin_created_at}: ${u.createdAt.toString().split(' ').first}',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 12,
                                color: AppColors.primaryInk,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                context.l10n.admin_encrypted_protected,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const LoadingView(),
                error: (err, _) => ErrorView(message: err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Section Comprehensive PDF Export with Full Sana'a Time & Date
  // ===========================================================================
  Future<void> _exportCurrentSectionToPdf(BuildContext context) async {
    final l10n = context.l10n;
    final int currentTab = _tabController.index;
    final List<String> sectionTitles = [
      context.l10n.admin_tab_properties,
      context.l10n.admin_tab_requests,
      context.l10n.admin_tab_commissions,
      context.l10n.admin_tab_reports,
      context.l10n.admin_section_users,
    ];

    final sectionTitle = sectionTitles[currentTab];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${context.l10n.admin_pdf_preparing} $sectionTitle...',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
      final fontCairo = pw.Font.ttf(fontData);
      final fontCairoBold = pw.Font.ttf(fontData);
      if (!context.mounted) return;

      final now = DateTime.now();
      final arabicDays = [
        context.l10n.admin_day_monday,
        context.l10n.admin_day_tuesday,
        context.l10n.admin_day_wednesday,
        context.l10n.admin_day_thursday,
        context.l10n.admin_day_friday,
        context.l10n.admin_day_saturday,
        context.l10n.admin_day_sunday,
      ];
      final arabicMonths = [
        context.l10n.admin_month_january,
        context.l10n.admin_month_february,
        context.l10n.admin_month_march,
        context.l10n.admin_month_april,
        context.l10n.admin_month_may,
        context.l10n.admin_month_june,
        context.l10n.admin_month_july,
        context.l10n.admin_month_august,
        context.l10n.admin_month_september,
        context.l10n.admin_month_october,
        context.l10n.admin_month_november,
        context.l10n.admin_month_december,
      ];

      final dayName = arabicDays[now.weekday - 1];
      final dayNum = now.day;
      final monthName = arabicMonths[now.month - 1];
      final yearNum = now.year;
      final int rawHour = now.hour;
      final int hour12 = rawHour > 12
          ? rawHour - 12
          : (rawHour == 0 ? 12 : rawHour);
      final period = rawHour >= 12 ? context.l10n.admin_pm : context.l10n.admin_am;
      final minute = now.minute.toString().padLeft(2, '0');
      final timeFormatted = '$hour12:$minute $period ${context.l10n.admin_sanaa_time}';

      final pdf = pw.Document();

      // Prepare table data based on current active tab
      List<String> tableHeaders = [];
      List<List<String>> tableData = [];

      switch (currentTab) {
        case 0: // Properties
          final props = ref.read(searchPropertiesProvider).asData?.value ?? [];
          tableHeaders = [
            context.l10n.admin_col_property_id,
            context.l10n.admin_col_address,
            context.l10n.admin_col_deal,
            context.l10n.admin_col_city,
            context.l10n.admin_col_price,
            context.l10n.admin_status_label,
          ];
          tableData = props
              .map(
                (p) => [
                  p.id,
                  p.title,
                  AppConstants.getDealTypeNameAr(p.dealType),
                  p.city,
                  Formatters.formatCurrency(p.price, p.currency),
                  AppConstants.getPropertyStatusNameAr(p.status),
                ],
              )
              .toList();
          break;

        case 1: // Rental Requests
          final reqs = ref.read(allRentalRequestsProvider).asData?.value ?? [];
          tableHeaders = [
            context.l10n.admin_col_request_id,
            context.l10n.admin_property_label,
            context.l10n.admin_col_tenant,
            context.l10n.admin_col_phone,
            context.l10n.admin_col_start_date,
            context.l10n.admin_status_label,
          ];
          tableData = reqs
              .map(
                (r) => [
                  r.requestNumber,
                  r.propertyTitle ?? r.propertyId,
                  r.fullName,
                  r.phone,
                  r.requestedStartDate?.toIso8601String().split('T').first ??
                      '-',
                  AppConstants.getRentalRequestStatusNameAr(r.status),
                ],
              )
              .toList();
          break;

        case 2: // Commissions
          final comms = ref.read(adminCommissionsProvider).asData?.value ?? [];
          tableHeaders = [
            context.l10n.admin_col_id,
            context.l10n.admin_property_label,
            context.l10n.admin_liable_party,
            context.l10n.admin_col_amount,
            context.l10n.admin_currency,
            context.l10n.admin_col_settlement_status,
          ];
          tableData = comms
              .map(
                (c) => [
                  c.id,
                  c.propertyTitle ?? c.propertyId,
                  AppConstants.getLiablePartyNameAr(c.liableParty),
                  Formatters.formatCurrency(c.totalAmount, c.currency),
                  c.currency,
                  AppConstants.getCommissionStatusNameAr(c.settlementStatus),
                ],
              )
              .toList();
          break;

        case 3: // Reports
          final reps = ref.read(adminReportsProvider).asData?.value ?? [];
          tableHeaders = [
            context.l10n.admin_col_id,
            context.l10n.admin_col_property_id,
            context.l10n.admin_col_report_reason,
            context.l10n.admin_status_label,
            context.l10n.admin_col_report_date,
          ];
          tableData = reps
              .map(
                (rp) => [
                  rp.id,
                  rp.propertyId,
                  rp.reason,
                  rp.status == 'pending' ? context.l10n.admin_status_under_review : context.l10n.admin_status_resolved,
                  rp.createdAt.toIso8601String().split('T').first,
                ],
              )
              .toList();
          break;

        case 4: // Users
        default:
          final users = ref.read(allUsersProvider).asData?.value ?? [];
          tableHeaders = [
            context.l10n.admin_col_number,
            context.l10n.admin_col_username,
            context.l10n.admin_col_account_email,
            context.l10n.admin_col_encryption_status,
            context.l10n.admin_created_at,
          ];
          tableData = users.asMap().entries.map((entry) {
            final u = entry.value;
            final account =
                u.email ??
                (u.phone != null && u.phone!.isNotEmpty ? u.phone! : u.id);
            return [
              '${entry.key + 1}',
              u.fullName,
              account,
              context.l10n.admin_encrypted_protected_pdf,
              u.createdAt.toString().split(' ').first,
            ];
          }).toList();
          break;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      context.l10n.admin_pdf_bismillah,
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      context.l10n.admin_pdf_republic,
                      style: pw.TextStyle(
                        font: fontCairoBold,
                        fontSize: 13,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      context.l10n.admin_pdf_report_header,
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          '${context.l10n.admin_pdf_section}: $sectionTitle',
                          style: pw.TextStyle(
                            font: fontCairoBold,
                            fontSize: 10,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          context.l10n.admin_pdf_issuer,
                          style: pw.TextStyle(font: fontCairo, fontSize: 9.5),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    // تفاصيل الوقت واليوم والشهر والسنة
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${context.l10n.admin_pdf_day_label}: $dayName',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${context.l10n.admin_pdf_date_label}: $dayNum',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${context.l10n.admin_pdf_month_label}: $monthName (${now.month})',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${context.l10n.admin_pdf_year_label}: $yearNum ${context.l10n.admin_pdf_year_suffix}',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            '${context.l10n.admin_pdf_time_label}: $timeFormatted',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 12),

              // KPI Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    '${context.l10n.admin_pdf_total_items}: ${tableData.length}',
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 10),
                  ),
                  pw.Text(
                    context.l10n.admin_pdf_data_status,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Detailed Table
              pw.Table.fromTextArray(
                headers: tableHeaders,
                data: tableData.isEmpty
                    ? [
                        List.generate(
                          tableHeaders.length,
                          (_) => context.l10n.admin_pdf_no_data,
                        ),
                      ]
                    : tableData,
                headerStyle: pw.TextStyle(
                  font: fontCairoBold,
                  fontSize: 8.5,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.green800,
                ),
                cellStyle: pw.TextStyle(font: fontCairo, fontSize: 7.5),
                cellAlignment: pw.Alignment.centerRight,
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Divider(thickness: 0.5, color: PdfColors.grey400),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    context.l10n.admin_pdf_copyright,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    context.l10n.admin_pdf_doc_footer,
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ];
          },
        ),
      );

      final pdfBytes = await pdf.save();

      Directory? dir;
      try {
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            dir = downloadDir;
          } else {
            dir = await getExternalStorageDirectory();
          }
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
      } catch (_) {
        dir = await getApplicationDocumentsDirectory();
      }

      final filename =
          '${l10n.admin_report_filename_prefix}${sectionTitle.replaceAll(" ", "_")}_${now.year}_${now.month}_${now.day}_${now.hour}${now.minute}.pdf';
      final file = File('${dir!.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primaryInk,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.l10n.admin_pdf_export_success,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.l10n.admin_pdf_saved_prefix}$sectionTitle${context.l10n.admin_pdf_saved_suffix}',
                  style: GoogleFonts.cairo(fontSize: 13),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.admin_pdf_file_name,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        filename,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.admin_pdf_save_path,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      SelectableText(
                        file.path,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: Text(context.l10n.admin_copy_path, style: GoogleFonts.cairo()),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        context.l10n.admin_path_copied,
                        style: GoogleFonts.cairo(),
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text(
                  context.l10n.admin_ok,
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.admin_export_failed}: $e', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showCsvDialog(BuildContext context, String title, String csvContent) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 350),
          child: SingleChildScrollView(
            child: SelectableText(
              csvContent,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.copy, size: 18),
            label: Text(context.l10n.admin_copy_data, style: GoogleFonts.cairo()),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.l10n.admin_csv_copied,
                    style: GoogleFonts.cairo(),
                  ),
                  backgroundColor: AppColors.success,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(context.l10n.admin_close),
          ),
        ],
      ),
    );
  }
}
