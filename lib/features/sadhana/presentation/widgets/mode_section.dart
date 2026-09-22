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
import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';

Map<CountMode, String> _modeHelp(AppLocalizations l) => {
      CountMode.tap: l.modeHelpTap,
      CountMode.rhythm: l.modeHelpRhythm,
      CountMode.voice: l.modeHelpVoice,
      CountMode.mala: l.modeHelpMala,
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
    final l = context.l10n;
    // Modes this device can never run, said up front rather than after a tap.
    final unusable = [
      if (!ref.read(voiceCounterServiceProvider).isSupported)
        l.msgVoiceUnsupported,
      if (!ref.read(volumeButtonServiceProvider).isSupported)
        l.msgMalaUnsupported,
    ];

    return SectionCard(
      title: l.countingModeLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final m in _modeOrder)
                _ModeButton(
                  mode: m,
                  l10n: l,
                  selected: mode == m,
                  // Unsupported platforms / denied permissions are handled by
                  // the session: it falls back to Tap and shows a message.
                  onTap: () => _select(context, ref, m),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _modeHelp(l)[mode]!,
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
              l.pacePrefix(formatPaceEvery(pace)),
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
    required this.l10n,
    required this.selected,
    required this.onTap,
  });

  final CountMode mode;
  final AppLocalizations l10n;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.modeSemanticLabel(mode.localized(l10n)),
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
              mode.localized(l10n),
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
