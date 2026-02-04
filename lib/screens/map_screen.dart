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
import '../utils/alert/access_denied_dialog.dart';
import '../providers/user_provider.dart';
import '../widget/custom_navigation_bar.dart';
import '../l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  final bool showBottomNav;
  const MapScreen({super.key, this.showBottomNav = true});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapLayerOption {
  final String name;
  final String url;
  MapLayerOption({required this.name, required this.url});
}

class MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final MapController _mapController;
  final LocationService _locationService = LocationService();
  late final OpenSpaceRepository _openSpaceRepository;
  bool isSatelliteView = false;
  bool _isTracking = false;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  LatLng _initialPosition = const LatLng(-6.7741, 39.2026); // Kinondoni
  List<OpenSpaceMarker> kinondoniSpaces = [];
  OpenSpaceMarker? _selectedSpace;
  LatLng? _selectedPosition;
  String? _selectedAreaName;
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

  // --- Add these inside MapScreenState ---
  final List<MapLayerOption> tileLayers = [
    MapLayerOption(
      name: "Street",
      url: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
    ),
    MapLayerOption(
      name: "Satellite",
      url:
          "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
    ),
    MapLayerOption(
      name: "Terrain",
      url: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
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

    if (isAnonymous) {
      // Anonymous users: 0 (Home), 1 (Map/Explore)
      if (index == 0) {
        Navigator.pop(context, 0);
      }
      // Index 1 is current screen
    } else {
      // Registered users: 0 (Home), 1 (Map), 2 (Profile)
      switch (index) {
        case 0:
          Navigator.pop(context, 0);
          break;
        case 1:
          // Already on Map
          break;
        case 2:
          Navigator.pushNamed(context, '/user-profile');
          break;
      }
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
            SnackBar(content: Text(AppLocalizations.of(context)!.unableFetchLocation)),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user location');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.locationError)));
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
  final ValueNotifier<String?> _selectedAreaNameNotifier = ValueNotifier<String?>(null);

  Future<void> _showLocationPopup(
    LatLng position, {
    OpenSpaceMarker? openSpace,
  }) async {
    if (!mounted) return;

    // 1. Prepare initial state
    setState(() {
      _selectedSpace = openSpace ?? _emptyMarker(position);
      _selectedPosition = position;
      _selectedAreaName = null; // Still keep for compatibility or other checks
    });
    _selectedAreaNameNotifier.value = null; // Reset notifier for the new tap

    // 2. Show the bottom sheet IMMEDIATELY
    // We don't await this because we want to start geocoding concurrently
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
      isScrollControlled: true,
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
      final areaName = await _locationService.getAreaName(position) ?? "Unknown Area";
      
      // 4. Update the sheet reactively
      if (mounted) {
        _selectedAreaNameNotifier.value = areaName;
        setState(() {
          _selectedAreaName = areaName;
        });
      }
    } catch (e) {
      if (mounted) {
        _selectedAreaNameNotifier.value = "Unknown Area";
        setState(() => _selectedAreaName = "Unknown Area");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.errorGeneric)));
      }
      if (kDebugMode) print('Error background geocoding: $e');
    }
  }

  void _closePopup() {
    if (mounted) {
      setState(() {
        _selectedPosition = null;
        _selectedSpace = null;
        _selectedAreaName = null;
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
        arguments: {'latitude': lat, 'longitude': lon, 'spaceName': spaceName, 'street': street, 'district': district},
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
          builder: (context) => AlertDialog(
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

    final userLocation = await _locationService.getUserLocation(useCache: false);
    if (userLocation == null) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.directionsError)),
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
    final bgColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.grey[400] : Colors.black54;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Grabber handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close, size: 20, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Title
          if (isOpenSpace)
            Text(
              _selectedSpace!.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            )
          else if (areaName != null)
            Text(
              areaName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            )
          else
            const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          const SizedBox(height: 12),

          // Details for OpenSpace or normal point
          _buildDetailRow(AppLocalizations.of(context)!.districtLabel, _selectedSpace?.district ?? "N/A"),
          _buildDetailRow(AppLocalizations.of(context)!.streetLabel, _selectedSpace?.street ?? "N/A"),
          if (isOpenSpace)
            _buildDetailRow(
              AppLocalizations.of(context)!.status,
              _selectedSpace!.status,
              valueColor:
                  _selectedSpace!.isAvailable ? Colors.green : Colors.red,
            ),

          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed:
                    _selectedPosition != null
                        ? () {
                          Navigator.pop(context);
                          _getDirections(_selectedPosition!);
                        }
                        : null,
                icon: const Icon(Icons.directions, size: 18),
                label: Text(
                  AppLocalizations.of(context)!.getDirectionsButton,
                  style: const TextStyle(fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (isOpenSpace) ...[
                ElevatedButton.icon(
                  onPressed:
                      _selectedSpace!.isAvailable
                          ? () {
                            Navigator.pop(context);
                            _bookSpace();
                          }
                          : null,
                  icon: const Icon(Icons.event_available, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.bookNowButton,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _reportSpace();
                  },
                  icon: const Icon(Icons.report_problem, size: 18),
                  label: Text(
                    AppLocalizations.of(context)!.reportButton,
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancelButton,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.mapScreenAppBar),
        centerTitle: true,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.layers),
            onSelected: (index) {
              setState(() => selectedLayerIndex = index);
            },
            itemBuilder:
                (context) =>
                    tileLayers
                        .asMap()
                        .entries
                        .map(
                          (entry) => PopupMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value.name),
                          ),
                        )
                        .toList(),
          ),
        ],
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

                final clickedSpace = kinondoniSpaces.firstWhere(
                  (space) =>
                      (space.point.latitude - point.latitude).abs() < 0.0001 &&
                      (space.point.longitude - point.longitude).abs() < 0.0001,
                  orElse:
                      () => OpenSpaceMarker(
                        id: '',
                        name: '',
                        district: '',
                        street: '',
                        latitude: point.latitude,
                        longitude: point.longitude,
                        isActive: false,
                        status: '',
                      ),
                );

                await _showLocationPopup(
                  point,
                  openSpace: clickedSpace.name.isNotEmpty ? clickedSpace : null,
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

              // Route polyline
              if (_routePoints != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints!,
                      strokeWidth: 4.0,
                      color: Colors.blue,
                      borderStrokeWidth: 2.0,
                      borderColor: Colors.white,
                    ),
                  ],
                ),

              CurrentLocationLayer(
                positionStream: _locationService.getLocationStream(),
                style: LocationMarkerStyle(
                  marker: DefaultLocationMarker(
                    color: AppConstants.primaryBlue,
                    child: Icon(
                      Icons.navigation,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  markerSize: Size(35, 35),
                  showAccuracyCircle: true,
                  accuracyCircleColor: Color(0x332196F3),
                ),
              ),
              MarkerLayer(
                markers:
                    kinondoniSpaces
                        .map(
                          (space) => Marker(
                            point: space.point,
                            width: 30,
                            height: 30,
                            child: GestureDetector(
                              onTap:
                                  () => _showLocationPopup(
                                    space.point,
                                    openSpace: space,
                                  ),
                              child: Icon(
                                Icons.place,
                                color:
                                    space.isAvailable
                                        ? Colors.green
                                        : Colors.red,
                              ),
                            ),
                          ),
                        )
                        .toList(),
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
                  color: AppConstants.primaryBlue,
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
                          _travelMode == 'driving' ? Icons.directions_car : Icons.directions_walk,
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
                          _travelMode == 'driving' ? Icons.speed : Icons.directions_walk,
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
                          onPressed: _navigationStarted ? _stopNavigation : _startNavigation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _navigationStarted 
                                ? Colors.red 
                                : (Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.green.shade700 
                                    : Colors.green),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_navigationStarted ? Icons.stop : Icons.play_arrow),
                              const SizedBox(width: 8),
                              Text(_navigationStarted ? 'Stop Navigation' : 'Start Navigation'),
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
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
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
                color: Colors.red.withValues(alpha: 0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 20,
            right: 10,
            child: TypeAheadField<LocationSuggestion>(
              debounceDuration: const Duration(milliseconds: 500),
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchHint,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
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
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFloatingButton(
                  icon: Icons.add,
                  onPressed: () => zoomIn(_mapController),
                  heroTag: "zoomIn",
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.remove,
                  onPressed: () => zoomOut(_mapController),
                  heroTag: "zoomOut",
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.my_location,
                  onPressed: _toggleLocationTracking,
                  heroTag: "locateMe",
                  animated: true,
                ),
                const SizedBox(height: 10),
                _buildFloatingButton(
                  icon: Icons.refresh,
                  onPressed: _fetchOpenSpaces,
                  heroTag: "refresh",
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomNav
          ? CustomBottomNavBar(
              currentIndex: _currentIndex,
              onTap: _onNavTap,
              isAnonymous: Provider.of<UserProvider>(context, listen: false).user.isAnonymous,
            )
          : null,
    );
  }

  Widget _buildFloatingButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
    bool animated = false,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      heroTag: heroTag,
      mini: true,
      backgroundColor: Colors.white,
      elevation: 2,
      shape: const CircleBorder(),
      child:
          animated
              ? AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _isTracking ? _opacityAnimation.value : 1.0,
                    child: Icon(icon, size: 20, color: Colors.black87),
                  );
                },
              )
              : Icon(icon, size: 20, color: Colors.black87),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: valueColor ?? (isDark ? Colors.white : Colors.black87)),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: AppConstants.primaryBlue, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
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
