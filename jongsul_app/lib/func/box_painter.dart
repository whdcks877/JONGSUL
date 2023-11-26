import 'package:flutter/material.dart';

class BoxPainter extends CustomPainter {
  final List<dynamic>? myResults;

  BoxPainter(this.myResults);
  
  String cls = "";

  @override
  void paint(Canvas canvas, Size size) {
    // Check if myResults is null or empty
    if (myResults == null || myResults!.isEmpty) {
      return;
    }

    var cls_color = Colors.green;

    // Iterate through myResults and draw boxes and labels on the canvas
    for (var box in myResults!) {
      // Ensure that 'point' is not null
      if (box['point'] != null) {
        // Extract box coordinates, class, and score
        List<dynamic> point = box["point"][0];
        var class_name = box["class"];
        var score = box["score"][0];
        if (class_name == "knife" || class_name == 'scissors') {
          cls_color = Colors.red;
          cls = "knife";
        } else {
          cls_color = Colors.green;
          cls = class_name;
          
        }

        // Convert the coordinates to double values
        double x1 = point[0];
        double y1 = point[1];
        double x2 = point[2];
        double y2 = point[3];

        Paint paint = Paint()
          ..color = cls_color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

        canvas.drawRect(Rect.fromLTRB(x1, y1, x2, y2), paint);

        TextSpan span = TextSpan(
          text: '$cls: ${score.toStringAsFixed(2)}',
          style: TextStyle(color: cls_color, fontSize: 20.0),
        );

        TextPainter tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );

        tp.layout();
        tp.paint(canvas, Offset(x1, y1 - tp.height - 5.0));
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // You can customize this based on your requirements
  }
}
