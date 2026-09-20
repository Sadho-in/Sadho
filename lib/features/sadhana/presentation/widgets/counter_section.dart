import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../focus_mode_screen.dart';
import '../format.dart';
import 'mode_meta.dart';
import 'mode_status.dart';
import 'progress_ring.dart';

/// Ring text for the current session: count/target, or remaining time for a
/// time target.
({String primary, String secondary}) ringLabels(SadhanaState s) => s.isTimeTarget
    ? (
        primary: formatClock(s.remainingSeconds),
        secondary: '${s.count} counted',
      )
    : (primary: '${s.count}', secondary: 'of ${s.targetCount}');

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
    final labels = ringLabels(s);
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
              label: 'Reset',
              child: IconButton.outlined(
                tooltip: 'Reset',
                iconSize: 24,
                onPressed: () => _confirmReset(context, s, notifier),
                icon: const Icon(Icons.restart_alt),
              ),
            ),
            _Control(
              label: 'Undo',
              child: IconButton.outlined(
                tooltip: 'Remove one',
                iconSize: 24,
                onPressed: s.count == 0 ? null : notifier.decrement,
                icon: const Icon(Icons.remove),
              ),
            ),
            _Control(
              label: 'Count',
              child: IconButton.filled(
                tooltip: 'Add one',
                iconSize: 34,
                padding: const EdgeInsets.all(10),
                onPressed: s.completed ? null : notifier.increment,
                icon: const Icon(Icons.add),
              ),
            ),
            _Control(
              label: 'Focus',
              child: IconButton.outlined(
                tooltip: 'Focus mode',
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
              label: Text(s.running ? 'Pause' : (started ? 'Resume' : 'Start')),
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
                        ? 'Target reached in ${s.mode.label} 🙏  Reset this mode, '
                            'switch mode, or raise the target.'
                        : 'Target reached 🙏  Reset, or raise the target.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  Future<void> _confirmReset(
    BuildContext context,
    SadhanaState s,
    SadhanaSessionNotifier notifier,
  ) async {
    if (s.count == 0 && s.elapsedSeconds == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.isSeparate
            ? 'Reset ${s.mode.label} count?'
            : 'Reset this session?'),
        content: Text(s.isSeparate
            ? 'Your ${s.mode.label} count of ${s.count} will return to zero. '
                'The other modes keep their counts.'
            : 'Your count of ${s.count} will return to zero.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset')),
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
