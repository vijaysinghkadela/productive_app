import 'package:intl/intl.dart';

/// DateTime extensions for formatting and comparison
extension DateTimeExtension on DateTime {
  /// Format: "Mon, Jan 15"
  String get shortFormat => DateFormat('E, MMM d').format(this);

  /// Format: "January 15, 2026"
  String get longFormat => DateFormat('MMMM d, yyyy').format(this);

  /// Format: "Jan 15"
  String get monthDay => DateFormat('MMM d').format(this);

  /// Format: "3:30 PM"
  String get timeFormat => DateFormat('h:mm a').format(this);

  /// Format: "2026-01-15"
  String get dateKey => DateFormat('yyyy-MM-dd').format(this);

  /// Format: "January 2026"
  String get monthYear => DateFormat('MMMM yyyy').format(this);

  /// Day name: "Monday"
  String get dayName => DateFormat('EEEE').format(this);

  /// Short day: "Mon"
  String get dayShort => DateFormat('E').format(this);

  /// Is today?
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Is yesterday?
  bool get isYesterday {
    final y = DateTime.now().subtract(const Duration(days: 1));
    return year == y.year && month == y.month && day == y.day;
  }

  /// Is this week?
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(startOfWeek.subtract(const Duration(days: 1)));
  }

  /// Start of day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Start of week (Monday)
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  /// Start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Relative time: "2 hours ago", "Just now", "Yesterday"
  String get relativeTime {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
    return monthDay;
  }

  /// Days between two dates
  int daysUntil(DateTime other) => other.difference(this).inDays;
}
