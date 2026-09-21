import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../data/calendar_mark.dart';
import '../services/reminder_scheduler.dart';

/// Every calendar mark, kept in Hive (no backend). Saving or deleting a mark
/// also updates its reminders with the [ReminderScheduler].
class CalendarMarksNotifier extends Notifier<List<CalendarMark>> {
  @override
  List<CalendarMark> build() {
    final marks = _load();
    // Refresh the system reminders on start (rolling windows, and anything the
    // OS dropped). Never blocks or fails the app.
    final scheduler = ref.read(reminderSchedulerProvider);
    Future.microtask(() async {
      try {
        await scheduler.rescheduleAll(marks);
      } catch (e) {
        debugPrint('Could not refresh reminders: $e');
      }
    });
    return marks;
  }

  static List<CalendarMark> _load() {
    final marks = <CalendarMark>[
      for (final v in AppStorage.calendarMarks.values)
        ?CalendarMark.fromMap(v),
    ]..sort(_byDate);
    return marks;
  }

  static int _byDate(CalendarMark a, CalendarMark b) {
    final c = a.date.compareTo(b.date);
    if (c != 0) return c;
    return (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0));
  }

  /// A fresh id for a new mark.
  String newId() => 'm_${DateTime.now().microsecondsSinceEpoch}';

  CalendarMark? byId(String id) {
    for (final m in state) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// The marks that fall on [day] (see [marksOnDay]).
  List<CalendarMark> marksOn(DateTime day) => marksOnDay(state, day);

  /// Saves (adds or replaces) [mark] and updates its reminders. The mark is
  /// stored first: a reminder that cannot be scheduled never loses it.
  Future<CalendarMark> save(CalendarMark mark) async {
    final saved = CalendarMark.fromMap(mark.toMap())!; // normalises the fields
    final stamped = saved.createdAt == null
        ? _withCreated(saved, byId(saved.id)?.createdAt ?? DateTime.now())
        : saved;
    await AppStorage.calendarMarks.put(stamped.id, stamped.toMap());
    state = [
      for (final m in state)
        if (m.id != stamped.id) m,
      stamped,
    ]..sort(_byDate);
    try {
      await ref.read(reminderSchedulerProvider).schedule(stamped);
    } catch (e) {
      debugPrint('Could not schedule reminders: $e');
    }
    return stamped;
  }

  CalendarMark _withCreated(CalendarMark m, DateTime created) {
    final map = m.toMap()..['createdAt'] = created.millisecondsSinceEpoch;
    return CalendarMark.fromMap(map)!;
  }

  /// Deletes the mark (and every repeat of it) and its reminders.
  Future<void> delete(String id) async {
    await AppStorage.calendarMarks.delete(id);
    state = [
      for (final m in state)
        if (m.id != id) m,
    ];
    try {
      await ref.read(reminderSchedulerProvider).cancel(id);
    } catch (e) {
      debugPrint('Could not cancel reminders: $e');
    }
  }
}

/// The marks that fall on [day]: those starting on it and repeats of earlier
/// ones. Most severe first (cautious, then good, then neutral), then oldest.
List<CalendarMark> marksOnDay(List<CalendarMark> marks, DateTime day) {
  final on = [for (final m in marks) if (m.occursOn(day)) m];
  const rank = {MarkType.cautious: 0, MarkType.good: 1, MarkType.neutral: 2};
  on.sort((a, b) {
    final r = rank[a.type]!.compareTo(rank[b.type]!);
    return r != 0 ? r : CalendarMarksNotifier._byDate(a, b);
  });
  return on;
}

/// Each mark that falls in [month], with its first date in that month,
/// earliest first. A repeating mark is listed once, not once per occurrence.
List<({CalendarMark mark, DateTime first})> marksInMonth(
    List<CalendarMark> marks, DateTime month) {
  final start = DateTime(month.year, month.month);
  final out = <({CalendarMark mark, DateTime first})>[];
  for (final m in marks) {
    final next = m.nextOccurrences(start, 1);
    if (next.isNotEmpty &&
        next.first.year == start.year &&
        next.first.month == start.month) {
      out.add((mark: m, first: next.first));
    }
  }
  out.sort((a, b) {
    final c = a.first.compareTo(b.first);
    return c != 0 ? c : CalendarMarksNotifier._byDate(a.mark, b.mark);
  });
  return out;
}

final calendarMarksProvider =
    NotifierProvider<CalendarMarksNotifier, List<CalendarMark>>(
  CalendarMarksNotifier.new,
);
