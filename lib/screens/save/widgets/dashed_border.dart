import 'package:flutter/material.dart';

/// 점선(dashed) 테두리를 그리는 CustomPainter
///
/// CustomPaint의 painter로 사용하면 위젯 크기에 맞게 점선 rounded-rect 테두리를 그린다.
class DashedBorderPainter extends CustomPainter {
  const DashedBorderPainter({
    required this.color,
    this.radius = 16.0,
    this.dashLength = 5.0,
    this.dashSpace = 4.0,
    this.strokeWidth = 1.5,
  });

  final Color color;
  final double radius;
  final double dashLength;
  final double dashSpace;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              strokeWidth / 2,
              strokeWidth / 2,
              size.width - strokeWidth,
              size.height - strokeWidth,
            ),
            Radius.circular(radius),
          ),
        );

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth;
}
