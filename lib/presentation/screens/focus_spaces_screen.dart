// ignore_for_file: discarded_futures, use_named_constants
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';
import 'package:focusguard_pro/presentation/widgets/app_buttons.dart';
import 'package:focusguard_pro/presentation/widgets/particle_field.dart';

class FocusSpacesScreen extends StatefulWidget {
  const FocusSpacesScreen({super.key});

  @override
  State<FocusSpacesScreen> createState() => _FocusSpacesScreenState();
}

class _FocusSpacesScreenState extends State<FocusSpacesScreen> {
  int _selectedRoom = 0;

  static const _rooms = [
    _RoomData(
      name: 'Silent Library',
      emoji: '📚',
      users: 234,
      gradient: LinearGradient(colors: [Color(0xFF3D2B1F), Color(0xFF0D1225)]),
      sound: 'Quiet ambiance',
      particleColor: AppColors.warning,
    ),
    _RoomData(
      name: 'Coffee Shop',
      emoji: '☕',
      users: 567,
      gradient: LinearGradient(colors: [Color(0xFF4A3728), Color(0xFF0D1225)]),
      sound: 'Chatter + coffee machine',
      particleColor: Color(0xFFD4A373),
    ),
    _RoomData(
      name: 'Forest Retreat',
      emoji: '🌲',
      users: 189,
      gradient: LinearGradient(colors: [Color(0xFF1B4332), Color(0xFF0D1225)]),
      sound: 'Birds + wind',
      particleColor: AppColors.success,
    ),
    _RoomData(
      name: 'Space Station',
      emoji: '🚀',
      users: 412,
      gradient: LinearGradient(colors: [Color(0xFF1A1040), Color(0xFF0D1225)]),
      sound: 'White noise + hum',
      particleColor: AppColors.primary,
    ),
    _RoomData(
      name: 'Rain Café',
      emoji: '🌧️',
      users: 321,
      gradient: LinearGradient(colors: [Color(0xFF2D3748), Color(0xFF0D1225)]),
      sound: 'Raindrops + thunder',
      particleColor: AppColors.secondary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final room = _rooms[_selectedRoom];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic room background
          AnimatedContainer(
            duration: Anim.slow,
            decoration: BoxDecoration(gradient: room.gradient),
          ),
          Positioned.fill(
            child: ParticleField(
              particleCount: 15,
              maxOpacity: 0.06,
              tintColor: room.particleColor,
            ),
          ),

          SafeArea(
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
                      Text(
                        'Focus Spaces',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // Room selector — swipeable cards
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: _rooms.length,
                    onPageChanged: (i) => setState(() => _selectedRoom = i),
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, i) {
                      final r = _rooms[i];
                      final isSelected = i == _selectedRoom;
                      return AnimatedContainer(
                        duration: Anim.normal,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        transform: Matrix4.identity()
                          ..scale(isSelected ? 1.0 : 0.92),
                        transformAlignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: r.gradient,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.transparent,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        r.particleColor.withValues(alpha: 0.2),
                                    blurRadius: 24,
                                  ),
                                ]
                              : [],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(r.emoji, style: const TextStyle(fontSize: 36)),
                            const SizedBox(height: 8),
                            Text(
                              r.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people_outline_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${r.users} focusing now',
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.volume_up_rounded,
                                  size: 14,
                                  color: AppColors.textTertiary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  r.sound,
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dot indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_rooms.length, (i) {
                      final isActive = i == _selectedRoom;
                      return AnimatedContainer(
                        duration: Anim.normal,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isActive ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: isActive
                              ? room.particleColor
                              : AppColors.textTertiary.withValues(alpha: 0.3),
                        ),
                      );
                    }),
                  ),
                ),

                // Participants section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'People Focusing',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      // Avatar cluster
                      SizedBox(
                        height: 50,
                        child: Stack(
                          children: List.generate(
                            6,
                            (i) => Positioned(
                              left: i * 36.0,
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      [
                                        AppColors.primary,
                                        AppColors.secondary,
                                        AppColors.tertiary,
                                        AppColors.success,
                                        AppColors.warning,
                                        AppColors.streak,
                                      ][i],
                                      AppColors.surfaceLight,
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    [
                                      'A',
                                      'S',
                                      'J',
                                      'M',
                                      'K',
                                      '+${room.users - 5}',
                                    ][i],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: i == 5 ? 10 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            ).animate(delay: (i * 80).ms).scale(
                                  begin: const Offset(0, 0),
                                  end: const Offset(1, 1),
                                  duration: 300.ms,
                                  curve: Curves.elasticOut,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Join button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  child: PrimaryButton(
                    label: 'Join ${room.name}',
                    icon: Icons.login_rounded,
                    gradient: LinearGradient(
                      colors: [
                        room.particleColor,
                        room.particleColor.withValues(alpha: 0.7),
                      ],
                    ),
                    onPressed: () {},
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomData {
  const _RoomData({
    required this.name,
    required this.emoji,
    required this.users,
    required this.gradient,
    required this.sound,
    required this.particleColor,
  });
  final String name;
  final String emoji;
  final String sound;
  final int users;
  final LinearGradient gradient;
  final Color particleColor;
}
