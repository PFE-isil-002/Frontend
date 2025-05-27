// lib/features/simulation/data/repository/simulation_repository.dart

import 'dart:async';
import 'dart:convert';
import '../../../../core/websockets/websocket_client.dart';

class SimulationRepository {
  final WebSocketClient client;

  SimulationRepository(this.client);

  Stream<Map<String, dynamic>> startSimulation({
    required String modelType,
    required String simulationType,
    required double duration,
    required double step,
    required double velocity,
    required Map<String, double> startPoint,
    required Map<String, double> endPoint,
    List<Map<String, double>>? waypoints,
  }) {
    final payload = {
      'type': 'start_simulation',
      'data': {
        'model_type': modelType,
        'simulation_type': simulationType,
        'duration': duration,
        'step': step,
        'velocity': velocity,
        'start_point': startPoint,
        'end_point': endPoint,
        if (waypoints != null) 'waypoints': waypoints,
      }
    };
    client.send(payload);

    // Create a new stream controller to manage the paced emission of events
    final controller = StreamController<Map<String, dynamic>>();

    // Listen to the raw WebSocket stream and apply delay before re-emitting
    client.stream
        .map((event) => event as String)
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .where((msg) =>
            msg['type'] == 'drone_data' ||
            msg['type'] == 'waypoint_collected' ||
            msg['type'] ==
                'batch_prediction_complete') // Listen for prediction complete
        .listen((data) async {
      // Apply delay only for 'drone_data' messages
      if (data['type'] == 'drone_data') {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Adjust this value
      }
      controller.add(data);
    }, onDone: () {
      controller.close();
    }, onError: (error) {
      controller.addError(error);
    });

    return controller.stream; // Return the controlled stream
  }

  void stopSimulation() {
    final payload = {'type': 'stop_simulation', 'data': {}};
    client.send(payload);
  }
}
