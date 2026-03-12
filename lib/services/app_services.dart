// ignore_for_file: discarded_futures, strict_raw_type
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Platform-aware app blocker service.
/// Dispatches to Android (UsageStatsManager) or iOS (FamilyControls) via MethodChannel.
class AppBlockerService {
  static const _channel = MethodChannel('com.focusguard/blocker');

  final Set<String> _blockedPackages = {};
  bool _isRunning = false;
  bool _strictModeEnabled = false;
  int _blockCount = 0;
  int _overrideCount = 0;

  bool get isRunning => _isRunning;
  bool get strictModeEnabled => _strictModeEnabled;
  int get blockCount => _blockCount;
  int get overrideCount => _overrideCount;
  Set<String> get blockedPackages => Set.unmodifiable(_blockedPackages);

  /// Start the blocking service
  Future<bool> start() async {
    try {
      final result = await _channel.invokeMethod<bool>('startService');
      _isRunning = result ?? false;
      debugPrint(
        '🛡️ Blocker service ${_isRunning ? 'started' : 'failed to start'}',
      );
      return _isRunning;
    } on MissingPluginException {
      // No native implementation — demo mode
      _isRunning = true;
      debugPrint('🛡️ Blocker service started (demo mode)');
      return true;
    }
  }

  /// Stop the blocking service
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stopService');
    } on MissingPluginException {/* demo */}
    _isRunning = false;
    debugPrint('🛡️ Blocker service stopped');
  }

  /// Update the list of blocked packages
  Future<void> updateBlockedApps(Set<String> packages) async {
    _blockedPackages
      ..clear()
      ..addAll(packages);
    try {
      await _channel
          .invokeMethod('updateBlockedApps', {'packages': packages.toList()});
    } on MissingPluginException {/* demo */}
    debugPrint('🛡️ Updated blocked apps: ${packages.length}');
  }

  /// Toggle a single app block
  void toggleApp(String packageName, {required bool blocked}) {
    if (blocked) {
      _blockedPackages.add(packageName);
    } else {
      _blockedPackages.remove(packageName);
    }
    updateBlockedApps(_blockedPackages);
  }

  /// Enable strict mode (requires biometric to disable)
  void enableStrictMode() {
    _strictModeEnabled = true;
    debugPrint('🔒 Strict mode enabled');
  }

  /// Disable strict mode
  void disableStrictMode() {
    _strictModeEnabled = false;
    debugPrint('🔓 Strict mode disabled');
  }

  /// Record a block event
  void recordBlock(String packageName) {
    _blockCount++;
    debugPrint('🚫 Blocked: $packageName (total: $_blockCount)');
  }

  /// Record an override
  void recordOverride(String packageName) {
    _overrideCount++;
    debugPrint('⚠️ Override: $packageName (total: $_overrideCount)');
  }

  /// Get current foreground app (Android only)
  Future<String?> getCurrentForegroundApp() async {
    try {
      return await _channel.invokeMethod<String>('getCurrentForegroundApp');
    } on MissingPluginException {
      return null;
    }
  }

  /// Check if usage stats permission is granted
  Future<bool> hasUsageStatsPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasUsagePermission') ?? false;
    } on MissingPluginException {
      return true; // demo mode
    }
  }

  /// Request usage stats permission
  Future<void> requestUsageStatsPermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on MissingPluginException {/* demo */}
  }
}

/// Platform-aware usage tracker service.
/// Tracks per-app screen time using platform channels.
class UsageTrackerService {
  static const _channel = MethodChannel('com.focusguard/usage');

  /// Get today's app usage
  Future<Map<String, int>> getTodayUsage() async {
    try {
      final result = await _channel.invokeMethod<Map>('getTodayUsage');
      return result?.map((k, v) => MapEntry(k.toString(), v as int)) ?? {};
    } on MissingPluginException {
      // Demo data
      return {
        'Instagram': 42,
        'TikTok': 28,
        'YouTube': 55,
        'Twitter': 15,
        'Facebook': 8,
        'Reddit': 22,
        'WhatsApp': 35,
        'Gmail': 20,
        'Chrome': 45,
      };
    }
  }

  /// Get total screen time today (minutes)
  Future<int> getTodayScreenTime() async {
    try {
      return await _channel.invokeMethod<int>('getTodayScreenTime') ?? 0;
    } on MissingPluginException {
      return 270; // Demo: 4.5 hours
    }
  }

  /// Get pickup count (Android only)
  Future<int> getPickupCount() async {
    try {
      return await _channel.invokeMethod<int>('getPickupCount') ?? 0;
    } on MissingPluginException {
      return 45; // Demo
    }
  }

  /// Get usage for a date range
  Future<List<Map<String, dynamic>>> getUsageRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final result = await _channel
          .invokeMethod<List<Map<String, dynamic>>>('getUsageRange', {
        'start': start.millisecondsSinceEpoch,
        'end': end.millisecondsSinceEpoch,
      });
      return result?.map(Map<String, dynamic>.from).toList() ?? [];
    } on MissingPluginException {
      return []; // Demo
    }
  }
}

