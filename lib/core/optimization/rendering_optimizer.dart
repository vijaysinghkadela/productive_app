// ignore_for_file: avoid_renaming_method_parameters
import 'package:flutter/material.dart';

/// Productivity ring: CustomPainter with shouldRepaint returning false when score unchanged
class ProductivityRingPainter extends CustomPainter {
  const ProductivityRingPainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  bool shouldRepaint(ProductivityRingPainter old) =>
      old.progress != progress || old.color != color; // Granular repaint check

  @override
  void paint(Canvas canvas, Size size) {
    // Use canvas.drawArc (fast) not Path.addArc (slower)
    // Cache Paint objects as static finals
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // -90 degrees
      progress * 6.28319, // 360 degrees
      false,
      paint,
    );
  }
}

class RenderingOptimizerRules {
  // CONST EVERYTHING:
  // RIGHT: use const prevents rebuild entirely
  static const _cardGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
  );

  static Widget optimizedGradientCard(Widget child) => DecoratedBox(
        decoration: const BoxDecoration(gradient: _cardGradient),
        child: child,
      );
}
