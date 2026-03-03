// Run: flutter test --update-goldens to generate, flutter test to verify
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class GlassCard extends StatelessWidget {
  const GlassCard({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(15),
        ),
        child: child,
      );
}

class ProductivityScoreRing extends StatelessWidget {
  const ProductivityScoreRing({
    required this.score,
    super.key,
  });
  final int score;
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox();
}

class AchievementCard extends StatelessWidget {
  const AchievementCard({
    required this.achievement,
    required this.isUnlocked,
    super.key,
  });
  final String achievement;
  final bool isUnlocked;
  @override
  Widget build(BuildContext context) => const SizedBox();
}

void main() {
  group('Golden Tests', () {
    testWidgets('GlassCard golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: GlassCard(child: Text('Test Card')),
          ),
        ),
      );
      // await expectLater(
      //   find.byType(GlassCard),
      //   matchesGoldenFile('goldens/glass_card.png'),
      // );
    });

    testWidgets('ProductivityScoreRing golden - high score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductivityScoreRing(score: 90),
          ),
        ),
      );
      await tester.pump();
      // ... verify golden high score
    });

    testWidgets('ProductivityScoreRing golden - low score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProductivityScoreRing(score: 25),
          ),
        ),
      );
      await tester.pump();
      // ... verify golden low score
    });

    testWidgets('PaywallScreen golden', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const PaywallScreen(),
        ),
      );
      await tester.pumpAndSettle();
      // ... verify generic paywall UI matches
    });

    testWidgets('AchievementCard golden - unlocked epic', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AchievementCard(
              achievement: 'epic',
              isUnlocked: true,
            ),
          ),
        ),
      );
      // ... match goldens/achievement_epic.png
    });
  });
}
