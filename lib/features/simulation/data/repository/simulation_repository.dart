import 'dart:async';
import 'dart:convert';
import '../../../../core/websockets/websocket_client.dart';

class SimulationRepository {
  final WebSocketClient client;
  // Keep track of the internal subscription to the client's stream
  StreamSubscription<Map<String, dynamic>>? _internalClientSubscription;

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
    // --- IMPORTANT FIX: Cancel any previous internal subscription ---
    _internalClientSubscription?.cancel();
    _internalClientSubscription = null; // Clear the reference

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

    // Create a new broadcast controller for the BLoC to listen to
    final controller = StreamController<Map<String, dynamic>>.broadcast();

    // --- IMPORTANT FIX: Re-assign the internal subscription for the new simulation ---
    _internalClientSubscription = client.stream
        .asBroadcastStream() // Ensure the client's stream is broadcast
        .map((event) => event as String)
        .map((raw) {
      try {
        return jsonDecode(raw) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding JSON: $e');
        rethrow;
      }
    }).listen((msg) async {
      print('Message type: ${msg['type']}');
      final messageType = msg['type'];
      // Only add relevant messages to the controller
      if (messageType == 'drone_data' ||
          messageType == 'waypoint_collected' ||
          messageType == 'batch_prediction_complete' ||
          messageType == 'outsider_status') {
        controller.add(msg);
      }
    }, onDone: () {
      print('WebSocket stream closed by client');
      // Close the controller when the underlying WebSocket stream closes
      controller.close();
    }, onError: (error) {
      print('WebSocket stream error in repository: $error');
      controller.addError(error);
      // Also close the controller on error
      controller.close();
    });

    return controller.stream;
  }

  void stopSimulation() {
    print('Sending stop simulation command...');
    client.send({'command': 'stop_simulation'});
    // Also cancel the internal listener when the simulation is explicitly stopped
    _internalClientSubscription?.cancel();
    _internalClientSubscription = null;
  }

  void dispose() {
    // Cancel the internal subscription when the repository itself is disposed
    _internalClientSubscription?.cancel();
    _internalClientSubscription = null;
    client.disconnect();
  }
}
