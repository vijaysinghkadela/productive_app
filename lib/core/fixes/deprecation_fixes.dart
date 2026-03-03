import 'package:flutter/material.dart';

class DeprecationFixes extends StatelessWidget {
  const DeprecationFixes({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX 33: Deprecated MediaQuery properties
    // FIXED: Only trigger rebuilds on very specific size queries
    final width = MediaQuery.sizeOf(context).width;

    // FIX 31: Deprecated WillPopScope
    // FIXED (Flutter 3.22+): PopScope overrides
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBackPress();
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Width is $width'),
              // FIX 37: Deprecated Buttons (RaisedButton/FlatButton)
              ElevatedButton(
                onPressed: () => _showSafeSnackbar(context),
                child: const Text('Show Snackbar'),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Cancel Button'),
              ),
              // FIX 32: Deprecated withOpacity -> withValues
              Container(
                width: 50,
                height: 50,
                color: Colors.blue.withAlpha(128), // Replacement strategy
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBackPress() {}

  // FIX 36: Deprecated Scaffold.of -> ScaffoldMessenger.of
  void _showSafeSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safe Snackbar Call')),
    );
  }

  // FIX 34 & 35: Deprecated ThemeData/TextTheme copying patterns
  static ThemeData buildSafeTheme() => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
          error: Colors.red,
        ),
        scaffoldBackgroundColor: const Color(0xFF070B1A),
        textTheme: const TextTheme(
          // Use modern `display`, `body`, `label` mappings
          displayLarge: TextStyle(fontSize: 32),
          bodyLarge: TextStyle(fontSize: 16),
          bodySmall: TextStyle(fontSize: 12),
          labelSmall: TextStyle(fontSize: 10),
        ),
      );
}

// FIX 38: go_router replaces legacy push/pop patterns
// context.push('/route') instead of Navigator.pushNamed

// FIX 39: test replaces flutter_test references inside test/ dir
// import 'package:flutter_test/flutter_test.dart';
