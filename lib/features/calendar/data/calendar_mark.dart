/// What a marked date means. Shown as green / red / amber.
enum MarkType {
  good('Good'),
  cautious('Cautious'),
  neutral('Neutral');

  const MarkType(this.label);
  final String label;
}

/// When to be reminded (with a notification) on the marked date.
enum ReminderMode {
  none('No time'),
  once('One time'),
  several('Several times');

  const ReminderMode(this.label);
  final String label;
}

/// How often a mark comes back after its first date.
enum RepeatRule {
  once('Once'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  quarterly('Quarterly'),
  halfYearly('Half-yearly'),
  yearly('Yearly');

  const RepeatRule(this.label);
  final String label;

  /// Months between occurrences for the calendar-month rules, else null.
  int? get monthStep => switch (this) {
        RepeatRule.monthly => 1,
        RepeatRule.quarterly => 3,
        RepeatRule.halfYearly => 6,
        RepeatRule.yearly => 12,
        _ => null,
      };
}

/// Whether, and how, a mark appears on the Home tab.
enum HomeMode {
  none("Don't show"),
  morning('Once in the morning'),
  allDay('Keep all day');

  const HomeMode(this.label);
  final String label;
}

/// The icons offered for a mark (also shown on the date and on its card).
const markEmojis = [
  '🕉', '☬', '📿', '🪔', '🔔', '🌅', //
  '⭐', '✦', '💰', '🤝', '🚫', '✅',
];

/// Spoken names for the emoji buttons (tooltips and screen readers).
const markEmojiNames = {
  '🕉': 'Om',
  '☬': 'Khanda',
  '📿': 'Mala',
  '🪔': 'Diya',
  '🔔': 'Bell',
  '🌅': 'Sunrise',
  '⭐': 'Star',
  '✦': 'Sparkle',
  '💰': 'Money',
  '🤝': 'Handshake',
  '🚫': 'Avoid',
  '✅': 'Done',
};

const maxReminderTimes = 8;
const maxLabelLength = 40;
const maxDetailsLength = 500;

/// The default clock times, as minutes since midnight.
const defaultReminderMinutes = 9 * 60;
const defaultHomeMinutes = 7 * 60;

/// Local calendar date at midnight (drops any time of day).
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// "2026-09-21": the stable text key for a date.
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? parseDateKey(Object? v) {
  if (v is! String) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(v);
  if (m == null) return null;
  final y = int.parse(m[1]!), mo = int.parse(m[2]!), d = int.parse(m[3]!);
  final date = DateTime(y, mo, d);
  // Reject impossible dates such as 2026-02-31 (DateTime would roll over).
  return date.year == y && date.month == mo && date.day == d ? date : null;
}

int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

/// A marked date (and, if it repeats, every date it comes back on).
class CalendarMark {
  const CalendarMark({
    required this.id,
    required this.date,
    this.type = MarkType.neutral,
    this.emoji,
    this.label = '',
    this.details = '',
    this.reminderMode = ReminderMode.none,
    this.reminderTimes = const [],
    this.repeat = RepeatRule.once,
    this.homeMode = HomeMode.none,
    this.homeMinutes = defaultHomeMinutes,
    this.createdAt,
  });

  final String id;

  /// First date of the mark (date only).
  final DateTime date;
  final MarkType type;

  /// One of [markEmojis], or null for none.
  final String? emoji;
  final String label;
  final String details;
  final ReminderMode reminderMode;

  /// Minutes since midnight, sorted, without duplicates.
  final List<int> reminderTimes;
  final RepeatRule repeat;
  final HomeMode homeMode;

  /// When a [HomeMode.morning] card first shows (minutes since midnight).
  final int homeMinutes;
  final DateTime? createdAt;

  /// The times that actually ring: none, the single time, or every time.
  List<int> get effectiveReminderTimes => switch (reminderMode) {
        ReminderMode.none => const [],
        ReminderMode.once => reminderTimes.isEmpty
            ? const [defaultReminderMinutes]
            : [reminderTimes.first],
        ReminderMode.several => reminderTimes,
      };

  bool get hasReminders => effectiveReminderTimes.isNotEmpty;

  /// A short name for lists and notifications.
  String get title =>
      label.trim().isNotEmpty ? label.trim() : '${type.label} day';

  CalendarMark copyWith({
    DateTime? date,
    MarkType? type,
    String? emoji,
    bool clearEmoji = false,
    String? label,
    String? details,
    ReminderMode? reminderMode,
    List<int>? reminderTimes,
    RepeatRule? repeat,
    HomeMode? homeMode,
    int? homeMinutes,
  }) =>
      CalendarMark(
        id: id,
        date: date == null ? this.date : dateOnly(date),
        type: type ?? this.type,
        emoji: clearEmoji ? null : (emoji ?? this.emoji),
        label: label ?? this.label,
        details: details ?? this.details,
        reminderMode: reminderMode ?? this.reminderMode,
        reminderTimes: reminderTimes ?? this.reminderTimes,
        repeat: repeat ?? this.repeat,
        homeMode: homeMode ?? this.homeMode,
        homeMinutes: homeMinutes ?? this.homeMinutes,
        createdAt: createdAt,
      );

  // ---- recurrence ----------------------------------------------------------

