import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';
import '../../core/utils.dart';

/// Animated gradient header with glassmorphism
class GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final List<Color> colors;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const GradientHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.colors = const [AppColors.primary, AppColors.accent],
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.map((c) => c.withValues(alpha: 0.15)).toList(),
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.first.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          if (icon != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.first.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: colors.first, size: 28),
            ),
          if (icon != null) const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
          if (onActionTap != null)
            IconButton(
              onPressed: onActionTap,
              icon: Icon(actionIcon ?? Icons.arrow_forward_rounded,
                  color: colors.first),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

/// Animated stat card with icon and value
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? changeText;
  final bool? isPositiveChange;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color = AppColors.primary,
    this.changeText,
    this.isPositiveChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                if (changeText != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (isPositiveChange == true
                              ? AppColors.success
                              : AppColors.alert)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      changeText!,
                      style: TextStyle(
                        color: isPositiveChange == true
                            ? AppColors.success
                            : AppColors.alert,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

/// Animated progress bar with label
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final Color? backgroundColor;
  final double height;
  final String? label;
  final String? trailingText;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color = AppColors.primary,
    this.backgroundColor,
    this.height = 8,
    this.label,
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null || trailingText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(label!, style: Theme.of(context).textTheme.bodySmall),
                if (trailingText != null)
                  Text(trailingText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w600,
                          )),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                Container(color: backgroundColor ?? AppColors.surfaceLight),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty state placeholder widget
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_rounded,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }
}

/// Premium badge indicator
class PremiumBadge extends StatelessWidget {
  final String tier;
  final double size;

  const PremiumBadge({super.key, required this.tier, this.size = 24});

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (tier) {
      'elite' => (const Color(0xFFFFD700), Icons.diamond_rounded),
      'pro' => (AppColors.accent, Icons.star_rounded),
      'basic' => (AppColors.primary, Icons.verified_rounded),
      _ => (AppColors.textTertiary, Icons.lock_rounded),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

/// Shimmer loading placeholder
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 1200.ms,
        color: AppColors.surfaceLight.withValues(alpha: 0.3));
  }
}

/// Streak fire indicator
class StreakIndicator extends StatelessWidget {
  final int streak;
  final double size;

  const StreakIndicator({super.key, required this.streak, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF6B35).withValues(alpha: 0.2),
            const Color(0xFFFF4444).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: size * 0.5)),
          const SizedBox(width: 4),
          Text('$streak',
              style: TextStyle(
                color: const Color(0xFFFF6B35),
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
              )),
        ],
      ),
    );
  }
}
