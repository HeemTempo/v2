class MapStyleConfig {
  const MapStyleConfig._();

  // Public browser/mobile map key already used by the web application.
  static const String apiKey = '9rtSKNwbDOYAoeEEeW9B';

  static const String streets =
      'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=$apiKey';
  static const String satellite =
      'https://api.maptiler.com/maps/hybrid/{z}/{x}/{y}.jpg?key=$apiKey';
  static const String topographic =
      'https://api.maptiler.com/maps/topo/{z}/{x}/{y}.png?key=$apiKey';
  static const String basic =
      'https://api.maptiler.com/maps/basic/{z}/{x}/{y}.png?key=$apiKey';
}