  /// The day-of-month this mark falls on in [year]/[month]: the start day, or
  /// the last day of a shorter month (the 31st becomes the 30th or 28th).
  int _dayIn(int year, int month) =>
      date.day <= daysInMonth(year, month) ? date.day : daysInMonth(year, month);

  /// Whether the mark is on [day] (first date or any repeat of it).
  bool occursOn(DateTime day) {
    final d = dateOnly(day);
    if (d.isBefore(date)) return false;
    switch (repeat) {
      case RepeatRule.once:
        return d == date;
      case RepeatRule.daily:
        return true;
      case RepeatRule.weekly:
        // Whole days between, on UTC so daylight-saving shifts cannot skew it.
        final days = DateTime.utc(d.year, d.month, d.day)
            .difference(DateTime.utc(date.year, date.month, date.day))
            .inDays;
        return days % 7 == 0;
      case RepeatRule.monthly:
      case RepeatRule.quarterly:
      case RepeatRule.halfYearly:
      case RepeatRule.yearly:
        final months = (d.year - date.year) * 12 + d.month - date.month;
        return months % repeat.monthStep! == 0 && d.day == _dayIn(d.year, d.month);
    }
  }

  /// The next [count] dates on or after [from] the mark falls on (fewer if it
  /// does not repeat that often). Never looks further than [horizon] ahead.
  List<DateTime> nextOccurrences(
    DateTime from,
    int count, {
    Duration horizon = const Duration(days: 366 * 30),
  }) {
    final start = dateOnly(from).isBefore(date) ? date : dateOnly(from);
    final limit = start.add(horizon);
    final out = <DateTime>[];
    if (count <= 0) return out;

    switch (repeat) {
      case RepeatRule.once:
        if (!date.isBefore(dateOnly(from))) out.add(date);
      case RepeatRule.daily:
        for (var i = 0; i < count; i++) {
          out.add(DateTime(start.year, start.month, start.day + i));
        }
      case RepeatRule.weekly:
        final days = DateTime.utc(start.year, start.month, start.day)
            .difference(DateTime.utc(date.year, date.month, date.day))
            .inDays;
        final skip = (7 - days % 7) % 7;
        for (var i = 0; i < count; i++) {
          out.add(DateTime(start.year, start.month, start.day + skip + 7 * i));
        }
      case RepeatRule.monthly:
      case RepeatRule.quarterly:
      case RepeatRule.halfYearly:
      case RepeatRule.yearly:
        final step = repeat.monthStep!;
        var k = 0;
        while (out.length < count) {
          final total = date.month - 1 + k * step;
          final y = date.year + total ~/ 12;
          final m = total % 12 + 1;
          final candidate = DateTime(y, m, _dayIn(y, m));
          if (candidate.isAfter(limit)) break;
          if (!candidate.isBefore(start)) out.add(candidate);
          k++;
        }
    }
    return out;
  }

  // ---- storage -------------------------------------------------------------

  Map<String, dynamic> toMap() => {
        'id': id,
        'date': dateKey(date),
        'type': type.name,
        'emoji': emoji,
        'label': label,
        'details': details,
        'reminderMode': reminderMode.name,
        'reminderTimes': reminderTimes,
        'repeat': repeat.name,
        'homeMode': homeMode.name,
        'homeMinutes': homeMinutes,
        'createdAt': createdAt?.millisecondsSinceEpoch,
      };

  /// Null if [m] is not a usable mark (no id or no valid date). Everything
  /// else falls back to a default, so one bad field never loses the mark.
  static CalendarMark? fromMap(Object? m) {
    if (m is! Map) return null;
    final id = m['id'];
    final date = parseDateKey(m['date']);
    if (id is! String || id.isEmpty || date == null) return null;

    T pick<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.firstWhere((v) => v.name == name, orElse: () => fallback);

    final times = m['reminderTimes'];
    final emoji = m['emoji'];
    final created = m['createdAt'];
    return CalendarMark(
      id: id,
      date: date,
      type: pick(MarkType.values, m['type'], MarkType.neutral),
      emoji: emoji is String && emoji.isNotEmpty ? emoji : null,
      label: m['label'] is String ? m['label'] as String : '',
      details: m['details'] is String ? m['details'] as String : '',
      reminderMode:
          pick(ReminderMode.values, m['reminderMode'], ReminderMode.none),
      reminderTimes: normalizeTimes([
        if (times is List)
          for (final t in times)
            if (t is int && t >= 0 && t < 24 * 60) t,
      ]),
      repeat: pick(RepeatRule.values, m['repeat'], RepeatRule.once),
      homeMode: pick(HomeMode.values, m['homeMode'], HomeMode.none),
      homeMinutes: m['homeMinutes'] is int &&
              (m['homeMinutes'] as int) >= 0 &&
              (m['homeMinutes'] as int) < 24 * 60
          ? m['homeMinutes'] as int
          : defaultHomeMinutes,
      createdAt: created is int
          ? DateTime.fromMillisecondsSinceEpoch(created)
          : null,
    );
  }
}

/// Sorted, without duplicates, at most [maxReminderTimes].
List<int> normalizeTimes(Iterable<int> times) {
  final set = {...times}.toList()..sort();
  return set.length > maxReminderTimes ? set.sublist(0, maxReminderTimes) : set;
}
