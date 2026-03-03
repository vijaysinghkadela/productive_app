import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/core/constants/route_constants.dart';
import 'package:focusguard_pro/data/providers/anti_gravity_provider.dart';
import 'package:focusguard_pro/domain/entities/user.dart';
import 'package:focusguard_pro/presentation/widgets/particle_painter.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

/// Focus-screen overlay that renders Anti-Gravity visuals and upsell states.
class AntiGravityOverlay extends ConsumerStatefulWidget {
  /// Creates an Anti-Gravity overlay for focus-session UI.
  const AntiGravityOverlay({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AntiGravityOverlay> createState() => _AntiGravityOverlayState();
}

class _AntiGravityOverlayState extends ConsumerState<AntiGravityOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _toastController;
  Timer? _toastTimer;
  bool _showToast = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _toastController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  void _onActivationChanged(bool isActive) {
    if (isActive) {
      _fadeController.forward();
    } else {
      _fadeController.reverse();
    }
  }

  void _showActivationToast() {
    _toastTimer?.cancel();
    if (!_showToast) {
      setState(() {
        _showToast = true;
      });
    }
    _toastController.forward(from: 0);

    _toastTimer = Timer(const Duration(milliseconds: 2500), () async {
      await _toastController.reverse();
      if (!mounted) return;
      setState(() {
        _showToast = false;
      });
    });
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _fadeController.dispose();
    _toastController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final antiGravityState = ref.watch(antiGravityProvider);
    final tier = ref.watch(currentSubscriptionTierProvider);

    ref.listen<AntiGravityState>(antiGravityProvider, (
      AntiGravityState? previous,
      AntiGravityState next,
    ) {
      final wasActive = previous?.isActive ?? false;
      if (wasActive != next.isActive) {
        _onActivationChanged(next.isActive);
      }
      if (!wasActive && next.isActive) {
        _showActivationToast();
      }
    });

    final showProUpsell = tier == SubscriptionTier.pro &&
        antiGravityState.elapsedMinutes >= 20 &&
        !antiGravityState.isActive;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!antiGravityState.isActive) return;
        final snapToken = ref.read(antiGravitySnapTriggerProvider.notifier);
        snapToken.state = snapToken.state + 1;
      },
      child: Stack(
        children: <Widget>[
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: FadeTransition(
                opacity: _fadeController,
                child: const AntiGravityParticleLayer(),
              ),
            ),
          ),
          if (showProUpsell)
            const Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: _LockedShimmerOverlay(),
              ),
            ),
          if (showProUpsell)
            Positioned(
              right: 16,
              top: MediaQuery.paddingOf(context).top + 12,
              child: _UpgradeBadge(
                onTap: () {
                  unawaited(context.push(RouteConstants.subscription));
                },
              ),
            ),
          if (_showToast)
            Positioned(
              left: 16,
              right: 16,
              top: MediaQuery.paddingOf(context).top + 12,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _toastController,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: const _ActivationToast(),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActivationToast extends StatelessWidget {
  const _ActivationToast();

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF2A2E5B), Color(0xFF4A7DFF)],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '🌌 Anti-Gravity Active',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      );
}

class _LockedShimmerOverlay extends StatelessWidget {
  const _LockedShimmerOverlay();

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.02),
          highlightColor: AppColors.secondary.withValues(alpha: 0.09),
          period: const Duration(milliseconds: 1400),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Color(0x1500D4FF),
                  Color(0x0000D4FF),
                ],
              ),
            ),
          ),
        ),
      );
}

class _UpgradeBadge extends StatelessWidget {
  const _UpgradeBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFF6C63FF), Color(0xFF00D4FF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'Unlock Anti-Gravity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
}
