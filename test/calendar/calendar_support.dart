import 'dart:async';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/core/theme/app_theme.dart' show SadhoColors;
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

/// A clock the test controls (no timers).
class FakeNow extends NowNotifier {
  FakeNow(this.initial);
  final DateTime initial;

  @override
  DateTime build() => initial;

  void set(DateTime t) => state = t;
}

/// Records what the app asked the phone to schedule.
class FakeScheduler implements ReminderScheduler {
  FakeScheduler({this.permission = true, this.throwOnSchedule = false});

  bool permission;
  bool throwOnSchedule;
  int permissionRequests = 0;
  final scheduled = <CalendarMark>[];
  final cancelled = <String>[];
  final rescheduledAll = <List<CalendarMark>>[];

  /// The alerts currently held per group (a group is replaced as a whole).
  final alerts = <String, List<ScheduledAlert>>{};
  final alertReplacements = <String>[];

  @override
  bool get isSupported => true;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<void> schedule(CalendarMark mark) async {
    if (throwOnSchedule) throw StateError('the alarm system said no');
    scheduled.add(mark);
  }

  @override
  Future<void> cancel(String markId) async => cancelled.add(markId);

  @override
  Future<void> rescheduleAll(Iterable<CalendarMark> marks) async =>
      rescheduledAll.add(marks.toList());

  @override
  Future<void> replaceAlerts(String group, List<ScheduledAlert> next) async {
    alertReplacements.add(group);
    alerts[group] = [...next];
  }

  /// Exact alarms / full-screen alarms are allowed (as on most phones).
  bool exact = true;
  bool fullScreen = true;

  /// What the permission pages answer when opened.
  bool grantExact = true;
  bool grantFullScreen = true;
  int exactRequests = 0;
  int fullScreenRequests = 0;

  @override
  Future<bool> canScheduleExact() async => exact;

  @override
  Future<bool> requestExactAlarms() async {
    exactRequests++;
    return exact = grantExact;
  }

  @override
  Future<bool> canUseFullScreen() async => fullScreen;

  @override
  Future<bool> requestFullScreen() async {
    fullScreenRequests++;
    return fullScreen = grantFullScreen;
  }

  final _opened = StreamController<String>.broadcast();

  /// The user taps a notification of [group].
  void tapNotification(String group) => _opened.add(group);

  @override
  Stream<String> get opened => _opened.stream;

  /// Groups whose already-shown alerts were dismissed.
  final dismissed = <String>[];

  @override
  Future<void> dismissShown(String group) async => dismissed.add(group);
}

/// Overrides for the calendar feature in tests.
List<Override> calendarOverrides({FakeScheduler? scheduler, DateTime? now}) => [
      reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeScheduler()),
      nowProvider.overrideWith(() => FakeNow(now ?? DateTime(2026, 9, 21, 8, 0))),
    ];

/// The app's colour roles (marigold + indigo) without its web fonts, which a
/// test cannot download.
ThemeData calendarTestTheme([Brightness brightness = Brightness.light]) {
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: SadhoColors.marigold,
      brightness: brightness,
    ).copyWith(
      secondary: dark ? const Color(0xFFC3BEFF) : SadhoColors.indigo,
      surface: dark ? const Color(0xFF17130F) : SadhoColors.parchment,
    ),
  );
}

/// A phone-sized screen tall enough for the whole tab.
void phoneScreen(WidgetTester tester, {double width = 411, double height = 2400}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Builds a container with the calendar test overrides and [marks] saved.
Future<ProviderContainer> calendarContainer({
  List<CalendarMark> marks = const [],
  FakeScheduler? scheduler,
  DateTime? now,
}) async {
  AppStorage.useMemoryForTests();
  final c = ProviderContainer(
      overrides: calendarOverrides(scheduler: scheduler, now: now));
  addTearDown(c.dispose);
  for (final m in marks) {
    await c.read(calendarMarksProvider.notifier).save(m);
  }
  return c;
}

/// Pumps [child] under [container] with the app's colours.
Future<void> pumpScreen(
  WidgetTester tester,
  ProviderContainer container,
  Widget child, {
  Brightness brightness = Brightness.light,
}) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: calendarTestTheme(brightness),
      home: Scaffold(body: child),
    ),
  ));
  await tester.pump();
}

/// Shorthand for a mark on [date].
CalendarMark markOn(
  DateTime date, {
  String id = 'm',
  MarkType type = MarkType.good,
  String? emoji,
  String label = '',
  String details = '',
  RepeatRule repeat = RepeatRule.once,
  HomeMode home = HomeMode.none,
  int homeMinutes = 7 * 60,
  ReminderMode reminder = ReminderMode.none,
  List<int> times = const [],
}) =>
    CalendarMark(
      id: id,
      date: DateTime(date.year, date.month, date.day),
      type: type,
      emoji: emoji,
      label: label,
      details: details,
      repeat: repeat,
      homeMode: home,
      homeMinutes: homeMinutes,
      reminderMode: reminder,
      reminderTimes: times,
    );
