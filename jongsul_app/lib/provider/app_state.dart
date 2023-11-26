import 'package:flutter/material.dart';

class MyAppState extends ChangeNotifier {
  String alert = "Safety";

  void setAlert(int level) {
    var prev_alert = alert;
    if (level == 1) {
      alert = "Danger";
    } else {
      alert = "Safety";
    }
    if (prev_alert != alert) {
      notifyListeners();
    }
  }

  String getAlert() {
    return alert;
  }
}
