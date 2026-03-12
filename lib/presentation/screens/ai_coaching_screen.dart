// ignore_for_file: discarded_futures
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/domain/entities/user.dart';
import 'package:focusguard_pro/presentation/providers/app_providers.dart'
    hide FocusTimerNotifier, FocusTimerState, TimerPhase, focusTimerProvider;
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int _kProDailyLimit = 10;
const String _kPrefCountKey = 'ai_coaching_count';
const String _kPrefDateKey = 'ai_coaching_date';

class AiCoachingScreen extends ConsumerStatefulWidget {
  const AiCoachingScreen({super.key});

  @override
  ConsumerState<AiCoachingScreen> createState() => _AiCoachingScreenState();
}

class _AiCoachingScreenState extends ConsumerState<AiCoachingScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text:
          "Hi! I'm Alex, your AI focus coach. I've analyzed your recent data — let me know how I can help you stay on track today! 🎯",
      isUser: false,
    ),
  ];
  bool _isTyping = false;
  int _todayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDailyCount();
  }

  Future<void> _loadDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString(_kPrefDateKey) ?? '';
    final count = savedDate == today ? (prefs.getInt(_kPrefCountKey) ?? 0) : 0;
    if (mounted) setState(() => _todayCount = count);
  }

  Future<void> _incrementDailyCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_kPrefDateKey, today);
    await prefs.setInt(_kPrefCountKey, _todayCount + 1);
    if (mounted) setState(() => _todayCount++);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final tier = ref.read(authProvider).user?.tier ?? SubscriptionTier.free;
    final isElite = tier == SubscriptionTier.elite;
    final isPro = tier == SubscriptionTier.pro || isElite;

    if (!isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔒 AI coaching requires Pro or Elite.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!isElite && _todayCount >= _kProDailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚡ Daily limit reached (10/day). Upgrade to Elite for unlimited AI coaching.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    unawaited(HapticFeedback.lightImpact());
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _inputCtrl.clear();
      _isTyping = true;
    });
    _scrollToBottom();
    await _incrementDailyCount();

    // Simulate AI response after delay
    unawaited(
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _isTyping = false;
            _messages.add(
              _ChatMessage(
                text: _getAIResponse(text),
                isUser: false,
              ),
            );
          });
          _scrollToBottom();
        }
      }),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: Anim.normal,
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getAIResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('week') || lower.contains('analytics')) {
      return "Looking at your past 7 days: You've averaged 2h 45m of focus time daily (up 18% from last week!). Instagram usage dropped by 22 minutes. Your best day was Wednesday — you hit a 92 score. Keep it up! 📈";
    } else if (lower.contains('focus') || lower.contains('schedule')) {
      return "Based on your patterns, your peak focus hours are 9-11 AM and 2-4 PM. I'd suggest scheduling deep work sessions during these windows. Want me to create an optimized daily schedule for you? 🗓️";
    } else if (lower.contains('instagram') || lower.contains('social')) {
      return "Your Instagram usage has been averaging 1h 12m daily. The biggest trigger times are 8am (first thing) and 9-10pm (before bed). Try the 'No Phone First 30 Min' habit — it's helped 73% of users reduce morning social media! 📱";
    }
    return "That's a great question! Based on your usage patterns, I'd recommend starting with short 25-minute focus sessions and gradually increasing. Consistency beats intensity. Would you like me to set up a personalized focus plan? ✨";
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Row(
                  children: [
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    const SizedBox(width: 12),
                    // AI Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppGradients.mint,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🤖', style: TextStyle(fontSize: 20)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'AI Focus Coach',
                          style: TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Daily insight card
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: ShimmerBorderCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          const Text(
                            "Today's Insight",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Based on 7 days',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your focus sessions are 40% more effective in the morning. Consider blocking Instagram during 9-11 AM to maximize productivity.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms),

              // Quick prompts
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _QuickPrompt(
                      label: '📊 Analyze my week',
                      onTap: () => _sendMessage('Analyze my week'),
                    ),
                    const SizedBox(width: 8),
                    _QuickPrompt(
                      label: '🎯 What to focus on?',
                      onTap: () => _sendMessage('What should I focus on?'),
                    ),
                    const SizedBox(width: 8),
                    _QuickPrompt(
                      label: '📱 Instagram habits',
                      onTap: () =>
                          _sendMessage('Why do I keep checking Instagram?'),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 8),

              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length && _isTyping) {
                      return _TypingIndicator();
                    }
                    return _MessageBubble(
                      message: _messages[i],
                      index: i,
                    );
                  },
                ),
              ),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputCtrl,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Ask Alex anything...',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_inputCtrl.text),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppGradients.hero,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _QuickPrompt extends StatelessWidget {
  const _QuickPrompt({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.index});
  final _ChatMessage message;
  final int index;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  gradient: AppGradients.mint,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 14)),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: message.isUser ? AppGradients.hero : null,
                  color: message.isUser ? null : AppColors.surfaceLight,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                    bottomRight: Radius.circular(message.isUser ? 4 : 16),
                  ),
                  border: message.isUser
                      ? null
                      : Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        message.isUser ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 200.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 200.ms,
          );
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: AppGradients.mint,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.textTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat())
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        delay: (i * 200).ms,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(0.5, 0.5),
                        duration: 600.ms,
                      ),
                ),
              ),
            ),
          ],
        ),
      );
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
