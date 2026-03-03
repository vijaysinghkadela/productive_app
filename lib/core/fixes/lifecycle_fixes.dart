// ignore_for_file: discarded_futures, inference_failure_on_instance_creation, inference_failure_on_untyped_parameter, unused_element, unused_field
import 'dart:async';
import 'package:flutter/material.dart';

class LifecycleFixes extends StatefulWidget {
  const LifecycleFixes({super.key});

  @override
  State<LifecycleFixes> createState() => _LifecycleFixesState();
}

class _LifecycleFixesState extends State<LifecycleFixes>
    with SingleTickerProviderStateMixin {
  // FIX 11: GlobalKey reused across rebuilds
  // _key created once in State, not build()
  final _key = GlobalKey();

  late final AnimationController _controller;
  StreamSubscription<int>? _subscription;
  String? _data;
  dynamic _error; // Keeping this because it's required for setState

  @override
  void initState() {
    super.initState();

    // FIX 8: Animation controller always initialized in initState and disposed.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // FIX 9: Stream subscription always cancelled in dispose
    _subscription = const Stream<int>.empty().listen((data) {
      if (mounted) {
        setState(() {
          _data = data.toString();
        });
      }
    });

    // FIX 12: initState calling async properly handled with catchError
    _loadData().catchError((error) {
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers
    _subscription?.cancel(); // Always cancel subscriptions
    super.dispose();
  }

  // FIX 7: setState called after dispose checked via `mounted`
  Future<void> _loadData() async {
    final data = await Future.value('loaded data');
    if (!mounted) return; // Check mounted after every await
    setState(() {
      _data = data;
    });
  }

  // FIX 10: BuildContext used across async gap safely
  Future<void> _showResult() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Safe ScaffoldMessenger Call')),
    );
  }

  @override
  Widget build(BuildContext context) =>
      Container(key: _key, child: Text(_data ?? 'Empty'));
}
