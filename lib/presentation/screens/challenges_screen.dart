// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () => Navigator.maybePop(context),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Challenges',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Featured challenge banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF00D4FF),
                          Color(0xFF0D1225),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorderLight),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '🏆 FEATURED',
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '7-Day Digital Detox',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '5 days remaining',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '12,483 participants',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: 0.43,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.1),
                            valueColor:
                                const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 100.ms)
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.03, end: 0),
              ),

              // Live counter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.5),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '12,483 people active right now',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Challenge list
              SliverList.builder(
                itemCount: _challenges.length,
                itemBuilder: (context, i) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    i < _challenges.length - 1 ? 10 : 0,
                  ),
                  child: _ChallengeCard(challenge: _challenges[i], index: i),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      );
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({required this.challenge, required this.index});
  final _ChallengeData challenge;
  final int index;

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.all(18),
        borderRadius: 18,
        child: Row(
          children: [
            // Color accent bar
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    challenge.color,
                    challenge.color.withValues(alpha: 0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _InfoPill(
                        icon: Icons.people_outline_rounded,
                        label: challenge.participants,
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        icon: Icons.timer_outlined,
                        label: challenge.duration,
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: challenge.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          challenge.difficulty,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: challenge.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Join button
            if (!challenge.joined)
              SecondaryButton(
                label: 'Join',
                icon: Icons.add_rounded,
                color: challenge.color,
                onPressed: () {},
              )
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Joined',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      )
          .animate(delay: (200 + index * 60).ms)
          .fadeIn(duration: 300.ms)
          .slideY(begin: 0.03, end: 0);
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textTertiary),
          ),
        ],
      );
}

class _ChallengeData {
  const _ChallengeData({
    required this.name,
    required this.description,
    required this.participants,
    required this.duration,
    required this.difficulty,
    required this.color,
    this.joined = false,
  });
  final String name;
  final String description;
  final String participants;
  final String duration;
  final String difficulty;
  final Color color;
  final bool joined;
}

const _challenges = [
  _ChallengeData(
    name: 'No Social Sunday',
    description: 'Zero social media usage every Sunday for 4 weeks',
    participants: '8.2K',
    duration: '4 weeks',
    difficulty: 'Medium',
    color: AppColors.primary,
    joined: true,
  ),
  _ChallengeData(
    name: 'Morning Focus Sprint',
    description: 'Complete a 45-min focus session before 9 AM daily',
    participants: '5.1K',
    duration: '2 weeks',
    difficulty: 'Hard',
    color: AppColors.tertiary,
  ),
  _ChallengeData(
    name: '100 Hour Focus',
    description: 'Accumulate 100 hours of focused work this month',
    participants: '3.8K',
    duration: '1 month',
    difficulty: 'Expert',
    color: AppColors.warning,
  ),
  _ChallengeData(
    name: 'Habit Streak 21',
    description: 'Complete all daily habits for 21 consecutive days',
    participants: '12.4K',
    duration: '21 days',
    difficulty: 'Medium',
    color: AppColors.success,
  ),
  _ChallengeData(
    name: 'Digital Minimalist',
    description: 'Reduce total screen time by 50% for one week',
    participants: '6.7K',
    duration: '1 week',
    difficulty: 'Hard',
    color: AppColors.secondary,
  ),
];
