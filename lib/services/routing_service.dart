import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  // Free OSRM routing API
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getRoute(LatLng start, LatLng end) async {
    final url = '$_baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';
    
    try {
      final response = await http.get(Uri.parse(url)).timeout(
        const Duration(seconds: 10),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['routes'] == null || (data['routes'] as List).isEmpty) {
          throw Exception('Hakuna njia iliyopatikana');
        }
        
        final route = data['routes'][0];
        final coordinates = route['geometry']['coordinates'] as List;
        
        final points = coordinates.map((coord) {
          return LatLng(coord[1] as double, coord[0] as double);
        }).toList();
        
        final distance = route['distance'] as num; // meters
        final duration = route['duration'] as num; // seconds
        
        return RouteResult(
          points: points,
          distanceInMeters: distance.toDouble(),
          durationInSeconds: duration.toDouble(),
        );
      } else {
        throw Exception('Imeshindwa kupata njia');
      }
    } catch (e) {
      throw Exception('Tatizo la intaneti: $e');
    }
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distanceInMeters;
  final double durationInSeconds;

  RouteResult({
    required this.points,
    required this.distanceInMeters,
    required this.durationInSeconds,
  });

  String get distanceText {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  String get durationText {
    final minutes = (durationInSeconds / 60).round();
    if (minutes < 60) {
      return '$minutes dakika';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours saa $remainingMinutes dak';
  }
}
