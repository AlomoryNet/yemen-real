import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../models/property_type.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../shared/widgets/app_footer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/property_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedDealType = ''; // '' for all, 'sale', 'rent'
  String? _selectedTypeId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmit() {
    final filterNotifier = ref.read(propertyFilterProvider.notifier);
    filterNotifier.resetFilters();
    if (_searchController.text.trim().isNotEmpty) {
      filterNotifier.setSearchQuery(_searchController.text.trim());
    }
    if (_selectedDealType.isNotEmpty) {
      filterNotifier.setDealType(_selectedDealType);
    }
    if (_selectedTypeId != null) {
      filterNotifier.setPropertyType(_selectedTypeId);
    }
    context.push('/search');
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(propertyTypesProvider);
    final featuredAsync = ref.watch(featuredPropertiesProvider);
    final forSaleAsync = ref.watch(propertiesForSaleProvider);
    final forRentAsync = ref.watch(propertiesForRentProvider);

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Search Section
            _buildHeroSection(typesAsync),

            // Content Container
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
                      // Featured Properties Section
                      _buildSectionHeader(
                        title: 'عقارات مميزة',
                        subtitle: 'مختارات عقارية موثوقة ومميزة في اليمن',
                        onViewAll: () {
                          ref
                              .read(propertyFilterProvider.notifier)
                              .resetFilters();
                          context.push('/search');
                        },
                      ),
                      const SizedBox(height: 16),
                      featuredAsync.when(
                        data: (properties) => _buildPropertyGrid(properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل العقارات المميزة...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () =>
                              ref.refresh(featuredPropertiesProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Properties For Sale Section
                      _buildSectionHeader(
                        title: 'أحدث العقارات للبيع',
                        subtitle: 'شقق، فلل، وأراضٍ معروضة للبيع المباشر',
                        onViewAll: () {
                          final f = ref.read(propertyFilterProvider.notifier);
                          f.resetFilters();
                          f.setDealType(AppConstants.dealSale);
                          context.push('/search');
                        },
                      ),
                      const SizedBox(height: 16),
                      forSaleAsync.when(
                        data: (properties) => _buildPropertyGrid(properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل عقارات للبيع...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(propertiesForSaleProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Properties For Rent Section
                      _buildSectionHeader(
                        title: 'أحدث العقارات للإيجار',
                        subtitle: 'شقق سكنية ومقرات تجارية جاهزة للإيجار',
                        onViewAll: () {
                          final f = ref.read(propertyFilterProvider.notifier);
                          f.resetFilters();
                          f.setDealType(AppConstants.dealRent);
                          context.push('/search');
                        },
                      ),
                      const SizedBox(height: 16),
                      forRentAsync.when(
                        data: (properties) => _buildPropertyGrid(properties),
                        loading: () => const LoadingView(
                          message: 'جاري تحميل عقارات للإيجار...',
                        ),
                        error: (err, _) => ErrorView(
                          message: err.toString(),
                          onRetry: () => ref.refresh(propertiesForRentProvider),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Publisher Call-To-Action Banner
                      _buildPublisherCta(context),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            const AppFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(AsyncValue<List<PropertyType>> typesAsync) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accent.withAlpha(120)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified,
                      size: 16,
                      color: AppColors.accentLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'المنصة العقارية الموثوقة في اليمن',
                      style: GoogleFonts.cairo(
                        color: AppColors.textLight,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Hero Title
              Text(
                'ابحث عن عقارك المثالي في اليمن',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: Responsive.isMobile(context) ? 26 : 38,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'آلاف الشقق والفلل والأراضي والمحلات التجارية المعروضة للبيع أو الإيجار مباشرة من المالك',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: Responsive.isMobile(context) ? 13 : 16,
                  color: AppColors.textLight.withAlpha(210),
                ),
              ),
              const SizedBox(height: 28),

              // Search Box Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Deal type tabs (الكل, للبيع, للإيجار)
                    Row(
                      children: [
                        _buildDealTypeTab('الكل', ''),
                        const SizedBox(width: 8),
                        _buildDealTypeTab(
                          'عقارات للبيع',
                          AppConstants.dealSale,
                        ),
                        const SizedBox(width: 8),
                        _buildDealTypeTab(
                          'عقارات للإيجار',
                          AppConstants.dealRent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Search input & button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'ابحث بالحي، المدينة، أو الكلمات الدلالية (مثال: شقة حدة)...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => _onSearchSubmit(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _onSearchSubmit,
                          child: Row(
                            children: [
                              const Icon(Icons.tune, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'بحث',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Property Type Filter Chips
              typesAsync.when(
                data: (types) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: types.map((type) {
                    final isSelected = _selectedTypeId == type.id;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(type.nameAr),
                      labelStyle: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.white70,
                      ),
                      backgroundColor: Colors.white.withAlpha(25),
                      selectedColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? AppColors.accent : Colors.white24,
                        ),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedTypeId = selected ? type.id : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDealTypeTab(String label, String value) {
    final isSelected = _selectedDealType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDealType = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: onViewAll,
          icon: const Icon(Icons.arrow_back, size: 16),
          label: Text(
            'عرض الكل',
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyGrid(List<Property> properties) {
    if (properties.isEmpty) {
      return const EmptyStateView(
        title: 'لا توجد عقارات في هذا القسم حالياً',
        description: 'تابع الإعلانات المضافة قريباً أو ابحث في الأقسام الأخرى',
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
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            return PropertyCard(property: properties[index]);
          },
        );
      },
    );
  }

  Widget _buildPublisherCta(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Responsive(
        mobile: Column(
          children: [
            Text(
              'هل تمتلك عقاراً ترغب في بيعه أو تأجيره؟',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انشر إعلانك مجاناً عبر بوابة اليمن العقارية وتواصل مباشرة مع آلاف الباحثين عن عقارات.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.push('/add-property'),
              child: const Text('أضف إعلانك الآن'),
            ),
          ],
        ),
        desktop: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'هل تمتلك عقاراً ترغب في بيعه أو تأجيره؟',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'انشر إعلانك عبر بوابة اليمن العقارية بميزة المراجعة الذاتية الفورية والتواصل المباشر مع العملاء.',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
              icon: const Icon(Icons.add_home_outlined),
              label: Text(
                'أضف إعلانك الآن',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onPressed: () => context.push('/add-property'),
            ),
          ],
        ),
      ),
    );
  }
}
