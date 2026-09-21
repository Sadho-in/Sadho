import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/sadhana_session_provider.dart';
import '../application/mantra_text_scale_provider.dart';
import '../application/selected_mantra_provider.dart';
import 'format.dart';
import 'widgets/counter_section.dart' show ringLabels;
import 'widgets/mode_meta.dart';
import 'widgets/mode_status.dart';
import 'widgets/progress_ring.dart';
import 'widgets/script_text.dart';

/// How long the exit gesture must be held.
const focusExitHold = Duration(seconds: 4);

/// Fingers required for the exit gesture.
const _exitFingers = 3;

/// A tap that drifts further than this (logical px) is a swipe, not a count.
const _tapSlop = 24.0;

Future<void> openFocusMode(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => const FocusModeScreen(),
    ));

/// Full-screen counter. In Tap mode a tap ANYWHERE counts; in the other modes
/// screen taps do nothing (only that mode's own input counts) and the +/−
/// buttons correct the count. The only ways out are holding
/// 3 fingers on the screen for [focusExitHold], or holding the "Hold to exit"
/// button for the same time. System back is blocked.
class FocusModeScreen extends ConsumerStatefulWidget {
  const FocusModeScreen({super.key});

  @override
  ConsumerState<FocusModeScreen> createState() => _FocusModeScreenState();
}

