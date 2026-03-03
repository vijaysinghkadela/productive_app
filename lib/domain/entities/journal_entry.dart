class JournalEntry {
  final String id;
  final DateTime date;
  final String content;
  final int mood; // 1-5 (1=terrible, 5=amazing)
  final List<String> gratitude; // up to 3 items
  final List<String> tags;
  final int focusRating; // 1-10 self-rating
  final String? topDistraction;
  final String? tomorrowPriority;
  final bool isPinned;

  const JournalEntry({
    required this.id,
    required this.date,
    this.content = '',
    this.mood = 3,
    this.gratitude = const [],
    this.tags = const [],
    this.focusRating = 5,
    this.topDistraction,
    this.tomorrowPriority,
    this.isPinned = false,
  });

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😞';
      case 2:
        return '😐';
      case 3:
        return '🙂';
      case 4:
        return '😊';
      case 5:
        return '🤩';
      default:
        return '🙂';
    }
  }

  JournalEntry copyWith({
    String? content,
    int? mood,
    List<String>? gratitude,
    List<String>? tags,
    int? focusRating,
    String? topDistraction,
    String? tomorrowPriority,
    bool? isPinned,
  }) {
    return JournalEntry(
      id: id,
      date: date,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      gratitude: gratitude ?? this.gratitude,
      tags: tags ?? this.tags,
      focusRating: focusRating ?? this.focusRating,
      topDistraction: topDistraction ?? this.topDistraction,
      tomorrowPriority: tomorrowPriority ?? this.tomorrowPriority,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': date.toIso8601String(),
        'content': content,
        'mood': mood,
        'gratitude': gratitude,
        'tags': tags,
        'focusRating': focusRating,
        'topDistraction': topDistraction,
        'tomorrowPriority': tomorrowPriority,
        'isPinned': isPinned,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> m) => JournalEntry(
        id: m['id'] as String,
        date: DateTime.parse(m['date'] as String),
        content: m['content'] as String? ?? '',
        mood: m['mood'] as int? ?? 3,
        gratitude: List<String>.from(m['gratitude'] as List? ?? []),
        tags: List<String>.from(m['tags'] as List? ?? []),
        focusRating: m['focusRating'] as int? ?? 5,
        topDistraction: m['topDistraction'] as String?,
        tomorrowPriority: m['tomorrowPriority'] as String?,
        isPinned: m['isPinned'] as bool? ?? false,
      );
}
