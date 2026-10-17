import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minAreaController = TextEditingController();
  final TextEditingController _maxAreaController = TextEditingController();

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(propertyFilterProvider);
    if (filter.searchQuery != null) {
      _queryController.text = filter.searchQuery!;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    final notifier = ref.read(propertyFilterProvider.notifier);
    notifier.setSearchQuery(
      _queryController.text.trim().isNotEmpty
          ? _queryController.text.trim()
          : null,
    );
    final minP = double.tryParse(_minPriceController.text.trim());
    final maxP = double.tryParse(_maxPriceController.text.trim());
    notifier.setPriceRange(minP, maxP);
    final minA = double.tryParse(_minAreaController.text.trim());
    final maxA = double.tryParse(_maxAreaController.text.trim());
    notifier.setAreaRange(minA, maxA);
    ref.refresh(searchPropertiesProvider);
  }

  void _resetFilters() {
    _queryController.clear();
    _minPriceController.clear();
    _maxPriceController.clear();
    _minAreaController.clear();
    _maxAreaController.clear();
    ref.read(propertyFilterProvider.notifier).resetFilters();
    ref.refresh(searchPropertiesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(propertyFilterProvider);
    final searchResultsAsync = ref.watch(searchPropertiesProvider);
    final typesAsync = ref.watch(propertyTypesProvider);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      appBar: const AppHeader(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Top Bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _queryController,
                          decoration: InputDecoration(
                            hintText:
                                'ابحث بالعنوان، الحي، أو الكلمات الدلالية...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.primary,
                            ),
                            suffixIcon: _queryController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _queryController.clear();
                                      _applyFilters();
                                    },
                                  )
                                : null,
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                        ),
                        icon: const Icon(Icons.search, size: 18),
                        label: Text(
                          'بحث',
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        onPressed: _applyFilters,
                      ),
                      if (!isDesktop) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: _showFilters
                                ? AppColors.primaryMuted
                                : AppColors.surfaceVariant,
                            padding: const EdgeInsets.all(12),
                          ),
                          icon: Icon(
                            Icons.tune,
                            color: _showFilters
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _showFilters = !_showFilters),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.divider),

            // Main Body: Sidebar Filters (desktop) or dropdown (mobile) + Results Grid
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Desktop Filter Sidebar
                      if (isDesktop)
                        SizedBox(
                          width: 280,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: AppColors.divider),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: _buildFilterFields(
                                typesAsync,
                                filterState,
                              ),
                            ),
                          ),
                        ),

                      if (isDesktop) const SizedBox(width: 24),

                      // Results Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mobile Collapsible Filters
                            if (!isDesktop && _showFilters) ...[
                              Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: const BorderSide(
                                    color: AppColors.divider,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildFilterFields(
                                    typesAsync,
                                    filterState,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],

                            // Results Header & Sorting Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                searchResultsAsync.maybeWhen(
                                  data: (list) => Text(
                                    'تم العثور على ${list.length} عقار',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  orElse: () => Text(
                                    'نتائج البحث',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                // Sorting Dropdown
                                Row(
                                  children: [
                                    Text(
                                      'ترتيب حسب: ',
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    DropdownButton<String>(
                                      value: filterState.sortBy,
                                      underline: const SizedBox.shrink(),
                                      style: GoogleFonts.cairo(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'newest',
                                          child: Text('الأحدث'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'price_asc',
                                          child: Text('السعر: الأقل أولاً'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'price_desc',
                                          child: Text('السعر: الأعلى أولاً'),
                                        ),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          ref
                                              .read(
                                                propertyFilterProvider.notifier,
                                              )
                                              .setSortBy(val);
                                          ref.refresh(searchPropertiesProvider);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // Results List
                            searchResultsAsync.when(
                              data: (properties) =>
                                  _buildSearchResultsGrid(properties),
                              loading: () => const LoadingView(
                                message: 'جاري البحث في قاعدة البيانات...',
                              ),
                              error: (err, _) => ErrorView(
                                message: err.toString(),
                                onRetry: () =>
                                    ref.refresh(searchPropertiesProvider),
                              ),
                            ),
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

  Widget _buildFilterFields(
    AsyncValue<List<PropertyType>> typesAsync,
    PropertyFilterState filterState,
  ) {
    final notifier = ref.read(propertyFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'تصفية النتائج',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: _resetFilters,
              child: Text(
                'إعادة تعيين',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 10),

        // Deal Type
        Text(
          'نوع العملية',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('للبيع')),
                selected: filterState.dealType == AppConstants.dealSale,
                onSelected: (val) {
                  notifier.setDealType(val ? AppConstants.dealSale : null);
                  ref.refresh(searchPropertiesProvider);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('للإيجار')),
                selected: filterState.dealType == AppConstants.dealRent,
                onSelected: (val) {
                  notifier.setDealType(val ? AppConstants.dealRent : null);
                  ref.refresh(searchPropertiesProvider);
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Property Type
        Text(
          'نوع العقار',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        typesAsync.when(
          data: (types) => DropdownButtonFormField<String>(
            isExpanded: true,
            value: filterState.propertyTypeId,
            decoration: const InputDecoration(hintText: 'جميع الأنواع'),
            items: [
              const DropdownMenuItem(value: null, child: Text('جميع الأنواع')),
              ...types.map(
                (t) => DropdownMenuItem(value: t.id, child: Text(t.nameAr)),
              ),
            ],
            onChanged: (val) {
              notifier.setPropertyType(val);
              ref.refresh(searchPropertiesProvider);
            },
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // Governorate Filter
        Text(
          'المحافظة',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: filterState.city,
          isExpanded: true,
          decoration: const InputDecoration(hintText: 'كافة المحافظات'),
          items: [
            const DropdownMenuItem(value: null, child: Text('كافة المحافظات')),
            ...AppConstants.yemeniGovernorates.map(
              (gov) => DropdownMenuItem(value: gov, child: Text(gov)),
            ),
          ],
          onChanged: (val) {
            notifier.setCity(val);
            ref.refresh(searchPropertiesProvider);
          },
        ),

        const SizedBox(height: 16),

        // Price Range
        Text(
          'نطاق السعر',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'من'),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'إلى'),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Area Range
        Text(
          'المساحة (م²)',
          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _minAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'من'),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _maxAreaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'إلى'),
                onSubmitted: (_) => _applyFilters(),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Apply Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: const Text('تطبيق التصفية'),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultsGrid(List<Property> properties) {
    if (properties.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_outlined,
        title: 'لم يتم العثور على عقارات مطابقة',
        description:
            'جرب تعديل خيارات التصفية أو استخدام كلمات بحث أقل تحديداً',
        actionText: 'إعادة تعيين الفلاتر',
        onAction: _resetFilters,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth > 800) {
          crossAxisCount = 2;
        }
        if (constraints.maxWidth > 1100) {
          crossAxisCount = 3;
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
}
