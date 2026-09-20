import 'package:flutter/material.dart';

import '../../application/sadhana_session_provider.dart';

/// Icon + name for each counting mode, shared by the chips and status line.
extension CountModeUi on CountMode {
  IconData get icon => switch (this) {
        CountMode.tap => Icons.touch_app_outlined,
        CountMode.rhythm => Icons.graphic_eq,
        CountMode.voice => Icons.mic_none,
        CountMode.mala => Icons.blur_circular,
      };

  String get label => switch (this) {
        CountMode.tap => 'Tap',
        CountMode.rhythm => 'Rhythm',
        CountMode.voice => 'Voice',
        CountMode.mala => 'Mala',
      };
}
