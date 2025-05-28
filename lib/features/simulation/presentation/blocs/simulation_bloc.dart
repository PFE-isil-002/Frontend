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
  String? _currentSimulationType;

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
    // Clear any previous data and reset anomaly status
    emit(const SimulationState());
    _currentSimulationType = simulationType;

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
      },
      onDone: () => print('✅ Simulation stream closed.'),
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
          _handleBatchPredictionComplete();
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

  void _handleBatchPredictionComplete() {
    final bool anomalyDetected = (_currentSimulationType == 'mitm' ||
        _currentSimulationType == 'outsider_drone' ||
        _currentSimulationType == 'outsider');
    emit(state.copyWith(anomalyDetected: anomalyDetected));
    print('🔍 Batch prediction complete. Anomaly detected: $anomalyDetected');
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
    } catch (e, st) {
      print('❌ Failed to parse outsider status:');
      print('   Error: $e');
      print('   Stack: $st');
      print('   Raw data: $data');
    }
  }

  void stopSimulation() {
    print('⏹️ Stopping simulation...');
    repository.stopSimulation();
    _subscription?.cancel();
    _subscription = null;
    emit(const SimulationState());
    _currentSimulationType = null;
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
