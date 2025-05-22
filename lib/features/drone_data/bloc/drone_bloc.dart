import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/drone_info.dart';
import '../domain/entities/systel_logs.dart';
import 'drone_event.dart';
import 'drone_state.dart';

class DroneInfoBloc extends Bloc<DroneInfoEvent, DroneInfoState> {
  DroneInfoBloc() : super(DroneInfoLoading()) {
    on<LoadDronesInfo>(_onLoadDronesInfo);
    on<RefreshDroneInfo>(_onRefreshDroneInfo);
  }

  Future<void> _onLoadDronesInfo(
    LoadDronesInfo event,
    Emitter<DroneInfoState> emit,
  ) async {
    emit(DroneInfoLoading());
    try {
      final drones = await fetchAllDrones();
      emit(DroneInfoLoaded(drones));
    } catch (e) {
      emit(DroneInfoError(e.toString()));
    }
  }

  Future<void> _onRefreshDroneInfo(
    RefreshDroneInfo event,
    Emitter<DroneInfoState> emit,
  ) async {
    if (state is DroneInfoLoaded) {
      final currentState = state as DroneInfoLoaded;
      try {
        final updatedDrone = await fetchDroneById(event.droneId);
        final updatedList = currentState.drones.map((drone) {
          return drone.id == event.droneId ? updatedDrone : drone;
        }).toList();
        emit(DroneInfoLoaded(updatedList));
      } catch (e) {
        emit(DroneInfoError('Failed to refresh drone: ${e.toString()}'));
      }
    }
  }

  
  Future<List<DroneInfo>> fetchAllDrones() async {
    await Future.delayed(Duration(seconds: 1));
    return [
      DroneInfo(
        id: 'iris_sim_001',
        name: 'PX4 Iris SITL',
        firmwareVersion: '1.14.0',
        isConnected: true,
        flightMode: 'POSCTL',
        batteryLevel: 92,
        batteryRemaining: 0.92,
        gpsSatellites: 12,
        signalStrength: 100,
        latitude: 36.7525, 
        longitude: 3.0420,
        altitude: 15.0,
        groundSpeed: 5.2,
        airspeed: 5.2,
        roll: 0.0,
        pitch: 0.0,
        yaw: 90.0,
        missionItems: 5,
        currentWaypoint: 2,
        distanceToNext: 35.0,
        missionProgress: 40.0,
        altitudeHistory: [14.8, 14.9, 15.0],
        verticalSpeedHistory: [0.0, 0.1, 0.0],
        voltageHistory: [11.1, 11.0, 10.9],
        currentHistory: [1.2, 1.3, 1.1],
        rollHistory: [0.0, 0.1, -0.1],
        pitchHistory: [0.0, -0.1, 0.1],
        yawHistory: [90.0, 91.0, 89.0],
        vehicleType: 'Quadrotor',
        heartbeatCount: 150,
        sensorsHealth: "All systems operational",
        cpuLoad: 35,
        lastStatusText: 'Ready for mission',
        accelCalibrated: true,
        gyroCalibrated: true,
        magCalibrated: true,
        levelCalibrated: true,
        rcCalibrated: true,
        escCalibrated: true,
        systemLogs: [
          SystemLog(
              timestamp: DateTime(2025),
              level: "1",
              message: "Message Started"),
          SystemLog(
              timestamp: DateTime(2025), level: "2", message: "Message 1"),
          SystemLog(
              timestamp: DateTime(2025), level: "3", message: "Message 2"),
          SystemLog(
              timestamp: DateTime(2025), level: "4", message: "Message 3"),
          SystemLog(
              timestamp: DateTime(2025), level: "5", message: "Message 4"),
          SystemLog(
              timestamp: DateTime(2025), level: "6", message: "Message 5"),
          SystemLog(
              timestamp: DateTime(2025), level: "7", message: "Message 6"),
          SystemLog(
              timestamp: DateTime(2025), level: "8", message: "Message 7"),
        ],
      )
    ];
  }

  Future<DroneInfo> fetchDroneById(String id) async {
    await Future.delayed(Duration(milliseconds: 800));
    return DroneInfo(
  id: 'iris_sim_001',
  name: 'PX4 Iris SITL',
  firmwareVersion: '1.14.0',
  isConnected: true,
  flightMode: 'POSCTL',
  batteryLevel: 92,
  batteryRemaining: 0.92,
  gpsSatellites: 12,
  signalStrength: 100,
  latitude: 36.7525, 
  longitude: 3.0420,
  altitude: 15.0,
  groundSpeed: 5.2,
  airspeed: 5.2,
  roll: 0.0,
  pitch: 0.0,
  yaw: 90.0,
  missionItems: 5,
  currentWaypoint: 2,
  distanceToNext: 35.0,
  missionProgress: 40.0,
  altitudeHistory: [14.8, 14.9, 15.0],
  verticalSpeedHistory: [0.0, 0.1, 0.0],
  voltageHistory: [11.1, 11.0, 10.9],
  currentHistory: [1.2, 1.3, 1.1],
  rollHistory: [0.0, 0.1, -0.1],
  pitchHistory: [0.0, -0.1, 0.1],
  yawHistory: [90.0, 91.0, 89.0],
  vehicleType: 'Quadrotor',
  heartbeatCount: 150,
  sensorsHealth: "All systems operational",
  cpuLoad: 35,
  lastStatusText: 'Ready for mission',
  accelCalibrated: true,
  gyroCalibrated: true,
  magCalibrated: true,
  levelCalibrated: true,
  rcCalibrated: true,
  escCalibrated: true,
  systemLogs: [
    SystemLog(timestamp: DateTime(2025), level: "1", message: "Message Started"),
    SystemLog(timestamp: DateTime(2025), level: "2", message: "Message 1"),
    SystemLog(timestamp: DateTime(2025), level: "3", message: "Message 2"),
    SystemLog(timestamp: DateTime(2025), level: "4", message: "Message 3"),
    SystemLog(timestamp: DateTime(2025), level: "5", message: "Message 4"),
    SystemLog(timestamp: DateTime(2025), level: "6", message: "Message 5"),
    SystemLog(timestamp: DateTime(2025), level: "7", message: "Message 6"),
    SystemLog(timestamp: DateTime(2025), level: "8", message: "Message 7"),
  ],
);
  }

  loadDronesInfo() {}
}


