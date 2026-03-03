import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:go_router/go_router.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final Map<String, bool> _permissions = {
    'Usage Access': false,
    'Overlay Permission': false,
    'Notifications': false,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Permissions',
                  style: Theme.of(context).textTheme.displaySmall,
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: 8),
                Text(
                  'FocusGuard needs a few permissions to protect your focus.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 40),
                _PermissionTile(
                  icon: Icons.bar_chart_rounded,
                  title: 'Usage Access',
                  description:
                      'Track which apps you use and for how long to provide accurate analytics.',
                  granted: _permissions['Usage Access']!,
                  onRequest: () => _grantPermission('Usage Access'),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                _PermissionTile(
                  icon: Icons.layers_rounded,
                  title: 'Overlay Permission',
                  description:
                      'Show a focus reminder when you open a blocked app.',
                  granted: _permissions['Overlay Permission']!,
                  onRequest: () => _grantPermission('Overlay Permission'),
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
                const SizedBox(height: 16),
                _PermissionTile(
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  description:
                      'Get smart nudges, focus reminders, and progress updates.',
                  granted: _permissions['Notifications']!,
                  onRequest: () => _grantPermission('Notifications'),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.1, end: 0),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => context.go('/login'),
                    child:
                        const Text('Continue', style: TextStyle(fontSize: 18)),
                  ),
                ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'I\'ll set up later',
                      style: TextStyle(color: AppColors.textTertiary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void _grantPermission(String permission) {
    setState(() => _permissions[permission] = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$permission granted ✓'),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.granted,
    required this.onRequest,
  });
  final IconData icon;
  final String title;
  final String description;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: granted
              ? AppColors.success.withValues(alpha: 0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: granted
                ? AppColors.success.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: granted
                    ? AppColors.success.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                granted ? Icons.check_rounded : icon,
                color: granted ? AppColors.success : AppColors.primary,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!granted)
              TextButton(
                onPressed: onRequest,
                child: const Text('Grant'),
              ),
          ],
        ),
      );
}
