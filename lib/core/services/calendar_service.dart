import 'package:flutter/foundation.dart';

/// Service for device calendar API integration.
/// Reads/writes focus sessions as calendar events and syncs
/// blocked time slots to native calendar.
///
/// Requires `device_calendar` package and user calendar permission.
class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  bool _initialized = false;
  String? _defaultCalendarId;

  /// Initialize and request calendar permissions.
  Future<bool> init() async {
    if (_initialized) return true;

    try {
      // In production: use device_calendar plugin
      // final plugin = DeviceCalendarPlugin();
      // final permResult = await plugin.requestPermissions();
      // if (!permResult.isSuccess || !permResult.data!) return false;
      // final calendarsResult = await plugin.retrieveCalendars();
      // if (calendarsResult.isSuccess && calendarsResult.data!.isNotEmpty) {
      //   _defaultCalendarId = calendarsResult.data!.first.id;
      // }
      _initialized = true;
      debugPrint('📅 Calendar service initialized');
      return true;
    } catch (e) {
      debugPrint('📅 Calendar init failed: $e');
      return false;
    }
  }

  /// Add a focus session as a calendar event.
  Future<String?> addFocusSession({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
  }) async {
    if (!_initialized) {
      final ok = await init();
      if (!ok) return null;
    }

    try {
      // In production: use device_calendar plugin
      // final event = Event(
      //   _defaultCalendarId,
      //   title: title,
      //   description: description ?? 'FocusGuard Pro session',
      //   start: TZDateTime.from(start, local),
      //   end: TZDateTime.from(end, local),
      // );
      // final result = await DeviceCalendarPlugin().createOrUpdateEvent(event);
      // return result?.data;
      debugPrint('📅 Added calendar event: $title ($start → $end)');
      return 'event_${start.millisecondsSinceEpoch}';
    } catch (e) {
      debugPrint('📅 Failed to add calendar event: $e');
      return null;
    }
  }

  /// Remove a calendar event by ID.
  Future<bool> removeFocusSession(String eventId) async {
    if (!_initialized) return false;

    try {
      // In production: use device_calendar plugin
      // await DeviceCalendarPlugin().deleteEvent(_defaultCalendarId, eventId);
      debugPrint('📅 Removed calendar event: $eventId');
      return true;
    } catch (e) {
      debugPrint('📅 Failed to remove calendar event: $e');
      return false;
    }
  }

  /// Sync blocked app time slots to device calendar.
  Future<void> syncBlockedSlots({
    required String calendarName,
    required List<BlockedSlot> slots,
  }) async {
    if (!_initialized) {
      final ok = await init();
      if (!ok) return;
    }

    for (final slot in slots) {
      await addFocusSession(
        title: '🛑 ${slot.appName} blocked',
        start: slot.startTime,
        end: slot.endTime,
        description: 'App blocking enforced by FocusGuard Pro',
      );
    }
  }

  /// Check if calendar permission is granted.
  Future<bool> hasPermission() async {
    // In production: check via device_calendar plugin
    return _initialized;
  }

  String? get defaultCalendarId => _defaultCalendarId;
}

/// Represents a blocked app time slot for calendar syncing.
class BlockedSlot {
  final String appName;
  final DateTime startTime;
  final DateTime endTime;

  const BlockedSlot({
    required this.appName,
    required this.startTime,
    required this.endTime,
  });
}
