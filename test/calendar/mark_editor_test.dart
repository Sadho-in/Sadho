import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/presentation/calendar_screen.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

import 'calendar_support.dart';

void main() {
  late FakeScheduler scheduler;

  Finder cell(int day) => find.byKey(ValueKey('day-2026-09-${day.toString().padLeft(2, '0')}'));
  Finder chip(String key) => find.byKey(ValueKey(key));

  bool selected(WidgetTester t, String key) =>
      t.widget<ChoiceChip>(chip(key)).selected;

  /// Opens the calendar and taps [day] (default the 24th).
  Future<ProviderContainer> open(
    WidgetTester tester, {
    List<CalendarMark> marks = const [],
    int day = 24,
    bool permission = true,
  }) async {
    phoneScreen(tester, height: 3200);
    scheduler = FakeScheduler(permission: permission);
    final c = await calendarContainer(marks: marks, scheduler: scheduler);
    await pumpScreen(tester, c, const CalendarScreen());
    await tester.tap(cell(day));
    await tester.pumpAndSettle();
    return c;
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(chip('save-mark'));
    await tester.tap(chip('save-mark'));
    await tester.pumpAndSettle();
  }

  Future<void> tapChip(WidgetTester tester, String key) async {
    await tester.ensureVisible(chip(key));
    await tester.tap(chip(key));
    await tester.pumpAndSettle();
  }

  /// Sets the time in an open time picker, using its keyboard entry.
  Future<void> pickTime(WidgetTester tester, {required int hour, required int minute}) async {
    await tester.tap(find.byIcon(Icons.keyboard_outlined));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    // The dialog's hour and minute fields come after the sheet's own fields.
    final n = fields.evaluate().length;
    await tester.enterText(fields.at(n - 2), '$hour');
    await tester.enterText(fields.at(n - 1), minute.toString().padLeft(2, '0'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  }

  CalendarMark stored(ProviderContainer c) => c.read(calendarMarksProvider).single;

  setUp(() => AppStorage.useMemoryForTests());

  group('a new mark', () {
    testWidgets('opens with sensible defaults and every section', (tester) async {
      await open(tester);
      expect(find.text('New mark'), findsWidgets);
      expect(find.text('Mark type'), findsOneWidget);
      expect(find.text('Icon'), findsOneWidget);
      expect(find.text('Remind me at'), findsOneWidget);
      expect(find.text('Repeat'), findsOneWidget);
      expect(find.text('On your home screen'), findsOneWidget);

      expect(selected(tester, 'type-good'), isTrue);
      expect(selected(tester, 'emoji-none'), isTrue);
      expect(selected(tester, 'reminder-none'), isTrue);
      expect(selected(tester, 'repeat-once'), isTrue);
      expect(selected(tester, 'home-none'), isTrue);
      expect(tester.widget<TextField>(chip('label-field')).controller!.text, '');
      expect(tester.widget<TextField>(chip('details-field')).controller!.text, '');
      expect(chip('delete-mark'), findsNothing, reason: 'nothing to delete yet');
      expect(chip('reminder-time-once'), findsNothing);
      expect(chip('add-time'), findsNothing);
      expect(chip('home-time'), findsNothing);
    });

    testWidgets('Good / Cautious / Neutral, each with its colour and outline',
        (tester) async {
      await open(tester);
      expect(find.text('Good'), findsWidgets);
      expect(find.text('Cautious'), findsWidgets);
      expect(find.text('Neutral'), findsWidgets);
      for (final t in MarkType.values) {
        final chipWidget = tester.widget<ChoiceChip>(chip('type-${t.name}'));
        final avatar = chipWidget.avatar! as Container;
        final d = avatar.decoration! as BoxDecoration;
        expect(d.color, MarkPalette.base(t, Brightness.light));
        expect(d.border!.top.color, MarkPalette.outline(t, Brightness.light));
      }
      await tapChip(tester, 'type-cautious');
      expect(selected(tester, 'type-cautious'), isTrue);
      expect(selected(tester, 'type-good'), isFalse);
    });

    testWidgets('the emoji picker offers exactly the twelve app icons',
        (tester) async {
      await open(tester);
      for (final e in markEmojis) {
        expect(chip('emoji-$e'), findsOneWidget, reason: e);
        expect(find.byTooltip(markEmojiNames[e]!), findsOneWidget);
      }
      expect(markEmojis, ['🕉', '☬', '📿', '🪔', '🔔', '🌅', '⭐', '✦', '💰', '🤝', '🚫', '✅']);
      await tapChip(tester, 'emoji-🪔');
      expect(selected(tester, 'emoji-🪔'), isTrue);
      expect(selected(tester, 'emoji-none'), isFalse);
      await tapChip(tester, 'emoji-none');
      expect(selected(tester, 'emoji-🪔'), isFalse);
    });

    testWidgets('saves type, emoji, label and details', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'type-cautious');
      await tapChip(tester, 'emoji-🪔');
      await tester.enterText(chip('label-field'), '  Amavasya  ');
      await tester.enterText(chip('details-field'), 'Fast until sunset.\nLight a lamp.');
      await save(tester);

      expect(find.text('New mark'), findsNothing, reason: 'the sheet closed');
      final m = stored(c);
      expect(m.type, MarkType.cautious);
      expect(m.emoji, '🪔');
      expect(m.label, 'Amavasya', reason: 'trimmed');
      expect(m.details, 'Fast until sunset.\nLight a lamp.');
      expect(m.date, DateTime(2026, 9, 24));
      expect(m.reminderMode, ReminderMode.none);
      expect(m.repeat, RepeatRule.once);
      expect(m.homeMode, HomeMode.none);
      expect(AppStorage.calendarMarks.get(m.id), isNotNull, reason: 'in Hive');
      expect(scheduler.permissionRequests, 0, reason: 'no reminder, no prompt');
    });

    testWidgets('the new mark appears on the date and as a card', (tester) async {
      await open(tester);
      await tapChip(tester, 'emoji-⭐');
      await tester.enterText(chip('label-field'), 'Star day');
      await save(tester);
      expect(find.descendant(of: cell(24), matching: find.text('⭐')), findsOneWidget);
      expect(find.text('Star day'), findsOneWidget);
      final grid = find.byType(TableCalendar<void>);
      expect(find.descendant(of: grid, matching: find.byKey(const ValueKey('mark-shape'))),
          findsNothing, reason: 'the default style is Dot');
      expect(find.descendant(of: cell(24), matching: find.byKey(const ValueKey('mark-dot-good'))),
          findsOneWidget);
    });

    testWidgets('a mark can be saved with nothing but a type', (tester) async {
      final c = await open(tester);
      await save(tester);
      expect(stored(c).label, '');
      expect(stored(c).emoji, isNull);
      expect(stored(c).title, 'Good day');
    });

    testWidgets('Cancel closes without saving', (tester) async {
      final c = await open(tester);
      await tester.enterText(chip('label-field'), 'Nope');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('New mark'), findsNothing);
      expect(c.read(calendarMarksProvider), isEmpty);
    });

    testWidgets('the label and details have length limits', (tester) async {
      await open(tester);
      await tester.enterText(chip('label-field'), 'x' * 80);
      await tester.enterText(chip('details-field'), 'y' * 700);
      expect(tester.widget<TextField>(chip('label-field')).controller!.text.length, 40);
      expect(tester.widget<TextField>(chip('details-field')).controller!.text.length, 500);
    });
  });

  group('Remind me at', () {
    testWidgets('No time | One time | Several times', (tester) async {
      await open(tester);
      for (final t in ['No time', 'One time', 'Several times']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('No time: nothing is scheduled and no permission is asked',
        (tester) async {
      final c = await open(tester);
      await save(tester);
      expect(stored(c).reminderMode, ReminderMode.none);
      expect(stored(c).reminderTimes, isEmpty);
      expect(scheduler.permissionRequests, 0);
      expect(scheduler.scheduled.single.hasReminders, isFalse);
    });

    testWidgets('One time: defaults to 9:00 AM and can be changed',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-once');
      expect(find.text('9:00 AM'), findsOneWidget);
      await tester.tap(chip('reminder-time-once'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 6, minute: 30);
      expect(find.text('6:30 AM'), findsOneWidget);
      await save(tester);

      final m = stored(c);
      expect(m.reminderMode, ReminderMode.once);
      expect(m.reminderTimes, [6 * 60 + 30]);
      expect(m.effectiveReminderTimes, [390]);
      expect(scheduler.permissionRequests, 1, reason: 'asked once, on save');
      expect(scheduler.scheduled.single.id, m.id);
    });

    testWidgets('One time: accepting the default keeps 9:00 AM', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-once');
      await save(tester);
      expect(stored(c).reminderTimes, [9 * 60]);
    });

    testWidgets('One time: cancelling the picker changes nothing', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-once');
      await tester.tap(chip('reminder-time-once'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(find.text('9:00 AM'), findsOneWidget);
      await save(tester);
      expect(stored(c).reminderTimes, [9 * 60]);
    });

    testWidgets('Several times: add and remove as many as you like',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-several');
      expect(chip('add-time'), findsOneWidget);
      expect(find.byType(InputChip), findsNothing, reason: 'none yet');

      // Each new time defaults to an hour after the last: 10:00, 11:00, 12:00.
      for (var i = 0; i < 3; i++) {
        await tester.tap(chip('add-time'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      expect(find.byType(InputChip), findsNWidgets(3));
      expect(find.text('10:00 AM'), findsOneWidget);
      expect(find.text('11:00 AM'), findsOneWidget);
      expect(find.text('12:00 PM'), findsOneWidget);

      // Remove the middle one with its x.
      await tester.tap(find.descendant(
          of: chip('reminder-time-660'), matching: find.byIcon(Icons.close)));
      await tester.pumpAndSettle();
      expect(find.byType(InputChip), findsNWidgets(2));
      expect(find.text('11:00 AM'), findsNothing);

      await save(tester);
      final m = stored(c);
      expect(m.reminderMode, ReminderMode.several);
      expect(m.reminderTimes, [600, 720]);
      expect(scheduler.permissionRequests, 1);
    });

    testWidgets('Several times: a chosen time is added and the list stays sorted',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-several');
      await tester.tap(chip('add-time'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 8, minute: 15);
      await tester.tap(chip('add-time'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 6, minute: 0);
      expect([for (final w in tester.widgetList<InputChip>(find.byType(InputChip))) (w.label as Text).data],
          ['6:00 AM', '8:15 AM']);
      await save(tester);
      expect(stored(c).reminderTimes, [360, 495]);
    });

    testWidgets('Several times: the same time twice is kept once', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-several');
      for (var i = 0; i < 2; i++) {
        await tester.tap(chip('add-time'));
        await tester.pumpAndSettle();
        await pickTime(tester, hour: 7, minute: 0);
      }
      expect(find.byType(InputChip), findsOneWidget);
      await save(tester);
      expect(stored(c).reminderTimes, [420]);
    });

    testWidgets('Several times with none added cannot be saved', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-several');
      await save(tester);
      expect(find.textContaining('Add at least one time'), findsOneWidget);
      expect(find.text('New mark'), findsWidgets, reason: 'the sheet stays open');
      expect(c.read(calendarMarksProvider), isEmpty);
      expect(scheduler.permissionRequests, 0);
    });

    testWidgets('at most eight times: Add time goes away at the limit',
        (tester) async {
      await open(tester);
      await tapChip(tester, 'reminder-several');
      for (var i = 0; i < maxReminderTimes; i++) {
        expect(chip('add-time'), findsOneWidget, reason: 'before time ${i + 1}');
        await tester.tap(chip('add-time'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      expect(find.byType(InputChip), findsNWidgets(8));
      expect(chip('add-time'), findsNothing);
    });

    testWidgets('going back to No time drops the reminders', (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-once');
      await tapChip(tester, 'reminder-none');
      await save(tester);
      expect(stored(c).reminderMode, ReminderMode.none);
      expect(stored(c).reminderTimes, isEmpty);
      expect(scheduler.permissionRequests, 0);
    });

    testWidgets('One time after Several keeps only the first time',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'reminder-several');
      for (final h in [7, 18]) {
        await tester.tap(chip('add-time'));
        await tester.pumpAndSettle();
        await pickTime(tester, hour: h > 12 ? h - 12 : h, minute: 0);
      }
      await tapChip(tester, 'reminder-once');
      await save(tester);
      expect(stored(c).effectiveReminderTimes.length, 1);
    });

    testWidgets('notifications refused: the mark is still saved, and you are '
        'told the reminder will not ring', (tester) async {
      final c = await open(tester, permission: false);
      await tapChip(tester, 'reminder-once');
      await save(tester);
      expect(scheduler.permissionRequests, 1);
      expect(c.read(calendarMarksProvider).length, 1);
      expect(find.textContaining('Notifications are off for Sadho'), findsOneWidget);
    });

    testWidgets('notifications allowed: no warning', (tester) async {
      await open(tester);
      await tapChip(tester, 'reminder-once');
      await save(tester);
      expect(find.textContaining('Notifications are off'), findsNothing);
    });
  });

  group('Repeat', () {
    testWidgets('Once, Daily, Weekly, Monthly, Quarterly, Half-yearly, Yearly',
        (tester) async {
      await open(tester);
      for (final t in ['Once', 'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Half-yearly', 'Yearly']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(RepeatRule.values.length, 7);
    });

    for (final r in RepeatRule.values) {
      testWidgets('saves "${r.label}"', (tester) async {
        final c = await open(tester);
        await tapChip(tester, 'repeat-${r.name}');
        expect(selected(tester, 'repeat-${r.name}'), isTrue);
        await save(tester);
        expect(stored(c).repeat, r);
        expect(makeFresh(c).single.repeat, r, reason: 'and it is in Hive');
      });
    }

    testWidgets('a weekly mark shows on the next week\'s date', (tester) async {
      await open(tester);
      await tapChip(tester, 'repeat-weekly');
      await save(tester);
      expect(find.byKey(const ValueKey('mark-dot-good')), findsWidgets);
      for (final d in [24]) {
        expect(find.descendant(of: cell(d), matching: find.byKey(const ValueKey('mark-dot-good'))),
            findsOneWidget);
      }
    });
  });

  group('On your home screen', () {
    testWidgets('Don\'t show | Once in the morning | Keep all day',
        (tester) async {
      await open(tester);
      for (final t in ["Don't show", 'Once in the morning', 'Keep all day']) {
        expect(find.text(t), findsOneWidget, reason: t);
      }
    });

    testWidgets('morning: asks for a time (default 7:00 AM) and saves it',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'home-morning');
      expect(find.text('Show from 7:00 AM'), findsOneWidget);
      await tester.tap(chip('home-time'));
      await tester.pumpAndSettle();
      await pickTime(tester, hour: 6, minute: 15);
      expect(find.text('Show from 6:15 AM'), findsOneWidget);
      await save(tester);
      expect(stored(c).homeMode, HomeMode.morning);
      expect(stored(c).homeMinutes, 6 * 60 + 15);
    });

    testWidgets('all day: no time is asked, and the card is described as pinned',
        (tester) async {
      final c = await open(tester);
      await tapChip(tester, 'home-allDay');
      expect(chip('home-time'), findsNothing);
      expect(find.textContaining('stays pinned on Home all day'), findsOneWidget);
      await save(tester);
      expect(stored(c).homeMode, HomeMode.allDay);
    });

    testWidgets('each option explains itself', (tester) async {
      await open(tester);
      expect(find.textContaining('stays on the calendar only'), findsOneWidget);
      await tapChip(tester, 'home-morning');
      expect(find.textContaining('Swipe it away'), findsOneWidget);
    });

    testWidgets('Don\'t show is the default and saves as such', (tester) async {
      final c = await open(tester);
      await save(tester);
      expect(stored(c).homeMode, HomeMode.none);
    });
  });

  group('editing an existing mark', () {
    final existing = markOn(
      DateTime(2026, 9, 24),
      id: 'e1',
      type: MarkType.cautious,
      emoji: '📿',
      label: 'Mala day',
      details: '108 rounds',
      reminder: ReminderMode.several,
      times: const [360, 1080],
      repeat: RepeatRule.monthly,
      home: HomeMode.morning,
      homeMinutes: 6 * 60 + 45,
    );

    testWidgets('opens with everything filled in', (tester) async {
      await open(tester, marks: [existing]);
      expect(find.text('Edit mark'), findsOneWidget);
      expect(selected(tester, 'type-cautious'), isTrue);
      expect(selected(tester, 'emoji-📿'), isTrue);
      expect(tester.widget<TextField>(chip('label-field')).controller!.text, 'Mala day');
      expect(tester.widget<TextField>(chip('details-field')).controller!.text, '108 rounds');
      expect(selected(tester, 'reminder-several'), isTrue);
      expect(find.text('6:00 AM'), findsOneWidget);
      expect(find.text('6:00 PM'), findsOneWidget);
      expect(selected(tester, 'repeat-monthly'), isTrue);
      expect(selected(tester, 'home-morning'), isTrue);
      expect(find.text('Show from 6:45 AM'), findsOneWidget);
      expect(chip('delete-mark'), findsOneWidget);
    });

    testWidgets('saving replaces the mark (same id) and changes only what was edited',
        (tester) async {
      final c = await open(tester, marks: [existing]);
      await tester.enterText(chip('label-field'), 'Renamed');
      await save(tester);
      expect(c.read(calendarMarksProvider).length, 1);
      final m = stored(c);
      expect(m.id, 'e1');
      expect(m.label, 'Renamed');
      expect(m.type, MarkType.cautious);
      expect(m.emoji, '📿');
      expect(m.reminderTimes, [360, 1080]);
      expect(m.repeat, RepeatRule.monthly);
      expect(m.homeMinutes, 6 * 60 + 45);
      expect(m.date, DateTime(2026, 9, 24));
    });

    testWidgets('re-scheduling: the edited mark is handed to the scheduler',
        (tester) async {
      await open(tester, marks: [existing]);
      scheduler.scheduled.clear();
      await tapChip(tester, 'type-good');
      await save(tester);
      expect(scheduler.scheduled.single.id, 'e1');
      expect(scheduler.scheduled.single.type, MarkType.good);
      expect(scheduler.permissionRequests, 1, reason: 'it has reminders');
    });

    testWidgets('Delete asks first, then removes the mark and its reminders',
        (tester) async {
      final c = await open(tester, marks: [existing]);
      await tester.ensureVisible(chip('delete-mark'));
      await tester.tap(chip('delete-mark'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this mark?'), findsOneWidget);
      expect(find.textContaining('all of its repeats'), findsOneWidget,
          reason: 'it repeats monthly');

      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(c.read(calendarMarksProvider).length, 1, reason: 'kept');
      expect(find.text('Edit mark'), findsOneWidget);

      await tester.tap(chip('delete-mark'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(c.read(calendarMarksProvider), isEmpty);
      expect(AppStorage.calendarMarks.get('e1'), isNull);
      expect(scheduler.cancelled, contains('e1'));
      expect(find.text('Edit mark'), findsNothing, reason: 'the sheet closed');
    });

    testWidgets('deleting a one-off does not mention repeats', (tester) async {
      await open(tester, marks: [markOn(DateTime(2026, 9, 24), id: 'x', label: 'One')]);
      await tester.ensureVisible(chip('delete-mark'));
      await tester.tap(chip('delete-mark'));
      await tester.pumpAndSettle();
      expect(find.textContaining('repeats'), findsNothing);
      expect(find.textContaining('“One”'), findsOneWidget);
    });

    testWidgets('editing from a later repeat changes the whole series',
        (tester) async {
      // Weekly from Monday 7 Sep; open it on Monday 21 Sep.
      final weekly = markOn(DateTime(2026, 9, 7), id: 'w', label: 'Weekly', repeat: RepeatRule.weekly);
      final c = await open(tester, marks: [weekly], day: 21);
      expect(find.text('Edit mark'), findsOneWidget);
      expect(find.textContaining('Every week, from'), findsOneWidget);
      expect(find.textContaining('Changes apply to every repeat'), findsOneWidget);
      expect(
          tester.widget<Text>(find.byKey(const ValueKey('editor-date'))).data,
          'Monday, September 21, 2026',
          reason: 'the date you tapped');
      await tester.enterText(chip('label-field'), 'Every Monday');
      await save(tester);
      expect(stored(c).label, 'Every Monday');
      expect(stored(c).date, DateTime(2026, 9, 7), reason: 'the series still starts on the 7th');
    });
  });

  group('several marks on one date', () {
    final a = markOn(DateTime(2026, 9, 24), id: 'a', label: 'First', type: MarkType.good, emoji: '⭐');
    final b = markOn(DateTime(2026, 9, 24), id: 'b', label: 'Second', type: MarkType.cautious);

    testWidgets('lists them, most severe first, plus "New mark"', (tester) async {
      await open(tester, marks: [a, b]);
      expect(chip('existing-a'), findsOneWidget);
      expect(chip('existing-b'), findsOneWidget);
      expect(chip('new-mark'), findsOneWidget);
      expect(find.text('⭐ First'), findsOneWidget);
      expect(tester.widget<TextField>(chip('label-field')).controller!.text, 'Second',
          reason: 'the cautious one is opened first');
      expect(selected(tester, 'existing-b'), isTrue);
    });

    testWidgets('tapping one loads it; New mark clears the form', (tester) async {
      await open(tester, marks: [a, b]);
      await tapChip(tester, 'existing-a');
      expect(tester.widget<TextField>(chip('label-field')).controller!.text, 'First');
      expect(selected(tester, 'emoji-⭐'), isTrue);
      await tapChip(tester, 'new-mark');
      expect(tester.widget<TextField>(chip('label-field')).controller!.text, '');
      expect(selected(tester, 'emoji-none'), isTrue);
      expect(find.text('New mark'), findsWidgets);
    });

    testWidgets('adding another mark to the date keeps the others',
        (tester) async {
      final c = await open(tester, marks: [a, b]);
      await tapChip(tester, 'new-mark');
      await tester.enterText(chip('label-field'), 'Third');
      await tapChip(tester, 'type-neutral');
      await save(tester);
      expect(c.read(calendarMarksProvider).length, 3);
      expect({for (final m in c.read(calendarMarksProvider)) m.label}, {'First', 'Second', 'Third'});
    });

    testWidgets('editing one leaves the other alone', (tester) async {
      final c = await open(tester, marks: [a, b]);
      await tapChip(tester, 'existing-a');
      await tester.enterText(chip('label-field'), 'First edited');
      await save(tester);
      final byId = {for (final m in c.read(calendarMarksProvider)) m.id: m};
      expect(byId['a']!.label, 'First edited');
      expect(byId['b']!.label, 'Second');
    });
  });
}

/// What a fresh load from Hive sees.
List<CalendarMark> makeFresh(ProviderContainer c) {
  final fresh = ProviderContainer(overrides: calendarOverrides());
  addTearDown(fresh.dispose);
  return fresh.read(calendarMarksProvider);
}
