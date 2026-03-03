import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/utils.dart';
import 'package:share_plus/share_plus.dart';

class AccountabilityScreen extends StatelessWidget {
  const AccountabilityScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Accountability'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Invite card
              GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.warning.withValues(alpha: 0.3),
                            AppColors.success.withValues(alpha: 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people_rounded,
                        size: 40,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Accountability Partner',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share your progress with a friend and stay motivated together.',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Share.share(
                            'Join me on FocusGuard! Track your productivity and stay focused. focusguard://invite/abc123',
                          );
                        },
                        icon: const Icon(Icons.share_rounded),
                        label: const Text('Invite Friend'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 24),

              // Leaderboard
              Text(
                'Weekly Leaderboard',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              ..._buildLeaderboard(context),

              const SizedBox(height: 24),

              // Weekly report
              Text(
                'Shared Reports',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.article_rounded,
                      color: AppColors.textTertiary,
                      size: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No shared reports yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Invite a friend to start sharing weekly progress reports.',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      );

  List<Widget> _buildLeaderboard(BuildContext context) {
    final entries = [
      ('You', 5, 78),
      ('Alex M.', 7, 85),
      ('Sarah K.', 3, 62),
    ];

    return entries.asMap().entries.map((entry) {
      final i = entry.key;
      final data = entry.value;
      final medals = ['🥇', '🥈', '🥉'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: i == 0
                ? AppColors.warning.withValues(alpha: 0.08)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: i == 0
                  ? AppColors.warning.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Text(medals[i], style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.$1,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${data.$2} day streak',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getScoreColor(data.$3).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${data.$3}',
                  style: TextStyle(
                    color: getScoreColor(data.$3),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate(delay: Duration(milliseconds: 200 + i * 100))
          .fadeIn(duration: 400.ms);
    }).toList();
  }
}
