import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/drone_data.dart'; // Import the new data models

class SimulationState extends Equatable {
  final List<DroneData> droneDataList;
  final List<LatLng> collectedWaypoints;
  final bool? anomalyDetected; // null, true, or false
  final OutsiderStatusData?
      outsiderStatus; // Already nullable, no change needed here.

  const SimulationState({
    this.droneDataList = const [],
    this.collectedWaypoints = const [],
    this.anomalyDetected,
    this.outsiderStatus, // Initialize the new field
  });

  SimulationState copyWith({
    List<DroneData>? droneDataList,
    List<LatLng>? collectedWaypoints,
    bool? anomalyDetected,
    OutsiderStatusData? outsiderStatus, // Add to copyWith
  }) {
    return SimulationState(
      droneDataList: droneDataList ?? this.droneDataList,
      collectedWaypoints: collectedWaypoints ?? this.collectedWaypoints,
      anomalyDetected: anomalyDetected ?? this.anomalyDetected,
      outsiderStatus:
          outsiderStatus ?? this.outsiderStatus, // Copy the new field
    );
  }

  @override
  List<Object?> get props => [
        droneDataList,
        collectedWaypoints,
        anomalyDetected,
        outsiderStatus, // Add to props
      ];
}
