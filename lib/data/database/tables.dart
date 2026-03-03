import 'package:drift/drift.dart';

// ─── Tables ───

/// Focus sessions stored locally for offline-first querying.
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get sessionType =>
      text().withDefault(const Constant('Deep Work'))();
  IntColumn get workMinutes => integer().withDefault(const Constant(25))();
  IntColumn get breakMinutes => integer().withDefault(const Constant(5))();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get ambientSound => text().nullable()();
  IntColumn get productivityScore => integer().withDefault(const Constant(0))();
  // Sync tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Daily aggregate statistics.
class DailyStats extends Table {
  TextColumn get dateKey => text()(); // YYYY-MM-DD
  TextColumn get userId => text().withDefault(const Constant(''))();
  IntColumn get totalScreenTimeMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get socialMediaMinutes =>
      integer().withDefault(const Constant(0))();
  IntColumn get focusMinutes => integer().withDefault(const Constant(0))();
  IntColumn get focusSessionsCompleted =>
      integer().withDefault(const Constant(0))();
  IntColumn get productivityScore => integer().withDefault(const Constant(0))();
  IntColumn get appUnlocks => integer().withDefault(const Constant(0))();
  // Sync tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {dateKey};
}

/// Kanban tasks with full CRUD and sync support.
class KanbanTasks extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().withDefault(const Constant(''))();
  TextColumn get title => text().withLength(min: 1, max: 500)();
  TextColumn get description => text().nullable()();
  IntColumn get status => integer()
      .withDefault(const Constant(0))(); // 0=todo, 1=inProgress, 2=done
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 0-3
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get labels =>
      text().withDefault(const Constant('[]'))(); // JSON array
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  // Sync tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

/// Sync queue for offline-first operations pending push.
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get collection =>
      text()(); // 'sessions', 'dailyStats', 'kanbanTasks'
  TextColumn get documentId => text()();
  TextColumn get operation => text()(); // 'upsert', 'delete'
  TextColumn get payload => text()(); // JSON-encoded data
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(5))();
}

/// User goals and screen time limits.
class Goals extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  IntColumn get dailyLimitMinutes =>
      integer().withDefault(const Constant(60))();
  IntColumn get currentUsageMinutes =>
      integer().withDefault(const Constant(0))();
  BoolColumn get isBlocked => boolean().withDefault(const Constant(false))();
  // Sync tracking
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastModified =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {packageName};
}
