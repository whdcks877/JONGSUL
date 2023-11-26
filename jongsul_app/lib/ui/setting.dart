import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/connect_state.dart';

class Setting extends StatelessWidget {
  const Setting({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddrSet();
          }));
        },
        icon: Icon(Icons.settings));
  }
}

class AddrSet extends StatelessWidget {
  const AddrSet({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<ConeectState>();
    final _CamEditController = TextEditingController(text: appState.addr_cam);
    final _KeyEditController = TextEditingController(text: appState.addr_key);

    return Scaffold(
        appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_new_sharp))),
        body: Column(
          children: [
            Center(
              child: SizedBox(
                width: 700,
                height: 100,
                child: TextField(
                  controller: _CamEditController,
                  decoration: InputDecoration(
                    labelText: "cam",
                  ),
                ),
              ),
            ),
            Center(
              child: SizedBox(
                width: 700,
                height: 100,
                child: TextField(
                  controller: _KeyEditController,
                  decoration: InputDecoration(
                    labelText: "controller",
                  ),
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  String cam_addr = _CamEditController.text;
                  String key_addr = _KeyEditController.text;

                  appState.addr_cam = cam_addr;
                  appState.addr_key = key_addr;

                  Navigator.pop(context);
                },
                child: Text("Apply"))
          ],
        ));
  }
}
