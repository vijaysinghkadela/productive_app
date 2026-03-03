class DailyStat {
  const DailyStat({
    required this.date,
    this.appUsageMinutes = const {},
    this.totalScreenTimeMinutes = 0,
    this.socialMediaMinutes = 0,
    this.focusSessionsCompleted = 0,
    this.goalsCompleted = 0,
    this.productivityScore = 100,
  });

  factory DailyStat.fromMap(Map<String, dynamic> map) => DailyStat(
        date: map['date'] as String,
        appUsageMinutes:
            Map<String, int>.from(map['appUsageMinutes'] as Map? ?? {}),
        totalScreenTimeMinutes: map['totalScreenTimeMinutes'] as int? ?? 0,
        socialMediaMinutes: map['socialMediaMinutes'] as int? ?? 0,
        focusSessionsCompleted: map['focusSessionsCompleted'] as int? ?? 0,
        goalsCompleted: map['goalsCompleted'] as int? ?? 0,
        productivityScore: map['productivityScore'] as int? ?? 100,
      );
  final String date; // 'yyyy-MM-dd'
  final Map<String, int> appUsageMinutes; // { 'Instagram': 45, 'TikTok': 20 }
  final int totalScreenTimeMinutes;
  final int socialMediaMinutes;
  final int focusSessionsCompleted;
  final int goalsCompleted;
  final int productivityScore;

  DailyStat copyWith({
    Map<String, int>? appUsageMinutes,
    int? totalScreenTimeMinutes,
    int? socialMediaMinutes,
    int? focusSessionsCompleted,
    int? goalsCompleted,
    int? productivityScore,
  }) =>
      DailyStat(
        date: date,
        appUsageMinutes: appUsageMinutes ?? this.appUsageMinutes,
        totalScreenTimeMinutes:
            totalScreenTimeMinutes ?? this.totalScreenTimeMinutes,
        socialMediaMinutes: socialMediaMinutes ?? this.socialMediaMinutes,
        focusSessionsCompleted:
            focusSessionsCompleted ?? this.focusSessionsCompleted,
        goalsCompleted: goalsCompleted ?? this.goalsCompleted,
        productivityScore: productivityScore ?? this.productivityScore,
      );

  Map<String, dynamic> toMap() => {
        'date': date,
        'appUsageMinutes': appUsageMinutes,
        'totalScreenTimeMinutes': totalScreenTimeMinutes,
        'socialMediaMinutes': socialMediaMinutes,
        'focusSessionsCompleted': focusSessionsCompleted,
        'goalsCompleted': goalsCompleted,
        'productivityScore': productivityScore,
      };
}
