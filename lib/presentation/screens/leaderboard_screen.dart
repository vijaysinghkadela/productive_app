import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedPeriod = 1; // Weekly default
  static const _periods = ['Today', 'Week', 'Month', 'All Time'];

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
                        'Leaderboard',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Period tabs
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Row(
                    children: List.generate(4, (i) {
                      final isActive = i == _selectedPeriod;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedPeriod = i);
                          },
                          child: AnimatedContainer(
                            duration: Anim.normal,
                            height: 36,
                            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            decoration: BoxDecoration(
                              gradient: isActive ? AppGradients.hero : null,
                              color: isActive ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                _periods[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
              ),

              // Top 3 Podium
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 220,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // #2
                        Expanded(
                          child: _PodiumItem(
                            rank: 2,
                            name: 'Sarah K.',
                            score: 8420,
                            height: 130,
                            color: Color(0xFFC0C0C0),
                            delay: 200,
                          ),
                        ),
                        SizedBox(width: 10),
                        // #1
                        Expanded(
                          child: _PodiumItem(
                            rank: 1,
                            name: 'Alex M.',
                            score: 9150,
                            height: 170,
                            color: AppColors.warning,
                            delay: 0,
                            isWinner: true,
                          ),
                        ),
                        SizedBox(width: 10),
                        // #3
                        Expanded(
                          child: _PodiumItem(
                            rank: 3,
                            name: 'Jordan C.',
                            score: 7890,
                            height: 100,
                            color: Color(0xFFCD7F32),
                            delay: 400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Your rank card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: ShimmerBorderCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: AppGradients.hero,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              '#127',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'You',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.hero,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'YOU',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Score: 5,420',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '↑ 12',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
              ),

              // Full list
              SliverList.builder(
                itemCount: 20,
                itemBuilder: (context, i) {
                  final rank = i + 4;
                  final rng = Random(rank);
                  final score = 7500 - (i * 250 + rng.nextInt(100));
                  final names = [
                    'Emma R.',
                    'Liam S.',
                    'Olivia T.',
                    'Noah B.',
                    'Ava P.',
                    'Mason D.',
                    'Sophia L.',
                    'Lucas K.',
                    'Mia W.',
                    'Ethan G.',
                    'Isabella F.',
                    'Logan V.',
                    'Charlotte N.',
                    'James H.',
                    'Amelia Q.',
                    'Benjamin Y.',
                    'Harper Z.',
                    'Elijah X.',
                    'Evelyn J.',
                    'William A.',
                  ];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, i < 19 ? 6 : 0),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 28,
                            child: Text(
                              '#$rank',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.surfaceLight,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                names[i][0],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              names[i],
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Text(
                            '$score',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(delay: (600 + i * 30).ms)
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.02, end: 0),
                  );
                },
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      );
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.height,
    required this.color,
    required this.delay,
    this.isWinner = false,
  });
  final int rank;
  final String name;
  final int score;
  final double height;
  final Color color;
  final int delay;
  final bool isWinner;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Crown for #1
          if (isWinner) const Text('👑', style: TextStyle(fontSize: 24)),
          if (isWinner) const SizedBox(height: 4),
          // Avatar
          Container(
            width: isWinner ? 64 : 48,
            height: isWinner ? 64 : 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isWinner
                  ? const LinearGradient(
                      colors: [AppColors.warning, Color(0xFFFF6B35)],
                    )
                  : null,
              color: isWinner ? null : AppColors.surfaceLight,
              border: Border.all(color: color, width: 2.5),
              boxShadow: isWinner
                  ? [
                      BoxShadow(
                        color: AppColors.warning.withValues(alpha: 0.4),
                        blurRadius: 16,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                name[0],
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: isWinner ? 24 : 18,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            '$score pts',
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          // Pedestal
          Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontSize: isWinner ? 32 : 24,
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        ],
      )
          .animate(delay: (200 + delay).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
}
