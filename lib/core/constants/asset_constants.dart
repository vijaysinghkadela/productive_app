/// Asset path constants for FocusGuard Pro
class AssetConstants {
  AssetConstants._();

  // Animation paths
  static const String animationsDir = 'assets/animations/';
  static const String splashAnimation = '${animationsDir}splash.json';
  static const String confettiAnimation = '${animationsDir}confetti.json';
  static const String loadingAnimation = '${animationsDir}loading.json';
  static const String emptyAnimation = '${animationsDir}empty.json';
  static const String achievementAnimation = '${animationsDir}achievement.json';

  // Image paths
  static const String imagesDir = 'assets/images/';
  static const String logo = '${imagesDir}logo.png';
  static const String onboarding1 = '${imagesDir}onboarding_1.png';
  static const String onboarding2 = '${imagesDir}onboarding_2.png';
  static const String onboarding3 = '${imagesDir}onboarding_3.png';

  // Sound paths
  static const String soundsDir = 'assets/sounds/';
  static const String rainSound = '${soundsDir}rain.mp3';
  static const String thunderstormSound = '${soundsDir}thunderstorm.mp3';
  static const String cafeSound = '${soundsDir}cafe.mp3';
  static const String whiteNoiseSound = '${soundsDir}white_noise.mp3';
  static const String brownNoiseSound = '${soundsDir}brown_noise.mp3';
  static const String pinkNoiseSound = '${soundsDir}pink_noise.mp3';
  static const String forestSound = '${soundsDir}forest.mp3';
  static const String oceanSound = '${soundsDir}ocean.mp3';
  static const String fireplaceSound = '${soundsDir}fireplace.mp3';
  static const String lofiSound = '${soundsDir}lofi.mp3';
  static const String riverSound = '${soundsDir}river.mp3';
  static const String fanSound = '${soundsDir}fan.mp3';
  static const String cityNightSound = '${soundsDir}city_night.mp3';
  static const String librarySound = '${soundsDir}library.mp3';

  // Env
  static const String envFile = '.env';

  // Fonts (Google Fonts loaded at runtime)
  static const String primaryFont = 'SpaceGrotesk';
  static const String bodyFont = 'Inter';
}
