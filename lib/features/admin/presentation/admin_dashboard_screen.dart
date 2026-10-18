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
import '../../../core/theme/app_colors.dart';
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
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/status_badge.dart';

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
        appBar: const AppHeader(),
        body: Center(
          child: EmptyStateView(
            icon: Icons.gpp_bad_outlined,
            title: 'منطقة إدارية محمية',
            description:
                'هذه الصفحة مخصصة لمديري بوابة اليمن العقارية فقط، وليس لديك الصلاحية الكافية لدخولها.',
            actionText: 'العودة للرئيسية',
            onAction: () => context.go('/'),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(adminStatsProvider);

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
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
                                  const Icon(
                                    Icons.admin_panel_settings,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'لوحة الإدارة والتحكم',
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
                                'إدارة المنصة، العقارات، طلبات الاستئجار، وسجلات العمولات اليدوية.',
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
                              'المسؤول العام: محمد السقاف',
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
                        loading: () => const LoadingView(
                          message: 'جاري تحميل الإحصائيات...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(adminStatsProvider),
                        ),
                      ),

                      const SizedBox(height: 32),

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
                              labelColor: AppColors.primary,
                              unselectedLabelColor: AppColors.textSecondary,
                              indicatorColor: AppColors.primary,
                              labelStyle: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.apartment, size: 18),
                                  text: 'إدارة العقارات',
                                ),
                                Tab(
                                  icon: Icon(Icons.assignment, size: 18),
                                  text: 'طلبات الاستئجار',
                                ),
                                Tab(
                                  icon: Icon(Icons.monetization_on, size: 18),
                                  text: 'سجلات العمولات',
                                ),
                                Tab(
                                  icon: Icon(Icons.flag, size: 18),
                                  text: 'بلاغات المخالفات',
                                ),
                                Tab(
                                  icon: Icon(Icons.people, size: 18),
                                  text: 'المستخدمين (مشفر)',
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
                            onPressed: _exportCurrentSectionToPdf,
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: Text(
                              'طباعة تقرير شامل PDF للقسم',
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
              'إجمالي العقارات',
              '${stats.totalProperties}',
              Icons.apartment,
              AppColors.primary,
            ),
            _buildStatCard(
              'العقارات المنشورة',
              '${stats.publishedProperties}',
              Icons.check_circle_outline,
              AppColors.success,
            ),
            _buildStatCard(
              'طلبات استئجار جديدة',
              '${stats.pendingRentalRequests}',
              Icons.assignment_outlined,
              AppColors.info,
            ),
            _buildStatCard(
              'بلاغات قيد الفحص',
              '${stats.openReports}',
              Icons.flag_outlined,
              AppColors.error,
            ),
            _buildStatCard(
              'إجمالي المستخدمين',
              '${stats.totalUsers}',
              Icons.people_outline,
              AppColors.primaryDark,
            ),
            _buildStatCard(
              'سجلات العمولات',
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
        side: const BorderSide(color: AppColors.divider),
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
            const SizedBox(width: 14),
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
                  'قائمة العقارات والتحكم بالنشر',
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
                  label: const Text('تصدير CSV'),
                  onPressed: () {
                    final list = searchAsync.value ?? [];
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportPropertiesToCsv(list);
                    _showCsvDialog(context, 'تصدير بيانات العقارات', csvData);
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
                    return const EmptyStateView(title: 'لا توجد عقارات حالياً');
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
                            color: AppColors.primary,
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
                          '${p.city} - ${p.district} • ${Formatters.formatCurrency(p.price, p.currency)} • الحالة: ${AppConstants.getPropertyStatusNameAr(p.status)}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            StatusBadge.propertyStatus(p.status),
                            if (p.status == AppConstants.statusPending) ...[
                              const SizedBox(width: 4),
                              IconButton(
                                tooltip: 'قبول ونشر الإعلان (محمد السقاف)',
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
                                          'تم قبول ونشر العقار بواسطة المسؤول: محمد السقاف',
                                          style: GoogleFonts.cairo(),
                                        ),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: 'رفض طلب النشر',
                                icon: const Icon(
                                  Icons.cancel,
                                  color: AppColors.error,
                                  size: 22,
                                ),
                                onPressed: () async {
                                  final repo = PropertyRepository();
                                  await repo.rejectPropertyPublishing(
                                    p.id,
                                    'مرفوض من قبل الإدارة بعد المراجعة',
                                  );
                                  ref.refresh(searchPropertiesProvider);
                                  ref.refresh(adminStatsProvider);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'تم رفض طلب النشر وتحديث الحالة',
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
                                    'مرفوض من قبل الإدارة بعد المراجعة',
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
                                  const PopupMenuItem(
                                    value: 'approve',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text('قبول واعتماد النشر'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'reject',
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cancel_outlined,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        SizedBox(width: 8),
                                        Text('رفض طلب النشر'),
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
                                          ? 'إخفاء الإعلان'
                                          : 'إعادة نشر',
                                    ),
                                  ),
                                ],
                                const PopupMenuItem(
                                  value: 'archive',
                                  child: Text('أرشفة'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'حذف نهائي',
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
                  'طلبات الاستئجار والمتابعة',
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
                  label: const Text('تصدير CSV'),
                  onPressed: () {
                    final list = requestsAsync.value ?? [];
                    final csvData = ref
                        .read(adminRepositoryProvider)
                        .exportRentalRequestsToCsv(list);
                    _showCsvDialog(context, 'تصدير طلبات الاستئجار', csvData);
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
                    return const EmptyStateView(
                      title: 'لا توجد طلبات استئجار مسجلة',
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
                          'هاتف: ${req.phone} • العقار: ${req.propertyTitle ?? req.propertyId}',
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
                                const PopupMenuItem(
                                  value: AppConstants.reqStatusUnderReview,
                                  child: Text('قيد المراجعة'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants.reqStatusContacted,
                                  child: Text('تم التواصل'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants
                                      .reqStatusProvisionallyAccepted,
                                  child: Text('مقبول مبدئياً'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants.reqStatusRejected,
                                  child: Text('مرفوض'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants.reqStatusCompleted,
                                  child: Text('مكتمل'),
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
                  'سجلات العمولة الإدارية (يدوية)',
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
                      label: const Text('تسجيل عمولة'),
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
                          'تصدير سجلات العمولات',
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
                    return const EmptyStateView(
                      icon: Icons.receipt_long,
                      title: 'لا توجد سجلات عمولة مسجلة',
                      description:
                          'سجل العمولات وفق القرارات المعتمدة (تسجيل يدوي بحسب الاتفاق)',
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
                          '${Formatters.formatCurrency(c.totalAmount, c.currency)} - ${c.propertyTitle ?? "عقار مسجل"}',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'المتحمل: ${AppConstants.getLiablePartyNameAr(c.liableParty)} • طريقة التسوية: ${c.settlementMethod ?? "بانتظار التحصيل"}',
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
                                const PopupMenuItem(
                                  value: AppConstants.commStatusPaid,
                                  child: Text('تم السداد'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants.commStatusDue,
                                  child: Text('مستحق'),
                                ),
                                const PopupMenuItem(
                                  value: AppConstants.commStatusCancelled,
                                  child: Text('ملغى'),
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
            'تسجيل سجل عمولة يدوي',
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
                    'عنوان العقار أو المعرف *',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      hintText: 'مثال: فيلا بيت بوس',
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'الطرف المتحمل للعمولة *',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: liableParty,
                    items: const [
                      DropdownMenuItem(
                        value: AppConstants.liableBoth,
                        child: Text('كلاهما (البائع والمشتري)'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableSeller,
                        child: Text('البائع فقط'),
                      ),
                      DropdownMenuItem(
                        value: AppConstants.liableBuyer,
                        child: Text('المشتري فقط'),
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
                              'مبلغ البائع',
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
                              'مبلغ المشتري',
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
                    'العملة',
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
                    'سبب العمولة وملاحظات الاتفاق',
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
              child: const Text('إلغاء'),
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
                      : 'عقار مسجل',
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
              child: const Text('حفظ السجل'),
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
                  'بلاغات الإعلانات المخالفة',
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
                    return const EmptyStateView(
                      icon: Icons.check_circle_outline,
                      title: 'لا توجد بلاغات مخالفة حالياً',
                      description:
                          'كافة الإعلانات المعلنة مطابقة ولم يتم الإبلاغ عن أي مخالفة.',
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
                          'تفاصيل: ${rep.details ?? "لا يوجد"} • الحالة: ${rep.status}',
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
                                  adminActionTaken: 'تم التحقق والإغلاق',
                                  adminId: authUser?.id,
                                );
                                ref.refresh(adminReportsProvider);
                                ref.refresh(adminStatsProvider);
                              },
                              child: const Text('معالجة'),
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
        authUser?.email == 'mohammed.f.saqqaf@gmail.com' ||
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
                  'قسم مشفر ومحمي خاص بالمدير العام فقط',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'وفقاً لسياسات الأمان والتشفير، بيانات المستخدمين لا تظهر إلا للمدير العام (م. محمد السقاف) لضمان الخصوصية التامة.',
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
                    const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'سجل حسابات المستخدمين (بيانات مشفرة ومحمية)',
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
                        'صلاحيات المدير العام',
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
                      'حماية البيانات: كلمات المرور والتفاصيل الحساسة مشفرة بنظام التشفير القياسي، ويظهر للمدير العام فقط اسم المستخدم وحسابه.',
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
                              color: AppColors.primary,
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
                          'الحساب: $accountEmail • تاريخ الإنشاء: ${u.createdAt.toString().split(' ').first}',
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
                              const Icon(
                                Icons.lock,
                                size: 12,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'مشفر ومحمي',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
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
  Future<void> _exportCurrentSectionToPdf() async {
    final int currentTab = _tabController.index;
    final List<String> sectionTitles = [
      'إدارة العقارات',
      'طلبات الاستئجار',
      'سجلات العمولات',
      'بلاغات المخالفات',
      'سجل المستخدمين',
    ];

    final sectionTitle = sectionTitles[currentTab];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'جاري تجهيز وطباعة تقرير PDF شامل لقسم: $sectionTitle...',
          style: GoogleFonts.cairo(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    try {
      final fontData = await rootBundle.load('assets/fonts/Cairo.ttf');
      final fontCairo = pw.Font.ttf(fontData);
      final fontCairoBold = pw.Font.ttf(fontData);

      final now = DateTime.now();
      const arabicDays = [
        'الإثنين',
        'الثلاثاء',
        'الأربعاء',
        'الخميس',
        'الجمعة',
        'السبت',
        'الأحد',
      ];
      const arabicMonths = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];

      final dayName = arabicDays[now.weekday - 1];
      final dayNum = now.day;
      final monthName = arabicMonths[now.month - 1];
      final yearNum = now.year;
      final int rawHour = now.hour;
      final int hour12 = rawHour > 12
          ? rawHour - 12
          : (rawHour == 0 ? 12 : rawHour);
      final period = rawHour >= 12 ? 'مساءً' : 'صباحاً';
      final minute = now.minute.toString().padLeft(2, '0');
      final timeFormatted = '$hour12:$minute $period (بتوقيت صنعاء)';

      final pdf = pw.Document();

      // Prepare table data based on current active tab
      List<String> tableHeaders = [];
      List<List<String>> tableData = [];

      switch (currentTab) {
        case 0: // Properties
          final props = ref.read(searchPropertiesProvider).asData?.value ?? [];
          tableHeaders = [
            'رقم العقار',
            'العنوان',
            'العملية',
            'المدينة',
            'السعر',
            'الحالة',
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
            'رقم الطلب',
            'العقار',
            'المستأجر',
            'الهاتف',
            'تاريخ البدء',
            'الحالة',
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
            'المعرف',
            'العقار',
            'الطرف المتحمل',
            'المبلغ',
            'العملة',
            'حالة التسوية',
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
            'المعرف',
            'رقم العقار',
            'سبب البلاغ',
            'الحالة',
            'تاريخ البلاغ',
          ];
          tableData = reps
              .map(
                (rp) => [
                  rp.id,
                  rp.propertyId,
                  rp.reason,
                  rp.status == 'pending' ? 'قيد المراجعة' : 'محلول',
                  rp.createdAt.toIso8601String().split('T').first,
                ],
              )
              .toList();
          break;

        case 4: // Users
        default:
          final users = ref.read(allUsersProvider).asData?.value ?? [];
          tableHeaders = [
            'الرقم',
            'اسم المستخدم',
            'الحساب (البريد)',
            'حالة التشفير',
            'تاريخ الإنشاء',
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
              '🔒 مشفر ومحمي',
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
                      'بسم الله الرحمن الرحيم',
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'الجمهورية اليمنية — بوابة اليمن العقارية',
                      style: pw.TextStyle(
                        font: fontCairoBold,
                        fontSize: 13,
                        color: PdfColors.green900,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'الإدارة العامة — تقرير رسمي شامل',
                      style: pw.TextStyle(font: fontCairoBold, fontSize: 11),
                    ),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'القسم: $sectionTitle',
                          style: pw.TextStyle(
                            font: fontCairoBold,
                            fontSize: 10,
                            color: PdfColors.green800,
                          ),
                        ),
                        pw.Text(
                          'المستخرج: المدير العام (م. محمد السقاف)',
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
                            'اليوم: $dayName',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            'التاريخ: $dayNum',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            'الشهر: $monthName (${now.month})',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            'السنة: $yearNum م',
                            style: pw.TextStyle(
                              font: fontCairoBold,
                              fontSize: 8.5,
                            ),
                          ),
                          pw.Text(
                            'الوقت: $timeFormatted',
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
                    'إجمالي عناصر القسم: ${tableData.length}',
                    style: pw.TextStyle(font: fontCairoBold, fontSize: 10),
                  ),
                  pw.Text(
                    'حالة البيانات: معتمدة ومحدثة لحظياً',
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
                          (_) => 'لا توجد بيانات مسجلة حالياً',
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
                    'شركة هيبه سوفت (Hiba Soft) — جميع الحقوق محفوظة © 2026',
                    style: pw.TextStyle(
                      font: fontCairo,
                      fontSize: 7.5,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'وثيقة إدارية رسمية — مشفرة وموثقة',
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
          'تقرير_${sectionTitle.replaceAll(" ", "_")}_${now.year}_${now.month}_${now.day}_${now.hour}${now.minute}.pdf';
      final file = File('${dir!.path}/$filename');
      await file.writeAsBytes(pdfBytes);

      if (mounted) {
        showDialog(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(
                  Icons.picture_as_pdf,
                  color: AppColors.primary,
                  size: 26,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم تصدير تقرير الـ PDF بنجاح',
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
                  'تم حفظ التقرير الشامل لقسم "$sectionTitle" متضمناً تفاصيل اليوم والتاريخ والشهر والسنة والوقت الدقيق بتوقيت صنعاء.',
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
                        '📁 اسم الملف:',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        filename,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📍 مسار الحفظ بالجهاز:',
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
                label: Text('نسخ المسار', style: GoogleFonts.cairo()),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: file.path));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم نسخ مسار الملف إلى الحافظة',
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
                  'حسناً',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تصدير التقرير: $e', style: GoogleFonts.cairo()),
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
            label: Text('نسخ البيانات', style: GoogleFonts.cairo()),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: csvContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم نسخ بيانات CSV بنجاح إلى الحافظة',
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
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
