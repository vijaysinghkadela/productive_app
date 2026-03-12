// ignore_for_file: discarded_futures
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/services/stripe_service.dart';
import 'package:focusguard_pro/data/models/feature_models.dart';
import 'package:focusguard_pro/domain/entities/user.dart';
import 'package:focusguard_pro/presentation/providers/app_providers.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:focusguard_pro/presentation/widgets/particle_field.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearly = true;
  int _selectedPlan = 1; // Pro default

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const Positioned.fill(
              child: ParticleField(particleCount: 25, maxOpacity: 0.05),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topRight,
                      child: AppIconButton(
                        icon: Icons.close_rounded,
                        onPressed: () {
                          unawaited(Navigator.maybePop(context));
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Header
                    GradientText(
                      'Unlock Your\nFull Potential',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontWeight: FontWeight.w800, height: 1.1),
                      textAlign: TextAlign.center,
                    )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, end: 0),

                    const SizedBox(height: 8),
                    const Text(
                      'Join 250,000+ focused users',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 6),
                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ...List.generate(
                          5,
                          (_) =>
                              const Text('⭐', style: TextStyle(fontSize: 14)),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '4.9 App Store Rating',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ).animate(delay: 200.ms).fadeIn(),

                    const SizedBox(height: 24),

                    // Monthly/Yearly toggle
                    GlassCard(
                      padding: const EdgeInsets.all(4),
                      borderRadius: 14,
                      child: Row(
                        children: [
                          Expanded(
                            child: _TogglePill(
                              label: 'Monthly',
                              isActive: !_isYearly,
                              onTap: () => setState(() => _isYearly = false),
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _TogglePill(
                                  label: 'Yearly',
                                  isActive: _isYearly,
                                  onTap: () => setState(() => _isYearly = true),
                                ),
                                Positioned(
                                  top: -8,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.warning,
                                          Color(0xFFFF6B35),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'SAVE 40%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 20),

                    // Plan cards
                    ...List.generate(3, (i) {
                      final plans = [
                        const _PlanData(
                          name: 'Basic',
                          monthlyPrice: r'$5.99',
                          yearlyPrice: r'$3.59',
                          features: [
                            '25-min focus timer',
                            'Basic analytics',
                            '3 blocked apps',
                            'Standard sounds',
                          ],
                          color: AppColors.textTertiary,
                        ),
                        const _PlanData(
                          name: 'Pro',
                          monthlyPrice: r'$9.99',
                          yearlyPrice: r'$5.99',
                          features: [
                            'All timer presets',
                            'Full analytics',
                            'Unlimited app blocking',
                            'AI coaching (10/day)',
                            'Habits & challenges',
                            'All sounds',
                          ],
                          color: AppColors.primary,
                          badge: 'MOST POPULAR',
                        ),
                        const _PlanData(
                          name: 'Elite',
                          monthlyPrice: r'$12.99',
                          yearlyPrice: r'$7.99',
                          features: [
                            'Everything in Pro',
                            'Unlimited AI coaching',
                            'Focus Spaces',
                            'Strict mode',
                            'Priority support',
                            'Custom themes',
                          ],
                          color: AppColors.warning,
                          badge: 'BEST VALUE',
                        ),
                      ];
                      return Padding(
                        padding: EdgeInsets.only(bottom: i < 2 ? 12 : 0),
                        child: _PlanCard(
                          plan: plans[i],
                          isYearly: _isYearly,
                          isSelected: i == _selectedPlan,
                          onTap: () => setState(() => _selectedPlan = i),
                          index: i,
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // CTA
                    PrimaryButton(
                      label: 'Start 7-Day Free Trial',
                      icon: Icons.rocket_launch_rounded,
                      onPressed: _startStripeCheckout,
                    ).animate(delay: 700.ms).fadeIn(duration: 400.ms),

                    const SizedBox(height: 8),
                    const Text(
                      'No charge for 7 days. Cancel anytime.',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Trust badges
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TrustBadge(icon: Icons.lock_rounded, label: 'Secure'),
                        _TrustBadge(
                          icon: Icons.replay_rounded,
                          label: '7-Day Free',
                        ),
                        _TrustBadge(
                          icon: Icons.cancel_outlined,
                          label: 'Cancel Anytime',
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Restore Purchases',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _startStripeCheckout() async {
    try {
      final stripeService = ref.read(stripeServiceProvider);

      // Replace with secure runtime config before production release.
      const stripeKey = 'pk_test_placeholder';
      await stripeService.initStripe(stripeKey);

      // Maps to _selectedPlan (0: Basic, 1: Pro, 2: Elite)
      final planIds = ['basic', 'pro', 'elite'];
      final tierId = planIds[_selectedPlan];

      final checkoutResult =
          await stripeService.presentSubscriptionSheet(tierId);
      if (checkoutResult.success && mounted) {
        final currentUserId = ref.read(authProvider).user?.uid ?? 'local_user';
        final stripeCustomerId =
            checkoutResult.customerId ?? 'unknown_customer';

        final stripeSubscription = SubscriptionModel.stripe(
          userId: currentUserId,
          tier: tierId,
          stripeCustomerId: stripeCustomerId,
          stripeSubscriptionId: checkoutResult.subscriptionId,
          stripePriceId: checkoutResult.priceId,
          purchaseDate: DateTime.now(),
          isTrialActive: true,
          willRenew: true,
          metadata: <String, String>{
            'currencyCode': checkoutResult.currencyCode,
            'billingCycle': _isYearly ? 'yearly' : 'monthly',
            'checkoutProvider': 'stripe',
          },
        );

        ref.read(authProvider.notifier).updateTier(_tierFromId(tierId));

        debugPrint(
          'Stripe subscription payload: ${stripeSubscription.toJson()}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successful! Welcome aboard.'),
          ),
        );
        unawaited(Navigator.maybePop(context));
      } else if (mounted) {
        final message = checkoutResult.message ?? 'Checkout cancelled.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Checkout failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  SubscriptionTier _tierFromId(String tierId) => switch (tierId) {
        'basic' => SubscriptionTier.basic,
        'pro' => SubscriptionTier.pro,
        'elite' => SubscriptionTier.elite,
        _ => SubscriptionTier.free,
      };
}

class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: Anim.normal,
          height: 40,
          decoration: BoxDecoration(
            gradient: isActive ? AppGradients.hero : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      );
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isYearly,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });
  final _PlanData plan;
  final bool isYearly;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  @override
  Widget build(BuildContext context) {
    final price = isYearly ? plan.yearlyPrice : plan.monthlyPrice;

    Widget card = GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: Anim.normal,
        transform: Matrix4.identity()..scale(isSelected ? 1.0 : 0.97),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x10FFFFFF), Color(0x04FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? plan.color.withValues(alpha: 0.5)
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: plan.color.withValues(alpha: 0.15),
                    blurRadius: 20,
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GradientText(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      plan.color,
                      plan.color.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                const Spacer(),
                if (plan.badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          plan.color,
                          plan.color.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: Text(
                    '/mo',
                    style: TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...plan.features.map(
              (f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: plan.color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      f,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (index == 2) {
      card = ShimmerBorderCard(
        padding: EdgeInsets.zero,
        colors: const [AppColors.warning, Colors.white, AppColors.warning],
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GradientText(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        plan.color,
                        plan.color.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (plan.badge != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            plan.color,
                            plan.color.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        plan.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '/mo',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...plan.features.map(
                (f) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: plan.color,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        f,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return card
        .animate(delay: (400 + index * 120).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }
}

class _TrustBadge extends StatelessWidget {
  const _TrustBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textTertiary, fontSize: 11),
          ),
        ],
      );
}

class _PlanData {
  const _PlanData({
    required this.name,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    required this.color,
    this.badge,
  });
  final String name;
  final String monthlyPrice;
  final String yearlyPrice;
  final List<String> features;
  final Color color;
  final String? badge;
}
