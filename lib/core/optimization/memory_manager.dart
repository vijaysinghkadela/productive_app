// ignore_for_file: avoid_dynamic_calls, avoid_positional_boolean_parameters, inference_failure_on_untyped_parameter, type_annotate_public_apis
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class MemoryManager {
  // Memory leak prevention checklist:
  // 1. Every AnimationController: dispose() in State.dispose()
  // 2. Every StreamSubscription: cancel() in dispose()
  // 3. Every TextEditingController: dispose()
  // 4. Every ScrollController: dispose()
  // 5. Every FocusNode: dispose()
  // 6. Every ChangeNotifier: dispose()
  // 7. Every Riverpod StreamProvider: auto-disposed via autoDispose

  // Image memory management:
  static void clearImageCacheOnMemoryPressure() {
    // Listen to memory pressure events:
    SystemChannels.system.setMessageHandler((message) async {
      if (message == 'memoryPressure') {
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();
      }
      return null;
    });
  }

  // Image cache tuning:
  static void configureImageCache() {
    PaintingBinding.instance.imageCache.maximumSize = 100; // Max 100 images
    PaintingBinding.instance.imageCache.maximumSizeBytes =
        50 * 1024 * 1024; // 50MB max
  }

  // Isar database: close when not actively used
  static Future<void> closeInactiveDatabase(
    isarInstance,
    bool dbInUse,
  ) async {
    if (!dbInUse && isarInstance != null) {
      await isarInstance.close();
    }
  }

  // Large data: process in chunks to avoid heap spikes
  static Stream<List<T>> processInChunks<T>(
    List<T> data, {
    int chunkSize = 100,
  }) async* {
    for (var i = 0; i < data.length; i += chunkSize) {
      yield data.sublist(i, min(i + chunkSize, data.length));
      await Future.microtask(() {}); // Yield to event loop between chunks
    }
  }
}
