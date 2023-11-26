import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../func/box_painter.dart' as boxpainting;

import '../provider/app_state.dart';

class WebCam extends StatefulWidget {
  final WebSocketChannel channel;
  const WebCam({required this.channel, Key? key}) : super(key: key);

  @override
  _WebCamState createState() => _WebCamState();
}

class _WebCamState extends State<WebCam> {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: SizedBox(
        height: 480,
        width: 640,
        child: StreamBuilder(
          stream: widget.channel.stream,
          builder: (context, snapshot) {
            Image? image_data;
            var myResults;

            if (snapshot.hasData) {
              var myJson = jsonDecode(snapshot.data.toString());

              //Read Image
              String base64EncodedImageData = myJson['image_data'];
              Uint8List decodedData = base64.decode(base64EncodedImageData);

              if (decodedData.isNotEmpty) {
                image_data = Image.memory(
                  decodedData,
                  gaplessPlayback: true,
                  fit: BoxFit.fill,
                );
              }

              //Read Dection Read
              myResults = jsonDecode(myJson['results_json']);
              var level = 0;

              for (var box in myResults) {
                String cls = box["class"];
                if (cls == 'knife' || cls == 'scissors') {
                  appState.setAlert(1);
                  level = 1;
                }
              }

              appState.setAlert(level);
            }

            return Stack(
              children: [
                // Draw the image first
                Positioned.fill(
                  child: Container(child: image_data ?? Placeholder()),
                ),
                // Draw the boxes on top of the image
                Positioned.fill(
                  child: Container(
                    child: CustomPaint(
                      painter: boxpainting.BoxPainter(myResults),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.channel.sink.close();
    });
    super.dispose();
  }
}
