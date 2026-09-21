import 'package:flutter/material.dart';

/// A ready-made duration for a devotional practice.
class TimerPreset {
  const TimerPreset(this.id, this.label, this.minutes, this.icon, this.hint);

  final String id;
  final String label;
  final int minutes;
  final IconData icon;
  final String hint;

  Duration get duration => Duration(minutes: minutes);
}

const timerPresets = [
  TimerPreset('aarti', 'Aarti', 5, Icons.local_fire_department_outlined, 'Evening or morning aarti'),
  TimerPreset('chalisa', 'Chalisa', 11, Icons.menu_book_outlined, 'Hanuman Chalisa'),
  TimerPreset('path', 'Path', 21, Icons.auto_stories_outlined, 'A sitting of paath'),
  TimerPreset('havan', 'Havan', 30, Icons.whatshot_outlined, 'Havan or long puja'),
];

/// The id of the special "Vrat → sunset" option (a countdown to sunset rather
/// than a fixed length).
const vratSunsetId = 'vrat_sunset';

/// 90 -> "1:30", 3725 -> "1:02:05", 65 -> "01:05". Never negative.
String formatCountdown(int seconds) {
  final s = seconds < 0 ? 0 : seconds;
  final h = s ~/ 3600;
  final m = (s % 3600) ~/ 60;
  final sec = s % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(sec)}' : '${two(m)}:${two(sec)}';
}
