import 'package:flutter/material.dart';

// FIX 1: Unsafe null assertions (! operator)
void safeNullAccess() {
  final user = <String, dynamic>{'displayName': 'John'};

  // FIXED: Provide default fallback
  final name = user['displayName'] as String? ?? 'User';
  debugPrint(name);
}

// FIX 2: Late variable not initialized
class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

class _ControllerExampleState extends State<ControllerExample>
    with SingleTickerProviderStateMixin {
  // FIXED:
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Always initialize in initState
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}

// FIX 3: Null check on non-nullable type (dead code warning)
void checkNonNullable(String nonNullableString) {
  // FIXED: Remove the check — compiler guarantees non-null
  debugPrint(nonNullableString.toUpperCase());
}

// FIX 4: Nullable collection iteration
void iterateNullableCollection(List<String>? items) {
  // FIXED:
  for (final item in items ?? <String>[]) {
    debugPrint(item);
  }
}

// FIX 5: Missing null check before method call
void checkStringLength(String? maybeString) {
  // FIXED:
  final length = maybeString?.length ?? 0;
  debugPrint('Length: $length');
}

// FIX 6: Conditional access result not checked
void handleConditionalAccess(Map<String, dynamic> map) {
  // FIXED:
  final result = map['key']?.toString();
  if (result != null) {
    debugPrint(result.toUpperCase());
  }
}
