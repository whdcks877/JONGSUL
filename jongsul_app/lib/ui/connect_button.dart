import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../func/websocket_manager.dart';
import '../provider/connect_state.dart';

class ConnectButton extends StatefulWidget {
  const ConnectButton({super.key});

  @override
  State<ConnectButton> createState() => _ConnectButtonState();
}

class _ConnectButtonState extends State<ConnectButton> {
  late WebSocketManager _webSocketManager;
  var connected;
  @override
  void initState() {
    // TODO: implement initState
    connected = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ConeectState>();
    _webSocketManager = appState.webSocketManager;

    return ElevatedButton(
      onPressed: () {
        appState.toggleConnection();
        setState(() {
          connected = _webSocketManager.connected;
        });
      },
      child:
          _webSocketManager.connected ? Icon(Icons.wifi) : Icon(Icons.wifi_off),
    );
  }
}
