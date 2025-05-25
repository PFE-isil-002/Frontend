// simulation_repository.dart
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
    List<Map<String, double>>? waypoints, // Optional waypoints
  }) {
    // Send the start message over WebSocket
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
        if (waypoints != null)
          'waypoints': waypoints, // Add waypoints if provided
      }
    };
    client.send(payload);

    // Create a new stream controller to manage the paced emission of events
    final _controller = StreamController<Map<String, dynamic>>();

    // Subscribe to the raw WebSocket stream
    client.stream
        .map((event) => event as String)
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .where((msg) =>
            msg['type'] == 'drone_data' || msg['type'] == 'waypoint_collected')
        .listen((data) async {
      // Introduce the delay before adding the data to the controller's stream
      // This ensures that the data is *emitted* from this stream slowly.
      if (data['type'] == 'drone_data') {
        await Future.delayed(const Duration(
            milliseconds:
                200)); // Adjust this value (e.g., 200ms for a noticeable delay)
      }
      _controller.add(data);
    }, onDone: () {
      _controller.close();
    }, onError: (error) {
      _controller.addError(error);
    });

    return _controller.stream; // Return the controlled stream
  }

  /// Sends the simulation stop command.
  void stopSimulation() {
    final payload = {'type': 'stop_simulation', 'data': {}};
    client.send(payload);
  }
}
