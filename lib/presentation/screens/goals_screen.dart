import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../providers/app_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_buttons.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final completedCount = goals.where((g) => g.isGoalMet).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Goals'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SecondaryButton(
              label: 'Add Goal',
              icon: Icons.add_rounded,
              color: AppColors.primary,
              onPressed: () => _showAddGoal(context),
            ),
          ),
        ],
      ),
      body: goals.isEmpty
          ? _EmptyGoals(onAdd: () => _showAddGoal(context))
          : CustomScrollView(
              slivers: [
                // Summary ring
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: GlassCard(
                      child: Row(
                        children: [
                          _CompletionRing(
                              completed: completedCount, total: goals.length),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Today's Goals",
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall),
                                const SizedBox(height: 4),
                                Text(
                                    '$completedCount of ${goals.length} completed',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                ),

                // Goals list
                SliverList.builder(
                  itemCount: goals.length,
                  itemBuilder: (context, i) {
                    final goal = goals[i];
                    return Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 0, 20, i < goals.length - 1 ? 10 : 0),
                      child: _GoalCard(goal: goal, index: i),
                    );
                  },
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
    );
  }

  void _showAddGoal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text('New Goal', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            const TextField(
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Goal Name',
                hintText: 'e.g., Limit Instagram to 30 min',
                prefixIcon: Icon(Icons.flag_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              style: TextStyle(color: AppColors.textPrimary),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Limit (minutes)',
                hintText: '30',
                prefixIcon:
                    Icon(Icons.timer_rounded, color: AppColors.secondary),
              ),
            ),
            const Spacer(),
            PrimaryButton(
              label: 'Create Goal',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  final int completed, total;
  const _CompletionRing({required this.completed, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total > 0 ? completed / total : 0.0;
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 6,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation(
              ratio >= 1.0 ? AppColors.success : AppColors.primary,
            ),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(ratio * 100).round()}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ratio >= 1.0 ? AppColors.success : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final dynamic goal;
  final int index;
  const _GoalCard({required this.goal, required this.index});

  @override
  Widget build(BuildContext context) {
    final current = goal.currentMinutes ?? 0;
    final target = goal.dailyLimitMinutes ?? 60;
    final ratio = (current / target).clamp(0.0, 1.2);
    final isCompleted = goal.isGoalMet;
    final streakDays = goal.streakDays ?? 0;

    // Dynamic color
    Color barColor;
    if (ratio <= 0.6) {
      barColor = AppColors.success;
    } else if (ratio <= 0.85) {
      barColor = AppColors.warning;
    } else {
      barColor = AppColors.alert;
    }

    return GlassCard(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      borderColor:
          isCompleted ? AppColors.success.withValues(alpha: 0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                  color: barColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.appName ?? 'Goal',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    Text('$current / $target minutes',
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Text(
                '${(ratio * 100).clamp(0, 100).round()}%',
                style: TextStyle(
                    color: barColor, fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 800),
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
                          gradient: LinearGradient(colors: [
                            barColor,
                            barColor.withValues(alpha: 0.6)
                          ]),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (streakDays > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.streak.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('🔥 $streakDays day streak',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.streak)),
              ),
            ),
        ],
      ),
    )
        .animate(delay: (100 + index * 60).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.03, end: 0);
  }
}

class _EmptyGoals extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGoals({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flag_rounded,
                  size: 48, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 24),
            Text('No Goals Yet',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Set daily limits for apps to stay on track.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            PrimaryButton(
                label: 'Add Your First Goal',
                icon: Icons.add_rounded,
                onPressed: onAdd),
          ],
        ).animate().fadeIn(delay: 200.ms),
      ),
    );
  }
}
