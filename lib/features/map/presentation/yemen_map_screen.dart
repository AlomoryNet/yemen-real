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
import '../../../services/device_location_service.dart';
import '../../../models/map_query.dart';
import '../../../models/property.dart';
import '../../../models/property_type.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/map_query_provider.dart';
import '../../../providers/property_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../shared/widgets/add_property_fab.dart';
import '../../../shared/widgets/app_bottom_nav_bar.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/app_page_body.dart';
import '../../../shared/widgets/empty_state_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/map/user_location.dart';
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

/// Public route widget. It gives every map visit its own [mapQueryProvider]
/// scope, seeded before the first frame, so dashboard arguments and direct
/// visits share one query source without mutating a provider in initState.
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
  ConsumerState<YemenMapScreen> createState() => _YemenMapScreenScopeState();
}

class _YemenMapScreenScopeState extends ConsumerState<YemenMapScreen> {
  late final MapQuery _initialQuery;

  @override
  void initState() {
    super.initState();
    _initialQuery = _YemenMapScreenState.seedQuery(
      incoming: widget.initialFilters,
      initialListView: widget.initialListView,
      settings: ref.read(settingsProvider),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        mapQueryProvider.overrideWith(
          (_) => MapQueryNotifier(_initialQuery),
        ),
      ],
      child: YemenMapView(
        initialListView: widget.initialListView,
        initialFilters: widget.initialFilters,
      ),
    );
  }
}

class YemenMapView extends ConsumerStatefulWidget {
  const YemenMapView({
    super.key,
    this.initialListView = false,
    this.initialFilters,
  });

  final bool initialListView;
  final MapScreenArgs? initialFilters;

  @override
  ConsumerState<YemenMapView> createState() => _YemenMapScreenState();
}

