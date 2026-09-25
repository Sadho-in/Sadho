import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../application/location_provider.dart';
import '../../application/timer_provider.dart';
import '../../data/timer_presets.dart';
import '../widgets/custom_duration_dialog.dart';
import '../widgets/tick_builder.dart';

/// Full-screen Sadhana & vrat timer: pick Aarti, Chalisa, Path, Havan, a
/// Custom length or "Vrat → sunset", then start. At zero it vibrates and rings (the completion
/// feedback), and a notification covers the case where the app is closed.
class TimerPage extends ConsumerWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final locked = t.running;
    final lastCustom = ref.watch(lastCustomTimerProvider);
    final l = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l.clockToolTimerTitle)),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final p in timerPresets)
                            ChoiceChip(
                              key: ValueKey('preset-${p.id}'),
                              avatar: Icon(p.icon, size: 18),
                              label: Text(l.presetChipLabel(
                                  presetLabelFor(l, p.id, p.label), p.minutes)),
                              selected: t.presetId == p.id,
                              onSelected: locked
                                  ? null
                                  : (_) => notifier.selectPreset(p),
                            ),
                          ChoiceChip(
                            key: const ValueKey('preset-custom'),
                            avatar: const Icon(Icons.tune, size: 18),
                            label: Text(lastCustom == null
                                ? l.custom
                                : l.customChipLabel(
                                    formatShortDuration(l, lastCustom))),
                            selected: t.presetId == customTimerId,
                            onSelected: locked
                                ? null
                                : (_) async {
                                    final secs = await showCustomDurationDialog(
                                      context,
                                      initialSeconds: lastCustom ?? 10 * 60,
                                    );
                                    if (secs != null) {
                                      notifier.selectCustom(secs);
                                    }
                                  },
                          ),
                          ChoiceChip(
                            key: const ValueKey('preset-vrat'),
                            avatar: const Icon(Icons.wb_twilight, size: 18),
                            label: Text(l.vratToSunset),
                            selected: t.isVrat,
                            onSelected: locked
                                ? null
                                : (_) => notifier.selectVratToSunset(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      TickBuilder(
                        interval: const Duration(milliseconds: 250),
                        active: t.running,
                        onTick: (_) => notifier.tick(),
                        builder: (context, now) {
                          final left = t.remainingAt(now);
                          final done = t.phase == TimerPhase.finished;
                          final progress = t.totalSeconds <= 0
                              ? 0.0
                              : (left / t.totalSeconds).clamp(0.0, 1.0);
                          return Center(
                            child: SizedBox.square(
                              dimension: math.min(
                                MediaQuery.sizeOf(context).width - 64,
                                320,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned.fill(
                                    child: CircularProgressIndicator(
                                      key: const ValueKey('timer-progress'),
                                      value: done ? 0 : progress,
                                      strokeWidth: 10,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                          scheme.surfaceContainerHigh,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              formatCountdown(left),
                                              key: const ValueKey(
                                                'timer-remaining',
                                              ),
                                              style: theme
                                                  .textTheme
                                                  .displayLarge
                                                  ?.copyWith(
                                                    fontSize: 72,
                                                    fontWeight: FontWeight.w300,
                                                    fontFeatures: const [
                                                      FontFeature.tabularFigures(),
                                                    ],
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          done
                                              ? l.timesUp
                                              : presetLabelFor(l, t.presetId, t.label),
                                          key: const ValueKey('timer-label'),
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: done
                                                    ? scheme.primary
                                                    : scheme.onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (t.isVrat) _VratNote(t: t),
                      if (t.message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            t.message!,
                            key: const ValueKey('timer-message'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          key: const ValueKey('timer-reset'),
                          onPressed: t.phase == TimerPhase.idle
                              ? null
                              : notifier.reset,
                          icon: const Icon(Icons.restart_alt),
                          label: Text(l.actionReset),
                          style: _big,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          key: const ValueKey('timer-toggle'),
                          onPressed: t.running
                              ? notifier.pause
                              : notifier.start,
                          icon: Icon(
                            t.running ? Icons.pause : Icons.play_arrow,
                          ),
                          label: Text(switch (t.phase) {
                            TimerPhase.running => l.pause,
                            TimerPhase.paused => l.resume,
                            TimerPhase.finished => l.startAgain,
                            TimerPhase.idle => l.start,
                          }),
                          style: _big,
                        ),
                      ),
                    ],
                  ),
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

/// Which sunset the vrat counts to, and whose sky it is.
class _VratNote extends ConsumerWidget {
  const _VratNote({required this.t});
  final TimerState t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l = context.l10n;
    final where = ref.watch(locationProvider).summaryIn(l);
    final target = t.vratTarget;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          if (target != null)
            Text(
              l.sunsetAtTime(DateFormat.jm().format(target)),
              key: const ValueKey('vrat-sunset'),
              style: theme.textTheme.titleMedium,
            ),
          Text(
            where,
            key: const ValueKey('vrat-where'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
