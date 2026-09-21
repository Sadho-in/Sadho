import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../sadhana/presentation/widgets/section_card.dart';
import '../../application/daily_reminder_provider.dart';

/// The daily sadhana reminder: a switch and a time.
class ReminderCard extends ConsumerWidget {
  const ReminderCard({super.key});

  Future<void> _toggle(BuildContext context, WidgetRef ref, bool on) async {
    final allowed = await ref.read(dailyReminderProvider.notifier).setEnabled(on);
    if (!context.mounted || !on || allowed) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Allow notifications in Settings so the reminder can ring.'),
      ));
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final r = ref.read(dailyReminderProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: r.hour, minute: r.minute),
      helpText: 'Daily sadhana reminder',
    );
    if (picked == null) return;
    ref.read(dailyReminderProvider.notifier).setTime(picked.hour * 60 + picked.minute);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(dailyReminderProvider);
    final time = TimeOfDay(hour: r.hour, minute: r.minute).format(context);
    return SectionCard(
      title: 'Daily reminder',
      child: Column(
        children: [
          SwitchListTile(
            key: const ValueKey('reminder-switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Daily sadhana reminder'),
            subtitle: Text(
              r.enabled ? 'Every day at $time' : 'Off',
              key: const ValueKey('reminder-status'),
            ),
            value: r.enabled,
            onChanged: (on) => _toggle(context, ref, on),
          ),
          ListTile(
            key: const ValueKey('reminder-time'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Time'),
            trailing: Text(time, key: const ValueKey('reminder-time-text')),
            onTap: () => _pickTime(context, ref),
          ),
        ],
      ),
    );
  }
}
