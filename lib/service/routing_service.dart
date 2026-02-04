import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RoutingService {
  static Future<RouteResult?> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true',
      );
      
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final coordinates = route['geometry']['coordinates'] as List;
          final distance = route['distance'] / 1000;
          final duration = route['duration'] / 60;
          
          final points = coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
          
          final steps = <NavigationStep>[];
          if (route['legs'] != null && route['legs'].isNotEmpty) {
            final leg = route['legs'][0];
            if (leg['steps'] != null) {
              for (var step in leg['steps']) {
                final maneuver = step['maneuver'];
                steps.add(NavigationStep(
                  instruction: step['name'] ?? 'Continue',
                  distance: (step['distance'] as num).toDouble(),
                  type: maneuver['type'] ?? 'turn',
                  modifier: maneuver['modifier'],
                  location: LatLng(
                    maneuver['location'][1],
                    maneuver['location'][0],
                  ),
                ));
              }
            }
          }
          
          return RouteResult(
            points: points,
            distance: distance,
            duration: duration,
            steps: steps,
          );
        }
      }
    } catch (e) {
      print('Routing error: $e');
    }
    
    return RouteResult(
      points: [start, end],
      distance: _calculateDistance(start, end),
      duration: 0,
      steps: [],
    );
  }
  
  static double _calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }
  
  static NavigationInstruction getNavigationInstruction(
    LatLng currentLocation,
    List<NavigationStep> steps,
    List<LatLng> routePoints,
  ) {
    if (steps.isEmpty) {
      return NavigationInstruction(
        instruction: 'Continue on route',
        distance: 0,
        type: 'continue',
      );
    }
    
    final Distance distance = Distance();
    NavigationStep? nextStep;
    double minDistance = double.infinity;
    
    for (var step in steps) {
      final dist = distance.as(
        LengthUnit.Meter,
        currentLocation,
        step.location,
      );
      if (dist < minDistance && dist > 10) {
        minDistance = dist;
        nextStep = step;
      }
    }
    
    if (nextStep != null) {
      return NavigationInstruction(
        instruction: _formatInstruction(nextStep),
        distance: minDistance,
        type: nextStep.type,
      );
    }
    
    return NavigationInstruction(
      instruction: 'Continue straight',
      distance: 0,
      type: 'continue',
    );
  }
  
  static String _formatInstruction(NavigationStep step) {
    final distanceText = step.distance < 1000
        ? '${step.distance.toInt()}m'
        : '${(step.distance / 1000).toStringAsFixed(1)}km';
    
    String action = '';
    if (step.type == 'turn') {
      if (step.modifier?.contains('left') == true) {
        action = 'Turn left';
      } else if (step.modifier?.contains('right') == true) {
        action = 'Turn right';
      } else {
        action = 'Turn';
      }
    } else if (step.type == 'depart') {
      action = 'Head';
    } else if (step.type == 'arrive') {
      action = 'Arrive at destination';
    } else if (step.type.contains('roundabout')) {
      action = 'Take roundabout';
    } else {
      action = 'Continue';
    }
    
    return '$action on ${step.instruction} in $distanceText';
  }
}

class RouteResult {
  final List<LatLng> points;
  final double distance;
  final double duration;
  final List<NavigationStep> steps;
  
  RouteResult({
    required this.points,
    required this.distance,
    required this.duration,
    required this.steps,
  });
}

class NavigationStep {
  final String instruction;
  final double distance;
  final String type;
  final String? modifier;
  final LatLng location;
  
  NavigationStep({
    required this.instruction,
    required this.distance,
    required this.type,
    this.modifier,
    required this.location,
  });
}

class NavigationInstruction {
  final String instruction;
  final double distance;
  final String type;
  
  NavigationInstruction({
    required this.instruction,
    required this.distance,
    required this.type,
  });
}
