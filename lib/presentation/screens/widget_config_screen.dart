import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants.dart';

class WidgetConfigScreen extends StatelessWidget {
  const WidgetConfigScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text('Home Widget',
              style: Theme.of(context).textTheme.headlineSmall)),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder)),
                child: Column(children: [
                  Text('📱', style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text('Home Screen Widget',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(
                      'See your focus stats at a glance without opening the app',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center),
                ])).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            Text('Widget Styles',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _widgetPreview('Minimal', 'Score + streak', AppColors.primary, 0),
            _widgetPreview(
                'Detailed', 'Score + top apps + timer', AppColors.accent, 1),
            _widgetPreview('Focus Timer', 'Quick-start focus session',
                AppColors.success, 2),
            _widgetPreview(
                'Habits', 'Today\'s habits checklist', AppColors.warning, 3),
            const SizedBox(height: 20),
            Text('Setup Instructions',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _step('1', 'Long-press on your home screen'),
            _step('2', 'Tap "Widgets" or "Add Widget"'),
            _step('3', 'Search for "FocusGuard"'),
            _step('4', 'Choose your preferred widget style'),
            _step('5', 'Place it on your home screen'),
          ])),
    );
  }

  Widget _widgetPreview(String name, String desc, Color color, int i) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Row(children: [
          Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                  child: Icon(Icons.widgets_rounded, color: color, size: 28))),
          const SizedBox(width: 14),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(name,
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
                Text(desc,
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ])),
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8)),
              child: Text('Select',
                  style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600))),
        ]),
      )
          .animate()
          .fadeIn(duration: 300.ms, delay: Duration(milliseconds: i * 80));

  Widget _step(String num, String text) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8)),
            child: Center(
                child: Text(num,
                    style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)))),
        const SizedBox(width: 12),
        Text(text,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
      ]));
}
