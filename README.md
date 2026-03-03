# FocusGuard Pro 🛡️

> **Guard your focus. Own your time.**

The most advanced productivity and digital wellness SaaS app for iOS & Android, built with Flutter.

## ✨ Features

| Category | Features |
|----------|----------|
| 🚫 **App Blocking** | Real-time app detection, overlay screen, strict mode, smart schedules |
| ⏱️ **Screen Time** | Per-app tracking, daily/weekly analytics, pickup count |
| 🎯 **Focus Sessions** | Pomodoro timer, ambient sounds, 14 sound options, custom intervals |
| 📊 **Productivity Score** | 16-factor algorithm, score breakdown, daily/weekly trends |
| 🤖 **AI Coaching** | GPT-4o powered coach, daily insights, pattern analysis |
| 📅 **Goals & Habits** | Daily screen time goals, habit tracker with streaks, stacking |
| 🏆 **Gamification** | XP, levels, 50+ achievements, leaderboards, challenges |
| 📝 **Journaling** | Daily entries with mood, gratitude, tags, search |
| 👥 **Social** | Accountability partners, community challenges, referrals |
| 📈 **Reports** | Weekly/monthly PDF/CSV exports, AI-generated insights |
| 🌙 **Wellbeing** | Bedtime mode, breathing exercises, eye strain reminders |
| 🔒 **Security** | PIN lock, biometric auth, strict mode with parent lock |

## 🏗️ Architecture

```
lib/
├── core/                  # Constants, theme, extensions, errors, network
│   ├── constants/         # API, route, asset, app constants
│   ├── extensions/        # Context, string, datetime, duration
│   ├── errors/            # Exceptions, Result type, error handler
│   ├── network/           # Dio client with retries
│   └── services/          # Analytics, crash, biometric, audio, haptic
├── data/
│   ├── models/            # 20 data models with JSON serialization
│   ├── datasources/       # Hive, SecureStorage, SharedPrefs
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Domain entities
│   ├── repositories/      # Abstract repository interfaces
│   └── use_cases/         # 42 use cases across 10 categories
├── presentation/
│   ├── providers/         # Riverpod providers
│   └── screens/           # 38 screens
├── services/              # App blocker, usage tracker, etc.
└── main.dart
```

## 🛠️ Tech Stack

- **Flutter** 3.19+ with Dart 3.x (sound null safety)
- **State Management**: Riverpod 2.x
- **Local DB**: Hive + Isar
- **Backend**: Firebase (Auth, Firestore, Functions, Crashlytics)
- **Purchases**: RevenueCat
- **Navigation**: go_router 13.x with deep linking
- **AI**: OpenAI GPT-4o
- **Native**: Kotlin (Android), Swift (iOS)

## 🚀 Getting Started

```bash
git clone https://github.com/your-org/focusguard-pro.git
cd focusguard-pro
cp .env.example .env  # Add your API keys
flutter pub get
flutter run
```

### Required API Keys (.env)
```
OPENAI_API_KEY=sk-...
FIREBASE_API_KEY=...
REVENUECAT_API_KEY_ANDROID=rc_...
REVENUECAT_API_KEY_IOS=rc_...
```

## 💰 Subscription Tiers

| Tier | Price | Features |
|------|-------|----------|
| **Basic** | $5.99/mo | 3 blocked apps, basic analytics, 25min timer |
| **Pro** | $9.99/mo | Unlimited blocks, all timers, AI coaching (10/day), habits, challenges |
| **Elite** | $12.99/mo | Everything + strict mode, focus spaces, unlimited AI, priority support |

## 📱 Screenshots

*Coming soon*

## 🧪 Testing

```bash
flutter test                        # Unit + widget tests
flutter test --coverage             # With coverage
flutter test integration_test/      # Integration tests
```

## 📦 Build

```bash
flutter build apk --release --split-per-abi   # Android APK
flutter build appbundle --release              # Android App Bundle
flutter build ios --release                    # iOS
```

## 📄 License

Copyright © 2026 FocusGuard. All rights reserved.
