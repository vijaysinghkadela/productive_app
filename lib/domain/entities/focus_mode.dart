class FocusMode {
  // 1=Mon..7=Sun

  const FocusMode({
    required this.id,
    required this.name,
    this.icon = '🎯',
    this.blockedApps = const [],
    this.allowedApps = const [],
    this.notificationFilter = 'calls_only',
    this.ambientSound,
    this.durationMinutes,
    this.isBuiltIn = false,
    this.isActive = false,
    this.scheduleStart,
    this.scheduleEnd,
    this.scheduleDays = const [],
  });

  factory FocusMode.fromMap(Map<String, dynamic> m) => FocusMode(
        id: m['id'] as String,
        name: m['name'] as String,
        icon: m['icon'] as String? ?? '🎯',
        blockedApps: List<String>.from(m['blockedApps'] as List? ?? []),
        allowedApps: List<String>.from(m['allowedApps'] as List? ?? []),
        notificationFilter: m['notificationFilter'] as String? ?? 'calls_only',
        ambientSound: m['ambientSound'] as String?,
        durationMinutes: m['durationMinutes'] as int?,
        isBuiltIn: m['isBuiltIn'] as bool? ?? false,
        isActive: m['isActive'] as bool? ?? false,
        scheduleStart: m['scheduleStart'] as String?,
        scheduleEnd: m['scheduleEnd'] as String?,
        scheduleDays: List<int>.from(m['scheduleDays'] as List? ?? []),
      );
  final String id;
  final String name;
  final String icon; // emoji
  final List<String> blockedApps;
  final List<String> allowedApps;
  final String notificationFilter; // 'none', 'calls_only', 'all'
  final String? ambientSound;
  final int? durationMinutes;
  final bool isBuiltIn;
  final bool isActive;
  final String? scheduleStart; // HH:mm
  final String? scheduleEnd; // HH:mm
  final List<int> scheduleDays;

  FocusMode copyWith({
    String? name,
    String? icon,
    List<String>? blockedApps,
    List<String>? allowedApps,
    String? notificationFilter,
    String? ambientSound,
    int? durationMinutes,
    bool? isActive,
    String? scheduleStart,
    String? scheduleEnd,
    List<int>? scheduleDays,
  }) =>
      FocusMode(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        blockedApps: blockedApps ?? this.blockedApps,
        allowedApps: allowedApps ?? this.allowedApps,
        notificationFilter: notificationFilter ?? this.notificationFilter,
        ambientSound: ambientSound ?? this.ambientSound,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        isBuiltIn: isBuiltIn,
        isActive: isActive ?? this.isActive,
        scheduleStart: scheduleStart ?? this.scheduleStart,
        scheduleEnd: scheduleEnd ?? this.scheduleEnd,
        scheduleDays: scheduleDays ?? this.scheduleDays,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'blockedApps': blockedApps,
        'allowedApps': allowedApps,
        'notificationFilter': notificationFilter,
        'ambientSound': ambientSound,
        'durationMinutes': durationMinutes,
        'isBuiltIn': isBuiltIn,
        'isActive': isActive,
        'scheduleStart': scheduleStart,
        'scheduleEnd': scheduleEnd,
        'scheduleDays': scheduleDays,
      };
}

/// Pre-built focus mode templates
const List<FocusMode> builtInFocusModes = [
  FocusMode(
    id: 'work',
    name: 'Work Mode',
    icon: '💼',
    isBuiltIn: true,
  ),
  FocusMode(
    id: 'study',
    name: 'Study Mode',
    icon: '📚',
    isBuiltIn: true,
    notificationFilter: 'none',
  ),
  FocusMode(
    id: 'creative',
    name: 'Creative Mode',
    icon: '🎨',
    isBuiltIn: true,
  ),
  FocusMode(
    id: 'exercise',
    name: 'Exercise Mode',
    icon: '🏋️',
    isBuiltIn: true,
    notificationFilter: 'all',
  ),
  FocusMode(
    id: 'date_night',
    name: 'Date Night',
    icon: '❤️',
    isBuiltIn: true,
    notificationFilter: 'none',
  ),
  FocusMode(
    id: 'family',
    name: 'Family Time',
    icon: '👨‍👩‍👧‍👦',
    isBuiltIn: true,
  ),
  FocusMode(
    id: 'morning',
    name: 'Morning Routine',
    icon: '🌅',
    isBuiltIn: true,
    notificationFilter: 'none',
  ),
  FocusMode(
    id: 'evening',
    name: 'Evening Wind-Down',
    icon: '🌙',
    isBuiltIn: true,
    notificationFilter: 'none',
  ),
];
