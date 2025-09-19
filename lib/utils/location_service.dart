import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'dart:collection';

class LocationService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'OpenSpaceApp/1.0 (Rahimramadhani2502@gmail.com)',
  };

  final _cache = LinkedHashMap<String, String?>(
    equals: (a, b) => a == b,
    hashCode: (key) => key.hashCode,
  );
  static const int _cacheSize = 50;

  LatLng? _lastKnownLocation;
  DateTime? _lastLocationTime;
  static const Duration _locationCacheTimeout = Duration(minutes: 1);

  Future<bool> _checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    return true;
  }

  Future<LatLng?> getUserLocation({bool useCache = true}) async {
    if (useCache &&
        _lastKnownLocation != null &&
        _lastLocationTime != null &&
        DateTime.now().difference(_lastLocationTime!) < _locationCacheTimeout) {
      return _lastKnownLocation;
    }

    try {
      if (!await _checkAndRequestPermission()) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _lastKnownLocation = LatLng(position.latitude, position.longitude);
      _lastLocationTime = DateTime.now();
      return _lastKnownLocation;
    } catch (e) {
      print('Error fetching user location: $e');
      return null;
    }
  }

  Stream<LocationMarkerPosition> getLocationStream() async* {
    if (await _checkAndRequestPermission()) {
      await for (final position in Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      )) {
        final markerPosition = LocationMarkerPosition(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        );
        _lastKnownLocation = LatLng(position.latitude, position.longitude);
        _lastLocationTime = DateTime.now();
        yield markerPosition;
      }
    }
  }

  Future<List<LocationSuggestion>> searchLocation(String query) async {
    if (query.trim().length < 3) {
      return [];
    }

    final url = Uri.parse(
      '$_nominatimBaseUrl/search?format=json&q=${Uri.encodeQueryComponent(query)}&limit=5',
    );

    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) {
              final lat = double.tryParse(item['lat']?.toString() ?? '');
              final lon = double.tryParse(item['lon']?.toString() ?? '');
              final displayName = item['display_name']?.toString();
              if (lat != null && lon != null && displayName != null) {
                return LocationSuggestion(
                  name: displayName,
                  position: LatLng(lat, lon),
                );
              }
              return null;
            })
            .whereType<LocationSuggestion>()
            .toList();
      } else {
        print('Search failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error searching location: $e');
      return [];
    }
  }

  Future<String?> getAreaName(LatLng position) async {
    final cacheKey =
        '${position.latitude.toStringAsFixed(5)}_${position.longitude.toStringAsFixed(5)}';

    if (_cache.containsKey(cacheKey)) {
      final value = _cache.remove(cacheKey);
      _cache[cacheKey] = value;
      return value;
    }

    final url = Uri.parse(
      '$_nominatimBaseUrl/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&addressdetails=1&zoom=18',
    );

    try {
      final response = await http.get(url, headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String? displayName = data['display_name']?.toString();
        if (displayName != null) {
          if (_cache.length >= _cacheSize) {
            _cache.remove(_cache.keys.first);
          }
          _cache[cacheKey] = displayName;
          return displayName;
        }
      } else {
        print(
          'Reverse geocoding failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }
    return null;
  }
}

class LocationSuggestion {
  final String name;
  final LatLng position;

  LocationSuggestion({required this.name, required this.position});
}
