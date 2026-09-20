import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/selected_mantra_provider.dart';
import '../../application/voice_training_provider.dart';
import '../../data/mantra.dart';
import '../../voice/match_model.dart';
import '../voice_training_screen.dart';
import 'voice_widgets.dart';

/// Shown in the Counting card while Voice is the active mode: whether the
/// selected mantra is trained, Train / Re-train / Clear, the sensitivity
/// slider, and the honest Beta caveats.
class VoicePanel extends ConsumerWidget {
  const VoicePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mantra = ref.watch(selectedMantraProvider);
    final trained = ref.watch(mantraTrainedProvider(mantra.id));
    final count = ref.watch(
        voiceTrainingProvider.select((m) => m[mantra.id]?.sampleCount ?? 0));
    final room = maxTrainingSamples - count;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  'Train your own mantra',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              const SizedBox(width: 8),
              const BetaBadge(),
            ],
          ),
          const SizedBox(height: 6),
          VoiceTrainedTag(mantra.id),
          const SizedBox(height: 4),
          Text(
            trained
                ? 'Counting “${mantra.title}” from your $count recordings. '
                    'Other sounds and words are ignored.'
                : 'Voice counts only a mantra you have trained. Record '
                    '“${mantra.title}” $minTrainingSamples to '
                    '$maxTrainingSamples times to begin.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (trained && room > 0)
                FilledButton.tonalIcon(
                  onPressed: () =>
                      openVoiceTraining(context, mantra, addMore: true),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add more samples'),
                ),
              if (trained)
                OutlinedButton.icon(
                  onPressed: () => openVoiceTraining(context, mantra),
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('Re-train'),
                )
              else
                FilledButton.tonalIcon(
                  onPressed: () => openVoiceTraining(context, mantra),
                  icon: const Icon(Icons.mic, size: 18),
                  label: const Text('Train voice'),
                ),
              if (trained)
                TextButton.icon(
                  onPressed: () => confirmClearTraining(context, ref, mantra),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Clear training'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const VoiceSensitivitySlider(),
          Text(
            'Beta: works on-device and offline. Accuracy improves with more '
            'recordings and drops in a noisy room. Pause briefly between '
            'repeats. Only your voice counts here; the + and − buttons '
            'correct the count.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Voice was chosen for a mantra that has no training yet.
Future<void> showTrainPrompt(BuildContext context, Mantra mantra) async {
  final train = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Train your voice first'),
      content: Text('Voice counts only your own trained mantra. Record '
          '“${mantra.title}” $minTrainingSamples to $maxTrainingSamples times '
          '(about a minute). It stays on this device and works offline.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Later')),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Train now')),
      ],
    ),
  );
  if (train == true && context.mounted) {
    await openVoiceTraining(context, mantra);
  }
}
