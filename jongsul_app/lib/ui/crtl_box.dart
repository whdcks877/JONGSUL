import 'package:flutter/material.dart';
import './mykey.dart';
import 'package:provider/provider.dart';

import '../provider/connect_state.dart';

class CtrlBox extends StatefulWidget {
  const CtrlBox({super.key});

  @override
  State<CtrlBox> createState() => _CtrlBoxState();
}

class _CtrlBoxState extends State<CtrlBox> {
  var connected = false;

  @override
  Widget build(BuildContext context) {
    Widget page;

    return Consumer<ConeectState>(builder: (context, provider, child) {
      connected = provider.connected;

      if (connected) {
        page = MyKey(channel: provider.webSocketManager.key_channel);
      } else {
        page = Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                  buildEmptyIcon(),
                ],
              ),
            ],
          ),
        );
      }
      return Scaffold(
        body: Expanded(
          child: page,
        ),
      );
    });
  }

  Widget buildEmptyIcon() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Icon(
        Icons.square,
        size: 40,
        color: Colors.grey,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
