import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/connect_state.dart';
import 'webcam.dart';

class VideoDisplay extends StatefulWidget {
  const VideoDisplay({Key? key}) : super(key: key);

  @override
  State<VideoDisplay> createState() => _VideoDisplayState();
}

class _VideoDisplayState extends State<VideoDisplay> {
  var connected = false;

  @override
  void initState() {
    super.initState();
    connected = false;
  }

  @override
  Widget build(BuildContext context) {
    Widget page;

    return Consumer<ConeectState>(builder: (context, provider, child) {
      connected = provider.connected;
      print("Provider-----------");
      print(connected);

      if (connected) {
        page = WebCam(channel: provider.webSocketManager.cam_channel);
      } else {
        page = Container(
          color: Colors.black,
        );
      }
      return Scaffold(
        body: Column(
          children: [
            SizedBox(height: 480, width: 640, child: page),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
