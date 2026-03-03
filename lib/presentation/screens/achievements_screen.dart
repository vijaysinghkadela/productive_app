import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const level = 12;
    const xp = 2340;
    const xpForNext = (level + 1) * 500;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header: Level + XP bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppIconButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Achievements',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              Text(
                                'Level $level · Focus Warrior',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppGradients.hero,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '$xp XP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // XP Progress bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${xp % xpForNext} / $xpForNext XP to Level ${level + 1}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: (xp % xpForNext) / xpForNext,
                            ),
                            duration: const Duration(milliseconds: 1200),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => SizedBox(
                              height: 8,
                              child: Stack(
                                children: [
                                  Container(color: AppColors.surfaceLight),
                                  FractionallySizedBox(
                                    widthFactor: value,
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.hero,
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.5),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
            ),

            // Category tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: const [
                      _CategoryPill(label: 'All 🏆', isActive: true),
                      SizedBox(width: 8),
                      _CategoryPill(label: 'Focus 🎯'),
                      SizedBox(width: 8),
                      _CategoryPill(label: 'Streaks 🔥'),
                      SizedBox(width: 8),
                      _CategoryPill(label: 'Habits 💪'),
                      SizedBox(width: 8),
                      _CategoryPill(label: 'Social 🤝'),
                      SizedBox(width: 8),
                      _CategoryPill(label: 'Special ⭐'),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
            ),

            // Achievement grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemCount: _achievements.length,
                itemBuilder: (context, i) => _AchievementCard(
                  achievement: _achievements[i],
                  index: i,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, this.isActive = false});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: isActive ? AppGradients.hero : null,
          color: isActive ? null : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : AppColors.textTertiary,
            ),
          ),
        ),
      );
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement, required this.index});
  final _AchievementData achievement;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.unlocked;
    final rarity = achievement.rarity;
    final rarityColor = switch (rarity) {
      'Common' => AppColors.textTertiary,
      'Rare' => AppColors.secondary,
      'Epic' => AppColors.primary,
      'Legendary' => AppColors.warning,
      _ => AppColors.textTertiary,
    };

    Widget card = GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      borderColor: isUnlocked ? rarityColor.withValues(alpha: 0.3) : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      colors: [rarityColor, rarityColor.withValues(alpha: 0.6)],
                    )
                  : null,
              color: isUnlocked ? null : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  achievement.icon,
                  size: 28,
                  color: isUnlocked ? Colors.white : AppColors.textTertiary,
                ),
                if (!isUnlocked)
                  Icon(
                    Icons.lock_rounded,
                    size: 16,
                    color: AppColors.textTertiary.withValues(alpha: 0.5),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
                  isUnlocked ? AppColors.textPrimary : AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Rarity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rarity,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: rarityColor,
              ),
            ),
          ),
          if (!isUnlocked && achievement.progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: SizedBox(
                height: 4,
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: AppColors.surfaceLight,
                  valueColor: AlwaysStoppedAnimation(rarityColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Legendary: shimmer border
    if (isUnlocked && rarity == 'Legendary') {
      card = ShimmerBorderCard(
        padding: const EdgeInsets.all(16),
        colors: const [AppColors.warning, Colors.white, AppColors.warning],
        child: (card as GlassCard).child,
      );
    }

    return card
        .animate(delay: (100 + index * 60).ms)
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }
}

class _AchievementData {
  const _AchievementData({
    required this.name,
    required this.rarity,
    required this.icon,
    this.unlocked = false,
    this.progress,
  });
  final String name;
  final String rarity;
  final IconData icon;
  final bool unlocked;
  final double? progress;
}

const _achievements = [
  _AchievementData(
    name: 'First Focus',
    rarity: 'Common',
    icon: Icons.play_circle_rounded,
    unlocked: true,
  ),
  _AchievementData(
    name: 'Block Master',
    rarity: 'Common',
    icon: Icons.shield_rounded,
    unlocked: true,
  ),
  _AchievementData(
    name: 'Marathon Focus',
    rarity: 'Rare',
    icon: Icons.timer_rounded,
    unlocked: true,
  ),
  _AchievementData(
    name: 'Social Detox',
    rarity: 'Rare',
    icon: Icons.phone_disabled_rounded,
    unlocked: true,
  ),
  _AchievementData(
    name: 'Week Warrior',
    rarity: 'Epic',
    icon: Icons.local_fire_department_rounded,
    unlocked: true,
  ),
  _AchievementData(
    name: 'Score Perfectionist',
    rarity: 'Epic',
    icon: Icons.stars_rounded,
    progress: 0.7,
  ),
  _AchievementData(
    name: 'Habit Champion',
    rarity: 'Legendary',
    icon: Icons.emoji_events_rounded,
    progress: 0.35,
  ),
  _AchievementData(
    name: 'Focus Legend',
    rarity: 'Legendary',
    icon: Icons.auto_awesome_rounded,
    progress: 0.15,
  ),
];
