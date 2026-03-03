import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:focusguard_pro/core/optimization/startup_optimizer.dart';

// Mock dependencies for compilation
class Firebase {
  static Future<void> initializeApp({options}) async {}
}

class DefaultFirebaseOptions {
  static dynamic get currentPlatform => null;
}

class ProviderScope extends StatelessWidget {
  const ProviderScope({
    required this.overrides,
    required this.child,
    super.key,
  });
  final List overrides;
  final Widget child;
  @override
  Widget build(BuildContext context) => child;
}

class FocusGuardApp extends StatelessWidget {
  const FocusGuardApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: Scaffold(body: Text('FocusGuard')));
}

void main() async {
  // Minimize work in main() — every ms here delays app launch
  WidgetsFlutterBinding.ensureInitialized();

  // Critical only:
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Pre-cache system font metrics (prevents layout jank on first render):
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Run Critical Initializations before first frame
  await StartupOptimizer.initializeCritical();

  // Start app immediately:
  runApp(
    const ProviderScope(
      overrides: [], // Empty — providers initialize lazily
      child: FocusGuardApp(),
    ),
  );

  // Deferred initialization (after first frame):
  StartupOptimizer.initializeDeferred();
}
