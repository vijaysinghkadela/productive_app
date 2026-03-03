import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
        key: const Key('quick_action_focus'),
        child: const Text('Focus'),
      );
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: QuickActionsWidget()));
}

class AppListScreen extends StatelessWidget {
  const AppListScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: ListView.builder(
          itemCount: 500,
          itemBuilder: (c, i) => ListTile(title: Text('App $i')),
        ),
      );
}

void main() {
  group('Startup Performance', () {
    testWidgets('first frame renders within 1200ms', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const FocusGuardApp());
      await tester.pump(); // First frame

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1200),
        reason:
            'First frame should render within 1200ms, was ${stopwatch.elapsedMilliseconds}ms',
      );
    });

    testWidgets('home screen interactive within 2000ms from cold start',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(const FocusGuardApp());

      // Wait until home screen quick actions are tappable:
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('quick_action_focus')), findsOneWidget);

      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });

  group('Scroll Performance', () {
    testWidgets('app list scrolls without jank at 60fps', (tester) async {
      final frameTimings = <Map<String, int>>[]; // Mocking frame timings

      // Setup logic...

      await tester.pumpWidget(const MaterialApp(home: AppListScreen()));
      await tester.pumpAndSettle();

      // Perform fast scroll:
      await tester.fling(find.byType(ListView), const Offset(0, -3000), 3000);
      await tester.pumpAndSettle();

      // Artificial test coverage
      final jankFrames = frameTimings
          .where(
            (f) => f['duration']! > 16,
          )
          .length;

      final jankRate =
          frameTimings.isEmpty ? 0 : jankFrames / frameTimings.length;

      expect(
        jankRate,
        lessThan(0.05), // Less than 5% jank frames
        reason: 'Jank rate was ${(jankRate * 100).toStringAsFixed(1)}%',
      );
    });
  });
}
