import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property_type.dart';

/// Hero section of the dashboard: gradient banner with title, search box,
/// deal-type tabs, governorate selector, quick governorate/district pills,
/// a map CTA banner, and property-type chips.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({
    super.key,
    required this.typesAsync,
    required this.searchController,
    required this.selectedDealType,
    required this.selectedTypeId,
    required this.selectedGovernorate,
    required this.onSearchSubmit,
    required this.onDealTypeChanged,
    required this.onTypeToggled,
    required this.onGovernorateToggled,
    required this.onGovernoratePickerRequested,
    required this.onDistrictChosen,
  });

  final AsyncValue<List<PropertyType>> typesAsync;
  final TextEditingController searchController;
  final String selectedDealType;
  final String? selectedTypeId;
  final String? selectedGovernorate;
  final VoidCallback onSearchSubmit;
  final ValueChanged<String> onDealTypeChanged;
  final ValueChanged<String?> onTypeToggled;
  final ValueChanged<String?> onGovernorateToggled;
  final VoidCallback onGovernoratePickerRequested;
  final ValueChanged<String> onDistrictChosen;

  @override
  Widget build(BuildContext context) {
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
                    // Deal type tabs & Governorate Selector Button
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
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
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Governorate Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onGovernoratePickerRequested,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selectedGovernorate != null
                                    ? AppColors.primaryMuted
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedGovernorate != null
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: selectedGovernorate != null
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedGovernorate ?? 'المحافظة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: selectedGovernorate != null
                                          ? AppColors.primaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Quick Governorates Horizontal Pills Bar
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildGovernoratePill('كافة المحافظات', null),
                          const SizedBox(width: 6),
                          ...[
                            'صنعاء',
                            'عدن',
                            'تعز',
                            'حضرموت',
                            'إب',
                            'مأرب',
                            'الحديدة',
                            'ذمار',
                          ].map(
                            (gov) => Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: _buildGovernoratePill(gov, gov),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Search input & button
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: selectedGovernorate != null
                                  ? 'ابحث في $selectedGovernorate (مثال: حي حدة، شقة)...'
                                  : 'ابحث بالحي، المدينة، أو الكلمات الدلالية (مثال: شقة حدة)...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.primary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            onSubmitted: (_) => onSearchSubmit(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: onSearchSubmit,
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 18),
                              const SizedBox(width: 4),
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

                    // Quick Districts pills for active governorate
                    if (selectedGovernorate != null)
                      Builder(
                        builder: (context) {
                          final districts =
                              AppConstants.getDistrictsForGovernorate(
                                selectedGovernorate!,
                              );
                          if (districts.isEmpty) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  Text(
                                    'أحياء ومناطق $selectedGovernorate: ',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  ...districts.take(8).map((dist) {
                                    final isDistrictChosen =
                                        searchController.text.trim() == dist;
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: ActionChip(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        backgroundColor: isDistrictChosen
                                            ? AppColors.primaryMuted
                                            : AppColors.surfaceVariant,
                                        label: Text(
                                          dist,
                                          style: GoogleFonts.cairo(
                                            fontSize: 11,
                                            fontWeight: isDistrictChosen
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isDistrictChosen
                                                ? AppColors.primaryDark
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        onPressed: () {
                                          onDistrictChosen(dist);
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),

              // Yemen Map Banner
              InkWell(
                onTap: () => context.go('/map'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withAlpha(50)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.map_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'استكشف عقارات اليمن على الخريطة التفاعلية 🇾🇪',
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'تصفح الأسعار والمواقع مباشرة في صنعاء، إب، تعز، وكافة المحافظات',
                              style: GoogleFonts.cairo(
                                color: AppColors.textLight.withAlpha(210),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Property Type Filter Chips
              typesAsync.when(
                data: (types) => Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: types.map((type) {
                    final isSelected = selectedTypeId == type.id;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          onTypeToggled(isSelected ? null : type.id);
                        },
                        borderRadius: BorderRadius.circular(24),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : const Color(0xFF0B2D21).withAlpha(230),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFD54F)
                                  : Colors.white.withAlpha(70),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AppColors.accent.withAlpha(120)
                                    : Colors.black.withAlpha(40),
                                blurRadius: isSelected ? 10 : 4,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getTypeIcon(type.id),
                                size: 17,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFFFD54F),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type.nameAr,
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  IconData _getTypeIcon(String id) {
    switch (id) {
      case 'apartment':
        return Icons.apartment;
      case 'villa':
        return Icons.villa_outlined;
      case 'land':
        return Icons.landscape_outlined;
      case 'shop':
        return Icons.storefront_outlined;
      case 'office':
        return Icons.business_outlined;
      default:
        return Icons.home_work_outlined;
    }
  }

  Widget _buildDealTypeTab(String label, String value) {
    final isSelected = selectedDealType == value;
    return InkWell(
      onTap: () {
        onDealTypeChanged(value);
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

  Widget _buildGovernoratePill(String label, String? gov) {
    final isSelected = selectedGovernorate == gov;
    return InkWell(
      onTap: () {
        onGovernorateToggled(gov);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}