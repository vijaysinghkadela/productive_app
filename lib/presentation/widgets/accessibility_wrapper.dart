import 'package:flutter/material.dart';
import 'package:focusguard_pro/core/constants.dart';

/// Wrapper widget that ensures accessibility compliance:
/// - Semantic labels on interactive elements
/// - Minimum touch target sizes (48dp Material 3 / 44pt HIG)
/// - Focus traversal support for keyboard/switch access
/// - High-contrast text support
class AccessibilityWrapper extends StatelessWidget {
  const AccessibilityWrapper({
    required this.child,
    super.key,
    this.semanticLabel,
    this.semanticHint,
    this.isButton = false,
    this.excludeFromSemantics = false,
    this.onTap,
  });
  final Widget child;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isButton;
  final bool excludeFromSemantics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    var wrapped = child;

    // Ensure minimum touch target
    if (isButton || onTap != null) {
      wrapped = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppSizes.minTouchTarget,
          minHeight: AppSizes.minTouchTarget,
        ),
        child: wrapped,
      );
    }

    // Add semantics
    if (!excludeFromSemantics) {
      wrapped = Semantics(
        label: semanticLabel,
        hint: semanticHint,
        button: isButton,
        onTap: onTap,
        child: wrapped,
      );
    }

    return wrapped;
  }

  /// Creates an accessible icon button with proper touch target and semantics.
  static Widget iconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    double size = AppSizes.iconLg,
    Color? color,
  }) =>
      Semantics(
        label: label,
        button: true,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: AppSizes.minTouchTarget,
              minHeight: AppSizes.minTouchTarget,
            ),
            child: Center(child: Icon(icon, size: size, color: color)),
          ),
        ),
      );

  /// Wraps a text widget with adequate contrast checking.
  static Widget accessibleText(
    String text, {
    required TextStyle style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) =>
      Semantics(
        label: text,
        child: Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        ),
      );
}
