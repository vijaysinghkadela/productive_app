import 'package:flutter/material.dart';

// Rule 1: Only animate transform and opacity — NEVER animate layout
class OptimizedTransformAnimation extends StatelessWidget {
  const OptimizedTransformAnimation({
    required this.isExpanded,
    required this.child,
    super.key,
  });
  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // RIGHT (transform only = smooth):
    return AnimatedScale(
      scale: isExpanded ? 1.0 : 0.33,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      child: child, // Fixed size, transform scales it implicitly outside layout
    );
  }
}

// Optimized Particle System bypassing widget trees
class ParticleFieldPainter extends CustomPainter {
  // Disable AA for tiny particles (faster)

  ParticleFieldPainter({
    required this.particles,
    required this.animationValue,
  });
  final List<_Particle> particles;
  final double animationValue;

  // Single Paint object (reused — no GC pressure):
  static final Paint _particlePaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = false;

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      _particlePaint.color = particle.color; // Just change color, not new Paint
      canvas.drawCircle(
        particle.position(animationValue, size),
        particle.radius,
        _particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticleFieldPainter old) =>
      old.animationValue !=
      animationValue; // Only repaint when animation advances
}

class _Particle {
  _Particle(this.color, this.radius, this.position);
  final Color color;
  final double radius;
  final Offset Function(double progress, Size size) position;
}

// Optimized Glassmorphism fallback for low-end
class OptimizedGlassCard extends StatelessWidget {
  const OptimizedGlassCard({
    required this.useBackdropFilter,
    required this.child,
    super.key,
  });
  final bool useBackdropFilter; // Disable on low-end devices
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLowEnd =
        !useBackdropFilter; // Derived realistically from DevicePerformanceTier

    if (isLowEnd) {
      // Low-end: solid semi-transparent background (no blur)
      return DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A), // Opaque approximation of glass
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: child,
      );
    }

    // High end: 2 active BackdropFilter widgets max onscreen at once.
    /*
    return ClipRRect( // Required parent for BackdropFilter
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.06), Colors.white.withOpacity(0.02)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: child,
        ),
      ),
    );
    */
    return Container();
  }
}
