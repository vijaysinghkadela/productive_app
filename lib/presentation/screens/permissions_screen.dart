// ignore_for_file: discarded_futures, use_named_constants
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  int _currentStep = 0;
  final List<bool> _granted = [false, false, false, false];

  static const _permissions = [
    _PermissionData(
      name: 'Usage Access',
      icon: Icons.analytics_rounded,
      description: 'Track which apps you use and for how long',
      benefit: 'Enables screen time tracking & productivity score',
      color: AppColors.primary,
    ),
    _PermissionData(
      name: 'Overlay Permission',
      icon: Icons.layers_rounded,
      description: 'Display focus reminders over other apps',
      benefit: 'Powers the distraction blocker nudges',
      color: AppColors.secondary,
    ),
    _PermissionData(
      name: 'Notifications',
      icon: Icons.notifications_rounded,
      description: 'Send you focus reminders and achievement alerts',
      benefit: 'Get smart nudges and streak warnings',
      color: AppColors.tertiary,
    ),
    _PermissionData(
      name: 'Battery Optimization',
      icon: Icons.battery_saver_rounded,
      description: 'Run in background to track app usage accurately',
      benefit: 'Ensures accurate all-day tracking',
      color: AppColors.success,
    ),
  ];

  void _grantPermission() {
    HapticFeedback.mediumImpact();
    setState(() {
      _granted[_currentStep] = true;
    });
    // Auto-advance after animation
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted && _currentStep < 3) {
        setState(() => _currentStep++);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final perm = _permissions[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.maybePop(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final isActive = i == _currentStep;
                  final isDone = _granted[i];
                  return Row(
                    children: [
                      AnimatedContainer(
                        duration: Anim.normal,
                        width: isActive ? 32 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient:
                              (isActive || isDone) ? AppGradients.hero : null,
                          color: (isActive || isDone)
                              ? null
                              : AppColors.surfaceLight,
                          boxShadow: isActive
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ]
                              : [],
                        ),
                        child: isDone && !isActive
                            ? const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 8,
                                ),
                              )
                            : null,
                      ),
                      if (i < 3)
                        Container(
                          width: 24,
                          height: 2,
                          color: isDone
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.surfaceLight,
                        ),
                    ],
                  );
                }),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              // Floating illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      perm.color.withValues(alpha: 0.15),
                      perm.color.withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(perm.icon, size: 56, color: perm.color),
              )
                  .animate(key: ValueKey(_currentStep))
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),

              const SizedBox(height: 24),

              // Permission card
              AnimatedSwitcher(
                duration: Anim.normal,
                child: _granted[_currentStep]
                    // Granted state
                    ? GlassCard(
                        key: ValueKey('granted_$_currentStep'),
                        padding: const EdgeInsets.all(24),
                        borderColor: AppColors.success.withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                gradient: AppGradients.mint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ).animate().scale(
                                  begin: const Offset(0, 0),
                                  end: const Offset(1, 1),
                                  duration: 400.ms,
                                  curve: Curves.elasticOut,
                                ),
                            const SizedBox(height: 12),
                            Text(
                              '${perm.name} Granted!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      )
                    // Request state
                    : ShimmerBorderCard(
                        key: ValueKey('request_$_currentStep'),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              perm.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              perm.description,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      perm.benefit,
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            PrimaryButton(
                              label: 'Grant ${perm.name}',
                              icon: perm.icon,
                              gradient: LinearGradient(
                                colors: [
                                  perm.color,
                                  perm.color.withValues(alpha: 0.7),
                                ],
                              ),
                              onPressed: _grantPermission,
                            ),
                          ],
                        ),
                      ),
              ),

              const Spacer(),

              // Continue button (shows when all granted or on last step)
              if (_granted.every((g) => g))
                PrimaryButton(
                  label: 'Continue to App',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.maybePop(context),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionData {
  const _PermissionData({
    required this.name,
    required this.icon,
    required this.description,
    required this.benefit,
    required this.color,
  });
  final String name;
  final String description;
  final String benefit;
  final IconData icon;
  final Color color;
}
