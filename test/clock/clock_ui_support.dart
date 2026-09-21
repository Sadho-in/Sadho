import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'clock_support.dart';

export 'clock_support.dart';

/// Everything a Clock-tab widget test needs to look at or poke.
class Rig {
  Rig(this.container, this.clock, this.scheduler, this.feedback, this.location);

  final ProviderContainer container;
  final FakeClock clock;
  final FakeScheduler scheduler;
  final FakeFeedback feedback;
  final FakeLocationService location;
}

/// Puts [child] on a phone-sized screen, on fresh storage, with every
/// plugin-backed service replaced.
Future<Rig> pumpClock(
  WidgetTester tester,
  Widget child, {
  DateTime? now,
  FakeScheduler? scheduler,
  FakeLocationService? location,
  bool use24 = false,
  Map<String, Object?> saved = const {},
  Brightness brightness = Brightness.light,
  double width = 411,
  double height = 800,
}) async {
  phoneScreen(tester, width: width, height: height);
  final clock = FakeClock(now ?? clockTestNow());
  final sched = scheduler ?? FakeScheduler();
  final feedback = FakeFeedback();
  final phone = location ?? FakeLocationService(state: LocationAccess.denied);
  final container = clockContainer(
    clock: clock,
    scheduler: sched,
    feedback: feedback,
    location: phone,
    saved: saved,
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: calendarTestTheme(brightness),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24),
          child: child!,
        ),
        home: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
  return Rig(container, clock, sched, feedback, phone);
}

/// Moves the fake clock forward and lets the screen's timers fire for as long.
Future<void> passTime(WidgetTester tester, Rig rig, Duration d) async {
  rig.clock.advance(d);
  await tester.pump(d);
}

/// "5:42 AM" the way the app writes it.
String jm(DateTime t) => DateFormat.jm().format(t);

/// The text of the widget with [key].
String textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(ValueKey(key))).data!;

Finder byKey(String key) => find.byKey(ValueKey(key));
