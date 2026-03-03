import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class NotificationsCenterScreen extends StatelessWidget {
  const NotificationsCenterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('Notifications',
              style: Theme.of(context).textTheme.headlineSmall),
          actions: [
            TextButton(
                onPressed: () {},
                child: Text('Clear All',
                    style: TextStyle(color: AppColors.alert, fontSize: 13)))
          ]),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        _section(
            'Today',
            [
              _notif(
                  '🏆',
                  'Achievement Unlocked!',
                  'You earned "Week Warrior" badge',
                  '2m ago',
                  AppColors.warning),
              _notif('🛡️', 'App Blocked', 'Instagram was blocked during focus',
                  '1h ago', AppColors.alert),
              _notif(
                  '🎯',
                  'Goal Warning',
                  'You\'ve used TikTok for 25/30 min today',
                  '2h ago',
                  AppColors.warning),
            ],
            0),
        _section(
            'Yesterday',
            [
              _notif(
                  '🧠',
                  'AI Insight',
                  'Alex has a new weekly insight for you',
                  'Yesterday',
                  AppColors.accent),
              _notif('🔥', 'Streak Alert', 'Don\'t break your 5-day streak!',
                  'Yesterday', AppColors.success),
              _notif(
                  '👥',
                  'Partner Update',
                  'Sarah completed a 2h deep work session!',
                  'Yesterday',
                  AppColors.primary),
            ],
            3),
        _section(
            'This Week',
            [
              _notif(
                  '📊',
                  'Weekly Report',
                  'Your report is ready — 78/100 this week',
                  'Mon',
                  AppColors.primary),
              _notif('⚔️', 'Challenge Update', 'You\'re #127 in Focus Marathon',
                  'Sun', AppColors.accent),
            ],
            6),
      ]),
    );
  }

  Widget _section(String title, List<Widget> items, int offset) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...items,
        const SizedBox(height: 16),
      ]);

  Widget _notif(
          String icon, String title, String desc, String time, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(desc,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ])),
          Text(time,
              style: TextStyle(color: AppColors.textTertiary, fontSize: 10)),
        ]),
      ).animate().fadeIn(duration: 300.ms);
}
