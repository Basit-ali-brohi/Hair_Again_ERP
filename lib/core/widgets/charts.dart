// core/widgets — hand-painted charts (shared by Dashboard + Reports).
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color line, fillTop, fillBottom, grid, text, dotFill;
  LineChartPainter({required this.data, required this.labels, required this.line, required this.fillTop, required this.fillBottom, required this.grid, required this.text, required this.dotFill});

  @override
  void paint(Canvas canvas, Size size) {
    const leftPad = 8.0, bottomPad = 26.0, topPad = 10.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad - topPad;
    if (data.isEmpty || chartH <= 0) return;
    final maxV = data.reduce(math.max) * 1.15;
    const minV = 0.0;
    final range = (maxV - minV) == 0 ? 1.0 : (maxV - minV);

    const lines = 4;
    final gp = Paint()..color = grid..strokeWidth = 1;
    for (int i = 0; i <= lines; i++) {
      final y = topPad + chartH * (i / lines);
      canvas.drawLine(Offset(leftPad, y), Offset(size.width, y), gp);
      _label(canvas, (maxV - range * (i / lines)).toStringAsFixed(0), Offset(leftPad, y - 6), text, 9);
    }

    Offset pt(int i) => Offset(leftPad + chartW * (data.length == 1 ? 0.5 : i / (data.length - 1)), topPad + chartH * (1 - (data[i] - minV) / range));

    final fill = Path()..moveTo(pt(0).dx, topPad + chartH);
    for (int i = 0; i < data.length; i++) {
      fill.lineTo(pt(i).dx, pt(i).dy);
    }
    fill.lineTo(pt(data.length - 1).dx, topPad + chartH);
    fill.close();
    canvas.drawPath(fill, Paint()..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [fillTop, fillBottom]).createShader(Rect.fromLTWH(0, topPad, size.width, chartH)));

    final lp = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (int i = 1; i < data.length; i++) {
      lp.lineTo(pt(i).dx, pt(i).dy);
    }
    canvas.drawPath(lp, Paint()..color = line..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round..strokeJoin = StrokeJoin.round);

    for (int i = 0; i < data.length; i++) {
      final o = pt(i);
      canvas.drawCircle(o, 4.5, Paint()..color = dotFill);
      canvas.drawCircle(o, 4.5, Paint()..color = line..style = PaintingStyle.stroke..strokeWidth = 2.5);
      _label(canvas, labels[i], Offset(o.dx, size.height - 14), text, 10, center: true);
    }
  }

  void _label(Canvas canvas, String s, Offset at, Color color, double size, {bool center = false}) {
    final tp = TextPainter(text: TextSpan(text: s, style: GoogleFonts.inter(color: color, fontSize: size, fontWeight: FontWeight.w500)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(center ? at.dx - tp.width / 2 : at.dx, at.dy));
  }

  @override
  bool shouldRepaint(covariant LineChartPainter old) => old.data != data || old.line != line || old.grid != grid;
}

class PieChartPainter extends CustomPainter {
  final List<(double, Color)> segments;
  final Color trackColor;
  PieChartPainter({required this.segments, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    const stroke = 26.0;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);
    final total = segments.fold<double>(0, (s, e) => s + e.$1);
    if (total <= 0) return;
    canvas.drawCircle(center, radius - stroke / 2, Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = stroke);
    double start = -math.pi / 2;
    const gap = 0.04;
    for (final seg in segments) {
      final sweep = (seg.$1 / total) * (2 * math.pi) - gap;
      canvas.drawArc(rect, start + gap / 2, sweep, false, Paint()..color = seg.$2..style = PaintingStyle.stroke..strokeWidth = stroke..strokeCap = StrokeCap.round);
      start += (seg.$1 / total) * (2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter old) => old.segments != segments;
}
