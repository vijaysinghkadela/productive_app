import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════
// COLOR PALETTE — Deep Space Glassmorphism
// ════════════════════════════════════════════════════════════════

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF070B1A);
  static const Color backgroundSecondary = Color(0xFF0D1225);
  static const Color surface = Color(0xFF0D1225);
  static const Color surfaceLight = Color(0xFF141A33);

  // Accents
  static const Color primary = Color(0xFF6C63FF); // Electric violet
  static const Color secondary = Color(0xFF00D4FF); // Electric cyan
  static const Color tertiary = Color(0xFFFF6B9D); // Neon pink
  static const Color success = Color(0xFF00FFB2); // Neon mint
  static const Color warning = Color(0xFFFFB800); // Amber gold
  static const Color alert = Color(0xFFFF4757); // Coral red
  static const Color streak = Color(0xFFFF6B35); // Burning orange

  // Legacy aliases (used by existing code)
  static const Color accent = secondary;
  static const Color primaryLight = Color(0xFF8B83FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xA6FFFFFF); // 65% white
  static const Color textTertiary = Color(0x59FFFFFF); // 35% white

  // Glass
  static const Color cardGlass = Color(0x0AFFFFFF); // 4% white
  static const Color cardBorder = Color(0x14FFFFFF); // 8% white
  static const Color cardBorderLight = Color(0x1FFFFFFF); // 12% white
  static const Color shimmer = Color(0xFF141A33);

  // Score colors
  static Color scoreColor(int score) {
    if (score >= 86) return success;
    if (score >= 71) return secondary;
    if (score >= 41) return warning;
    return alert;
  }
}

// ════════════════════════════════════════════════════════════════
// GRADIENTS
// ════════════════════════════════════════════════════════════════

