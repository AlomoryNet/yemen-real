import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Modal bottom sheet that lets the user pick a governorate (or a district
/// inside one). Callers receive the chosen governorate/district via callbacks
/// and apply them to their own state.
class HomeGovernoratePickerSheet extends StatefulWidget {
  const HomeGovernoratePickerSheet({
    super.key,
    required this.initialGovernorate,
    required this.onGovernorateSelected,
    required this.onDistrictChosen,
  });

  final String? initialGovernorate;
  final ValueChanged<String?> onGovernorateSelected;
  final ValueChanged<String> onDistrictChosen;

  @override
  State<HomeGovernoratePickerSheet> createState() =>
      _HomeGovernoratePickerSheetState();
}

class _HomeGovernoratePickerSheetState
    extends State<HomeGovernoratePickerSheet> {
  late String? _selectedGovernorate;

  @override
  void initState() {
    super.initState();
    _selectedGovernorate = widget.initialGovernorate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'اختر المحافظة اليمنية لعرض العقارات',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 20),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedGovernorate == null
                    ? AppColors.primary
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.public,
                color: _selectedGovernorate == null
                    ? Colors.white
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
            title: Text(
              'كافة المحافظات اليمنية (عرض الكل)',
              style: GoogleFonts.cairo(
                fontWeight: _selectedGovernorate == null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
            trailing: _selectedGovernorate == null
                ? const Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              setState(() => _selectedGovernorate = null);
              widget.onGovernorateSelected(null);
              Navigator.pop(context);
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: AppConstants.yemeniGovernorates.length,
              itemBuilder: (context, index) {
                final gov = AppConstants.yemeniGovernorates[index];
                final isSelected = _selectedGovernorate == gov;
                final districts = AppConstants.getDistrictsForGovernorate(
                  gov,
                );
                return ExpansionTile(
                  initiallyExpanded: isSelected,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    gov,
                    style: GoogleFonts.cairo(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                        )
                      : const Icon(Icons.keyboard_arrow_down),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                              foregroundColor: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () {
                              setState(() => _selectedGovernorate = gov);
                              widget.onGovernorateSelected(gov);
                              Navigator.pop(context);
                            },
                            child: Text('عرض كافة عقارات محافظة $gov'),
                          ),
                          if (districts.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              'أو اختر حي / منطقة محددة:',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: districts.map((dist) {
                                return ActionChip(
                                  label: Text(
                                    dist,
                                    style: GoogleFonts.cairo(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedGovernorate = gov;
                                    });
                                    widget.onDistrictChosen(dist);
                                    Navigator.pop(context);
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}