// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:go_router/go_router.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('More', style: Theme.of(context).textTheme.displaySmall)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                const Text(
                  'Everything at your fingertips',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                // Quick access grid
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.05,
                  children: [
                    _tile(context, '👤', 'Profile', '/profile-page'),
                    _tile(context, '🧠', 'AI Coach', '/ai-coaching'),
                    _tile(context, '✅', 'Habits', '/habits'),
                    _tile(context, '⚔️', 'Challenges', '/challenges'),
                    _tile(context, '📓', 'Journal', '/journal'),
                    _tile(context, '🏆', 'Leaderboard', '/leaderboard'),
                    _tile(context, '🎵', 'Sounds', '/focus-music'),
                    _tile(context, '🎯', 'Focus Modes', '/focus-modes'),
                    _tile(context, '🏫', 'Spaces', '/focus-spaces'),
                  ],
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 20),
                // Feature sections
                const Text(
                  'Wellness & Growth',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _row(
                  context,
                  '🧘',
                  'Digital Wellbeing',
                  'Mindfulness, breaks, detox',
                  '/digital-wellbeing',
                ),
                _row(
                  context,
                  '🧘',
                  '7-Day Detox',
                  'Guided detox challenge',
                  '/detox-challenge',
                ),
                _row(
                  context,
                  '📊',
                  'Reports',
                  'Weekly & monthly insights',
                  '/reports',
                ),
                _row(
                  context,
                  '🔔',
                  'Notifications',
                  'Activity feed',
                  '/notifications-center',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Settings & Tools',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _row(
                  context,
                  '⚙️',
                  'Settings',
                  'App preferences',
                  '/settings-page',
                ),
                _row(
                  context,
                  '🔒',
                  'App Lock',
                  'PIN & biometric lock',
                  '/app-lock',
                ),
                _row(
                  context,
                  '💎',
                  'Subscription',
                  'Manage your plan',
                  '/subscription',
                ),
                _row(
                  context,
                  '📱',
                  'Home Widget',
                  'Configure widget',
                  '/widget-config',
                ),
                _row(
                  context,
                  '🎁',
                  'Refer & Earn',
                  'Invite friends',
                  '/referral',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Info',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _row(
                  context,
                  '❓',
                  'Help & Support',
                  'FAQ, contact, bug report',
                  '/support',
                ),
                _row(
                  context,
                  '🔐',
                  'Privacy Policy',
                  'Data & privacy info',
                  '/privacy-policy',
                ),
                _row(context, '🆕', "What's New", 'Changelog', '/changelog'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );

  Widget _tile(BuildContext context, String icon, String label, String route) =>
      GestureDetector(
        onTap: () => context.push(route),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _row(
    BuildContext context,
    String icon,
    String title,
    String desc,
    String route,
  ) =>
      GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      desc,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ),
        ),
      );
}
