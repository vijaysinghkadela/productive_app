import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});
  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  bool _pinEnabled = false;
  bool _biometricEnabled = false;
  bool _lockOnExit = true;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'App Lock',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      AppColors.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Protect Your Progress',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Prevent others from disabling your focus settings',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 24),
              _toggle(
                '🔢',
                'PIN Lock',
                'Require 4-digit PIN to open FocusGuard',
                _pinEnabled,
                (v) => setState(() => _pinEnabled = v),
              ),
              _toggle(
                '🔐',
                'Biometric Lock',
                'Use fingerprint or face to unlock',
                _biometricEnabled,
                (v) => setState(() => _biometricEnabled = v),
              ),
              _toggle(
                '🔄',
                'Lock on Exit',
                'Re-lock when app goes to background',
                _lockOnExit,
                (v) => setState(() => _lockOnExit = v),
              ),
              const SizedBox(height: 20),
              if (_pinEnabled) ...[
                const Text(
                  'Change PIN',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _pinInput(),
                const SizedBox(height: 20),
              ],
              // Strict mode
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.alert.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.alert.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.gpp_good_rounded,
                      color: AppColors.alert,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strict Mode',
                            style: TextStyle(
                              color: AppColors.alert,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Once activated, you cannot disable blocking until the timer ends. Use with caution!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      );

  Widget _toggle(
    String icon,
    String title,
    String desc,
    bool value,
    ValueChanged<bool> onChanged,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.success,
            ),
          ],
        ),
      );

  Widget _pinInput() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          4,
          (i) => Container(
            width: 52,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: const Center(
              child: Text(
                '•',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                ),
              ),
            ),
          ),
        ),
      );
}
