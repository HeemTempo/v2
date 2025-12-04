import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteInfo {
  final List<LatLng> coordinates;
  final double distanceInMeters;
  final double durationInSeconds;

  RouteInfo({
    required this.coordinates,
    required this.distanceInMeters,
    required this.durationInSeconds,
  });

  double get distanceInKm => distanceInMeters / 1000;
  int get durationInMinutes => (durationInSeconds / 60).round();

  String get formattedDistance {
    if (distanceInKm < 1) {
      return '${distanceInMeters.round()} m';
    }
    return '${distanceInKm.toStringAsFixed(1)} km';
  }

  String get formattedDuration {
    if (durationInMinutes < 60) {
      return '$durationInMinutes min';
    }
    final hours = durationInMinutes ~/ 60;
    final mins = durationInMinutes % 60;
    return '${hours}h ${mins}min';
  }
}

class RoutingService {
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1';
  
  /// Get route between two points
  /// [profile] can be 'driving', 'walking', or 'cycling'
  Future<RouteInfo?> getRoute({
    required LatLng start,
    required LatLng end,
    String profile = 'driving',
  }) async {
    try {
      final url = Uri.parse(
        '$_osrmBaseUrl/$profile/${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        print('OSRM API error: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' || data['routes'] == null || (data['routes'] as List).isEmpty) {
        print('OSRM: No route found');
        return null;
      }

      final route = data['routes'][0];
      final geometry = route['geometry'];
      final coordinates = (geometry['coordinates'] as List)
          .map((coord) => LatLng(coord[1] as double, coord[0] as double))
          .toList();

      return RouteInfo(
        coordinates: coordinates,
        distanceInMeters: (route['distance'] as num).toDouble(),
        durationInSeconds: (route['duration'] as num).toDouble(),
      );
    } catch (e) {
      print('Error fetching route: $e');
      return null;
    }
  }

  /// Get multiple routes with different profiles
  Future<Map<String, RouteInfo?>> getMultipleRoutes({
    required LatLng start,
    required LatLng end,
  }) async {
    final results = await Future.wait([
      getRoute(start: start, end: end, profile: 'driving'),
      getRoute(start: start, end: end, profile: 'walking'),
    ]);

    return {
      'driving': results[0],
      'walking': results[1],
    };
  }
}
