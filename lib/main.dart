import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'core/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF070B1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox('sessions');
  await Hive.openBox('daily_stats');
  await Hive.openBox('goals');
  await Hive.openBox('blocker');
  await Hive.openBox('settings');
  await Hive.openBox('achievements');

  runApp(const ProviderScope(child: FocusGuardApp()));
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FocusGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
