/// User data model with JSON serialization
class UserModel {
  const UserModel({
    required this.uid,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
    this.displayName,
    this.photoUrl,
    this.username,
    this.bio,
    this.streakDays = 0,
    this.totalFocusMinutes = 0,
    this.level = 1,
    this.totalXp = 0,
    this.subscriptionTier = 'free',
    this.accountabilityPartnerIds = const [],
    this.settings = const {},
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        username: json['username'] as String?,
        bio: json['bio'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
        streakDays: json['streakDays'] as int? ?? 0,
        totalFocusMinutes: json['totalFocusMinutes'] as int? ?? 0,
        level: json['level'] as int? ?? 1,
        totalXp: json['totalXp'] as int? ?? 0,
        subscriptionTier: json['subscriptionTier'] as String? ?? 'free',
        accountabilityPartnerIds: List<String>.from(
          json['accountabilityPartnerIds'] as Iterable<dynamic>? ?? [],
        ),
        settings: Map<String, dynamic>.from(json['settings'] as Map? ?? {}),
      );
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? username;
  final String? bio;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int streakDays;
  final int totalFocusMinutes;
  final int level;
  final int totalXp;
  final String subscriptionTier; // free, basic, pro, elite
  final List<String> accountabilityPartnerIds;
  final Map<String, dynamic> settings;

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'username': username,
        'bio': bio,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
        'streakDays': streakDays,
        'totalFocusMinutes': totalFocusMinutes,
        'level': level,
        'totalXp': totalXp,
        'subscriptionTier': subscriptionTier,
        'accountabilityPartnerIds': accountabilityPartnerIds,
        'settings': settings,
      };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? username,
    String? bio,
    int? streakDays,
    int? totalFocusMinutes,
    int? level,
    int? totalXp,
    String? subscriptionTier,
    List<String>? accountabilityPartnerIds,
    Map<String, dynamic>? settings,
    DateTime? lastLoginAt,
  }) =>
      UserModel(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        username: username ?? this.username,
        bio: bio ?? this.bio,
        createdAt: createdAt,
        lastLoginAt: lastLoginAt ?? this.lastLoginAt,
        streakDays: streakDays ?? this.streakDays,
        totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
        level: level ?? this.level,
        totalXp: totalXp ?? this.totalXp,
        subscriptionTier: subscriptionTier ?? this.subscriptionTier,
        accountabilityPartnerIds:
            accountabilityPartnerIds ?? this.accountabilityPartnerIds,
        settings: settings ?? this.settings,
      );
}
