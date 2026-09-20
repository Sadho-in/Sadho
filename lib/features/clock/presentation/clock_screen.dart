import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon.dart';

/// Phase 1 placeholder. TODO(later-phase): build the real Clock experience.
class ClockScreen extends StatelessWidget {
  const ClockScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ComingSoon(title: 'Clock', icon: Icons.schedule_outlined);
}
