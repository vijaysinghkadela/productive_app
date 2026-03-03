import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../widgets/particle_field.dart';
import '../widgets/app_buttons.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;

  static const _slides = [
    _SlideData(
      icon: Icons.notifications_off_rounded,
      iconBg: Color(0xFF6C63FF),
      gradientColor: Color(0xFF6C63FF),
      title: 'Break Free\nFrom Distractions',
      subtitle:
          'Block addictive apps and reclaim hours every day. Your focus is your superpower.',
      features: [],
    ),
    _SlideData(
      icon: Icons.timer_rounded,
      iconBg: Color(0xFF00D4FF),
      gradientColor: Color(0xFF00D4FF),
      title: 'Deep Work\nSessions',
      subtitle:
          'Scientifically-designed focus timers with ambient sounds to maximize your flow state.',
      features: ['Pomodoro Timer', 'Ambient Sounds', 'Focus Modes'],
    ),
    _SlideData(
      icon: Icons.insights_rounded,
      iconBg: Color(0xFFFF6B9D),
      gradientColor: Color(0xFFFF6B9D),
      title: 'Track Your\nProgress',
      subtitle:
          'Beautiful analytics show your habits, trends, and productivity score over time.',
      features: ['Daily Score', 'Usage Heatmap', 'Habit Streaks'],
    ),
    _SlideData(
      icon: Icons.shield_rounded,
      iconBg: Color(0xFF00FFB2),
      gradientColor: Color(0xFF00FFB2),
      title: 'Digital\nWellness Shield',
      subtitle:
          'Set healthy boundaries with app limits, bedtime mode, and strict lock-down.',
      features: [],
    ),
    _SlideData(
      icon: Icons.emoji_events_rounded,
      iconBg: Color(0xFFFFB800),
      gradientColor: Color(0xFFFFB800),
      title: 'Compete &\nAchieve',
      subtitle:
          'Join challenges, climb leaderboards, unlock achievements, and build lasting habits.',
      features: [],
    ),
  ];

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage < _slides.length - 1) {
      _pageCtrl.nextPage(duration: Anim.normal, curve: Anim.easeInOut);
    } else {
      context.go('/permissions');
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    context.go('/permissions');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: Anim.slow,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.0, -0.3),
                radius: 1.2,
                colors: [
                  _slides[_currentPage].gradientColor.withValues(alpha: 0.15),
                  AppColors.background,
                ],
              ),
            ),
          ),

          // Particles
          const Positioned.fill(
              child: ParticleField(particleCount: 20, maxOpacity: 0.05)),

          // Page content
          SafeArea(
            child: Column(
              children: [
                // Top bar: skip / back + dots
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      // Back button (slides 2-5)
                      AnimatedOpacity(
                        opacity: _currentPage > 0 ? 1.0 : 0.0,
                        duration: Anim.fast,
                        child: AppIconButton(
                          icon: Icons.arrow_back_rounded,
                          onPressed: _currentPage > 0
                              ? () => _pageCtrl.previousPage(
                                  duration: Anim.normal, curve: Anim.easeInOut)
                              : null,
                        ),
                      ),
                      const Spacer(),
                      // Dot indicator
                      Row(
                        children: List.generate(5, (i) {
                          final isActive = i == _currentPage;
                          return AnimatedContainer(
                            duration: Anim.normal,
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: isActive
                                  ? _slides[_currentPage].gradientColor
                                  : AppColors.textTertiary
                                      .withValues(alpha: 0.3),
                            ),
                          );
                        }),
                      ),
                      const Spacer(),
                      // Skip button (slides 1-2)
                      AnimatedOpacity(
                        opacity: _currentPage < 2 ? 1.0 : 0.0,
                        duration: Anim.fast,
                        child: TextButton(
                          onPressed: _currentPage < 2 ? _skip : null,
                          child: Text('Skip',
                              style: TextStyle(color: AppColors.textTertiary)),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page view
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _slides.length,
                    itemBuilder: (context, i) => _SlideContent(
                      slide: _slides[i],
                      isActive: i == _currentPage,
                    ),
                  ),
                ),

                // Bottom section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: _currentPage == _slides.length - 1
                      ? PrimaryButton(
                          label: 'Start Free 7-Day Trial',
                          icon: Icons.arrow_forward_rounded,
                          gradient: LinearGradient(
                            colors: [
                              _slides[_currentPage].gradientColor,
                              _slides[_currentPage]
                                  .gradientColor
                                  .withValues(alpha: 0.7),
                            ],
                          ),
                          onPressed: _next,
                        )
                      : PrimaryButton(
                          label: 'Continue',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _next,
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

class _SlideData {
  final IconData icon;
  final Color iconBg;
  final Color gradientColor;
  final String title;
  final String subtitle;
  final List<String> features;

  const _SlideData({
    required this.icon,
    required this.iconBg,
    required this.gradientColor,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class _SlideContent extends StatelessWidget {
  final _SlideData slide;
  final bool isActive;

  const _SlideContent({required this.slide, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large icon
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  slide.gradientColor.withValues(alpha: 0.2),
                  slide.gradientColor.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 80, color: slide.gradientColor),
          )
              .animate(target: isActive ? 1 : 0)
              .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 48),

          // Title
          GradientText(
            slide.title,
            style:
                Theme.of(context).textTheme.displayLarge?.copyWith(height: 1.1),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                slide.gradientColor.withValues(alpha: 0.8)
              ],
            ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0, delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          const SizedBox(height: 20),

          // Subtitle
          Text(
            slide.subtitle,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          )
              .animate(target: isActive ? 1 : 0, delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0),

          // Features row (only some slides)
          if (slide.features.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: slide.features.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: slide.gradientColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: slide.gradientColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: slide.gradientColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                    .animate(
                        target: isActive ? 1 : 0, delay: (300 + e.key * 100).ms)
                    .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 400.ms)
                    .fadeIn(duration: 300.ms);
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
