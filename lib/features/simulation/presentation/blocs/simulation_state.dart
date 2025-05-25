

import 'package:latlong2/latlong.dart';

import '../../domain/entities/drone_data.dart';

class SimulationState {
  final List<DroneData> droneDataList;
  final List<LatLng> collectedWaypoints; // Store LatLng for map display

  SimulationState({
    this.droneDataList = const [],
    this.collectedWaypoints = const [],
  });

  SimulationState copyWith({
    List<DroneData>? droneDataList,
    List<LatLng>? collectedWaypoints,
  }) {
    return SimulationState(
      droneDataList: droneDataList ?? this.droneDataList,
      collectedWaypoints: collectedWaypoints ?? this.collectedWaypoints,
    );
  }
}