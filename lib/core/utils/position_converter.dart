import 'dart:math';

class PositionConverter {
  final double referenceLat;
  final double referenceLon;

  PositionConverter({required this.referenceLat, required this.referenceLon});

  static const double metersPerDegreeLat = 111320.0;

  /// Convert (lat, lon) to (x, y) relative to the reference point
  Map<String, double> convertToXY(double lat, double lon) {
    double latOffset = lat - referenceLat;
    double lonOffset = lon - referenceLon;

    double y = latOffset * metersPerDegreeLat;
    double x = lonOffset * metersPerDegreeLat * cos(referenceLat * pi / 180);

    return {
      'x': x,
      'y': y,
    };
  }

  /// Convert (x, y) to (lat, lon) relative to the reference point
  Map<String, double> convertToLatLon(double x, double y) {
    double latOffset = y / metersPerDegreeLat;
    double lonOffset = x / (metersPerDegreeLat * cos(referenceLat * pi / 180));

    double lat = referenceLat + latOffset;
    double lon = referenceLon + lonOffset;

    return {
      'latitude': lat,
      'longitude': lon,
    };
  }
}
