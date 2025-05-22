import 'dart:math';

class PositionConverter {
  final double referenceLat;
  final double referenceLon;

  PositionConverter({required this.referenceLat, required this.referenceLon});

  Map<String, double> convertToLatLon(double x, double y) {
    const double metersPerDegreeLat = 111320.0;
    double latOffset = y / metersPerDegreeLat;
    double lonOffset = x / (metersPerDegreeLat * cos(referenceLat * pi / 180));

    double newLat = referenceLat + latOffset;
    double newLon = referenceLon + lonOffset;

    return {
      'latitude': newLat,
      'longitude': newLon,
    };
  }
}
