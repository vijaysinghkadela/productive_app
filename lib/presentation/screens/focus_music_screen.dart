import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:focusguard_pro/core/constants.dart';

class FocusMusicScreen extends StatefulWidget {
  const FocusMusicScreen({super.key});
  @override
  State<FocusMusicScreen> createState() => _FocusMusicScreenState();
}

class _FocusMusicScreenState extends State<FocusMusicScreen> {
  final Map<String, double> _volumes = {};
  final Set<String> _playing = {};

  final _sounds = [
    {'icon': '🌧️', 'name': 'Rain', 'color': AppColors.accent},
    {'icon': '⛈️', 'name': 'Thunderstorm', 'color': AppColors.primary},
    {'icon': '☕', 'name': 'Café', 'color': AppColors.warning},
    {'icon': '🌊', 'name': 'Ocean Waves', 'color': AppColors.accent},
    {'icon': '🔥', 'name': 'Fireplace', 'color': AppColors.alert},
    {'icon': '🌲', 'name': 'Forest', 'color': AppColors.success},
    {'icon': '📻', 'name': 'White Noise', 'color': AppColors.textSecondary},
    {'icon': '🟤', 'name': 'Brown Noise', 'color': AppColors.warning},
    {'icon': '🎵', 'name': 'Lo-fi Beats', 'color': AppColors.primary},
    {'icon': '🏞️', 'name': 'River', 'color': AppColors.accent},
    {'icon': '💨', 'name': 'Fan', 'color': AppColors.textTertiary},
    {'icon': '🌃', 'name': 'City Night', 'color': AppColors.primary},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            'Focus Sounds',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Now playing
              if (_playing.isNotEmpty) _nowPlaying(),
              // Sound mixer info
              const Text(
                'Mix up to 3 sounds',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ).animate().fadeIn(duration: 300.ms),
              const SizedBox(height: 16),
              // Binaural beats section
              const Text(
                'Binaural Beats',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _binauralCard(
                    'Alpha',
                    '8-13 Hz',
                    'Relaxed Focus',
                    AppColors.success,
                  ),
                  const SizedBox(width: 10),
                  _binauralCard(
                    'Beta',
                    '14-30 Hz',
                    'Active Focus',
                    AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  _binauralCard(
                    'Theta',
                    '4-7 Hz',
                    'Deep Meditation',
                    AppColors.accent,
                  ),
                ],
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: 20),
              // Ambient sounds grid
              const Text(
                'Ambient Sounds',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _sounds.length,
                itemBuilder: (ctx, i) => _soundTile(_sounds[i], i),
              ),
              const SizedBox(height: 20),
              // External links
              const Text(
                'External Music',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _externalLink('🟢', 'Spotify Focus', 'Open focus playlist'),
              _externalLink('🔴', 'YouTube Lo-fi', 'Lo-fi hip hop beats'),
              _externalLink('🍎', 'Apple Music', 'Focus station'),
            ],
          ),
        ),
      );

  Widget _nowPlaying() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.accent.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.graphic_eq, color: AppColors.primary, size: 20)
                    .animate(onPlay: (c) => c.repeat())
                    .fadeIn()
                    .then()
                    .fadeOut(delay: 800.ms),
                const SizedBox(width: 8),
                const Text(
                  'Now Playing',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(_playing.clear),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.alert.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Stop All',
                      style: TextStyle(color: AppColors.alert, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ..._playing.map(
              (name) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13,),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 120,
                      child: SliderTheme(
                        data: const SliderThemeData(
                          activeTrackColor: AppColors.accent,
                          inactiveTrackColor: AppColors.surface,
                          thumbColor: AppColors.accent,
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                        ),
                        child: Slider(
                          value: _volumes[name] ?? 0.7,
                          onChanged: (v) => setState(() {
                            _volumes[name] = v;
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms);

  Widget _binauralCard(String name, String freq, String desc, Color color) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                freq,
                style: const TextStyle(
                    color: AppColors.textTertiary, fontSize: 10,),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 10,),
              ),
            ],
          ),
        ),
      );

  Widget _soundTile(Map<String, dynamic> sound, int index) {
    final name = sound['name'] as String;
    final isActive = _playing.contains(name);
    final color = sound['color'] as Color;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isActive) {
            _playing.remove(name);
          } else if (_playing.length < 3) {
            _playing.add(name);
            _volumes[name] = 0.7;
          }
        });
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              isActive ? color.withValues(alpha: 0.12) : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isActive ? color.withValues(alpha: 0.4) : AppColors.cardBorder,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(sound['icon'] as String, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                color: isActive ? color : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Icon(Icons.volume_up_rounded, size: 14, color: color),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: Duration(milliseconds: index * 40));
  }

  Widget _externalLink(String icon, String name, String desc) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 11,),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 600.ms, duration: 300.ms);
}
