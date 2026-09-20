import 'package:flutter/material.dart';

import '../../sadhana/presentation/widgets/count_scope_control.dart';
import '../../sadhana/presentation/widgets/section_card.dart';

/// Settings live here until the real Profile experience is built.
/// TODO(later-phase): build the real Profile experience.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const SectionCard(
              title: 'Sadhana settings',
              child: CountScopeControl(),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Profile: coming soon',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
