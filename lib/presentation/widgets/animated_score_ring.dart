import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/theme.dart';

/// Animated productivity score ring — the hero widget of the dashboard.
/// CustomPainter: 18px gradient stroke, animated draw, count-up number, pulsing glow.
class AnimatedScoreRing extends StatefulWidget {
  const AnimatedScoreRing({
    required this.score,
    super.key,
    this.size = 220,
    this.strokeWidth = 18,
    this.duration = const Duration(milliseconds: 1200),
  });
  final int score;
  final double size;
  final double strokeWidth;
  final Duration duration;

  @override
  State<AnimatedScoreRing> createState() => _AnimatedScoreRingState();
}

class _AnimatedScoreRingState extends State<AnimatedScoreRing>
    with TickerProviderStateMixin {
  late final AnimationController _drawCtrl;
  late final AnimationController _glowCtrl;
  late final Animation<double> _drawAnim;
  late final Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _drawCtrl = AnimationController(vsync: this, duration: widget.duration);
    _drawAnim =
        CurvedAnimation(parent: _drawCtrl, curve: const Cubic(0, 0, 0.2, 1));
    _countAnim = Tween(begin: 0.0, end: widget.score.toDouble()).animate(
      CurvedAnimation(parent: _drawCtrl, curve: const Cubic(0.4, 0, 0.2, 1)),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _drawCtrl.forward();
  }

  @override
  void didUpdateWidget(AnimatedScoreRing old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _drawCtrl.reset();
      _countAnim = Tween(begin: 0.0, end: widget.score.toDouble()).animate(
        CurvedAnimation(parent: _drawCtrl, curve: const Cubic(0.4, 0, 0.2, 1)),
      );
      _drawCtrl.forward();
    }
  }

  @override
  void dispose() {
    _drawCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([_drawCtrl, _glowCtrl]),
        builder: (context, _) {
          final score = _countAnim.value.round();
          final color = AppColors.scoreColor(score);
          final glowIntensity =
              0.2 + (_glowCtrl.value * 0.15) * (widget.score / 100);

          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow
                Container(
                  width: widget.size * 0.85,
                  height: widget.size * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: glowIntensity),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
                // Ring painter
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ScoreRingPainter(
                    progress: _drawAnim.value * (widget.score / 100),
                    strokeWidth: widget.strokeWidth,
                    score: widget.score,
                  ),
                ),
                // Center content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$score',
                      style: AppTheme.mono(64, FontWeight.w700).copyWith(
                        color: color,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "TODAY'S SCORE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
}

class _ScoreRingPainter extends CustomPainter {
  _ScoreRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.score,
  });
  final double progress;
  final double strokeWidth;
  final int score;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background track
    final trackPaint = Paint()
      ..color = const Color(0x0FFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // Gradient stroke
    List<Color> colors;
    if (score >= 71) {
      colors = [const Color(0xFF6C63FF), const Color(0xFF00D4FF)];
    } else if (score >= 41) {
      colors = [const Color(0xFFFFB800), const Color(0xFFFF6B35)];
    } else {
      colors = [const Color(0xFFFF4757), const Color(0xFFFF6B9D)];
    }

    final gradientPaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: colors,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, gradientPaint);

    // End cap glow
    if (progress > 0.05) {
      final endAngle = -pi / 2 + sweepAngle;
      final endX = center.dx + radius * cos(endAngle);
      final endY = center.dy + radius * sin(endAngle);
      final glowPaint = Paint()
        ..color = colors.last.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(endX, endY), strokeWidth / 2, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_ScoreRingPainter old) =>
      old.progress != progress || old.score != score;
}
