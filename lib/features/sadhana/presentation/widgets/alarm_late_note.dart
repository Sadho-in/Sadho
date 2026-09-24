import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// One line under the counter while the finish alarm is set but exact alarms
/// are not allowed on this phone.
class AlarmLateNote extends StatelessWidget {
  const AlarmLateNote({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              context.l10n.alarmMayBeLate,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
