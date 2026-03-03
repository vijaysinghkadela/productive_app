// ignore_for_file: discarded_futures
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class AppBlockerScreen extends ConsumerStatefulWidget {
  const AppBlockerScreen({super.key});

  @override
  ConsumerState<AppBlockerScreen> createState() => _AppBlockerScreenState();
}

class _AppBlockerScreenState extends ConsumerState<AppBlockerScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedCategory = 0;
  final Map<String, bool> _blocked = {};
  bool _focusModeActive = false;
  bool _strictMode = false;

  static const _categories = [
    'All',
    'Social',
    'Games',
    'Entertain',
    'Shopping',
    'News',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'App Blocker',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ).animate().fadeIn(duration: 300.ms),
              ),

              // Focus Mode Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: ShimmerBorderCard(
                    colors: _focusModeActive
                        ? [
                            AppColors.success,
                            AppColors.secondary,
                            AppColors.success,
                          ]
                        : [
                            AppColors.primary,
                            AppColors.secondary,
                            AppColors.primary,
                          ],
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _focusModeActive
                                ? AppGradients.mint
                                : AppGradients.hero,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            _focusModeActive
                                ? Icons.shield_rounded
                                : Icons.shield_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Focus Mode',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                _focusModeActive
                                    ? 'Active — blocking distractions'
                                    : 'Block all selected apps',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        CustomToggle(
                          value: _focusModeActive,
                          activeColor: AppColors.success,
                          onChanged: (v) =>
                              setState(() => _focusModeActive = v),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppColors.textTertiary,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
              ),

              // Category pills
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final isActive = i == _selectedCategory;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = i);
                          },
                          child: AnimatedContainer(
                            duration: Anim.normal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              gradient: isActive ? AppGradients.hero : null,
                              color: isActive ? null : AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isActive
                                    ? Colors.transparent
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _categories[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
              ),

              // App list
              SliverList.builder(
                itemCount: socialMediaApps.length,
                itemBuilder: (context, i) {
                  final app = socialMediaApps[i];
                  final isBlocked = _blocked[app] ?? false;
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      i < socialMediaApps.length - 1 ? 8 : 0,
                    ),
                    child: _AppBlockRow(
                      name: app,
                      isBlocked: isBlocked,
                      usage: '${45 - i * 3}m today',
                      onToggle: (v) => setState(() => _blocked[app] = v),
                      index: i,
                    ),
                  );
                },
              ),

              // Strict Mode Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: AccentCard(
                    color: AppColors.alert,
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.alert.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            color: AppColors.alert,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Strict Mode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                'Requires biometric to unblock',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        CustomToggle(
                          value: _strictMode,
                          activeColor: AppColors.alert,
                          onChanged: (v) => setState(() => _strictMode = v),
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      );
}

class _AppBlockRow extends StatelessWidget {
  const _AppBlockRow({
    required this.name,
    required this.usage,
    required this.isBlocked,
    required this.onToggle,
    required this.index,
  });
  final String name;
  final String usage;
  final bool isBlocked;
  final ValueChanged<bool> onToggle;
  final int index;

  @override
  Widget build(BuildContext context) => GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 14,
        borderColor:
            isBlocked ? AppColors.primary.withValues(alpha: 0.3) : null,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isBlocked ? AppGradients.hero : null,
                color: isBlocked ? null : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  name[0],
                  style: TextStyle(
                    color: isBlocked ? Colors.white : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(usage, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            CustomToggle(value: isBlocked, onChanged: onToggle),
          ],
        ),
      )
          .animate(delay: (150 + index * 40).ms)
          .fadeIn(duration: 300.ms)
          .slideX(begin: 0.02, end: 0);
}
