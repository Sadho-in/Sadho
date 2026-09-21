import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/home_cards_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import '../sadhana/test_support.dart';
import 'calendar_support.dart';

/// The whole feature through the real app shell.
void main() {
  late FakeScheduler scheduler;

  Future<ProviderContainer> openApp(WidgetTester tester) async {
    phoneScreen(tester, height: 3200);
    AppStorage.useMemoryForTests();
    scheduler = FakeScheduler();
    // testOverrides fixes the clock at Monday 21 Sep 2026, 08:00.
    final c = ProviderContainer(overrides: [
      ...testOverrides(),
      reminderSchedulerProvider.overrideWithValue(scheduler),
    ]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(theme: calendarTestTheme(), home: const AppShell()),
    ));
    await tester.pump();
    return c;
  }

  Future<void> goTo(WidgetTester tester, String tab) async {
    await tester.tap(find.descendant(
        of: find.byType(NavigationBar), matching: find.text(tab)));
    await tester.pumpAndSettle();
  }

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<void> tapKey(WidgetTester tester, String k) async {
    await tester.ensureVisible(key(k));
    await tester.tap(key(k));
    await tester.pumpAndSettle();
  }

  testWidgets('Calendar and Home are real screens now, not "Coming soon"',
      (tester) async {
    await openApp(tester);
    await goTo(tester, 'Calendar');
    expect(find.byType(TableCalendar<void>), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);

    await goTo(tester, 'Home');
    expect(key('home-empty'), findsOneWidget);
    expect(find.text('Coming soon'), findsNothing);
  });

  testWidgets('mark today, put it on Home all day; then make it a swipeable '
      'morning card', (tester) async {
    final c = await openApp(tester);
    await goTo(tester, 'Calendar');

    // Mark today (Monday 21st) from the calendar.
    await tester.tap(key('day-2026-09-21'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'type-good');
    await tapKey(tester, 'emoji-🌅');
    await tester.enterText(key('label-field'), 'Morning puja');
    await tester.enterText(key('details-field'), 'Light the diya first.');
    await tapKey(tester, 'home-allDay');
    await tapKey(tester, 'save-mark');

    expect(c.read(calendarMarksProvider).single.label, 'Morning puja');
    expect(find.descendant(of: key('day-2026-09-21'), matching: find.text('🌅')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('today-dot')), findsOneWidget);

    // It is pinned on Home.
    await goTo(tester, 'Home');
    expect(find.text('Morning puja'), findsOneWidget);
    expect(find.text('🌅'), findsOneWidget);
    expect(find.text('Light the diya first.'), findsOneWidget);
    expect(find.text('Pinned all day'), findsOneWidget);
    expect(find.byType(Dismissible), findsNothing);

    // Edit it from the card: once in the morning, from 6:00.
    await tester.tap(key('home-card-${c.read(calendarMarksProvider).single.id}'));
    await tester.pumpAndSettle();
    expect(find.text('Edit mark'), findsOneWidget);
    await tapKey(tester, 'home-morning');
    await tapKey(tester, 'save-mark');

    expect(find.text('Swipe to dismiss for today'), findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);
    await tester.fling(find.byType(Dismissible), const Offset(-600, 0), 2000);
    await tester.pumpAndSettle();
    expect(key('home-empty'), findsOneWidget, reason: 'done for today');
    expect(find.text('Done for today: Morning puja'), findsOneWidget);

    // Still on the calendar.
    await goTo(tester, 'Calendar');
    expect(find.descendant(of: key('day-2026-09-21'), matching: find.text('🌅')),
        findsOneWidget);
    expect(c.read(homeCardsProvider), isEmpty);
  });

  testWidgets('a mark with reminders reaches the scheduler, and is refreshed '
      'when the app starts again', (tester) async {
    final c = await openApp(tester);
    await goTo(tester, 'Calendar');
    await tester.tap(key('day-2026-09-25'));
    await tester.pumpAndSettle();
    await tester.enterText(key('label-field'), 'Ekadashi');
    await tapKey(tester, 'reminder-several');
    for (var i = 0; i < 2; i++) {
      await tapKey(tester, 'add-time');
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
    await tapKey(tester, 'repeat-monthly');
    await tapKey(tester, 'save-mark');

    final m = c.read(calendarMarksProvider).single;
    expect(m.reminderTimes, [600, 660]);
    expect(m.repeat, RepeatRule.monthly);
    expect(scheduler.permissionRequests, 1);
    expect(scheduler.scheduled.single.id, m.id);

    // "Restart": a new container reads the mark from Hive and re-schedules it.
    await tester.pumpWidget(const SizedBox());
    final second = FakeScheduler();
    final again = ProviderContainer(overrides: [
      ...testOverrides(),
      reminderSchedulerProvider.overrideWithValue(second),
    ]);
    addTearDown(again.dispose);
    again.read(calendarMarksProvider);
    await tester.pump();
    await tester.pump();
    expect(second.rescheduledAll.single.single.id, m.id);
  });

  testWidgets('deleting a mark clears it from the calendar, Home and reminders',
      (tester) async {
    final c = await openApp(tester);
    final saved = await c.read(calendarMarksProvider.notifier).save(markOn(
        DateTime(2026, 9, 21),
        id: 'x',
        label: 'Temp',
        home: HomeMode.allDay,
        reminder: ReminderMode.once,
        times: const [600]));
    await goTo(tester, 'Home');
    expect(find.text('Temp'), findsOneWidget);

    await goTo(tester, 'Calendar');
    await tester.tap(key('day-2026-09-21'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'delete-mark');
    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
    await tester.pumpAndSettle();

    expect(c.read(calendarMarksProvider), isEmpty);
    expect(scheduler.cancelled, [saved.id]);
    await goTo(tester, 'Home');
    expect(find.text('Temp'), findsNothing);
    expect(key('home-empty'), findsOneWidget);
  });

  testWidgets('the calendar stays put while you use the other tabs',
      (tester) async {
    await openApp(tester);
    await goTo(tester, 'Calendar');
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    await goTo(tester, 'Sadhana');
    await goTo(tester, 'Calendar');
    expect(find.text('October 2026'), findsOneWidget);
  });
}
