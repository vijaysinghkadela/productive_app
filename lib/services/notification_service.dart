import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local notifications for focus reminders, nudges, and usage alerts.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification plugin.
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap — navigate to relevant screen
    // This will be handled by the app's router
  }

  /// Request notification permission (iOS 10+, Android 13+).
  Future<bool> requestPermission() async {
    if (Platform.isIOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      return result ?? false;
    }
    if (Platform.isAndroid) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }
    return false;
  }

  // --- Notification channel IDs ---
  static const _focusChannelId = 'focus_session';
  static const _nudgeChannelId = 'smart_nudge';
  static const _goalChannelId = 'goal_alert';
  static const _blockerChannelId = 'blocker_service';
  static const _bedtimeChannelId = 'bedtime_mode';

  /// Show a notification when a focus session is completed.
  Future<void> showFocusSessionComplete(int minutes) async {
    await _show(
      id: 100,
      channelId: _focusChannelId,
      channelName: 'Focus Sessions',
      title: 'Focus Session Complete! 🎉',
      body: 'Great work! You focused for $minutes minutes. Time for a break.',
    );
  }

  /// Show a smart nudge when user opens a blocked app.
  Future<void> showSmartNudge(String appName, int minutesUsed) async {
    await _show(
      id: 200,
      channelId: _nudgeChannelId,
      channelName: 'Smart Nudges',
      title: 'Time to focus! 💪',
      body:
          "You've been on $appName for $minutesUsed minutes. Take a break and get back to work!",
    );
  }

  /// Show a notification when a daily goal is reached.
  Future<void> showGoalReached(String appName) async {
    await _show(
      id: 300,
      channelId: _goalChannelId,
      channelName: 'Goal Alerts',
      title: 'Daily Limit Reached ⚠️',
      body:
          'You\'ve reached your daily limit for $appName. Time to switch off!',
    );
  }

  /// Show a notification when a goal has been met (positive).
  Future<void> showGoalAchieved(String appName) async {
    await _show(
      id: 301,
      channelId: _goalChannelId,
      channelName: 'Goal Alerts',
      title: 'Goal Achieved! 🎯',
      body: 'You stayed within your $appName limit today. Keep it up!',
    );
  }

  /// Show persistent notification for the blocking service.
  Future<void> showBlockerServiceNotification() async {
    await _show(
      id: 400,
      channelId: _blockerChannelId,
      channelName: 'App Blocker',
      title: 'FocusGuard is protecting your focus',
      body: 'App blocking is active. Stay productive!',
      ongoing: true,
    );
  }

  /// Show bedtime mode reminder.
  Future<void> showBedtimeReminder() async {
    await _show(
      id: 500,
      channelId: _bedtimeChannelId,
      channelName: 'Bedtime Mode',
      title: 'Time to wind down 🌙',
      body:
          'Bedtime mode is about to activate. Put your phone down and get some rest.',
    );
  }

  /// Cancel a notification by ID.
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Schedule a notification at a specific time.
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
  }) async {
    // For simplicity, we use a periodic approach
    // In production, use flutter_local_notifications' zonedSchedule
    await _show(
      id: id,
      channelId: _nudgeChannelId,
      channelName: 'Smart Nudges',
      title: title,
      body: body,
    );
  }

  Future<void> _show({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    bool ongoing = false,
  }) async {
    if (!_initialized) await initialize();

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      ongoing: ongoing,
      autoCancel: !ongoing,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
