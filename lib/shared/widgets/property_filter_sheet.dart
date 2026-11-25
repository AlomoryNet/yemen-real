import 'package:flutter/material.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/context_l10n.dart';
import '../../core/theme/app_colors.dart';
import '../../models/property_filter_selection.dart';
import '../../models/property_type.dart';

export '../../models/property_filter_selection.dart';

/// Opens the shared M3 filter sheet and returns the applied selection.
/// Returns `null` when the user dismisses the sheet without applying.
Future<PropertyFilterSelection?> showPropertyFilterSheet({
  required BuildContext context,
  required PropertyFilterSelection initial,
  List<PropertyType> propertyTypes = const <PropertyType>[],
  bool showAdvancedFilters = false,
  String? title,
}) {
  return showModalBottomSheet<PropertyFilterSelection>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor:
        Theme.of(context).colorScheme.scrim.withValues(alpha: 0.32),
    builder: (_) => PropertyFilterSheet(
      initial: initial,
      propertyTypes: propertyTypes,
      showAdvancedFilters: showAdvancedFilters,
      title: title,
    ),
  );
}

/// A compact, searchable filter sheet shared by the dashboard and the map.
///
/// Governorates and districts are exposed as filterable dropdown menus instead
/// of long horizontal chip rails, and all choices live in vertical sections
/// that keep the sheet readable at any width.
class PropertyFilterSheet extends StatefulWidget {
  const PropertyFilterSheet({
    super.key,
    required this.initial,
    this.propertyTypes = const <PropertyType>[],
    this.showAdvancedFilters = false,
    this.title,
  });

  final PropertyFilterSelection initial;
  final List<PropertyType> propertyTypes;
  final bool showAdvancedFilters;
  final String? title;

  @override
  State<PropertyFilterSheet> createState() => _PropertyFilterSheetState();
}

class _PropertyFilterSheetState extends State<PropertyFilterSheet> {
  late String _dealType;
  late String? _typeId;
  late String _governorate;
  late String _district;
  late double? _minPrice;
  late double? _maxPrice;
  late int? _minBedrooms;
  late bool _onlyExactCoordinates;
  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;

  static const String _all = '';

