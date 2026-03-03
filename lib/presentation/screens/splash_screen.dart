import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/particle_field.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _loaderCtrl;
  late final AnimationController _exitCtrl;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loaderCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _exitCtrl = AnimationController(vsync: this, duration: Anim.normal);

    // Sequence: logo(0-1.2s) → loader(1.0-2.5s) → wait → exit(3.0-3.3s) → navigate
    _logoCtrl.forward();
    Future.delayed(
      const Duration(milliseconds: 1000),
      () => _loaderCtrl.forward(),
    );
    Future.delayed(const Duration(milliseconds: 3000), () async {
      await _exitCtrl.forward();
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _loaderCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: AnimatedBuilder(
          animation: _exitCtrl,
          builder: (context, child) {
            final exitT = Curves.easeIn.transform(_exitCtrl.value);
            return Opacity(
              opacity: 1.0 - exitT,
              child: Transform.scale(
                scale: 1.0 - (exitT * 0.05),
                child: child,
              ),
            );
          },
          child: Stack(
            children: [
              // Particle background
              const Positioned.fill(
                child: ParticleField(particleCount: 35, maxOpacity: 0.06),
              ),

              // Radial glow pulse (appears at 600ms)
              Center(
                child: AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (context, _) {
                    final t = (_logoCtrl.value - 0.5).clamp(0.0, 0.5) *
                        2; // 0.5→1.0 mapped to 0→1
                    return Container(
                      width: 300 + (t * 100),
                      height: 300 + (t * 100),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.15 * t),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo — shield with lightning bolt
                    _AnimatedLogo(controller: _logoCtrl),

                    const SizedBox(height: 32),

                    // Wordmark: "FocusGuard Pro" — fades up at 1000ms
                    Text(
                      'FocusGuard Pro',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    )
                        .animate(delay: 1000.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                    const SizedBox(height: 8),

                    // Tagline
                    Text(
                      AppStrings.tagline,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate(delay: 1200.ms).fadeIn(duration: 500.ms),
                  ],
                ),
              ),

              // Loading bar at bottom
              Positioned(
                left: 60,
                right: 60,
                bottom: 80,
                child: AnimatedBuilder(
                  animation: _loaderCtrl,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_loaderCtrl.value);
                    return Container(
                      height: 2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(1),
                        color: AppColors.surfaceLight,
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: t,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.hero,
                            borderRadius: BorderRadius.circular(1),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
}

/// 3-stage animated logo: shield outline draw → bolt fill → bounce+glow
class _AnimatedLogo extends StatelessWidget {
  const _AnimatedLogo({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final t = controller.value;

          // Stage 1 (0-0.33): shield draws — scale up from 0.5
          final stage1 = (t / 0.33).clamp(0.0, 1.0);
          // Stage 2 (0.33-0.58): bolt fills in
          final stage2 = ((t - 0.33) / 0.25).clamp(0.0, 1.0);
          // Stage 3 (0.58-1.0): scale bounce + glow
          final stage3 = ((t - 0.58) / 0.42).clamp(0.0, 1.0);

          final scaleBase = 0.5 + (stage1 * 0.5);
          final scaleBounce =
              stage3 > 0 ? 1.0 + sin(stage3 * pi) * 0.08 : scaleBase;

          return Transform.scale(
            scale: stage1 < 1.0 ? scaleBase : scaleBounce,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: stage1),
                    AppColors.secondary.withValues(alpha: stage1 * 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withValues(alpha: 0.3 * stage1 + 0.2 * stage3),
                    blurRadius: 30 + (stage3 * 20),
                    spreadRadius: stage3 * 5,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15 * stage1),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Shield icon — always visible
                  Icon(
                    Icons.shield_rounded,
                    size: 64,
                    color: Colors.white.withValues(alpha: stage1),
                  ),
                  // Lightning bolt — fades in stage 2
                  Positioned(
                    top: 30,
                    child: Icon(
                      Icons.bolt_rounded,
                      size: 48,
                      color: Colors.white.withValues(alpha: stage2),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}
