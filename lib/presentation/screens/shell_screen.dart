// ignore_for_file: discarded_futures
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:go_router/go_router.dart';

class ShellScreen extends StatelessWidget {
  const ShellScreen({required this.child, super.key});
  final Widget child;

  static const _tabs = [
    _TabItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      path: '/home',
    ),
    _TabItem(
      icon: Icons.timer_outlined,
      activeIcon: Icons.timer_rounded,
      label: 'Focus',
      path: '/focus',
    ),
    _TabItem(
      icon: Icons.insights_outlined,
      activeIcon: Icons.insights_rounded,
      label: 'Stats',
      path: '/analytics',
    ),
    _TabItem(
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield_rounded,
      label: 'Block',
      path: '/blocker',
    ),
    _TabItem(
      icon: Icons.grid_view_outlined,
      activeIcon: Icons.grid_view_rounded,
      label: 'More',
      path: '/more',
    ),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (var i = 0; i < _tabs.length; i++) {
      if (location == _tabs[i].path) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0x18FFFFFF), Color(0x08FFFFFF)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorderLight),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40000000),
                    blurRadius: 24,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_tabs.length, (i) {
                  final tab = _tabs[i];
                  final isActive = i == current;
                  return _NavBarItem(
                    tab: tab,
                    isActive: isActive,
                    onTap: () {
                      if (i != current) {
                        HapticFeedback.selectionClick();
                        context.go(tab.path);
                      }
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });
  final _TabItem tab;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 56,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: Anim.normal,
                curve: Curves.easeInOut,
                child: Icon(
                  isActive ? tab.activeIcon : tab.icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              // Glowing dot indicator
              AnimatedContainer(
                duration: Anim.normal,
                width: isActive ? 6 : 0,
                height: isActive ? 6 : 0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.6),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: Anim.fast,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppColors.primary : AppColors.textTertiary,
                ),
                child: Text(tab.label),
              ),
            ],
          ),
        ),
      );
}
