/// Duration extensions for display formatting
extension DurationExtension on Duration {
  /// "1h 30m"
  String get shortFormat {
    final h = inHours;
    final m = inMinutes.remainder(60);
    if (h > 0 && m > 0) return '${h}h ${m}m';
    if (h > 0) return '${h}h';
    return '${m}m';
  }

  /// "1 hour 30 minutes"
  String get longFormat {
    final h = inHours;
    final m = inMinutes.remainder(60);
    final s = inSeconds.remainder(60);
    if (h > 0) return '$h hr${h > 1 ? 's' : ''} $m min';
    if (m > 0) return '$m min${m > 1 ? 's' : ''} $s sec';
    return '$s sec';
  }

  /// "01:30:00" timer format
  String get timerFormat {
    final h = inHours.toString().padLeft(2, '0');
    final m = inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (inHours > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  /// Convert to minutes (as double for charts)
  double get totalMinutes => inSeconds / 60.0;

  /// Convert to hours (as double for charts)
  double get totalHours => inMinutes / 60.0;

  /// Percentage of another duration
  double percentOf(Duration total) {
    if (total.inSeconds == 0) return 0;
    return (inSeconds / total.inSeconds).clamp(0.0, 1.0);
  }
}
