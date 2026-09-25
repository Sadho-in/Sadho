import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';
import '../application/stopwatch_provider.dart';
import '../application/sun_alarm_provider.dart';
import '../application/timer_provider.dart';
import '../data/clock_tool.dart';
import '../data/timer_presets.dart';
import 'tools/big_clock_page.dart';
import 'tools/stopwatch_page.dart';
import 'tools/sun_alarm_page.dart';
import 'tools/timer_page.dart';
import 'tools/world_clock_page.dart';
import 'widgets/tick_builder.dart';
import '../../../l10n/date_formats.dart';

/// Opens [tool] full-screen.
Future<void> openClockTool(BuildContext context, ClockTool tool) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => switch (tool) {
          ClockTool.clock => const BigClockPage(),
          ClockTool.sunAlarm => const SunAlarmPage(),
          ClockTool.worldClock => const WorldClockPage(),
          ClockTool.timer => const TimerPage(),
          ClockTool.stopwatch => const StopwatchPage(),
        },
      ),
    );

/// Clock tab: a list of tools, each opening full-screen.
class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            for (final tool in ClockTool.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ToolCard(tool: tool),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToolCard extends ConsumerWidget {
  const _ToolCard({required this.tool});
  final ClockTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    return Card(
      key: ValueKey('tool-${tool.name}'),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => openClockTool(context, tool),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: Icon(tool.icon, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tool.localizedTitle(l), style: theme.textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      tool.localizedSubtitle(l),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    _Status(tool: tool),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// A live one-liner under a tool that is doing something (a running timer, an
/// alarm that is on), so the list shows what is going on at a glance.
class _Status extends ConsumerWidget {
  const _Status({required this.tool});
  final ClockTool tool;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final style = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        );
    Widget line(String text) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            text,
            key: ValueKey('status-${tool.name}'),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        );

    switch (tool) {
      case ClockTool.sunAlarm:
        final s = ref.watch(sunAlarmProvider);
        if (!s.enabled) return const SizedBox.shrink();
        final upcoming = ref.watch(upcomingSunAlarmsProvider);
        final at = upcoming.isEmpty
            ? ''
            : ' · ${AppDates.of(context).time(upcoming.first.alarm)}';
        return line('${l.statusOn} · ${offsetLabelIn(l, s.offsetMinutes, s.event)}$at');
      case ClockTool.timer:
        final t = ref.watch(timerProvider);
        if (t.phase == TimerPhase.idle) return const SizedBox.shrink();
        final label = presetLabelFor(l, t.presetId, t.label);
        return TickBuilder(
          active: t.running,
          builder: (context, now) {
            final left = t.remainingAt(now);
            if (t.phase == TimerPhase.finished || (t.running && left <= 0)) {
              return line('$label · ${l.finished}');
            }
            return line(
                '$label · ${formatCountdown(left)} ${t.running ? l.left : l.paused}');
          },
        );
      case ClockTool.stopwatch:
        final sw = ref.watch(stopwatchProvider);
        if (sw.isZero) return const SizedBox.shrink();
        return TickBuilder(
          interval: const Duration(milliseconds: 200),
          active: sw.running,
          builder: (context, now) => line(
              '${sw.running ? l.runningStatus : l.stoppedStatus} · ${formatStopwatch(sw.elapsedAt(now))}'),
        );
      case ClockTool.clock:
      case ClockTool.worldClock:
        return const SizedBox.shrink();
    }
  }
}
