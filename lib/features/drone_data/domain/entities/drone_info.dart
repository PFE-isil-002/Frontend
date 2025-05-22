import 'systel_logs.dart';

class DroneInfo {
  final String id;
  final String name;
  final String firmwareVersion;
  final bool isConnected;
  final String flightMode;
  final double batteryLevel;
  final double batteryRemaining;
  final int gpsSatellites;
  final double signalStrength;
  final double latitude;
  final double longitude;
  final double altitude;
  final double groundSpeed;
  final double airspeed;
  final double roll;
  final double pitch;
  final double yaw;
  final int missionItems;
  final int currentWaypoint;
  final double distanceToNext;
  final double missionProgress;
  final List<double> altitudeHistory;
  final List<double> verticalSpeedHistory;
  final List<double> voltageHistory;
  final List<double> currentHistory;
  final List<double> rollHistory;
  final List<double> pitchHistory;
  final List<double> yawHistory;
  final String vehicleType;
  final int heartbeatCount;
  final String sensorsHealth;
  final int cpuLoad;
  final String lastStatusText;
  final bool accelCalibrated;
  final bool gyroCalibrated;
  final bool magCalibrated;
  final bool levelCalibrated;
  final bool rcCalibrated;
  final bool escCalibrated;
  final List<SystemLog> systemLogs;

  DroneInfo({
    required this.id,
    required this.name,
    required this.firmwareVersion,
    required this.isConnected,
    required this.flightMode,
    required this.batteryLevel,
    required this.batteryRemaining,
    required this.gpsSatellites,
    required this.signalStrength,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.groundSpeed,
    required this.airspeed,
    required this.roll,
    required this.pitch,
    required this.yaw,
    required this.missionItems,
    required this.currentWaypoint,
    required this.distanceToNext,
    required this.missionProgress,
    required this.altitudeHistory,
    required this.verticalSpeedHistory,
    required this.voltageHistory,
    required this.currentHistory,
    required this.rollHistory,
    required this.pitchHistory,
    required this.yawHistory,
    required this.vehicleType,
    required this.heartbeatCount,
    required this.sensorsHealth,
    required this.cpuLoad,
    required this.lastStatusText,
    required this.accelCalibrated,
    required this.gyroCalibrated,
    required this.magCalibrated,
    required this.levelCalibrated,
    required this.rcCalibrated,
    required this.escCalibrated,
    required this.systemLogs,
  });

  factory DroneInfo.empty() {
    return DroneInfo(
      id: '',
      name: 'Unknown',
      firmwareVersion: 'Unknown',
      isConnected: false,
      flightMode: 'UNKNOWN',
      batteryLevel: 0,
      batteryRemaining: 0,
      gpsSatellites: 0,
      signalStrength: 0,
      latitude: 0,
      longitude: 0,
      altitude: 0,
      groundSpeed: 0,
      airspeed: 0,
      roll: 0,
      pitch: 0,
      yaw: 0,
      missionItems: 0,
      currentWaypoint: 0,
      distanceToNext: 0,
      missionProgress: 0,
      altitudeHistory: [],
      verticalSpeedHistory: [],
      voltageHistory: [],
      currentHistory: [],
      rollHistory: [],
      pitchHistory: [],
      yawHistory: [],
      vehicleType: 'Unknown',
      heartbeatCount: 0,
      sensorsHealth: 'Unknown',
      cpuLoad: 0,
      lastStatusText: 'No status',
      accelCalibrated: false,
      gyroCalibrated: false,
      magCalibrated: false,
      levelCalibrated: false,
      rcCalibrated: false,
      escCalibrated: false,
      systemLogs: [],
    );
  }
}