import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/data/datasources/local_data_source.dart';
import 'package:focusguard_pro/domain/entities/goal.dart';
import 'package:focusguard_pro/presentation/providers/focus_timer_provider.dart';

// ─── Goals Notifier (autoDispose: frees memory when GoalsScreen unmounts) ───

class GoalsNotifier extends StateNotifier<List<AppGoal>> {
  GoalsNotifier(this._ds) : super([]) {
    _load();
  }
  final LocalDataSource _ds;

  void _load() => state = _ds.getGoals();

  Future<void> addGoal(AppGoal goal) async {
    await _ds.saveGoal(goal);
    _load();
  }

  Future<void> updateGoal(AppGoal goal) async {
    await _ds.saveGoal(goal);
    _load();
  }

  Future<void> removeGoal(String packageName) async {
    await _ds.deleteGoal(packageName);
    _load();
  }
}

final goalsProvider =
    StateNotifierProvider.autoDispose<GoalsNotifier, List<AppGoal>>(
  (ref) {
    ref.keepAlive(); // Prevent disposal while actively used across screens
    return GoalsNotifier(ref.read(localDataSourceProvider));
  },
);
