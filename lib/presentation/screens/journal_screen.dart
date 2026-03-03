import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  int _selectedMood = -1;
  final _entryCtrl = TextEditingController();
  final List<TextEditingController> _gratitudeCtrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  static const _moods = [
    _MoodData(emoji: '😫', label: 'Awful', color: AppColors.alert),
    _MoodData(emoji: '😕', label: 'Bad', color: AppColors.streak),
    _MoodData(emoji: '😐', label: 'Okay', color: AppColors.warning),
    _MoodData(emoji: '🙂', label: 'Good', color: AppColors.secondary),
    _MoodData(emoji: '😊', label: 'Great', color: AppColors.success),
  ];

  @override
  void dispose() {
    _entryCtrl.dispose();
    for (final c in _gratitudeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Journal'),
          leading: AppIconButton(
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: SecondaryButton(
                label: 'Save',
                icon: Icons.check_rounded,
                color: AppColors.success,
                onPressed: HapticFeedback.mediumImpact,
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Text(
                'Today · ${_formatDate(DateTime.now())}',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 20),

              // Mood selector
              const Text(
                'How are you feeling?',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (i) {
                  final mood = _moods[i];
                  final isSelected = i == _selectedMood;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedMood = i);
                    },
                    child: AnimatedContainer(
                      duration: Anim.normal,
                      curve: Curves.easeOut,
                      width: isSelected ? 64 : 54,
                      height: isSelected ? 64 : 54,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  mood.color.withValues(alpha: 0.2),
                                  mood.color.withValues(alpha: 0.05),
                                ],
                              )
                            : null,
                        color: isSelected ? null : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? mood.color : AppColors.cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mood.emoji,
                            style: TextStyle(fontSize: isSelected ? 24 : 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            mood.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? mood.color
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 300.ms,
                      );
                }),
              ),

              const SizedBox(height: 24),

              // Journal entry
              const Text(
                'Journal Entry',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                child: TextField(
                  controller: _entryCtrl,
                  maxLines: 6,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.7,
                  ),
                  decoration: const InputDecoration(
                    hintText: "What's on your mind today?",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms),

              const SizedBox(height: 24),

              // Gratitude section
              const Text(
                'Gratitude ✨',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(
                3,
                (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    borderRadius: 14,
                    child: Row(
                      children: [
                        Text(
                          '${i + 1}.',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _gratitudeCtrls[i],
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: [
                                'What made you smile?',
                                'Who helped you today?',
                                'What are you proud of?',
                              ][i],
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            textInputAction: i < 2
                                ? TextInputAction.next
                                : TextInputAction.done,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: (400 + i * 80).ms)
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.03, end: 0),
              ),

              const SizedBox(height: 24),

              // Past entries section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Past Entries',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  AppIconButton(icon: Icons.search_rounded, onPressed: () {}),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(3, (i) {
                final moods = ['😊', '🙂', '😫'];
                final dates = ['Yesterday', '2 days ago', '3 days ago'];
                final snippets = [
                  'Had a really productive day. Managed to complete all my focus sessions...',
                  'Decent day. Struggled with Instagram in the afternoon but recovered...',
                  'Tough day. Missed most of my goals but tomorrow is a fresh start...',
                ];
                return Padding(
                  padding: EdgeInsets.only(bottom: i < 2 ? 10 : 0),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderRadius: 16,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(moods[i], style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dates[i],
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                snippets[i],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textTertiary,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textTertiary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ).animate(delay: (600 + i * 80).ms).fadeIn(duration: 300.ms);
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      );

  String _formatDate(DateTime d) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

class _MoodData {
  const _MoodData({
    required this.emoji,
    required this.label,
    required this.color,
  });
  final String emoji;
  final String label;
  final Color color;
}
