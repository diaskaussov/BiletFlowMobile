import 'dart:math' as math;

import 'package:flutter/rendering.dart';

/// Штриховка 45° для полей отказа: полоса 7 pt с шагом 16 pt, белый 11%,
/// только верхние [height] pt (§06).
class HatchPainter extends CustomPainter {
  const HatchPainter({this.height = 210});

  final double height;

  @override
  void paint(Canvas canvas, Size size) {
    final h = math.min(height, size.height);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, h));
    final paint = Paint()
      ..color = const Color(0x1CFFFFFF)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke;
    // Линии под 45°; шаг по x = 16·√2, чтобы перпендикулярный шаг был 16 pt.
    const step = 16 * math.sqrt2;
    for (double c = -h; c < size.width + step; c += step) {
      canvas.drawLine(Offset(c, h), Offset(c + h, 0), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(HatchPainter old) => old.height != height;
}

/// Вертикальные линии 1 pt с шагом 12 pt — поле Campaign QR,
/// намеренно не похожее на отказ по билету (§06).
class VerticalRulesPainter extends CustomPainter {
  const VerticalRulesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x14FFFFFF)
      ..strokeWidth = 1;
    for (double x = 6; x < size.width; x += 12) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(VerticalRulesPainter old) => false;
}

/// Рамка-прицел сканера: четыре уголка 46 pt по 2 pt и линия посередине (§07).
class ReticlePainter extends CustomPainter {
  const ReticlePainter({required this.cornerColor, required this.lineColor});

  final Color cornerColor;
  final Color lineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 46.0;
    final p = Paint()
      ..color = cornerColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final w = size.width, h = size.height;
    final path = Path()
      ..moveTo(0, arm)
      ..lineTo(0, 0)
      ..lineTo(arm, 0)
      ..moveTo(w - arm, 0)
      ..lineTo(w, 0)
      ..lineTo(w, arm)
      ..moveTo(w, h - arm)
      ..lineTo(w, h)
      ..lineTo(w - arm, h)
      ..moveTo(arm, h)
      ..lineTo(0, h)
      ..lineTo(0, h - arm);
    canvas.drawPath(path, p);
    canvas.drawLine(
      Offset(26, h / 2),
      Offset(w - 26, h / 2),
      Paint()
        ..color = lineColor
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(ReticlePainter old) =>
      old.cornerColor != cornerColor || old.lineColor != lineColor;
}

/// Пунктирная рамка 2 pt — знак вердикта для повторного скана (B6).
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dash = 5.0, gap = 4.0;
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final rect = Offset.zero & size;
    final path = Path()..addRect(rect.deflate(1));
    for (final metric in path.computeMetrics()) {
      for (double d = 0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), p);
      }
    }
  }

  @override
  bool shouldRepaint(DashedBorderPainter old) => old.color != color;
}
