import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/focus_session.dart';
import '../../domain/entities/daily_stat.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/app_info.dart';
import '../../domain/entities/achievement.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/security/input_sanitizer.dart';

/// Local data source backed by encrypted Hive boxes.
/// All boxes are encrypted with AES-256-GCM via platform secure enclaves.
class LocalDataSource {
  static const String _sessionsBox = 'sessions';
  static const String _statsBox = 'daily_stats';
  static const String _goalsBox = 'goals';
  static const String _blockerBox = 'blocker';
  static const String _settingsBox = 'settings';
  static const String _achievementsBox = 'achievements';

  static Future<void> init() async {
    await Hive.initFlutter();
    // Initialize encryption service first
    await SecureStorageService.init();
    // Open all boxes with AES-256 encryption
    await SecureStorageService.openEncryptedBox(_sessionsBox);
    await SecureStorageService.openEncryptedBox(_statsBox);
    await SecureStorageService.openEncryptedBox(_goalsBox);
    await SecureStorageService.openEncryptedBox(_blockerBox);
    await SecureStorageService.openEncryptedBox(_settingsBox);
    await SecureStorageService.openEncryptedBox(_achievementsBox);
  }

  // --- Focus Sessions ---
  Box get _sessions => Hive.box(_sessionsBox);

  Future<void> saveSession(FocusSession session) async {
    await _sessions.put(session.id, jsonEncode(session.toMap()));
  }

  List<FocusSession> getSessions() {
    return _sessions.values
        .map((v) => FocusSession.fromMap(
            jsonDecode(v as String) as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<FocusSession> getSessionsForDate(String dateKey) {
    return getSessions()
        .where((s) => s.startTime.toIso8601String().startsWith(dateKey))
        .toList();
  }

  /// Paginated session retrieval for lazy-loading lists.
  List<FocusSession> getSessionsPaginated({int page = 0, int pageSize = 20}) {
    final all = getSessions();
    final start = page * pageSize;
    if (start >= all.length) return [];
    return all.sublist(start, (start + pageSize).clamp(0, all.length));
  }

  Future<void> deleteSession(String id) async {
    await _sessions.delete(id);
  }

  // --- Daily Stats ---
  Box get _stats => Hive.box(_statsBox);

  Future<void> saveDailyStat(DailyStat stat) async {
    await _stats.put(stat.date, jsonEncode(stat.toMap()));
  }

  DailyStat? getDailyStat(String dateKey) {
    final data = _stats.get(dateKey);
    if (data == null) return null;
    return DailyStat.fromMap(
        jsonDecode(data as String) as Map<String, dynamic>);
  }

  List<DailyStat> getStatsForRange(DateTime start, DateTime end) {
    final results = <DailyStat>[];
    var current = start;
    while (!current.isAfter(end)) {
      final key =
          '${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}';
      final stat = getDailyStat(key);
      if (stat != null) results.add(stat);
      current = current.add(const Duration(days: 1));
    }
    return results;
  }

  // --- Goals ---
  Box get _goals => Hive.box(_goalsBox);

  Future<void> saveGoal(AppGoal goal) async {
    await _goals.put(goal.packageName, jsonEncode(goal.toMap()));
  }

  List<AppGoal> getGoals() {
    return _goals.values
        .map((v) =>
            AppGoal.fromMap(jsonDecode(v as String) as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteGoal(String packageName) async {
    await _goals.delete(packageName);
  }

  // --- Blocker Config ---
  Box get _blocker => Hive.box(_blockerBox);

  Future<void> saveBlockedApp(AppInfo app) async {
    await _blocker.put(app.packageName, jsonEncode(app.toMap()));
  }

  List<AppInfo> getBlockedApps() {
    return _blocker.values
        .map((v) =>
            AppInfo.fromMap(jsonDecode(v as String) as Map<String, dynamic>))
        .toList();
  }

  Future<void> removeBlockedApp(String packageName) async {
    await _blocker.delete(packageName);
  }

  // --- Settings (sensitive values use secure enclave) ---
  Box get _settingsData => Hive.box(_settingsBox);

  Future<void> saveSetting(String key, dynamic value) async {
    await _settingsData.put(key, jsonEncode(value));
  }

  T? getSetting<T>(String key) {
    final data = _settingsData.get(key);
    if (data == null) return null;
    return jsonDecode(data as String) as T?;
  }

  bool getHasCompletedOnboarding() =>
      getSetting<bool>('onboarding_completed') ?? false;
  Future<void> setHasCompletedOnboarding() =>
      saveSetting('onboarding_completed', true);

  bool getHasAcceptedTerms() => getSetting<bool>('terms_accepted') ?? false;
  Future<void> setHasAcceptedTerms() => saveSetting('terms_accepted', true);

  /// PIN stored in secure enclave, not in Hive.
  Future<String?> getStrictModePin() async {
    return SecureStorageService.readSecure('strict_mode_pin');
  }

  Future<void> setStrictModePin(String pin) async {
    final sanitized = InputSanitizer.sanitizePin(pin);
    if (sanitized != null) {
      await SecureStorageService.writeSecure('strict_mode_pin', sanitized);
    }
  }

  // --- Bedtime ---
  Map<String, dynamic>? getBedtimeConfig() {
    final data = _settingsData.get('bedtime_config');
    if (data == null) return null;
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  Future<void> saveBedtimeConfig(Map<String, dynamic> config) async {
    await _settingsData.put('bedtime_config', jsonEncode(config));
  }

  // --- Achievements ---
  Box get _achievementsData => Hive.box(_achievementsBox);

  Future<void> saveAchievement(Achievement achievement) async {
    await _achievementsData.put(
        achievement.id,
        jsonEncode({
          'id': achievement.id,
          'currentValue': achievement.currentValue,
          'unlocked': achievement.unlocked,
          'unlockedDate': achievement.unlockedDate?.toIso8601String(),
        }));
  }

  Map<String, dynamic>? getAchievementProgress(String id) {
    final data = _achievementsData.get(id);
    if (data == null) return null;
    return jsonDecode(data as String) as Map<String, dynamic>;
  }

  // --- Clear all data ---
  Future<void> clearAll() async {
    await _sessions.clear();
    await _stats.clear();
    await _goals.clear();
    await _blocker.clear();
    await _settingsData.clear();
    await _achievementsData.clear();
    await SecureStorageService.clearAll();
  }
}
