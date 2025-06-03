import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/position_converter.dart';
import '../../data/repository/simulation_repository.dart';
import '../../domain/entities/drone_data.dart';
import 'simulation_state.dart';

class SimulationBloc extends Cubit<SimulationState> {
  final SimulationRepository repository;
  StreamSubscription<Map<String, dynamic>>? _subscription;

  SimulationBloc(this.repository) : super(const SimulationState());

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
    // Clear any previous data and reset anomaly status and messages
    emit(const SimulationState());

    // Cancel old subscription
    _subscription?.cancel();

    // New subscription on the broadcast stream
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
      (message) {
        _handleMessage(message);
      },
      onError: (error, st) {
        print('❌ Simulation stream error: $error');
        print('Stack trace: $st');
        emit(state.copyWith(
            anomalyDetectionMessage: 'Simulation error: $error'));
        stopSimulation(); // Stop listening on error
      },
      onDone: () {
        print('✅ Simulation stream closed.');
        stopSimulation(); // Stop listening when done
      },
    );
  }

  void _handleMessage(Map<String, dynamic> message) {
    final messageType = message['type'];
    print('📨 Processing message: $messageType');

    try {
      switch (messageType) {
        case 'drone_data':
          _handleDroneData(message);
          break;
        case 'waypoint_collected':
          _handleWaypointCollected(message);
          break;
        case 'batch_prediction_complete':
          _handleBatchPredictionComplete(message); // Pass the message
          break;
        case 'outsider_status':
          _handleOutsiderStatus(message);
          break;
        default:
          print('❓ Unknown message type: $messageType');
      }
    } catch (e, st) {
      print('❌ Error processing message type $messageType: $e');
      print('Stack trace: $st');
      print('Raw message: $message');
      emit(
          state.copyWith(anomalyDetectionMessage: 'Error processing data: $e'));
    }
  }

  void _handleDroneData(Map<String, dynamic> message) {
    final droneData =
        DroneData.fromMap(message['data'] as Map<String, dynamic>);
    final updatedList = List<DroneData>.from(state.droneDataList)
      ..add(droneData);
    emit(state.copyWith(droneDataList: updatedList));
    print('🚁 Updated drone data list, count: ${updatedList.length}');
  }

  void _handleWaypointCollected(Map<String, dynamic> message) {
    final waypointData =
        WaypointCollectedData.fromMap(message['data'] as Map<String, dynamic>);
    final updatedWaypoints = List<LatLng>.from(state.collectedWaypoints);
    final latLon = _positionConverter.convertToLatLon(
        waypointData.currentX, waypointData.currentY);
    updatedWaypoints.add(LatLng(latLon['latitude']!, latLon['longitude']!));
    emit(state.copyWith(collectedWaypoints: updatedWaypoints));
    print(
        '📍 Waypoint ${waypointData.waypointsCollected} collected at (${waypointData.currentX}, ${waypointData.currentY}, ${waypointData.currentZ})');
  }

  void _handleBatchPredictionComplete(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) {
      print('❌ batch_prediction_complete data is null');
      return;
    }

    // Assuming the 'batch_prediction_complete' message contains an 'anomaly_detected' field
    final bool anomalyDetected = data['anomaly_detected'] as bool? ?? false;
    emit(state.copyWith(
      anomalyDetected: anomalyDetected,
      anomalyDetectionMessage:
          anomalyDetected ? 'Anomaly detected!' : 'No anomaly detected.',
    ));
    print('🔍 Batch prediction complete. Anomaly detected: $anomalyDetected');
    stopSimulation(); // Stop listening after batch prediction is complete
  }

  void _handleOutsiderStatus(Map<String, dynamic> message) {
    print('👤 Processing outsider status message...');

    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) {
      print('❌ Outsider status data is null');
      return;
    }

    try {
      final outsiderStatusData = OutsiderStatusData.fromMap(data);

      // Update state with new outsider status
      emit(state.copyWith(outsiderStatus: outsiderStatusData));

      print('✅ Outsider status updated:');
      print('   - Status: ${outsiderStatusData.status}');
      print('   - Drone ID: ${outsiderStatusData.droneId}');
      print(
          '   - Position: (${outsiderStatusData.outsiderTelemetry.position.x}, ${outsiderStatusData.outsiderTelemetry.position.y}, ${outsiderStatusData.outsiderTelemetry.position.z})');
      print('   - Battery: ${outsiderStatusData.outsiderTelemetry.battery}%');
      print(
          '   - Flight history points: ${outsiderStatusData.outsiderTelemetry.flightHistory.length}');

      // Check for final outsider status and trigger pop-up
      if (outsiderStatusData.status == 'blocked') {
        print(
            '🚨 Outsider drone BLOCKED! Emitting pop-up message.'); // Debug print
        emit(state.copyWith(
            outsiderSimulationMessage:
                'Outsider Drone Status: BLOCKED! Drone ID: ${outsiderStatusData.droneId}'));
        stopSimulation(); // Stop listening after outsider drone is blocked
      } else if (outsiderStatusData.status == 'authenticated') {
        print(
            '✅ Outsider drone AUTHENTICATED! Emitting pop-up message.'); // Debug print
        emit(state.copyWith(
            outsiderSimulationMessage:
                'Outsider Drone Status: AUTHENTICATED! Drone ID: ${outsiderStatusData.droneId}'));
        stopSimulation(); // Stop listening after outsider drone is authenticated
      }
    } catch (e, st) {
      print('❌ Failed to parse outsider status:');
      print('   Error: $e');
      print('   Stack: $st');
      print('   Raw data: $data');
      emit(state.copyWith(
          outsiderSimulationMessage: 'Error parsing outsider status: $e'));
    }
  }

  void stopSimulation() {
    print('⏹️ Stopping simulation...');
    repository.stopSimulation();
    _subscription?.cancel();
    _subscription = null;
    emit(const SimulationState()); // Reset state completely
  }

  // Method to acknowledge and clear anomaly detection message
  void clearAnomalyDetectionMessage() {
    emit(state.copyWith(anomalyDetectionMessage: null));
  }

  // Method to acknowledge and clear outsider simulation message
  void clearOutsiderSimulationMessage() {
    emit(state.copyWith(outsiderSimulationMessage: null));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  final PositionConverter _positionConverter = PositionConverter(
    referenceLat: 36.7131,
    referenceLon: 3.1793,
  );
}