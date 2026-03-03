import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_buttons.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final weekday = now.weekday; // 1=Mon

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Habits'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // 7-Day Circle Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: GlassCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final isToday = i + 1 == weekday;
                    final isPast = i + 1 < weekday;
                    return Column(
                      children: [
                        Text(days[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isToday
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
                            )),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: Anim.normal,
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isPast ? AppGradients.hero : null,
                            color: isToday
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surfaceLight,
                            border: isToday
                                ? Border.all(color: AppColors.primary, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: isPast
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 18)
                                : Text(
                                    '${now.day - weekday + i + 1}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.textTertiary,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // Streak cards
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SizedBox(
                height: 95,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _StreakCard(
                        emoji: '🔥',
                        label: 'Current Streak',
                        value: '12 days',
                        color: AppColors.streak),
                    const SizedBox(width: 10),
                    _StreakCard(
                        emoji: '🏆',
                        label: 'Best Streak',
                        value: '28 days',
                        color: AppColors.warning),
                    const SizedBox(width: 10),
                    _StreakCard(
                        emoji: '⚡',
                        label: 'This Week',
                        value: '5/7',
                        color: AppColors.secondary),
                  ],
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            ),
          ),

          // Section header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text("Today's Habits",
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
          ),

          // Habits list
          SliverList.builder(
            itemCount: _sampleHabits.length,
            itemBuilder: (context, i) {
              final h = _sampleHabits[i];
              return Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 0, 20, i < _sampleHabits.length - 1 ? 10 : 0),
                child: _HabitCard(habit: h, index: i),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.hero,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.elevatedGlow(AppColors.primary),
        ),
        child: FloatingActionButton.extended(
          onPressed: () {},
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('New Habit',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String emoji, label, value;
  final Color color;

  const _StreakCard(
      {required this.emoji,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.12),
            color.withValues(alpha: 0.04)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _HabitCard extends StatefulWidget {
  final _HabitData habit;
  final int index;
  const _HabitCard({required this.habit, required this.index});

  @override
  State<_HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<_HabitCard>
    with SingleTickerProviderStateMixin {
  late bool _completed;
  late final AnimationController _checkCtrl;

  @override
  void initState() {
    super.initState();
    _completed = widget.habit.completed;
    _checkCtrl = AnimationController(
        vsync: this, duration: Anim.normal, value: _completed ? 1.0 : 0.0);
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() {
      _completed = !_completed;
      if (_completed) {
        _checkCtrl.forward();
      } else {
        _checkCtrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: _completed ? AppColors.success.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          // Animated checkbox
          GestureDetector(
            onTap: _toggle,
            child: AnimatedBuilder(
              animation: _checkCtrl,
              builder: (context, _) {
                final t = _checkCtrl.value;
                return Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: t > 0.5 ? AppGradients.mint : null,
                    color: t <= 0.5 ? AppColors.surfaceLight : null,
                    border: Border.all(
                      color: Color.lerp(
                          AppColors.cardBorderLight, AppColors.success, t)!,
                      width: 1.5,
                    ),
                  ),
                  child: t > 0.3
                      ? Icon(Icons.check_rounded,
                          size: 18, color: Colors.white.withValues(alpha: t))
                      : null,
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.habit.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration:
                          _completed ? TextDecoration.lineThrough : null,
                      color: _completed
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                    )),
                if (widget.habit.streak > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('🔥 ${widget.habit.streak} day streak',
                        style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.streak,
                            fontWeight: FontWeight.w500)),
                  ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.habit.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.habit.icon, color: widget.habit.color, size: 20),
          ),
        ],
      ),
    )
        .animate(delay: (100 + widget.index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.02, end: 0);
  }
}

class _HabitData {
  final String name;
  final int streak;
  final IconData icon;
  final Color color;
  final bool completed;
  const _HabitData(
      {required this.name,
      required this.streak,
      required this.icon,
      required this.color,
      this.completed = false});
}

const _sampleHabits = [
  _HabitData(
      name: 'No phone first 30 min',
      streak: 12,
      icon: Icons.phone_disabled_rounded,
      color: AppColors.primary,
      completed: true),
  _HabitData(
      name: 'Morning focus session',
      streak: 8,
      icon: Icons.wb_sunny_rounded,
      color: AppColors.warning),
  _HabitData(
      name: 'Exercise 30 min',
      streak: 5,
      icon: Icons.fitness_center_rounded,
      color: AppColors.success),
  _HabitData(
      name: 'Read 20 pages',
      streak: 3,
      icon: Icons.auto_stories_rounded,
      color: AppColors.secondary),
  _HabitData(
      name: 'Digital sunset at 9 PM',
      streak: 15,
      icon: Icons.dark_mode_rounded,
      color: AppColors.tertiary),
  _HabitData(
      name: 'Meditate 10 min',
      streak: 7,
      icon: Icons.spa_rounded,
      color: AppColors.primary),
];
