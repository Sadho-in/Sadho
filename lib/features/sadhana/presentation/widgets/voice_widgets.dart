import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/voice_training_provider.dart';
import '../../data/mantra.dart';

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
        'BETA',
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
            trained ? 'Voice trained' : 'Voice not trained',
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
        Text('Sensitivity', style: theme.textTheme.titleSmall),
        Slider(
          value: value,
          onChanged: ref.read(voiceSensitivityProvider.notifier).set,
          semanticFormatterCallback: (v) =>
              v < 0.34 ? 'Strict' : (v > 0.66 ? 'Lenient' : 'Medium'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Strict', style: theme.textTheme.bodySmall),
            Text('Lenient', style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}

/// Asks before wiping a mantra's trained voice. Returns true if cleared.
Future<bool> confirmClearTraining(
    BuildContext context, WidgetRef ref, Mantra mantra) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Clear voice training?'),
      content: Text('Voice will stop counting “${mantra.title}” until you '
          'train it again.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear training')),
      ],
    ),
  );
  if (ok != true) return false;
  await ref.read(voiceTrainingProvider.notifier).clear(mantra.id);
  return true;
}
