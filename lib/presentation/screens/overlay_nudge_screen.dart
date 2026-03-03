// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:focusguard_pro/presentation/widgets/particle_field.dart';

/// Overlay nudge shown when user opens a blocked app.
/// Used as a standalone screen (Android overlay) or a route.
class OverlayNudgeScreen extends StatelessWidget {
  const OverlayNudgeScreen({
    super.key,
    this.appName = 'Instagram',
    this.minutesUsed = 47,
    this.dailyLimit = 30,
    this.timesUsedToday = 2,
  });
  final String appName;
  final int minutesUsed;
  final int dailyLimit;
  final int timesUsedToday;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Red-tinted particle field
            const Positioned.fill(
              child: ParticleField(
                particleCount: 20,
                maxOpacity: 0.04,
                tintColor: AppColors.alert,
              ),
            ),

            // Warning halo border
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.alert.withValues(alpha: 0.08),
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
                  duration: 2.seconds,
                  builder: (context, value, child) =>
                      Opacity(opacity: 0.3 + value * 0.7, child: child),
                ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    const Spacer(),

                    // App icon with X badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.alert.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.photo_camera_rounded,
                            size: 40,
                            color: AppColors.textTertiary,
                          ),
                        ),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.alert, Color(0xFFFF6B9D)],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.alert.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ).animate().scale(
                          begin: const Offset(0.5, 0.5),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),

                    const SizedBox(height: 24),

                    // Main message
                    const Text(
                      "You've been on",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Time counter
                    GradientText(
                      '${minutesUsed}m today',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                      ),
                      gradient: const LinearGradient(
                        colors: [AppColors.alert, AppColors.warning],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).custom(
                          duration: 2.seconds,
                          builder: (context, value, child) => Opacity(
                            opacity: 0.7 + value * 0.3,
                            child: child,
                          ),
                        ),

                    Text(
                      'Your limit was $dailyLimit minutes',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quote card
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      borderColor: AppColors.warning.withValues(alpha: 0.2),
                      child: Column(
                        children: [
                          Text(
                            motivationalQuotes[DateTime.now().minute %
                                motivationalQuotes.length],
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 16),

                    // Stats row
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak at risk',
                          color: AppColors.streak,
                        ),
                        SizedBox(width: 16),
                        _StatBadge(
                          icon: Icons.trending_down_rounded,
                          label: 'Score -8 pts',
                          color: AppColors.alert,
                        ),
                      ],
                    ).animate(delay: 400.ms).fadeIn(duration: 300.ms),

                    const Spacer(flex: 2),

                    // CTA buttons
                    PrimaryButton(
                      label: 'Back to Work 💪',
                      icon: Icons.arrow_forward_rounded,
                      gradient: AppGradients.mint,
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        Navigator.maybePop(context);
                      },
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                          begin: const Offset(1, 1),
                          end: const Offset(1.02, 1.02),
                          duration: 1500.ms,
                        ),

                    const SizedBox(height: 12),

                    // 5 more minutes button
                    SecondaryButton(
                      label: '5 More Minutes (used ${timesUsedToday}x today)',
                      icon: Icons.timer_rounded,
                      color: AppColors.alert,
                      onPressed: () => Navigator.maybePop(context),
                    ).animate(delay: 500.ms).fadeIn(duration: 300.ms),

                    const SizedBox(height: 16),

                    const Text(
                      'Your future self will thank you',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
