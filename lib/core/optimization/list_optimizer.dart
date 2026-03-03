import 'package:flutter/material.dart';

// For large app lists (1000+ items):
class OptimizedAppList extends StatelessWidget {
  const OptimizedAppList({required this.apps, super.key});
  final List<dynamic> apps;

  @override
  Widget build(BuildContext context) => ListView.builder(
        // Critical performance settings:
        itemCount: apps.length,
        itemExtent:
            72.0, // Fixed height enables O(1) scroll position calculation
        // OR use SliverFixedExtentList for even better performance
        cacheExtent: 500, // Pre-render 500px ahead of viewport
        addAutomaticKeepAlives: false, // Don't keep offscreen items alive
        addSemanticIndexes:
            false, // Disable if no accessibility requirement for perf

        itemBuilder: (context, index) {
          final app = apps[index]
              as dynamic; // Type assumption fixed via dynamic cast locally giving property access
          return SizedBox(
            key: ValueKey(
              app.packageId as String,
            ), // Stable keys
            height: 72.0,
            child: Text(app.name as String),
          );
        },
      );
}

class InfiniteScrollOptimizer {
  // Pagination: load 20 items at a time
  // Pre-fetch trigger: when user is 5 items from bottom (not at bottom — prevents jank)
  // Loading state: shimmer skeleton for next page (not spinner — less jarring)
  // De-duplicate: handle race conditions in rapid scroll

  static const int pageSize = 20;
  static const int prefetchThreshold = 5;

  bool shouldFetchNextPage(int currentIndex, int totalLoaded) =>
      currentIndex >= totalLoaded - prefetchThreshold;
}
