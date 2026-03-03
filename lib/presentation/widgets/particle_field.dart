import 'dart:math';
import 'package:flutter/material.dart';
import 'package:focusguard_pro/core/constants.dart';

/// Ambient floating particle system — used as background layer on key screens.
/// Uses CustomPainter with RepaintBoundary for performance.
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    this.particleCount = 28,
    this.tintColor,
    this.maxOpacity = 0.08,
  });
  final int particleCount;
  final Color? tintColor;
  final double maxOpacity;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Particle> _particles;
  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
    _particles = List.generate(widget.particleCount, (_) => _randomParticle());
  }

  _Particle _randomParticle() {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
    ];
    return _Particle(
      x: _rng.nextDouble(),
      y: _rng.nextDouble(),
      size: 2 + _rng.nextDouble() * 4,
      opacity: 0.02 + _rng.nextDouble() * (widget.maxOpacity - 0.02),
      speed: 0.0003 + _rng.nextDouble() * 0.0008,
      angle: _rng.nextDouble() * 2 * pi,
      color: widget.tintColor ?? colors[_rng.nextInt(colors.length)],
      driftPhase: _rng.nextDouble() * 2 * pi,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) => CustomPaint(
            painter: _ParticlePainter(
              particles: _particles,
              progress: _ctrl.value,
            ),
            size: Size.infinite,
          ),
        ),
      );
}

class _Particle {
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.angle,
    required this.color,
    required this.driftPhase,
  });
  double x;
  double y;
  double size;
  double opacity;
  double speed;
  double angle;
  double driftPhase;
  Color color;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({required this.particles, required this.progress});
  final List<_Particle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      // Slow drift with sinusoidal wobble
      final t = progress * 40; // Total seconds elapsed (roughly)
      final dx = cos(p.angle + sin(t * 0.1 + p.driftPhase) * 0.5) * p.speed * t;
      final dy =
          sin(p.angle + cos(t * 0.08 + p.driftPhase) * 0.5) * p.speed * t;

      final px = ((p.x + dx) % 1.0) * size.width;
      final py = ((p.y + dy) % 1.0) * size.height;

      // Breathing opacity
      final breathe = 0.5 + 0.5 * sin(t * 0.15 + p.driftPhase);
      final alpha = p.opacity * (0.6 + 0.4 * breathe);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);

      canvas.drawCircle(Offset(px, py), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}
