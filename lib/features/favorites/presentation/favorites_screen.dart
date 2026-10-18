import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/favorites_provider.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/auth_prompt_dialog.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/property_card.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      return Scaffold(
        appBar: const AppHeader(),
        body: Center(
          child: EmptyStateView(
            icon: Icons.favorite_border,
            title: 'تسجيل الدخول مطلوب',
            description:
                'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
            actionText: 'إنشاء حساب أو تسجيل الدخول',
            onAction: () => AuthPromptDialog.show(
              context,
              message:
                  'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.',
              redirectTo: '/favorites',
            ),
          ),
        ),
      );
    }

    final favoritesAsync = ref.watch(favoritesProvider);

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
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'العقارات المفضلة',
                        style: GoogleFonts.cairo(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'العقارات التي قمت بحفظها لسهولة الرجوع إليها ومقارنتها.',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      favoritesAsync.when(
                        data: (properties) {
                          if (properties.isEmpty) {
                            return EmptyStateView(
                              icon: Icons.favorite_border,
                              title: 'لا توجد عقارات في المفضلة',
                              description:
                                  'يمكنك إضافة أي عقار إلى قائمتك بالنقر على أيقونة القلب في بطاقة العقار',
                              actionText: 'تصفح العقارات الآن',
                              onAction: () => context.push('/search'),
                            );
                          }

                          return LayoutBuilder(
                            builder: (context, constraints) {
                              int crossAxisCount = 1;
                              if (constraints.maxWidth > 960) {
                                crossAxisCount = 3;
                              } else if (constraints.maxWidth > 640) {
                                crossAxisCount = 2;
                              }

                              return GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: properties.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.85,
                                    ),
                                itemBuilder: (context, index) {
                                  return PropertyCard(
                                    property: properties[index],
                                  );
                                },
                              );
                            },
                          );
                        },
                        loading: () => const LoadingView(
                          message: 'جاري تحميل قائمة المفضلة...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref
                              .read(favoritesProvider.notifier)
                              .loadFavorites(),
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
