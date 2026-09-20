import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon.dart';

/// Phase 1 placeholder. TODO(later-phase): build the real Home experience.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ComingSoon(title: 'Home', icon: Icons.home_outlined);
}
