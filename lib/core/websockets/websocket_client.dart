// File: core/websockets/websocket_client.dart

import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  final String _url = 'ws://localhost:9000/ws';
  WebSocketChannel? _channel; // Make it nullable
  // The crucial part: A single broadcast StreamController for the entire client's lifetime.
  final _controller = StreamController<dynamic>.broadcast();

  // The getter for the stream, always returns the stream from the broadcast controller.
  Stream<dynamic> get stream => _controller.stream;

  WebSocketClient() {
    // Connect automatically when the client is instantiated
    _initializeWebSocket();
  }

  // Private method to handle WebSocket channel initialization and listening
  void _initializeWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_url));

      // Listen to the raw WebSocket stream ONCE and pipe events to the broadcast controller.
      _channel!.stream.listen(
        (data) {
          if (!_controller.isClosed) {
            _controller.add(data);
          }
        },
        onError: (error) {
          if (!_controller.isClosed) {
            _controller.addError(error);
          }
          print('WebSocket channel error: $error');
          _reconnect(); // Attempt to reconnect on error
        },
        onDone: () {
          print('WebSocket channel done. Attempting to reconnect...');
          _reconnect(); // Attempt to reconnect when the channel is closed
        },
      );
      print('WebSocket initialized and listening to $_url');
    } catch (e) {
      print('Failed to initialize WebSocket: $e');
      // If initial connection fails, try to reconnect after a delay
      _reconnect();
    }
  }

  // Public connect method, primarily for re-connection if disconnected
  void connect() {
    if (_channel == null || _channel!.closeCode != null) {
      // Only re-initialize if not already connected or if channel is closed
      print('Attempting to connect WebSocket...');
      _initializeWebSocket();
    } else {
      print('WebSocket is already connected.');
    }
  }

  void _reconnect() {
    // Implement a simple reconnect logic with a delay to prevent rapid attempts
    print('Attempting to reconnect in 5 seconds...');
    Timer(const Duration(seconds: 5), () {
      if (_controller.isClosed) {
        print('Cannot reconnect: WebSocketClient has been disposed.');
        return;
      }
      _initializeWebSocket(); // Re-initialize the channel
    });
  }

  void send(Map<String, dynamic> data) {
    if (_channel != null && _channel!.closeCode == null) {
      _channel!.sink.add(jsonEncode(data));
      // print('Sent data: ${jsonEncode(data)}'); // Optional: for debugging
    } else {
      print('WebSocket not connected. Attempting to reconnect and send.');
      connect(); // Try to reconnect
      // Note: Data won't be sent immediately in this call.
      // You might need a more sophisticated retry mechanism for critical sends.
    }
  }

  void disconnect() {
    print('Disconnecting WebSocket...');
    _channel?.sink.close(); // Close the WebSocket channel's sink
    _channel = null; // Clear the channel reference
  }

  // Call this method when the WebSocketClient instance is no longer needed
  // (e.g., in the dispose method of a BLoC or provider that owns it).
  void dispose() {
    print('Disposing WebSocketClient...');
    disconnect(); // Disconnect the WebSocket channel
    if (!_controller.isClosed) {
      _controller.close(); // Close the broadcast controller permanently
    }
  }
}
