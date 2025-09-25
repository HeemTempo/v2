
import 'package:latlong2/latlong.dart';

class OpenSpaceMarker {
  final String id;
  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String status;
  final List<String> amenities; // Optional
  final List<String> images;    // Optional

  OpenSpaceMarker({
    required this.id,
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.status,
    this.amenities = const [],
    this.images = const [],
  });

  factory OpenSpaceMarker.fromJson(Map<String, dynamic> json) {
    return OpenSpaceMarker(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      district: json['district'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['isActive'] as bool? ?? false,
      status: json['status'] as String? ?? '',
      amenities: (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  LatLng get point => LatLng(latitude, longitude);
  bool get isAvailable => status.toLowerCase() == 'available';
}