import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

/// §2/§2a of test/QA_COVERAGE.md: the Home tab dashboard.
void main() {
  setUpIntegrationTest();

  /// Writes a mark straight to Hive (the same store the Calendar editor UI
  /// writes to — its own coverage is in calendar_test.dart) so this file can
  /// test Home's own rendering/interaction without re-driving that editor,
  /// and without depending on what time of day the suite happens to run.
  Future<void> seedTodayMark({
    required String id,
    required String label,
    required HomeMode home,
  }) async {
    final today = dateOnly(DateTime.now());
    final mark = CalendarMark(
      id: id,
      date: today,
      type: MarkType.good,
      label: label,
      homeMode: home,
      homeMinutes: 1, // 00:01 — always in the past, whenever the test runs
    );
    await AppStorage.calendarMarks.put(id, mark.toMap());
  }

  testWidgets('greeting + date line, and the Today card tradition switch',
      (tester) async {
    await pumpOnboardedApp(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(byKey('home-greeting'), findsOneWidget);
    expect(byKey('today-card'), findsOneWidget);

    // Hindu (the default) shows tithi/nakshatra-style lines.
    expect(byKey('detail-tithi'), findsOneWidget);
    expect(byKey('example-tithi'), findsOneWidget); // EXAMPLE tag

    await tester.tap(find.descendant(
        of: byKey('tradition-switch'), matching: find.text('Sikh')));
    await tester.pumpAndSettle();
    expect(byKey('detail-hukamnama'), findsOneWidget);
    expect(byKey('detail-tithi'), findsNothing);

    await tester.tap(find.descendant(
        of: byKey('tradition-switch'), matching: find.text('By place')));
    await tester.pumpAndSettle();
    expect(byKey('detail-sunrise'), findsOneWidget);
    expect(byKey('example-sunrise'), findsNothing); // sunrise is real, no tag
    expect(byKey('live-note'), findsOneWidget);
  });

  testWidgets(
      'a "Keep all day" mark shows as a pinned Home card that cannot be '
      'swiped away', (tester) async {
    await seedTodayMark(id: 'pinned-1', label: 'Pinned test mark', home: HomeMode.allDay);
    await pumpOnboardedApp(tester);

    expect(find.text('Pinned test mark'), findsOneWidget);
    expect(byKey('home-card-pinned-1'), findsOneWidget);
    expect(find.text('Pinned all day'), findsOneWidget);
    // No Dismissible around a pinned card, so swiping does nothing.
    await tester.drag(find.text('Pinned test mark'), const Offset(400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Pinned test mark'), findsOneWidget);
  });

  testWidgets(
      'a "Once in the morning" mark can be swiped away, with Undo bringing '
      'it back', (tester) async {
    await seedTodayMark(id: 'morning-1', label: 'Morning test mark', home: HomeMode.morning);
    await pumpOnboardedApp(tester);

    expect(find.text('Morning test mark'), findsOneWidget);
    await tester.drag(byKey('home-swipe-morning-1'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    expect(find.text('Morning test mark'), findsNothing);
    expect(find.textContaining('Done for today'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Morning test mark'), findsOneWidget);
  });

  testWidgets('no marks flagged for Home shows the empty state', (tester) async {
    await pumpOnboardedApp(tester);
    expect(byKey('home-empty'), findsOneWidget);
  });

  testWidgets(
      'plans: starting a suggestion, marking today done and undoing it, '
      'then deleting the plan', (tester) async {
    await pumpOnboardedApp(tester);

    final startChip = byKey('start-0');
    await tester.scrollUntilVisible(startChip, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(startChip);
    await tester.pumpAndSettle();
    expect(byKey('plans-empty'), findsNothing);

    final toggleFinder = find.byWidgetPredicate(
        (w) => w.key != null && (w.key as Key).toString().contains('plan-toggle-'));
    await tester.scrollUntilVisible(toggleFinder, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(toggleFinder);
    await tester.pumpAndSettle();
    expect(find.text('Done today'), findsOneWidget);
    await tester.tap(find.text('Done today'));
    await tester.pumpAndSettle();
    expect(find.text('Mark today done'), findsOneWidget);

    final menuFinder = find.byWidgetPredicate(
        (w) => w.key != null && (w.key as Key).toString().contains('plan-menu-'));
    await tester.scrollUntilVisible(menuFinder, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.tap(menuFinder);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete plan'));
    await tester.pumpAndSettle();
    expect(find.text('Delete plan?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(byKey('plans-empty'), findsOneWidget);
  });
}
