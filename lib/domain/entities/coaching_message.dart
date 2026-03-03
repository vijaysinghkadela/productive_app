class CoachingMessage {
  const CoachingMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.insightType,
  });

  factory CoachingMessage.fromMap(Map<String, dynamic> m) => CoachingMessage(
        id: m['id'] as String,
        role: MessageRole.values.firstWhere(
          (e) => e.name == m['role'],
          orElse: () => MessageRole.assistant,
        ),
        content: m['content'] as String,
        timestamp: DateTime.parse(m['timestamp'] as String),
        insightType: m['insightType'] != null
            ? InsightType.values.firstWhere(
                (e) => e.name == m['insightType'],
                orElse: () => InsightType.general,
              )
            : null,
      );
  final String id;
  final MessageRole role; // user or assistant
  final String content;
  final DateTime timestamp;
  final InsightType? insightType;

  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.name,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'insightType': insightType?.name,
      };
}

enum MessageRole { user, assistant, system }

enum InsightType {
  general,
  patternAnalysis,
  weeklyReview,
  personalityAssessment,
  scheduleOptimization,
  challengeSuggestion,
  wellnessCheckIn,
}
