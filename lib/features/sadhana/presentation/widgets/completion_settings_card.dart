import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/completion_settings_provider.dart';
import '../../application/sadhana_session_provider.dart';
import '../../data/ringtone.dart';
import '../../services/feedback_service.dart';
import 'section_card.dart';
import '../../application/collapsed_cards_provider.dart';
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

    final l = context.l10n;
    return CollapsibleSectionCard(
      id: SadhanaCard.completion,
      title: l.completionTitle,
      summary: [
        settings.vibrationEnabled ? l.summaryVibrationOn : l.summaryVibrationOff,
        settings.ringtoneEnabled
            ? settings.ringtone.localized(l)
            : l.summarySoundOff,
      ].join(', '),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Screen -----------------------------------------------------
          SwitchListTile(
            key: const ValueKey('keep-screen-on'),
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(Icons.light_mode_outlined),
            title: Text(context.l10n.keepScreenOnLabel),
            subtitle: Text(context.l10n.keepScreenOnSubtitle),
            value: settings.keepScreenOn,
            onChanged: notifier.setKeepScreenOn,
          ),
          const Divider(height: 32),
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
            _RepeatChoice<VibrationRepeat>(
              keyPrefix: 'vibration-repeat',
              values: VibrationRepeat.values,
              selected: settings.vibrationRepeat,
              label: (r) => switch (r) {
                VibrationRepeat.once => context.l10n.repeatOnce,
                VibrationRepeat.untilStopped => context.l10n
                    .vibrationRepeatUntilStopped(vibrationRepeatEvery.inSeconds),
              },
              onSelected: notifier.setVibrationRepeat,
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
            _RepeatChoice<SoundRepeat>(
              keyPrefix: 'sound-repeat',
              values: SoundRepeat.values,
              selected: settings.soundRepeat,
              label: (r) => switch (r) {
                SoundRepeat.once => context.l10n.repeatOnce,
                SoundRepeat.repeat => context.l10n.soundRepeatTimes(soundRepeatTimes),
                SoundRepeat.untilStopped => context.l10n.repeatUntilStopped,
              },
              onSelected: notifier.setSoundRepeat,
            ),
          ],
        ],
      ),
    );
  }
}

/// "Repeat" and one chip per option. Chips wrap, so long translations never
/// overflow a narrow phone.
class _RepeatChoice<T extends Enum> extends StatelessWidget {
  const _RepeatChoice({
    required this.keyPrefix,
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
  });

  final String keyPrefix;
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.repeatLabel,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in values)
                  ChoiceChip(
                    key: ValueKey('$keyPrefix-${v.name}'),
                    label: Text(label(v)),
                    selected: v == selected,
                    onSelected: (_) => onSelected(v),
                  ),
              ],
            ),
          ],
        ),
      );
}
