import 'package:flutter/material.dart';
import 'package:focusguard_pro/presentation/screens/accountability_screen.dart';
import 'package:focusguard_pro/presentation/screens/achievements_screen.dart';
import 'package:focusguard_pro/presentation/screens/ai_coaching_screen.dart';
import 'package:focusguard_pro/presentation/screens/analytics_screen.dart';
import 'package:focusguard_pro/presentation/screens/app_blocker_screen.dart';
import 'package:focusguard_pro/presentation/screens/auth/login_screen.dart';
import 'package:focusguard_pro/presentation/screens/auth/signup_screen.dart';
import 'package:focusguard_pro/presentation/screens/challenges_screen.dart';
import 'package:focusguard_pro/presentation/screens/digital_wellbeing_screen.dart';
import 'package:focusguard_pro/presentation/screens/focus_session_screen.dart';
import 'package:focusguard_pro/presentation/screens/focus_spaces_screen.dart';
import 'package:focusguard_pro/presentation/screens/goals_screen.dart';
import 'package:focusguard_pro/presentation/screens/habits_screen.dart';
import 'package:focusguard_pro/presentation/screens/home_screen.dart';
import 'package:focusguard_pro/presentation/screens/journal_screen.dart';
import 'package:focusguard_pro/presentation/screens/kanban_screen.dart';
import 'package:focusguard_pro/presentation/screens/leaderboard_screen.dart';
import 'package:focusguard_pro/presentation/screens/onboarding_screen.dart';
import 'package:focusguard_pro/presentation/screens/overlay_nudge_screen.dart';
import 'package:focusguard_pro/presentation/screens/permissions_screen.dart';
import 'package:focusguard_pro/presentation/screens/profile_screen.dart';
import 'package:focusguard_pro/presentation/screens/settings_screen.dart';
import 'package:focusguard_pro/presentation/screens/shell_screen.dart';
import 'package:focusguard_pro/presentation/screens/splash_screen.dart';
import 'package:focusguard_pro/presentation/screens/subscription_screen.dart';
import 'package:focusguard_pro/presentation/screens/terms_screen.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (ctx, a, sa, c) =>
          FadeTransition(opacity: a, child: c),
    );

CustomTransitionPage _slidePage(
  GoRouterState state,
  Widget child, {
  Offset begin = const Offset(1, 0),
}) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (ctx, a, sa, c) => SlideTransition(
        position: Tween(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
        ),
        child: c,
      ),
    );

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (c, s) => _fadePage(s, const OnboardingScreen()),
    ),
    GoRoute(
      path: '/permissions',
      pageBuilder: (c, s) => _fadePage(s, const PermissionsScreen()),
    ),
    GoRoute(
      path: '/terms',
      pageBuilder: (c, s) => _fadePage(s, const TermsScreen()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (c, s) => _slidePage(s, const LoginScreen()),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (c, s) => _slidePage(s, const SignupScreen()),
    ),

    // Main app shell with bottom navigation
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (c, s, child) => ShellScreen(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (c, s) => _fadePage(s, const HomeScreen()),
        ),
        GoRoute(
          path: '/focus',
          pageBuilder: (c, s) => _fadePage(s, const FocusSessionScreen()),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (c, s) => _fadePage(s, const AnalyticsScreen()),
        ),
        GoRoute(
          path: '/blocker',
          pageBuilder: (c, s) => _fadePage(s, const AppBlockerScreen()),
        ),
      ],
    ),

    // Standalone screens (outside shell)
    GoRoute(
      path: '/goals',
      pageBuilder: (c, s) =>
          _slidePage(s, const GoalsScreen(), begin: const Offset(0, 1)),
    ),
    GoRoute(
      path: '/habits',
      pageBuilder: (c, s) => _slidePage(s, const HabitsScreen()),
    ),
    GoRoute(
      path: '/achievements',
      pageBuilder: (c, s) => _slidePage(s, const AchievementsScreen()),
    ),
    GoRoute(
      path: '/challenges',
      pageBuilder: (c, s) => _slidePage(s, const ChallengesScreen()),
    ),
    GoRoute(
      path: '/leaderboard',
      pageBuilder: (c, s) => _slidePage(s, const LeaderboardScreen()),
    ),
    GoRoute(
      path: '/subscription',
      pageBuilder: (c, s) => _slidePage(
        s,
        const SubscriptionScreen(),
        begin: const Offset(0, 1),
      ),
    ),
    GoRoute(
      path: '/ai-coaching',
      pageBuilder: (c, s) => _slidePage(s, const AiCoachingScreen()),
    ),
    GoRoute(
      path: '/journal',
      pageBuilder: (c, s) => _slidePage(s, const JournalScreen()),
    ),
    GoRoute(
      path: '/digital-wellbeing',
      pageBuilder: (c, s) => _slidePage(s, const DigitalWellbeingScreen()),
    ),
    GoRoute(
      path: '/focus-spaces',
      pageBuilder: (c, s) => _slidePage(s, const FocusSpacesScreen()),
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (c, s) => _slidePage(s, const ProfileScreen()),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (c, s) => _slidePage(s, const SettingsScreen()),
    ),
    GoRoute(
      path: '/overlay-nudge',
      pageBuilder: (c, s) => _fadePage(s, const OverlayNudgeScreen()),
    ),
    GoRoute(
      path: '/accountability',
      pageBuilder: (c, s) => _slidePage(s, const AccountabilityScreen()),
    ),
    GoRoute(
      path: '/kanban',
      pageBuilder: (c, s) => _slidePage(s, const KanbanScreen()),
    ),
  ],
);
