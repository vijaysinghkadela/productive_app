import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;

/// Production device calendar integration.
///
/// Creates/manages focus session events in the device's native calendar,
/// syncs blocked time slots, and handles permission lifecycle.
class CalendarService {
  CalendarService._();
  static final CalendarService instance = CalendarService._();

  final DeviceCalendarPlugin _plugin = DeviceCalendarPlugin();
  String? _calendarId;
  bool _hasPermission = false;

  /// Request permissions and find or create the FocusGuard calendar.
  Future<bool> init() async {
    try {
      // Request calendar permissions
      var permResult = await _plugin.hasPermissions();
      if (permResult.isSuccess && !(permResult.data ?? false)) {
        permResult = await _plugin.requestPermissions();
      }

      _hasPermission = permResult.isSuccess && (permResult.data ?? false);
      if (!_hasPermission) {
        debugPrint('📅 Calendar permission denied');
        return false;
      }

      // Find existing FocusGuard calendar or use the default
      final calendarsResult = await _plugin.retrieveCalendars();
      if (!calendarsResult.isSuccess || calendarsResult.data == null) {
        return false;
      }

      final calendars = calendarsResult.data!;

      // Look for a calendar named "FocusGuard"
      final focusGuardCal = calendars.where(
        (c) => c.name?.contains('FocusGuard') == true,
      );

      if (focusGuardCal.isNotEmpty) {
        _calendarId = focusGuardCal.first.id;
      } else if (calendars.isNotEmpty) {
        // Fall back to the first writable calendar
        final writable = calendars.where((c) => !(c.isReadOnly ?? true));
        _calendarId =
            writable.isNotEmpty ? writable.first.id : calendars.first.id;
      }

      debugPrint('📅 Calendar initialized: $_calendarId');
      return _calendarId != null;
    } catch (e) {
      debugPrint('📅 Calendar init error: $e');
      return false;
    }
  }

  /// Create a calendar event for a completed focus session.
  Future<String?> addFocusSession({
    required String title,
    required DateTime startUtc,
    required DateTime endUtc,
    String? description,
  }) async {
    if (!_hasPermission || _calendarId == null) {
      final ok = await init();
      if (!ok) return null;
    }

    try {
      final event = Event(
        _calendarId,
        title: '🎯 $title',
        description: description ?? 'Focus session tracked by FocusGuard Pro',
        start: tz.TZDateTime.from(startUtc, tz.local),
        end: tz.TZDateTime.from(endUtc, tz.local),
        availability: Availability.Busy,
      );

      final result = await _plugin.createOrUpdateEvent(event);
      if (result?.isSuccess == true && result?.data != null) {
        debugPrint('📅 Created event: ${result!.data}');
        return result.data;
      }
      return null;
    } catch (e) {
      debugPrint('📅 Create event error: $e');
      return null;
    }
  }

  /// Delete a calendar event by its ID.
  Future<bool> removeEvent(String eventId) async {
    if (!_hasPermission || _calendarId == null) return false;
    try {
      final result = await _plugin.deleteEvent(_calendarId, eventId);
      return result.isSuccess;
    } catch (e) {
      debugPrint('📅 Delete event error: $e');
      return false;
    }
  }

  /// Retrieve upcoming events for the next N days from the device calendar.
  Future<List<Event>> getUpcomingEvents({int days = 7}) async {
    if (!_hasPermission || _calendarId == null) {
      final ok = await init();
      if (!ok) return [];
    }

    try {
      final now = tz.TZDateTime.now(tz.local);
      final end = now.add(Duration(days: days));

      final result = await _plugin.retrieveEvents(
        _calendarId,
        RetrieveEventsParams(startDate: now, endDate: end),
      );

      if (result.isSuccess && result.data != null) {
        return result.data!;
      }
      return [];
    } catch (e) {
      debugPrint('📅 Retrieve events error: $e');
      return [];
    }
  }

  /// Sync blocked app time slots as "busy" calendar events.
  Future<int> syncBlockedSlots(List<BlockedSlot> slots) async {
    if (!_hasPermission || _calendarId == null) {
      final ok = await init();
      if (!ok) return 0;
    }

    var synced = 0;
    for (final slot in slots) {
      final result = await addFocusSession(
        title: '🛑 ${slot.appName} blocked',
        startUtc: slot.startTime,
        endUtc: slot.endTime,
        description: 'App blocking enforced by FocusGuard Pro',
      );
      if (result != null) synced++;
    }
    return synced;
  }

  /// Check current permission status.
  Future<bool> hasPermission() async {
    final result = await _plugin.hasPermissions();
    _hasPermission = result.isSuccess && (result.data ?? false);
    return _hasPermission;
  }

  String? get calendarId => _calendarId;
}

/// Represents a blocked app time slot for calendar syncing.
class BlockedSlot {
  const BlockedSlot({
    required this.appName,
    required this.startTime,
    required this.endTime,
  });
  final String appName;
  final DateTime startTime;
  final DateTime endTime;
}
