class FocusSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final int workMinutes;
  final int breakMinutes;
  final String sessionType; // 'Deep Work', 'Study', 'Creative', etc.
  final String? ambientSound;
  final bool completed;

  const FocusSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.workMinutes,
    required this.breakMinutes,
    required this.sessionType,
    this.ambientSound,
    this.completed = false,
  });

  Duration get duration {
    if (endTime != null) {
      return endTime!.difference(startTime);
    }
    return DateTime.now().difference(startTime);
  }

  FocusSession copyWith({
    DateTime? endTime,
    bool? completed,
  }) {
    return FocusSession(
      id: id,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      workMinutes: workMinutes,
      breakMinutes: breakMinutes,
      sessionType: sessionType,
      ambientSound: ambientSound,
      completed: completed ?? this.completed,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'workMinutes': workMinutes,
        'breakMinutes': breakMinutes,
        'sessionType': sessionType,
        'ambientSound': ambientSound,
        'completed': completed,
      };

  factory FocusSession.fromMap(Map<String, dynamic> map) => FocusSession(
        id: map['id'] as String,
        startTime: DateTime.parse(map['startTime'] as String),
        endTime: map['endTime'] != null
            ? DateTime.parse(map['endTime'] as String)
            : null,
        workMinutes: map['workMinutes'] as int,
        breakMinutes: map['breakMinutes'] as int,
        sessionType: map['sessionType'] as String,
        ambientSound: map['ambientSound'] as String?,
        completed: map['completed'] as bool? ?? false,
      );
}
