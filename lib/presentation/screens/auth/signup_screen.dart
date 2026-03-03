import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:focusguard_pro/presentation/widgets/particle_field.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  int _step = 0; // 0=email+pw, 1=name, 2=finish
  int _strengthLevel = 0; // 0-4

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _updateStrength(String pw) {
    var strength = 0;
    if (pw.length >= 6) strength++;
    if (pw.length >= 10) strength++;
    if (RegExp('[A-Z]').hasMatch(pw) && RegExp('[0-9]').hasMatch(pw)) {
      strength++;
    }
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw)) strength++;
    setState(() => _strengthLevel = strength);
  }

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_step < 2) {
      setState(() => _step++);
    } else {
      // Create account
      setState(() => _loading = true);
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) context.go('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strengthLabels = ['', 'Weak', 'Fair', 'Strong', 'Very Strong'];
    final strengthColors = [
      AppColors.textTertiary,
      AppColors.alert,
      AppColors.warning,
      AppColors.secondary,
      AppColors.success,
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const Positioned.fill(
            child: ParticleField(particleCount: 18, maxOpacity: 0.04),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      if (_step > 0)
                        AppIconButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: () => setState(() => _step--),
                        ),
                      const Spacer(),
                      // Step indicator
                      Row(
                        children: List.generate(3, (i) {
                          final isActive = i == _step;
                          final isDone = i < _step;
                          return Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: AnimatedContainer(
                              duration: Anim.normal,
                              width: isActive ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: (isActive || isDone)
                                    ? AppGradients.hero
                                    : null,
                                color: (isActive || isDone)
                                    ? null
                                    : AppColors.surfaceLight,
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Step content with animation
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: Anim.normal,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) => SlideTransition(
                        position: Tween(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: _step == 0
                          ? _Step1(
                              key: const ValueKey(0),
                              emailCtrl: _emailCtrl,
                              passCtrl: _passCtrl,
                              obscure: _obscure,
                              strengthLevel: _strengthLevel,
                              strengthLabel: strengthLabels[_strengthLevel],
                              strengthColor: strengthColors[_strengthLevel],
                              onToggleObscure: () =>
                                  setState(() => _obscure = !_obscure),
                              onPasswordChanged: _updateStrength,
                            )
                          : _step == 1
                              ? _Step2(
                                  key: const ValueKey(1),
                                  nameCtrl: _nameCtrl,
                                )
                              : const _Step3(key: ValueKey(2)),
                    ),
                  ),

                  // Next / Create button
                  PrimaryButton(
                    label: _step < 2 ? 'Continue' : 'Create Account',
                    icon: _step < 2
                        ? Icons.arrow_forward_rounded
                        : Icons.check_rounded,
                    isLoading: _loading,
                    onPressed: _loading ? null : _nextStep,
                  ),

                  if (_step == 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step1 extends StatelessWidget {
  const _Step1({
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.strengthLevel,
    required this.strengthLabel,
    required this.strengthColor,
    required this.onToggleObscure,
    required this.onPasswordChanged,
    super.key,
  });
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final int strengthLevel;
  final String strengthLabel;
  final Color strengthColor;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onPasswordChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Create Account',
              style: Theme.of(context).textTheme.displaySmall,),
          const SizedBox(height: 8),
          const Text(
            'Set up your email and password',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: passCtrl,
            obscureText: obscure,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: onToggleObscure,
                child: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
            onChanged: onPasswordChanged,
          ),
          const SizedBox(height: 12),
          // Password strength meter
          if (passCtrl.text.isNotEmpty) ...[
            Row(
              children: List.generate(
                4,
                (i) => Expanded(
                  child: AnimatedContainer(
                    duration: Anim.normal,
                    height: 4,
                    margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < strengthLevel
                          ? strengthColor
                          : AppColors.surfaceLight,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strengthLabel,
              style: TextStyle(
                color: strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      );
}

class _Step2 extends StatelessWidget {
  const _Step2({required this.nameCtrl, super.key});
  final TextEditingController nameCtrl;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Profile', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            'Choose a display name and avatar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Display Name',
              prefixIcon: Icon(
                Icons.person_outline_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose Avatar',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, i) {
                final colors = [
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.tertiary,
                  AppColors.success,
                  AppColors.warning,
                  AppColors.streak,
                  AppColors.primary,
                  AppColors.secondary,
                  AppColors.tertiary,
                  AppColors.success,
                ];
                final emojis = [
                  '🦊',
                  '🐼',
                  '🦁',
                  '🐸',
                  '🦉',
                  '🐙',
                  '🦄',
                  '🐺',
                  '🦅',
                  '🐯',
                ];
                return Padding(
                  padding: EdgeInsets.only(right: i < 9 ? 10 : 0),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colors[i].withValues(alpha: 0.2),
                          colors[i].withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: i == 0 ? colors[i] : AppColors.cardBorder,
                        width: i == 0 ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emojis[i],
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ).animate(delay: (i * 50).ms).scale(
                      begin: const Offset(0.7, 0.7),
                      duration: 300.ms,
                      curve: Curves.elasticOut,
                    );
              },
            ),
          ),
        ],
      );
}

class _Step3 extends StatelessWidget {
  const _Step3({super.key});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Almost Done!', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          const Text(
            'Just a few more things',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Get reminded to stay focused',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomToggle(value: true, onChanged: (_) {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.secondary,
                  size: 24,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Reports',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        'Receive productivity insights',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomToggle(value: true, onChanged: (_) {}),
              ],
            ),
          ),
        ],
      );
}
