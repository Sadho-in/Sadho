import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rhythm_pace.dart';
import '../../application/sadhana_session_provider.dart';
import '../../application/voice_training_provider.dart';
import 'mode_meta.dart';
import 'voice_widgets.dart';

/// The ACTIVE counting mode and what it is doing right now, in two lines:
/// the mode name, then a status ("Tap anywhere to count", the Rhythm pace,
/// "Listening…", "Press the volume keys to count"...).
/// Shown on the Sadhana tab and in Focus mode. In Separate scope the name also
/// says the count is this mode's own.
///
/// [compact] puts the name and the status on ONE line (Sadhana tab, where
/// height is precious); the default two-line form is for Focus mode.
class ModeStatusLine extends ConsumerWidget {
  const ModeStatusLine({super.key, this.center = true, this.compact = false});

  final bool center;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sadhanaSessionProvider);
    final trained = ref.watch(mantraTrainedProvider(s.mantraId));
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final pace = formatPaceEvery(s.rhythmSeconds);
    final (IconData icon, String text, bool live) = switch (s.mode) {
      CountMode.tap => (s.mode.icon, 'Tap anywhere to count', false),
      CountMode.rhythm => (
          s.mode.icon,
          s.running ? 'Counting $pace' : 'Paused · $pace',
          s.running,
        ),
      CountMode.voice when s.running && s.inputActive => (
          Icons.mic,
          'Listening…',
          true,
        ),
      CountMode.voice when s.running => (
          s.mode.icon,
          'Starting microphone… allow access if asked',
          false,
        ),
      CountMode.voice when !trained => (
          Icons.mic_off_outlined,
          'Not trained yet · train your mantra to use Voice',
          false,
        ),
      CountMode.voice => (
          Icons.mic_off_outlined,
          'Paused · press Start to listen',
          false,
        ),
      CountMode.mala when s.running && s.inputActive => (
          s.mode.icon,
          'Press the volume keys to count',
          true,
        ),
      CountMode.mala when s.running => (
          s.mode.icon,
          'Capturing the volume keys…',
          false,
        ),
      CountMode.mala => (
          s.mode.icon,
          'Paused · press Start to use the volume keys',
          false,
        ),
    };

    final color = live ? scheme.primary : scheme.onSurfaceVariant;
    final align = center ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final title = '${s.mode.label} mode${s.isSeparate ? ' · own count' : ''}';

    final icon0 = _Pulse(
      active: live,
      child: _Bump(
        // A new utterance (counted or not) bumps the icon.
        trigger: s.lastVoice?.seq ?? 0,
        child: Icon(
          icon,
          size: 18,
          color: s.lastVoice?.counted == true && live ? scheme.tertiary : color,
        ),
      ),
    );
    final caption = s.mode == CountMode.voice && s.running && s.lastVoice != null
        ? (s.lastVoice!.counted
            ? 'Counted · ${(s.lastVoice!.closeness * 100).round()}% match'
            : 'Ignored · ${(s.lastVoice!.closeness * 100).round()}% match '
                '(not your mantra)')
        : null;

    if (compact) {
      return Semantics(
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment:
                  center ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                icon0,
                const SizedBox(width: 6),
                Text(
                  '${s.mode.label} mode',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (s.mode == CountMode.voice) ...[
                  const SizedBox(width: 6),
                  const BetaBadge(),
                ],
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            if (caption != null)
              Text(
                caption,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: s.lastVoice!.counted
                      ? scheme.tertiary
                      : scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      );
    }

    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Pulse(
                active: live,
                child: _Bump(
                  // A new utterance (counted or not) bumps the icon.
                  trigger: s.lastVoice?.seq ?? 0,
                  child: Icon(
                    icon,
                    size: 18,
                    color: s.lastVoice?.counted == true && live
                        ? scheme.tertiary
                        : color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (s.mode == CountMode.voice) ...[
                const SizedBox(width: 8),
                const BetaBadge(),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Text(
            text,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
          if (s.mode == CountMode.voice && s.running && s.lastVoice != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                s.lastVoice!.counted
                    ? 'Counted · ${(s.lastVoice!.closeness * 100).round()}% match'
                    : 'Ignored · ${(s.lastVoice!.closeness * 100).round()}% match '
                        '(not your mantra)',
                textAlign: center ? TextAlign.center : TextAlign.start,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: s.lastVoice!.counted
                      ? scheme.tertiary
                      : scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Gentle breathing animation on the icon while an input is live.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Pulse old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) {
      _c.repeat(reverse: true);
    } else if (!widget.active && _c.isAnimating) {
      _c.animateTo(0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween(begin: 1.0, end: 0.35).animate(_c),
        child: widget.child,
      );
}

/// A quick grow-and-settle on the icon every time [trigger] changes.
class _Bump extends StatelessWidget {
  const _Bump({required this.trigger, required this.child});

  final int trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        key: ValueKey(trigger),
        tween: Tween(begin: trigger == 0 ? 1.0 : 1.7, end: 1.0),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
        child: child,
      );
}
