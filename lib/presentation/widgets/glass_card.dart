import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

/// Core glassmorphism card — used everywhere instead of plain Container.
/// Features: backdrop blur, gradient glass background, subtle border, shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final double blur;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.borderColor,
    this.blur = 20,
    this.onTap,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x0FFFFFFF), Color(0x05FFFFFF)],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppColors.cardBorderLight,
                width: 1,
              ),
              boxShadow: boxShadow ??
                  [
                    const BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 32,
                      offset: Offset(0, 8),
                    ),
                  ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Pressable glass card — scales to 0.97 on press with spring animation.
class PressableCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? borderColor;
  final VoidCallback? onTap;
  final Color? glowColor;

  const PressableCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.borderColor,
    this.onTap,
    this.glowColor,
  });

  @override
  State<PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<PressableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Anim.fast);
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: GlassCard(
          padding: widget.padding,
          borderRadius: widget.borderRadius,
          borderColor: widget.borderColor,
          boxShadow: widget.glowColor != null
              ? AppShadows.elevatedGlow(widget.glowColor!)
              : null,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Shimmer border card — animated gradient border that slowly rotates.
/// Used for premium/featured/legendary items.
class ShimmerBorderCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double borderWidth;
  final List<Color>? colors;

  const ShimmerBorderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = 20,
    this.borderWidth = 1.5,
    this.colors,
  });

  @override
  State<ShimmerBorderCard> createState() => _ShimmerBorderCardState();
}

class _ShimmerBorderCardState extends State<ShimmerBorderCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ??
        [
          AppColors.primary,
          AppColors.secondary,
          AppColors.tertiary,
          AppColors.primary,
        ];

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: SweepGradient(
              center: Alignment.center,
              startAngle: _ctrl.value * 6.28,
              colors: colors,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(widget.borderWidth),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(
                widget.borderRadius - widget.borderWidth,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                widget.borderRadius - widget.borderWidth,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Gradient accent card with specific color tinting
class AccentCard extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  const AccentCard({
    super.key,
    required this.child,
    required this.color,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.12),
              color.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: child,
      ),
    );
  }
}
