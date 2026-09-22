import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
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
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.clockToolStopwatchTitle)),
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
                                label: Text(l.lap),
                                style: _big,
                              )
                            : OutlinedButton.icon(
                                key: const ValueKey('sw-reset'),
                                onPressed: sw.isZero ? null : notifier.reset,
                                icon: const Icon(Icons.restart_alt),
                                label: Text(l.actionReset),
                                style: _big,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('sw-toggle'),
                          onPressed: sw.running ? notifier.stop : notifier.start,
                          icon: Icon(sw.running ? Icons.stop : Icons.play_arrow),
                          label: Text(sw.running ? l.stop : l.start),
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
                            sw.running ? l.tapLapToMark : l.startThenTapLap,
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
    final l = context.l10n;
    // Fastest and slowest only mean something once there are three laps.
    Duration? best, worst;
    if (laps.length >= 3) {
      best = laps.map((e) => e.lap).reduce((a, b) => a < b ? a : b);
      worst = laps.map((e) => e.lap).reduce((a, b) => a > b ? a : b);
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
                SizedBox(width: 72, child: Text(l.lap, style: head)),
                Expanded(child: Text(l.lapTime, style: head)),
                Text(l.total, style: head),
              ],
            ),
          );
        }
        final entry = laps[i - 1];
        final tag = entry.lap == best
            ? l.fastest
            : (entry.lap == worst ? l.slowest : null);
        final color = entry.lap == best
            ? scheme.tertiary
            : (entry.lap == worst ? scheme.error : null);
        return Padding(
          key: ValueKey('lap-${entry.number}'),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                child: Text('${entry.number}', style: mono?.copyWith(color: color)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatStopwatch(entry.lap),
                      key: ValueKey('lap-${entry.number}-time'),
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
                formatStopwatch(entry.total),
                key: ValueKey('lap-${entry.number}-total'),
                style: mono?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}
