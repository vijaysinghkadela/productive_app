import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hive local datasource for persistent key-value and list storage
class HiveDatasource {
  static const String _userBox = 'user_box';
  static const String _sessionsBox = 'sessions_box';
  static const String _statsBox = 'stats_box';
  static const String _settingsBox = 'settings_box';
  static const String _cacheBox = 'cache_box';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_userBox);
    await Hive.openBox(_sessionsBox);
    await Hive.openBox(_statsBox);
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_cacheBox);
  }

  // Generic CRUD
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = Hive.box(boxName);
    await box.put(
        key, value is Map || value is List ? jsonEncode(value) : value);
  }

  dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = Hive.box(boxName);
    final val = box.get(key, defaultValue: defaultValue);
    if (val is String) {
      try {
        return jsonDecode(val);
      } catch (_) {
        return val;
      }
    }
    return val;
  }

  Future<void> delete(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  List<dynamic> getAll(String boxName) {
    final box = Hive.box(boxName);
    return box.values.map((v) {
      if (v is String) {
        try {
          return jsonDecode(v);
        } catch (_) {
          return v;
        }
      }
      return v;
    }).toList();
  }

  Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }

  // Typed helpers
  Future<void> saveUserData(Map<String, dynamic> data) =>
      put(_userBox, 'current_user', data);

  Map<String, dynamic>? getUserData() {
    final data = get(_userBox, 'current_user');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  Future<void> saveSessions(List<Map<String, dynamic>> sessions) =>
      put(_sessionsBox, 'history', sessions);

  List<Map<String, dynamic>> getSessions() {
    final data = get(_sessionsBox, 'history', defaultValue: []);
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<void> saveDailyStat(String date, Map<String, dynamic> stat) =>
      put(_statsBox, date, stat);

  Map<String, dynamic>? getDailyStat(String date) {
    final data = get(_statsBox, date);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // Settings
  Future<void> saveSetting(String key, dynamic value) =>
      put(_settingsBox, key, value);
  dynamic getSetting(String key, {dynamic defaultValue}) =>
      get(_settingsBox, key, defaultValue: defaultValue);

  // Cache with TTL
  Future<void> cacheData(String key, dynamic data,
      {Duration ttl = const Duration(hours: 1)}) async {
    final expiry = DateTime.now().add(ttl).toIso8601String();
    await put(_cacheBox, key, {'data': data, 'expiry': expiry});
  }

  dynamic getCachedData(String key) {
    final cached = get(_cacheBox, key);
    if (cached is Map && cached['expiry'] != null) {
      final expiry = DateTime.parse(cached['expiry'] as String);
      if (DateTime.now().isBefore(expiry)) return cached['data'];
      delete(_cacheBox, key);
    }
    return null;
  }

  Future<void> dispose() async => await Hive.close();
}

/// Secure storage datasource for sensitive data (PIN, tokens)
class SecureStorageDatasource {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);
  Future<String?> read(String key) => _storage.read(key: key);
  Future<void> delete(String key) => _storage.delete(key: key);
  Future<void> deleteAll() => _storage.deleteAll();

  // Typed helpers
  Future<void> savePin(String pin) => write('app_pin', pin);
  Future<String?> getPin() => read('app_pin');
  Future<void> saveAuthToken(String token) => write('auth_token', token);
  Future<String?> getAuthToken() => read('auth_token');
  Future<void> saveRefreshToken(String token) => write('refresh_token', token);
  Future<String?> getRefreshToken() => read('refresh_token');
}

/// SharedPreferences datasource for simple flags and settings
class SharedPrefsDatasource {
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs => _prefs!;

  // Onboarding
  bool get hasCompletedOnboarding =>
      prefs.getBool('onboarding_complete') ?? false;
  Future<void> setOnboardingComplete() =>
      prefs.setBool('onboarding_complete', true);

  // Terms acceptance
  bool get hasAcceptedTerms => prefs.getBool('terms_accepted') ?? false;
  Future<void> setTermsAccepted() => prefs.setBool('terms_accepted', true);

  // Theme
  String get themeMode => prefs.getString('theme_mode') ?? 'dark';
  Future<void> setThemeMode(String mode) => prefs.setString('theme_mode', mode);

  // Locale
  String get locale => prefs.getString('locale') ?? 'en';
  Future<void> setLocale(String locale) => prefs.setString('locale', locale);

  // Last sync
  DateTime? get lastSyncTime {
    final ts = prefs.getString('last_sync');
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  Future<void> setLastSyncTime() =>
      prefs.setString('last_sync', DateTime.now().toIso8601String());

  // First launch
  bool get isFirstLaunch => prefs.getBool('first_launch') ?? true;
  Future<void> setFirstLaunchDone() => prefs.setBool('first_launch', false);

  // Notification settings
  bool get notificationsEnabled =>
      prefs.getBool('notifications_enabled') ?? true;
  Future<void> setNotificationsEnabled(bool v) =>
      prefs.setBool('notifications_enabled', v);

  // Biometric
  bool get biometricEnabled => prefs.getBool('biometric_enabled') ?? false;
  Future<void> setBiometricEnabled(bool v) =>
      prefs.setBool('biometric_enabled', v);

  // App lock
  bool get appLockEnabled => prefs.getBool('app_lock_enabled') ?? false;
  Future<void> setAppLockEnabled(bool v) =>
      prefs.setBool('app_lock_enabled', v);

  Future<void> clear() async {
    debugPrint('⚠️ Clearing all SharedPreferences');
    await prefs.clear();
  }
}
