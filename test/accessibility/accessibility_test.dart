import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class CustomAnimatedToggle extends StatelessWidget {
  const CustomAnimatedToggle({
    required this.value,
    required this.onChanged,
    required this.label,
    super.key,
  });
  final bool value;
  final Function(bool) onChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
        toggled: value,
        label: label,
        onTapHint: 'Toggle',
        onTap: () => onChanged(!value),
        child: Switch(value: value, onChanged: onChanged),
      );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Home'));
}

class FocusSessionScreen extends StatelessWidget {
  const FocusSessionScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Text('Focus Timer remaining 25', key: Key('timer_display')),
      );
}

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('Analytics'));
}

void main() {
  group('Accessibility Tests', () {
    final a11yHandle = SemanticsHandle();

    setUp(() => null);
    tearDown(a11yHandle.dispose);

    testWidgets('HomeScreen passes accessibility audit', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      // Run Flutter's built-in accessibility checker:
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('FocusSessionScreen timer readable by screen reader',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: FocusSessionScreen()));
      await tester.pumpAndSettle();

      final timerSemantics =
          tester.getSemantics(find.byKey(const Key('timer_display')));
      expect(timerSemantics.label, contains('remaining'));
    });

    testWidgets('All interactive elements have labels', (tester) async {
      final screens = [
        const HomeScreen(),
        const FocusSessionScreen(),
        const AnalyticsScreen(),
      ];

      for (final screen in screens) {
        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pumpAndSettle();

        final interactiveWidgets = tester.widgetList(
          find.byWidgetPredicate((w) => w is GestureDetector || w is InkWell),
        );

        for (final widget in interactiveWidgets) {
          final semantics = tester.getSemantics(find.byWidget(widget));
          expect(
            semantics.label,
            isNotEmpty,
            reason:
                'Interactive widget missing semantic label in ${screen.runtimeType}',
          );
        }
      }
    });

    testWidgets('Color contrast meets WCAG AA (4.5:1 ratio)', (tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: Scaffold(body: Text('Hello'))));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
    });

    testWidgets('Custom toggle has proper semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomAnimatedToggle(
              value: true,
              onChanged: (_) {},
              label: 'Enable blocking',
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(CustomAnimatedToggle));
      expect(semantics.hasFlag(SemanticsFlag.isToggled), isTrue);
      expect(semantics.label, equals('Enable blocking'));
    });

    testWidgets('Minimum tap target 48x48dp everywhere', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    });
  });
}
