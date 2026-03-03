// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Settings'),
          leading: AppIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subscription card
              PressableCard(
                padding: const EdgeInsets.all(18),
                borderRadius: 18,
                borderColor: AppColors.primary.withValues(alpha: 0.3),
                onTap: () => context.push('/subscription'),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppGradients.hero,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const GradientText(
                            'Pro Plan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Active · Renews Mar 15',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    SecondaryButton(
                      label: 'Manage',
                      icon: Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      onPressed: () => context.push('/subscription'),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // General section
              const _SectionHeader(label: 'General', icon: Icons.tune_rounded),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _ToggleRow(
                    icon: Icons.dark_mode_rounded,
                    label: 'Dark Mode',
                    value: true,
                    onChanged: (_) {},
                  ),
                  _ToggleRow(
                    icon: Icons.notifications_rounded,
                    label: 'Notifications',
                    value: true,
                    onChanged: (_) {},
                  ),
                  _ToggleRow(
                    icon: Icons.vibration_rounded,
                    label: 'Haptic Feedback',
                    value: true,
                    onChanged: (_) {},
                  ),
                  _NavRow(
                    icon: Icons.language_rounded,
                    label: 'Language',
                    value: 'English',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Focus section
              const _SectionHeader(
                label: 'Focus',
                icon: Icons.gps_fixed_rounded,
              ),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _NavRow(
                    icon: Icons.timer_rounded,
                    label: 'Default Timer',
                    value: '25 min',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.music_note_rounded,
                    label: 'Default Sound',
                    value: 'Rain',
                    onTap: () {},
                  ),
                  _ToggleRow(
                    icon: Icons.do_not_disturb_rounded,
                    label: 'DND During Focus',
                    value: true,
                    onChanged: (_) {},
                  ),
                  _ToggleRow(
                    icon: Icons.fingerprint_rounded,
                    label: 'Biometric Lock',
                    value: false,
                    onChanged: (_) {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Data section
              const _SectionHeader(
                label: 'Data & Privacy',
                icon: Icons.shield_rounded,
              ),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _NavRow(
                    icon: Icons.download_rounded,
                    label: 'Export Data',
                    value: 'CSV',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.cloud_sync_rounded,
                    label: 'Cloud Sync',
                    value: 'Enabled',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.privacy_tip_rounded,
                    label: 'Privacy Policy',
                    value: '',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.description_rounded,
                    label: 'Terms of Service',
                    value: '',
                    onTap: () => context.push('/terms'),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // About section
              const _SectionHeader(
                label: 'About',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 10),
              _SettingsGroup(
                children: [
                  _NavRow(
                    icon: Icons.star_border_rounded,
                    label: 'Rate App',
                    value: '',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.feedback_outlined,
                    label: 'Send Feedback',
                    value: '',
                    onTap: () {},
                  ),
                  _NavRow(
                    icon: Icons.code_rounded,
                    label: 'Version',
                    value: '1.0.0 (42)',
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Danger zone
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                borderColor: AppColors.alert.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Danger Zone',
                      style: TextStyle(
                        color: AppColors.alert,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _NavRow(
                      icon: Icons.logout_rounded,
                      label: 'Sign Out',
                      value: '',
                      onTap: () {},
                      color: AppColors.alert,
                    ),
                    const SizedBox(height: 8),
                    _NavRow(
                      icon: Icons.delete_forever_rounded,
                      label: 'Delete Account',
                      value: '',
                      onTap: () {},
                      color: AppColors.alert,
                    ),
                  ],
                ),
              ).animate(delay: 500.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 8),
          GradientText(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      );
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        borderRadius: 16,
        child: Column(
          children: List.generate(children.length * 2 - 1, (i) {
            if (i.isOdd) {
              return const Divider(color: AppColors.cardBorder, height: 1);
            }
            return children[i ~/ 2];
          }),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomToggle(value: value, onChanged: onChanged),
          ],
        ),
      );
}

class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: color ?? AppColors.textSecondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textTertiary,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                color: (color ?? AppColors.textTertiary).withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
        ),
      );
}