class _YemenMapScreenState extends ConsumerState<YemenMapView>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  final TextEditingController _searchController = TextEditingController();

  // One reusable camera animation: filter/search moves restart it instead of
  // creating a new controller (and ticker) per call, and dispose() can stop it
  // when the route is popped mid-flight.
  late final AnimationController _cameraAnimationController;
  double _cameraLatFrom = 0;
  double _cameraLatTo = 0;
  double _cameraLngFrom = 0;
  double _cameraLngTo = 0;
  double _cameraZoomFrom = _defaultZoom;
  double _cameraZoomTo = _defaultZoom;
  bool _hasCameraAnimation = false;

  Property? _selectedProperty;

  /// Remembered so the async SharedPreferences refinement does not overwrite a
  /// governorate the user picked before it completed.
  String? _seededGovernorate;

  /// Only a plain /map visit may infer its governorate from stored location.
  /// Dashboard presets carry explicit filters (sometimes with the generic
  /// `general` source), and must keep the governorate they were given.
  late final bool _inferDefaultGovernorate;

  double _currentZoom = _defaultZoom;
  LatLng? _userLocation;
  bool _userLocationAppliedToCamera = false;
  bool _skipNextQueryFit = false;
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
  static const double _headerChipHeight = 48;
  static const double _headerGap = 8;
  static const double _selectedCardReserve = 372;

  double _headerBottom(BuildContext context) =>
      MediaQuery.paddingOf(context).top +
      _headerPadding +
      _headerSearchHeight +
      _headerGap +
      _headerChipHeight +
      _headerGap;

  /// Nearest governorate centre to a stored device location. Squared degree
  /// distance is enough at this scale and avoids creating a Distance object on
  /// every map open.
  static YemenGovernorateCoord _governorateForLocation(LatLng location) {
    var best = _governorates.first;
    var bestDistance = double.infinity;
    for (final gov in _governorates) {
      final latDelta = gov.latitude - location.latitude;
      final lngDelta = gov.longitude - location.longitude;
      final distance = latDelta * latDelta + lngDelta * lngDelta;
      if (distance < bestDistance) {
        bestDistance = distance;
        best = gov;
      }
    }
    return best;
  }

  static YemenGovernorateCoord? _governorateForName(String name) {
    for (final gov in _governorates) {
      if (gov.name == name ||
          gov.name.contains(name) ||
          name.contains(gov.name)) {
        return gov;
      }
    }
    return null;
  }

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

  /// Build the one immutable query used by the whole map surface. Called once
  /// per route from the outer scope so it never overwrites live user filters.
  static MapQuery seedQuery({
    required MapScreenArgs? incoming,
    required bool initialListView,
    required SettingsState settings,
  }) {
    final storedLocation =
        settings.latitude != null && settings.longitude != null
        ? LatLng(settings.latitude!, settings.longitude!)
        : _ibbCenter;
    final defaultGovernorate = _governorateForLocation(storedLocation);

    final view = incoming != null
        ? (incoming.initialListView ? MapViewMode.list : MapViewMode.map)
        : initialListView || settings.defaultMapView == 'list'
        ? MapViewMode.list
        : MapViewMode.map;

    if (incoming != null) {
      return MapQuery(
        freeText: incoming.searchQuery ?? '',
        dealType: incoming.dealType ?? '',
        propertyTypeId: incoming.propertyTypeId,
        governorate: (incoming.city == null || incoming.city!.isEmpty)
            ? null
            : incoming.city,
        district: (incoming.district == null || incoming.district!.isEmpty)
            ? null
            : incoming.district,
        onlyFeatured: incoming.onlyFeatured,
        nearbyCenter: incoming.nearbyCenter,
        radiusKm: incoming.radiusKm,
        view: view,
        source: incoming.source,
      );
    }

    // Direct /map visits start scoped to the user's city. Only the chip shows
    // that scope; the search field stays user-owned.
    return MapQuery(
      governorate: defaultGovernorate.name,
      view: view,
      source: MapQuerySource.general,
    );
  }

  @override
  void initState() {
    super.initState();
    _inferDefaultGovernorate = widget.initialFilters == null;
    _mapController = MapController();
    _cameraAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addListener(_applyCameraAnimation);

    // The outer route scope has already seeded this provider before the first
    // frame; the screen never mutates it during a widget lifecycle.
    final seed = ref.read(mapQueryProvider);
    final settings = ref.read(settingsProvider);
    final storedLocation =
        settings.latitude != null && settings.longitude != null
        ? LatLng(settings.latitude!, settings.longitude!)
        : _ibbCenter;
    final defaultGovernorate = _governorateForLocation(storedLocation);

    if (seed.governorate != null) {
      final gov = _governorateForName(seed.governorate!) ?? defaultGovernorate;
      _initialFocus = LatLng(gov.latitude, gov.longitude);
      _initialZoom = gov.defaultZoom;
    } else if (seed.nearbyCenter != null) {
      _initialFocus = seed.nearbyCenter;
      _initialZoom = _defaultZoom;
    }

    _seededGovernorate = seed.governorate;
    _searchController.text = seed.freeText;
    _requestFitToFiltered();

    // The provider may still be loading persisted coordinates; _initMapCenter
    // refines the default governorate once SharedPreferences is available.
    _initMapCenter();
    _restoreUserLocation();
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

  /// Initialize map center and zoom. Dashboard presets keep their own focus;
  /// only plain /map visits refine the default governorate from SharedPreferences.
  Future<void> _initMapCenter() async {
    final current = ref.read(mapQueryProvider);
    // Explicit dashboard/search presets own their governorate. A plain /map
    // visit is the only case allowed to refine it from stored coordinates.
    if (!_inferDefaultGovernorate || current.source != MapQuerySource.general) {
      if (_initialFocus == null) return;
      _lastSearchCenter = _initialFocus;
      _currentZoom = _initialZoom ?? _defaultZoom;
      if (mounted) setState(() {});
      return;
    }

    var location = _ibbCenter;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('settings_latitude');
      final lng = prefs.getDouble('settings_longitude');
      if (lat != null && lng != null) location = LatLng(lat, lng);
    } catch (_) {
      // Fall back to Ibb when preferences are unavailable.
    }

    if (!mounted) return;
    // A live user position won the race while preferences were loading.
    if (_userLocationAppliedToCamera) return;
    final latest = ref.read(mapQueryProvider);
    // Do not overwrite a governorate the user changed while prefs were loading.
    if (latest.source != MapQuerySource.general ||
        latest.governorate != _seededGovernorate) {
      return;
    }

    final governorate = _governorateForLocation(location);
    setState(() {
      _initialFocus = LatLng(governorate.latitude, governorate.longitude);
      _initialZoom = governorate.defaultZoom;
      _lastSearchCenter = _initialFocus;
      _currentZoom = governorate.defaultZoom;
    });
    if (latest.governorate != governorate.name) {
      ref
          .read(mapQueryProvider.notifier)
          .update((query) => query.copyWith(governorate: governorate.name));
    }
  }

  /// Show the device dot when permission is already granted, without prompting.
  /// A stored location (saved by the first-run flow or Settings) has already
  /// driven the initial camera, so only a permission granted outside those
  /// flows needs an extra camera move here.
  Future<void> _restoreUserLocation() async {
    final result = await DeviceLocationService.currentLocationIfPermitted();
    if (!mounted || !result.hasPosition) return;
    final position = result.position!;
    setState(() => _userLocation = position);

    final settings = ref.read(settingsProvider);
    final query = ref.read(mapQueryProvider);
    if (!_inferDefaultGovernorate ||
        settings.latitude != null ||
        query.source != MapQuerySource.general) {
      return;
    }

    _userLocationAppliedToCamera = true;
    _pendingFitToFiltered = false;
    final governorate = _governorateForLocation(position);
    if (query.governorate != governorate.name) {
      _skipNextQueryFit = true;
      ref.read(mapQueryProvider.notifier).update(
            (current) => current.copyWith(governorate: governorate.name),
          );
    }

    setState(() {
      _lastSearchCenter = position;
      _currentZoom = 15;
    });

    // Before the first frame the FlutterMap options above own the camera;
    // afterwards animate so the change is visible to the user.
    try {
      _mapController.camera;
      _animatedMapMove(position, 15);
    } catch (_) {
      // MapController is not attached yet — initialCenter has been updated.
    }
  }

  void _onUserLocated(LatLng position) {
    setState(() => _userLocation = position);
    _animatedMapMove(position, math.max(_currentZoom, 15));
  }

  @override
  void dispose() {
    _cameraAnimationController
      ..stop()
      ..removeListener(_applyCameraAnimation)
      ..dispose();
    _listScrollController.dispose();
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _applyCameraAnimation() {
    if (!mounted || !_hasCameraAnimation) return;
    final t = Curves.easeInOutCubic.transform(_cameraAnimationController.value);
    _mapController.move(
      LatLng(
        _cameraLatFrom + (_cameraLatTo - _cameraLatFrom) * t,
        _cameraLngFrom + (_cameraLngTo - _cameraLngFrom) * t,
      ),
      _cameraZoomFrom + (_cameraZoomTo - _cameraZoomFrom) * t,
    );
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!mounted) return;
    try {
      final camera = _mapController.camera;
      _cameraLatFrom = camera.center.latitude;
      _cameraLatTo = destLocation.latitude;
      _cameraLngFrom = camera.center.longitude;
      _cameraLngTo = destLocation.longitude;
      _cameraZoomFrom = camera.zoom;
      _cameraZoomTo = destZoom;
      _hasCameraAnimation = true;
      _cameraAnimationController
        ..reset()
        ..forward();
    } catch (_) {
      // Controller can still be unattached during the first frame.
    }
  }

  /// A filter change makes fit-to-results the only camera authority. Leaving a
  /// governorate move running used to overwrite the fit on the next tick.
  void _stopCameraAnimation() {
    if (!_hasCameraAnimation) return;
    _cameraAnimationController.stop();
    _hasCameraAnimation = false;
  }

  void _requestFitToFiltered() {
    _stopCameraAnimation();
    _pendingFitToFiltered = true;
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
    }).where((point) {
      return point.latitude.isFinite && point.longitude.isFinite;
    }).toList();
    if (points.isEmpty) return;

    var minLat = points.map((p) => p.latitude).reduce(math.min);
    var maxLat = points.map((p) => p.latitude).reduce(math.max);
    var minLng = points.map((p) => p.longitude).reduce(math.min);
    var maxLng = points.map((p) => p.longitude).reduce(math.max);

    // Two listings in the same street produce a near-zero span. Expanding it
    // keeps the fit at a readable neighbourhood zoom instead of the cap.
    const minSpan = 0.006;
    final latCenter = (minLat + maxLat) / 2;
    final lngCenter = (minLng + maxLng) / 2;
    if (maxLat - minLat < minSpan) {
      minLat = latCenter - minSpan / 2;
      maxLat = latCenter + minSpan / 2;
    }
    if (maxLng - minLng < minSpan) {
      minLng = lngCenter - minSpan / 2;
      maxLng = lngCenter + minSpan / 2;
    }

    // Only guard against a world-level camera. The old 11.5 floor made a
    // Reset-to-all-Yemen fit impossible even though the bounds were correct.
    // Tiny result sets are handled above by expanding the bounds instead.
    const minFitZoom = 3.0;
    const maxFitZoom = 14.0;
    try {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [LatLng(minLat, minLng), LatLng(maxLat, maxLng)],
          padding: EdgeInsets.only(
            left: 48,
            right: 48,
            top: _headerBottom(context) + 16,
            bottom: _selectedProperty != null ? 180 : 96,
          ),
          minZoom: minFitZoom,
          maxZoom: maxFitZoom,
        ),
      );
      final camera = _mapController.camera;
      _lastSearchCenter = camera.center;
      _currentZoom = camera.zoom.clamp(minFitZoom, maxFitZoom).toDouble();
    } catch (_) {
      // Camera may not be attached yet (first frame / list mode); the pending
      // flag keeps the request for the next map build.
      _requestFitToFiltered();
      if (mounted) setState(() {});
    }
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
      initial: ref.read(mapQueryProvider).toSelection,
      propertyTypes: propertyTypes,
      showAdvancedFilters: true,
      title: context.l10n.map_filter_title,
    );
    if (result == null || !mounted) return;

    // Apply/Reset is one commit. The provider listener updates chips, results
    // and the camera; the search field is never rewritten with a location label.
    ref.read(mapQueryProvider.notifier).applySelection(result);
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
    final query = ref.watch(mapQueryProvider);

    // One subscription for every committed query change: keep the text field
    // in sync and reframe the camera. Free-text typing is excluded from the
    // camera key and reframes only on explicit submit.
    ref.listen<MapQuery>(mapQueryProvider, (previous, next) {
      if (!mounted) return;
      if (previous?.freeText != next.freeText &&
          _searchController.text != next.freeText) {
        _searchController.text = next.freeText;
        _searchController.selection = TextSelection.collapsed(
          offset: next.freeText.length,
        );
      }
      if (previous != null && previous.cameraKey == next.cameraKey) return;
      // The silent "point at me" update is a camera move of its own; letting
      // fit-to-results run here would immediately undo it.
      if (_skipNextQueryFit) {
        _skipNextQueryFit = false;
        return;
      }
      _requestFitToFiltered();
      if (_selectedProperty != null) {
        setState(() => _selectedProperty = null);
      }
    });

    final isListView = query.view == MapViewMode.list;
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

            final filteredProperties = filterMapProperties(
              listings: effectiveList,
              query: query,
              drawnPolygon: _drawnPolygon,
            );
            _filteredCount = filteredProperties.length;

            if (_pendingFitToFiltered && !isListView) {
              _pendingFitToFiltered = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _fitToFiltered(filterMapProperties(
                    listings: _allListings(),
                    query: ref.read(mapQueryProvider),
                    drawnPolygon: _drawnPolygon,
                  ));
                }
              });
            }

            // Count badge and list use the same filtered result set as the
            // map markers. Clipping them to the current viewport made correct
            // filters look empty whenever the camera was still at the
            // governorate centroid.
            final mapProperties = filteredProperties;

            // Reset pagination whenever the filters change.
            final filterKey = '${query.filterKey}|${_drawnPolygon.length}';
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
                if (!isListView)
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
                      highlightGovernorate: query.governorate,
                      drawnPolygon: _drawnPolygon,
                      showBoundaries: true,
                      userLocation: _userLocation,
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
                                    ref
                                        .read(mapQueryProvider.notifier)
                                        .setView(MapViewMode.map);
                                    setState(() {
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
                            Tooltip(
                              message: context.l10n.map_clear_draw,
                              child: Material(
                                color: AppColors.surfaceVariant,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () {
                                    setState(() {
                                      _drawnPolygon.clear();
                                    });
                                  },
                                  child: SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
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
                      // controls already occupy this stack, and in the
                      // Settings "Outline button on Home" mode.
                      if (isListView && settings.addPropertyStyle == 'fab') ...[
                        const AddPropertyFab(
                          key: ValueKey('map_add_property_fab'),
                          heroTag: 'map_add_property',
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (!isListView) ...[
                        LocateMeButton(
                          heroTag: 'map_locate_me',
                          onLocated: _onUserLocated,
                        ),
                        const SizedBox(height: 8),
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
                          isListView
                              ? Icons.map_rounded
                              : Icons.format_list_bulleted_rounded,
                          size: 18,
                        ),
                        label: Text(
                          isListView
                              ? context.l10n.map_show_map
                              : context.l10n.map_show_list,
                          style: PropertyTextStyles.badge(size: 13),
                        ),
                        onPressed: () {
                          final showingList = isListView;
                          ref.read(mapQueryProvider.notifier).setView(
                                showingList ? MapViewMode.map : MapViewMode.list,
                              );
                          if (showingList) _requestFitToFiltered();
                        },
                      ),
                    ],
                  ),
                ),
                // 8. Selected Property Card
                if (_selectedProperty != null && !isListView)
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
          loading: () => LoadingView(message: context.l10n.loading),
          error: (err, stack) => ErrorView(
            title: context.l10n.map_load_error,
            message: err.toString(),
            onRetry: () => ref.refresh(allMapPropertiesProvider),
          ),
        ),
      ),
    );
  }

  // Unified Map Header & Filter Bar (RTL, Responsive, High Contrast)
  Widget _buildMapHeader() {
    final query = ref.read(mapQueryProvider);
    final hasActiveFilters = query.hasActiveFilters;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border.withAlpha(120)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                color: AppColors.surface.withAlpha(244),
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
                      height: _headerChipHeight,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        children: [
                          // زر الفلاتر الشاملة — يفتح شريحة الفلاتر السفلية
                          Center(
                            child: _buildFilterBarBtn(
                              label: hasActiveFilters
                                  ? context.l10n.map_filters_active
                                  : context.l10n.map_filters,
                              icon: Icons.tune,
                              isActive: hasActiveFilters,
                              onTap: _showFilterModal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Always show the live result total. Modern map apps
                          // keep this visible so the user can tell at a glance
                          // whether a filter is narrowing the map.
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryFill,
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
                          ),
                          const SizedBox(width: 8),
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
      height: _headerSearchHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(_headerSearchHeight / 2),
        border: Border.all(color: AppColors.divider.withAlpha(120)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryMuted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search_rounded,
              color: AppColors.primaryInk,
              size: 18,
            ),
          ),
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
              onChanged: (val) =>
                  ref.read(mapQueryProvider.notifier).setFreeText(val),
              onSubmitted: (val) {
                ref.read(mapQueryProvider.notifier).setFreeText(val);
                _requestFitToFiltered();
              },
              textInputAction: TextInputAction.search,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              tooltip: context.l10n.map_clear_search,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: Icon(
                Icons.close_rounded,
                color: AppColors.textSecondary,
                size: 19,
              ),
              onPressed: () {
                ref.read(mapQueryProvider.notifier).setFreeText('');
                _requestFitToFiltered();
              },
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
            width: 48,
            height: 48,
            child: Icon(icon, color: AppColors.primaryInk, size: 22),
          ),
        ),
      ),
    );
  }

  /// Chips are a pure rendering of the committed query. Every removal is a
  /// single provider commit, so results, count and camera stay in lockstep.
  List<Widget> _activeFilterChips() {
    final query = ref.read(mapQueryProvider);
    final notifier = ref.read(mapQueryProvider.notifier);
    final chips = <Widget>[];

    void add(String label, MapQuery Function(MapQuery current) clear) {
      chips.add(
        Center(
          child: _buildSelectedFilterChip(
            label,
            onRemoved: () => notifier.update(clear),
          ),
        ),
      );
    }

    if (query.onlyFeatured) {
      add(context.l10n.sh_property_featured, (q) => q.copyWith(onlyFeatured: false));
    }

    if (query.nearbyCenter != null && query.radiusKm != null) {
      add(context.l10n.near_you, (q) => q.copyWith(
            nearbyCenter: null,
            radiusKm: null,
          ));
    }

    if (query.dealType.isNotEmpty) {
      add(
        query.dealType == AppConstants.dealSale
            ? context.l10n.map_for_sale
            : context.l10n.map_for_rent,
        (q) => q.copyWith(dealType: ''),
      );
    }

    if (query.propertyTypeId != null && query.propertyTypeId!.isNotEmpty) {
      add(_propertyTypeLabel(query.propertyTypeId!), (q) => q.copyWith(
            propertyTypeId: null,
          ));
    }

    if (query.governorate != null && query.governorate!.isNotEmpty) {
      add(AppConstants.getGovernorateNameAr(query.governorate!), (q) => q.copyWith(
            governorate: null,
          ));
    }

    if (query.district != null && query.district!.isNotEmpty) {
      add(AppConstants.getDistrictNameAr(query.district!), (q) => q.copyWith(
            district: null,
          ));
    }

    if (query.minBedrooms != null) {
      add('${query.minBedrooms} ${context.l10n.map_bedrooms}', (q) => q.copyWith(
            minBedrooms: null,
          ));
    }

    if (query.minPrice != null || query.maxPrice != null) {
      add(
        '${Formatters.formatCurrency(query.minPrice ?? 0, AppConstants.currencyYer)} – '
        '${Formatters.formatCurrency(query.maxPrice ?? 0, AppConstants.currencyYer)}',
        (q) => q.copyWith(minPrice: null, maxPrice: null),
      );
    }

    if (query.onlyExactCoordinates) {
      add(context.l10n.map_exact_gps_only, (q) => q.copyWith(
            onlyExactCoordinates: false,
          ));
    }

    if (chips.length > 1) {
      add(context.l10n.clear_all, (q) => q.resetFilters());
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

  /// زر شريط الفلاتر العلوي — Material 3 action-chip styling with a real
  /// ripple, a 48dp touch target and semantic foreground/background tokens.
  Widget _buildFilterBarBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? AppColors.primaryFill : AppColors.surfaceVariant,
      shape: StadiumBorder(
        side: BorderSide(
          color: isActive
              ? AppColors.primaryInk.withAlpha(80)
              : AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 17,
                  color: isActive
                      ? AppColors.primaryInk
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: isActive
                        ? AppColors.primaryInk
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
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
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
            color: color.withAlpha(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildEmptyAreaView() {
    return EmptyStateView(
      icon: Icons.location_off_outlined,
      title: context.l10n.map_no_properties_in_area,
      description: context.l10n.map_no_properties_area_hint,
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
        borderRadius: BorderRadiusGeometry.all(Radius.circular(16.0)),
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
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
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
