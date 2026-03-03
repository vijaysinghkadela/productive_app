import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

class DetoxChallengeScreen extends StatelessWidget {
  const DetoxChallengeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            '7-Day Detox',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.12),
                      AppColors.accent.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Text('🧘', style: TextStyle(fontSize: 48)),
                    SizedBox(height: 12),
                    Text(
                      'Digital Detox Challenge',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '7 days. Transform your relationship with your phone.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 500.ms),
              const SizedBox(height: 20),
              ...List.generate(7, (i) => _dayCard(i + 1, i)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Start 7-Day Detox',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );

  Widget _dayCard(int day, int index) {
    final data = [
      {
        'title': 'Awareness Day',
        'task':
            'Track every phone pickup. Write down when and why you reached for it.',
        'time': '15 min reflection',
      },
      {
        'title': 'Notification Purge',
        'task':
            'Disable ALL non-essential notifications. Keep only calls and messages.',
        'time': '20 min setup',
      },
      {
        'title': 'Social Media Fast',
        'task':
            'Remove social media apps. Use FocusGuard to block web versions.',
        'time': 'All day',
      },
      {
        'title': 'Phone-Free Meals',
        'task':
            'No phone during any meal today. Be present with your food and people.',
        'time': '3 meals',
      },
      {
        'title': 'Morning Liberation',
        'task':
            'No phone for first 2 hours after waking. Start your day intentionally.',
        'time': '2 hours',
      },
      {
        'title': 'Digital Sunset',
        'task':
            'Put phone away 2 hours before bed. Read, journal, or meditate instead.',
        'time': 'Evening',
      },
      {
        'title': 'Full Detox',
        'task':
            'Phone stays off or in another room. Go phone-free for 12 hours!',
        'time': '12 hours',
      },
    ];
    final d = data[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.2),
                  AppColors.accent.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$day',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d['title']!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  d['task']!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      d['time']!,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 60));
  }
}