class _FocusModeScreenState extends ConsumerState<FocusModeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _hold =
      AnimationController(vsync: this, duration: focusExitHold)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) _exit();
        });

  /// Tiny scale "pulse" on every count so taps feel acknowledged.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
  );

  /// Every finger currently on the screen -> where it landed.
  final Map<int, Offset> _pointers = {};

  /// Pointers that started on a control (buttons); they never count as taps.
  final Set<int> _controlPointers = {};

  /// Pointers currently pressing the "Hold to exit" button.
  final Set<int> _exitButtonPointers = {};

  bool _tapCandidate = false;
  bool _exiting = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hold.dispose();
    _pulse.dispose();
    super.dispose();
  }

  // ---- exit hold -----------------------------------------------------------

  void _syncHold() {
    final wanted =
        _pointers.length >= _exitFingers || _exitButtonPointers.isNotEmpty;
    if (wanted) {
      if (!_hold.isAnimating && _hold.status != AnimationStatus.completed) {
        _hold.forward(from: 0);
      }
    } else if (!_hold.isDismissed && !_exiting) {
      _hold.reset();
    }
  }

  void _exit() {
    if (_exiting || !mounted) return;
    _exiting = true;
    Navigator.of(context).pop();
  }

  // ---- raw pointers --------------------------------------------------------

  void _onDown(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    // Only a lone finger that did not land on a control can become a tap.
    _tapCandidate =
        _pointers.length == 1 && !_controlPointers.contains(e.pointer);
    _syncHold();
  }

  void _onMove(PointerMoveEvent e) {
    final start = _pointers[e.pointer];
    if (start != null && (e.position - start).distance > _tapSlop) {
      _tapCandidate = false;
    }
  }

  void _onUp(PointerUpEvent e) {
    final wasTap = _tapCandidate && _pointers.length == 1;
    _release(e.pointer);
    // A screen tap counts ONLY in Tap mode; other modes count from their own
    // input (voice / rhythm timer / volume key).
    if (wasTap) ref.read(sadhanaSessionProvider.notifier).tap();
  }

  void _onCancel(PointerCancelEvent e) {
    _tapCandidate = false;
    _release(e.pointer);
  }

  void _release(int pointer) {
    _pointers.remove(pointer);
    _controlPointers.remove(pointer);
    _exitButtonPointers.remove(pointer);
    if (_pointers.isEmpty) _tapCandidate = false;
    _syncHold();
  }

  // ---- build ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = ref.watch(sadhanaSessionProvider);
    final mantra = ref.watch(selectedMantraProvider);
    final textScale = ref.watch(mantraTextScaleProvider);
    final labels = ringLabels(s);

    ref.listen(sadhanaSessionProvider.select((v) => v.count), (prev, next) {
      if (prev != null && next > prev) _pulse.forward(from: 0);
    });

    final showRun = s.usesRunToggle;

    return PopScope(
      canPop: false, // Back gesture/button must not leave Focus mode.
      child: Scaffold(
        backgroundColor: scheme.surface,
        body: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerDown: _onDown,
          onPointerMove: _onMove,
          onPointerUp: _onUp,
          onPointerCancel: _onCancel,
          // Fill the whole screen: without this the Stack (and so the touch
          // Listener) shrinks to its widest child and edge taps are lost.
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: LayoutBuilder(builder: (context, box) {
                  final ring = math.min(box.maxWidth * 0.8, box.maxHeight * 0.42);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        // The mantra, at the size chosen on the Sadhana card.
                        // It wraps to the screen width (so a bigger size really
                        // is bigger) and only shrinks if it would not fit the
                        // height.
                        Flexible(
                          child: LayoutBuilder(
                            builder: (context, c) => FittedBox(
                              fit: BoxFit.scaleDown,
                              child: SizedBox(
                                width: c.maxWidth,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (mantra.script.isNotEmpty)
                                      ScriptText(
                                        mantra.script,
                                        textAlign: TextAlign.center,
                                        style: scaledMantraStyle(
                                            theme.textTheme.headlineMedium,
                                            textScale),
                                      ),
                                    Text(
                                      mantra.title,
                                      textAlign: TextAlign.center,
                                      style: scaledMantraStyle(
                                          theme.textTheme.titleMedium?.copyWith(
                                            color: scheme.onSurfaceVariant,
                                          ),
                                          textScale),
                                    ),
                                    if (mantra.transliteration.isNotEmpty &&
                                        mantra.transliteration != mantra.title)
                                      Text(
                                        mantra.transliteration,
                                        textAlign: TextAlign.center,
                                        style: scaledMantraStyle(
                                            theme.textTheme.bodyMedium?.copyWith(
                                              fontStyle: FontStyle.italic,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                            textScale),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedBuilder(
                          animation: _pulse,
                          builder: (_, child) => Transform.scale(
                            scale: 1 + 0.04 * math.sin(math.pi * _pulse.value),
                            child: child,
                          ),
                          child: ProgressRing(
                            progress: s.progress,
                            primaryText: labels.primary,
                            secondaryText: labels.secondary,
                            completed: s.completed,
                            size: ring,
                            strokeWidth: math.max(14, ring * 0.06),
                          ),
                        ),
                        const Spacer(),
                        const ModeStatusLine(),
                        const SizedBox(height: 12),
                        // Tap mode's own status already says "Tap anywhere to
                        // count"; in the other modes taps are inert.
                        if (s.completed)
                          Text(
                            'Target reached 🙏',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (s.mode != CountMode.tap)
                          Text(
                            'Screen taps do not count in ${s.mode.label} mode. '
                            'Use + or − to correct.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Text(
                          'Hold $_exitFingers fingers for ${focusExitHold.inSeconds} seconds to exit',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            if (showRun)
                              _control(
                                FilledButton.tonalIcon(
                                  onPressed: s.completed
                                      ? null
                                      : ref
                                          .read(sadhanaSessionProvider.notifier)
                                          .toggleRunning,
                                  icon: Icon(
                                      s.running ? Icons.pause : Icons.play_arrow),
                                  label: Text(s.running ? 'Pause' : 'Start'),
                                ),
                              ),
                            // Manual corrections (any mode), e.g. a rep Voice
                            // counted by mistake or missed. Controls, so
                            // touching them is never a tap.
                            _control(
                              IconButton.outlined(
                                tooltip: 'Remove one',
                                onPressed: s.count == 0
                                    ? null
                                    : ref
                                        .read(sadhanaSessionProvider.notifier)
                                        .decrement,
                                icon: const Icon(Icons.remove),
                              ),
                            ),
                            _control(
                              IconButton.filled(
                                tooltip: 'Add one',
                                onPressed: s.completed
                                    ? null
                                    : ref
                                        .read(sadhanaSessionProvider.notifier)
                                        .increment,
                                icon: const Icon(Icons.add),
                              ),
                            ),
                            _HoldToExitButton(
                              progress: _hold,
                              onPointerDown: (id) {
                                _controlPointers.add(id);
                                _exitButtonPointers.add(id);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                }),
              ),
              _HoldOverlay(progress: _hold),
            ],
          ),
        ),
      ),
    );
  }

  /// Marks a widget as a control so touches on it are not counted as taps.
  Widget _control(Widget child) => Listener(
        onPointerDown: (e) => _controlPointers.add(e.pointer),
        child: child,
      );
}

/// Button that fills while pressed; a fallback for devices/hands where the
/// 3-finger hold is awkward. Reports raw pointer ids to the screen so its
/// touches are neither counted nor mistaken for the 3-finger gesture.
class _HoldToExitButton extends StatelessWidget {
  const _HoldToExitButton({required this.progress, required this.onPointerDown});

  final Animation<double> progress;
  final ValueChanged<int> onPointerDown;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Hold to exit focus mode',
      child: Listener(
        onPointerDown: (e) => onPointerDown(e.pointer),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: progress,
                    builder: (_, _) => Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.value,
                        heightFactor: 1,
                        child: ColoredBox(
                          color: scheme.primary.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout, size: 18, color: scheme.onSurface),
                    const SizedBox(width: 8),
                    Text('Hold to exit',
                        style: Theme.of(context).textTheme.labelLarge),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Big fill/progress indicator that appears while an exit hold is running.
class _HoldOverlay extends StatelessWidget {
  const _HoldOverlay({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: progress,
        builder: (_, _) {
          final v = progress.value;
          if (v == 0) return const SizedBox.shrink();
          final secondsLeft =
              (focusExitHold.inSeconds * (1 - v)).ceil().clamp(1, 99);
          return Container(
            color: scheme.scrim.withValues(alpha: 0.55 * math.min(1, v * 4)),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox.expand(
                        child: CircularProgressIndicator(
                          value: v,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.25),
                          color: scheme.primary,
                        ),
                      ),
                      Text(
                        formatClock(secondsLeft).substring(1),
                        style: theme.textTheme.displaySmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Keep holding to exit…',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
