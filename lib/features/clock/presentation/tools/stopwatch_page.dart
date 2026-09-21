import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/stopwatch_provider.dart';
import '../widgets/tick_builder.dart';

/// Full-screen Paath stopwatch: start / stop / lap, with the laps listed below.
/// It keeps counting when this screen is closed.
class StopwatchPage extends ConsumerWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final sw = ref.watch(stopwatchProvider);
    final notifier = ref.read(stopwatchProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paath stopwatch')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TickBuilder(
                    interval: const Duration(milliseconds: 50),
                    active: sw.running,
                    builder: (context, now) => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        formatStopwatch(sw.elapsedAt(now)),
                        key: const ValueKey('sw-time'),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 88,
                          fontWeight: FontWeight.w300,
                          color: sw.running ? scheme.primary : scheme.onSurface,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: sw.running
                            ? OutlinedButton.icon(
                                key: const ValueKey('sw-lap'),
                                onPressed: notifier.lap,
                                icon: const Icon(Icons.flag_outlined),
                                label: const Text('Lap'),
                                style: _big,
                              )
                            : OutlinedButton.icon(
                                key: const ValueKey('sw-reset'),
                                onPressed: sw.isZero ? null : notifier.reset,
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Reset'),
                                style: _big,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('sw-toggle'),
                          onPressed: sw.running ? notifier.stop : notifier.start,
                          icon: Icon(sw.running ? Icons.stop : Icons.play_arrow),
                          label: Text(sw.running ? 'Stop' : 'Start'),
                          style: _big,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: sw.laps.isEmpty
                      ? Center(
                          child: Text(
                            sw.running
                                ? 'Tap Lap to mark a lap.'
                                : 'Start, then tap Lap at each round.',
                            key: const ValueKey('sw-empty'),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : _LapList(laps: sw.laps),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static final _big = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size.fromHeight(56)),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    ),
  );
}

class _LapList extends StatelessWidget {
  const _LapList({required this.laps});

  /// Newest first.
  final List<LapEntry> laps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Fastest and slowest only mean something once there are three laps.
    Duration? best, worst;
    if (laps.length >= 3) {
      best = laps.map((l) => l.lap).reduce((a, b) => a < b ? a : b);
      worst = laps.map((l) => l.lap).reduce((a, b) => a > b ? a : b);
      if (best == worst) best = worst = null;
    }
    final mono = theme.textTheme.titleMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: laps.length + 1,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        if (i == 0) {
          final head = theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(width: 72, child: Text('Lap', style: head)),
                Expanded(child: Text('Lap time', style: head)),
                Text('Total', style: head),
              ],
            ),
          );
        }
        final l = laps[i - 1];
        final tag = l.lap == best
            ? 'Fastest'
            : (l.lap == worst ? 'Slowest' : null);
        final color = l.lap == best
            ? scheme.tertiary
            : (l.lap == worst ? scheme.error : null);
        return Padding(
          key: ValueKey('lap-${l.number}'),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text('${l.number}', style: mono?.copyWith(color: color)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatStopwatch(l.lap),
                      key: ValueKey('lap-${l.number}-time'),
                      style: mono?.copyWith(color: color),
                    ),
                    if (tag != null)
                      Text(tag,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: color)),
                  ],
                ),
              ),
              Text(
                formatStopwatch(l.total),
                key: ValueKey('lap-${l.number}-total'),
                style: mono?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}
