import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/completion_settings_provider.dart';
import '../../application/sadhana_session_provider.dart';
import '../../data/ringtone.dart';
import '../../services/feedback_service.dart';
import 'section_card.dart';

/// Completion settings. Vibration and ringtone are two separate settings,
/// each with its own on/off switch.
class CompletionSettingsCard extends ConsumerWidget {
  const CompletionSettingsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(completionSettingsProvider);
    final notifier = ref.read(completionSettingsProvider.notifier);
    final feedback = ref.read(feedbackServiceProvider);
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Completion',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Vibration --------------------------------------------------
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.vibration),
            title: const Text('Vibration'),
            subtitle: Text(
              'A buzz every $milestoneEvery counts, and a stronger one at the target.',
            ),
            value: settings.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
          ),
          if (settings.vibrationEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Intensity: level ${settings.vibrationLevel} of 5',
                style: theme.textTheme.titleSmall,
              ),
            ),
            Slider(
              value: settings.vibrationLevel.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: '${settings.vibrationLevel}',
              onChanged: (v) => notifier.setVibrationLevel(v.round()),
              // Feel the new level as soon as the slider is released.
              onChangeEnd: (_) => feedback.previewVibration(strong: false),
            ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => feedback.previewVibration(strong: false),
                  icon: const Icon(Icons.vibration, size: 18),
                  label: const Text('Test milestone'),
                ),
                OutlinedButton.icon(
                  onPressed: () => feedback.previewVibration(strong: true),
                  icon: const Icon(Icons.vibration, size: 18),
                  label: const Text('Test target'),
                ),
              ],
            ),
          ],
          const Divider(height: 32),
          // ---- Ringtone ---------------------------------------------------
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_active_outlined),
            title: const Text('Ringtone'),
            subtitle: const Text('A sound plays when the target is reached.'),
            value: settings.ringtoneEnabled,
            onChanged: notifier.setRingtoneEnabled,
          ),
          if (settings.ringtoneEnabled) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in Ringtone.values)
                  ChoiceChip(
                    label: Text(r.label),
                    selected: settings.ringtone == r,
                    onSelected: (_) {
                      notifier.setRingtone(r);
                      feedback.previewRingtone(r);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => feedback.previewRingtone(settings.ringtone),
              icon: const Icon(Icons.play_arrow, size: 18),
              label: const Text('Play sound'),
            ),
          ],
        ],
      ),
    );
  }
}
