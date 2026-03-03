import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard_pro/data/datasources/local_data_source.dart';
import 'package:focusguard_pro/domain/entities/app_info.dart';
import 'package:focusguard_pro/presentation/providers/focus_timer_provider.dart';

// ─── Blocker Notifier (autoDispose: screen-scoped) ───

class BlockerNotifier extends StateNotifier<List<AppInfo>> {
  BlockerNotifier(this._ds) : super([]) {
    _load();
  }
  final LocalDataSource _ds;

  void _load() => state = _ds.getBlockedApps();

  Future<void> toggleBlock(AppInfo app) async {
    final updated = app.copyWith(isBlocked: !app.isBlocked);
    if (updated.isBlocked) {
      await _ds.saveBlockedApp(updated);
    } else {
      await _ds.removeBlockedApp(updated.packageName);
    }
    _load();
  }

  Future<void> updateApp(AppInfo app) async {
    await _ds.saveBlockedApp(app);
    _load();
  }
}

final blockerProvider =
    StateNotifierProvider.autoDispose<BlockerNotifier, List<AppInfo>>(
  (ref) {
    ref.keepAlive();
    return BlockerNotifier(ref.read(localDataSourceProvider));
  },
);
