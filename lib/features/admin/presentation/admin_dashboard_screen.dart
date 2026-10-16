import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
                              'صلاحيات موحدة: ويب وهاتف',
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

                      // Tabs for Admin Sections
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
                            fontSize: 14,
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
                              text: 'المستخدمين',
                            ),
                          ],
                        ),
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
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              onSelected: (action) async {
                                final repo = PropertyRepository();
                                if (action == 'hide') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusHidden,
                                  );
                                } else if (action == 'publish') {
                                  await repo.updatePropertyStatus(
                                    p.id,
                                    AppConstants.statusPublished,
                                  );
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
  // 5. Users Tab
  // ===========================================================================
  Widget _buildUsersTab(BuildContext context) {
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
                Text(
                  'إدارة المستخدمين والأدوار',
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
              child: usersAsync.when(
                data: (users) {
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryMuted,
                          child: Text(
                            u.fullName.isNotEmpty ? u.fullName[0] : 'U',
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
                          '${u.phone ?? "بدون هاتف"} • الدور: ${u.role}',
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: u.isAdmin
                                ? AppColors.accentLight
                                : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            u.isAdmin ? 'مدير' : 'مستخدم',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: u.isAdmin
                                  ? AppColors.accentDark
                                  : AppColors.textSecondary,
                            ),
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
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