  @override
  void initState() {
    super.initState();
    _dealType = widget.initial.dealType;
    _typeId = widget.initial.typeId;
    _governorate = widget.initial.governorate ?? _all;
    _district = widget.initial.district ?? _all;
    _minPrice = widget.initial.minPrice;
    _maxPrice = widget.initial.maxPrice;
    _minBedrooms = widget.initial.minBedrooms;
    _onlyExactCoordinates = widget.initial.onlyExactCoordinates;
    _minPriceController = TextEditingController(
      text: _minPrice == null ? '' : _minPrice!.toStringAsFixed(0),
    );
    _maxPriceController = TextEditingController(
      text: _maxPrice == null ? '' : _maxPrice!.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  PropertyFilterSelection get _selection => PropertyFilterSelection(
        dealType: _dealType,
        typeId: _typeId,
        governorate: _governorate.isEmpty ? null : _governorate,
        district: _district.isEmpty ? null : _district,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minBedrooms: _minBedrooms,
        onlyExactCoordinates: _onlyExactCoordinates,
      );

  List<String> get _governorateOptions {
    final options = List<String>.from(AppConstants.yemeniGovernorates);
    if (_governorate.isNotEmpty && !options.contains(_governorate)) {
      options.insert(0, _governorate);
    }
    return options;
  }

  List<String> get _districtOptions {
    if (_governorate.isEmpty) return const <String>[];
    final options = AppConstants.getDistrictsForGovernorate(_governorate);
    if (_district.isNotEmpty && !options.contains(_district)) {
      return <String>[_district, ...options];
    }
    return options;
  }

  void _reset() {
    setState(() {
      _dealType = _all;
      _typeId = null;
      _governorate = _all;
      _district = _all;
      _minPrice = null;
      _maxPrice = null;
      _minBedrooms = null;
      _onlyExactCoordinates = false;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(_selection);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final activeCount = _selection.activeCount;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 24,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: AppColors.primaryMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.tune_rounded,
                        color: AppColors.primaryInk, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title ?? l10n.map_filter_results,
                      style: AppFonts.cairo(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (activeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$activeCount',
                        style: AppFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: onPrimary,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: _reset,
                    child: Text(
                      l10n.map_reset_filters,
                      style: AppFonts.cairo(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSection(
                        context: context,
                        icon: Icons.swap_horiz_rounded,
                        label: l10n.map_deal_type,
                        child: SegmentedButton<String>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment<String>(
                              value: _all,
                              label: Text(l10n.map_all),
                              icon: const Icon(Icons.all_inclusive_rounded),
                            ),
                            ButtonSegment<String>(
                              value: AppConstants.dealSale,
                              label: Text(l10n.map_for_sale),
                              icon: const Icon(Icons.sell_outlined),
                            ),
                            ButtonSegment<String>(
                              value: AppConstants.dealRent,
                              label: Text(l10n.map_for_rent),
                              icon: const Icon(Icons.key_outlined),
                            ),
                          ],
                          selected: <String>{_dealType},
                          onSelectionChanged: (values) {
                            setState(() => _dealType = values.first);
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        context: context,
                        icon: Icons.home_work_outlined,
                        label: l10n.map_property_type,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFilterChip(
                              context: context,
                              label: l10n.map_all,
                              icon: Icons.select_all_rounded,
                              selected: _typeId == null,
                              onTap: () => setState(() => _typeId = null),
                            ),
                            for (final option in _typeOptions(context))
                              _buildFilterChip(
                                context: context,
                                label: option.label,
                                icon: option.icon,
                                selected: _typeId == option.id,
                                onTap: () =>
                                    setState(() => _typeId = option.id),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSection(
                        context: context,
                        icon: Icons.location_on_outlined,
                        label: l10n.map_governorate,
                        child: Column(
                          children: [
                            DropdownMenu<String>(
                              expandedInsets: EdgeInsets.zero,
                              initialSelection: _governorate,
                              requestFocusOnTap: true,
                              enableFilter: true,
                              label: Text(l10n.map_governorate),
                              hintText: l10n.map_all_governorates_plain,
                              menuHeight: 260,
                              dropdownMenuEntries: [
                                DropdownMenuEntry<String>(
                                  value: _all,
                                  label: l10n.map_all_governorates_plain,
                                  leadingIcon: const Icon(Icons.public_rounded),
                                ),
                                for (final gov in _governorateOptions)
                                  DropdownMenuEntry<String>(
                                    value: gov,
                                    label:
                                        AppConstants.getGovernorateNameAr(gov),
                                    leadingIcon: const Icon(
                                      Icons.location_city_outlined,
                                    ),
                                  ),
                              ],
                              onSelected: (value) {
                                setState(() {
                                  _governorate = value ?? _all;
                                  _district = _all;
                                });
                              },
                            ),
                            if (_governorate.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              DropdownMenu<String>(
                                expandedInsets: EdgeInsets.zero,
                                initialSelection: _district,
                                requestFocusOnTap: true,
                                enableFilter: true,
                                label: Text(l10n.map_district_in),
                                hintText:
                                    '${l10n.map_all_districts_in} ${AppConstants.getGovernorateNameAr(_governorate)}',
                                menuHeight: 260,
                                dropdownMenuEntries: [
                                  DropdownMenuEntry<String>(
                                    value: _all,
                                    label:
                                        '${l10n.map_all_districts_in} ${AppConstants.getGovernorateNameAr(_governorate)}',
                                    leadingIcon: const Icon(
                                      Icons.format_list_bulleted_rounded,
                                    ),
                                  ),
                                  for (final district in _districtOptions)
                                    DropdownMenuEntry<String>(
                                      value: district,
                                      label: AppConstants.getDistrictNameAr(
                                        district,
                                      ),
                                    ),
                                ],
                                onSelected: (value) {
                                  setState(() => _district = value ?? _all);
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (widget.showAdvancedFilters) ...[
                        const SizedBox(height: 12),
                        _buildSection(
                          context: context,
                          icon: Icons.payments_outlined,
                          label: l10n.map_price_range,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _minPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.map_min_price,
                                    hintText: '0',
                                    prefixIcon: const Icon(Icons.price_check),
                                  ),
                                  onChanged: (value) {
                                    _minPrice = double.tryParse(value.trim());
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _maxPriceController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.map_max_price,
                                    hintText: l10n.map_no_max,
                                    prefixIcon: const Icon(Icons.price_change),
                                  ),
                                  onChanged: (value) {
                                    _maxPrice = double.tryParse(value.trim());
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSection(
                          context: context,
                          icon: Icons.bed_outlined,
                          label: l10n.map_min_bedrooms,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final beds in <int?>[null, 1, 2, 3, 4, 5])
                                _buildFilterChip(
                                  context: context,
                                  label: beds == null
                                      ? l10n.map_all
                                      : '$beds+',
                                  icon: Icons.bedroom_parent_outlined,
                                  selected: _minBedrooms == beds,
                                  onTap: () =>
                                      setState(() => _minBedrooms = beds),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSection(
                          context: context,
                          icon: Icons.gps_fixed,
                          label: l10n.map_exact_gps_only,
                          child: Material(
                            type: MaterialType.transparency,
                            child: SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              value: _onlyExactCoordinates,
                              title: Text(
                                l10n.map_exact_gps_only,
                                style: AppFonts.cairo(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                l10n.map_hide_approximate,
                                style: AppFonts.cairo(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              onChanged: (value) {
                                setState(
                                  () => _onlyExactCoordinates = value,
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: Text(l10n.map_reset_filters),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _apply,
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(l10n.map_apply_filters),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<({String id, String label, IconData icon})> _typeOptions(
    BuildContext context,
  ) {
    final l10n = context.l10n;
    final activeTypes =
        widget.propertyTypes.where((type) => type.isActive).toList();
    if (activeTypes.isNotEmpty) {
      return activeTypes
          .map(
            (type) => (
              id: type.id,
              label: type.nameAr,
              icon: _typeIcon(type.id),
            ),
          )
          .toList();
    }

    return [
      (
        id: 'apartment',
        label: l10n.map_type_apartment,
        icon: Icons.apartment,
      ),
      (id: 'villa', label: l10n.map_type_villa, icon: Icons.villa_outlined),
      (id: 'shop', label: l10n.map_type_shop, icon: Icons.storefront_outlined),
      (id: 'land', label: l10n.map_type_land, icon: Icons.landscape_outlined),
      (
        id: 'building',
        label: l10n.map_type_building,
        icon: Icons.business_outlined,
      ),
      (id: 'office', label: l10n.map_type_office, icon: Icons.business_center),
    ];
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primaryInk),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppFonts.cairo(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    return FilterChip(
      showCheckmark: false,
      selected: selected,
      label: Text(label),
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? onPrimary : AppColors.primaryInk,
      ),
      onSelected: (_) => onTap(),
    );
  }

  IconData _typeIcon(String id) {
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
}
