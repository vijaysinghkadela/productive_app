import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text("What's New",
              style: Theme.of(context).textTheme.headlineSmall)),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _release('2.0.0', 'Mar 2026', true, [
          _f('🧠', 'AI Coaching', 'Chat with Alex, your AI productivity coach'),
          _f('📝', 'Habits', 'Track daily habits with streaks and templates'),
          _f('⚔️', 'Challenges', 'Join community challenges and compete'),
          _f('📊', 'Leaderboard', 'See how you rank globally'),
          _f('🎵', 'Focus Sounds', 'Mix ambient sounds and binaural beats'),
          _f('📓', 'Journal', 'Daily reflection with mood tracking'),
          _f('🧘', 'Digital Wellbeing',
              'Screen budget, mindfulness, health reminders'),
          _f('🎯', 'Focus Modes', '8 context-aware profiles'),
          _f('🎁', 'Referral Program', 'Invite friends, earn free months'),
          _f('⭐', 'XP & Levels', 'Full gamification system'),
        ]),
        _release('1.0.0', 'Feb 2026', false, [
          _f('🚫', 'App Blocker', 'Block distracting apps'),
          _f('⏱️', 'Focus Sessions', 'Pomodoro timer with presets'),
          _f('📈', 'Analytics', 'Usage charts and productivity score'),
          _f('🏆', 'Achievements', 'Earn badges for milestones'),
          _f('🌙', 'Bedtime Mode', 'Auto-block at night'),
          _f('🤝', 'Accountability', 'Partner with friends'),
        ]),
      ]),
    );
  }

  Widget _release(
          String version, String date, bool isLatest, List<Widget> features) =>
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: isLatest
                ? AppColors.primary.withValues(alpha: 0.06)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: isLatest
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.cardBorder)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('v$version',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text(date,
                style: TextStyle(color: AppColors.textTertiary, fontSize: 13)),
            const Spacer(),
            if (isLatest)
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text('LATEST',
                      style: TextStyle(
                          color: AppColors.success,
                          fontSize: 10,
                          fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 16),
          ...features,
        ]),
      ).animate().fadeIn(duration: 400.ms);

  Widget _f(String icon, String title, String desc) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                Text(desc,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ])),
        ]),
      );
}
