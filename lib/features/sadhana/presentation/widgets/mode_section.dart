import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/rhythm_pace.dart';
import '../../application/sadhana_session_provider.dart';
import '../../application/selected_mantra_provider.dart';
import '../../application/voice_training_provider.dart';
import '../../services/voice_counter_service.dart';
import '../../services/volume_button_service.dart';
import 'mode_meta.dart';
import 'rhythm_pace_editor.dart';
import 'section_card.dart';
import 'voice_panel.dart';
import 'voice_widgets.dart';

const _modeHelp = {
  CountMode.tap: 'Tap the ring, or anywhere in Focus mode. Only Tap mode counts '
      'screen taps.',
  CountMode.rhythm:
      'Press Start and the count advances by itself at the pace below.',
  CountMode.voice:
      'Press Start, then chant your trained mantra. Each time it is '
          'recognised it adds one count, straight away; other sounds are '
          'ignored. Needs the microphone; works best in a quiet room.',
  CountMode.mala:
      'Press Start, then press either volume button to count. Handy with '
          'eyes closed or the phone in a pocket. The screen must stay on.',
};

/// Left-to-right order of the mode buttons.
const _modeOrder = [
  CountMode.tap,
  CountMode.voice,
  CountMode.rhythm,
  CountMode.mala,
];

/// Choose how counting happens: Tap, Voice, Rhythm or Mala, as four round icon
/// buttons in ONE row. The settings of the chosen mode appear right below:
/// the Rhythm pace only for Rhythm, the Voice panel (training, sensitivity)
/// only for Voice. The + and − buttons work in every mode.
class ModeSection extends ConsumerWidget {
  const ModeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(sadhanaSessionProvider.select((s) => s.mode));
    final pace = ref.watch(sadhanaSessionProvider.select((s) => s.rhythmSeconds));
    final theme = Theme.of(context);
    // Modes this device can never run, said up front rather than after a tap.
    final unusable = [
      if (!ref.read(voiceCounterServiceProvider).isSupported)
        voiceUnsupportedText,
      if (!ref.read(volumeButtonServiceProvider).isSupported)
        malaUnsupportedText,
    ];

    return SectionCard(
      title: 'Counting mode',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final m in _modeOrder)
                _ModeButton(
                  mode: m,
                  selected: mode == m,
                  // Unsupported platforms / denied permissions are handled by
                  // the session: it falls back to Tap and shows a message.
                  onTap: () => _select(context, ref, m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _modeHelp[mode]!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final why in unusable)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: theme.colorScheme.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      why,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ),
          // Each mode's own settings appear only while that mode is chosen.
          if (mode == CountMode.rhythm) ...[
            const SizedBox(height: 16),
            Text(
              'Pace: count ${formatPaceEvery(pace)}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const RhythmPaceEditor(),
          ],
          if (mode == CountMode.voice) const VoicePanel(),
        ],
      ),
    );
  }
}

/// A round icon button with its name underneath (Voice also wears a Beta tag).
class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final CountMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '${mode.label} mode',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 40,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected
                        ? scheme.primary
                        : scheme.surfaceContainerHigh,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Icon(
                    mode.icon,
                    size: 26,
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
                if (mode == CountMode.voice)
                  const Positioned(
                    top: -6,
                    right: -10,
                    child: BetaBadge(),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              mode.label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Selects [m]. Choosing Voice for a mantra with no trained voice asks to
/// train it first (the mode stays selected; Start also refuses until trained).
Future<void> _select(BuildContext context, WidgetRef ref, CountMode m) async {
  ref.read(sadhanaSessionProvider.notifier).setMode(m);
  if (m != CountMode.voice ||
      ref.read(sadhanaSessionProvider).mode != CountMode.voice) {
    return;
  }
  final mantra = ref.read(selectedMantraProvider);
  if (!ref.read(mantraTrainedProvider(mantra.id)) && context.mounted) {
    await showTrainPrompt(context, mantra);
  }
}
