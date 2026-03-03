import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/domain/entities/focus_mode.dart';

class FocusModesScreen extends StatefulWidget {
  const FocusModesScreen({super.key});
  @override
  State<FocusModesScreen> createState() => _FocusModesScreenState();
}

class _FocusModesScreenState extends State<FocusModesScreen> {
  String? _activeModeId;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Focus Modes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_rounded, color: AppColors.primary),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active mode banner
              if (_activeModeId != null) _activeBanner(),
              const Text(
                'Choose a mode to match your activity',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 20),
              const Text(
                'Built-in Modes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...builtInFocusModes
                  .asMap()
                  .entries
                  .map((e) => _modeCard(e.value, e.key)),
              const SizedBox(height: 20),
              const Text(
                'Custom Modes',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _emptyCustom(),
            ],
          ),
        ),
      );

  Widget _activeBanner() {
    final mode = builtInFocusModes.firstWhere(
      (m) => m.id == _activeModeId,
      orElse: () => builtInFocusModes[0],
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.success.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(mode.icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${mode.name} Active',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Notifications: ${mode.notificationFilter}',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _activeModeId = null),
            child: const Text(
              'Stop',
              style: TextStyle(color: AppColors.alert, fontSize: 13),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _modeCard(FocusMode mode, int index) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _activeModeId == mode.id
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _activeModeId == mode.id
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    mode.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.notifications_off_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mode.notificationFilter == 'none'
                              ? 'Silent'
                              : mode.notificationFilter == 'calls_only'
                                  ? 'Calls only'
                                  : 'All',
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
              GestureDetector(
                onTap: () => setState(
                  () =>
                      _activeModeId = _activeModeId == mode.id ? null : mode.id,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _activeModeId == mode.id
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _activeModeId == mode.id ? 'Active' : 'Start',
                    style: TextStyle(
                      color: _activeModeId == mode.id
                          ? AppColors.success
                          : AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 60));

  Widget _emptyCustom() => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.cardBorder,
          ),
        ),
        child: const Column(
          children: [
            Icon(Icons.tune_rounded, size: 40, color: AppColors.textTertiary),
            SizedBox(height: 12),
            Text(
              'No custom modes yet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              'Create modes tailored to your activities',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 500.ms, duration: 400.ms);
}
