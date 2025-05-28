import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketClient {
  final String _url = 'ws://localhost:9000/ws';
  late final WebSocketChannel channel;

  WebSocketClient() {
    channel = WebSocketChannel.connect(Uri.parse(_url));
  }

  void connect() {
    channel = WebSocketChannel.connect(Uri.parse(_url));
  }

  void send(Map<String, dynamic> data) {
    channel.sink.add(jsonEncode(data));
  }

  Stream<dynamic> get stream => channel.stream;

  void disconnect() {
    channel.sink.close();
  }
}
