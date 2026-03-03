import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Refer & Earn',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    const Text(
                      'Invite Friends, Earn Rewards',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share your code and earn free Pro months!',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'FOCUS-AB3X7K',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: AppColors.accent,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.share_rounded),
                        label: const Text(
                          'Share Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              // Rewards tiers
              _rewardTier(
                '3 Friends',
                '1 Month Pro Free',
                Icons.star_outline,
                AppColors.warning,
                true,
              ),
              _rewardTier(
                '10 Friends',
                '1 Month Elite Free',
                Icons.diamond_outlined,
                AppColors.accent,
                false,
              ),
              _rewardTier(
                '25 Friends',
                '3 Months Elite Free',
                Icons.emoji_events,
                AppColors.primary,
                false,
              ),
              const SizedBox(height: 20),
              // Progress
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Progress',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _progressStat('1', 'Invited'),
                        _progressStat('0', 'Signed Up'),
                        _progressStat('0', 'Rewards'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      );

  Widget _rewardTier(
    String friends,
    String reward,
    IconData icon,
    Color color,
    bool reached,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              reached ? color.withValues(alpha: 0.08) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                reached ? color.withValues(alpha: 0.3) : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friends,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    reward,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (reached)
              Icon(Icons.check_circle, color: color, size: 24)
            else
              const Icon(
                Icons.lock_outline,
                color: AppColors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 300.ms);

  Widget _progressStat(String value, String label) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      );
}
