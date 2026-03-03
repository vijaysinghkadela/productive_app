import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/utils.dart';
import 'package:focusguard_pro/presentation/providers/app_providers.dart';

class BedtimeScreen extends ConsumerWidget {
  const BedtimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bedtime Mode'),
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
            // Hero card
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
                          AppColors.accent.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.3),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.nightlight_rounded,
                      size: 40,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wind Down',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Automatically block distracting apps at bedtime to help you sleep better.',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05, end: 0),

            const SizedBox(height: 24),

            // Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.power_settings_new_rounded,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enable Bedtime Mode',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          settings.bedtimeModeEnabled ? 'Active' : 'Disabled',
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: settings.bedtimeModeEnabled,
                    onChanged: (v) {
                      hapticLight();
                      ref
                          .read(settingsProvider.notifier)
                          .updateBedtime(enabled: v);
                    },
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 16),

            // Schedule
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _TimeRow(
                    label: 'Bedtime',
                    time: settings.bedtimeStart,
                    icon: Icons.bedtime_rounded,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.bedtimeStart,
                      );
                      if (time != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateBedtime(start: time);
                      }
                    },
                  ),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  _TimeRow(
                    label: 'Wake up',
                    time: settings.bedtimeEnd,
                    icon: Icons.wb_sunny_rounded,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: settings.bedtimeEnd,
                      );
                      if (time != null) {
                        ref
                            .read(settingsProvider.notifier)
                            .updateBedtime(end: time);
                      }
                    },
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            Text(
              'During bedtime, these apps will be blocked:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: socialMediaApps
                  .take(6)
                  .map(
                    (app) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8,),
                      decoration: BoxDecoration(
                        color: AppColors.alert.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.alert.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Text(
                        app,
                        style: const TextStyle(
                            color: AppColors.alert, fontSize: 13,),
                      ),
                    ),
                  )
                  .toList(),
            ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.label,
    required this.time,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final TimeOfDay time;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              time.format(context),
              style: const TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      );
}
