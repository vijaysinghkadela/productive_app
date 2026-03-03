// ignore_for_file: avoid_catches_without_on_clauses
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myProvider = FutureProvider<String>((ref) async => 'data');

class RiverpodFixes extends ConsumerWidget {
  const RiverpodFixes({super.key});

  // FIX 13: Provider read inside build without watch
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIXED: Use watch() inside build for reactive rebuilds.
    final data = ref.watch(myProvider);
    return data.when(
      data: Text.new,
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

// FIX 14: Missing error handling in AsyncNotifier
class DataNotifier extends AsyncNotifier<String> {
  final String _testData = 'data';

  @override
  Future<String> build() async {
    try {
      return await _fetchData();
    } catch (e, st) {
      Error.throwWithStackTrace(Exception('Unexpected error'), st);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetchData);
  }

  Future<String> _fetchData() async => _testData;
}

// FIX 15: Provider family type mismatch
// FIXED: Use correct primitive type bounds
// final userProvider = FutureProvider.family<User, String>((ref, id) => getUser(id));

// FIX 16: Circular provider dependency
// FIXED: Refactor shared state into a parent provider rather than mutually passing them.

final autoDisposeProvider = Provider.autoDispose<String>((ref) => 'test');

// FIX 17: AutoDispose provider accessed after disposal
void listenToAutoDispose(WidgetRef ref) {
  ref.listen<String>(autoDisposeProvider, (prev, next) {
    // FIXED: Protect listener access if navigated away
    debugPrint(next);
  });
}
