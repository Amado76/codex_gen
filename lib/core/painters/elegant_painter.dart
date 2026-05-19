import 'package:flutter/material.dart';

/// Elegant border-and-ornament background painter.
/// Draws two concentric border lines, corner diamonds, and mid-edge ticks —
/// all at low opacity so card text remains legible.
class ElegantPainter extends CustomPainter {
  final Color color;
  const ElegantPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    const inset = 7.0;
    const r = 10.0;

    // Single outer border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset),
        const Radius.circular(r),
      ),
      linePaint,
    );

    // Corner diamond ornaments on the outer border
    _drawCornerOrnaments(canvas, size, inset, color);

    // Mid-edge tick marks on the outer border only
    _drawMidEdgeTicks(canvas, size, inset, linePaint);
  }

  void _drawCornerOrnaments(Canvas canvas, Size size, double inset, Color c) {
    const d = 5.0;
    final fill  = Paint()..color = c.withValues(alpha: 0.22)..style = PaintingStyle.fill;
    final cross = Paint()..color = c.withValues(alpha: 0.18)..strokeWidth = 0.6;

    final corners = [
      Offset(inset + d + 1, inset + d + 1),
      Offset(size.width - inset - d - 1, inset + d + 1),
      Offset(inset + d + 1, size.height - inset - d - 1),
      Offset(size.width - inset - d - 1, size.height - inset - d - 1),
    ];
    for (final c in corners) {
      final path = Path()
        ..moveTo(c.dx, c.dy - d)..lineTo(c.dx + d, c.dy)
        ..lineTo(c.dx, c.dy + d)..lineTo(c.dx - d, c.dy)..close();
      canvas.drawPath(path, fill);
      canvas.drawLine(Offset(c.dx - d - 2, c.dy), Offset(c.dx + d + 2, c.dy), cross);
      canvas.drawLine(Offset(c.dx, c.dy - d - 2), Offset(c.dx, c.dy + d + 2), cross);
    }
  }

  void _drawMidEdgeTicks(Canvas canvas, Size size, double inset, Paint p) {
    final midX = size.width / 2;
    final midY = size.height / 2;

    for (final y in [inset, size.height - inset]) {
      _drawSmallDiamond(canvas, Offset(midX, y), 3, p.color);
    }
    for (final x in [inset, size.width - inset]) {
      _drawSmallDiamond(canvas, Offset(x, midY), 3, p.color);
    }
  }

  void _drawSmallDiamond(Canvas canvas, Offset c, double r, Color col) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)..lineTo(c.dx + r, c.dy)
      ..lineTo(c.dx, c.dy + r)..lineTo(c.dx - r, c.dy)..close();
    canvas.drawPath(path, Paint()..color = col.withValues(alpha: 0.28)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant ElegantPainter old) => old.color != color;
}
