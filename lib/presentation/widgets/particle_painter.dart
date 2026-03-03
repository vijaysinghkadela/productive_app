// ignore_for_file: unnecessary_getters_setters
import 'dart:async';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/data/providers/anti_gravity_provider.dart';

/// Runtime particle state for Anti-Gravity visual effects.
class Particle {
  /// Creates a particle.
  Particle({
    required this.x,
    required this.y,
    required this.vy,
    required this.opacity,
    required this.radius,
  });

  double x;
  double y;
  double vy;
  double opacity;
  double radius;
}

/// Animated particle layer rendered above focus content while Anti-Gravity is active.
class AntiGravityParticleLayer extends ConsumerStatefulWidget {
  /// Creates an Anti-Gravity particle layer.
  const AntiGravityParticleLayer({super.key});

  @override
  ConsumerState<AntiGravityParticleLayer> createState() =>
      _AntiGravityParticleLayerState();
}

class _AntiGravityParticleLayerState
    extends ConsumerState<AntiGravityParticleLayer>
    with SingleTickerProviderStateMixin {
  final Random _random = Random();
  final List<Particle> _particles = <Particle>[];
  late final AnimationController _frameController;
  late final ParticlePainter _painter;

  @override
  void initState() {
    super.initState();
    _frameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..repeat();
    _painter = ParticlePainter(
      particles: _particles,
      random: _random,
      tiltX: 0,
      repaint: _frameController,
    );
    unawaited(_configureParticleCount());
  }

  Future<void> _configureParticleCount() async {
    final particleCount = await _resolveParticleCount();
    if (!mounted) return;

    setState(() {
      _particles
        ..clear()
        ..addAll(
          List<Particle>.generate(
            particleCount,
            (_) => _buildParticle(),
          ),
        );
    });
  }

  Future<int> _resolveParticleCount() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final info = await deviceInfoPlugin.androidInfo;
        return info.isLowRamDevice ? 15 : 30;
      case TargetPlatform.iOS:
        final info = await deviceInfoPlugin.iosInfo;
        final majorVersionRaw = info.systemVersion.split('.').first;
        final majorVersion = int.tryParse(majorVersionRaw) ?? 17;
        return majorVersion >= 16 ? 30 : 15;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return 30;
    }
  }

  Particle _buildParticle() => Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        vy: 0.001 + _random.nextDouble() * 0.003,
        opacity: 0.15 + _random.nextDouble() * 0.45,
        radius: 1.4 + _random.nextDouble() * 2.6,
      );

  @override
  void dispose() {
    _frameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final antiGravityState = ref.watch(antiGravityProvider);
    if (_particles.isEmpty || !antiGravityState.isActive) {
      return const SizedBox.shrink();
    }

    _painter.tiltX = antiGravityState.tiltX;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _frameController,
        builder: (BuildContext context, Widget? child) => CustomPaint(
          painter: _painter,
          size: Size.infinite,
        ),
      ),
    );
  }
}

/// Painter for Anti-Gravity upward drifting particles.
class ParticlePainter extends CustomPainter {
  /// Creates a particle painter.
  ParticlePainter({
    required this.particles,
    required this.random,
    required double tiltX,
    required Listenable repaint,
  })  : _tiltX = tiltX,
        super(repaint: repaint);

  final List<Particle> particles;
  final Random random;
  double _tiltX;

  /// Current horizontal tilt influence in normalized range [-1, 1].
  double get tiltX => _tiltX;

  /// Updates horizontal tilt influence for particle drift.
  set tiltX(double value) {
    _tiltX = value;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    for (final particle in particles) {
      particle.y -= particle.vy;
      particle.x += (_tiltX * 2.0) / size.width;

      if (particle.x < 0) {
        particle.x += 1;
      } else if (particle.x > 1) {
        particle.x -= 1;
      }

      if (particle.y < 0) {
        particle.y = 1;
        particle.x = random.nextDouble();
      }

      final paintX = particle.x * size.width;
      final paintY = particle.y * size.height;

      final fadeIn = ((1 - particle.y) / 0.2).clamp(0, 1).toDouble();
      final fadeOut = (particle.y / 0.2).clamp(0, 1).toDouble();
      final alpha = particle.opacity * fadeIn * fadeOut;

      final paint = Paint()
        ..color = const Color(0xFF9FD7FF).withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      canvas.drawCircle(Offset(paintX, paintY), particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) =>
      oldDelegate.tiltX != tiltX;
}
