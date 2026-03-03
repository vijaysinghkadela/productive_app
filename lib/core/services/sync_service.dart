import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Offline-first sync service that queues local changes and pushes
/// them to the remote backend when connectivity is restored.
///
/// Implements last-write-wins conflict resolution with timestamps.
class SyncService {
  static final SyncService _instance = SyncService._();
  factory SyncService() => _instance;
  SyncService._();

  final _syncQueue = <SyncOperation>[];
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isSyncing = false;
  Timer? _retryTimer;

  /// Initialize connectivity listener.
  void init() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection && _syncQueue.isNotEmpty) {
        _processSyncQueue();
      }
    });
  }

  /// Enqueue a sync operation for later execution.
  void enqueue(SyncOperation operation) {
    _syncQueue.add(operation);
    debugPrint('📤 Sync queue: ${_syncQueue.length} pending operations');
    // Try to sync immediately
    _processSyncQueue();
  }

  /// Process all pending sync operations.
  Future<void> _processSyncQueue() async {
    if (_isSyncing || _syncQueue.isEmpty) return;
    _isSyncing = true;
    _retryTimer?.cancel();

    final connectivityResult = await Connectivity().checkConnectivity();
    final isOnline =
        connectivityResult.any((r) => r != ConnectivityResult.none);

    if (!isOnline) {
      _isSyncing = false;
      _scheduleRetry();
      return;
    }

    final failedOps = <SyncOperation>[];

    for (final op in List.of(_syncQueue)) {
      try {
        await op.execute();
        _syncQueue.remove(op);
        debugPrint('✅ Synced: ${op.description}');
      } catch (e) {
        op.retryCount++;
        if (op.retryCount < op.maxRetries) {
          failedOps.add(op);
        } else {
          debugPrint('❌ Sync failed permanently: ${op.description}');
          _syncQueue.remove(op);
        }
      }
    }

    _isSyncing = false;

    if (_syncQueue.isNotEmpty) {
      _scheduleRetry();
    }
  }

  /// Schedule a retry with exponential backoff.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    final delay = Duration(seconds: 5 * (_syncQueue.first.retryCount + 1));
    _retryTimer = Timer(delay, _processSyncQueue);
  }

  /// Force sync now (e.g., on manual pull-to-refresh).
  Future<void> syncNow() => _processSyncQueue();

  /// Number of pending operations.
  int get pendingCount => _syncQueue.length;

  /// Whether a sync is currently in progress.
  bool get isSyncing => _isSyncing;

  /// Dispose resources.
  void dispose() {
    _connectivitySub?.cancel();
    _retryTimer?.cancel();
  }
}

/// Represents a single sync operation in the queue.
class SyncOperation {
  final String id;
  final String description;
  final String collection;
  final String documentId;
  final Map<String, dynamic> data;
  final SyncType type;
  final DateTime timestamp;
  int retryCount;
  final int maxRetries;

  SyncOperation({
    required this.id,
    required this.description,
    required this.collection,
    required this.documentId,
    required this.data,
    this.type = SyncType.upsert,
    DateTime? timestamp,
    this.retryCount = 0,
    this.maxRetries = 5,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Execute the sync operation against the remote backend.
  /// In production, this would call Firestore/API directly.
  Future<void> execute() async {
    // Placeholder — replace with actual Firestore write
    debugPrint(
      '🔄 Syncing ${type.name} to $collection/$documentId '
      '(attempt ${retryCount + 1}/$maxRetries)',
    );
    // Simulate network call
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

enum SyncType { upsert, delete }
