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
  
    emit(const SimulationState());

    // Cancel old subscription
    _subscription?.cancel();

   
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
        print('Stack trace: $st');
        emit(state.copyWith(
            anomalyDetectionMessage: 'Simulation error: $error'));
        stopSimulation();
      },
      onDone: () {
        print('✅ Simulation stream closed.');
        stopSimulation(); 
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
      }
    } catch (e, st) {
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
        ' Waypoint ${waypointData.waypointsCollected} collected at (${waypointData.currentX}, ${waypointData.currentY}, ${waypointData.currentZ})');
  }

  void _handleBatchPredictionComplete(Map<String, dynamic> message) {
    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) {
      return;
    }

    final bool anomalyDetected = data['anomaly_detected'] as bool? ?? false;
    emit(state.copyWith(
      anomalyDetected: anomalyDetected,
      anomalyDetectionMessage:
          anomalyDetected ? 'Anomaly detected!' : 'No anomaly detected.',
    ));

    stopSimulation();

  void _handleOutsiderStatus(Map<String, dynamic> message) {
    print('👤 Processing outsider status message...');

    final data = message['data'] as Map<String, dynamic>?;
    if (data == null) {
      return;
    }

    try {
      final outsiderStatusData = OutsiderStatusData.fromMap(data);

     
      emit(state.copyWith(outsiderStatus: outsiderStatusData));

      
      if (outsiderStatusData.status == 'blocked') {
        emit(state.copyWith(
            outsiderSimulationMessage:
                'Outsider Drone Status: BLOCKED! Drone ID: ${outsiderStatusData.droneId}'));
      } else if (outsiderStatusData.status == 'authenticated') {
        emit(state.copyWith(
            outsiderSimulationMessage:
                'Outsider Drone Status: AUTHENTICATED! Drone ID: ${outsiderStatusData.droneId}'));
      }
    } catch (e, st) {
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
    emit(const SimulationState()); 
  }
  void clearAnomalyDetectionMessage() {
    emit(state.copyWith(anomalyDetectionMessage: null));
  }
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
