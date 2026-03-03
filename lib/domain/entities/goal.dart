class AppGoal {
  final String appName;
  final String packageName;
  final int dailyLimitMinutes;
  final int currentUsageMinutes;
  final List<String> completedDates; // dates when goal was met

  const AppGoal({
    required this.appName,
    required this.packageName,
    required this.dailyLimitMinutes,
    this.currentUsageMinutes = 0,
    this.completedDates = const [],
  });

  bool get isGoalMet => currentUsageMinutes <= dailyLimitMinutes;
  double get progress => dailyLimitMinutes > 0
      ? (currentUsageMinutes / dailyLimitMinutes).clamp(0.0, 2.0)
      : 0.0;
  int get minutesRemaining =>
      (dailyLimitMinutes - currentUsageMinutes).clamp(0, dailyLimitMinutes);
  bool get isOverLimit => currentUsageMinutes > dailyLimitMinutes;
  int get minutesOver =>
      isOverLimit ? currentUsageMinutes - dailyLimitMinutes : 0;

  AppGoal copyWith({
    int? dailyLimitMinutes,
    int? currentUsageMinutes,
    List<String>? completedDates,
  }) {
    return AppGoal(
      appName: appName,
      packageName: packageName,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      currentUsageMinutes: currentUsageMinutes ?? this.currentUsageMinutes,
      completedDates: completedDates ?? this.completedDates,
    );
  }

  Map<String, dynamic> toMap() => {
        'appName': appName,
        'packageName': packageName,
        'dailyLimitMinutes': dailyLimitMinutes,
        'currentUsageMinutes': currentUsageMinutes,
        'completedDates': completedDates,
      };

  factory AppGoal.fromMap(Map<String, dynamic> map) => AppGoal(
        appName: map['appName'] as String,
        packageName: map['packageName'] as String,
        dailyLimitMinutes: map['dailyLimitMinutes'] as int,
        currentUsageMinutes: map['currentUsageMinutes'] as int? ?? 0,
        completedDates: List<String>.from(map['completedDates'] as List? ?? []),
      );
}
