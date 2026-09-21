import '../../calendar/data/calendar_mark.dart'
    show dateKey, dateOnly, parseDateKey;

enum PlanKind {
  paath('Paath'),
  mantra('Mantra');

  const PlanKind(this.label);
  final String label;
}

const minPlanDays = 1;
const maxPlanDays = 365;

/// A paath or mantra you set out to do for [totalDays] days. You mark each day
/// done; progress is days done out of the target.
class Plan {
  const Plan({
    required this.id,
    required this.title,
    required this.kind,
    required this.totalDays,
    required this.startDate,
    this.doneDays = const {},
  });

  final String id;
  final String title;
  final PlanKind kind;

  /// The target: how many days to complete.
  final int totalDays;
  final DateTime startDate;

  /// The days (as `yyyy-MM-dd` keys) marked done.
  final Set<String> doneDays;

  int get completed =>
      doneDays.length > totalDays ? totalDays : doneDays.length;

  double get progress => totalDays <= 0 ? 0 : completed / totalDays;

  bool get isComplete => completed >= totalDays;

  bool get isActive => !isComplete;

  bool doneOn(DateTime day) => doneDays.contains(dateKey(day));

  Plan copyWith({Set<String>? doneDays}) => Plan(
    id: id,
    title: title,
    kind: kind,
    totalDays: totalDays,
    startDate: startDate,
    doneDays: doneDays ?? this.doneDays,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'days': totalDays,
    'start': dateKey(startDate),
    'done': doneDays.toList()..sort(),
  };

  /// Null when [m] is not a usable plan (so damaged data is skipped, not fatal).
  static Plan? fromMap(Object? m) {
    if (m is! Map) return null;
    final id = m['id'], title = m['title'], days = m['days'];
    if (id is! String || id.isEmpty) return null;
    if (title is! String || title.trim().isEmpty) return null;
    if (days is! int || days < minPlanDays || days > maxPlanDays) return null;
    final start = m['start'] is String
        ? parseDateKey(m['start'] as String)
        : null;
    if (start == null) return null;
    final done = m['done'];
    return Plan(
      id: id,
      title: title,
      kind: PlanKind.values.firstWhere(
        (k) => k.name == m['kind'],
        orElse: () => PlanKind.mantra,
      ),
      totalDays: days,
      startDate: dateOnly(start),
      doneDays: {
        if (done is List)
          for (final d in done)
            if (d is String && parseDateKey(d) != null) d,
      },
    );
  }
}

/// A ready-made plan to start with one tap.
class PlanSuggestion {
  const PlanSuggestion(this.title, this.kind, this.days);
  final String title;
  final PlanKind kind;
  final int days;
}

const planSuggestions = [
  PlanSuggestion('Hanuman Chalisa', PlanKind.paath, 40),
  PlanSuggestion('Japji Sahib', PlanKind.paath, 40),
  PlanSuggestion('Sukhmani Sahib', PlanKind.paath, 11),
  PlanSuggestion('Gayatri Mantra', PlanKind.mantra, 21),
  PlanSuggestion('Om Namah Shivaya', PlanKind.mantra, 108),
  PlanSuggestion('Waheguru', PlanKind.mantra, 21),
];

/// The quick choices for the number of days.
const planDayChoices = [7, 11, 21, 40, 108];

/// Days in a row, ending today (or yesterday, if today is not done yet), on
/// which at least one plan was marked done. [doneKeys] holds `yyyy-MM-dd` keys.
int currentStreak(Set<String> doneKeys, DateTime today) {
  var day = dateOnly(today);
  if (!doneKeys.contains(dateKey(day))) {
    day = day.subtract(const Duration(days: 1));
  }
  var n = 0;
  while (doneKeys.contains(dateKey(day))) {
    n++;
    day = DateTime(day.year, day.month, day.day - 1);
  }
  return n;
}
