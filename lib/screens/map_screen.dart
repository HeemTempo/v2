import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:openspace_mobile_app/data/local/openspace_local.dart';
import 'package:openspace_mobile_app/data/repository/openspace_repository.dart';
import 'package:openspace_mobile_app/service/openspace_service.dart';
import 'package:provider/provider.dart';
import '../model/openspace.dart';

import '../utils/location_service.dart';
import '../utils/alert/access_denied_dialog.dart';
import '../providers/user_provider.dart';
import '../widget/custom_navigation_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
  int _currentIndex = 1;

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
    setState(() => _currentIndex = index);

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/map');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/user-profile');
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
          const SnackBar(content: Text('Error fetching open spaces')),
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
    _controller.dispose();
    _mapController.dispose();
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
            const SnackBar(content: Text("Unable to fetch location.")),
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
        ).showSnackBar(SnackBar(content: Text("Location error")));
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

  Future<void> _showLocationPopup(
    LatLng position, {
    OpenSpaceMarker? openSpace,
  }) async {
    if (!mounted) return;

    setState(() {
      _selectedSpace = openSpace ?? _emptyMarker(position);
      _selectedPosition = position;
    });

    try {
      final areaName =
          await _locationService.getAreaName(position) ?? "Unknown Area";

      if (mounted) {
        setState(() {
          _selectedAreaName = areaName;
        });

        await showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          backgroundColor: Colors.white,
          isScrollControlled: true,
          builder: (context) => _buildBottomSheetContent(),
        );

        if (mounted) _closePopup();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _selectedAreaName = "Unknown Area");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error fetching area name")));
      }
      if (kDebugMode) print('Error showing location popup: $e');
    }
  }

  void _closePopup() {
    if (mounted) {
      setState(() {
        _selectedPosition = null;
        _selectedSpace = null;
        _selectedAreaName = null;
      });
    }
  }

  void _bookSpace() {
    if (_selectedSpace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No space selected for booking.")),
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
          const SnackBar(content: Text("Error: Invalid space ID for booking.")),
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
        const SnackBar(
          content: Text("This space is currently not available for booking."),
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
        const SnackBar(
          content: Text("Pinpointed area is not a Public open space"),
        ),
      );
    }
  }

  Future<void> _getDirections(LatLng destination) async {
    final userLocation = await _locationService.getUserLocation(
      useCache: false,
    );
    if (userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unable to fetch your current location.")),
      );
      return;
    }

    final distance = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      destination.latitude,
      destination.longitude,
    );

    final distanceInKm = (distance / 1000).toStringAsFixed(2);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Directions to ${_selectedAreaName ?? 'selected location'}:\n"
          "Straight-line distance: $distanceInKm km.\n"
          "(Implement a directions API for detailed navigation.)",
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Widget _buildBottomSheetContent() {
    final isOpenSpace = _selectedSpace != null && _selectedSpace!.id.isNotEmpty;

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
              icon: const Icon(Icons.close, size: 20, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            isOpenSpace
                ? _selectedSpace!.name
                : _selectedAreaName ?? "Unknown Area",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Details for OpenSpace or normal point
          _buildDetailRow("District", _selectedSpace?.district ?? "Unknown"),
          _buildDetailRow("Street", _selectedSpace?.street ?? "Unknown"),
          if (isOpenSpace)
            _buildDetailRow(
              "Status",
              _selectedSpace!.status,
              valueColor:
                  _selectedSpace!.isAvailable ? Colors.green : Colors.red,
            ),

          const SizedBox(height: 16),
          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed:
                    _selectedPosition != null
                        ? () {
                          Navigator.pop(context);
                          _getDirections(_selectedPosition!);
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Get Directions",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              if (isOpenSpace) ...[
                ElevatedButton(
                  onPressed:
                      _selectedSpace!.isAvailable
                          ? () {
                            Navigator.pop(context);
                            _bookSpace();
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Book Now",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _reportSpace();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Report",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
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
        title: const Text("Open Spaces Map"),
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
              TileLayer(
                key: ValueKey(selectedLayerIndex),
                urlTemplate: tileLayers[selectedLayerIndex].url,
                userAgentPackageName: "com.example.openspace_mobile_app",
                tileProvider: CancellableNetworkTileProvider(),
                keepBuffer: 5,
                maxZoom: 19,
              ),

              CurrentLocationLayer(
                positionStream: _locationService.getLocationStream(),
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
          if (_errorMessage != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.withOpacity(0.8),
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
                    hintText: 'Search public open space',
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
                return [...backendSuggestions];
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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: valueColor ?? Colors.black87),
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

class LocationSuggestion {
  final String name;
  final LatLng position;

  LocationSuggestion({required this.name, required this.position});
}
