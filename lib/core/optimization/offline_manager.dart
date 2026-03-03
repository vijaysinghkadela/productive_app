// ignore_for_file: discarded_futures, inference_failure_on_untyped_parameter
import 'dart:async';

class OfflineFirstManager {
  OfflineFirstManager() {
    _connectivityStream.stream.listen((isConnected) {
      if (isConnected) _flushQueue();
    });
  }
  // Every read: local first, remote second (stale-while-revalidate pattern)

  static Future<T> readWithFallback<T>({
    required Future<T?> Function() localRead,
    required Future<T> Function() remoteRead,
    required Future<void> Function(T) localWrite,
    Duration staleness = const Duration(minutes: 5),
  }) async {
    // Try local cache first (instant response):
    final local = await localRead();

    if (local != null && !_isStale(local, staleness)) {
      // Fresh cache hit — return immediately, no network
      return local;
    }

    if (local != null) {
      // Stale cache hit — return stale data immediately, refresh in background:
      unawaited(
        remoteRead().then((fresh) => localWrite(fresh)).catchError((_) {
          /* Ignore network failure, let user keep stale data */
        }),
      );
      return local;
    }

    // Cache miss — must fetch from network:
    final remote = await remoteRead();
    unawaited(localWrite(remote));
    return remote;
  }

  static bool _isStale(data, Duration maxAge) {
    if (data is Map && data.containsKey('syncTs')) {
      final sync = DateTime.parse(data['syncTs'] as String);
      return DateTime.now().difference(sync) > maxAge;
    }
    return true; // Default stale if unknown structure
  }

  // Offline queue: operations performed offline queued for sync:
  final List<Map<String, dynamic>> _operationQueue = [];
  final StreamController<bool> _connectivityStream =
      StreamController.broadcast();

  Future<void> queueOfflineOperation(Map<String, dynamic> operation) async {
    _operationQueue.add(operation);
  }

  void _flushQueue() {
    // Flush queue logic conceptually
    _operationQueue.clear();
  }

  void dispose() {
    _connectivityStream.close();
  }
}
