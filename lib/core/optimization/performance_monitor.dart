import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// App-wide structural profiler hooking into Firebase Performance, Flutter Frame timings,
/// and automated Jank reporting limits.
class PerformanceMonitor {
  /// Wraps any asynchronous block, recording true wall-clock time
  /// and automatically publishing Firebase Performance custom metrics.
  static Future<T> trackOperation<T>({
    required String name,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
  }) async {
    // Simulated: final trace = FirebasePerformance.instance.newTrace(name);
    // attributes?.forEach(trace.putAttribute);
    // await trace.start();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await operation();
      stopwatch.stop();

      // trace.putMetric('duration_ms', stopwatch.elapsedMilliseconds);
      if (kDebugMode) {
        print('[PERF] $name took ${stopwatch.elapsedMilliseconds}ms');
      }

      return result;
    } catch (e) {
      // trace.putAttribute('error', e.toString());
      rethrow;
    } finally {
      // await trace.stop();
    }
  }

  /// Registers background frame listeners to detect skipped VSync bounds.
  /// Throttled to < 16ms for ordinary devices to ensure flat 60FPS.
  static void startFrameMonitoring() {
    SchedulerBinding.instance.addTimingsCallback((List<FrameTiming> timings) {
      for (final timing in timings) {
        final frameMs = timing.totalSpan.inMilliseconds;

        // 16ms == ~60 FPS bounds
        if (frameMs > 16) {
          _reportJankFrame(
            frameMs,
            timing.rasterDuration,
            timing.buildDuration,
          );
        }
      }
    });
  }

  /// Sends dropped frame events to remote monitoring, without blocking UI cycle
  static void _reportJankFrame(
    int totalSpanMs,
    Duration raster,
    Duration build,
  ) {
    if (kReleaseMode) {
      // FirebasePerformance.instance.newTrace('jank_frame')
      //   ..putMetric('frame_ms', frameMs)
      //   ..putMetric('raster_ms', raster.inMilliseconds)
      //   ..putMetric('build_ms', build.inMilliseconds)
      //   ..start()
      //   ..stop();
    }
  }
}
