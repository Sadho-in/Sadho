import 'package:flutter/widgets.dart';

/// Rebuilds the whole app from what is saved, as if it had just been opened.
/// Used after restoring a backup or deleting everything, so no screen or
/// provider keeps showing what used to be there.
class AppRestart extends StatefulWidget {
  const AppRestart({super.key, required this.builder});

  /// Builds the app (its `ProviderScope` included). It is called again, with a
  /// fresh key, on every restart.
  final Widget Function(BuildContext context) builder;

  /// Restarts the app from anywhere below it.
  static void of(BuildContext context) =>
      context.findAncestorStateOfType<_AppRestartState>()?._restart();

  @override
  State<AppRestart> createState() => _AppRestartState();
}

class _AppRestartState extends State<AppRestart> {
  int _epoch = 0;

  void _restart() => setState(() => _epoch++);

  @override
  Widget build(BuildContext context) =>
      KeyedSubtree(key: ValueKey(_epoch), child: widget.builder(context));
}
