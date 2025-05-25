class DroneData {
  final double x;
  final double y;
  final double z;
  final double battery;
  final double signalStrength;
  final double packetLoss;
  final double latency;
  final DateTime timestamp;


  DroneData({
    required this.x,
    required this.y,
    required this.z,
    required this.battery,
    required this.signalStrength,
    required this.packetLoss,
    required this.latency,
    required this.timestamp,
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
      timestamp: DateTime.parse(map['timestamp'] as String),

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
      'timestamp': timestamp.toIso8601String(),

    };
  }
}

class WaypointCollectedData {
  final int waypointsCollected;
  final double currentX;
  final double currentY;
  final double currentZ;
  final DateTime timestamp;

  WaypointCollectedData({
    required this.waypointsCollected,
    required this.currentX,
    required this.currentY,
    required this.currentZ,
    required this.timestamp,
  });

  factory WaypointCollectedData.fromMap(Map<String, dynamic> map) {
    final currentPosition = map['current_position'] as Map<String, dynamic>;
    return WaypointCollectedData(
      waypointsCollected: map['waypoints_collected'] as int,
      currentX: (currentPosition['x'] as num).toDouble(),
      currentY: (currentPosition['y'] as num).toDouble(),
      currentZ: (currentPosition['z'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}