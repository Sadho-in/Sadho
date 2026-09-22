import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/completion_settings_provider.dart';
import '../../application/sadhana_session_provider.dart';
import '../../data/ringtone.dart';
import '../../services/feedback_service.dart';
import 'section_card.dart';
import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';

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
      title: context.l10n.completionTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Vibration --------------------------------------------------
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.vibration),
            title: Text(context.l10n.vibrationLabel),
            subtitle: Text(context.l10n.vibrationSubtitle(milestoneEvery)),
            value: settings.vibrationEnabled,
            onChanged: notifier.setVibrationEnabled,
          ),
          if (settings.vibrationEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.intensityLevel(settings.vibrationLevel),
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
                  label: Text(context.l10n.testMilestone),
                ),
                OutlinedButton.icon(
                  onPressed: () => feedback.previewVibration(strong: true),
                  icon: const Icon(Icons.vibration, size: 18),
                  label: Text(context.l10n.testTarget),
                ),
              ],
            ),
          ],
          const Divider(height: 32),
          // ---- Ringtone ---------------------------------------------------
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.notifications_active_outlined),
            title: Text(context.l10n.ringtoneLabel),
            subtitle: Text(context.l10n.ringtoneSubtitle),
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
                    label: Text(r.localized(context.l10n)),
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
              label: Text(context.l10n.playSound),
            ),
          ],
        ],
      ),
    );
  }
}
