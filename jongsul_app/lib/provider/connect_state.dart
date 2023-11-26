import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../func/websocket_manager.dart';

class ConeectState extends ChangeNotifier {
  WebSocketManager _webSocketManager = WebSocketManager();
  var connected = false;

  String addr_cam = 'ws://localhost:8765';
  String addr_key = 'ws://localhost:9997';

  void toggleConnection() {
    _webSocketManager.toggleConnection(addr_cam, addr_key);
    connected = _webSocketManager.connected;
    notifyListeners();
  }

  WebSocketManager get webSocketManager => _webSocketManager;

  WebSocketChannel get cam_channel => _webSocketManager.cam_channel;
  WebSocketChannel get key_channel => _webSocketManager.key_channel;
}
