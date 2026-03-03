import 'dart:async';

class NetworkOptimizer {
  // Request deduplication: identical in-flight requests share response:
  static final _DuplicateQueue _queue = _DuplicateQueue();

  static Future<T> fetch<T>(String key, Future<T> Function() fetcher) =>
      _queue.fetch(key, fetcher);
}

class _DuplicateQueue {
  final Map<String, Future<dynamic>> _inflight = {};

  Future<T> fetch<T>(String key, Future<T> Function() fetcher) async {
    if (_inflight.containsKey(key)) {
      return await _inflight[key] as T;
    }

    final future = fetcher().whenComplete(() => _inflight.remove(key));
    _inflight[key] = future;
    return future;
  }
}

// Request batching: combine multiple requests into one:
class RequestBatcher<T> {
  RequestBatcher({
    required this.batchFetch,
    this.window = const Duration(milliseconds: 50),
  });
  final Duration window;
  final Future<List<T>> Function(List<String>) batchFetch;

  final Map<String, Completer<T>> _pending = {};
  Timer? _timer;

  Future<T> fetch(String id) {
    if (_pending.containsKey(id)) {
      return _pending[id]!.future;
    }

    final completer = Completer<T>();
    _pending[id] = completer;
    _timer?.cancel();
    _timer = Timer(window, _flush);
    return completer.future;
  }

  Future<void> _flush() async {
    final ids = _pending.keys.toList();
    final completers = Map.of(_pending);
    _pending.clear();

    try {
      final results = await batchFetch(ids);
      for (var i = 0; i < ids.length; i++) {
        completers[ids[i]]?.complete(results[i]);
      }
    } catch (e) {
      for (final c in completers.values) {
        c.completeError(e);
      }
    }
  }
}

// Delta sync: only send changed fields (not full document):
class DeltaSyncService {
  final Map<String, dynamic> _lastSynced = {};

  Map<String, dynamic> computeDelta(String key, Map<String, dynamic> current) {
    final last = _lastSynced[key] ?? {};
    final delta = <String, dynamic>{};

    for (final entry in current.entries) {
      if (last[entry.key] != entry.value) {
        delta[entry.key] = entry.value;
      }
    }
    _lastSynced[key] = Map.from(current);
    return delta; // Only changed fields
  }
}

class PrefetchManager {
  // Prefetch next screen data when user shows intent:
  void onNavigationHintDetected(String route) {
    switch (route) {
      case '/analytics':
        _prefetchAnalyticsData();
      case '/achievements':
        _prefetchAchievements();
      case '/leaderboard':
        _prefetchLeaderboard();
    }
  }

  void _prefetchAnalyticsData() {}
  void _prefetchAchievements() {}
  void _prefetchLeaderboard() {}
}
