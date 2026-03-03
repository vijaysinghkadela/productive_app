// ignore_for_file: discarded_futures
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class DigitalWellbeingScreen extends StatefulWidget {
  const DigitalWellbeingScreen({super.key});

  @override
  State<DigitalWellbeingScreen> createState() => _DigitalWellbeingScreenState();
}

class _DigitalWellbeingScreenState extends State<DigitalWellbeingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breatheCtrl;
  int _selectedBreathing = 0;
  bool _breathingActive = false;
  int _breatheDuration = 3; // minutes

  static const _breathingModes = [
    _BreathingMode(name: '4-7-8 Breathing', inhale: 4, hold: 7, exhale: 8),
    _BreathingMode(name: 'Box Breathing', inhale: 4, hold: 4, exhale: 4),
    _BreathingMode(name: 'Deep Calm', inhale: 6, hold: 2, exhale: 8),
  ];

  @override
  void initState() {
    super.initState();
    final mode = _breathingModes[_selectedBreathing];
    final totalSeconds = mode.inhale + mode.hold + mode.exhale;
    _breatheCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: totalSeconds),
    );
  }

  @override
  void dispose() {
    _breatheCtrl.dispose();
    super.dispose();
  }

  String _breathPhaseLabel() {
    final mode = _breathingModes[_selectedBreathing];
    final total = mode.inhale + mode.hold + mode.exhale;
    final t = _breatheCtrl.value * total;
    if (t < mode.inhale) return 'Breathe In...';
    if (t < mode.inhale + mode.hold) return 'Hold...';
    return 'Breathe Out...';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Digital Wellbeing',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Screen Time Budget Gauge
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Screen Time Budget',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 200,
                          height: 120,
                          child: CustomPaint(
                            painter: _GaugePainter(value: 0.65),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const GradientText(
                          '2h 15m remaining',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'of 6h daily budget',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              ),

              // Pickup counter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text('📱', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 8),
                              const Text(
                                '47',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Pickups Today',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 24)),
                              const SizedBox(height: 8),
                              const Text(
                                '8-9 PM',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.warning,
                                ),
                              ),
                              Text(
                                'Peak Hour',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
              ),

              // Mindfulness breathing section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text(
                    'Mindfulness Break',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _breathingModes.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final isActive = i == _selectedBreathing;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedBreathing = i);
                          },
                          child: AnimatedContainer(
                            duration: Anim.normal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: isActive ? AppGradients.mint : null,
                              color: isActive ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Center(
                              child: Text(
                                _breathingModes[i].name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
              ),

              // Breathing circle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: AnimatedBuilder(
                            animation: _breatheCtrl,
                            builder: (context, _) {
                              final mode = _breathingModes[_selectedBreathing];
                              final total =
                                  mode.inhale + mode.hold + mode.exhale;
                              final t = _breatheCtrl.value * total;
                              double scale;
                              if (t < mode.inhale) {
                                scale = 0.6 + 0.4 * (t / mode.inhale);
                              } else if (t < mode.inhale + mode.hold) {
                                scale = 1.0;
                              } else {
                                scale = 1.0 -
                                    0.4 *
                                        ((t - mode.inhale - mode.hold) /
                                            mode.exhale);
                              }
                              return Center(
                                child: Container(
                                  width: 160 * scale,
                                  height: 160 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppColors.success
                                            .withValues(alpha: 0.2),
                                        AppColors.success
                                            .withValues(alpha: 0.05),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: AppColors.success
                                          .withValues(alpha: 0.3),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.success
                                            .withValues(alpha: 0.15 * scale),
                                        blurRadius: 30,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      _breathingActive
                                          ? _breathPhaseLabel()
                                          : 'Press to Start',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Duration selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [1, 3, 5].map((min) {
                            final isActive = min == _breatheDuration;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _breatheDuration = min),
                                child: AnimatedContainer(
                                  duration: Anim.normal,
                                  width: 52,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient:
                                        isActive ? AppGradients.mint : null,
                                    color: isActive
                                        ? null
                                        : AppColors.surfaceLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${min}m',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? Colors.white
                                            : AppColors.textTertiary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: _breathingActive ? 'Stop' : 'Start Breathing',
                          icon: _breathingActive
                              ? Icons.stop_rounded
                              : Icons.spa_rounded,
                          gradient: AppGradients.mint,
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              _breathingActive = !_breathingActive;
                              if (_breathingActive) {
                                _breatheCtrl.repeat();
                              } else {
                                _breatheCtrl.stop();
                                _breatheCtrl.reset();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
              ),

              // Bedtime reminder
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: AccentCard(
                    color: AppColors.primary,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bedtime_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bedtime Mode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Activates at 10:00 PM',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        CustomToggle(
                          value: true,
                          activeColor: AppColors.primary,
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      );
}

class _BreathingMode {
  const _BreathingMode({
    required this.name,
    required this.inhale,
    required this.hold,
    required this.exhale,
  });
  final String name;
  final int inhale;
  final int hold;
  final int exhale;
}

class _GaugePainter extends CustomPainter {
  // 0.0 to 1.0 (0=full budget remaining, 1=empty)
  _GaugePainter({required this.value});
  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background arc
    canvas.drawArc(
      rect,
      pi,
      pi,
      false,
      Paint()
        ..color = const Color(0x0FFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );

    // Value arc with gradient
    final usedFraction = 1.0 - value; // invert for "used" display
    Color fillColor;
    if (value > 0.6) {
      fillColor = AppColors.success;
    } else if (value > 0.3) {
      fillColor = AppColors.warning;
    } else {
      fillColor = AppColors.alert;
    }

    canvas.drawArc(
      rect,
      pi,
      pi * usedFraction,
      false,
      Paint()
        ..shader = SweepGradient(
          startAngle: pi,
          colors: [fillColor.withValues(alpha: 0.8), fillColor],
        ).createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round,
    );

    // Needle
    final needleAngle = pi + pi * usedFraction;
    final needleEnd = Offset(
      center.dx + (radius - 20) * cos(needleAngle),
      center.dy + (radius - 20) * sin(needleAngle),
    );
    canvas.drawLine(
      center,
      needleEnd,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Center dot
    canvas.drawCircle(center, 5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_GaugePainter old) => old.value != value;
}
