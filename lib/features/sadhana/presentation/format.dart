/// 3725 -> "1:02:05", 605 -> "10:05".
String formatClock(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  String two(int n) => n.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// 5400 -> "1 h 30 min", 90 -> "1 min 30 s".
String formatDurationWords(int totalSeconds) {
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  final s = totalSeconds % 60;
  final parts = <String>[
    if (h > 0) '$h h',
    if (m > 0) '$m min',
    if (s > 0 || (h == 0 && m == 0)) '$s s',
  ];
  return parts.join(' ');
}
