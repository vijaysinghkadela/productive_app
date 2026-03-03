import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants.dart';

/// Primary gradient button with glow shadow, scale animation, and loading state.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Gradient? gradient;
  final double height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.height = 56,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Anim.fast);
    _scale = Tween(begin: 1.0, end: 0.95).animate(
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
    final grad = widget.gradient ?? AppGradients.hero;
    final enabled = widget.onPressed != null && !widget.isLoading;

    return GestureDetector(
      onTapDown: enabled ? (_) => _ctrl.forward() : null,
      onTapUp: enabled
          ? (_) {
              _ctrl.reverse();
              HapticFeedback.mediumImpact();
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: AnimatedOpacity(
          duration: Anim.fast,
          opacity: enabled ? 1.0 : 0.5,
          child: Container(
            width: double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: grad,
              borderRadius: BorderRadius.circular(16),
              boxShadow:
                  enabled ? AppShadows.elevatedGlow(AppColors.primary) : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.label,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        if (widget.icon != null) ...[
                          const SizedBox(width: 10),
                          Icon(widget.icon, color: Colors.white, size: 20),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary glass button with gradient border.
class SecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton>
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
    final c = widget.color ?? AppColors.primary;
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onPressed != null
          ? (_) {
              _ctrl.reverse();
              HapticFeedback.lightImpact();
              widget.onPressed!();
            }
          : null,
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: c, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 44×44 glass icon button with glow on press.
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.size = 44,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Anim.fast);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? AppColors.textSecondary;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.selectionClick();
        widget.onPressed?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color:
                  Color.lerp(AppColors.cardGlass, c.withValues(alpha: 0.15), t),
              shape: BoxShape.circle,
              border: Border.all(
                color: Color.lerp(
                    AppColors.cardBorder, c.withValues(alpha: 0.3), t)!,
              ),
              boxShadow: t > 0.1 ? AppShadows.glow(c, blur: 12 * t) : null,
            ),
            child: Icon(widget.icon, color: c, size: widget.size * 0.45),
          );
        },
      ),
    );
  }
}

/// Custom animated toggle switch with spring physics.
class CustomToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  const CustomToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
  });

  @override
  State<CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<CustomToggle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: widget.value ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(CustomToggle old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      if (widget.value) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? AppColors.primary;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onChanged?.call(!widget.value);
      },
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          final trackColor = Color.lerp(
            AppColors.surfaceLight,
            activeColor,
            t,
          )!;
          final thumbX =
              3 + t * 26; // 3px offset → 29px offset (within 56px track)

          return Container(
            width: 56,
            height: 30,
            decoration: BoxDecoration(
              color: trackColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: t > 0.5
                  ? [
                      BoxShadow(
                          color: activeColor.withValues(alpha: 0.3 * t),
                          blurRadius: 8)
                    ]
                  : null,
            ),
            child: Stack(
              children: [
                Positioned(
                  left: thumbX,
                  top: 3,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Gradient text widget
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient = AppGradients.hero,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(text, style: style, textAlign: textAlign),
    );
  }
}
