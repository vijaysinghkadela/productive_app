import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// Date formatters
String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);
String formatDateShort(DateTime date) => DateFormat('MMM dd').format(date);
String formatDayOfWeek(DateTime date) => DateFormat('EEE').format(date);
String formatMonthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

// Duration formatters
String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes}m';
  }
  return '${minutes}m';
}

String formatDurationLong(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '$hours hr $minutes min';
  }
  if (minutes > 0) {
    return '$minutes min $seconds sec';
  }
  return '$seconds sec';
}

String formatTimerDisplay(int totalSeconds) {
  final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$minutes:$seconds';
}

// Validators
String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'Email is required';
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  if (!regex.hasMatch(value.trim())) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) return 'Name is required';
  if (value.trim().length < 2) return 'Name must be at least 2 characters';
  return null;
}

String? validatePin(String? value) {
  if (value == null || value.isEmpty) return 'PIN is required';
  if (value.length != 4 || int.tryParse(value) == null) {
    return 'PIN must be 4 digits';
  }
  return null;
}

// Haptic feedback helper
void hapticLight() => HapticFeedback.lightImpact();
void hapticMedium() => HapticFeedback.mediumImpact();
void hapticHeavy() => HapticFeedback.heavyImpact();
void hapticSelection() => HapticFeedback.selectionClick();

// Glassmorphism helper widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double borderRadius;
  final double blur;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 20,
    this.blur = 10,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color ?? Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// Score color helper — delegates to AppColors
Color getScoreColor(int score) {
  if (score >= 86) return const Color(0xFF00FFB2);
  if (score >= 71) return const Color(0xFF00D4FF);
  if (score >= 41) return const Color(0xFFFFB800);
  return const Color(0xFFFF4757);
}

// Day key for dates (used in Hive storage)
String dayKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

// Get today's date without time
DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
