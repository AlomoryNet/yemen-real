import 'dart:ui' show ImageFilter;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_real_estate_portal/core/theme/app_fonts.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/property.dart';
import '../../../models/property_type.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/add_property_fab.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../core/theme/property_text_styles.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/property_filter_sheet.dart';
import '../../../data/demo_properties_generator.dart';
import '../../../services/supabase_service.dart';
import '../services/map_cluster_service.dart';
import 'map_screen_args.dart';
import 'property_map_view.dart';

export 'map_screen_args.dart';
import '../../../core/l10n/context_l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  /// Dashboard FAB opens the map/list view in list mode. Direct /map visits
  /// keep the map as the initial view.
  final bool initialListView;

  /// Optional filter values coming from the dashboard search / view-all CTAs.
  final MapScreenArgs? initialFilters;

  const YemenMapScreen({
    super.key,
    this.initialListView = false,
    this.initialFilters,
  });

  @override
  ConsumerState<YemenMapScreen> createState() => _YemenMapScreenState();
}

class _YemenMapScreenState extends ConsumerState<YemenMapScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  Property? _selectedProperty;
  String _selectedDealType = ''; // '' = all, 'sale', 'rent'
  String? _selectedTypeId; // null = all
  String? _selectedGovName; // null = all yemen
  String? _selectedDistrict; // null = all districts
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  bool _onlyExactCoordinates = false;

  bool _isListView =
      false; // overwritten from widget.initialListView in initState
  double _currentZoom = _defaultZoom;
  LatLng? _lastSearchCenter;
  LatLng? _initialFocus;
  double? _initialZoom;

  /// Set when a filter changes so the next build frames the filtered results.
  bool _pendingFitToFiltered = false;

  /// Count of listings after applying filters.
  int _filteredCount = 0;
  final ScrollController _listScrollController = ScrollController();

  // Listing pagination — render 12 rows initially, extend on scroll.
  static const int _pageSize = 12;
  int _visibleCount = _pageSize;
  int _lastFilteredCount = 0;
  String _lastFilterKey = '';

  int _activeCardImageIndex = 0;
  bool _isSatellite = false;

  // Freehand Map Drawing Mode
  bool _isDrawingMode = false;
  List<LatLng> _drawnPolygon = [];

  static const double _defaultZoom = 12.5;
  static const LatLng _ibbCenter = LatLng(13.9667, 44.1833);

  // Map shell geometry — one source of truth for the floating header and the
  // controls anchored around it. Previously these were seven unrelated magic
  // offsets that broke with text scaling and safe-area changes.
  static const double _headerPadding = 10;
  static const double _headerSearchHeight = 46;
  static const double _headerChipHeight = 42;
  static const double _headerGap = 8;
  static const double _selectedCardReserve = 372;

  double _headerBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).top +
      _headerPadding +
      _headerSearchHeight +
      _headerGap +
      _headerChipHeight +
      _headerGap;

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

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _isListView = widget.initialListView;
    // Respect the user's default map view preference from Settings for direct
    // /map visits (not when the dashboard explicitly requests list mode).
    if (widget.initialFilters == null && !widget.initialListView) {
      final settings = ref.read(settingsProvider);
      _isListView = settings.defaultMapView == 'list';
    }

    final incoming = widget.initialFilters;
    if (incoming != null) {
      _pendingFitToFiltered = true;
      if (incoming.searchQuery != null && incoming.searchQuery!.isNotEmpty) {
        _searchController.text = incoming.searchQuery!;
      }
      _selectedDealType = incoming.dealType ?? '';
      _selectedTypeId = incoming.propertyTypeId;
      _selectedGovName = (incoming.city == null || incoming.city!.isEmpty)
          ? null
          : incoming.city;
      _selectedDistrict =
          (incoming.district == null || incoming.district!.isEmpty)
          ? null
          : incoming.district;
      if (_selectedGovName != null) {
        for (final gov in _governorates) {
          if (gov.name == _selectedGovName ||
              gov.name.contains(_selectedGovName!) ||
              _selectedGovName!.contains(gov.name)) {
            _initialFocus = LatLng(gov.latitude, gov.longitude);
            _initialZoom = gov.defaultZoom;
            break;
          }
        }
      }
    }

    // Use the requested focus, or the user's stored location (Ibb fallback).
    if (_initialFocus == null) _initMapCenter();
    _listScrollController.addListener(() {
      if (!_listScrollController.hasClients || !mounted) return;
      final position = _listScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 300 &&
          _visibleCount < _lastFilteredCount) {
        setState(() {
          _visibleCount = (_visibleCount + _pageSize).clamp(
            0,
            _lastFilteredCount,
          );
        });
      }
    });
  }

  /// Initialize map center and zoom based on user's stored location (or Ibb fallback).
  Future<void> _initMapCenter() async {
    final requestedFocus = _initialFocus;
    if (requestedFocus != null) {
      _lastSearchCenter = requestedFocus;
      _currentZoom = _initialZoom ?? _defaultZoom;
      if (mounted) setState(() {});
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('settings_latitude');
      final lng = prefs.getDouble('settings_longitude');
      if (lat != null && lng != null) {
        _lastSearchCenter = LatLng(lat, lng);
        _currentZoom = _defaultZoom;
      } else {
        _lastSearchCenter = _ibbCenter;
        _currentZoom = _defaultZoom;
      }
    } catch (_) {
      _lastSearchCenter = _ibbCenter;
      _currentZoom = _defaultZoom;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _listScrollController.dispose();
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

  (double, double) _getPropertyCoords(Property prop) {
    return MapClusterService.getPropertyCoordinates(prop);
  }

  /// All listings available to this screen (backend result or demo fallback).
  List<Property> _allListings() {
    final remote = ref.read(allMapPropertiesProvider).value;
    if (remote != null && remote.isNotEmpty) return remote;
    if (SupabaseService.demoProperties.isNotEmpty) {
      return SupabaseService.demoProperties;
    }
    return DemoPropertiesGenerator.cachedDemoProperties;
  }

  /// Frame the filtered listings so the map lands on their actual area instead
  /// of a governorate centroid that can leave every result outside the view.
  void _fitToFiltered(List<Property> filtered) {
    if (filtered.isEmpty || !mounted) return;
    final points = filtered.map((p) {
      final coords = _getPropertyCoords(p);
      return LatLng(coords.$1, coords.$2);
    }).toList();
    try {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: points,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 96),
          maxZoom: 14.5,
        ),
      );
      final camera = _mapController.camera;
      _lastSearchCenter = camera.center;
      _currentZoom = camera.zoom;
    } catch (_) {
      // Camera may not be attached yet (first frame / list mode); the pending
      // flag keeps the request for the next map build.
      _pendingFitToFiltered = true;
      if (mounted) setState(() {});
    }
  }

  // Point in polygon ray-casting test for freehand drawing filter
  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return true;
    bool inside = false;
    int j = polygon.length - 1;
    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].latitude;
      final yi = polygon[i].longitude;
      final xj = polygon[j].latitude;
      final yj = polygon[j].longitude;

      final intersect =
          ((yi > point.longitude) != (yj > point.longitude)) &&
          (point.latitude <
              (xj - xi) * (point.longitude - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
      j = i;
    }
    return inside;
  }

  List<Property> _filterProperties(List<Property> all) {
    final query = _searchController.text.trim().toLowerCase();
    // Applying a governorate filter also writes its localized label into the
    // search box. That label is display text, not a raw Arabic data key, so
    // skip the free-text pass when it exactly mirrors the active filter.
    final queryIsActiveGovernorateLabel =
        _selectedGovName != null &&
        query ==
            AppConstants.getGovernorateNameAr(_selectedGovName!)
                .toLowerCase();

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

      // Filter governorate. Sana'a City and Sana'a Governorate are treated as
      // one area, so choosing "صنعاء" also finds listings stored under
      // "أمانة العاصمة" (e.g. بيت بوس).
      if (!AppConstants.governorateMatches(_selectedGovName, p.city)) {
        return false;
      }

      // Filter district
      if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
        final matchesDist =
            p.district == _selectedDistrict ||
            p.district.contains(_selectedDistrict!) ||
            _selectedDistrict!.contains(p.district);
        if (!matchesDist) return false;
      }

      // Filter text query (city, district, addressDetails, title)
      if (query.isNotEmpty && !queryIsActiveGovernorateLabel) {
        final inCity = p.city.toLowerCase().contains(query);
        final inDist = p.district.toLowerCase().contains(query);
        final inTitle = p.title.toLowerCase().contains(query);
        final inAddr = (p.addressDetails ?? '').toLowerCase().contains(query);
        if (!inCity && !inDist && !inTitle && !inAddr) return false;
      }

      // Filter price
      if (_minPrice != null && p.price < _minPrice!) return false;
      if (_maxPrice != null && p.price > _maxPrice!) return false;

      // Filter bedrooms
      if (_minBedrooms != null && p.bedrooms < _minBedrooms!) return false;

      // Filter exact coordinates only
      if (_onlyExactCoordinates && !MapClusterService.hasExactCoordinates(p)) {
        return false;
      }

      // Filter by custom drawn polygon if active
      if (_drawnPolygon.length > 2) {
        final coords = _getPropertyCoords(p);
        if (!_isPointInPolygon(LatLng(coords.$1, coords.$2), _drawnPolygon)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _makeCall(String phone) async {
    final clean = Formatters.formatPhoneForDialing(phone);
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// فتح Google Maps للملاحة إلى موقع العقار الحقيقي
  Future<void> _openGoogleMapsNavigation(Property prop) async {
    final lat = prop.latitude;
    final lng = prop.longitude;

    if (lat == null || lng == null || lat == 0.0 || lng == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.map_location_missing_message,
              style: AppFonts.cairo(fontSize: 13),
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: context.l10n.map_call,
              textColor: AppColors.textLight,
              onPressed: () => _makeCall(prop.contactPhone),
            ),
          ),
        );
      }
      return;
    }

    // رابط Google Maps للملاحة بإحداثيات العقار الحقيقية
    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving';
    // رابط بديل يفتح موقع العقار مباشرة عبر تطبيق الملاحة
    final googleMapsAppUrl = 'google.navigation:q=$lat,$lng&mode=d';
    final geoUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

    try {
      // محاولة فتح تطبيق Google Maps للملاحة مباشرة
      final appUri = Uri.parse(googleMapsAppUrl);
      if (await canLaunchUrl(appUri)) {
        await launchUrl(appUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    try {
      // محاولة فتح تطبيق الخرائط عبر بروتوكول geo المعتمد
      if (await canLaunchUrl(geoUri)) {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    // فتح رابط Google Maps عبر المتصفح كبديل
    try {
      final webUri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.map_maps_open_error,
              style: AppFonts.cairo(fontSize: 13),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final cleanPhone = Formatters.formatPhoneForWhatsApp(phone);
    final msg = Uri.encodeComponent(
      '${context.l10n.map_whatsapp_prefix}: $title',
    );
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showFilterModal() async {
    final propertyTypes =
        ref.read(propertyTypesProvider).value ?? const <PropertyType>[];
    final result = await showPropertyFilterSheet(
      context: context,
      initial: PropertyFilterSelection(
        dealType: _selectedDealType,
        typeId: _selectedTypeId,
        governorate: _selectedGovName,
        district: _selectedDistrict,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minBedrooms: _minBedrooms,
        onlyExactCoordinates: _onlyExactCoordinates,
      ),
      propertyTypes: propertyTypes,
      showAdvancedFilters: true,
      title: context.l10n.map_filter_title,
    );
    if (result == null || !mounted) return;

    setState(() {
      // Reframe on the filtered coordinates after this rebuild.
      _pendingFitToFiltered = true;
      _selectedDealType = result.dealType;
      _selectedTypeId = result.typeId;
      _selectedGovName = result.governorate;
      _selectedDistrict = result.district;
      _minBedrooms = result.minBedrooms;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _onlyExactCoordinates = result.onlyExactCoordinates;
      _selectedProperty = null;

      if (_selectedGovName != null) {
        _searchController.text =
            AppConstants.getGovernorateNameAr(_selectedGovName!);
        final govCoord = _governorates.firstWhere(
          (g) => g.name == _selectedGovName,
          orElse: () => _governorates.first,
        );
        _lastSearchCenter = LatLng(govCoord.latitude, govCoord.longitude);
        _currentZoom = govCoord.defaultZoom;
        _animatedMapMove(_lastSearchCenter!, govCoord.defaultZoom);
      }
    });
  }

  void _onPropertyTap(Property prop, LatLng centroid) {
    setState(() {
      _selectedProperty = prop;
      _activeCardImageIndex = 0;
    });
    _animatedMapMove(centroid, math.max(_currentZoom, 14.5));
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(allMapPropertiesProvider);
    // Keep property types cached for the shared filter sheet.
    ref.watch(propertyTypesProvider);
    final settings = ref.watch(settingsProvider);
    final isMobile = Responsive.isMobile(context);
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: isDesktop ? null : const AppDrawer(),
      bottomNavigationBar: isDesktop
          ? null
          : const AppBottomNavBar(currentRoute: '/map'),
      body: AppPageBody(
        child: propertiesAsync.when(
          data: (allProperties) {
            final effectiveList = allProperties.isNotEmpty
                ? allProperties
                : SupabaseService.demoProperties.isNotEmpty
                ? SupabaseService.demoProperties
                : DemoPropertiesGenerator.cachedDemoProperties;

            final filteredProperties = _filterProperties(effectiveList);
            _filteredCount = filteredProperties.length;

            if (_pendingFitToFiltered && !_isListView) {
              _pendingFitToFiltered = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _fitToFiltered(_filterProperties(_allListings()));
              });
            }

            // Count badge and list use the same filtered result set as the
            // map markers. Clipping them to the current viewport made correct
            // filters look empty whenever the camera was still at the
            // governorate centroid.
            final mapProperties = filteredProperties;

            // Reset pagination whenever the filters change.
            final filterKey = [
              _searchController.text,
              _selectedDealType,
              _selectedTypeId,
              _selectedGovName,
              _selectedDistrict,
              _minPrice,
              _maxPrice,
              _minBedrooms,
              _onlyExactCoordinates,
              _drawnPolygon.length,
            ].join('|');
            if (filterKey != _lastFilterKey) {
              _lastFilterKey = filterKey;
              _visibleCount = _pageSize;
            }
            _lastFilteredCount = mapProperties.length;
            // Keep the page size inside the actual result length. Without this,
            // filtering to e.g. 3 listings still built 12 rows and threw a
            // RangeError while scrolling.
            if (_visibleCount > _lastFilteredCount) {
              _visibleCount = _lastFilteredCount;
            }

            return Stack(
              children: [
                // 1. Full Screen Interactive Map or List View
                if (!_isListView)
                  GestureDetector(
                    // Handlers for freehand drawing feature
                    onPanStart: _isDrawingMode
                        ? (details) {
                            final latLng = _mapController.camera.offsetToCrs(
                              details.localPosition,
                            );
                            setState(() {
                              _drawnPolygon = [latLng];
                            });
                          }
                        : null,
                    onPanUpdate: _isDrawingMode
                        ? (details) {
                            final latLng = _mapController.camera.offsetToCrs(
                              details.localPosition,
                            );
                            setState(() {
                              _drawnPolygon.add(latLng);
                            });
                          }
                        : null,
                    onPanEnd: _isDrawingMode
                        ? (details) {
                            if (_drawnPolygon.length > 2) {
                              setState(() {
                                _isDrawingMode = false;
                              });
                            }
                          }
                        : null,
                    child: PropertyMapView(
                      properties: filteredProperties,
                      mapController: _mapController,
                      initialCenter: _lastSearchCenter ?? _ibbCenter,
                      initialZoom: _currentZoom,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      isSatellite: _isSatellite,
                      selectedPropertyId: _selectedProperty?.id,
                      highlightGovernorate: _selectedGovName,
                      drawnPolygon: _drawnPolygon,
                      showBoundaries: true,
                      interactionFlags: _isDrawingMode
                          ? InteractiveFlag.none
                          : InteractiveFlag.all,
                      onPositionChanged: (pos, hasGesture) {
                        if (pos.zoom != _currentZoom) {
                          setState(() {
                            _currentZoom = pos.zoom;
                          });
                        }
                        // The map follows the filtered results; a manual pan
                        // no longer offers a separate "search this area" step.
                      },
                      onMapTap: (tapPosition, point) {
                        if (_selectedProperty != null) {
                          setState(() {
                            _selectedProperty = null;
                          });
                        }
                      },
                      onPropertyTap: _onPropertyTap,
                    ),
                  )
                else
                  // Synced List View
                  Container(
                    color: AppColors.background,
                    padding: EdgeInsets.only(top: _headerBottom(context) + 12),
                    child: mapProperties.isEmpty
                        ? _buildEmptyAreaView()
                        : ListView.builder(
                            controller: _listScrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: _visibleCount < _lastFilteredCount
                                ? _visibleCount + 1
                                : _visibleCount,
                            itemBuilder: (context, index) {
                              if (index == _visibleCount) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: OutlinedButton.icon(
                                    onPressed: () => setState(() {
                                      _visibleCount =
                                          (_visibleCount + _pageSize).clamp(
                                            0,
                                            _lastFilteredCount,
                                          );
                                    }),
                                    icon: const Icon(Icons.expand_more_rounded),
                                    label: Text(context.l10n.map_load_more),
                                  ),
                                );
                              }
                              final prop = mapProperties[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: PropertyCard(
                                  property: prop,
                                  layout: PropertyCardLayout.row,
                                  onTap: () {
                                    setState(() {
                                      _isListView = false;
                                      _selectedProperty = prop;
                                      _activeCardImageIndex = 0;
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
                                  trailing: IconButton(
                                    tooltip: context.l10n.map_view_details,
                                    icon: const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 18,
                                    ),
                                    onPressed: () =>
                                        context.push('/property/${prop.id}'),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                // 2. Unified Top Search & Filters Header
                Positioned(top: 0, left: 0, right: 0, child: _buildMapHeader()),

                // 3. Drawing Mode Instruction Banner
                if (_isDrawingMode)
                  Positioned(
                    top: _headerBottom(context) + 8,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.draw_rounded,
                            color: AppColors.textLight,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              context.l10n.map_draw_instruction,
                              style: AppFonts.cairo(
                                color: AppColors.textLight,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isDrawingMode = false;
                                _drawnPolygon.clear();
                              });
                            },
                            child: Text(
                              context.l10n.map_cancel,
                              style: AppFonts.cairo(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. Active Drawn Polygon Filter Badge
                if (_drawnPolygon.isNotEmpty && !_isDrawingMode)
                  Positioned(
                    top: _headerBottom(context) + 8,
                    left: 16,
                    right: 16,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryInk,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.primaryInk,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${context.l10n.map_draw_filter_active} (${mapProperties.length} ${context.l10n.map_result_property_unit})',
                              style: AppFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryInk,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _drawnPolygon.clear();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 6. Floating map controls — one RTL-aware anchored stack.
                //    draw → layers → count → list toggle (top to bottom).
                PositionedDirectional(
                  end: 16,
                  bottom: _selectedProperty != null ? _selectedCardReserve : 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Primary list action: compact add-property FAB. It is
                      // deliberately hidden over the map, where draw/layers
                      // controls already occupy this stack.
                      if (_isListView) ...[
                        const AddPropertyFab(
                          key: ValueKey('map_add_property_fab'),
                          heroTag: 'map_add_property',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!_isListView) ...[
                        _buildSmallMapFab(
                          heroTag: 'map_draw_area',
                          icon: Icons.draw_rounded,
                          tooltip: _isDrawingMode
                              ? context.l10n.map_cancel_draw
                              : context.l10n.map_draw_search_area,
                          highlight: _isDrawingMode,
                          onPressed: () {
                            setState(() {
                              _isDrawingMode = !_isDrawingMode;
                              if (!_isDrawingMode) _drawnPolygon.clear();
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSmallMapFab(
                          heroTag: 'map_layers_toggle',
                          icon: _isSatellite
                              ? Icons.map_rounded
                              : Icons.satellite_alt_rounded,
                          tooltip: _isSatellite
                              ? context.l10n.map_switch_to_streets
                              : context.l10n.map_switch_to_satellite,
                          onPressed: () =>
                              setState(() => _isSatellite = !_isSatellite),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (settings.assetCountVisibility == 'always' ||
                          mapProperties.isNotEmpty)
                        _buildCountBadge(mapProperties),
                      const SizedBox(height: 10),
                      FloatingActionButton.extended(
                        key: const ValueKey('map_list_toggle'),
                        heroTag: 'map_list_toggle',
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        elevation: 4,
                        icon: Icon(
                          _isListView
                              ? Icons.map_rounded
                              : Icons.format_list_bulleted_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isListView
                              ? context.l10n.map_show_map
                              : context.l10n.map_show_list,
                          style: PropertyTextStyles.badge(size: 13),
                        ),
                        onPressed: () {
                          final showingList = _isListView;
                          setState(() => _isListView = !showingList);
                          if (showingList && _pendingFitToFiltered) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (mounted) {
                                _fitToFiltered(
                                  _filterProperties(_allListings()),
                                );
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                // 8. Selected Property Card
                if (_selectedProperty != null && !_isListView)
                  Positioned(
                    bottom: 10,
                    left: isMobile ? 8 : 20,
                    right: isMobile ? 8 : 20,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: _buildSelectedPropertyCard(_selectedProperty!),
                      ),
                    ),
                  ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.map_load_error,
                    style: AppFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.refresh(allMapPropertiesProvider),
                    child: Text(context.l10n.map_retry),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Unified Map Header & Filter Bar (RTL, Responsive, High Contrast)
  Widget _buildMapHeader() {
    final hasActiveFilters =
        _selectedTypeId != null ||
        _minBedrooms != null ||
        _selectedGovName != null ||
        _selectedDistrict != null ||
        _minPrice != null ||
        _maxPrice != null ||
        _onlyExactCoordinates ||
        _selectedDealType.isNotEmpty ||
        _searchController.text.trim().isNotEmpty;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.divider.withAlpha(140)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: AppColors.surface.withAlpha(238),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Search Row: back + pill search + menu
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        children: [
                          _mapHeaderCircleButton(
                            icon: Icons.arrow_back_rounded,
                            tooltip: context.l10n.map_back_home,
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/');
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: _mapHeaderSearchField()),
                          const SizedBox(width: 8),
                          if (!Responsive.isDesktop(context))
                            Builder(
                              builder: (btnCtx) => _mapHeaderCircleButton(
                                icon: Icons.menu_rounded,
                                tooltip: context.l10n.map_main_menu,
                                onPressed: () =>
                                    Scaffold.of(btnCtx).openDrawer(),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Filter Chips Row: filter button opens the bottom sheet;
                    // any active filter is shown as a chip right beside it.
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        children: [
                          // زر الفلاتر الشاملة — يفتح شريحة الفلاتر السفلية
                          _buildFilterBarBtn(
                            label: hasActiveFilters
                                ? context.l10n.map_filters_active
                                : context.l10n.map_filters,
                            icon: Icons.tune,
                            isActive: hasActiveFilters,
                            onTap: _showFilterModal,
                          ),
                          const SizedBox(width: 8),
                          // Live count while filters are being applied.
                          if (hasActiveFilters)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryMuted,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.apartment_rounded,
                                    size: 15,
                                    color: AppColors.primaryInk,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_filteredCount ${context.l10n.map_result_property_unit}',
                                    style: AppFonts.cairo(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryInk,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (hasActiveFilters) const SizedBox(width: 8),
                          // الفلاتر المختارة تظهر كشيكات صغيرة بجوار زر الفلاتر
                          ..._activeFilterChips(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mapHeaderSearchField() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(23),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.primaryInk, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppFonts.cairo(
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.l10n.map_search_hint,
                hintStyle: AppFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => setState(() {}),
              onSubmitted: (_) => setState(() => _pendingFitToFiltered = true),
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _searchController.clear()),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 19,
              ),
            ),
        ],
      ),
    );
  }

  Widget _mapHeaderCircleButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceVariant,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: AppColors.primaryInk, size: 22),
          ),
        ),
      ),
    );
  }

  /// الفلاتر المختارة تظهر كشيكات صغيرة بجوار زر الفلاتر في شريط الرأس.
  List<Widget> _activeFilterChips() {
    final chips = <Widget>[];

    if (_selectedDealType.isNotEmpty) {
      chips.add(
        _buildSelectedFilterChip(
          _selectedDealType == AppConstants.dealSale
              ? context.l10n.map_for_sale
              : context.l10n.map_for_rent,
          onRemoved: () => setState(() => _selectedDealType = ''),
        ),
      );
    }

    if (_selectedTypeId != null && _selectedTypeId!.isNotEmpty) {
      chips.add(
        _buildSelectedFilterChip(
          _propertyTypeLabel(_selectedTypeId!),
          onRemoved: () => setState(() => _selectedTypeId = null),
        ),
      );
    }

    if (_selectedGovName != null && _selectedGovName!.isNotEmpty) {
      chips.add(
        _buildSelectedFilterChip(
          AppConstants.getGovernorateNameAr(_selectedGovName!),
          onRemoved: () => setState(() => _selectedGovName = null),
        ),
      );
    }

    if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) {
      chips.add(
        _buildSelectedFilterChip(
          AppConstants.getDistrictNameAr(_selectedDistrict!),
          onRemoved: () => setState(() => _selectedDistrict = null),
        ),
      );
    }

    if (_minBedrooms != null) {
      chips.add(
        _buildSelectedFilterChip(
          '$_minBedrooms ${context.l10n.map_bedrooms}',
          onRemoved: () => setState(() => _minBedrooms = null),
        ),
      );
    }

    if (_minPrice != null || _maxPrice != null) {
      chips.add(
        _buildSelectedFilterChip(
          '${Formatters.formatCurrency(_minPrice ?? 0, AppConstants.currencyYer)} – ${Formatters.formatCurrency(_maxPrice ?? 0, AppConstants.currencyYer)}',
          onRemoved: () => setState(() {
            _minPrice = null;
            _maxPrice = null;
          }),
        ),
      );
    }

    if (_onlyExactCoordinates) {
      chips.add(
        _buildSelectedFilterChip(
          context.l10n.map_exact_gps_only,
          onRemoved: () => setState(() => _onlyExactCoordinates = false),
        ),
      );
    }

    return chips;
  }

  Widget _buildSelectedFilterChip(
    String label, {
    required VoidCallback onRemoved,
  }) {
    return Chip(
      deleteIcon: const Icon(Icons.close_rounded, size: 16),
      onDeleted: onRemoved,
      label: Text(
        label,
        style: AppFonts.cairo(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      backgroundColor: AppColors.surfaceVariant,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  String _propertyTypeLabel(String typeId) {
    switch (typeId) {
      case 'apartment':
        return context.l10n.map_type_apartment;
      case 'villa':
        return context.l10n.map_type_villa;
      case 'shop':
        return context.l10n.map_type_shop;
      case 'land':
        return context.l10n.map_type_land;
      case 'building':
        return context.l10n.map_type_building;
      case 'office':
        return context.l10n.map_type_office;
      default:
        return context.l10n.map_property_type;
    }
  }

  /// زر شريط الفلاتر العلوي — موحد ومنظم
  Widget _buildFilterBarBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (AppColors.isDark
                    ? AppColors.primaryMuted.withAlpha(140)
                    : AppColors.primaryMuted)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? AppColors.primaryInk : AppColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppFonts.cairo(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primaryInk : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small secondary map control (layers / draw) using app tokens.
  Widget _buildSmallMapFab({
    required String heroTag,
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool highlight = false,
  }) {
    return FloatingActionButton.small(
      heroTag: heroTag,
      backgroundColor: highlight ? AppColors.primary : AppColors.surfaceVariant,
      foregroundColor: highlight ? AppColors.textLight : AppColors.primaryInk,
      elevation: 2,
      tooltip: tooltip,
      onPressed: onPressed,
      child: Icon(icon, size: 20),
    );
  }

  /// زر دائري للإجراءات في بطاقة العقار
  Widget _buildCircleActionBtn({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
            color: color.withAlpha(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }

  Widget _buildEmptyAreaView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.map_no_properties_in_area,
              style: AppFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.map_no_properties_area_hint,
              textAlign: TextAlign.center,
              style: AppFonts.cairo(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Property count badge — capsule with the same height (40 dp) and
  // fully-rounded shape as the draw / satellite buttons beside it.
  Widget _buildCountBadge(List<Property> properties) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(AppColors.isDark ? 70 : 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.apartment_rounded, size: 16, color: AppColors.primaryInk),
          const SizedBox(width: 8),
          Text(
            '${properties.length} ${context.l10n.map_properties_available}',
            style: AppFonts.cairo(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  // Selected Property Card — shared card with map-specific actions as slots.
  Widget _buildSelectedPropertyCard(
    Property prop, {
    VoidCallback? onSelectOnMap,
  }) {
    final l10n = context.l10n;
    final isRent = prop.isForRent;
    final images = prop.images
        .map((img) => img.imageUrl)
        .where((url) => url.isNotEmpty)
        .toList();
    final isFloating = onSelectOnMap == null;
    final hasExactGps =
        prop.latitude != null &&
        prop.longitude != null &&
        prop.latitude != 0.0 &&
        prop.longitude != 0.0;

    final discountPill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isRent ? l10n.map_rent_discount : l10n.map_sale_discount,
        style: PropertyTextStyles.badge(size: 10.5),
      ),
    );

    return PropertyCard(
      property: prop,
      layout: PropertyCardLayout.overlay,
      imageUrls: images,
      activeImageIndex: _activeCardImageIndex,
      onImageIndexChanged: (index) => _activeCardImageIndex = index,
      onClose: isFloating
          ? () => setState(() => _selectedProperty = null)
          : null,
      onTap: onSelectOnMap ?? () => context.push('/property/${prop.id}'),
      extraBadges: [discountPill],
      trailing: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: Icon(Icons.more_horiz, color: AppColors.textMuted),
        tooltip: l10n.map_view_details,
        onPressed: () => context.push('/property/${prop.id}'),
      ),
      priceCaption: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors.primaryInk, size: 14),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              isRent
                  ? l10n.map_total_monthly_price
                  : l10n.map_final_purchase_price,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PropertyTextStyles.caption(),
            ),
          ),
        ],
      ),
      locationDetail: Row(
        children: [
          Icon(
            hasExactGps ? Icons.location_on : Icons.near_me_outlined,
            size: 13,
            color: hasExactGps ? AppColors.primaryInk : AppColors.warning,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              hasExactGps
                  ? l10n.map_exact_location
                  : '${l10n.map_approximate_location_prefix} ${AppConstants.getGovernorateNameAr(prop.city)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PropertyTextStyles.caption(size: 10.5).copyWith(
                color: hasExactGps ? AppColors.primaryInk : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
      actions: [
        _buildCircleActionBtn(
          icon: Icons.phone,
          color: AppColors.primary,
          tooltip: l10n.map_call,
          onTap: () => _makeCall(prop.contactPhone),
        ),
        const SizedBox(width: 6),
        if (prop.contactWhatsapp != null && prop.contactWhatsapp!.isNotEmpty)
          _buildCircleActionBtn(
            icon: Icons.chat,
            color: AppColors.success,
            tooltip: l10n.map_whatsapp,
            onTap: () => _openWhatsApp(prop.contactWhatsapp!, prop.title),
          ),
        const SizedBox(width: 6),
        _buildCircleActionBtn(
          icon: Icons.directions_rounded,
          color: AppColors.success,
          tooltip: l10n.map_directions,
          onTap: () => _openGoogleMapsNavigation(prop),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SizedBox(
            height: 40,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed:
                  onSelectOnMap ?? () => context.push('/property/${prop.id}'),
              child: Text(
                isRent ? l10n.map_check_availability : l10n.map_view_details,
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
      secondaryAction: isFloating
          ? SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.success,
                  side: const BorderSide(color: AppColors.success, width: 1.5),
                  minimumSize: const Size(0, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.directions_rounded, size: 18),
                label: Text(
                  l10n.map_directions_google_maps,
                  style: AppFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () => _openGoogleMapsNavigation(prop),
              ),
            )
          : null,
    );
  }
}
