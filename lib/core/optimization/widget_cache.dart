import 'package:flutter/material.dart';

class WidgetCache {
  // Cache expensive widgets that are rarely invalidated:
  static final Map<String, Widget> _cache = {};

  // Cache app icons (loaded from package manager — expensive):
  static Widget getCachedAppIcon(String packageId) => _cache.putIfAbsent(
        'icon_$packageId',
        () => _AppIconMock(packageId: packageId),
      );

  // Cache chart widgets with identical data:
  static Widget getCachedChart(String chartId, List<double> data) {
    final key = '$chartId:${data.hashCode}';
    return _cache.putIfAbsent(key, () {
      _evictIfNeeded();
      return _ChartMock(data: data);
    });
  }

  // LRU eviction to prevent memory bloat:
  static final _lruTracker = <String, int>{};
  static const _maxCacheSize = 50;

  static void _evictIfNeeded() {
    while (_cache.length > _maxCacheSize) {
      final oldest = _lruTracker.keys.first;
      _cache.remove(oldest);
      _lruTracker.remove(oldest);
    }
  }
}

class _AppIconMock extends StatelessWidget {
  const _AppIconMock({required this.packageId});
  final String packageId;
  @override
  Widget build(BuildContext context) => const SizedBox(width: 48, height: 48);
}

class _ChartMock extends StatelessWidget {
  const _ChartMock({required this.data});
  final List<double> data;
  @override
  Widget build(BuildContext context) => const SizedBox();
}
