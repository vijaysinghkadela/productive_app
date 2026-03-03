import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

/// Paywall dialog — shown when a free user tries to access a premium feature
class PaywallDialog extends StatelessWidget {
  const PaywallDialog({required this.feature, super.key, this.onUpgrade});
  final String feature;
  final VoidCallback? onUpgrade;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.accent.withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.diamond_rounded,
                  color: AppColors.accent,
                  size: 40,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
              Text(
                'Unlock $feature',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Upgrade to Pro or Elite to access $feature and many more premium features.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const _PlanOption(
                label: 'Pro',
                price: r'$9.99/mo',
                color: AppColors.accent,
                features: [
                  'Unlimited blocks',
                  'All timers',
                  'Full analytics',
                  'Habits & challenges',
                ],
              ),
              const SizedBox(height: 12),
              const _PlanOption(
                label: 'Elite',
                price: r'$12.99/mo',
                color: Color(0xFFFFD700),
                features: [
                  'Everything in Pro',
                  'AI coaching',
                  'Strict mode',
                  'Priority support',
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onUpgrade ?? () => Navigator.pop(context),
                  child: const Text('Upgrade Now'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Maybe Later',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      );
}

class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.label,
    required this.price,
    required this.color,
    required this.features,
  });
  final String label;
  final String price;
  final Color color;
  final List<String> features;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        price,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...features.map(
                    (f) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: color, size: 14),
                          const SizedBox(width: 6),
                          Text(f, style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Achievement unlock dialog with confetti
class AchievementDialog extends StatelessWidget {
  const AchievementDialog({
    required this.name,
    required this.description,
    super.key,
    this.icon = '🏆',
    this.rarity = 'common',
    this.xpReward = 100,
  });
  final String name;
  final String description;
  final String icon;
  final String rarity;
  final int xpReward;

  Color get _rarityColor => switch (rarity) {
        'legendary' => const Color(0xFFFFD700),
        'epic' => const Color(0xFF9B59B6),
        'rare' => AppColors.accent,
        _ => AppColors.success,
      };

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Achievement Unlocked!',
                style: TextStyle(
                  color: _rarityColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(icon, style: const TextStyle(fontSize: 64))
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 16),
              Text(
                name,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _rarityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+$xpReward XP',
                  style: TextStyle(
                    color: _rarityColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Awesome!'),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Confirmation dialog for destructive actions
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.onConfirm,
    super.key,
    this.confirmLabel = 'Confirm',
    this.confirmColor = AppColors.alert,
  });
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmLabel),
          ),
        ],
      );
}
