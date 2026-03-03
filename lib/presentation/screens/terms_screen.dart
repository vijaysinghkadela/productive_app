import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/glass_card.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  final _scrollCtrl = ScrollController();
  bool _scrolledToBottom = false;
  bool _accepted = false;
  double _scrollProgress = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final max = _scrollCtrl.position.maxScrollExtent;
    final current = _scrollCtrl.offset;
    setState(() {
      _scrollProgress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0;
      if (current >= max - 50) _scrolledToBottom = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canAccept = _scrolledToBottom && _accepted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: AppIconButton(
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.maybePop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _scrollProgress),
            duration: const Duration(milliseconds: 100),
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.transparent,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 2,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(20),
              child: const GlassCard(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('1. Acceptance of Terms'),
                    _BodyText(
                      'By downloading, installing, or using FocusGuard Pro ("the App"), you agree to be bound by these Terms and Conditions. If you do not agree, do not use the App.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('2. Description of Service'),
                    _BodyText(
                      'FocusGuard Pro is a digital wellness and productivity application that provides screen time tracking, app blocking, focus sessions, and related features.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('3. User Data & Privacy'),
                    _HighlightedSection(
                      text:
                          'We collect usage statistics from your device to provide productivity insights. This data is processed locally and encrypted before any cloud sync. We never sell your personal data to third parties.',
                      color: AppColors.warning,
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('4. Device Monitoring'),
                    _HighlightedSection(
                      text:
                          'The App requires Usage Access permission to monitor app usage patterns. This monitoring is essential for core functionality including screen time tracking, app blocking, and productivity scoring.',
                      color: AppColors.warning,
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('5. Subscription Terms'),
                    _BodyText(
                      r'FocusGuard Pro offers Basic ($5.99/mo), Pro ($9.99/mo), and Elite ($12.99/mo) subscription tiers. All subscriptions include a 7-day free trial. Subscriptions auto-renew unless cancelled 24 hours before the renewal date.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('6. Refund Policy'),
                    _BodyText(
                      'Refunds are handled through the respective app store (Google Play or Apple App Store) according to their policies. In-app purchases are non-refundable except as required by applicable law.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('7. Intellectual Property'),
                    _BodyText(
                      'All content, features, and functionality of the App are owned by FocusGuard Inc. and are protected by international copyright, trademark, and other intellectual property laws.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('8. Limitation of Liability'),
                    _BodyText(
                      'FocusGuard Pro is provided "as is" without warranties of any kind. We are not liable for any indirect, incidental, or consequential damages arising from your use of the App.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('9. Changes to Terms'),
                    _BodyText(
                      'We reserve the right to modify these terms at any time. Continued use of the App after changes constitutes acceptance of the modified terms.',
                    ),
                    SizedBox(height: 20),
                    _SectionTitle('10. Contact'),
                    _BodyText(
                      'For questions about these Terms, contact us at legal@focusguard.app',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom accept bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0A0F20),
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_scrolledToBottom) {
                      HapticFeedback.selectionClick();
                      setState(() => _accepted = !_accepted);
                    }
                  },
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: Anim.normal,
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          gradient: _accepted ? AppGradients.hero : null,
                          color: _accepted ? null : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: _accepted
                                ? AppColors.primary
                                : AppColors.cardBorderLight,
                          ),
                        ),
                        child: _accepted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ).animate().scale(
                                  begin: const Offset(0, 0),
                                  duration: 200.ms,
                                  curve: Curves.elasticOut,
                                )
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'I have read and accept the Terms & Conditions',
                          style: TextStyle(
                            fontSize: 13,
                            color: _scrolledToBottom
                                ? AppColors.textSecondary
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: Anim.normal,
                  child: PrimaryButton(
                    label: 'Accept & Continue',
                    icon: Icons.check_circle_rounded,
                    onPressed:
                        canAccept ? () => Navigator.maybePop(context) : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GradientText(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      );
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.7,
        ),
      );
}

class _HighlightedSection extends StatelessWidget {
  const _HighlightedSection({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      );
}
