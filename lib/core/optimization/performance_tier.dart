class PerformanceConfig {
  const PerformanceConfig({
    required this.particleCount,
    required this.backdropFilterEnabled,
    required this.animationComplexity,
    required this.targetFPS,
    required this.chartAnimationDuration,
    required this.imageQuality,
    required this.shadowLayers,
  });
  final int particleCount;
  final bool backdropFilterEnabled;
  final _AnimationComplexity animationComplexity;
  final int targetFPS;
  final Duration chartAnimationDuration;
  final _FilterQuality imageQuality;
  final int shadowLayers;
}

enum PerformanceTier { flagship, highEnd, midRange, lowEnd }

enum _AnimationComplexity { full, reduced, minimal }

enum _FilterQuality { high, medium, low }

class DevicePerformanceTier {
  // Detect device capability at first launch:
  static late PerformanceTier _tier;
  static bool _initialized = false;

  static Future<void> detect() async {
    if (_initialized) return;

    // final deviceInfo = await DeviceInfoPlugin().androidInfo;
    // final memoryMB = deviceInfo.totalRam ~/ 1024 ~/ 1024; // Android
    const simulatedRam = 3000; // Simulated mid-range hardware

    _tier = switch (simulatedRam) {
      >= 6000 => PerformanceTier.flagship, // 6GB+ RAM
      >= 4000 => PerformanceTier.highEnd, // 4-6GB RAM
      >= 2000 => PerformanceTier.midRange, // 2-4GB RAM
      _ => PerformanceTier.lowEnd, // < 2GB RAM
    };

    _initialized = true;
  }

  // Apply performance settings per tier:
  static PerformanceConfig get config => switch (_tier) {
        PerformanceTier.flagship => const PerformanceConfig(
            particleCount: 30,
            backdropFilterEnabled: true,
            animationComplexity: _AnimationComplexity.full,
            targetFPS: 120,
            chartAnimationDuration: Duration(milliseconds: 800),
            imageQuality: _FilterQuality.high,
            shadowLayers: 3,
          ),
        PerformanceTier.highEnd => const PerformanceConfig(
            particleCount: 20,
            backdropFilterEnabled: true,
            animationComplexity: _AnimationComplexity.full,
            targetFPS: 60,
            chartAnimationDuration: Duration(milliseconds: 600),
            imageQuality: _FilterQuality.medium,
            shadowLayers: 2,
          ),
        PerformanceTier.midRange => const PerformanceConfig(
            particleCount: 10,
            backdropFilterEnabled: true,
            animationComplexity: _AnimationComplexity.reduced,
            targetFPS: 60,
            chartAnimationDuration: Duration(milliseconds: 400),
            imageQuality: _FilterQuality.medium,
            shadowLayers: 1,
          ),
        PerformanceTier.lowEnd => const PerformanceConfig(
            particleCount: 0, // No particles
            backdropFilterEnabled: false, // No blur effects
            animationComplexity: _AnimationComplexity.minimal,
            targetFPS: 60,
            chartAnimationDuration: Duration(milliseconds: 200),
            imageQuality: _FilterQuality.low,
            shadowLayers: 0, // No shadows
          ),
      };

  static bool get isLowEnd => _initialized && _tier == PerformanceTier.lowEnd;
  static bool get supportsHighFPS =>
      _initialized && _tier == PerformanceTier.flagship;
}
