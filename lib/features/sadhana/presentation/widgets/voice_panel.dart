import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/sadhana_session_provider.dart';
import '../../application/selected_mantra_provider.dart';
import '../../application/voice_training_provider.dart';
import '../../data/mantra.dart';
import '../../services/pcm_input.dart';
import '../../services/voice_counter_service.dart';
import '../../voice/match_model.dart';
import '../voice_calibration_screen.dart';
import '../voice_training_screen.dart';
import 'voice_widgets.dart';
import '../../../../l10n/l10n.dart';

/// Shown in the Counting card while Voice is the active mode: whether the
/// selected mantra is trained, Train / Re-train / Clear, the sensitivity
/// slider, and the honest Beta caveats.
class VoicePanel extends ConsumerStatefulWidget {
  const VoicePanel({super.key});

  @override
  ConsumerState<VoicePanel> createState() => _VoicePanelState();
}

class _VoicePanelState extends ConsumerState<VoicePanel>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Which microphone is in use: its own training is picked.
    Future.microtask(_refreshInput);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshInput();
  }

  Future<void> _refreshInput() async {
    if (!mounted) return;
    await ref.read(voiceTrainingProvider.notifier).refreshInput();
  }

  @override
  Widget build(BuildContext context) {
    final mantra = ref.watch(selectedMantraProvider);
    final trained = ref.watch(mantraTrainedProvider(mantra.id));
    final count = ref.watch(
        voiceTrainingProvider.select((m) => m[mantra.id]?.sampleCount ?? 0));
    final room = maxTrainingSamples - count;
    final calibrated = ref.watch(voiceTrainingProvider
        .select((m) => m[mantra.id]?.isCalibrated ?? false));
    final otherInput = ref.watch(trainedWithOtherInputProvider(mantra.id));
    final listening = ref.watch(sadhanaSessionProvider
        .select((s) => s.mode == CountMode.voice && s.inputActive));
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
                  context.l10n.trainYourOwnMantra,
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
                ? context.l10n.voiceCountingFrom(mantra.title, count)
                : context.l10n.voiceCountsOnlyTrained(
                    mantra.title, minTrainingSamples, maxTrainingSamples),
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          if (otherInput != null) ...[
            const SizedBox(height: 8),
            Row(
              key: const ValueKey('voice-other-input'),
              children: [
                Icon(Icons.headset_off_outlined, size: 18, color: scheme.error),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    otherInput == VoiceInput.headset
                        ? context.l10n.voiceTrainedWithHeadset
                        : context.l10n.voiceTrainedWithPhone,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                key: const ValueKey('voice-train-this-input'),
                onPressed: () => openVoiceTraining(context, mantra),
                icon: const Icon(Icons.mic, size: 18),
                label: Text(context.l10n.trainVoice),
              ),
            ),
          ],
          if (listening) ...[
            const SizedBox(height: 8),
            ValueListenableBuilder<double>(
              valueListenable: ref.read(voiceCounterServiceProvider).level,
              builder: (context, level, _) => InputLevelBar(
                  key: const ValueKey('voice-level'), level: level),
            ),
          ],
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
                  label: Text(context.l10n.addMoreSamples),
                ),
              if (trained)
                OutlinedButton.icon(
                  onPressed: () => openVoiceTraining(context, mantra),
                  icon: const Icon(Icons.mic, size: 18),
                  label: Text(context.l10n.retrain),
                )
              else
                FilledButton.tonalIcon(
                  onPressed: () => openVoiceTraining(context, mantra),
                  icon: const Icon(Icons.mic, size: 18),
                  label: Text(context.l10n.trainVoice),
                ),
              if (trained)
                OutlinedButton.icon(
                  key: const ValueKey('voice-calibrate'),
                  onPressed: () => openVoiceCalibration(context, mantra),
                  icon: Icon(calibrated ? Icons.tune : Icons.graphic_eq, size: 18),
                  label: Text(calibrated
                      ? context.l10n.recalibrateVoice
                      : context.l10n.calibrateVoice),
                ),
              if (trained)
                TextButton.icon(
                  onPressed: () => confirmClearTraining(context, ref, mantra),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(context.l10n.clearTraining),
                ),
            ],
          ),
          if (trained && !calibrated) ...[
            const SizedBox(height: 4),
            Row(
              key: const ValueKey('voice-calibrate-prompt'),
              children: [
                Icon(Icons.info_outline, size: 16, color: scheme.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(context.l10n.voiceCalibratePrompt,
                      style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          const VoiceSensitivitySlider(),
          Text(
            context.l10n.voiceBetaNote,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.voiceHonestNote,
            key: const ValueKey('voice-honest-note'),
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
      title: Text(context.l10n.trainVoiceFirstTitle),
      content: Text(context.l10n.trainVoiceFirstBody(
          mantra.title, minTrainingSamples, maxTrainingSamples)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.later)),
        FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.trainNow)),
      ],
    ),
  );
  if (train == true && context.mounted) {
    await openVoiceTraining(context, mantra);
  }
}
