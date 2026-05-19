import 'package:flutter/material.dart';
import '../models/card_background.dart';
import '../theme/app_colors.dart';
import '../l10n/app_localizations.dart';

class BackgroundSelectorWidget extends StatelessWidget {
  final CardBackground current;
  final ValueChanged<CardBackground> onChange;
  const BackgroundSelectorWidget({super.key, required this.current, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final labels = {
      CardBackground.lines:   s.bgLines,
      CardBackground.elegant: s.bgElegant,
    };
    return Row(
      children: CardBackground.values.map((bg) {
        final active = bg == current;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(bg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? kAccentBlue.withValues(alpha: 0.2) : kBgField,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: active ? kAccentBlue : kBorderStrong, width: active ? 1.5 : 1),
              ),
              child: Column(
                children: [
                  BgPreviewWidget(bg: bg),
                  const SizedBox(height: 5),
                  Text(labels[bg] ?? bg.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? Colors.white : kTextMuted,
                        fontSize: 9,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class BgPreviewWidget extends StatelessWidget {
  final CardBackground bg;
  const BgPreviewWidget({super.key, required this.bg});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size(48, 32), painter: _BgPreviewPainter(bg: bg));
  }
}

class _BgPreviewPainter extends CustomPainter {
  final CardBackground bg;
  const _BgPreviewPainter({required this.bg});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(4)),
      Paint()..color = const Color(0xFF1B3A6E),
    );

    if (bg == CardBackground.lines) {
      final p = Paint()..color = Colors.white.withValues(alpha: 0.1)..strokeWidth = 0.5;
      for (double i = -size.height; i < size.width + size.height; i += 8) {
        canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), p);
      }
    } else {
      final p = Paint()..color = Colors.white.withValues(alpha: 0.28)..strokeWidth = 0.7..style = PaintingStyle.stroke;
      const inset = 3.0;
      canvas.drawRRect(RRect.fromRectAndRadius(
          Rect.fromLTRB(inset, inset, size.width - inset, size.height - inset), const Radius.circular(3)), p);
      final fp = Paint()..color = Colors.white.withValues(alpha: 0.35);
      for (final c in [
        Offset(inset + 4, inset + 4), Offset(size.width - inset - 4, inset + 4),
        Offset(inset + 4, size.height - inset - 4), Offset(size.width - inset - 4, size.height - inset - 4),
      ]) {
        final path = Path()
          ..moveTo(c.dx, c.dy - 2.5)..lineTo(c.dx + 2.5, c.dy)
          ..lineTo(c.dx, c.dy + 2.5)..lineTo(c.dx - 2.5, c.dy)..close();
        canvas.drawPath(path, fp);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BgPreviewPainter old) => old.bg != bg;
}
