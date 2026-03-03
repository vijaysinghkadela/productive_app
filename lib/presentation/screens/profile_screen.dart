import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../providers/app_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_buttons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Gradient hero header
          SliverToBoxAdapter(
            child: Container(
              height: 280,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1A1040), AppColors.background],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AppIconButton(
                              icon: Icons.arrow_back_rounded,
                              onPressed: () => Navigator.maybePop(context)),
                          AppIconButton(
                              icon: Icons.settings_rounded,
                              onPressed: () => context.push('/settings')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Avatar
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppGradients.hero,
                        border: Border.all(
                            color: AppColors.cardBorderLight, width: 3),
                        boxShadow: AppShadows.elevatedGlow(AppColors.primary),
                      ),
                      child: Center(
                        child: Text(
                          (user?.displayName ?? 'U')[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 38),
                        ),
                      ),
                    )
                        .animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                    const SizedBox(height: 12),
                    Text(user?.displayName ?? 'User',
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: AppGradients.hero,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('⚡ Level 12 · Focus Warrior',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Row(
                children: [
                  _StatCell(
                      value: '142h',
                      label: 'Focus Hours',
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  _StatCell(
                      value: '28',
                      label: 'Day Streak',
                      color: AppColors.streak),
                  const SizedBox(width: 10),
                  _StatCell(
                      value: '23',
                      label: 'Achievements',
                      color: AppColors.warning),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          ),

          // Badge showcase
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Badges',
                      style: Theme.of(context).textTheme.headlineSmall),
                  GestureDetector(
                    onTap: () => context.push('/achievements'),
                    child: Text('View All →',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _BadgeItem(
                      emoji: '🎯',
                      label: 'Sharp Focus',
                      color: AppColors.primary),
                  const SizedBox(width: 10),
                  _BadgeItem(
                      emoji: '🔥',
                      label: 'Streak Master',
                      color: AppColors.streak),
                  const SizedBox(width: 10),
                  _BadgeItem(
                      emoji: '🏆', label: 'Champion', color: AppColors.warning),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          ),

          // Recent Activity
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text('Recent Activity',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),
          SliverList.builder(
            itemCount: _recentActivity.length,
            itemBuilder: (context, i) {
              final activity = _recentActivity[i];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, i < _recentActivity.length - 1 ? 8 : 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 14,
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: activity.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(activity.icon,
                            color: activity.color, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(activity.title,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(activity.subtitle,
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      Text(activity.time,
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textTertiary)),
                    ],
                  ),
                ).animate(delay: (400 + i * 60).ms).fadeIn(duration: 300.ms),
              );
            },
          ),

          // Account actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                children: [
                  _ActionRow(
                      icon: Icons.share_rounded,
                      label: 'Share Profile',
                      color: AppColors.secondary,
                      onTap: () {}),
                  const SizedBox(height: 8),
                  _ActionRow(
                      icon: Icons.download_rounded,
                      label: 'Export Data',
                      color: AppColors.primary,
                      onTap: () {}),
                  const SizedBox(height: 8),
                  _ActionRow(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      color: AppColors.alert,
                      onTap: () {}),
                ],
              ),
            ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCell(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String emoji, label;
  final Color color;
  const _BadgeItem(
      {required this.emoji, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05)
                ]),
                shape: BoxShape.circle,
              ),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionRow(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressableCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: color))),
          Icon(Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }
}

class _ActivityData {
  final IconData icon;
  final String title, subtitle, time;
  final Color color;
  const _ActivityData(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.time,
      required this.color});
}

const _recentActivity = [
  _ActivityData(
      icon: Icons.timer_rounded,
      title: 'Focus Session Complete',
      subtitle: '45 min · Deep Work',
      time: '2h ago',
      color: AppColors.primary),
  _ActivityData(
      icon: Icons.emoji_events_rounded,
      title: 'Achievement Unlocked',
      subtitle: 'Marathon Focus — Rare',
      time: '4h ago',
      color: AppColors.warning),
  _ActivityData(
      icon: Icons.flag_rounded,
      title: 'Goal Met',
      subtitle: 'Instagram < 30 min',
      time: '6h ago',
      color: AppColors.success),
  _ActivityData(
      icon: Icons.local_fire_department_rounded,
      title: 'Streak Extended',
      subtitle: '28 days and counting!',
      time: 'Yesterday',
      color: AppColors.streak),
  _ActivityData(
      icon: Icons.shield_rounded,
      title: 'Blocked 12 Apps',
      subtitle: 'Social media + games',
      time: 'Yesterday',
      color: AppColors.secondary),
];
