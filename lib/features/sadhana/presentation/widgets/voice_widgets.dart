import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/voice_training_provider.dart';
import '../../data/mantra.dart';
import '../../../../l10n/l10n.dart';

/// Small "BETA" label: Voice counting is an experimental, trained-on-you
/// feature, and says so wherever it appears.
class BetaBadge extends StatelessWidget {
  const BetaBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.betaLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: scheme.onTertiaryContainer,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

/// "Voice trained" / "Voice not trained" for one mantra.
class VoiceTrainedTag extends ConsumerWidget {
  const VoiceTrainedTag(this.mantraId, {super.key});

  final String mantraId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trained = ref.watch(mantraTrainedProvider(mantraId));
    final scheme = Theme.of(context).colorScheme;
    final color = trained ? scheme.primary : scheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(trained ? Icons.check_circle : Icons.mic_off_outlined,
            size: 16, color: color),
        const SizedBox(width: 4),
        // Flexible: in a narrow card the label shrinks instead of overflowing.
        Flexible(
          child: Text(
            trained ? context.l10n.voiceTrained : context.l10n.voiceNotTrained,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

/// Strict ↔ Lenient. Strict rejects more near-misses; Lenient counts looser
/// repeats (and is more likely to count something that is not the mantra).
class VoiceSensitivitySlider extends ConsumerWidget {
  const VoiceSensitivitySlider({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(voiceSensitivityProvider);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.sensitivityLabel, style: theme.textTheme.titleSmall),
        Slider(
          value: value,
          onChanged: ref.read(voiceSensitivityProvider.notifier).set,
          semanticFormatterCallback: (v) => v < 0.34
              ? context.l10n.sensitivityStrict
              : (v > 0.66 ? context.l10n.sensitivityLenient : context.l10n.sensitivityMedium),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(context.l10n.sensitivityStrict, style: theme.textTheme.bodySmall),
            Text(context.l10n.sensitivityLenient, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

/// A live input-level bar: can the phone hear you? [level] is 0..1.
class InputLevelBar extends StatelessWidget {
  const InputLevelBar({super.key, required this.level});

  final double? level;

  @override
  Widget build(BuildContext context) => Semantics(
        label: context.l10n.voiceInputLevel,
        value: level == null ? null : '${(level! * 100).round()}%',
        child: LinearProgressIndicator(
          value: level,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      );
}

/// Asks before wiping a mantra's trained voice. Returns true if cleared.
Future<bool> confirmClearTraining(
    BuildContext context, WidgetRef ref, Mantra mantra) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.clearVoiceTrainingTitle),
      content: Text(context.l10n.clearVoiceTrainingBody(mantra.title)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel)),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.clearTraining)),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(voiceTrainingProvider.notifier).clear(mantra.id);
  return true;
}
