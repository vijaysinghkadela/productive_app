// ignore_for_file: avoid_catches_without_on_clauses, unused_element, unused_field
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

class AsyncFixesState extends State<StatefulWidget> {
  String _userId = '';
  String _userData = '';

  // FIX 18: Race condition in sequential async calls
  Future<void> _loadUserData() async {
    final userId = await _getUserId();
    if (!mounted) return;

    final userData = await _getUserData(userId);
    if (!mounted) return;

    setState(() {
      _userId = userId;
      _userData = userData;
    });
  }

  // FIX 19: Unawaited future in critical path
  Future<void> onTap() async {
    try {
      await _saveData(); // Properly awaited
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  // FIX 21: Parallel futures error swallowed
  Future<void> testParallelFutures() async {
    // Propagate first error immediately
    final results = await Future.wait(
      [_fetchA(), _fetchB(), _fetchC()],
      eagerError: true,
    );
    debugPrint(results.toString());
  }

  // FIX 22: Isolate not closed after use
  Future<void> spawnSafeIsolate() async {
    final receivePort = ReceivePort();
    final isolate = await Isolate.spawn(_heavyWork, receivePort.sendPort);

    receivePort.listen((result) {
      receivePort.close(); // Close port when done
      isolate.kill(); // Kill isolate to prevent memory leak
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox();

  Future<String> _getUserId() async => '123';
  Future<String> _getUserData(String id) async => 'data';
  Future<void> _saveData() async {}
  Future<dynamic> _fetchA() async {}
  Future<dynamic> _fetchB() async {}
  Future<dynamic> _fetchC() async {}
}

void _heavyWork(SendPort port) {
  port.send('done');
}
