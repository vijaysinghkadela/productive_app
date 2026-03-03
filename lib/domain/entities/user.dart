enum SubscriptionTier { free, basic, pro, elite }

class UserEntity {
  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.tier = SubscriptionTier.free,
    this.streakDays = 0,
    this.lastActiveDate,
    this.settings = const {},
  });
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final SubscriptionTier tier;
  final int streakDays;
  final DateTime? lastActiveDate;
  final Map<String, dynamic> settings;

  UserEntity copyWith({
    String? displayName,
    String? photoUrl,
    SubscriptionTier? tier,
    int? streakDays,
    DateTime? lastActiveDate,
    Map<String, dynamic>? settings,
  }) =>
      UserEntity(
        uid: uid,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl ?? this.photoUrl,
        tier: tier ?? this.tier,
        streakDays: streakDays ?? this.streakDays,
        lastActiveDate: lastActiveDate ?? this.lastActiveDate,
        settings: settings ?? this.settings,
      );
}
