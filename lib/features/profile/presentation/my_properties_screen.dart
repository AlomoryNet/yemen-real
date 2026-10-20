import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
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
        bottomNavigationBar: const AppBottomNavBar(currentRoute: '/my-properties'),
        body: Center(
          child: EmptyStateView(
            icon: Icons.apartment,
            title: 'تسجيل الدخول مطلوب',
            description:
                'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
            actionText: 'إنشاء حساب أو تسجيل الدخول',
            onAction: () => AuthPromptDialog.show(
              context,
              message:
                  'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
              redirectTo: '/my-properties',
            ),
          ),
        ),
      );
    }

    final userId = authState.user!.id;
    final myPropertiesAsync = ref.watch(userPropertiesProvider(userId));

    return Scaffold(
      appBar: const AppHeader(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/my-properties'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(
          'إضافة عقار جديد',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        onPressed: () => context.push('/add-property'),
      ),
      body: SingleChildScrollView(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'عقاراتي المعلنة',
                                style: GoogleFonts.cairo(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'إدارة عقاراتك، متابعة المشاهدات، وتعديل الحالة.',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            icon: const Icon(Icons.add_home_outlined, size: 18),
                            label: Text(
                              'أضف عقاراً',
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () => context.push('/add-property'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      myPropertiesAsync.when(
                        data: (properties) {
                          if (properties.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.apartment_outlined,
                              title: 'لم تقم بنشر أي عقار بعد',
                              description:
                                  'انشر أول عقار لك الآن مجاناً وابدأ باستقبال طلبات المهتمين مباشرة',
                              actionText: 'أضف عقارك الأول',
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
                                          Row(
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
                                          PopupMenuButton<String>(
                                            itemBuilder: (context) => [
                                              const PopupMenuItem(
                                                value: 'contract',
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .description_outlined,
                                                      size: 18,
                                                      color: AppColors.primary,
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text('تشكيل وطباعة العقد'),
                                                  ],
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'edit',
                                                child: Text('تعديل الإعلان'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'view',
                                                child: Text('عرض الإعلان'),
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
                                                      ? 'إخفاء الإعلان'
                                                      : 'إعادة النشر',
                                                ),
                                              ),
                                              const PopupMenuItem(
                                                value: 'archive',
                                                child: Text('أرشفة الإعلان'),
                                              ),
                                              const PopupMenuItem(
                                                value: 'delete',
                                                child: Text(
                                                  'حذف نهائي',
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
                                          Text(
                                            'المشاهدات: ${prop.viewsCount} • تاريخ الإضافة: ${Formatters.formatDate(prop.createdAt)}',
                                            style: GoogleFonts.cairo(
                                              fontSize: 11,
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/property/${prop.id}',
                                            ),
                                            child: const Text('معاينة'),
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
                            const LoadingView(message: 'جاري تحميل عقاراتك...'),
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
    );
  }
}
