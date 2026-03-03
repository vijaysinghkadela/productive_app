import 'package:flutter/material.dart';
import 'package:focusguard_pro/core/constants.dart';

/// Context extensions for common operations
extension BuildContextExtension on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  bool get isLandscape => screenWidth > screenHeight;
  bool get isTablet => screenWidth > 600;

  // Snackbar helpers
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void showErrorSnackBar(String message) =>
      showSnackBar(message, backgroundColor: AppColors.alert);

  void showSuccessSnackBar(String message) =>
      showSnackBar(message, backgroundColor: AppColors.success);

  // Navigation
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  bool get canPop => Navigator.of(this).canPop();
}
