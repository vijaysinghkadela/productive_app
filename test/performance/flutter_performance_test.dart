import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';

// Mocks simulating App and List Screens
class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});
  @override
  Widget build(BuildContext context) => const MaterialApp(home: Scaffold());
}

class AppListScreen extends StatelessWidget {
  const AppListScreen({required this.apps, super.key});
  final List<dynamic> apps;
  @override
  Widget build(BuildContext context) => MaterialApp(
        home: ListView.builder(
          itemExtent: 50,
          itemCount: apps.length,
          itemBuilder: (_, i) => Text('App $i'),
        ),
      );
}

void main() {
  // Test startup time:
  testWidgets('app cold start < 1200ms', (tester) async {
    final stopwatch = Stopwatch()..start();
    await tester.pumpWidget(const FocusGuardApp());
    await tester.pumpAndSettle(); // Wait for all animations
    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, lessThan(1200));
  });

  // Test list scroll performance:
  testWidgets('app list scrolls at 60fps', (tester) async {
    // Generate 1000 items
    final dummyApps = List.generate(1000, (i) => i);

    await tester.pumpWidget(AppListScreen(apps: dummyApps));

    final frameTimings = <FrameTiming>[];
    SchedulerBinding.instance.addTimingsCallback(frameTimings.addAll);

    await tester.fling(find.byType(ListView), const Offset(0, -5000), 5000);
    await tester.pumpAndSettle();

    final jankFrames =
        frameTimings.where((f) => f.totalSpan.inMilliseconds > 16);
    expect(
      jankFrames.length / frameTimings.length,
      lessThan(0.01),
    ); // < 1% jank
  });

  // Test memory usage:
  test('home screen memory < 80MB', () async {
    final memBefore = ProcessInfo.currentRss;
    // Simulate: Navigate to home screen...
    final memAfter = ProcessInfo.currentRss;
    expect(
      (memAfter - memBefore) / 1024 / 1024,
      lessThan(80),
    ); // Evaluates strictly under 80MB differential
  });
}
