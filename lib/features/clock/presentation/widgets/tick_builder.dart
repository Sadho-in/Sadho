import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/clock_source.dart';

/// Rebuilds [builder] every [interval] with the current time (from
/// [clockNowProvider], so tests can drive it). The timer belongs to the widget
/// and stops with it, and while [active] is false.
class TickBuilder extends ConsumerStatefulWidget {
  const TickBuilder({
    super.key,
    required this.builder,
    this.interval = const Duration(seconds: 1),
    this.active = true,
    this.onTick,
  });

  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;
  final bool active;

  /// Called on every tick, before the rebuild.
  final void Function(DateTime now)? onTick;

  @override
  ConsumerState<TickBuilder> createState() => _TickBuilderState();
}

class _TickBuilderState extends ConsumerState<TickBuilder> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(TickBuilder old) {
    super.didUpdateWidget(old);
    if (old.active != widget.active || old.interval != widget.interval) _sync();
  }

  void _sync() {
    _timer?.cancel();
    _timer = null;
    if (!widget.active) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) return;
      widget.onTick?.call(ref.read(clockNowProvider)());
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, ref.read(clockNowProvider)());
}
