import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../focus_mode_screen.dart';
import '../format.dart';
import 'mode_status.dart';
import 'alarm_late_note.dart';
import 'progress_ring.dart';
import 'stop_alert_button.dart';
import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';

/// Ring text for the current session: count/target, or remaining time for a
/// time target.
({String primary, String secondary}) ringLabels(SadhanaState s, AppLocalizations l) =>
    s.isTimeTarget
        ? (
            primary: formatClock(s.remainingSeconds),
            secondary: l.countedLabel(s.count),
          )
        : (primary: '${s.count}', secondary: l.ofTarget(s.targetCount));

/// Progress ring, then ONE row with the four controls (Reset, − undo, + count,
/// Focus), the primary Start / Pause / Resume button, and a one-line status.
/// Built to sit above the fold, so it is compact; [ringSize] lets the screen
/// shrink the ring to fit short phones.
class CounterSection extends ConsumerWidget {
  const CounterSection({super.key, this.ringSize = 220});

  final double ringSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sadhanaSessionProvider);
    final notifier = ref.read(sadhanaSessionProvider.notifier);
    final theme = Theme.of(context);
    final l = context.l10n;
    final labels = ringLabels(s, l);
    final own = s.activeProgress;
    final started = own.count > 0 || own.elapsedSeconds > 0;

    return Column(
      children: [
        // A tap on the ring counts only in Tap mode; the other modes count
        // from their own input (the + button still adds one in any mode).
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: notifier.tap,
          child: ProgressRing(
            progress: s.progress,
            primaryText: labels.primary,
            secondaryText: labels.secondary,
            completed: s.completed,
            size: ringSize,
            strokeWidth: (ringSize * 0.065).clamp(9.0, 16.0),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Control(
              label: l.actionReset,
              child: IconButton.outlined(
                tooltip: l.actionReset,
                iconSize: 24,
                onPressed: () => _confirmReset(context, s, notifier),
                icon: const Icon(Icons.restart_alt),
              ),
            ),
            _Control(
              label: l.undoLabel,
              child: IconButton.outlined(
                tooltip: l.removeOneTooltip,
                iconSize: 24,
                onPressed: s.count == 0 ? null : notifier.decrement,
                icon: const Icon(Icons.remove),
              ),
            ),
            _Control(
              label: l.countLabel,
              child: IconButton.filled(
                tooltip: l.addOneTooltip,
                iconSize: 34,
                padding: const EdgeInsets.all(10),
                onPressed: s.completed ? null : notifier.increment,
                icon: const Icon(Icons.add),
              ),
            ),
            _Control(
              label: l.focusLabel,
              child: IconButton.outlined(
                tooltip: l.focusModeTooltip,
                iconSize: 24,
                onPressed: () => openFocusMode(context),
                icon: const Icon(Icons.center_focus_strong_outlined),
              ),
            ),
          ],
        ),
        if (s.usesRunToggle) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: s.completed ? null : notifier.toggleRunning,
              icon: Icon(s.running ? Icons.pause : Icons.play_arrow),
              label: Text(s.running ? l.pause : (started ? l.resume : l.start)),
            ),
          ),
        ],
        const SizedBox(height: 6),
        // Always visible, so the active mode and its state are never a guess.
        const ModeStatusLine(compact: true),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: s.completed
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    s.isSeparate
                        ? l.targetReachedSeparate(s.mode.localized(l))
                        : l.targetReachedCombined,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
        const StopAlertButton(),
        if (s.alarmMayBeLate && s.running) const AlarmLateNote(),
      ],
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    SadhanaState s,
    SadhanaSessionNotifier notifier,
  ) async {
    if (s.count == 0 && s.elapsedSeconds == 0) return;
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.isSeparate
            ? l.resetModeCountTitle(s.mode.localized(l))
            : l.resetSessionTitle),
        content: Text(s.isSeparate
            ? l.resetModeCountBody(s.mode.localized(l), s.count)
            : l.resetSessionBody(s.count)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionReset)),
        ],
      ),
    );
    if (ok == true) notifier.reset();
  }
}

/// One control of the action row: the button with a small label under it.
class _Control extends StatelessWidget {
  const _Control({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      );
}