/// Focus session service — manages active focus sessions
class FocusSessionService {
  bool _isActive = false;
  DateTime? _startTime;
  int _distractionCount = 0;
  String _currentType = 'Deep Work';
  int _elapsedSeconds = 0;

  bool get isActive => _isActive;
  DateTime? get startTime => _startTime;
  int get distractionCount => _distractionCount;
  String get currentType => _currentType;
  int get elapsedSeconds => _elapsedSeconds;

  void startSession({required String type, int workMinutes = 25}) {
    _isActive = true;
    _startTime = DateTime.now();
    _distractionCount = 0;
    _currentType = type;
    _elapsedSeconds = 0;
    debugPrint('🎯 Session started: $type ($workMinutes min)');
  }

  void endSession() {
    _isActive = false;
    if (_startTime != null) {
      _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }
    debugPrint(
      '🎯 Session ended: ${_elapsedSeconds}s, $_distractionCount distractions',
    );
  }

  void recordDistraction() {
    _distractionCount++;
    debugPrint('🎯 Distraction #$_distractionCount');
  }

  void tick() {
    if (_isActive && _startTime != null) {
      _elapsedSeconds = DateTime.now().difference(_startTime!).inSeconds;
    }
  }
}

/// Notification service abstraction
class NotificationService {
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // In production: initialize flutter_local_notifications + FCM
    _initialized = true;
    debugPrint('🔔 Notification service initialized');
  }

  Future<void> showBlockingAlert(String appName) async {
    debugPrint('🔔 Blocking: $appName is blocked');
  }

  Future<void> showGoalWarning(String goalName, int minutesRemaining) async {
    debugPrint('🔔 Goal: $goalName — $minutesRemaining min remaining');
  }

  Future<void> showAchievement(String name, String icon) async {
    debugPrint('🔔 Achievement: $icon $name unlocked!');
  }

  Future<void> showFocusReminder() async {
    debugPrint('🔔 Focus: Time to start a focus session!');
  }

  Future<void> showStreakAlert(int streak, int hoursRemaining) async {
    debugPrint(
      '🔔 Streak: Don\'t break your $streak-day streak! ${hoursRemaining}h left',
    );
  }

  Future<void> showWeeklyReport(int score) async {
    debugPrint('🔔 Report: Your weekly score is $score/100');
  }

  Future<void> showBedtimeReminder() async {
    debugPrint('🔔 Bedtime: Time to wind down 🌙');
  }

  Future<void> showEyeStrainReminder() async {
    debugPrint('🔔 Eye: 20-20-20 reminder — look away for 20 seconds');
  }

  Future<void> showWaterReminder() async {
    debugPrint('🔔 Water: Stay hydrated! 💧');
  }

  Future<void> cancelAll() async {
    debugPrint('🔔 Cancelled all notifications');
  }
}

/// Purchase/subscription service abstraction
class PurchaseService {
  String _currentTier = 'free';
  bool _isTrialActive = false;

  String get currentTier => _currentTier;
  bool get isTrialActive => _isTrialActive;
  bool get isBasic => _currentTier == 'basic';
  bool get isPro => _currentTier == 'pro' || _currentTier == 'elite';
  bool get isElite => _currentTier == 'elite';

  Future<void> init() async {
    // In production: initialize RevenueCat
    debugPrint('💎 Purchase service initialized (demo: pro tier)');
    _currentTier = 'pro'; // Demo mode: give Pro access
    _isTrialActive = true;
  }

  bool hasAccess(String feature) {
    switch (feature) {
      case 'unlimited_blocks':
        return isPro;
      case 'all_timers':
        return isPro;
      case 'full_analytics':
        return isPro;
      case 'ai_coaching':
        return isPro;
      case 'ai_coaching_unlimited':
        return isElite;
      case 'strict_mode':
        return isElite;
      case 'focus_spaces':
        return isElite;
      case 'accountability':
        return isPro;
      case 'habits':
        return isPro;
      case 'challenges':
        return isPro;
      case 'export':
        return isPro;
      default:
        return true;
    }
  }

  Future<bool> purchase(String productId) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentTier = productId.contains('elite') ? 'elite' : 'pro';
    debugPrint('💎 Purchased: $productId → $_currentTier');
    return true;
  }

  Future<void> restore() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    debugPrint('💎 Purchases restored');
  }
}

/// Background task service
class BackgroundTaskService {
  static const _channel = MethodChannel('com.focusguard/background');

  Future<void> registerTasks() async {
    try {
      await _channel.invokeMethod('registerTasks');
      debugPrint('⏰ Background tasks registered');
    } on MissingPluginException {
      debugPrint('⏰ Background tasks registered (demo)');
    }
  }

  Future<void> cancelAllTasks() async {
    try {
      await _channel.invokeMethod('cancelAllTasks');
    } on MissingPluginException {/* demo */}
  }
}
