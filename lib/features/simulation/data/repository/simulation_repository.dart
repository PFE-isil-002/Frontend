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
        .map((raw) {
          print('Raw WebSocket message: $raw'); // Debug: Log raw message
          try {
            return jsonDecode(raw) as Map<String, dynamic>;
          } catch (e) {
            print('Error decoding JSON: $e');
            rethrow;
          }
        })
        .listen((msg) async {
          print('Decoded message: $msg'); // Debug: Log decoded message
          print('Message type: ${msg['type']}'); // Debug: Log message type
          
          // Check if message type is one we want to handle
          final messageType = msg['type'];
          if (messageType == 'drone_data' ||
              messageType == 'waypoint_collected' ||
              messageType == 'batch_prediction_complete' ||
              messageType == 'outsider_status') {
            print('Processing message of type: $messageType'); // Debug: Confirm processing
            controller.add(msg);
          } else {
            print('Ignoring message of type: $messageType'); // Debug: Log ignored messages
          }
        }, onDone: () {
          print('WebSocket stream closed');
          controller.close();
        }, onError: (error) {
          print('WebSocket stream error: $error');
          controller.addError(error);
        });

    return controller.stream;
  }

  void stopSimulation() {
    client.send({'type': 'stop_simulation'});
  }
}