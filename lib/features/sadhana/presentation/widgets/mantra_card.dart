import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../../application/mantra_text_scale_provider.dart';
import '../../application/selected_mantra_provider.dart';
import '../../data/mantra.dart';
import '../mantra_library_screen.dart';
import 'script_text.dart';
import 'voice_widgets.dart';

/// Opens the library and applies the choice, confirming first if it would
/// discard a count in progress.
Future<void> pickMantra(BuildContext context, WidgetRef ref) async {
  final picked = await Navigator.of(context).push<Mantra>(
    MaterialPageRoute(builder: (_) => const MantraLibraryScreen()),
  );
  if (picked == null || !context.mounted) return;

  final session = ref.read(sadhanaSessionProvider);
  if (picked.id == session.mantraId) return;

  if (session.count > 0 || session.elapsedSeconds > 0) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to ${picked.title}?'),
        content: const Text('Your current count will be reset.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep current'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (ok != true) return;
  }
  ref
      .read(sadhanaSessionProvider.notifier)
      .selectMantra(picked.id, picked.defaultCount);
}

/// The selected mantra: script, name and transliteration, small tags
/// (tradition, whether its voice is trained), a Library button, and an A− / A+
/// stepper for the text size (pinching the card with two fingers works too).
///
/// The text is drawn at [mantraTextScaleProvider] times its base size and
/// WRAPS rather than being cut off, so the card simply grows with bigger text.
/// (The Sadhana screen shrinks the ring to make room.)
class MantraCard extends ConsumerWidget {
  const MantraCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mantra = ref.watch(selectedMantraProvider);
    final scale = ref.watch(mantraTextScaleProvider);
    final sizer = ref.read(mantraTextScaleProvider.notifier);
    final onCard = scheme.onSecondaryContainer;

    return Card(
      color: scheme.secondaryContainer.withValues(alpha: 0.55),
      child: _PinchToZoom(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => pickMantra(context, ref),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 4, 8),
            // The right edge holds two things at opposite corners: A− / A+ at
            // the top, Library at the bottom, so Library is never right under
            // A+. (IntrinsicHeight lets that column stretch to the card.)
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mantra.script.isNotEmpty)
                          ScriptText(
                            mantra.script,
                            style: scaledMantraStyle(
                              theme.textTheme.titleMedium?.copyWith(
                                color: onCard,
                              ),
                              scale,
                            ),
                          ),
                        Text(
                          mantra.title,
                          style: scaledMantraStyle(
                            theme.textTheme.titleSmall?.copyWith(
                              color: onCard,
                              fontWeight: FontWeight.w700,
                            ),
                            scale,
                          ),
                        ),
                        if (mantra.transliteration.isNotEmpty &&
                            mantra.transliteration != mantra.title)
                          Text(
                            mantra.transliteration,
                            style: scaledMantraStyle(
                              theme.textTheme.bodySmall?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: onCard.withValues(alpha: 0.8),
                              ),
                              scale,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (mantra.tradition.isNotEmpty)
                              Text(
                                mantra.tradition,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: onCard.withValues(alpha: 0.85),
                                ),
                              ),
                            // Voice counts only a trained mantra: say whether
                            // this one is.
                            VoiceTrainedTag(mantra.id),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    key: const ValueKey('mantra-card-controls'),
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        key: const ValueKey('mantra-size-controls'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _SizeButton(
                            label: 'A−',
                            fontSize: 13,
                            tooltip: 'Smaller mantra text',
                            onPressed: scale > minMantraTextScale
                                ? sizer.smaller
                                : null,
                          ),
                          _SizeButton(
                            label: 'A+',
                            fontSize: 19,
                            tooltip: 'Larger mantra text',
                            onPressed: scale < maxMantraTextScale
                                ? sizer.larger
                                : null,
                          ),
                        ],
                      ),
                      // A little air between the two, whatever the text size.
                      const SizedBox(height: 16),
                      TextButton.icon(
                        key: const ValueKey('mantra-library-button'),
                        onPressed: () => pickMantra(context, ref),
                        icon: const Icon(
                          Icons.library_music_outlined,
                          size: 16,
                        ),
                        label: const Text('Library'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A small "A−" / "A+" text-size button. The two letters are drawn at
/// different sizes so their meaning reads at a glance.
class _SizeButton extends StatelessWidget {
  const _SizeButton({
    required this.label,
    required this.fontSize,
    required this.tooltip,
    required this.onPressed,
  });

  final String label;
  final double fontSize;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    // A disabled button (at the smallest / largest size) must still take the
    // tap: otherwise it falls through to the card, which opens the Library.
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size(38, 34),
          padding: const EdgeInsets.symmetric(horizontal: 6),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
      ),
    ),
  );
}

/// Two-finger pinch on [child] changes the mantra text size.
///
/// Built on raw pointers rather than a scale gesture recogniser on purpose: a
/// recogniser would join the gesture arena and steal one-finger drags from the
/// page's scrolling, and taps from the card. This never competes: with one
/// finger nothing changes.
class _PinchToZoom extends ConsumerStatefulWidget {
  const _PinchToZoom({required this.child});

  final Widget child;

  @override
  ConsumerState<_PinchToZoom> createState() => _PinchToZoomState();
}

class _PinchToZoomState extends ConsumerState<_PinchToZoom> {
  final _pointers = <int, Offset>{};
  double _startDistance = 0;
  double _startScale = defaultMantraTextScale;
  bool _pinching = false;

  double get _distance {
    final p = _pointers.values.toList();
    return (p[0] - p[1]).distance;
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.position;
    if (_pointers.length == 2) {
      _pinching = true;
      _startDistance = _distance;
      _startScale = ref.read(mantraTextScaleProvider);
    }
  }

  void _move(PointerMoveEvent e) {
    if (!_pointers.containsKey(e.pointer)) return;
    _pointers[e.pointer] = e.position;
    if (_pinching && _pointers.length == 2 && _startDistance > 8) {
      // Live while pinching; saved once when the fingers lift.
      ref
          .read(mantraTextScaleProvider.notifier)
          .set(_startScale * _distance / _startDistance, persist: false);
    }
  }

  void _up(PointerEvent e) {
    _pointers.remove(e.pointer);
    if (_pinching && _pointers.length < 2) {
      _pinching = false;
      ref.read(mantraTextScaleProvider.notifier).commit();
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _down,
    onPointerMove: _move,
    onPointerUp: _up,
    onPointerCancel: _up,
    child: widget.child,
  );
}
