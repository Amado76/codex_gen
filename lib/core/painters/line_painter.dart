import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  const LinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0x0AFFFFFF)
      ..strokeWidth = 0.7;
    for (double i = -size.height; i < size.width + size.height; i += 10) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
