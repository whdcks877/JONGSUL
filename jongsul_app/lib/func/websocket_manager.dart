import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  late WebSocketChannel _cam_channel;
  late WebSocketChannel _key_channel;
  bool connected = false;

  WebSocketManager();

  void toggleConnection(String addr_cam, String addr_key) {
    if (connected) {
      _cam_channel.sink.close();
      _key_channel.sink.close();
    } else {
      try {
        _cam_channel = WebSocketChannel.connect(
          Uri.parse(addr_cam),
        );

        _key_channel = WebSocketChannel.connect(
          Uri.parse(addr_key),
        );
      } catch (e) {
        return;
      }
    }
    if (connected) {
      connected = false;
    } else {
      connected = true;
    }
  }

  WebSocketChannel get cam_channel => _cam_channel;
  WebSocketChannel get key_channel => _key_channel;

  void dispose() {
    _cam_channel.sink.close();
    _key_channel.sink.close();
  }
}
