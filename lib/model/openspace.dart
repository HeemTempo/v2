import 'dart:convert';

import 'package:latlong2/latlong.dart';

class OpenSpaceMarker {
  final String id;
  final String name;
  final String district;
  final String street; // NEW
  final double latitude;
  final double longitude;
  final bool isActive;
  final String status;
  final String shapeType;
  final List<LatLng> boundary;
  final double area;
  final List<String> amenities; // Optional
  final List<String> images; // Optional

  OpenSpaceMarker({
    required this.id,
    required this.name,
    required this.district,
    required this.street, // NEW
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.status,
    this.shapeType = 'polygon',
    this.boundary = const [],
    this.area = 0,
    this.amenities = const [],
    this.images = const [],
  });

  factory OpenSpaceMarker.fromJson(Map<String, dynamic> json) {
    final district = json['district'] as String? ?? '';
    final street = json['street'] as String? ?? '';

    // Debug log to verify data from backend
    // print('OpenSpaceMarker.fromJson: id=${json['id']}, district=$district, street=$street');

    return OpenSpaceMarker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      district: district.isEmpty ? 'N/A' : district,
      street: street.isEmpty ? 'N/A' : street,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      shapeType: json['shapeType'] as String? ?? 'polygon',
      boundary: _parseBoundary(json['boundary']),
      area: (json['area'] as num?)?.toDouble() ?? 0,
      amenities:
          (json['amenities'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  LatLng get point => LatLng(latitude, longitude);
  bool get isAvailable => status.toLowerCase() == 'available';

  Map<String, dynamic> get boundaryGeoJson => {
    'type': 'Polygon',
    'coordinates': [
      boundary.map((point) => [point.longitude, point.latitude]).toList(),
    ],
  };

  static List<LatLng> _parseBoundary(dynamic rawBoundary) {
    dynamic boundaryData = rawBoundary;

    for (var attempt = 0; attempt < 2 && boundaryData is String; attempt++) {
      try {
        boundaryData = jsonDecode(boundaryData);
      } catch (_) {
        return const [];
      }
    }

    if (boundaryData is! Map) return const [];
    final coordinates = boundaryData['coordinates'];
    if (coordinates is! List || coordinates.isEmpty) return const [];

    final outerRing = coordinates.first;
    if (outerRing is! List) return const [];

    return outerRing
        .whereType<List>()
        .where((coordinate) => coordinate.length >= 2)
        .map(
          (coordinate) => LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          ),
        )
        .toList(growable: false);
  }
}
