import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rental_request_provider.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
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
        appBar: const AppHeader(),
        body: Center(
          child: EmptyStateView(
            icon: Icons.lock_outline,
            title: 'يرجى تسجيل الدخول',
            description:
                'سجّل الدخول إلى حسابك لتتمكن من استعراض ومتابعة طلبات الاستئجار الخاصة بك',
            actionText: 'تسجيل الدخول',
            onAction: () => context.push('/login'),
          ),
        ),
      );
    }

    final requestsAsync = ref.watch(userRentalRequestsProvider);

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
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
                        'طلبات الاستئجار الخاصة بي',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'تابع حالة طلباتك واستفساراتك المقدمة للعقارات المعروضة للإيجار.',
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
                              title: 'لا توجد طلبات استئجار سابقة',
                              description:
                                  'تصفح العقارات المتاحة للإيجار وأرسل طلب استئجار مبدئي',
                              actionText: 'تصفح عقارات الإيجار',
                              onAction: () => context.push('/search'),
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
                                  side: const BorderSide(
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
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                          StatusBadge.rentalRequest(req.status),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        req.propertyTitle ?? 'عقار للإيجار',
                                        style: GoogleFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 14,
                                            color: AppColors.textMuted,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'تاريخ البدء المطلوب: ${req.requestedStartDate != null ? Formatters.formatDate(req.requestedStartDate) : 'غير محدد'}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (req.notes != null &&
                                          req.notes!.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        Text(
                                          'ملاحظاتك: ${req.notes}',
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
                                                  'رد المالك/الإدارة: ${req.adminNotes}',
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
                                          Text(
                                            'تاريخ الإرسال: ${Formatters.formatDateTime(req.createdAt)}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/property/${req.propertyId}',
                                            ),
                                            child: const Text('عرض العقار'),
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
                            const LoadingView(message: 'جاري تحميل طلباتك...'),
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
    );
  }
}
