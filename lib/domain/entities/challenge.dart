class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int durationDays;
  final int currentDay;
  final double progress; // 0.0 - 1.0
  final int participantCount;
  final String? reward; // badge name
  final int xpReward;
  final DateTime startDate;
  final DateTime endDate;
  final bool isCompleted;
  final bool isActive;
  final List<String> milestones;
  final List<String> completedMilestones;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.type = ChallengeType.community,
    required this.durationDays,
    this.currentDay = 0,
    this.progress = 0.0,
    this.participantCount = 0,
    this.reward,
    this.xpReward = 500,
    required this.startDate,
    required this.endDate,
    this.isCompleted = false,
    this.isActive = false,
    this.milestones = const [],
    this.completedMilestones = const [],
  });

  int get daysRemaining =>
      endDate.difference(DateTime.now()).inDays.clamp(0, durationDays);
  bool get isExpired => DateTime.now().isAfter(endDate);

  Challenge copyWith({
    int? currentDay,
    double? progress,
    int? participantCount,
    bool? isCompleted,
    bool? isActive,
    List<String>? completedMilestones,
  }) {
    return Challenge(
      id: id,
      title: title,
      description: description,
      type: type,
      durationDays: durationDays,
      currentDay: currentDay ?? this.currentDay,
      progress: progress ?? this.progress,
      participantCount: participantCount ?? this.participantCount,
      reward: reward,
      xpReward: xpReward,
      startDate: startDate,
      endDate: endDate,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      milestones: milestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'durationDays': durationDays,
        'currentDay': currentDay,
        'progress': progress,
        'participantCount': participantCount,
        'reward': reward,
        'xpReward': xpReward,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'isCompleted': isCompleted,
        'isActive': isActive,
        'milestones': milestones,
        'completedMilestones': completedMilestones,
      };

  factory Challenge.fromMap(Map<String, dynamic> m) => Challenge(
        id: m['id'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        type: ChallengeType.values.firstWhere((e) => e.name == m['type'],
            orElse: () => ChallengeType.community),
        durationDays: m['durationDays'] as int,
        currentDay: m['currentDay'] as int? ?? 0,
        progress: (m['progress'] as num?)?.toDouble() ?? 0.0,
        participantCount: m['participantCount'] as int? ?? 0,
        reward: m['reward'] as String?,
        xpReward: m['xpReward'] as int? ?? 500,
        startDate: DateTime.parse(m['startDate'] as String),
        endDate: DateTime.parse(m['endDate'] as String),
        isCompleted: m['isCompleted'] as bool? ?? false,
        isActive: m['isActive'] as bool? ?? false,
        milestones: List<String>.from(m['milestones'] as List? ?? []),
        completedMilestones:
            List<String>.from(m['completedMilestones'] as List? ?? []),
      );
}

enum ChallengeType { community, personal, friend, detox }
