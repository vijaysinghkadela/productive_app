import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text('Reset Password',
                      style: Theme.of(context).textTheme.displaySmall)
                  .animate()
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Enter your email and we\'ll send you a link to reset your password.',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
              const SizedBox(height: 40),
              if (!_sent) ...[
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppColors.textTertiary),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (validateEmail(_emailController.text) == null) {
                        setState(() => _sent = true);
                      }
                    },
                    child: const Text('Send Reset Link',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 48),
                      const SizedBox(height: 16),
                      Text('Email Sent!',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        'Check your inbox for a password reset link.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .scale(begin: const Offset(0.95, 0.95)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Back to Sign In',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
