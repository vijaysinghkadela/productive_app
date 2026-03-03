// ignore_for_file: avoid_catches_without_on_clauses, discarded_futures
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:focusguard_pro/data/database/app_database.dart';

/// Production offline-first sync engine.
///
/// Pipeline:
/// 1. Local write → drift DB with synced=false
/// 2. On connectivity restored → push unsynced rows to Firestore
/// 3. Pull remote changes with Last-Write-Wins conflict resolution
class SyncService {
  factory SyncService() => _instance;
  SyncService._();
  static final SyncService _instance = SyncService._();

  final _db = AppDatabase.instance;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicSync;
  bool _isSyncing = false;
  DateTime? _lastPullTimestamp;

  void init() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_onConnectivityChange);
    _periodicSync = Timer.periodic(const Duration(minutes: 5), (_) => sync());
  }

  void _onConnectivityChange(List<ConnectivityResult> results) {
    if (results.any((r) => r != ConnectivityResult.none)) {
      sync();
    }
  }

  /// Full bidirectional sync: push then pull.
  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity.every((r) => r == ConnectivityResult.none)) {
        _isSyncing = false;
        return;
      }

      await _pushSessions();
      await _pushDailyStats();
      await _pushKanbanTasks();
      await _pullRemoteSessions();
    } catch (e) {
      debugPrint('❌ Sync error: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // ─── PUSH: Local → Firestore ───

  Future<void> _pushSessions() async {
    final unsynced = await (_db.select(_db.sessions)
          ..where((t) => t.synced.equals(false)))
        .get();

    for (final session in unsynced) {
      try {
        await _firestore.collection('sessions').doc(session.id).set(
          {
            'sessionType': session.sessionType,
            'workMinutes': session.workMinutes,
            'breakMinutes': session.breakMinutes,
            'startTime': Timestamp.fromDate(session.startTime),
            'endTime': session.endTime != null
                ? Timestamp.fromDate(session.endTime!)
                : null,
            'completed': session.completed,
            'productivityScore': session.productivityScore,
            'lastModified': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await (_db.update(_db.sessions)..where((t) => t.id.equals(session.id)))
            .write(const SessionsCompanion(synced: Value(true)));
        debugPrint('✅ Pushed session ${session.id}');
      } catch (e) {
        debugPrint('⚠️ Failed session ${session.id}: $e');
      }
    }
  }

  Future<void> _pushDailyStats() async {
    final unsynced = await (_db.select(_db.dailyStats)
          ..where((t) => t.synced.equals(false)))
        .get();

    for (final stat in unsynced) {
      try {
        await _firestore.collection('dailyStats').doc(stat.dateKey).set(
          {
            'totalScreenTimeMinutes': stat.totalScreenTimeMinutes,
            'socialMediaMinutes': stat.socialMediaMinutes,
            'focusMinutes': stat.focusMinutes,
            'focusSessionsCompleted': stat.focusSessionsCompleted,
            'productivityScore': stat.productivityScore,
            'appUnlocks': stat.appUnlocks,
            'lastModified': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await (_db.update(_db.dailyStats)
              ..where((t) => t.dateKey.equals(stat.dateKey)))
            .write(const DailyStatsCompanion(synced: Value(true)));
        debugPrint('✅ Pushed stat ${stat.dateKey}');
      } catch (e) {
        debugPrint('⚠️ Failed stat ${stat.dateKey}: $e');
      }
    }
  }

  Future<void> _pushKanbanTasks() async {
    final unsynced = await (_db.select(_db.kanbanTasks)
          ..where((t) => t.synced.equals(false)))
        .get();

    for (final task in unsynced) {
      try {
        await _firestore.collection('kanbanTasks').doc(task.id).set(
          {
            'title': task.title,
            'description': task.description,
            'status': task.status,
            'priority': task.priority,
            'createdAt': Timestamp.fromDate(task.createdAt),
            'dueDate':
                task.dueDate != null ? Timestamp.fromDate(task.dueDate!) : null,
            'labels': task.labels,
            'sortOrder': task.sortOrder,
            'lastModified': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        await (_db.update(_db.kanbanTasks)..where((t) => t.id.equals(task.id)))
            .write(const KanbanTasksCompanion(synced: Value(true)));
        debugPrint('✅ Pushed task ${task.id}');
      } catch (e) {
        debugPrint('⚠️ Failed task ${task.id}: $e');
      }
    }
  }

  // ─── PULL: Firestore → Local (Last-Write-Wins) ───

  Future<void> _pullRemoteSessions() async {
    final since = _lastPullTimestamp ?? DateTime(2020);
    try {
      final snap = await _firestore
          .collection('sessions')
          .where('lastModified', isGreaterThan: Timestamp.fromDate(since))
          .get();

      for (final doc in snap.docs) {
        final data = doc.data();
        final remoteModified = (data['lastModified'] as Timestamp).toDate();

        // Check if local copy is newer
        final localRows = await (_db.select(_db.sessions)
              ..where((t) => t.id.equals(doc.id)))
            .get();

        if (localRows.isEmpty ||
            remoteModified.isAfter(localRows.first.lastModified)) {
          await _db.into(_db.sessions).insertOnConflictUpdate(
                SessionsCompanion(
                  id: Value(doc.id),
                  sessionType:
                      Value(data['sessionType'] as String? ?? 'Deep Work'),
                  workMinutes: Value(data['workMinutes'] as int? ?? 25),
                  breakMinutes: Value(data['breakMinutes'] as int? ?? 5),
                  startTime: Value((data['startTime'] as Timestamp).toDate()),
                  endTime: Value(
                    data['endTime'] != null
                        ? (data['endTime'] as Timestamp).toDate()
                        : null,
                  ),
                  completed: Value(data['completed'] as bool? ?? false),
                  synced: const Value(true),
                  lastModified: Value(remoteModified),
                ),
              );
        }
      }

      _lastPullTimestamp = DateTime.now();
      debugPrint('⬇️ Pulled ${snap.docs.length} remote sessions');
    } catch (e) {
      debugPrint('⚠️ Pull failed: $e');
    }
  }

  bool get isSyncing => _isSyncing;

  void dispose() {
    _connectivitySub?.cancel();
    _periodicSync?.cancel();
  }
}
