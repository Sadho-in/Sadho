import 'package:flutter/material.dart';

/// The tools on the Clock tab. Each opens full-screen.
enum ClockTool {
  clock('Clock', 'A large, live time and date', Icons.schedule),
  sunAlarm('Sun-based alarm', 'Wake at sunrise or sunset, with an offset',
      Icons.wb_twilight),
  worldClock('World clock', 'Amritsar, Haridwar, London and more', Icons.public),
  timer('Sadhana & vrat timer', 'Aarti, Chalisa, Path, Havan, or until sunset',
      Icons.hourglass_bottom),
  stopwatch('Paath stopwatch', 'Start, stop and lap', Icons.timer_outlined);

  const ClockTool(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}
