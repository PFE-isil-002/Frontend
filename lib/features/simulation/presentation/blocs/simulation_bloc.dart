import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart'; // Import LatLng
import '../../../../core/utils/position_converter.dart';
import '../../data/repository/simulation_repository.dart';
import '../../domain/entities/drone_data.dart';
import 'simulation_state.dart'; // Import the new state class

class SimulationBloc extends Cubit<SimulationState> {
  final SimulationRepository repository;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  SimulationBloc(this.repository)
      : super(SimulationState()); // Initialize with new state

  void startSimulation({
    required String modelType,
    required String simulationType,
    required double duration,
    required double step,
    required double velocity,
    required Map<String, double> startPoint,
    required Map<String, double> endPoint,
    List<Map<String, double>>? waypoints,
  }) {
    // 1) clear any previous data
    emit(SimulationState()); // Emit an empty initial state

    // 2) cancel old subscription (just in case)
    _subscription?.cancel();

    // 3) new subscription on the broadcast stream
    _subscription = repository
        .startSimulation(
      modelType: modelType,
      simulationType: simulationType,
      duration: duration,
      step: step,
      velocity: velocity,
      startPoint: startPoint,
      endPoint: endPoint,
      waypoints: waypoints,
    )
        .listen(
      (message) async {
        // Make the listener async
        try {
          final messageType = message['type'];
          final messageData = message['data'] as Map<String, dynamic>;

          if (messageType == 'drone_data') {
            final droneData = DroneData.fromMap(messageData);
            final updatedDroneDataList =
                List<DroneData>.from(state.droneDataList)..add(droneData);
            emit(state.copyWith(
                droneDataList: updatedDroneDataList)); // Update droneDataList
          } else if (messageType == 'waypoint_collected') {
            final waypointData = WaypointCollectedData.fromMap(messageData);
            final newWaypoint = LatLng(
                _positionConverter.convertToLatLon(
                    waypointData.currentX, waypointData.currentY)['latitude']!,
                _positionConverter.convertToLatLon(waypointData.currentX,
                    waypointData.currentY)['longitude']!);
            final updatedWaypoints = List<LatLng>.from(state.collectedWaypoints)
              ..add(newWaypoint);
            emit(state.copyWith(
                collectedWaypoints:
                    updatedWaypoints)); // Update collectedWaypoints
            print(
                'Waypoint Collected: ${waypointData.waypointsCollected} at (${waypointData.currentX}, ${waypointData.currentY}, ${waypointData.currentZ})');
          }
        } catch (e, st) {
          print('Error processing WebSocket message: $e\n$st');
        }
      },
      onError: (error, st) => print('Simulation stream error: $error\n$st'),
      onDone: () => print('Simulation stream closed.'),
    );
  }

  void stopSimulation() {
    // 1) tell server
    repository.stopSimulation();
    // 2) cancel receipt
    _subscription?.cancel();
    _subscription = null;
    // 3) clear data
    emit(SimulationState()); // Emit an empty state
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  // Add a PositionConverter instance to the BLoC
  final PositionConverter _positionConverter = PositionConverter(
    referenceLat: 36.7131,
    referenceLon: 3.1793,
  );
}
