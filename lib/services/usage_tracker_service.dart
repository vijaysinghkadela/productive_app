// ignore_for_file: strict_raw_type
import 'package:flutter/services.dart';

/// Service that retrieves app usage statistics from the platform.
///
/// Android: Uses UsageStatsManager API
/// iOS: Uses Screen Time API DeviceActivityReport
class UsageTrackerService {
  static const _channel = MethodChannel('com.focusguard/usage_tracker');

  /// Get usage stats for a specific date range.
  /// Returns a map of package name → usage duration in minutes.
  Future<Map<String, int>> getUsageStats({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final result = await _channel.invokeMethod<Map>('getUsageStats', {
        'startTime': startDate.millisecondsSinceEpoch,
        'endTime': endDate.millisecondsSinceEpoch,
      });
      if (result == null) return {};
      return result.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    } on PlatformException {
      // Return demo data when platform API is unavailable
      return _getDemoUsageStats();
    }
  }

  /// Get today's usage stats for a specific app.
  Future<int> getAppUsageToday(String packageName) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final stats = await getUsageStats(startDate: startOfDay, endDate: now);
    return stats[packageName] ?? 0;
  }

  /// Get today's total screen time in minutes.
  Future<int> getTotalScreenTimeToday() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final stats = await getUsageStats(startDate: startOfDay, endDate: now);
    return stats.values.fold<int>(0, (sum, v) => sum + v);
  }

  /// Get the list of installed apps with their package names.
  Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List>('getInstalledApps');
      if (result == null) return [];
      return result.map((app) {
        final map = Map<String, dynamic>.from(app as Map);
        return {
          'name': map['name']?.toString() ?? 'Unknown',
          'package': map['package']?.toString() ?? '',
        };
      }).toList();
    } on PlatformException {
      return [];
    }
  }

  /// Check if usage stats permission is granted.
  Future<bool> hasUsagePermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Request usage stats permission (opens system settings).
  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException {
      // Silently fail — user will see the permission screen
    }
  }

  /// Get social media usage for today.
  /// Filters usage stats to only include known social media apps.
  Future<int> getSocialMediaUsageToday() async {
    const socialMediaPackages = [
      'com.instagram.android',
      'com.zhiliaoapp.musically', // TikTok
      'com.google.android.youtube',
      'com.twitter.android',
      'com.facebook.katana',
      'com.snapchat.android',
      'com.reddit.frontpage',
      'com.pinterest',
      'com.linkedin.android',
    ];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final stats = await getUsageStats(startDate: startOfDay, endDate: now);

    return stats.entries
        .where((e) => socialMediaPackages.contains(e.key))
        .fold<int>(0, (sum, e) => sum + e.value);
  }

  /// Fallback demo data when platform API is not available.
  Map<String, int> _getDemoUsageStats() => {
        'com.instagram.android': 45,
        'com.zhiliaoapp.musically': 30,
        'com.google.android.youtube': 60,
        'com.twitter.android': 20,
        'com.facebook.katana': 15,
        'com.whatsapp': 40,
        'com.android.chrome': 35,
        'com.google.android.gm': 10,
        'com.spotify.music': 30,
        'com.netflix.mediaclient': 50,
      };
}
