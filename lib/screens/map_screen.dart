import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:kinondoni_openspace_app/data/local/openspace_local.dart';
import 'package:kinondoni_openspace_app/data/repository/openspace_repository.dart';
import 'package:kinondoni_openspace_app/service/openspace_service.dart';
import 'package:kinondoni_openspace_app/service/offline_map_service.dart';
import 'package:kinondoni_openspace_app/service/routing_service.dart';
import 'package:provider/provider.dart';
import '../model/openspace.dart';

import '../utils/location_service.dart';
import '../utils/constants.dart';
import '../utils/map_style_config.dart';
import '../utils/alert/access_denied_dialog.dart';
import '../providers/user_provider.dart';
import '../widget/custom_navigation_bar.dart';
import '../l10n/app_localizations.dart';

enum MapLaunchIntent { browse, report, booking }

class MapScreen extends StatefulWidget {
  final bool showBottomNav;
  final MapLaunchIntent launchIntent;
  const MapScreen({
    super.key,
    this.showBottomNav = true,
    this.launchIntent = MapLaunchIntent.browse,
  });

  @override
  MapScreenState createState() => MapScreenState();
}

class MapLayerOption {
  final String name;
  final String url;
  final IconData icon;
  MapLayerOption({required this.name, required this.url, required this.icon});
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  late final OpenSpaceRepository _openSpaceRepository;
  bool _isTracking = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  LatLng _initialPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  List<OpenSpaceMarker> kinondoniSpaces = [];
  OpenSpaceMarker? _selectedSpace;
  LatLng? _selectedPosition;
  // final int _selectedIndex = 1;
  bool _isLoading = true;
  String? _errorMessage;
  final int _currentIndex = 1;
  List<LatLng>? _routePoints;
  bool _isLoadingRoute = false;
  bool _isNavigating = false;
  bool _navigationStarted = false;
  String _navigationInstruction = '';
  List<NavigationStep> _navigationSteps = [];
  StreamSubscription<Position>? _navigationSubscription;
  double _routeDistance = 0.0;
  double _routeDuration = 0.0;
  String _travelMode = 'driving';
  double _currentSpeed = 0.0;

  OpenSpaceMarker _emptyMarker(LatLng point) {
    return OpenSpaceMarker(
      id: '',
      name: '',
      district: '',
      street: '', // <-- added
      latitude: point.latitude,
      longitude: point.longitude,
      isActive: false,
      status: '',
    );
  }

  final List<MapLayerOption> tileLayers = [
    MapLayerOption(
      name: "Street",
      url: MapStyleConfig.streets,
      icon: Icons.map_outlined,
    ),
    MapLayerOption(
      name: "Satellite",
      url: MapStyleConfig.satellite,
      icon: Icons.satellite_alt_outlined,
    ),
    MapLayerOption(
      name: "Topographic",
      url: MapStyleConfig.topographic,
      icon: Icons.terrain_outlined,
    ),
    MapLayerOption(
      name: "Basic",
      url: MapStyleConfig.basic,
      icon: Icons.layers_outlined,
    ),
  ];

  int selectedLayerIndex = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _openSpaceRepository = OpenSpaceRepository(
      remoteService: OpenSpaceService(), // online service
      localService: OpenSpaceLocal(), // offline service
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _opacityAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_controller);

