// ignore_for_file: discarded_futures
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/utils.dart';
import 'package:focusguard_pro/presentation/providers/app_providers.dart';
import 'package:focusguard_pro/presentation/widgets/animated_score_ring.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final score = ref.watch(productivityScoreProvider);
    final timer = ref.watch(focusTimerProvider);
    final goals = ref.watch(goalsProvider);
    final quote =
        motivationalQuotes[DateTime.now().day % motivationalQuotes.length];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ──── FLOATING HEADER ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Avatar + greeting
                    GestureDetector(
                      onTap: () => context.push('/profile-page'),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppGradients.hero,
                              border: Border.all(
                                color: AppColors.cardBorderLight,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                (auth.user?.displayName ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, ${auth.user?.displayName.split(' ').first ?? 'User'} 👋',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                formatDate(DateTime.now()),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Streak badge
                    GestureDetector(
                      onTap: () => context.push('/achievements'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.streak.withValues(alpha: 0.15),
                              AppColors.streak.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.streak.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${auth.user?.streakDays ?? 0}',
                              style: const TextStyle(
                                color: AppColors.streak,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Notification bell
                    AppIconButton(
                      icon: Icons.notifications_none_rounded,
                      onPressed: () => context.push('/notifications-center'),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms),
              ),
            ),

            // ──── SCORE RING ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      context.push('/analytics');
                    },
                    child: AnimatedScoreRing(score: score),
                  ),
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 600.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.easeOut,
                  ),
            ),

            // ──── STATS ROW ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatMiniCard(
                      emoji: '🎯',
                      label: 'Focus Time',
                      value: formatDuration(
                        Duration(
                          minutes: timer.todaySessions
                              .where((s) => s.completed)
                              .fold(0, (sum, s) => sum + s.workMinutes),
                        ),
                      ),
                      color: AppColors.secondary,
                      onTap: () => context.go('/focus'),
                    ),
                    const SizedBox(width: 10),
                    _StatMiniCard(
                      emoji: '🚫',
                      label: 'Blocked',
                      value: '8',
                      color: AppColors.primary,
                      delay: 100,
                      onTap: () => context.go('/blocker'),
                    ),
                    const SizedBox(width: 10),
                    _StatMiniCard(
                      emoji: '✅',
                      label: 'Goals Met',
                      value:
                          '${goals.where((g) => g.isGoalMet).length}/${goals.length}',
                      color: AppColors.success,
                      delay: 200,
                      onTap: () => context.push('/goals'),
                    ),
                  ],
                ),
              ),
            ),

            // ──── FOCUS BUTTON ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: PressableCard(
                  glowColor: AppColors.primary,
                  onTap: () => context.go('/focus'),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppGradients.hero,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          size: 28,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Focus Session',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '25 min · Deep Work',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.04, end: 0),
            ),

            // ──── QUICK ACTIONS GRID (2×3) ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _QuickActionCard(
                          icon: Icons.shield_rounded,
                          label: 'Block Apps',
                          color: AppColors.secondary,
                          onTap: () => context.go('/blocker'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionCard(
                          icon: Icons.flag_rounded,
                          label: 'Set Goal',
                          color: AppColors.tertiary,
                          onTap: () => context.push('/goals'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionCard(
                          icon: Icons.insights_rounded,
                          label: 'Stats',
                          color: AppColors.warning,
                          onTap: () => context.go('/analytics'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _QuickActionCard(
                          icon: Icons.psychology_rounded,
                          label: 'AI Coach',
                          color: AppColors.success,
                          onTap: () => context.push('/ai-coaching'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionCard(
                          icon: Icons.emoji_events_rounded,
                          label: 'Challenge',
                          color: AppColors.streak,
                          onTap: () => context.push('/challenges'),
                        ),
                        const SizedBox(width: 10),
                        _QuickActionCard(
                          icon: Icons.spa_rounded,
                          label: 'Wellbeing',
                          color: AppColors.primary,
                          onTap: () => context.push('/digital-wellbeing'),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn(duration: 500.ms),
            ),

            // ──── SOCIAL MEDIA TODAY ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Social Media Today',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/analytics'),
                      child: const Text(
                        'See All →',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: min(6, socialMediaApps.length),
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final mins = [45, 30, 60, 20, 15, 10][i % 6];
                    const limit = 30;
                    final isOver = mins > limit;
                    return _SocialAppCard(
                      name: socialMediaApps[i],
                      minutes: mins,
                      limit: limit,
                      isOver: isOver,
                    );
                  },
                ),
              )
                  .animate(delay: 700.ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.05, end: 0),
            ),

            // ──── DAILY QUOTE ────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: GlassCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GradientText(
                        '❝',
                        style: TextStyle(fontSize: 32, height: 1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          quote,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    height: 1.6,
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn(duration: 500.ms),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

// ──── COMPONENTS ────

class _StatMiniCard extends StatelessWidget {
  const _StatMiniCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
    this.delay = 0,
    this.onTap,
  });
  final String emoji;
  final String label;
  final String value;
  final Color color;
  final int delay;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: PressableCard(
          padding: const EdgeInsets.all(14),
          borderRadius: 16,
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        )
            .animate(delay: (300 + delay).ms)
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, end: 0),
      );
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: PressableCard(
          padding: const EdgeInsets.symmetric(vertical: 18),
          borderRadius: 16,
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
}

class _SocialAppCard extends StatelessWidget {
  const _SocialAppCard({
    required this.name,
    required this.minutes,
    required this.limit,
    required this.isOver,
  });
  final String name;
  final int minutes;
  final int limit;
  final bool isOver;

  @override
  Widget build(BuildContext context) => Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (isOver ? AppColors.alert : AppColors.surfaceLight)
                  .withValues(alpha: isOver ? 0.15 : 0.5),
              (isOver ? AppColors.alert : AppColors.surfaceLight)
                  .withValues(alpha: isOver ? 0.05 : 0.2),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isOver ? AppColors.alert : AppColors.cardBorder)
                .withValues(alpha: isOver ? 0.3 : 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Center(
                    child: Text(
                      name[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                if (isOver)
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.alert,
                    size: 16,
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${minutes}m / ${limit}m',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOver ? AppColors.alert : AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
