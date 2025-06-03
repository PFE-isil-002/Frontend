import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/entities/drone_data.dart'; // Import the new data models

class SimulationState extends Equatable {
  final List<DroneData> droneDataList;
  final List<LatLng> collectedWaypoints;
  final bool? anomalyDetected; // null, true, or false
  final OutsiderStatusData? outsiderStatus;
  final String? anomalyDetectionMessage; // New: Message for anomaly pop-up
  final String? outsiderSimulationMessage; // New: Message for outsider status pop-up
  final LatLng? startPoint; // Add startPoint to state
  final LatLng? endPoint; // Add endPoint to state

  const SimulationState({
    this.droneDataList = const [],
    this.collectedWaypoints = const [],
    this.anomalyDetected,
    this.outsiderStatus,
    this.anomalyDetectionMessage, // Initialize new field
    this.outsiderSimulationMessage, // Initialize new field
    this.startPoint, // Initialize new field
    this.endPoint, // Initialize new field
  });

  SimulationState copyWith({
    List<DroneData>? droneDataList,
    List<LatLng>? collectedWaypoints,
    bool? anomalyDetected,
    OutsiderStatusData? outsiderStatus,
    String? anomalyDetectionMessage, // Add to copyWith
    String? outsiderSimulationMessage, // Add to copyWith
    LatLng? startPoint, // Add to copyWith
    LatLng? endPoint, // Add to copyWith
  }) {
    return SimulationState(
      droneDataList: droneDataList ?? this.droneDataList,
      collectedWaypoints: collectedWaypoints ?? this.collectedWaypoints,
      anomalyDetected: anomalyDetected ?? this.anomalyDetected,
      outsiderStatus: outsiderStatus ?? this.outsiderStatus,
      anomalyDetectionMessage: anomalyDetectionMessage, // Allow null to clear message
      outsiderSimulationMessage: outsiderSimulationMessage, // Allow null to clear message
      startPoint: startPoint, // Allow null to clear
      endPoint: endPoint, // Allow null to clear
    );
  }

  @override
  List<Object?> get props => [
        droneDataList,
        collectedWaypoints,
        anomalyDetected,
        outsiderStatus,
        anomalyDetectionMessage, 
        outsiderSimulationMessage, 
        startPoint,
        endPoint,
      ];
}