    _fetchOpenSpaces();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkMapInitialization();
    });

    _locationService.getLocationStream().listen(
      (position) {
        if (_isTracking && mounted) {
          setState(() {
            _initialPosition = LatLng(position.latitude, position.longitude);
          });
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            _mapController.camera.zoom,
          );
        }
      },
      onError: (e) {
        if (kDebugMode) {
          print('Location stream error: $e');
        }
      },
    );
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isAnonymous = userProvider.user.isAnonymous;

    switch (index) {
      case 0:
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        break;
      case 1:
        // Already on Open Spaces.
        break;
      case 2:
        Navigator.pushNamed(
          context,
          isAnonymous ? '/guest-profile' : '/user-profile',
        );
        break;
      case 3:
        Navigator.pushNamed(context, '/setting');
        break;
    }
  }

  Future<void> _fetchOpenSpaces() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final spaces = await _openSpaceRepository.getAllOpenSpaces();

      if (mounted) {
        setState(() {
          kinondoniSpaces = spaces;
          _isLoading = false;
        });

        if (kinondoniSpaces.isNotEmpty) {
          _mapController.move(kinondoniSpaces.first.point, 15.0);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst(
            RegExp(r'^Exception:\s*'),
            '',
          );
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric)),
        );
      }
      if (kDebugMode) print('Fetch open spaces error: $e');
    }
  }

  void _checkMapInitialization() {
    try {
      _getUserLocation();
    } catch (e) {
      if (kDebugMode) {
        print('Map initialization error: $e');
      }
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _checkMapInitialization();
        }
      });
    }
  }

  @override
  void dispose() {
    _selectedAreaNameNotifier.dispose();
    _controller.dispose();
    _mapController.dispose();
    _navigationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    try {
      final userLocation = await _locationService.getUserLocation(
        useCache: true,
      );
      if (mounted) {
        setState(() {
          if (userLocation != null) {
            _initialPosition = userLocation;
          }
        });
        if (userLocation != null) {
          _mapController.move(userLocation, 15.0);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.unableFetchLocation),
            ),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user location');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.locationError)),
        );
      }
    }
  }

  void _toggleLocationTracking() {
    setState(() {
      _isTracking = !_isTracking;
      if (_isTracking) {
        _controller.repeat(reverse: true);
        _getUserLocation();
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    });
  }

  // Use a ValueNotifier to update the bottom sheet reactively without blocking the main UI
  final ValueNotifier<String?> _selectedAreaNameNotifier =
      ValueNotifier<String?>(null);

  Future<void> _showLocationPopup(
    LatLng position, {
    OpenSpaceMarker? openSpace,
  }) async {
    if (!mounted) return;

    // 1. Prepare initial state
    setState(() {
      _selectedSpace = openSpace ?? _emptyMarker(position);
      _selectedPosition = position;
    });
    _selectedAreaNameNotifier.value = null; // Reset notifier for the new tap

    // 2. Show the bottom sheet IMMEDIATELY
    // We don't await this because we want to start geocoding concurrently
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: AppConstants.navy.withValues(alpha: 0.58),
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return ValueListenableBuilder<String?>(
          valueListenable: _selectedAreaNameNotifier,
          builder: (context, areaName, _) {
            return _buildBottomSheetWithContent(areaName);
          },
        );
      },
    ).then((_) {
      if (mounted) _closePopup();
    });

    // 3. Start geocoding in the background
    try {
      final areaName =
          await _locationService.getAreaName(position) ?? "Unknown Area";

      // 4. Update the sheet reactively
      if (mounted) {
        _selectedAreaNameNotifier.value = areaName;
      }
    } catch (e) {
      if (mounted) {
        _selectedAreaNameNotifier.value = "Unknown Area";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric)),
        );
      }
      if (kDebugMode) print('Error background geocoding: $e');
    }
  }

  Future<void> _handleLocationSelection(
    LatLng position, {
    OpenSpaceMarker? openSpace,
  }) async {
    if (!mounted) return;

    if (openSpace == null || widget.launchIntent == MapLaunchIntent.browse) {
      await _showLocationPopup(position, openSpace: openSpace);
      return;
    }

    setState(() {
      _selectedSpace = openSpace;
      _selectedPosition = position;
    });

    switch (widget.launchIntent) {
      case MapLaunchIntent.booking:
        _bookSpace();
        break;
      case MapLaunchIntent.report:
        _reportSpace();
        break;
      case MapLaunchIntent.browse:
        break;
    }
  }

  void _closePopup() {
    if (mounted) {
      setState(() {
        _selectedPosition = null;
        _selectedSpace = null;
      });
      _selectedAreaNameNotifier.value = null;
    }
  }

  void _bookSpace() {
    if (_selectedSpace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noSpaceSelected)),
      );
      return;
    }

    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user.isAnonymous) {
      showAccessDeniedDialog(context, featureName: "booking");
      return;
    }

    if (_selectedSpace!.isAvailable) {
      final int? spaceIdForBooking = int.tryParse(_selectedSpace!.id);
      if (spaceIdForBooking == null || _selectedSpace!.id.isEmpty) {
        if (kDebugMode) {
          print('Invalid space ID: ${_selectedSpace!.id}');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric)),
        );
        return;
      }
      Navigator.pushNamed(
        context,
        '/booking',
        arguments: {
          'spaceId': spaceIdForBooking,
          'spaceName': _selectedSpace!.name,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.spaceNotAvailable),
        ),
      );
    }
  }

  void _reportSpace() {
    double? lat;
    double? lon;
    String? spaceName;
    String? street;
    String? district;

    if (_selectedSpace != null) {
      lat = _selectedSpace!.point.latitude;
      lon = _selectedSpace!.point.longitude;
      spaceName = _selectedSpace!.name;
      street = _selectedSpace!.street;
      district = _selectedSpace!.district;
    } else if (_selectedPosition != null) {
      lat = _selectedPosition!.latitude;
      lon = _selectedPosition!.longitude;
    }

    if (lat != null && lon != null) {
      Navigator.pushNamed(
        context,
        '/report-issue',
        arguments: {
          'latitude': lat,
          'longitude': lon,
          'spaceName': spaceName,
          'street': street,
          'district': district,
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pinpointedNotPublic),
        ),
      );
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    final hasPermission = await _locationService.checkAndRequestPermission();
    if (!hasPermission) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text(AppLocalizations.of(context)!.locationError),
                content: Text(AppLocalizations.of(context)!.directionsError),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.okButton),
                  ),
                ],
              ),
        );
      }
      return;
    }

    if (!mounted) return;
    setState(() => _isLoadingRoute = true);

    final userLocation = await _locationService.getUserLocation(
      useCache: false,
    );
    if (userLocation == null) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.directionsError),
          ),
        );
      }
      return;
    }

    final route = await RoutingService.getRoute(userLocation, destination);

    if (!mounted) return;

    setState(() {
      _routePoints = route?.points;
      _navigationSteps = route?.steps ?? [];
      _routeDistance = route?.distance ?? 0.0;
      _routeDuration = route?.duration ?? 0.0;
      _isLoadingRoute = false;
      _isNavigating = true;
      _navigationStarted = false;
    });

    if (route != null) {
      _startNavigation();
    }
  }

  void _startNavigation() {
    if (!mounted) return;
    setState(() => _navigationStarted = true);

    _navigationSubscription?.cancel();
    _navigationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((position) {
      if (!_isNavigating || _navigationSteps.isEmpty) return;

      final currentLocation = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentSpeed = position.speed;
          _travelMode = _currentSpeed > 1.5 ? 'driving' : 'walking';
        });
      }

      final instruction = RoutingService.getNavigationInstruction(
        currentLocation,
        _navigationSteps,
        _routePoints ?? [],
      );

      if (mounted) {
        setState(() {
          _navigationInstruction = instruction.instruction;
        });

        _mapController.move(currentLocation, _mapController.camera.zoom);
      }
    });
  }

  void _stopNavigation() {
    if (!mounted) return;
    setState(() {
      _isNavigating = false;
      _navigationStarted = false;
      _routePoints = null;
      _navigationSteps = [];
      _navigationInstruction = '';
      _routeDistance = 0.0;
      _routeDuration = 0.0;
    });
    _navigationSubscription?.cancel();
  }

  Widget _buildBottomSheetWithContent(String? areaName) {
    final isOpenSpace = _selectedSpace != null && _selectedSpace!.id.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final surfaceColor = isDark ? AppConstants.darkCard : AppConstants.white;
    final textColor = isDark ? AppConstants.darkText : AppConstants.navy;
    final secondaryTextColor =
        isDark ? AppConstants.darkTextSecondary : AppConstants.muted;
    final borderColor = isDark ? AppConstants.darkBorder : AppConstants.border;
    final selectedSpace = _selectedSpace;
    final isAvailable = selectedSpace?.isAvailable ?? false;
    final statusColor =
        isAvailable ? AppConstants.primaryGreen : AppConstants.danger;
    final statusText =
        selectedSpace?.status.trim().isNotEmpty == true
            ? _formatStatus(selectedSpace!.status)
            : localizations.statusUnknown;
    final title =
        isOpenSpace
            ? selectedSpace!.name
            : areaName ?? localizations.unknownArea;
    final showReportAction =
        isOpenSpace && widget.launchIntent != MapLaunchIntent.booking;
    final showBookingAction =
        isOpenSpace && widget.launchIntent != MapLaunchIntent.report;

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.84,
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.18),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            20 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 42,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? AppConstants.darkTextSecondary.withValues(
                                  alpha: 0.45,
                                )
                                : AppConstants.border,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Positioned(
                      right: -6,
                      top: 0,
                      child: IconButton(
                        tooltip: localizations.cancelButton,
                        onPressed: () => Navigator.pop(context),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              isDark
                                  ? AppConstants.darkCardAlt
                                  : AppConstants.pageBackground,
                          foregroundColor: secondaryTextColor,
                        ),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryGreenSoft,
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.park_rounded,
                      color: AppConstants.primaryGreen,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.openSpaceDetails.toUpperCase(),
                          style: TextStyle(
                            color: AppConstants.primaryGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (!isOpenSpace && areaName == null)
                          const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        else
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 22,
                              height: 1.16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                        if (isOpenSpace) ...[
                          const SizedBox(height: 9),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.11),
                                borderRadius: BorderRadius.circular(99),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Container(
                decoration: BoxDecoration(
                  color:
                      isDark
                          ? AppConstants.darkCardAlt
                          : AppConstants.pageBackground,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildSheetDetailRow(
                      icon: Icons.location_city_rounded,
                      label: localizations.districtLabel,
                      value: selectedSpace?.district ?? 'N/A',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                    Divider(height: 1, indent: 54, color: borderColor),
                    _buildSheetDetailRow(
                      icon: Icons.signpost_rounded,
                      label: localizations.streetLabel,
                      value: selectedSpace?.street ?? 'N/A',
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ],
                ),
              ),
              if (showReportAction) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppConstants.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppConstants.danger.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.campaign_rounded,
                          color: AppConstants.danger,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Text(
                          localizations.reportIssueSubtitle,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _reportSpace();
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppConstants.danger,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.report_problem_rounded, size: 21),
                  label: Text(
                    localizations.reportIssue,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 11),
              ],
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _selectedPosition != null
                              ? () {
                                Navigator.pop(context);
                                _getDirections(_selectedPosition!);
                              }
                              : null,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor:
                            isDark ? Colors.white : AppConstants.navy,
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.directions_rounded, size: 19),
                      label: Text(
                        localizations.getDirectionsButton,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (showBookingAction) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed:
                            isAvailable
                                ? () {
                                  Navigator.pop(context);
                                  _bookSpace();
                                }
                                : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          backgroundColor:
                              isDark
                                  ? AppConstants.primaryGreen.withValues(
                                    alpha: 0.22,
                                  )
                                  : AppConstants.primaryGreenSoft,
                          foregroundColor:
                              isDark
                                  ? AppConstants.accentMint
                                  : AppConstants.primaryGreenDark,
                          disabledBackgroundColor:
                              isDark
                                  ? AppConstants.darkCardAlt
                                  : AppConstants.pageBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        icon: const Icon(
                          Icons.event_available_rounded,
                          size: 19,
                        ),
                        label: Text(
                          localizations.bookNowButton,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    final normalized = status.trim();
    if (normalized.isEmpty) return normalized;
    return '${normalized[0].toUpperCase()}${normalized.substring(1).toLowerCase()}';
  }

  Widget _buildSheetDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppConstants.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppConstants.primaryGreen, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.trim().isEmpty ? 'N/A' : value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  OpenSpaceMarker? _findOpenSpaceAt(LatLng point) {
    for (final space in kinondoniSpaces.reversed) {
      if (space.boundary.length >= 3 &&
          _isPointInsideBoundary(point, space.boundary)) {
        return space;
      }

      if ((space.latitude - point.latitude).abs() < 0.00015 &&
          (space.longitude - point.longitude).abs() < 0.00015) {
        return space;
      }
    }
    return null;
  }

  bool _isPointInsideBoundary(LatLng point, List<LatLng> boundary) {
    var isInside = false;
    var previousIndex = boundary.length - 1;

    for (var index = 0; index < boundary.length; index++) {
      final current = boundary[index];
      final previous = boundary[previousIndex];
      final crossesLatitude =
          (current.latitude > point.latitude) !=
          (previous.latitude > point.latitude);

      if (crossesLatitude) {
        final longitudeAtLatitude =
            (previous.longitude - current.longitude) *
                (point.latitude - current.latitude) /
                (previous.latitude - current.latitude) +
            current.longitude;
        if (point.longitude < longitudeAtLatitude) isInside = !isInside;
      }
      previousIndex = index;
    }

    return isInside;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedLayer = tileLayers[selectedLayerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mapScreenAppBar),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all | InteractiveFlag.pinchZoom,
              ),
              initialCenter: _initialPosition,
              initialZoom: 13.0,
              maxZoom: 19.0,
              minZoom: 6.0,
              onTap: (tapPosition, point) async {
                if (!mounted) return;

                final clickedSpace = _findOpenSpaceAt(point);

                await _handleLocationSelection(
                  point,
                  openSpace: clickedSpace,
                );
              },
            ),
            children: [
              // Use offline-capable tile layer
              if (selectedLayerIndex == 0)
                OfflineMapService.getTileLayer()
              else
                TileLayer(
                  key: ValueKey(selectedLayerIndex),
                  urlTemplate: tileLayers[selectedLayerIndex].url,
                  userAgentPackageName: "com.kinondoni.openspace",
                  maxZoom: 19,
                ),

              PolygonLayer(
                polygons:
                    kinondoniSpaces
                        .where((space) => space.boundary.length >= 3)
                        .map(
                          (space) => Polygon(
                            points: space.boundary,
                            color: (space.isAvailable
                                    ? AppConstants.primaryGreen
                                    : AppConstants.danger)
                                .withValues(
                                  alpha: selectedLayerIndex == 1 ? 0.48 : 0.30,
                                ),
                            borderColor:
                                selectedLayerIndex == 1
                                    ? Colors.white
                                    : space.isAvailable
                                    ? AppConstants.primaryGreenDark
                                    : AppConstants.dangerDark,
                            borderStrokeWidth: selectedLayerIndex == 1 ? 3 : 2,
                          ),
                        )
                        .toList(),
              ),

              // Route polyline
              if (_routePoints != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 4.0,
                      color: AppConstants.info,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),

              CurrentLocationLayer(
                positionStream: _locationService.getLocationStream(),
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppConstants.info,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  showAccuracyCircle: true,
                  accuracyCircleColor: Color(0x332B7C9F),
                ),
              ),
              MarkerLayer(
                markers:
                    kinondoniSpaces
                        .map(
                          (space) => Marker(
                            point: space.point,
                            width: 42,
                            height: 48,
                            child: GestureDetector(
                              onTap:
                                  () => _handleLocationSelection(
                                    space.point,
                                    openSpace: space,
                                  ),
                              child: _OpenSpaceMapMarker(
                                isAvailable: space.isAvailable,
                                isSatellite: selectedLayerIndex == 1,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('© MapTiler'),
                  TextSourceAttribution('© OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_navigationStarted && _navigationInstruction.isNotEmpty)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _travelMode == 'driving'
                              ? Icons.directions_car
                              : Icons.directions_walk,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _navigationInstruction,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: _stopNavigation,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _travelMode == 'driving'
                              ? Icons.speed
                              : Icons.directions_walk,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _travelMode == 'driving'
                              ? 'Driving (${(_currentSpeed * 3.6).toStringAsFixed(0)} km/h)'
                              : 'Walking',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_isNavigating && _routePoints != null)
            Positioned(
              bottom: 100,
              left: 20,
              right: 20,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 400),
                offset: _isNavigating ? Offset.zero : const Offset(0, 2),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isNavigating ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoItem(
                              Icons.straighten,
                              '${_routeDistance.toStringAsFixed(1)} km',
                              'Distance',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildInfoItem(
                              Icons.access_time,
                              '${_routeDuration.toStringAsFixed(0)} min',
                              'ETA',
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildInfoItem(
                              Icons.turn_right,
                              '${_navigationSteps.length}',
                              'Turns',
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              _navigationStarted
                                  ? _stopNavigation
                                  : _startNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _navigationStarted
                                    ? AppConstants.danger
                                    : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppConstants.primaryGreenDark
                                        : AppConstants.primaryGreen),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _navigationStarted
                                    ? Icons.stop
                                    : Icons.play_arrow,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _navigationStarted
                                    ? 'Stop Navigation'
                                    : 'Start Navigation',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_isLoadingRoute)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 4),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Text(AppLocalizations.of(context)!.routeSearching),
                    ],
                  ),
                ),
              ),
            ),
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: AppConstants.danger.withValues(alpha: 0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          if (!_navigationStarted)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstants.navy.withValues(alpha: 0.16),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: TypeAheadField<LocationSuggestion>(
                  debounceDuration: const Duration(milliseconds: 500),
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.searchHint,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppConstants.primaryGreen,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? AppConstants.darkCardAlt : Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color:
                                isDark
                                    ? AppConstants.darkBorder
                                    : AppConstants.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: AppConstants.primaryGreen,
                            width: 1.5,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    if (pattern.length < 3) return [];
                    final backendSuggestions =
                        kinondoniSpaces
                            .where(
                              (space) => space.name.toLowerCase().contains(
                                pattern.toLowerCase(),
                              ),
                            )
                            .map(
                              (space) => LocationSuggestion(
                                name: space.name,
                                position: space.point,
                              ),
                            )
                            .toList();
                    final locationSuggestions = await _locationService
                        .searchLocation(pattern);
                    return [...backendSuggestions, ...locationSuggestions];
                  },
                  itemBuilder:
                      (context, suggestion) => ListTile(
                        leading: const Icon(Icons.location_on),
                        title: Text(suggestion.name),
                      ),
                  onSelected: (suggestion) {
                    setState(() => _initialPosition = suggestion.position);
                    _mapController.move(suggestion.position, 15.0);
                  },
                ),
              ),
            ),
          if (!_navigationStarted)
            Positioned(top: 78, left: 12, child: _buildMapGuide(isDark)),
          if (!_navigationStarted)
            Positioned(
              top: 78,
              right: 12,
              child: _buildMapStyleMenu(selectedLayer, isDark),
            ),
          Positioned(
            bottom: widget.showBottomNav ? 20 : 104,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkCardAlt : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppConstants.darkBorder : AppConstants.border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.navy.withValues(alpha: 0.16),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFloatingButton(
                    icon: Icons.add_rounded,
                    onPressed: () => zoomIn(_mapController),
                  ),
                  _mapControlDivider(isDark),
                  _buildFloatingButton(
                    icon: Icons.remove_rounded,
                    onPressed: () => zoomOut(_mapController),
                  ),
                  _mapControlDivider(isDark),
                  _buildFloatingButton(
                    icon: Icons.my_location_rounded,
                    onPressed: _toggleLocationTracking,
                    animated: true,
                  ),
                  _mapControlDivider(isDark),
                  _buildFloatingButton(
                    icon: Icons.refresh_rounded,
                    onPressed: _fetchOpenSpaces,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          widget.showBottomNav
              ? CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: _onNavTap,
              )
              : null,
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool animated = false,
  }) {
    final foreground =
        _isTracking && animated
            ? AppConstants.primaryGreen
            : Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppConstants.navy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child:
                animated
                    ? AnimatedBuilder(
                      animation: _opacityAnimation,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _isTracking ? _opacityAnimation.value : 1.0,
                          child: Icon(icon, size: 21, color: foreground),
                        );
                      },
                    )
                    : Icon(icon, size: 21, color: foreground),
          ),
        ),
      ),
    );
  }

  Widget _mapControlDivider(bool isDark) => Container(
    width: 24,
    height: 1,
    color: isDark ? AppConstants.darkBorder : AppConstants.border,
  );

  Widget _buildMapGuide(bool isDark) {
    return Container(
      height: 43,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardAlt : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppConstants.darkBorder : AppConstants.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppConstants.navy.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppConstants.primaryGreenSoft,
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.park_rounded,
              size: 17,
              color: AppConstants.primaryGreen,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${kinondoniSpaces.length} ${AppLocalizations.of(context)!.openSpaces}',
            style: TextStyle(
              color: isDark ? Colors.white : AppConstants.navy,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapStyleMenu(MapLayerOption selectedLayer, bool isDark) {
    return Material(
      color: isDark ? AppConstants.darkCardAlt : Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      child: PopupMenuButton<int>(
        initialValue: selectedLayerIndex,
        tooltip: 'Map view',
        onSelected: (index) => setState(() => selectedLayerIndex = index),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        itemBuilder:
            (context) =>
                tileLayers
                    .asMap()
                    .entries
                    .map(
                      (entry) => PopupMenuItem<int>(
                        value: entry.key,
                        child: Row(
                          children: [
                            Icon(
                              entry.value.icon,
                              size: 19,
                              color:
                                  entry.key == selectedLayerIndex
                                      ? AppConstants.primaryGreen
                                      : AppConstants.muted,
                            ),
                            const SizedBox(width: 10),
                            Text(entry.value.name),
                          ],
                        ),
                      ),
                    )
                    .toList(),
        child: Container(
          height: 43,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppConstants.darkBorder : AppConstants.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppConstants.navy.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selectedLayer.icon,
                size: 18,
                color: AppConstants.primaryGreen,
              ),
              const SizedBox(width: 7),
              Text(
                selectedLayer.name,
                style: TextStyle(
                  color: isDark ? Colors.white : AppConstants.navy,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.expand_more_rounded, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryGreen, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _OpenSpaceMapMarker extends StatelessWidget {
  const _OpenSpaceMapMarker({
    required this.isAvailable,
    required this.isSatellite,
  });

  final bool isAvailable;
  final bool isSatellite;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppConstants.primaryGreen : AppConstants.danger;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Icon(
          Icons.location_on_rounded,
          size: 46,
          color: color,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: isSatellite ? 0.46 : 0.26),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        Positioned(
          top: 7,
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(Icons.park_rounded, size: 14, color: color),
          ),
        ),
      ],
    );
  }
}

void zoomIn(MapController mapController) {
  final currentZoom = mapController.camera.zoom;
  if (currentZoom < 19.0) {
    mapController.move(mapController.camera.center, currentZoom + 1);
  }
}

void zoomOut(MapController mapController) {
  final currentZoom = mapController.camera.zoom;
  if (currentZoom > 6.0) {
    mapController.move(mapController.camera.center, currentZoom - 1);
  }
}
