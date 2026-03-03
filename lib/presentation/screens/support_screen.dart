import 'package:flutter/material.dart';
import 'package:focusguard_pro/core/constants.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Help & Support',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _section('Quick Help', [
              _faq(
                'How does app blocking work?',
                'FocusGuard uses Android UsageStatsManager and iOS Family Controls to detect when you open blocked apps and displays a motivational overlay encouraging you to get back to work.',
              ),
              _faq(
                'How is my productivity score calculated?',
                'Your score starts at 100 and deducts points for going over screen time goals, while adding points for focus sessions, habit completions, streaks, and social-media-free days.',
              ),
              _faq(
                'Can I use FocusGuard offline?',
                'Yes! All core features work offline. Data syncs to the cloud when you reconnect. Some features like AI coaching require internet.',
              ),
              _faq(
                'How do I cancel my subscription?',
                'Go to Settings → Subscription → Manage. You can also cancel through Apple App Store or Google Play Store subscription management.',
              ),
              _faq(
                'Is my data private?',
                'Absolutely. App usage data is processed locally on your device. We never sell data to third parties. See our Privacy Policy for details.',
              ),
            ]),
            const SizedBox(height: 20),
            _section('Contact', [
              _contactOption(
                '📧',
                'Email Support',
                'support@focusguard.app',
                AppColors.primary,
              ),
              _contactOption(
                '💬',
                'Live Chat',
                'Available for Elite users',
                AppColors.accent,
              ),
              _contactOption(
                '🐛',
                'Report a Bug',
                'Help us improve',
                AppColors.alert,
              ),
              _contactOption(
                '💡',
                'Feature Request',
                'Tell us what you want',
                AppColors.success,
              ),
            ]),
            const SizedBox(height: 20),
            _section('Community', [
              _contactOption(
                '💬',
                'Discord Community',
                'Join 5,000+ members',
                AppColors.primary,
              ),
              _contactOption(
                '🐦',
                'Twitter',
                '@FocusGuardApp',
                AppColors.accent,
              ),
            ]),
          ],
        ),
      );

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      );

  Widget _faq(String q, String a) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: ExpansionTile(
          title: Text(
            q,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textTertiary,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text(
              a,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      );

  Widget _contactOption(String icon, String title, String desc, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
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
      );
}
