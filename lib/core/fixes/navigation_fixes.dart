import 'package:flutter/material.dart';

class NavigationFixes extends StatelessWidget {
  const NavigationFixes({super.key});

  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: () => _safeNavigation(context),
        child: const Text('Navigate'),
      );

  // FIX 23: Navigator used after context disposed
  Future<void> _safeNavigation(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2));

    // FIXED:
    if (!context.mounted) return;
    Navigator.pushNamed(context, '/next');
  }
}

// FIX 24: go_router navigation in build phase
class BuildPhaseNavigation extends StatelessWidget {
  const BuildPhaseNavigation({required this.isLoggedIn, super.key});
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      // FIXED: Use post frame callbacks rather than routing inside the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Conceptually: if (context.mounted) context.go('/login');
      });
      return const SizedBox.shrink();
    }
    return const Scaffold(body: Text('Home Screen'));
  }
}

// FIX 25: Missing route guards concept:
/*
  GoRoute(
    path: '/analytics',
    redirect: (context, state) {
      final isAuth = ref.read(authStateProvider).valueOrNull != null;
      if (!isAuth) return '/login?redirect=${state.uri}';
      return null;
    },
    builder: (_, __) => const AnalyticsScreen(),
  )
*/
