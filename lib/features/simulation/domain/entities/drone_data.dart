class DroneData {
  final double x;
  final double y;
  final double z;
  final double battery;
  final double signalStrength;
  final double packetLoss;
  final double latency;

  DroneData({
    required this.x,
    required this.y,
    required this.z,
    required this.battery,
    required this.signalStrength,
    required this.packetLoss,
    required this.latency,
  });

  /// Creates a [DroneData] instance from a JSON-like map.
  factory DroneData.fromMap(Map<String, dynamic> map) {
    // Extract nested position safely and convert to double
    final pos = map['position'] as Map<String, dynamic>;
    return DroneData(
      x: (pos['x'] as num).toDouble(),
      y: (pos['y'] as num).toDouble(),
      z: (pos['z'] as num).toDouble(),
      battery: (map['battery'] as num).toDouble(),
      signalStrength: (map['signal_strength'] as num).toDouble(),
      packetLoss: (map['packet_loss'] as num).toDouble(),
      latency: (map['latency'] as num).toDouble(),
    );
  }

  /// Converts this instance back to a map
  Map<String, dynamic> toMap() {
    return {
      'position': {'x': x, 'y': y, 'z': z},
      'battery': battery,
      'signal_strength': signalStrength,
      'packet_loss': packetLoss,
      'latency': latency,
    };
  }
}
