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
    try {
      final currentPosition = map['current_position'] as Map<String, dynamic>;
      return WaypointCollectedData(
        waypointsCollected: map['waypoints_collected'] as int,
        currentX: (currentPosition['x'] as num).toDouble(),
        currentY: (currentPosition['y'] as num).toDouble(),
        currentZ: (currentPosition['z'] as num).toDouble(),
        // Use the main timestamp, not the nested one in current_position
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
    } catch (e) {
      print('Error in WaypointCollectedData.fromMap: $e');
      print('Input map: $map');
      rethrow;
    }
  }
}

class OutsiderPosition {
  final double x;
  final double y;
  final double z;
  final DateTime timestamp;

  OutsiderPosition({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
  });

  factory OutsiderPosition.fromMap(Map<String, dynamic> map) {
    return OutsiderPosition(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      z: (map['z'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class OutsiderTelemetry {
  final String droneId;
  final OutsiderPosition position;
  final Map<String, double> velocity;
  final Map<String, double> acceleration;
  final Map<String, double> orientation;
  final Map<String, double> angularVelocity;
  final double battery;
  final double signalStrength;
  final double packetLoss;
  final double latency;
  final List<OutsiderPosition> flightHistory;
  final DateTime authenticationTimestamp;

  OutsiderTelemetry({
    required this.droneId,
    required this.position,
    required this.velocity,
    required this.acceleration,
    required this.orientation,
    required this.angularVelocity,
    required this.battery,
    required this.signalStrength,
    required this.packetLoss,
    required this.latency,
    required this.flightHistory,
    required this.authenticationTimestamp,
  });

  factory OutsiderTelemetry.fromMap(Map<String, dynamic> map) {
    try {
      return OutsiderTelemetry(
        droneId: map['drone_id'] as String,
        position:
            OutsiderPosition.fromMap(map['position'] as Map<String, dynamic>),
        velocity: Map<String, double>.from(map['velocity'] as Map),
        acceleration: Map<String, double>.from(map['acceleration'] as Map),
        orientation: Map<String, double>.from(map['orientation'] as Map),
        angularVelocity:
            Map<String, double>.from(map['angular_velocity'] as Map),
        battery: (map['battery'] as num).toDouble(),
        signalStrength: (map['signal_strength'] as num).toDouble(),
        packetLoss: (map['packet_loss'] as num).toDouble(),
        latency: (map['latency'] as num).toDouble(),
        flightHistory: (map['flight_history'] as List)
            .map((e) => OutsiderPosition.fromMap(e as Map<String, dynamic>))
            .toList(),
        authenticationTimestamp:
            DateTime.parse(map['authentication_timestamp'] as String),
      );
    } catch (e) {
      print('Error in OutsiderTelemetry.fromMap: $e');
      print('Input map: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'drone_id': droneId,
      'position': position.toMap(),
      'velocity': velocity,
      'acceleration': acceleration,
      'orientation': orientation,
      'angular_velocity': angularVelocity,
      'battery': battery,
      'signal_strength': signalStrength,
      'packet_loss': packetLoss,
      'latency': latency,
      'flight_history': flightHistory.map((e) => e.toMap()).toList(),
      'authentication_timestamp': authenticationTimestamp.toIso8601String(),
    };
  }
}

class OutsiderStatusData {
  final String status;
  final String droneId;
  final OutsiderTelemetry outsiderTelemetry;
  final DateTime? timestamp; // Made nullable

  OutsiderStatusData({
    required this.status,
    required this.droneId,
    required this.outsiderTelemetry,
    this.timestamp, // No longer required
  });

  factory OutsiderStatusData.fromMap(Map<String, dynamic> map) {
    try {
      final status = map['status'] as String?;
      final droneId = map['drone_id'] as String?;
      final outsiderTelemetryMap =
          map['outsider_telemetry'] as Map<String, dynamic>?;

      // Handle timestamp safely
      DateTime? parsedTimestamp;
      final timestampValue = map['timestamp'];
      if (timestampValue is String) {
        try {
          parsedTimestamp = DateTime.parse(timestampValue);
        } catch (e) {
          print(
              'Warning: Could not parse timestamp string "$timestampValue": $e');
          // parsedTimestamp remains null
        }
      } else if (timestampValue != null) {
        print(
            'Warning: timestamp is not a String in OutsiderStatusData: $timestampValue');
        // parsedTimestamp remains null
      }
      // If timestampValue is null, parsedTimestamp will remain null, which is handled now.

      if (status == null) {
        throw ArgumentError('status cannot be null');
      }
      if (droneId == null) {
        throw ArgumentError('drone_id cannot be null');
      }
      if (outsiderTelemetryMap == null) {
        throw ArgumentError('outsider_telemetry cannot be null');
      }

      return OutsiderStatusData(
        status: status,
        droneId: droneId,
        outsiderTelemetry: OutsiderTelemetry.fromMap(outsiderTelemetryMap),
        timestamp: parsedTimestamp, // Assign the nullable parsedTimestamp
      );
    } catch (e) {
      print('Error in OutsiderStatusData.fromMap: $e');
      print('Input map: $map');
      rethrow;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'drone_id': droneId,
      'outsider_telemetry': outsiderTelemetry.toMap(),
      'timestamp':
          timestamp?.toIso8601String(), // Handle nullable timestamp for toMap
    };
  }
}