class AppGradients {
  static const hero = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const energy = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const mint = LinearGradient(
    colors: [Color(0xFF00FFB2), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const cardShine = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const glass = LinearGradient(
    colors: [Color(0x0FFFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const scoreLow = LinearGradient(
    colors: [Color(0xFFFF4757), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const scoreMid = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const scoreHigh = LinearGradient(
    colors: [Color(0xFF00FFB2), Color(0xFF00D4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ════════════════════════════════════════════════════════════════
// ANIMATION CONSTANTS
// ════════════════════════════════════════════════════════════════

class Anim {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration xSlow = Duration(milliseconds: 1200);

  static const Curve easeIn = Cubic(0.4, 0, 1, 1);
  static const Curve easeOut = Cubic(0, 0, 0.2, 1);
  static const Curve easeInOut = Cubic(0.4, 0, 0.2, 1);
  static const Curve bounce = ElasticOutCurve(0.6);

  static const SpringDescription spring = SpringDescription(
    mass: 1.0,
    stiffness: 200,
    damping: 20,
  );

  static const SpringDescription springBouncy = SpringDescription(
    mass: 1.0,
    stiffness: 300,
    damping: 15,
  );
}

// Legacy alias
class AppDurations {
  static const Duration splashDelay = Duration(seconds: 3);
  static const Duration animationFast = Anim.fast;
  static const Duration animationMedium = Anim.normal;
  static const Duration animationSlow = Anim.slow;
  static const Duration pollingInterval = Duration(seconds: 2);
}

// ════════════════════════════════════════════════════════════════
// SPACING SCALE (Material 3 / HIG aligned)
// ════════════════════════════════════════════════════════════════

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

// ════════════════════════════════════════════════════════════════
// BORDER RADII
// ════════════════════════════════════════════════════════════════

class AppRadius {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 100;
}

// ════════════════════════════════════════════════════════════════
// SIZE CONSTRAINTS (a11y compliant)
// ════════════════════════════════════════════════════════════════

class AppSizes {
  /// Minimum touch target per Material 3 (48dp) & HIG (44pt)
  static const double minTouchTarget = 48;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 64;
  static const double cardMinHeight = 80;
  static const double bottomNavHeight = 72;
  static const double appBarHeight = 56;
}

// ════════════════════════════════════════════════════════════════
// SHADOWS & EFFECTS
// ════════════════════════════════════════════════════════════════

class AppShadows {
  static List<BoxShadow> glow(
    Color color, {
    double blur = 20,
    double spread = 0,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: 0.4),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x66000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedGlow(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
        const BoxShadow(
          color: Color(0x40000000),
          blurRadius: 32,
          offset: Offset(0, 8),
        ),
      ];
}

// ════════════════════════════════════════════════════════════════
// APP DATA
// ════════════════════════════════════════════════════════════════

class AppStrings {
  static const String appName = 'FocusGuard Pro';
  static const String tagline = 'Guard your focus. Own your time.';
}

class AppAssets {
  static const String animationsPath = 'assets/animations/';
  static const String imagesPath = 'assets/images/';
  static const String soundsPath = 'assets/sounds/';
}

class PomodoroPreset {
  const PomodoroPreset(
    this.workMinutes,
    this.breakMinutes,
    this.label, [
    this.emoji = '🎯',
  ]);
  final int workMinutes;
  final int breakMinutes;
  final String label;
  final String emoji;
}

const List<PomodoroPreset> pomodoroPresets = [
  PomodoroPreset(25, 5, 'Classic', '🍅'),
  PomodoroPreset(50, 10, 'Extended', '⚡'),
  PomodoroPreset(90, 20, 'Deep Work', '🧠'),
  PomodoroPreset(15, 3, 'Sprint', '🏃'),
  PomodoroPreset(120, 30, 'Marathon', '🏋️'),
];

const List<String> sessionTypes = [
  'Deep Work',
  'Study',
  'Creative',
  'Reading',
  'Exercise',
  'Meditation',
  'Planning',
  'Coding',
];

const Map<String, String> sessionEmojis = {
  'Deep Work': '🧠',
  'Study': '📚',
  'Creative': '🎨',
  'Reading': '📖',
  'Exercise': '💪',
  'Meditation': '🧘',
  'Planning': '📋',
  'Coding': '💻',
};

const List<Map<String, String>> ambientSounds = [
  {'name': 'Rain', 'icon': '🌧️', 'file': 'rain.mp3'},
  {'name': 'White Noise', 'icon': '📻', 'file': 'white_noise.mp3'},
  {'name': 'Lo-fi Beats', 'icon': '🎵', 'file': 'lofi.mp3'},
  {'name': 'Forest', 'icon': '🌲', 'file': 'forest.mp3'},
  {'name': 'Ocean Waves', 'icon': '🌊', 'file': 'ocean.mp3'},
  {'name': 'Coffee Shop', 'icon': '☕', 'file': 'coffee_shop.mp3'},
  {'name': 'Thunderstorm', 'icon': '⛈️', 'file': 'thunder.mp3'},
  {'name': 'Fireplace', 'icon': '🔥', 'file': 'fireplace.mp3'},
  {'name': 'Wind Chimes', 'icon': '🎐', 'file': 'wind_chimes.mp3'},
  {'name': 'Night Crickets', 'icon': '🦗', 'file': 'crickets.mp3'},
  {'name': 'Birds', 'icon': '🐦', 'file': 'birds.mp3'},
  {'name': 'Piano', 'icon': '🎹', 'file': 'piano.mp3'},
  {'name': 'Space', 'icon': '🚀', 'file': 'space.mp3'},
  {'name': 'Silence', 'icon': '🤫', 'file': ''},
];

const List<String> socialMediaApps = [
  'Instagram',
  'TikTok',
  'YouTube',
  'Twitter/X',
  'Facebook',
  'Snapchat',
  'Reddit',
  'Pinterest',
  'LinkedIn',
  'WhatsApp',
  'Telegram',
  'Discord',
  'Threads',
  'BeReal',
];

const List<String> motivationalQuotes = [
  'The secret of getting ahead is getting started. — Mark Twain',
  'Focus on being productive instead of busy. — Tim Ferriss',
  "Your time is limited. Don't waste it living someone else's life. — Steve Jobs",
  "It's not that I'm so smart, it's just that I stay with problems longer. — Albert Einstein",
  'The way to get started is to quit talking and begin doing. — Walt Disney',
  "You don't have to be great to start, but you have to start to be great. — Zig Ziglar",
  'Amateurs sit and wait for inspiration. The rest of us just get up and go to work. — Stephen King',
  'Productivity is never an accident. It is always the result of commitment to excellence. — Paul J. Meyer',
  'Action is the foundational key to all success. — Pablo Picasso',
  'The only way to do great work is to love what you do. — Steve Jobs',
  "Don't count the days. Make the days count. — Muhammad Ali",
  'Start where you are. Use what you have. Do what you can. — Arthur Ashe',
  'The future depends on what you do today. — Mahatma Gandhi',
  'You are never too old to set another goal or to dream a new dream. — C.S. Lewis',
  'Success is not final, failure is not fatal: it is the courage to continue that counts. — Winston Churchill',
  "Believe you can and you're halfway there. — Theodore Roosevelt",
  'Hardships often prepare ordinary people for an extraordinary destiny. — C.S. Lewis',
  "It always seems impossible until it's done. — Nelson Mandela",
  'What you get by achieving your goals is not as important as what you become. — Zig Ziglar',
  'Dream big and dare to fail. — Norman Vaughan',
  'The best time to plant a tree was 20 years ago. The second best time is now. — Chinese Proverb',
  "Don't watch the clock; do what it does. Keep going. — Sam Levenson",
  "Everything you've ever wanted is on the other side of fear. — George Addair",
  "Opportunities don't happen. You create them. — Chris Grosser",
  'Success usually comes to those who are too busy to be looking for it. — Henry David Thoreau',
  'I find that the harder I work, the more luck I seem to have. — Thomas Jefferson',
  'The only limit to our realization of tomorrow is our doubts of today. — Franklin D. Roosevelt',
  'Do what you can with all you have, wherever you are. — Theodore Roosevelt',
  'A year from now you may wish you had started today. — Karen Lamb',
  'In the middle of every difficulty lies opportunity. — Albert Einstein',
];
