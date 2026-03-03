// ignore_for_file: avoid_positional_boolean_parameters, discarded_futures, inference_failure_on_instance_creation, unawaited_futures, use_setters_to_change_properties
import 'package:flutter/services.dart';

/// Haptic feedback service with semantic methods.
class HapticService {
  HapticService._();
  static final HapticService instance = HapticService._();

  bool _enabled = true;

  /// Enable/disable haptic feedback globally
  void setEnabled(bool enabled) => _enabled = enabled;

  /// Light impact — button taps, selections
  void light() {
    if (_enabled) HapticFeedback.lightImpact();
  }

  /// Medium impact — important actions, toggle changes
  void medium() {
    if (_enabled) HapticFeedback.mediumImpact();
  }

  /// Heavy impact — destructive actions, errors
  void heavy() {
    if (_enabled) HapticFeedback.heavyImpact();
  }

  /// Selection click — scroll pickers, segments
  void selection() {
    if (_enabled) HapticFeedback.selectionClick();
  }

  /// Vibrate — long vibration for alerts
  void vibrate() {
    if (_enabled) HapticFeedback.vibrate();
  }

  /// Success pattern
  void success() => light();

  /// Error pattern
  void error() => heavy();

  /// Warning pattern
  void warning() => medium();

  /// Achievement unlock pattern
  Future<void> achievement() async {
    if (!_enabled) return;
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
  }
}
