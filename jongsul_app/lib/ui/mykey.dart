import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MyKey extends StatefulWidget {
  final WebSocketChannel channel;
  const MyKey({required this.channel, Key? key}) : super(key: key);

  @override
  _MyKeyState createState() => _MyKeyState();
}

class _MyKeyState extends State<MyKey> {
  String message = '';
  String msg = "...";

  // Map to track the state of each button
  Map<String, bool> buttonStates = {
    'UP': false,
    'DOWN': false,
    'LEFT': false,
    'RIGHT': false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Text('WebSocket Message: $message'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    buildButton('TEMP0', Icons.light_mode),
                    buildButton('UP', Icons.arrow_upward),
                    buildButton('TEMP1', Icons.volume_up),
                  ],
                ),
                Row(
                  children: [
                    buildButton('LEFT', Icons.arrow_back),
                    buildButton('TEMP2', Icons.check_box_outline_blank),
                    buildButton('RIGHT', Icons.arrow_forward),
                  ],
                ),
                Row(
                  children: [
                    buildButton('TEMP3', Icons.check_box_outline_blank),
                    buildButton('DOWN', Icons.arrow_downward),
                    buildButton('TEMP4', Icons.check_box_outline_blank),
                  ],
                ),
              ],
            )
          ],
        ),
        RawKeyboardListener(
          autofocus: true,
          focusNode: FocusNode(),
          onKey: (RawKeyEvent event) {
            if (event is RawKeyDownEvent) {
              String key = event.logicalKey.debugName ?? "";
              String direction = getDirection(key);
              sendMessage(direction);
              setState(() {
                msg = direction;
                // Update the button state
                buttonStates[direction] = true;
              });
            }
            if (event is RawKeyUpEvent) {
              sendMessage("STOP");
              setState(() {
                msg = "STOP";
                // Reset button states
                buttonStates.forEach((key, value) {
                  buttonStates[key] = false;
                });
              });
            }
          },
          child: Text(msg),
        ),
      ],
    );
  }

  Widget buildButton(String direction, IconData icon) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        onTapDown: (_) {
          sendMessage(direction);
          setState(() {
            msg = direction;
            buttonStates[direction] = true;
          });
        },
        onTapUp: (_) {
          sendMessage("STOP");
          setState(() {
            msg = "STOP";
            buttonStates[direction] = false;
          });
        },
        onTapCancel: () {
          sendMessage("STOP");
          setState(() {
            msg = "STOP";
            buttonStates[direction] = false;
          });
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          decoration: BoxDecoration(
            color: buttonStates[direction] ?? false ? Colors.blue : Colors.grey,
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: EdgeInsets.all(16.0),
          child: Icon(
            icon,
            size: 40,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String getDirection(String key) {
    switch (key) {
      case 'Key W':
        return 'UP';
      case 'Key A':
        return 'LEFT';
      case 'Key D':
        return 'RIGHT';
      case 'Key S':
        return 'DOWN';
      default:
        return 'STOP';
    }
  }

  void sendMessage(String direction) {
    widget.channel.sink.add(direction);
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}
