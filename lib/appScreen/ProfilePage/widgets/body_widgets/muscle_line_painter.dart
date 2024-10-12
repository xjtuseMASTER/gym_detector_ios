//绘制肌肉导航线
import 'package:flutter/material.dart';

class MuscleLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  MuscleLinePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =Color.fromARGB(255, 225, 155, 238)
      ..strokeWidth = 1;

    // 绘制导航线
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(MuscleLinePainter oldDelegate) {
    return oldDelegate.start != start || oldDelegate.end != end;
  }
}