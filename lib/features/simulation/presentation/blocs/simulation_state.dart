// lib/features/simulation/presentation/blocs/simulation_state.dart

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/drone_data.dart';

class SimulationState extends Equatable {
  final List<DroneData> droneDataList;
  final List<LatLng> collectedWaypoints;
  final bool? anomalyDetected; // null: not complete, true: anomaly, false: no anomaly

  const SimulationState({
    this.droneDataList = const [],
    this.collectedWaypoints = const [],
    this.anomalyDetected,
  });

  SimulationState copyWith({
    List<DroneData>? droneDataList,
    List<LatLng>? collectedWaypoints,
    bool? anomalyDetected,
  }) {
    return SimulationState(
      droneDataList: droneDataList ?? this.droneDataList,
      collectedWaypoints: collectedWaypoints ?? this.collectedWaypoints,
      anomalyDetected: anomalyDetected, // Always take the new value or null it
    );
  }

  @override
  List<Object?> get props => [droneDataList, collectedWaypoints, anomalyDetected];
}