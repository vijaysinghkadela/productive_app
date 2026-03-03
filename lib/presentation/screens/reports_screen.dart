import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Reports',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Latest weekly report
              _reportCard(
                context,
                '📊',
                'Weekly Report',
                'Feb 24 - Mar 2, 2026',
                'Score: 78 avg | Focus: 12h 45m | Social: 2h 10m/day',
                true,
                0,
              ),
              _reportCard(
                context,
                '📅',
                'Monthly Report',
                'February 2026',
                'Score: 74 avg | Focus: 48h 20m | Goals: 82%',
                false,
                1,
              ),
              const SizedBox(height: 20),
              const Text(
                'Report History',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(4, _historyItem),
              const SizedBox(height: 20),
              // Export options
              const Text(
                'Export Data',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _exportOption(
                '📄',
                'Export as PDF',
                'Beautiful formatted report',
                AppColors.alert,
              ),
              _exportOption(
                '📊',
                'Export as CSV',
                'Raw data spreadsheet',
                AppColors.success,
              ),
              _exportOption(
                '📷',
                'Share as Image',
                'Instagram/WhatsApp ready',
                AppColors.primary,
              ),
              _exportOption(
                '📧',
                'Email Report',
                'Send to your inbox',
                AppColors.accent,
              ),
            ],
          ),
        ),
      );

  Widget _reportCard(
    BuildContext context,
    String icon,
    String title,
    String date,
    String summary,
    bool isNew,
    int i,
  ) =>
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: isNew ? 0.12 : 0.06),
              AppColors.accent.withValues(alpha: isNew ? 0.08 : 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isNew
                ? AppColors.primary.withValues(alpha: 0.3)
                : AppColors.cardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isNew)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              summary,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'View Report',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: Duration(milliseconds: i * 100), duration: 400.ms);

  Widget _historyItem(int i) {
    final items = [
      {'d': 'Feb 17-23', 't': 'Weekly', 'score': '74'},
      {'d': 'Feb 10-16', 't': 'Weekly', 'score': '71'},
      {'d': 'January 2026', 't': 'Monthly', 'score': '69'},
      {'d': 'Feb 3-9', 't': 'Weekly', 'score': '73'},
    ];
    final item = items[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(
            item['t'] == 'Weekly' ? '📊' : '📅',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item['t']} Report',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item['d']!,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item['score']} avg',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 20,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: 300 + i * 60), duration: 300.ms);
  }

  Widget _exportOption(String icon, String title, String desc, Color color) =>
      Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.download_rounded, color: color, size: 20),
          ],
        ),
      );
}
