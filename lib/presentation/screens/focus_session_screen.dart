import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../providers/app_providers.dart';
import '../widgets/glass_card.dart';
import '../widgets/particle_field.dart';
import '../widgets/app_buttons.dart';

class FocusSessionScreen extends ConsumerStatefulWidget {
  const FocusSessionScreen({super.key});

  @override
  ConsumerState<FocusSessionScreen> createState() => _FocusSessionScreenState();
}

class _FocusSessionScreenState extends ConsumerState<FocusSessionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ringCtrl;
  late final AnimationController _breatheCtrl;
  int _selectedPreset = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  int _remainingSeconds = 25 * 60;
  int _totalSeconds = 25 * 60;
  final int _currentPhase = 1;
  final int _totalPhases = 4;
  final bool _isBreakPhase = false;
  String _selectedSound = 'Rain';

  @override
  void initState() {
    super.initState();
    _ringCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
    _breatheCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 8))
          ..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _breatheCtrl.dispose();
    super.dispose();
  }

  void _toggleSession() {
    HapticFeedback.mediumImpact();
    setState(() {
      if (!_isRunning) {
        _isRunning = true;
        _totalSeconds = pomodoroPresets[_selectedPreset].workMinutes * 60;
        _remainingSeconds = _totalSeconds;
      } else {
        _isPaused = !_isPaused;
      }
    });
  }

  void _stopSession() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = pomodoroPresets[_selectedPreset].workMinutes * 60;
      _totalSeconds = _remainingSeconds;
    });
  }

  double get _progress => _isRunning
      ? 1.0 - (_remainingSeconds / _totalSeconds).clamp(0.0, 1.0)
      : 0.0;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(focusTimerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Calming particle background
          Positioned.fill(
            child: ParticleField(
              particleCount: 18,
              maxOpacity: 0.04,
              tintColor: _isBreakPhase ? AppColors.success : AppColors.primary,
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppIconButton(
                        icon: Icons.arrow_back_rounded,
                        onPressed: () =>
                            context.canPop() ? context.pop() : null,
                      ),
                      Text('Focus Session',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(width: 44),
                    ],
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 32),

                  // ──── MAIN TIMER ────
                  SizedBox(
                    width: 280,
                    height: 280,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer decorative ring (slow rotation)
                        if (_isRunning)
                          AnimatedBuilder(
                            animation: _ringCtrl,
                            builder: (context, _) => Transform.rotate(
                              angle: _ringCtrl.value * 2 * pi * 0.02,
                              child: CustomPaint(
                                size: const Size(280, 280),
                                painter: _DecoRingPainter(),
                              ),
                            ),
                          ),

                        // Main progress ring
                        CustomPaint(
                          size: const Size(260, 260),
                          painter: _TimerRingPainter(
                            progress: _progress,
                            isBreak: _isBreakPhase,
                          ),
                        ),

                        // Breathing circle overlay (break phase)
                        if (_isBreakPhase && _isRunning)
                          AnimatedBuilder(
                            animation: _breatheCtrl,
                            builder: (context, _) {
                              final scale =
                                  0.7 + 0.3 * sin(_breatheCtrl.value * 2 * pi);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.success
                                        .withValues(alpha: 0.06),
                                    border: Border.all(
                                      color: AppColors.success
                                          .withValues(alpha: 0.15),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                        // Center text
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formatTimerDisplay(_remainingSeconds),
                              style: AppTheme.mono(56, FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isRunning
                                  ? '${_isBreakPhase ? 'BREAK' : 'DEEP WORK'} · PHASE $_currentPhase OF $_totalPhases'
                                  : 'READY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textTertiary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 600.ms).scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 600.ms,
                        curve: Curves.easeOut,
                      ),

                  const SizedBox(height: 36),

                  // ──── CONTROLS ────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isRunning)
                        AppIconButton(
                          icon: Icons.stop_rounded,
                          color: AppColors.alert,
                          size: 48,
                          onPressed: _stopSession,
                        ).animate().fadeIn(duration: 200.ms),

                      if (_isRunning) const SizedBox(width: 24),

                      // Play/Pause
                      GestureDetector(
                        onTap: _toggleSession,
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: _isBreakPhase
                                ? AppGradients.mint
                                : AppGradients.hero,
                            shape: BoxShape.circle,
                            boxShadow: AppShadows.elevatedGlow(
                              _isBreakPhase
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                          child: Icon(
                            _isRunning && !_isPaused
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                      ).animate(delay: 300.ms).scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 400.ms,
                            curve: Curves.elasticOut,
                          ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ──── SESSION TYPE SELECTOR (when not running) ────
                  if (!_isRunning) ...[
                    Text('Session Type',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(letterSpacing: 2)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: pomodoroPresets.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final p = pomodoroPresets[i];
                          final isSelected = i == _selectedPreset;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedPreset = i;
                                _totalSeconds = p.workMinutes * 60;
                                _remainingSeconds = _totalSeconds;
                              });
                            },
                            child: AnimatedContainer(
                              duration: Anim.normal,
                              width: 100,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: isSelected ? AppGradients.hero : null,
                                color:
                                    isSelected ? null : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.5)
                                      : AppColors.cardBorder,
                                ),
                                boxShadow: isSelected
                                    ? AppShadows.glow(AppColors.primary,
                                        blur: 12)
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(p.emoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(height: 4),
                                  Text(p.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                      )),
                                  Text('${p.workMinutes}m',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white70
                                            : AppColors.textTertiary,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                  ],

                  const SizedBox(height: 20),

                  // ──── AMBIENT SOUND ────
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.music_note_rounded,
                              color: AppColors.secondary, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ambient Sound',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              Text(_selectedSound,
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                        AppIconButton(
                          icon: Icons.tune_rounded,
                          color: AppColors.secondary,
                          onPressed: () => _showSoundPicker(context),
                        ),
                      ],
                    ),
                  ).animate(delay: 500.ms).fadeIn(duration: 400.ms),

                  const SizedBox(height: 100), // Bottom padding for nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSoundPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: const BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Text('Ambient Sounds',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: ambientSounds.length,
                itemBuilder: (context, i) {
                  final sound = ambientSounds[i];
                  final isSelected = sound['name'] == _selectedSound;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedSound = sound['name']!);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppGradients.hero : null,
                        color: isSelected ? null : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(sound['icon']!,
                              style: const TextStyle(fontSize: 24)),
                          const SizedBox(height: 6),
                          Text(sound['name']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(Icons.check_circle,
                                  color: Colors.white, size: 14),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──── PAINTERS ────

class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool isBreak;
  _TimerRingPainter({required this.progress, this.isBreak = false});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 20) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = const Color(0x0FFFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round);

    if (progress <= 0) return;

    // Gradient progress
    final colors = isBreak
        ? [const Color(0xFF00FFB2), const Color(0xFF00D4FF)]
        : [const Color(0xFF6C63FF), const Color(0xFF00D4FF)];

    canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..shader = SweepGradient(
                  startAngle: -pi / 2, endAngle: 3 * pi / 2, colors: colors)
              .createShader(rect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      old.progress != progress || old.isBreak != isBreak;
}

class _DecoRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 4) / 2;

    // Dashed decorative ring
    const dashCount = 60;
    for (int i = 0; i < dashCount; i++) {
      final angle = (i / dashCount) * 2 * pi;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(
          Offset(x, y),
          0.8,
          Paint()
            ..color = Colors.white.withValues(alpha: i.isEven ? 0.06 : 0.02));
    }
  }

  @override
  bool shouldRepaint(_DecoRingPainter old) => false;
}
