class AppInfo {
  final String appName;
  final String packageName;
  final bool isBlocked;
  final bool isSocialMedia;
  final int? usageTodayMinutes;
  final List<BlockSchedule> blockSchedules;

  const AppInfo({
    required this.appName,
    required this.packageName,
    this.isBlocked = false,
    this.isSocialMedia = false,
    this.usageTodayMinutes,
    this.blockSchedules = const [],
  });

  AppInfo copyWith({
    bool? isBlocked,
    int? usageTodayMinutes,
    List<BlockSchedule>? blockSchedules,
  }) {
    return AppInfo(
      appName: appName,
      packageName: packageName,
      isBlocked: isBlocked ?? this.isBlocked,
      isSocialMedia: isSocialMedia,
      usageTodayMinutes: usageTodayMinutes ?? this.usageTodayMinutes,
      blockSchedules: blockSchedules ?? this.blockSchedules,
    );
  }

  Map<String, dynamic> toMap() => {
        'appName': appName,
        'packageName': packageName,
        'isBlocked': isBlocked,
        'isSocialMedia': isSocialMedia,
        'usageTodayMinutes': usageTodayMinutes,
        'blockSchedules': blockSchedules.map((s) => s.toMap()).toList(),
      };

  factory AppInfo.fromMap(Map<String, dynamic> map) => AppInfo(
        appName: map['appName'] as String,
        packageName: map['packageName'] as String,
        isBlocked: map['isBlocked'] as bool? ?? false,
        isSocialMedia: map['isSocialMedia'] as bool? ?? false,
        usageTodayMinutes: map['usageTodayMinutes'] as int?,
        blockSchedules: (map['blockSchedules'] as List?)
                ?.map((s) => BlockSchedule.fromMap(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class BlockSchedule {
  final String startTime; // 'HH:mm'
  final String endTime; // 'HH:mm'
  final List<int> daysOfWeek; // 1=Mon, 7=Sun

  const BlockSchedule({
    required this.startTime,
    required this.endTime,
    required this.daysOfWeek,
  });

  Map<String, dynamic> toMap() => {
        'startTime': startTime,
        'endTime': endTime,
        'daysOfWeek': daysOfWeek,
      };

  factory BlockSchedule.fromMap(Map<String, dynamic> map) => BlockSchedule(
        startTime: map['startTime'] as String,
        endTime: map['endTime'] as String,
        daysOfWeek: List<int>.from(map['daysOfWeek'] as List),
      );
}
