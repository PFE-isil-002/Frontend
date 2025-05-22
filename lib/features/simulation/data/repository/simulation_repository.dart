import 'dart:async';
import 'dart:convert';
import '../../../../core/websockets/websocket_client.dart';

class SimulationRepository {
  final WebSocketClient client;

  SimulationRepository(this.client);
  Stream<Map<String, dynamic>> startSimulation(
    String modelType,
    String simulationType,
    double duration,
    double step,
  ) {
    // Send the start message over WebSocket
    final payload = {
      'type': 'start_simulation',
      'data': {
        'model_type': modelType,
        'simulation_type': simulationType,
        'duration': duration,
        'step': step,
      }
    };
    client.send(payload);

    final broadcast = client.stream.asBroadcastStream();

    return broadcast
        .map((event) => event as String)
        .map((raw) => jsonDecode(raw) as Map<String, dynamic>)
        .where((msg) => msg['type'] == 'drone_data')
        .map((msg) => msg['data'] as Map<String, dynamic>);
  }

  /// Sends the simulation stop command.
  void stopSimulation() {
    final payload = {'type': 'stop_simulation', 'data': {}};
    client.send(payload);
  }
}
