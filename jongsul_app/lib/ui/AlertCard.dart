import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/app_state.dart';

class AlertCard extends StatefulWidget {
  const AlertCard({Key? key}) : super(key: key);

  @override
  _AlertCardState createState() => _AlertCardState();
}

class _AlertCardState extends State<AlertCard> {
  String alertLevel = "Initial Level";

  @override
  Widget build(BuildContext context) {
    return Consumer<MyAppState>(
      builder: (context, provider, child) {
        // Use the current state to build the UI
        Widget alertCard = buildAlertCard(alertLevel);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            alertLevel = provider.getAlert();
          });
        });

        return SizedBox(height: 100, width: 320, child: alertCard);
      },
    );
  }

  Widget buildAlertCard(String alertLevel) {
    switch (alertLevel) {
      case "Safety":
        return Card(
          color: Colors.green,
          child: Text("양호", style: TextStyle(fontSize: 50), textAlign: TextAlign.center,)
        );
      case "Danger":
        return Card(
          color: Colors.red,
          child: Text("※ 위험 감지 ※", style: TextStyle(fontSize: 40), textAlign: TextAlign.center,)
        );
      default:
        return Card(
          color: Colors.purple,
        );
    }
  }
}
