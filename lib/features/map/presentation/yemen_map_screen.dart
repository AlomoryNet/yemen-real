import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../providers/property_provider.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_header.dart';
import '../../../data/demo_properties_generator.dart';

class YemenGovernorateCoord {
  final String name;
  final double latitude;
  final double longitude;
  final double defaultZoom;

  const YemenGovernorateCoord({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.defaultZoom = 12.5,
  });
}

class YemenMapScreen extends ConsumerStatefulWidget {
  const YemenMapScreen({super.key});

  @override
  ConsumerState<YemenMapScreen> createState() => _YemenMapScreenState();
}

class _YemenMapScreenState extends ConsumerState<YemenMapScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  Property? _selectedProperty;
  String _selectedDealType = ''; // '' = all, 'sale', 'rent'
  String? _selectedTypeId; // null = all
  String? _selectedGovName; // null = all yemen
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;

  bool _isListView = false;
  bool _showSearchThisAreaBtn = false;
  LatLng? _lastSearchCenter;
  Timer? _debounceTimer;

  static const List<YemenGovernorateCoord> _governorates = [
    YemenGovernorateCoord(
      name: 'أمانة العاصمة',
      latitude: 15.3547,
      longitude: 44.2075,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'صنعاء',
      latitude: 15.2200,
      longitude: 44.3500,
      defaultZoom: 11.5,
    ),
    YemenGovernorateCoord(
      name: 'عدن',
      latitude: 12.8250,
      longitude: 45.0100,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'تعز',
      latitude: 13.5789,
      longitude: 44.0219,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'حضرموت',
      latitude: 14.5425,
      longitude: 49.1242,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'إب',
      latitude: 13.9667,
      longitude: 44.1833,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'الحديدة',
      latitude: 14.7978,
      longitude: 42.9545,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'مأرب',
      latitude: 15.4624,
      longitude: 45.3258,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'ذمار',
      latitude: 14.5427,
      longitude: 44.4051,
      defaultZoom: 13.0,
    ),
    YemenGovernorateCoord(
      name: 'شبوة',
      latitude: 14.5377,
      longitude: 46.8319,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'لحج',
      latitude: 13.0583,
      longitude: 44.8828,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'أبين',
      latitude: 13.1287,
      longitude: 45.3805,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'صعدة',
      latitude: 16.9402,
      longitude: 43.7639,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'المهرة',
      latitude: 16.2079,
      longitude: 52.1760,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'عمران',
      latitude: 15.6594,
      longitude: 43.9439,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'حجة',
      latitude: 15.6942,
      longitude: 43.6021,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'البيضاء',
      latitude: 13.9852,
      longitude: 45.5727,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'الضالع',
      latitude: 13.6957,
      longitude: 44.7314,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'ريمة',
      latitude: 14.6289,
      longitude: 43.7128,
      defaultZoom: 12.0,
    ),
    YemenGovernorateCoord(
      name: 'المحويت',
      latitude: 15.4701,
      longitude: 43.5449,
      defaultZoom: 12.5,
    ),
    YemenGovernorateCoord(
      name: 'سقطرى',
      latitude: 12.6500,
      longitude: 54.0167,
      defaultZoom: 11.0,
    ),
    YemenGovernorateCoord(
      name: 'الجوف',
      latitude: 16.1404,
      longitude: 44.9609,
      defaultZoom: 11.5,
    ),
  ];

  static const LatLng _yemenCenter = LatLng(15.3547, 44.2075);
  static const double _initialZoom = 11.5;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _lastSearchCenter = _yemenCenter;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutCubic,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  void _selectGovernorate(YemenGovernorateCoord? gov) {
    setState(() {
      _selectedGovName = gov?.name;
      _selectedProperty = null;
      _showSearchThisAreaBtn = false;
      if (gov != null) {
        _searchController.text = gov.name;
      } else {
        _searchController.clear();
      }
    });

    if (gov != null) {
      _animatedMapMove(
        LatLng(gov.latitude, gov.longitude),
        gov.defaultZoom,
      );
      _lastSearchCenter = LatLng(gov.latitude, gov.longitude);
    } else {
      _animatedMapMove(_yemenCenter, 7.0);
      _lastSearchCenter = _yemenCenter;
    }
  }

  (double, double) _getPropertyCoords(Property prop) {
    if (prop.latitude != null && prop.longitude != null) {
      return (prop.latitude!, prop.longitude!);
    }
    return AppConstants.getCoordinatesForGovernorate(prop.city);
  }

  List<Property> _filterProperties(List<Property> all) {
    final query = _searchController.text.trim().toLowerCase();

    return all.where((p) {
      if (p.status != AppConstants.statusPublished) return false;

      // Filter deal type
      if (_selectedDealType.isNotEmpty && p.dealType != _selectedDealType) {
        return false;
      }

      // Filter property type
      if (_selectedTypeId != null &&
          _selectedTypeId!.isNotEmpty &&
          p.propertyTypeId != _selectedTypeId) {
        return false;
      }

      // Filter governorate
      if (_selectedGovName != null && _selectedGovName!.isNotEmpty) {
        final matchesCity = p.city == _selectedGovName ||
            p.city.contains(_selectedGovName!) ||
            _selectedGovName!.contains(p.city);
        if (!matchesCity) return false;
      }

      // Filter text query (city, district, title)
      if (query.isNotEmpty) {
        final inCity = p.city.toLowerCase().contains(query);
        final inDist = p.district.toLowerCase().contains(query);
        final inTitle = p.title.toLowerCase().contains(query);
        if (!inCity && !inDist && !inTitle) return false;
      }

      // Filter price
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;

      // Filter bedrooms
      if (_minBedrooms != null && p.bedrooms < _minBedrooms!) return false;

      return true;
    }).toList();
  }

  String _formatPriceTag(Property p) {
    final cur = p.currency == AppConstants.currencyYer
        ? 'ر.ي'
        : p.currency == AppConstants.currencyUsd
            ? '\$'
            : 'ر.س';

    final isRent = p.dealType == AppConstants.dealRent;
    final suffix = isRent ? '/شهرياً' : '';

    if (p.price >= 1000000) {
      final millions =
          (p.price / 1000000).toStringAsFixed(1).replaceAll('.0', '');
      return '$millions م $cur $suffix'.trim();
    } else if (p.price >= 1000) {
      final thousands = (p.price / 1000).toStringAsFixed(0);
      return '$thousands ألف $cur $suffix'.trim();
    }
    return '${p.price.toStringAsFixed(0)} $cur $suffix'.trim();
  }

  Future<void> _makeCall(String phone) async {
    final clean = Formatters.formatPhoneForDialing(phone);
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final cleanPhone = Formatters.formatPhoneForWhatsApp(phone);
    final msg = Uri.encodeComponent(
      'السلام عليكم، بخصوص العقار المعروض في بوابة اليمن العقارية: $title',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String tempDeal = _selectedDealType;
        String? tempType = _selectedTypeId;
        int? tempBeds = _minBedrooms;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.tune_rounded, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'تصفية عقارات الخريطة',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              tempDeal = '';
                              tempType = null;
                              tempBeds = null;
                            });
                          },
                          child: Text(
                            'إعادة ضبط',
                            style: GoogleFonts.cairo(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Deal Type
                    Text(
                      'نوع المعاملة',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFilterOption(
                          label: 'الكل',
                          isSelected: tempDeal == '',
                          onTap: () => setModalState(() => tempDeal = ''),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterOption(
                          label: 'للبيع',
                          isSelected: tempDeal == AppConstants.dealSale,
                          onTap: () => setModalState(
                              () => tempDeal = AppConstants.dealSale),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterOption(
                          label: 'للإيجار',
                          isSelected: tempDeal == AppConstants.dealRent,
                          onTap: () => setModalState(
                              () => tempDeal = AppConstants.dealRent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Property Type
                    Text(
                      'نوع العقار',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterOption(
                          label: 'الكل',
                          isSelected: tempType == null,
                          onTap: () => setModalState(() => tempType = null),
                        ),
                        _buildFilterOption(
                          label: 'شقق سكنية',
                          isSelected: tempType == 'apartment',
                          onTap: () =>
                              setModalState(() => tempType = 'apartment'),
                        ),
                        _buildFilterOption(
                          label: 'فلل ومنازل',
                          isSelected: tempType == 'villa',
                          onTap: () => setModalState(() => tempType = 'villa'),
                        ),
                        _buildFilterOption(
                          label: 'محلات تجارية',
                          isSelected: tempType == 'shop',
                          onTap: () => setModalState(() => tempType = 'shop'),
                        ),
                        _buildFilterOption(
                          label: 'أراضٍ',
                          isSelected: tempType == 'land',
                          onTap: () => setModalState(() => tempType = 'land'),
                        ),
                        _buildFilterOption(
                          label: 'مكاتب تجارية',
                          isSelected: tempType == 'office',
                          onTap: () => setModalState(() => tempType = 'office'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bedrooms
                    Text(
                      'عدد الغرف على الأقل',
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (final b in [null, 1, 2, 3, 4, 5])
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: _buildFilterOption(
                              label: b == null ? 'الكل' : '$b+',
                              isSelected: tempBeds == b,
                              onTap: () => setModalState(() => tempBeds = b),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedDealType = tempDeal;
                            _selectedTypeId = tempType;
                            _minBedrooms = tempBeds;
                            _selectedProperty = null;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(
                          'تطبيق الفلاتر',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allMapPropertiesProvider);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      appBar: const AppHeader(),
      drawer: const AppDrawer(),
      bottomNavigationBar: const AppBottomNavBar(currentRoute: '/map'),
      body: propertiesAsync.when(
        data: (allProperties) {
          // If live database returned empty or offline, fallback to DemoPropertiesGenerator
          final effectiveList = allProperties.isNotEmpty
              ? allProperties
              : DemoPropertiesGenerator.generateAllDemoProperties();

          final filteredProperties = _filterProperties(effectiveList);

          return Stack(
            children: [
              // 1. Full Screen Interactive Map or List View
              if (!_isListView)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _yemenCenter,
                    initialZoom: _initialZoom,
                    minZoom: 5.0,
                    maxZoom: 18.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all,
                    ),
                    onPositionChanged: (pos, hasGesture) {
                      if (hasGesture) {
                        _debounceTimer?.cancel();
                        _debounceTimer =
                            Timer(const Duration(milliseconds: 350), () {
                          if (mounted) {
                            final dist = _lastSearchCenter != null
                                ? const Distance().as(
                                    LengthUnit.Kilometer,
                                    _lastSearchCenter!,
                                    pos.center,
                                  )
                                : 0;
                            if (dist > 3.0) {
                              setState(() {
                                _showSearchThisAreaBtn = true;
                              });
                            }
                          }
                        });
                      }
                    },
                    onTap: (tapPosition, point) {
                      if (_selectedProperty != null) {
                        setState(() {
                          _selectedProperty = null;
                        });
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.yemenreal.portal',
                      maxZoom: 19,
                    ),
                    MarkerLayer(
                      markers: filteredProperties.map((prop) {
                        final isSelected = _selectedProperty?.id == prop.id;
                        final priceText = _formatPriceTag(prop);
                        final isRent = prop.dealType == AppConstants.dealRent;
                        final coords = _getPropertyCoords(prop);

                        return Marker(
                          point: LatLng(coords.$1, coords.$2),
                          width: isSelected ? 150 : 130,
                          height: 52,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedProperty = prop;
                              });
                              _animatedMapMove(
                                LatLng(coords.$1, coords.$2),
                                14.5,
                              );
                            },
                            child: _buildZillowMarker(
                              priceText: priceText,
                              isSelected: isSelected,
                              isRent: isRent,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              else
                // Synced List View
                Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.only(top: 140),
                  child: filteredProperties.isEmpty
                      ? _buildEmptyAreaView()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredProperties.length,
                          itemBuilder: (context, index) {
                            final prop = filteredProperties[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: _buildZillowPropertyCard(
                                prop,
                                onSelectOnMap: () {
                                  setState(() {
                                    _isListView = false;
                                    _selectedProperty = prop;
                                  });
                                  final coords = _getPropertyCoords(prop);
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _animatedMapMove(
                                      LatLng(coords.$1, coords.$2),
                                      15.0,
                                    );
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),

              // 2. Top Interactive Bar: Search + Filter Chips + Governorate Selector
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Search and Filter Controls Card
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header badge / title
                            Row(
                              children: [
                                const Icon(
                                  Icons.map_rounded,
                                  size: 16,
                                  color: Color(0xFF0F766E),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'الخريطة العقارية',
                                  style: GoogleFonts.cairo(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF0F766E),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E).withAlpha(15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'خريطة اليمن',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Search Row with Text Field and Filter Dialog
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: TextField(
                                      controller: _searchController,
                                      style: GoogleFonts.cairo(fontSize: 13),
                                      decoration: InputDecoration(
                                        hintText:
                                            'ابحث بالمحافظة، الحي، أو اسم العقار...',
                                        hintStyle:
                                            GoogleFonts.cairo(fontSize: 12),
                                        prefixIcon: const Icon(
                                          Icons.search,
                                          size: 20,
                                          color: Color(0xFF0F766E),
                                        ),
                                        suffixIcon: _searchController
                                                .text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear,
                                                    size: 16),
                                                onPressed: () {
                                                  setState(() {
                                                    _searchController.clear();
                                                    _selectedGovName = null;
                                                  });
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {});
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Filter Button
                                InkWell(
                                  onTap: _showFilterModal,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (_selectedTypeId != null ||
                                              _minBedrooms != null)
                                          ? const Color(0xFF0F766E)
                                          : AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: AppColors.divider,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.tune_rounded,
                                          size: 18,
                                          color: (_selectedTypeId != null ||
                                                  _minBedrooms != null)
                                              ? Colors.white
                                              : AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'فلترة',
                                          style: GoogleFonts.cairo(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (_selectedTypeId != null ||
                                                    _minBedrooms != null)
                                                ? Colors.white
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Deal Chips & Count Row
                            Row(
                              children: [
                                _buildDealChip('الكل', ''),
                                const SizedBox(width: 6),
                                _buildDealChip('للبيع', AppConstants.dealSale),
                                const SizedBox(width: 6),
                                _buildDealChip('للإيجار', AppConstants.dealRent),

                                const Spacer(),

                                // Count
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F766E).withAlpha(15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${filteredProperties.length} عقار 🇾🇪',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Horizontal 22 Yemeni Governorates Selector Chips
                      SizedBox(
                        height: 38,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _governorates.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final isAll = _selectedGovName == null;
                              return Padding(
                                padding: const EdgeInsets.only(left: 6),
                                child: ChoiceChip(
                                  label: Text(
                                    'كافة المحافظات 🇾🇪',
                                    style: GoogleFonts.cairo(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: isAll
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  selected: isAll,
                                  selectedColor: const Color(0xFF0F766E),
                                  backgroundColor: Colors.white.withAlpha(245),
                                  onSelected: (_) => _selectGovernorate(null),
                                ),
                              );
                            }

                            final gov = _governorates[index - 1];
                            final isSelected = _selectedGovName == gov.name;

                            return Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: ChoiceChip(
                                label: Text(
                                  gov.name,
                                  style: GoogleFonts.cairo(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF0F766E),
                                backgroundColor: Colors.white.withAlpha(245),
                                onSelected: (_) => _selectGovernorate(gov),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. "Search this area" Button (Zillow style floating pill)
              if (_showSearchThisAreaBtn && !_isListView)
                Positioned(
                  top: 155,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F766E),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(
                            color: Color(0xFF0D9488),
                            width: 1.5,
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: Text(
                        'البحث في هذه المنطقة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _lastSearchCenter = _mapController.camera.center;
                          _showSearchThisAreaBtn = false;
                        });
                      },
                    ),
                  ),
                ),

              // 4. Floating Controls (Recenter, Zoom, Map/List Toggle)
              Positioned(
                bottom: _selectedProperty != null ? 245 : 20,
                left: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Map / List Toggle
                    FloatingActionButton.extended(
                      heroTag: 'map_list_toggle',
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F766E),
                      elevation: 4,
                      icon: Icon(
                        _isListView
                            ? Icons.map_rounded
                            : Icons.format_list_bulleted,
                        size: 20,
                      ),
                      label: Text(
                        _isListView ? 'عرض الخريطة' : 'عرض القائمة',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _isListView = !_isListView;
                        });
                      },
                    ),
                    const SizedBox(height: 10),

                    // Zoom In
                    _buildFloatingIconBtn(
                      heroTag: 'map_zoom_in',
                      icon: Icons.add,
                      tooltip: 'تكبير الخريطة',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          (_mapController.camera.zoom + 1).clamp(5.0, 18.0),
                        );
                      },
                    ),
                    const SizedBox(height: 6),

                    // Zoom Out
                    _buildFloatingIconBtn(
                      heroTag: 'map_zoom_out',
                      icon: Icons.remove,
                      tooltip: 'تصغير الخريطة',
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          (_mapController.camera.zoom - 1).clamp(5.0, 18.0),
                        );
                      },
                    ),
                    const SizedBox(height: 6),

                    // Recenter Default to Yemen Center
                    _buildFloatingIconBtn(
                      heroTag: 'map_recenter',
                      icon: Icons.my_location,
                      tooltip: 'العودة لموقع اليمن الافتراضي',
                      onPressed: () {
                        _selectGovernorate(null);
                      },
                    ),
                  ],
                ),
              ),

              // 5. Selected Property Preview Card
              if (_selectedProperty != null && !_isListView)
                Positioned(
                  bottom: 14,
                  left: isMobile ? 10 : 20,
                  right: isMobile ? 10 : 20,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _buildZillowPropertyCard(_selectedProperty!),
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل الخريطة. يمكنك استخدام العرض البديل.',
                  style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.refresh(allMapPropertiesProvider),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDealChip(String label, String value) {
    final isSelected = _selectedDealType == value;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedDealType = value;
          _selectedProperty = null;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F766E) : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingIconBtn({
    required String heroTag,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: FloatingActionButton(
        heroTag: heroTag,
        mini: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F766E),
        elevation: 3,
        tooltip: tooltip,
        onPressed: onPressed,
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildZillowMarker({
    required String priceText,
    required bool isSelected,
    required bool isRent,
  }) {
    final bgColor = isSelected
        ? Colors.amber.shade700
        : (isRent ? const Color(0xFF0D9488) : AppColors.primary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? Colors.amber.withAlpha(120)
                    : Colors.black.withAlpha(60),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  priceText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: isSelected ? 11.5 : 10.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: const Size(10, 5),
          painter: _TrianglePainter(color: bgColor),
        ),
      ],
    );
  }

  Widget _buildEmptyAreaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              'لا توجد عقارات مطابقة في هذا النطاق',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'يرجى تغيير نطاق البحث أو مسح الفلاتر لعرض العقارات المتوفرة في بقية محافظات اليمن.',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                'عرض كافة المحافظات اليمنية',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _selectGovernorate(null),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZillowPropertyCard(Property prop, {VoidCallback? onSelectOnMap}) {
    final isRent = prop.dealType == AppConstants.dealRent;
    final primaryImg = prop.primaryImageUrl ??
        'https://images.unsplash.com/photo-1560518883-ce09059eeffa?auto=format&fit=crop&w=800&q=80';

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Image Banner
              Stack(
                children: [
                  SizedBox(
                    height: 115,
                    width: double.infinity,
                    child: CachedNetworkImage(
                      imageUrl: primaryImg,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, err) => Container(
                        color: AppColors.surfaceVariant,
                        child: const Icon(
                          Icons.apartment,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(60),
                            Colors.transparent,
                            Colors.black.withAlpha(140),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (onSelectOnMap == null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedProperty = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  // Deal Type & Demo Badge
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isRent
                                ? const Color(0xFF0D9488)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isRent ? 'للإيجار' : 'للبيع',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(140),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'عرض تجريبي',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price on bottom of image
                  Positioned(
                    bottom: 6,
                    left: 10,
                    child: Text(
                      _formatPriceTag(prop),
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              // Details & Action Buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 13,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${prop.city} — ${prop.district}',
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (prop.bedrooms > 0) ...[
                          _buildSpecBadge(
                            Icons.bed_outlined,
                            '${prop.bedrooms} غرف',
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (prop.bathrooms > 0) ...[
                          _buildSpecBadge(
                            Icons.bathtub_outlined,
                            '${prop.bathrooms} حمام',
                          ),
                          const SizedBox(width: 6),
                        ],
                        _buildSpecBadge(
                          Icons.square_foot_outlined,
                          '${prop.areaSqm.toInt()} م²',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Actions
                    Row(
                      children: [
                        if (onSelectOnMap != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.place, size: 15),
                              label: Text(
                                'تحديد على الخريطة',
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: onSelectOnMap,
                            ),
                          )
                        else
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.visibility, size: 15),
                              label: Text(
                                'عرض التفاصيل',
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.5,
                                ),
                              ),
                              onPressed: () {
                                context.push('/property/${prop.id}');
                              },
                            ),
                          ),
                        const SizedBox(width: 6),
                        IconButton.filledTonal(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.shade50,
                            foregroundColor: Colors.green.shade700,
                          ),
                          icon: const Icon(Icons.phone, size: 16),
                          tooltip: 'اتصال',
                          onPressed: () => _makeCall(prop.contactPhone),
                        ),
                        if (prop.contactWhatsapp != null &&
                            prop.contactWhatsapp!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          IconButton.filledTonal(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.teal.shade50,
                              foregroundColor: Colors.teal.shade700,
                            ),
                            icon: const Icon(Icons.chat, size: 16),
                            tooltip: 'واتساب',
                            onPressed: () => _openWhatsApp(
                              prop.contactWhatsapp!,
                              prop.title,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(
            text,
            style: GoogleFonts.cairo(
              fontSize: 9.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
