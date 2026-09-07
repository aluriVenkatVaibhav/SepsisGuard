import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedRiskRing extends StatelessWidget {
  final double progress;
  final Color color;
  final double size;

  const AnimatedRiskRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return CustomPaint(
          size: Size(size, size),
          painter: _RingPainter(value, color),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final fgPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.6), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
