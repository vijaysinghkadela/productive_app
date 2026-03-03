import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/app_buttons.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int _selectedPeriod = 0;
  static const _periods = ['Today', 'Week', 'Month', '3 Mo', 'Year'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Text('Analytics',
                    style: Theme.of(context).textTheme.displaySmall),
              ).animate().fadeIn(duration: 300.ms),
            ),

            // Period tabs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: List.generate(_periods.length, (i) {
                    final isActive = i == _selectedPeriod;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedPeriod = i);
                        },
                        child: AnimatedContainer(
                          duration: Anim.normal,
                          height: 36,
                          margin: EdgeInsets.only(right: i < 4 ? 6 : 0),
                          decoration: BoxDecoration(
                            gradient: isActive ? AppGradients.hero : null,
                            color: isActive ? null : AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(_periods[i],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isActive
                                      ? Colors.white
                                      : AppColors.textTertiary,
                                )),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
            ),

            // Screen Time Overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Screen Time',
                              style: Theme.of(context).textTheme.headlineSmall),
                          GradientText('5h 14m',
                              style: Theme.of(context).textTheme.headlineLarge,
                              gradient: AppGradients.hero),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Stacked bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 12,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 64,
                                  child: Container(
                                      color: AppColors.success
                                          .withValues(alpha: 0.7))),
                              Expanded(
                                  flex: 33,
                                  child: Container(
                                      color: AppColors.alert
                                          .withValues(alpha: 0.7))),
                              Expanded(
                                  flex: 13,
                                  child: Container(
                                      color: AppColors.textTertiary
                                          .withValues(alpha: 0.3))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _LegendDot(
                              color: AppColors.success,
                              label: 'Productive: 3h 20m'),
                          const SizedBox(width: 16),
                          _LegendDot(
                              color: AppColors.alert,
                              label: 'Distracting: 1h 45m'),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.03, end: 0),
            ),

            // Productivity Score Chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Productivity Score',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('30-day trend',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: _buildScoreChart(),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            ),

            // Per-App Usage
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('App Usage',
                    style: Theme.of(context).textTheme.headlineSmall),
              ),
            ),
            SliverList.builder(
              itemCount: min(8, socialMediaApps.length),
              itemBuilder: (context, i) {
                final mins = [65, 48, 42, 35, 28, 22, 15, 10][i];
                final maxMins = 65;
                return Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, i < 7 ? 8 : 0),
                  child: _AppUsageRow(
                      name: socialMediaApps[i],
                      minutes: mins,
                      maxMinutes: maxMins,
                      index: i),
                );
              },
            ),

            // Focus Heatmap
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Focus Heatmap',
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      Text('7-day × 24-hour activity',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: _HeatmapPainter(),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChart() {
    final rng = Random(42);
    final spots = List.generate(30, (i) {
      final base = 55 + rng.nextInt(35);
      return FlSpot(i.toDouble(), base.toDouble());
    });

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (v) => FlLine(
            color: AppColors.textTertiary.withValues(alpha: 0.08),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 29,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            gradient: AppGradients.hero,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) => spot.x == 29
                  ? FlDotCirclePainter(
                      radius: 5, color: AppColors.secondary, strokeWidth: 0)
                  : FlDotCirclePainter(
                      radius: 0, color: Colors.transparent, strokeWidth: 0),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.backgroundSecondary,
            tooltipRoundedRadius: 10,
            getTooltipItems: (spots) => spots
                .map(
                  (s) => LineTooltipItem(
                      'Score: ${s.y.round()}',
                      const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                )
                .toList(),
          ),
        ),
      ),
      duration: Anim.slow,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _AppUsageRow extends StatelessWidget {
  final String name;
  final int minutes, maxMinutes, index;
  const _AppUsageRow(
      {required this.name,
      required this.minutes,
      required this.maxMinutes,
      required this.index});

  @override
  Widget build(BuildContext context) {
    final ratio = minutes / maxMinutes;
    final isSocial = [
      'Instagram',
      'TikTok',
      'Twitter/X',
      'Facebook',
      'Snapchat',
      'Reddit'
    ].contains(name);
    final barColor = isSocial ? AppColors.alert : AppColors.success;

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: barColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(name[0],
                  style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        Container(color: AppColors.surfaceLight),
                        FractionallySizedBox(
                          widthFactor: ratio,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                barColor,
                                barColor.withValues(alpha: 0.6)
                              ]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text('${minutes}m',
              style: TextStyle(
                  color: barColor, fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    )
        .animate(delay: (200 + index * 50).ms)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0);
  }
}

class _HeatmapPainter extends CustomPainter {
  final _rng = Random(123);

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = (size.width - 40) / 24;
    final cellH = (size.height - 10) / 7;
    final cellSize = min(cellW, cellH) - 2;

    for (int day = 0; day < 7; day++) {
      for (int hour = 0; hour < 24; hour++) {
        final intensity = _rng.nextDouble();
        final color = intensity < 0.2
            ? AppColors.surfaceLight
            : AppColors.primary.withValues(alpha: 0.2 + intensity * 0.6);

        final x = 20 + hour * (cellSize + 2);
        final y = day * (cellSize + 2);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, cellSize, cellSize),
            const Radius.circular(3),
          ),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) => false;
}
