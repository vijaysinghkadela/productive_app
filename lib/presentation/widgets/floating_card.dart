import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/data/providers/anti_gravity_provider.dart';

/// A card wrapper that tilts and floats with Anti-Gravity sensor data.
class FloatingCard extends ConsumerStatefulWidget {
  /// Creates a floating card.
  const FloatingCard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<FloatingCard> createState() => _FloatingCardState();
}

class _FloatingCardState extends ConsumerState<FloatingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  late final Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _snapAnimation = CurvedAnimation(
      parent: _snapController,
      curve: Curves.elasticOut,
    );
  }

  void _animateSnapToOrigin() {
    _snapController.forward(from: 0);
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(antiGravitySnapTriggerProvider, (int? _, int __) {
      _animateSnapToOrigin();
    });

    final antiGravityState = ref.watch(antiGravityProvider);
    if (!antiGravityState.isActive && _snapController.value == 0) {
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _snapAnimation,
        builder: (BuildContext context, Widget? child) {
          final settleFactor = 1 - _snapAnimation.value;
          final tiltX = antiGravityState.tiltX * settleFactor;
          final tiltY = antiGravityState.tiltY * settleFactor;

          final transformMatrix = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(tiltY * 0.08)
            ..rotateY(-tiltX * 0.08);

          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: antiGravityState.isActive
                ? () {
                    final snapToken =
                        ref.read(antiGravitySnapTriggerProvider.notifier);
                    snapToken.state = snapToken.state + 1;
                  }
                : null,
            child: Transform.translate(
              offset: Offset(tiltX * 18.0, tiltY * 18.0),
              child: Transform(
                alignment: Alignment.center,
                transform: transformMatrix,
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
