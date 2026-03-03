// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SessionsTable extends Sessions with TableInfo<$SessionsTable, Session> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sessionTypeMeta =
      const VerificationMeta('sessionType');
  @override
  late final GeneratedColumn<String> sessionType = GeneratedColumn<String>(
      'session_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Deep Work'));
  static const VerificationMeta _workMinutesMeta =
      const VerificationMeta('workMinutes');
  @override
  late final GeneratedColumn<int> workMinutes = GeneratedColumn<int>(
      'work_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(25));
  static const VerificationMeta _breakMinutesMeta =
      const VerificationMeta('breakMinutes');
  @override
  late final GeneratedColumn<int> breakMinutes = GeneratedColumn<int>(
      'break_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  static const VerificationMeta _startTimeMeta =
      const VerificationMeta('startTime');
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
      'start_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endTimeMeta =
      const VerificationMeta('endTime');
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
      'end_time', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _ambientSoundMeta =
      const VerificationMeta('ambientSound');
  @override
  late final GeneratedColumn<String> ambientSound = GeneratedColumn<String>(
      'ambient_sound', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _productivityScoreMeta =
      const VerificationMeta('productivityScore');
  @override
  late final GeneratedColumn<int> productivityScore = GeneratedColumn<int>(
      'productivity_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        sessionType,
        workMinutes,
        breakMinutes,
        startTime,
        endTime,
        completed,
        ambientSound,
        productivityScore,
        synced,
        lastModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(Insertable<Session> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('session_type')) {
      context.handle(
          _sessionTypeMeta,
          sessionType.isAcceptableOrUnknown(
              data['session_type']!, _sessionTypeMeta));
    }
    if (data.containsKey('work_minutes')) {
      context.handle(
          _workMinutesMeta,
          workMinutes.isAcceptableOrUnknown(
              data['work_minutes']!, _workMinutesMeta));
    }
    if (data.containsKey('break_minutes')) {
      context.handle(
          _breakMinutesMeta,
          breakMinutes.isAcceptableOrUnknown(
              data['break_minutes']!, _breakMinutesMeta));
    }
    if (data.containsKey('start_time')) {
      context.handle(_startTimeMeta,
          startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(_endTimeMeta,
          endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('ambient_sound')) {
      context.handle(
          _ambientSoundMeta,
          ambientSound.isAcceptableOrUnknown(
              data['ambient_sound']!, _ambientSoundMeta));
    }
    if (data.containsKey('productivity_score')) {
      context.handle(
          _productivityScoreMeta,
          productivityScore.isAcceptableOrUnknown(
              data['productivity_score']!, _productivityScoreMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Session map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Session(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      sessionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}session_type'])!,
      workMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}work_minutes'])!,
      breakMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}break_minutes'])!,
      startTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!,
      endTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_time']),
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      ambientSound: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ambient_sound']),
      productivityScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}productivity_score'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      lastModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class Session extends DataClass implements Insertable<Session> {
  final String id;
  final String userId;
  final String sessionType;
  final int workMinutes;
  final int breakMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool completed;
  final String? ambientSound;
  final int productivityScore;
  final bool synced;
  final DateTime lastModified;
  const Session(
      {required this.id,
      required this.userId,
      required this.sessionType,
      required this.workMinutes,
      required this.breakMinutes,
      required this.startTime,
      this.endTime,
      required this.completed,
      this.ambientSound,
      required this.productivityScore,
      required this.synced,
      required this.lastModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['session_type'] = Variable<String>(sessionType);
    map['work_minutes'] = Variable<int>(workMinutes);
    map['break_minutes'] = Variable<int>(breakMinutes);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['completed'] = Variable<bool>(completed);
    if (!nullToAbsent || ambientSound != null) {
      map['ambient_sound'] = Variable<String>(ambientSound);
    }
    map['productivity_score'] = Variable<int>(productivityScore);
    map['synced'] = Variable<bool>(synced);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      userId: Value(userId),
      sessionType: Value(sessionType),
      workMinutes: Value(workMinutes),
      breakMinutes: Value(breakMinutes),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      completed: Value(completed),
      ambientSound: ambientSound == null && nullToAbsent
          ? const Value.absent()
          : Value(ambientSound),
      productivityScore: Value(productivityScore),
      synced: Value(synced),
      lastModified: Value(lastModified),
    );
  }

  factory Session.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Session(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      sessionType: serializer.fromJson<String>(json['sessionType']),
      workMinutes: serializer.fromJson<int>(json['workMinutes']),
      breakMinutes: serializer.fromJson<int>(json['breakMinutes']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      completed: serializer.fromJson<bool>(json['completed']),
      ambientSound: serializer.fromJson<String?>(json['ambientSound']),
      productivityScore: serializer.fromJson<int>(json['productivityScore']),
      synced: serializer.fromJson<bool>(json['synced']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'sessionType': serializer.toJson<String>(sessionType),
      'workMinutes': serializer.toJson<int>(workMinutes),
      'breakMinutes': serializer.toJson<int>(breakMinutes),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'completed': serializer.toJson<bool>(completed),
      'ambientSound': serializer.toJson<String?>(ambientSound),
      'productivityScore': serializer.toJson<int>(productivityScore),
      'synced': serializer.toJson<bool>(synced),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  Session copyWith(
          {String? id,
          String? userId,
          String? sessionType,
          int? workMinutes,
          int? breakMinutes,
          DateTime? startTime,
          Value<DateTime?> endTime = const Value.absent(),
          bool? completed,
          Value<String?> ambientSound = const Value.absent(),
          int? productivityScore,
          bool? synced,
          DateTime? lastModified}) =>
      Session(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        sessionType: sessionType ?? this.sessionType,
        workMinutes: workMinutes ?? this.workMinutes,
        breakMinutes: breakMinutes ?? this.breakMinutes,
        startTime: startTime ?? this.startTime,
        endTime: endTime.present ? endTime.value : this.endTime,
        completed: completed ?? this.completed,
        ambientSound:
            ambientSound.present ? ambientSound.value : this.ambientSound,
        productivityScore: productivityScore ?? this.productivityScore,
        synced: synced ?? this.synced,
        lastModified: lastModified ?? this.lastModified,
      );
  Session copyWithCompanion(SessionsCompanion data) {
    return Session(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      sessionType:
          data.sessionType.present ? data.sessionType.value : this.sessionType,
      workMinutes:
          data.workMinutes.present ? data.workMinutes.value : this.workMinutes,
      breakMinutes: data.breakMinutes.present
          ? data.breakMinutes.value
          : this.breakMinutes,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      completed: data.completed.present ? data.completed.value : this.completed,
      ambientSound: data.ambientSound.present
          ? data.ambientSound.value
          : this.ambientSound,
      productivityScore: data.productivityScore.present
          ? data.productivityScore.value
          : this.productivityScore,
      synced: data.synced.present ? data.synced.value : this.synced,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Session(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionType: $sessionType, ')
          ..write('workMinutes: $workMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('completed: $completed, ')
          ..write('ambientSound: $ambientSound, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      sessionType,
      workMinutes,
      breakMinutes,
      startTime,
      endTime,
      completed,
      ambientSound,
      productivityScore,
      synced,
      lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Session &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.sessionType == this.sessionType &&
          other.workMinutes == this.workMinutes &&
          other.breakMinutes == this.breakMinutes &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.completed == this.completed &&
          other.ambientSound == this.ambientSound &&
          other.productivityScore == this.productivityScore &&
          other.synced == this.synced &&
          other.lastModified == this.lastModified);
}

class SessionsCompanion extends UpdateCompanion<Session> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> sessionType;
  final Value<int> workMinutes;
  final Value<int> breakMinutes;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<bool> completed;
  final Value<String?> ambientSound;
  final Value<int> productivityScore;
  final Value<bool> synced;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.workMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.completed = const Value.absent(),
    this.ambientSound = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    this.sessionType = const Value.absent(),
    this.workMinutes = const Value.absent(),
    this.breakMinutes = const Value.absent(),
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.completed = const Value.absent(),
    this.ambientSound = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        startTime = Value(startTime);
  static Insertable<Session> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? sessionType,
    Expression<int>? workMinutes,
    Expression<int>? breakMinutes,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<bool>? completed,
    Expression<String>? ambientSound,
    Expression<int>? productivityScore,
    Expression<bool>? synced,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (sessionType != null) 'session_type': sessionType,
      if (workMinutes != null) 'work_minutes': workMinutes,
      if (breakMinutes != null) 'break_minutes': breakMinutes,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (completed != null) 'completed': completed,
      if (ambientSound != null) 'ambient_sound': ambientSound,
      if (productivityScore != null) 'productivity_score': productivityScore,
      if (synced != null) 'synced': synced,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? sessionType,
      Value<int>? workMinutes,
      Value<int>? breakMinutes,
      Value<DateTime>? startTime,
      Value<DateTime?>? endTime,
      Value<bool>? completed,
      Value<String?>? ambientSound,
      Value<int>? productivityScore,
      Value<bool>? synced,
      Value<DateTime>? lastModified,
      Value<int>? rowid}) {
    return SessionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      sessionType: sessionType ?? this.sessionType,
      workMinutes: workMinutes ?? this.workMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      completed: completed ?? this.completed,
      ambientSound: ambientSound ?? this.ambientSound,
      productivityScore: productivityScore ?? this.productivityScore,
      synced: synced ?? this.synced,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (sessionType.present) {
      map['session_type'] = Variable<String>(sessionType.value);
    }
    if (workMinutes.present) {
      map['work_minutes'] = Variable<int>(workMinutes.value);
    }
    if (breakMinutes.present) {
      map['break_minutes'] = Variable<int>(breakMinutes.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (ambientSound.present) {
      map['ambient_sound'] = Variable<String>(ambientSound.value);
    }
    if (productivityScore.present) {
      map['productivity_score'] = Variable<int>(productivityScore.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('sessionType: $sessionType, ')
          ..write('workMinutes: $workMinutes, ')
          ..write('breakMinutes: $breakMinutes, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('completed: $completed, ')
          ..write('ambientSound: $ambientSound, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyStatsTable extends DailyStats
    with TableInfo<$DailyStatsTable, DailyStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateKeyMeta =
      const VerificationMeta('dateKey');
  @override
  late final GeneratedColumn<String> dateKey = GeneratedColumn<String>(
      'date_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _totalScreenTimeMinutesMeta =
      const VerificationMeta('totalScreenTimeMinutes');
  @override
  late final GeneratedColumn<int> totalScreenTimeMinutes = GeneratedColumn<int>(
      'total_screen_time_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _socialMediaMinutesMeta =
      const VerificationMeta('socialMediaMinutes');
  @override
  late final GeneratedColumn<int> socialMediaMinutes = GeneratedColumn<int>(
      'social_media_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _focusMinutesMeta =
      const VerificationMeta('focusMinutes');
  @override
  late final GeneratedColumn<int> focusMinutes = GeneratedColumn<int>(
      'focus_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _focusSessionsCompletedMeta =
      const VerificationMeta('focusSessionsCompleted');
  @override
  late final GeneratedColumn<int> focusSessionsCompleted = GeneratedColumn<int>(
      'focus_sessions_completed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _productivityScoreMeta =
      const VerificationMeta('productivityScore');
  @override
  late final GeneratedColumn<int> productivityScore = GeneratedColumn<int>(
      'productivity_score', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _appUnlocksMeta =
      const VerificationMeta('appUnlocks');
  @override
  late final GeneratedColumn<int> appUnlocks = GeneratedColumn<int>(
      'app_unlocks', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        dateKey,
        userId,
        totalScreenTimeMinutes,
        socialMediaMinutes,
        focusMinutes,
        focusSessionsCompleted,
        productivityScore,
        appUnlocks,
        synced,
        lastModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_stats';
  @override
  VerificationContext validateIntegrity(Insertable<DailyStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date_key')) {
      context.handle(_dateKeyMeta,
          dateKey.isAcceptableOrUnknown(data['date_key']!, _dateKeyMeta));
    } else if (isInserting) {
      context.missing(_dateKeyMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('total_screen_time_minutes')) {
      context.handle(
          _totalScreenTimeMinutesMeta,
          totalScreenTimeMinutes.isAcceptableOrUnknown(
              data['total_screen_time_minutes']!, _totalScreenTimeMinutesMeta));
    }
    if (data.containsKey('social_media_minutes')) {
      context.handle(
          _socialMediaMinutesMeta,
          socialMediaMinutes.isAcceptableOrUnknown(
              data['social_media_minutes']!, _socialMediaMinutesMeta));
    }
    if (data.containsKey('focus_minutes')) {
      context.handle(
          _focusMinutesMeta,
          focusMinutes.isAcceptableOrUnknown(
              data['focus_minutes']!, _focusMinutesMeta));
    }
    if (data.containsKey('focus_sessions_completed')) {
      context.handle(
          _focusSessionsCompletedMeta,
          focusSessionsCompleted.isAcceptableOrUnknown(
              data['focus_sessions_completed']!, _focusSessionsCompletedMeta));
    }
    if (data.containsKey('productivity_score')) {
      context.handle(
          _productivityScoreMeta,
          productivityScore.isAcceptableOrUnknown(
              data['productivity_score']!, _productivityScoreMeta));
    }
    if (data.containsKey('app_unlocks')) {
      context.handle(
          _appUnlocksMeta,
          appUnlocks.isAcceptableOrUnknown(
              data['app_unlocks']!, _appUnlocksMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dateKey};
  @override
  DailyStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStat(
      dateKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date_key'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      totalScreenTimeMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}total_screen_time_minutes'])!,
      socialMediaMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}social_media_minutes'])!,
      focusMinutes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}focus_minutes'])!,
      focusSessionsCompleted: attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}focus_sessions_completed'])!,
      productivityScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}productivity_score'])!,
      appUnlocks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}app_unlocks'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      lastModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!,
    );
  }

  @override
  $DailyStatsTable createAlias(String alias) {
    return $DailyStatsTable(attachedDatabase, alias);
  }
}

class DailyStat extends DataClass implements Insertable<DailyStat> {
  final String dateKey;
  final String userId;
  final int totalScreenTimeMinutes;
  final int socialMediaMinutes;
  final int focusMinutes;
  final int focusSessionsCompleted;
  final int productivityScore;
  final int appUnlocks;
  final bool synced;
  final DateTime lastModified;
  const DailyStat(
      {required this.dateKey,
      required this.userId,
      required this.totalScreenTimeMinutes,
      required this.socialMediaMinutes,
      required this.focusMinutes,
      required this.focusSessionsCompleted,
      required this.productivityScore,
      required this.appUnlocks,
      required this.synced,
      required this.lastModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date_key'] = Variable<String>(dateKey);
    map['user_id'] = Variable<String>(userId);
    map['total_screen_time_minutes'] = Variable<int>(totalScreenTimeMinutes);
    map['social_media_minutes'] = Variable<int>(socialMediaMinutes);
    map['focus_minutes'] = Variable<int>(focusMinutes);
    map['focus_sessions_completed'] = Variable<int>(focusSessionsCompleted);
    map['productivity_score'] = Variable<int>(productivityScore);
    map['app_unlocks'] = Variable<int>(appUnlocks);
    map['synced'] = Variable<bool>(synced);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  DailyStatsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatsCompanion(
      dateKey: Value(dateKey),
      userId: Value(userId),
      totalScreenTimeMinutes: Value(totalScreenTimeMinutes),
      socialMediaMinutes: Value(socialMediaMinutes),
      focusMinutes: Value(focusMinutes),
      focusSessionsCompleted: Value(focusSessionsCompleted),
      productivityScore: Value(productivityScore),
      appUnlocks: Value(appUnlocks),
      synced: Value(synced),
      lastModified: Value(lastModified),
    );
  }

  factory DailyStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStat(
      dateKey: serializer.fromJson<String>(json['dateKey']),
      userId: serializer.fromJson<String>(json['userId']),
      totalScreenTimeMinutes:
          serializer.fromJson<int>(json['totalScreenTimeMinutes']),
      socialMediaMinutes: serializer.fromJson<int>(json['socialMediaMinutes']),
      focusMinutes: serializer.fromJson<int>(json['focusMinutes']),
      focusSessionsCompleted:
          serializer.fromJson<int>(json['focusSessionsCompleted']),
      productivityScore: serializer.fromJson<int>(json['productivityScore']),
      appUnlocks: serializer.fromJson<int>(json['appUnlocks']),
      synced: serializer.fromJson<bool>(json['synced']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dateKey': serializer.toJson<String>(dateKey),
      'userId': serializer.toJson<String>(userId),
      'totalScreenTimeMinutes': serializer.toJson<int>(totalScreenTimeMinutes),
      'socialMediaMinutes': serializer.toJson<int>(socialMediaMinutes),
      'focusMinutes': serializer.toJson<int>(focusMinutes),
      'focusSessionsCompleted': serializer.toJson<int>(focusSessionsCompleted),
      'productivityScore': serializer.toJson<int>(productivityScore),
      'appUnlocks': serializer.toJson<int>(appUnlocks),
      'synced': serializer.toJson<bool>(synced),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  DailyStat copyWith(
          {String? dateKey,
          String? userId,
          int? totalScreenTimeMinutes,
          int? socialMediaMinutes,
          int? focusMinutes,
          int? focusSessionsCompleted,
          int? productivityScore,
          int? appUnlocks,
          bool? synced,
          DateTime? lastModified}) =>
      DailyStat(
        dateKey: dateKey ?? this.dateKey,
        userId: userId ?? this.userId,
        totalScreenTimeMinutes:
            totalScreenTimeMinutes ?? this.totalScreenTimeMinutes,
        socialMediaMinutes: socialMediaMinutes ?? this.socialMediaMinutes,
        focusMinutes: focusMinutes ?? this.focusMinutes,
        focusSessionsCompleted:
            focusSessionsCompleted ?? this.focusSessionsCompleted,
        productivityScore: productivityScore ?? this.productivityScore,
        appUnlocks: appUnlocks ?? this.appUnlocks,
        synced: synced ?? this.synced,
        lastModified: lastModified ?? this.lastModified,
      );
  DailyStat copyWithCompanion(DailyStatsCompanion data) {
    return DailyStat(
      dateKey: data.dateKey.present ? data.dateKey.value : this.dateKey,
      userId: data.userId.present ? data.userId.value : this.userId,
      totalScreenTimeMinutes: data.totalScreenTimeMinutes.present
          ? data.totalScreenTimeMinutes.value
          : this.totalScreenTimeMinutes,
      socialMediaMinutes: data.socialMediaMinutes.present
          ? data.socialMediaMinutes.value
          : this.socialMediaMinutes,
      focusMinutes: data.focusMinutes.present
          ? data.focusMinutes.value
          : this.focusMinutes,
      focusSessionsCompleted: data.focusSessionsCompleted.present
          ? data.focusSessionsCompleted.value
          : this.focusSessionsCompleted,
      productivityScore: data.productivityScore.present
          ? data.productivityScore.value
          : this.productivityScore,
      appUnlocks:
          data.appUnlocks.present ? data.appUnlocks.value : this.appUnlocks,
      synced: data.synced.present ? data.synced.value : this.synced,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStat(')
          ..write('dateKey: $dateKey, ')
          ..write('userId: $userId, ')
          ..write('totalScreenTimeMinutes: $totalScreenTimeMinutes, ')
          ..write('socialMediaMinutes: $socialMediaMinutes, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('focusSessionsCompleted: $focusSessionsCompleted, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('appUnlocks: $appUnlocks, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      dateKey,
      userId,
      totalScreenTimeMinutes,
      socialMediaMinutes,
      focusMinutes,
      focusSessionsCompleted,
      productivityScore,
      appUnlocks,
      synced,
      lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStat &&
          other.dateKey == this.dateKey &&
          other.userId == this.userId &&
          other.totalScreenTimeMinutes == this.totalScreenTimeMinutes &&
          other.socialMediaMinutes == this.socialMediaMinutes &&
          other.focusMinutes == this.focusMinutes &&
          other.focusSessionsCompleted == this.focusSessionsCompleted &&
          other.productivityScore == this.productivityScore &&
          other.appUnlocks == this.appUnlocks &&
          other.synced == this.synced &&
          other.lastModified == this.lastModified);
}

class DailyStatsCompanion extends UpdateCompanion<DailyStat> {
  final Value<String> dateKey;
  final Value<String> userId;
  final Value<int> totalScreenTimeMinutes;
  final Value<int> socialMediaMinutes;
  final Value<int> focusMinutes;
  final Value<int> focusSessionsCompleted;
  final Value<int> productivityScore;
  final Value<int> appUnlocks;
  final Value<bool> synced;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const DailyStatsCompanion({
    this.dateKey = const Value.absent(),
    this.userId = const Value.absent(),
    this.totalScreenTimeMinutes = const Value.absent(),
    this.socialMediaMinutes = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.focusSessionsCompleted = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.appUnlocks = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyStatsCompanion.insert({
    required String dateKey,
    this.userId = const Value.absent(),
    this.totalScreenTimeMinutes = const Value.absent(),
    this.socialMediaMinutes = const Value.absent(),
    this.focusMinutes = const Value.absent(),
    this.focusSessionsCompleted = const Value.absent(),
    this.productivityScore = const Value.absent(),
    this.appUnlocks = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dateKey = Value(dateKey);
  static Insertable<DailyStat> custom({
    Expression<String>? dateKey,
    Expression<String>? userId,
    Expression<int>? totalScreenTimeMinutes,
    Expression<int>? socialMediaMinutes,
    Expression<int>? focusMinutes,
    Expression<int>? focusSessionsCompleted,
    Expression<int>? productivityScore,
    Expression<int>? appUnlocks,
    Expression<bool>? synced,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dateKey != null) 'date_key': dateKey,
      if (userId != null) 'user_id': userId,
      if (totalScreenTimeMinutes != null)
        'total_screen_time_minutes': totalScreenTimeMinutes,
      if (socialMediaMinutes != null)
        'social_media_minutes': socialMediaMinutes,
      if (focusMinutes != null) 'focus_minutes': focusMinutes,
      if (focusSessionsCompleted != null)
        'focus_sessions_completed': focusSessionsCompleted,
      if (productivityScore != null) 'productivity_score': productivityScore,
      if (appUnlocks != null) 'app_unlocks': appUnlocks,
      if (synced != null) 'synced': synced,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyStatsCompanion copyWith(
      {Value<String>? dateKey,
      Value<String>? userId,
      Value<int>? totalScreenTimeMinutes,
      Value<int>? socialMediaMinutes,
      Value<int>? focusMinutes,
      Value<int>? focusSessionsCompleted,
      Value<int>? productivityScore,
      Value<int>? appUnlocks,
      Value<bool>? synced,
      Value<DateTime>? lastModified,
      Value<int>? rowid}) {
    return DailyStatsCompanion(
      dateKey: dateKey ?? this.dateKey,
      userId: userId ?? this.userId,
      totalScreenTimeMinutes:
          totalScreenTimeMinutes ?? this.totalScreenTimeMinutes,
      socialMediaMinutes: socialMediaMinutes ?? this.socialMediaMinutes,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      focusSessionsCompleted:
          focusSessionsCompleted ?? this.focusSessionsCompleted,
      productivityScore: productivityScore ?? this.productivityScore,
      appUnlocks: appUnlocks ?? this.appUnlocks,
      synced: synced ?? this.synced,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dateKey.present) {
      map['date_key'] = Variable<String>(dateKey.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (totalScreenTimeMinutes.present) {
      map['total_screen_time_minutes'] =
          Variable<int>(totalScreenTimeMinutes.value);
    }
    if (socialMediaMinutes.present) {
      map['social_media_minutes'] = Variable<int>(socialMediaMinutes.value);
    }
    if (focusMinutes.present) {
      map['focus_minutes'] = Variable<int>(focusMinutes.value);
    }
    if (focusSessionsCompleted.present) {
      map['focus_sessions_completed'] =
          Variable<int>(focusSessionsCompleted.value);
    }
    if (productivityScore.present) {
      map['productivity_score'] = Variable<int>(productivityScore.value);
    }
    if (appUnlocks.present) {
      map['app_unlocks'] = Variable<int>(appUnlocks.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatsCompanion(')
          ..write('dateKey: $dateKey, ')
          ..write('userId: $userId, ')
          ..write('totalScreenTimeMinutes: $totalScreenTimeMinutes, ')
          ..write('socialMediaMinutes: $socialMediaMinutes, ')
          ..write('focusMinutes: $focusMinutes, ')
          ..write('focusSessionsCompleted: $focusSessionsCompleted, ')
          ..write('productivityScore: $productivityScore, ')
          ..write('appUnlocks: $appUnlocks, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KanbanTasksTable extends KanbanTasks
    with TableInfo<$KanbanTasksTable, KanbanTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KanbanTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 500),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
      'labels', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        description,
        status,
        priority,
        createdAt,
        dueDate,
        labels,
        sortOrder,
        synced,
        lastModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kanban_tasks';
  @override
  VerificationContext validateIntegrity(Insertable<KanbanTask> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('labels')) {
      context.handle(_labelsMeta,
          labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KanbanTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KanbanTask(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      labels: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}labels'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      lastModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!,
    );
  }

  @override
  $KanbanTasksTable createAlias(String alias) {
    return $KanbanTasksTable(attachedDatabase, alias);
  }
}

class KanbanTask extends DataClass implements Insertable<KanbanTask> {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final int status;
  final int priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String labels;
  final int sortOrder;
  final bool synced;
  final DateTime lastModified;
  const KanbanTask(
      {required this.id,
      required this.userId,
      required this.title,
      this.description,
      required this.status,
      required this.priority,
      required this.createdAt,
      this.dueDate,
      required this.labels,
      required this.sortOrder,
      required this.synced,
      required this.lastModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<int>(status);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['labels'] = Variable<String>(labels);
    map['sort_order'] = Variable<int>(sortOrder);
    map['synced'] = Variable<bool>(synced);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  KanbanTasksCompanion toCompanion(bool nullToAbsent) {
    return KanbanTasksCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      priority: Value(priority),
      createdAt: Value(createdAt),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      labels: Value(labels),
      sortOrder: Value(sortOrder),
      synced: Value(synced),
      lastModified: Value(lastModified),
    );
  }

  factory KanbanTask.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KanbanTask(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<int>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      labels: serializer.fromJson<String>(json['labels']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      synced: serializer.fromJson<bool>(json['synced']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<int>(status),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'labels': serializer.toJson<String>(labels),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'synced': serializer.toJson<bool>(synced),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  KanbanTask copyWith(
          {String? id,
          String? userId,
          String? title,
          Value<String?> description = const Value.absent(),
          int? status,
          int? priority,
          DateTime? createdAt,
          Value<DateTime?> dueDate = const Value.absent(),
          String? labels,
          int? sortOrder,
          bool? synced,
          DateTime? lastModified}) =>
      KanbanTask(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        createdAt: createdAt ?? this.createdAt,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        labels: labels ?? this.labels,
        sortOrder: sortOrder ?? this.sortOrder,
        synced: synced ?? this.synced,
        lastModified: lastModified ?? this.lastModified,
      );
  KanbanTask copyWithCompanion(KanbanTasksCompanion data) {
    return KanbanTask(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      labels: data.labels.present ? data.labels.value : this.labels,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      synced: data.synced.present ? data.synced.value : this.synced,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KanbanTask(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('labels: $labels, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, title, description, status,
      priority, createdAt, dueDate, labels, sortOrder, synced, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KanbanTask &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.description == this.description &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.dueDate == this.dueDate &&
          other.labels == this.labels &&
          other.sortOrder == this.sortOrder &&
          other.synced == this.synced &&
          other.lastModified == this.lastModified);
}

class KanbanTasksCompanion extends UpdateCompanion<KanbanTask> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> status;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime?> dueDate;
  final Value<String> labels;
  final Value<int> sortOrder;
  final Value<bool> synced;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const KanbanTasksCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.labels = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KanbanTasksCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    required DateTime createdAt,
    this.dueDate = const Value.absent(),
    this.labels = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<KanbanTask> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? status,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? dueDate,
    Expression<String>? labels,
    Expression<int>? sortOrder,
    Expression<bool>? synced,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (dueDate != null) 'due_date': dueDate,
      if (labels != null) 'labels': labels,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (synced != null) 'synced': synced,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KanbanTasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? status,
      Value<int>? priority,
      Value<DateTime>? createdAt,
      Value<DateTime?>? dueDate,
      Value<String>? labels,
      Value<int>? sortOrder,
      Value<bool>? synced,
      Value<DateTime>? lastModified,
      Value<int>? rowid}) {
    return KanbanTasksCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      labels: labels ?? this.labels,
      sortOrder: sortOrder ?? this.sortOrder,
      synced: synced ?? this.synced,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KanbanTasksCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('dueDate: $dueDate, ')
          ..write('labels: $labels, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _collectionMeta =
      const VerificationMeta('collection');
  @override
  late final GeneratedColumn<String> collection = GeneratedColumn<String>(
      'collection', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _documentIdMeta =
      const VerificationMeta('documentId');
  @override
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(5));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        collection,
        documentId,
        operation,
        payload,
        createdAt,
        retryCount,
        maxRetries
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection')) {
      context.handle(
          _collectionMeta,
          collection.isAcceptableOrUnknown(
              data['collection']!, _collectionMeta));
    } else if (isInserting) {
      context.missing(_collectionMeta);
    }
    if (data.containsKey('document_id')) {
      context.handle(
          _documentIdMeta,
          documentId.isAcceptableOrUnknown(
              data['document_id']!, _documentIdMeta));
    } else if (isInserting) {
      context.missing(_documentIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      collection: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}collection'])!,
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;
  final String collection;
  final String documentId;
  final String operation;
  final String payload;
  final DateTime createdAt;
  final int retryCount;
  final int maxRetries;
  const SyncQueueData(
      {required this.id,
      required this.collection,
      required this.documentId,
      required this.operation,
      required this.payload,
      required this.createdAt,
      required this.retryCount,
      required this.maxRetries});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['collection'] = Variable<String>(collection);
    map['document_id'] = Variable<String>(documentId);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      collection: Value(collection),
      documentId: Value(documentId),
      operation: Value(operation),
      payload: Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      collection: serializer.fromJson<String>(json['collection']),
      documentId: serializer.fromJson<String>(json['documentId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collection': serializer.toJson<String>(collection),
      'documentId': serializer.toJson<String>(documentId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
    };
  }

  SyncQueueData copyWith(
          {int? id,
          String? collection,
          String? documentId,
          String? operation,
          String? payload,
          DateTime? createdAt,
          int? retryCount,
          int? maxRetries}) =>
      SyncQueueData(
        id: id ?? this.id,
        collection: collection ?? this.collection,
        documentId: documentId ?? this.documentId,
        operation: operation ?? this.operation,
        payload: payload ?? this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
      );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      collection:
          data.collection.present ? data.collection.value : this.collection,
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('collection: $collection, ')
          ..write('documentId: $documentId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collection, documentId, operation,
      payload, createdAt, retryCount, maxRetries);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.collection == this.collection &&
          other.documentId == this.documentId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> collection;
  final Value<String> documentId;
  final Value<String> operation;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.collection = const Value.absent(),
    this.documentId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String collection,
    required String documentId,
    required String operation,
    required String payload,
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
  })  : collection = Value(collection),
        documentId = Value(documentId),
        operation = Value(operation),
        payload = Value(payload);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? collection,
    Expression<String>? documentId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collection != null) 'collection': collection,
      if (documentId != null) 'document_id': documentId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
    });
  }

  SyncQueueCompanion copyWith(
      {Value<int>? id,
      Value<String>? collection,
      Value<String>? documentId,
      Value<String>? operation,
      Value<String>? payload,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<int>? maxRetries}) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      collection: collection ?? this.collection,
      documentId: documentId ?? this.documentId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (collection.present) {
      map['collection'] = Variable<String>(collection.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('collection: $collection, ')
          ..write('documentId: $documentId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta =
      const VerificationMeta('packageName');
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
      'package_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _appNameMeta =
      const VerificationMeta('appName');
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
      'app_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dailyLimitMinutesMeta =
      const VerificationMeta('dailyLimitMinutes');
  @override
  late final GeneratedColumn<int> dailyLimitMinutes = GeneratedColumn<int>(
      'daily_limit_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(60));
  static const VerificationMeta _currentUsageMinutesMeta =
      const VerificationMeta('currentUsageMinutes');
  @override
  late final GeneratedColumn<int> currentUsageMinutes = GeneratedColumn<int>(
      'current_usage_minutes', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isBlockedMeta =
      const VerificationMeta('isBlocked');
  @override
  late final GeneratedColumn<bool> isBlocked = GeneratedColumn<bool>(
      'is_blocked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_blocked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
      'synced', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("synced" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _lastModifiedMeta =
      const VerificationMeta('lastModified');
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
      'last_modified', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        packageName,
        appName,
        dailyLimitMinutes,
        currentUsageMinutes,
        isBlocked,
        synced,
        lastModified
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
          _packageNameMeta,
          packageName.isAcceptableOrUnknown(
              data['package_name']!, _packageNameMeta));
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(_appNameMeta,
          appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta));
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('daily_limit_minutes')) {
      context.handle(
          _dailyLimitMinutesMeta,
          dailyLimitMinutes.isAcceptableOrUnknown(
              data['daily_limit_minutes']!, _dailyLimitMinutesMeta));
    }
    if (data.containsKey('current_usage_minutes')) {
      context.handle(
          _currentUsageMinutesMeta,
          currentUsageMinutes.isAcceptableOrUnknown(
              data['current_usage_minutes']!, _currentUsageMinutesMeta));
    }
    if (data.containsKey('is_blocked')) {
      context.handle(_isBlockedMeta,
          isBlocked.isAcceptableOrUnknown(data['is_blocked']!, _isBlockedMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('last_modified')) {
      context.handle(
          _lastModifiedMeta,
          lastModified.isAcceptableOrUnknown(
              data['last_modified']!, _lastModifiedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      packageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}package_name'])!,
      appName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}app_name'])!,
      dailyLimitMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_limit_minutes'])!,
      currentUsageMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}current_usage_minutes'])!,
      isBlocked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_blocked'])!,
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}synced'])!,
      lastModified: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_modified'])!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String packageName;
  final String appName;
  final int dailyLimitMinutes;
  final int currentUsageMinutes;
  final bool isBlocked;
  final bool synced;
  final DateTime lastModified;
  const Goal(
      {required this.packageName,
      required this.appName,
      required this.dailyLimitMinutes,
      required this.currentUsageMinutes,
      required this.isBlocked,
      required this.synced,
      required this.lastModified});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes);
    map['current_usage_minutes'] = Variable<int>(currentUsageMinutes);
    map['is_blocked'] = Variable<bool>(isBlocked);
    map['synced'] = Variable<bool>(synced);
    map['last_modified'] = Variable<DateTime>(lastModified);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      packageName: Value(packageName),
      appName: Value(appName),
      dailyLimitMinutes: Value(dailyLimitMinutes),
      currentUsageMinutes: Value(currentUsageMinutes),
      isBlocked: Value(isBlocked),
      synced: Value(synced),
      lastModified: Value(lastModified),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      dailyLimitMinutes: serializer.fromJson<int>(json['dailyLimitMinutes']),
      currentUsageMinutes:
          serializer.fromJson<int>(json['currentUsageMinutes']),
      isBlocked: serializer.fromJson<bool>(json['isBlocked']),
      synced: serializer.fromJson<bool>(json['synced']),
      lastModified: serializer.fromJson<DateTime>(json['lastModified']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'dailyLimitMinutes': serializer.toJson<int>(dailyLimitMinutes),
      'currentUsageMinutes': serializer.toJson<int>(currentUsageMinutes),
      'isBlocked': serializer.toJson<bool>(isBlocked),
      'synced': serializer.toJson<bool>(synced),
      'lastModified': serializer.toJson<DateTime>(lastModified),
    };
  }

  Goal copyWith(
          {String? packageName,
          String? appName,
          int? dailyLimitMinutes,
          int? currentUsageMinutes,
          bool? isBlocked,
          bool? synced,
          DateTime? lastModified}) =>
      Goal(
        packageName: packageName ?? this.packageName,
        appName: appName ?? this.appName,
        dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
        currentUsageMinutes: currentUsageMinutes ?? this.currentUsageMinutes,
        isBlocked: isBlocked ?? this.isBlocked,
        synced: synced ?? this.synced,
        lastModified: lastModified ?? this.lastModified,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      packageName:
          data.packageName.present ? data.packageName.value : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      dailyLimitMinutes: data.dailyLimitMinutes.present
          ? data.dailyLimitMinutes.value
          : this.dailyLimitMinutes,
      currentUsageMinutes: data.currentUsageMinutes.present
          ? data.currentUsageMinutes.value
          : this.currentUsageMinutes,
      isBlocked: data.isBlocked.present ? data.isBlocked.value : this.isBlocked,
      synced: data.synced.present ? data.synced.value : this.synced,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('currentUsageMinutes: $currentUsageMinutes, ')
          ..write('isBlocked: $isBlocked, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(packageName, appName, dailyLimitMinutes,
      currentUsageMinutes, isBlocked, synced, lastModified);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.dailyLimitMinutes == this.dailyLimitMinutes &&
          other.currentUsageMinutes == this.currentUsageMinutes &&
          other.isBlocked == this.isBlocked &&
          other.synced == this.synced &&
          other.lastModified == this.lastModified);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> packageName;
  final Value<String> appName;
  final Value<int> dailyLimitMinutes;
  final Value<int> currentUsageMinutes;
  final Value<bool> isBlocked;
  final Value<bool> synced;
  final Value<DateTime> lastModified;
  final Value<int> rowid;
  const GoalsCompanion({
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.dailyLimitMinutes = const Value.absent(),
    this.currentUsageMinutes = const Value.absent(),
    this.isBlocked = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String packageName,
    required String appName,
    this.dailyLimitMinutes = const Value.absent(),
    this.currentUsageMinutes = const Value.absent(),
    this.isBlocked = const Value.absent(),
    this.synced = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : packageName = Value(packageName),
        appName = Value(appName);
  static Insertable<Goal> custom({
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<int>? dailyLimitMinutes,
    Expression<int>? currentUsageMinutes,
    Expression<bool>? isBlocked,
    Expression<bool>? synced,
    Expression<DateTime>? lastModified,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (dailyLimitMinutes != null) 'daily_limit_minutes': dailyLimitMinutes,
      if (currentUsageMinutes != null)
        'current_usage_minutes': currentUsageMinutes,
      if (isBlocked != null) 'is_blocked': isBlocked,
      if (synced != null) 'synced': synced,
      if (lastModified != null) 'last_modified': lastModified,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? packageName,
      Value<String>? appName,
      Value<int>? dailyLimitMinutes,
      Value<int>? currentUsageMinutes,
      Value<bool>? isBlocked,
      Value<bool>? synced,
      Value<DateTime>? lastModified,
      Value<int>? rowid}) {
    return GoalsCompanion(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      dailyLimitMinutes: dailyLimitMinutes ?? this.dailyLimitMinutes,
      currentUsageMinutes: currentUsageMinutes ?? this.currentUsageMinutes,
      isBlocked: isBlocked ?? this.isBlocked,
      synced: synced ?? this.synced,
      lastModified: lastModified ?? this.lastModified,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (dailyLimitMinutes.present) {
      map['daily_limit_minutes'] = Variable<int>(dailyLimitMinutes.value);
    }
    if (currentUsageMinutes.present) {
      map['current_usage_minutes'] = Variable<int>(currentUsageMinutes.value);
    }
    if (isBlocked.present) {
      map['is_blocked'] = Variable<bool>(isBlocked.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('dailyLimitMinutes: $dailyLimitMinutes, ')
          ..write('currentUsageMinutes: $currentUsageMinutes, ')
          ..write('isBlocked: $isBlocked, ')
          ..write('synced: $synced, ')
          ..write('lastModified: $lastModified, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $DailyStatsTable dailyStats = $DailyStatsTable(this);
  late final $KanbanTasksTable kanbanTasks = $KanbanTasksTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sessions, dailyStats, kanbanTasks, syncQueue, goals];
}

typedef $$SessionsTableCreateCompanionBuilder = SessionsCompanion Function({
  required String id,
  Value<String> userId,
  Value<String> sessionType,
  Value<int> workMinutes,
  Value<int> breakMinutes,
  required DateTime startTime,
  Value<DateTime?> endTime,
  Value<bool> completed,
  Value<String?> ambientSound,
  Value<int> productivityScore,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});
typedef $$SessionsTableUpdateCompanionBuilder = SessionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> sessionType,
  Value<int> workMinutes,
  Value<int> breakMinutes,
  Value<DateTime> startTime,
  Value<DateTime?> endTime,
  Value<bool> completed,
  Value<String?> ambientSound,
  Value<int> productivityScore,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get workMinutes => $composableBuilder(
      column: $table.workMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get breakMinutes => $composableBuilder(
      column: $table.breakMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get workMinutes => $composableBuilder(
      column: $table.workMinutes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get breakMinutes => $composableBuilder(
      column: $table.breakMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get sessionType => $composableBuilder(
      column: $table.sessionType, builder: (column) => column);

  GeneratedColumn<int> get workMinutes => $composableBuilder(
      column: $table.workMinutes, builder: (column) => column);

  GeneratedColumn<int> get breakMinutes => $composableBuilder(
      column: $table.breakMinutes, builder: (column) => column);

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get ambientSound => $composableBuilder(
      column: $table.ambientSound, builder: (column) => column);

  GeneratedColumn<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);
}

class $$SessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()> {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> sessionType = const Value.absent(),
            Value<int> workMinutes = const Value.absent(),
            Value<int> breakMinutes = const Value.absent(),
            Value<DateTime> startTime = const Value.absent(),
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String?> ambientSound = const Value.absent(),
            Value<int> productivityScore = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion(
            id: id,
            userId: userId,
            sessionType: sessionType,
            workMinutes: workMinutes,
            breakMinutes: breakMinutes,
            startTime: startTime,
            endTime: endTime,
            completed: completed,
            ambientSound: ambientSound,
            productivityScore: productivityScore,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            Value<String> sessionType = const Value.absent(),
            Value<int> workMinutes = const Value.absent(),
            Value<int> breakMinutes = const Value.absent(),
            required DateTime startTime,
            Value<DateTime?> endTime = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String?> ambientSound = const Value.absent(),
            Value<int> productivityScore = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SessionsCompanion.insert(
            id: id,
            userId: userId,
            sessionType: sessionType,
            workMinutes: workMinutes,
            breakMinutes: breakMinutes,
            startTime: startTime,
            endTime: endTime,
            completed: completed,
            ambientSound: ambientSound,
            productivityScore: productivityScore,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SessionsTable,
    Session,
    $$SessionsTableFilterComposer,
    $$SessionsTableOrderingComposer,
    $$SessionsTableAnnotationComposer,
    $$SessionsTableCreateCompanionBuilder,
    $$SessionsTableUpdateCompanionBuilder,
    (Session, BaseReferences<_$AppDatabase, $SessionsTable, Session>),
    Session,
    PrefetchHooks Function()>;
typedef $$DailyStatsTableCreateCompanionBuilder = DailyStatsCompanion Function({
  required String dateKey,
  Value<String> userId,
  Value<int> totalScreenTimeMinutes,
  Value<int> socialMediaMinutes,
  Value<int> focusMinutes,
  Value<int> focusSessionsCompleted,
  Value<int> productivityScore,
  Value<int> appUnlocks,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});
typedef $$DailyStatsTableUpdateCompanionBuilder = DailyStatsCompanion Function({
  Value<String> dateKey,
  Value<String> userId,
  Value<int> totalScreenTimeMinutes,
  Value<int> socialMediaMinutes,
  Value<int> focusMinutes,
  Value<int> focusSessionsCompleted,
  Value<int> productivityScore,
  Value<int> appUnlocks,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});

class $$DailyStatsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dateKey => $composableBuilder(
      column: $table.dateKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalScreenTimeMinutes => $composableBuilder(
      column: $table.totalScreenTimeMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get socialMediaMinutes => $composableBuilder(
      column: $table.socialMediaMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get focusSessionsCompleted => $composableBuilder(
      column: $table.focusSessionsCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get appUnlocks => $composableBuilder(
      column: $table.appUnlocks, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));
}

class $$DailyStatsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dateKey => $composableBuilder(
      column: $table.dateKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalScreenTimeMinutes => $composableBuilder(
      column: $table.totalScreenTimeMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get socialMediaMinutes => $composableBuilder(
      column: $table.socialMediaMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get focusSessionsCompleted => $composableBuilder(
      column: $table.focusSessionsCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get appUnlocks => $composableBuilder(
      column: $table.appUnlocks, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));
}

class $$DailyStatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyStatsTable> {
  $$DailyStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dateKey =>
      $composableBuilder(column: $table.dateKey, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get totalScreenTimeMinutes => $composableBuilder(
      column: $table.totalScreenTimeMinutes, builder: (column) => column);

  GeneratedColumn<int> get socialMediaMinutes => $composableBuilder(
      column: $table.socialMediaMinutes, builder: (column) => column);

  GeneratedColumn<int> get focusMinutes => $composableBuilder(
      column: $table.focusMinutes, builder: (column) => column);

  GeneratedColumn<int> get focusSessionsCompleted => $composableBuilder(
      column: $table.focusSessionsCompleted, builder: (column) => column);

  GeneratedColumn<int> get productivityScore => $composableBuilder(
      column: $table.productivityScore, builder: (column) => column);

  GeneratedColumn<int> get appUnlocks => $composableBuilder(
      column: $table.appUnlocks, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);
}

class $$DailyStatsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DailyStatsTable,
    DailyStat,
    $$DailyStatsTableFilterComposer,
    $$DailyStatsTableOrderingComposer,
    $$DailyStatsTableAnnotationComposer,
    $$DailyStatsTableCreateCompanionBuilder,
    $$DailyStatsTableUpdateCompanionBuilder,
    (DailyStat, BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStat>),
    DailyStat,
    PrefetchHooks Function()> {
  $$DailyStatsTableTableManager(_$AppDatabase db, $DailyStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> dateKey = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<int> totalScreenTimeMinutes = const Value.absent(),
            Value<int> socialMediaMinutes = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> focusSessionsCompleted = const Value.absent(),
            Value<int> productivityScore = const Value.absent(),
            Value<int> appUnlocks = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyStatsCompanion(
            dateKey: dateKey,
            userId: userId,
            totalScreenTimeMinutes: totalScreenTimeMinutes,
            socialMediaMinutes: socialMediaMinutes,
            focusMinutes: focusMinutes,
            focusSessionsCompleted: focusSessionsCompleted,
            productivityScore: productivityScore,
            appUnlocks: appUnlocks,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String dateKey,
            Value<String> userId = const Value.absent(),
            Value<int> totalScreenTimeMinutes = const Value.absent(),
            Value<int> socialMediaMinutes = const Value.absent(),
            Value<int> focusMinutes = const Value.absent(),
            Value<int> focusSessionsCompleted = const Value.absent(),
            Value<int> productivityScore = const Value.absent(),
            Value<int> appUnlocks = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DailyStatsCompanion.insert(
            dateKey: dateKey,
            userId: userId,
            totalScreenTimeMinutes: totalScreenTimeMinutes,
            socialMediaMinutes: socialMediaMinutes,
            focusMinutes: focusMinutes,
            focusSessionsCompleted: focusSessionsCompleted,
            productivityScore: productivityScore,
            appUnlocks: appUnlocks,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DailyStatsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DailyStatsTable,
    DailyStat,
    $$DailyStatsTableFilterComposer,
    $$DailyStatsTableOrderingComposer,
    $$DailyStatsTableAnnotationComposer,
    $$DailyStatsTableCreateCompanionBuilder,
    $$DailyStatsTableUpdateCompanionBuilder,
    (DailyStat, BaseReferences<_$AppDatabase, $DailyStatsTable, DailyStat>),
    DailyStat,
    PrefetchHooks Function()>;
typedef $$KanbanTasksTableCreateCompanionBuilder = KanbanTasksCompanion
    Function({
  required String id,
  Value<String> userId,
  required String title,
  Value<String?> description,
  Value<int> status,
  Value<int> priority,
  required DateTime createdAt,
  Value<DateTime?> dueDate,
  Value<String> labels,
  Value<int> sortOrder,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});
typedef $$KanbanTasksTableUpdateCompanionBuilder = KanbanTasksCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<String?> description,
  Value<int> status,
  Value<int> priority,
  Value<DateTime> createdAt,
  Value<DateTime?> dueDate,
  Value<String> labels,
  Value<int> sortOrder,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});

class $$KanbanTasksTableFilterComposer
    extends Composer<_$AppDatabase, $KanbanTasksTable> {
  $$KanbanTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get labels => $composableBuilder(
      column: $table.labels, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));
}

class $$KanbanTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $KanbanTasksTable> {
  $$KanbanTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get labels => $composableBuilder(
      column: $table.labels, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));
}

class $$KanbanTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $KanbanTasksTable> {
  $$KanbanTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);
}

class $$KanbanTasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KanbanTasksTable,
    KanbanTask,
    $$KanbanTasksTableFilterComposer,
    $$KanbanTasksTableOrderingComposer,
    $$KanbanTasksTableAnnotationComposer,
    $$KanbanTasksTableCreateCompanionBuilder,
    $$KanbanTasksTableUpdateCompanionBuilder,
    (KanbanTask, BaseReferences<_$AppDatabase, $KanbanTasksTable, KanbanTask>),
    KanbanTask,
    PrefetchHooks Function()> {
  $$KanbanTasksTableTableManager(_$AppDatabase db, $KanbanTasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KanbanTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KanbanTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KanbanTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> labels = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KanbanTasksCompanion(
            id: id,
            userId: userId,
            title: title,
            description: description,
            status: status,
            priority: priority,
            createdAt: createdAt,
            dueDate: dueDate,
            labels: labels,
            sortOrder: sortOrder,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<String> labels = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KanbanTasksCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            description: description,
            status: status,
            priority: priority,
            createdAt: createdAt,
            dueDate: dueDate,
            labels: labels,
            sortOrder: sortOrder,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KanbanTasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KanbanTasksTable,
    KanbanTask,
    $$KanbanTasksTableFilterComposer,
    $$KanbanTasksTableOrderingComposer,
    $$KanbanTasksTableAnnotationComposer,
    $$KanbanTasksTableCreateCompanionBuilder,
    $$KanbanTasksTableUpdateCompanionBuilder,
    (KanbanTask, BaseReferences<_$AppDatabase, $KanbanTasksTable, KanbanTask>),
    KanbanTask,
    PrefetchHooks Function()>;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String collection,
  required String documentId,
  required String operation,
  required String payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> maxRetries,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> collection,
  Value<String> documentId,
  Value<String> operation,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<int> maxRetries,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collection => $composableBuilder(
      column: $table.collection, builder: (column) => column);

  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);
}

class $$SyncQueueTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> collection = const Value.absent(),
            Value<String> documentId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
          }) =>
              SyncQueueCompanion(
            id: id,
            collection: collection,
            documentId: documentId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            maxRetries: maxRetries,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String collection,
            required String documentId,
            required String operation,
            required String payload,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
          }) =>
              SyncQueueCompanion.insert(
            id: id,
            collection: collection,
            documentId: documentId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            maxRetries: maxRetries,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTable,
    SyncQueueData,
    $$SyncQueueTableFilterComposer,
    $$SyncQueueTableOrderingComposer,
    $$SyncQueueTableAnnotationComposer,
    $$SyncQueueTableCreateCompanionBuilder,
    $$SyncQueueTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String packageName,
  required String appName,
  Value<int> dailyLimitMinutes,
  Value<int> currentUsageMinutes,
  Value<bool> isBlocked,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> packageName,
  Value<String> appName,
  Value<int> dailyLimitMinutes,
  Value<int> currentUsageMinutes,
  Value<bool> isBlocked,
  Value<bool> synced,
  Value<DateTime> lastModified,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentUsageMinutes => $composableBuilder(
      column: $table.currentUsageMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isBlocked => $composableBuilder(
      column: $table.isBlocked, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get appName => $composableBuilder(
      column: $table.appName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentUsageMinutes => $composableBuilder(
      column: $table.currentUsageMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isBlocked => $composableBuilder(
      column: $table.isBlocked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified,
      builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
      column: $table.packageName, builder: (column) => column);

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<int> get dailyLimitMinutes => $composableBuilder(
      column: $table.dailyLimitMinutes, builder: (column) => column);

  GeneratedColumn<int> get currentUsageMinutes => $composableBuilder(
      column: $table.currentUsageMinutes, builder: (column) => column);

  GeneratedColumn<bool> get isBlocked =>
      $composableBuilder(column: $table.isBlocked, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
      column: $table.lastModified, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> packageName = const Value.absent(),
            Value<String> appName = const Value.absent(),
            Value<int> dailyLimitMinutes = const Value.absent(),
            Value<int> currentUsageMinutes = const Value.absent(),
            Value<bool> isBlocked = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            packageName: packageName,
            appName: appName,
            dailyLimitMinutes: dailyLimitMinutes,
            currentUsageMinutes: currentUsageMinutes,
            isBlocked: isBlocked,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String packageName,
            required String appName,
            Value<int> dailyLimitMinutes = const Value.absent(),
            Value<int> currentUsageMinutes = const Value.absent(),
            Value<bool> isBlocked = const Value.absent(),
            Value<bool> synced = const Value.absent(),
            Value<DateTime> lastModified = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            packageName: packageName,
            appName: appName,
            dailyLimitMinutes: dailyLimitMinutes,
            currentUsageMinutes: currentUsageMinutes,
            isBlocked: isBlocked,
            synced: synced,
            lastModified: lastModified,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$DailyStatsTableTableManager get dailyStats =>
      $$DailyStatsTableTableManager(_db, _db.dailyStats);
  $$KanbanTasksTableTableManager get kanbanTasks =>
      $$KanbanTasksTableTableManager(_db, _db.kanbanTasks);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
}
