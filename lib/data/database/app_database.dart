// ignore_for_file: prefer_constructors_over_static_methods
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:focusguard_pro/data/database/tables.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Offline-first SQLite database using drift.
/// Run `dart run build_runner build` to generate app_database.g.dart
@DriftDatabase(tables: [Sessions, DailyStats, KanbanTasks, SyncQueue, Goals])
class AppDatabase extends _$AppDatabase {
  AppDatabase._() : super(_openConnection());

  static AppDatabase? _instance;
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          debugPrint('📦 Database created');
        },
      );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'focusguard.sqlite'));
      return NativeDatabase.createInBackground(file, logStatements: kDebugMode);
    });
