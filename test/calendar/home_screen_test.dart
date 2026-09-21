import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/application/calendar_marks_provider.dart';
import 'package:advance_calendar/features/calendar/application/home_cards_provider.dart';
import 'package:advance_calendar/features/calendar/application/now_provider.dart';
import 'package:advance_calendar/features/calendar/data/calendar_mark.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_palette.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'calendar_support.dart';

void main() {
  // Monday 21 September 2026.
  DateTime at(int h, [int m = 0, int day = 21]) => DateTime(2026, 9, day, h, m);

  Future<ProviderContainer> open(
    WidgetTester tester, {
    List<CalendarMark> marks = const [],
    DateTime? now,
  }) async {
    phoneScreen(tester, height: 1600);
    final c = await calendarContainer(marks: marks, now: now ?? at(8));
    await pumpScreen(tester, c, const HomeScreen());
    return c;
  }

  FakeNow clock(ProviderContainer c) => c.read(nowProvider.notifier) as FakeNow;

  Finder card(String id) => find.byKey(ValueKey('home-card-$id'));

  Future<void> swipe(WidgetTester tester, String id, {double dx = -600}) async {
    await tester.fling(card(id), Offset(dx, 0), 2000);
    await tester.pumpAndSettle();
  }

  final pinned = markOn(DateTime(2026, 9, 21),
      id: 'pin', label: 'Ekadashi fast', emoji: '🪔', details: 'Eat only fruit.',
      type: MarkType.cautious, home: HomeMode.allDay);
  final morning = markOn(DateTime(2026, 9, 21),
      id: 'morn', label: 'Sunrise prayer', emoji: '🌅', details: 'Face east.',
      type: MarkType.good, home: HomeMode.morning, homeMinutes: 6 * 60 + 30);

  setUp(() => AppStorage.useMemoryForTests());

  group('the Home tab', () {
    testWidgets('says nothing is flagged, and how to flag something',
        (tester) async {
      await open(tester);
      expect(find.text('Today'), findsOneWidget);
      expect(tester.widget<Text>(find.byKey(const ValueKey('home-date'))).data,
          'Monday, September 21, 2026');
      expect(find.byKey(const ValueKey('home-empty')), findsOneWidget);
      expect(find.textContaining('On your home screen'), findsOneWidget);
      expect(find.text('Coming soon'), findsNothing, reason: 'no longer a placeholder');
    });

    testWidgets('does not show marks that are not flagged, or not today',
        (tester) async {
      await open(tester, marks: [
        markOn(DateTime(2026, 9, 21), id: 'a', label: 'not flagged'),
        markOn(DateTime(2026, 9, 22), id: 'b', label: 'tomorrow', home: HomeMode.allDay),
      ]);
      expect(find.text('not flagged'), findsNothing);
      expect(find.text('tomorrow'), findsNothing);
      expect(find.byKey(const ValueKey('home-empty')), findsOneWidget);
    });

    testWidgets('a repeating mark appears on the days it falls on',
        (tester) async {
      await open(tester, marks: [
        markOn(DateTime(2026, 9, 7), id: 'w', label: 'Weekly puja',
            repeat: RepeatRule.weekly, home: HomeMode.allDay),
      ]);
      expect(find.text('Weekly puja'), findsOneWidget, reason: 'Monday 21 is 2 weeks on');
    });
  });

  group('"Keep all day" cards are pinned', () {
    testWidgets('show emoji, label, notes and a pin, in the mark\'s colour',
        (tester) async {
      await open(tester, marks: [pinned]);
      expect(find.text('Ekadashi fast'), findsOneWidget);
      expect(find.text('🪔'), findsOneWidget);
      expect(find.text('Eat only fruit.'), findsOneWidget);
      expect(find.byKey(const ValueKey('mark-pin')), findsOneWidget);
      expect(find.text('Pinned all day'), findsOneWidget);
      expect(find.text('Cautious'), findsOneWidget);
      expect(find.text('On Home all day'), findsOneWidget);
      final stripe = tester.widget<Container>(find.byKey(const ValueKey('mark-stripe')));
      expect(stripe.color, MarkPalette.base(MarkType.cautious, Brightness.light));
    });

    testWidgets('cannot be swiped away', (tester) async {
      final c = await open(tester, marks: [pinned]);
      expect(find.byType(Dismissible), findsNothing);
      for (final dx in [-700.0, 700.0]) {
        await swipe(tester, 'pin', dx: dx);
        expect(card('pin'), findsOneWidget, reason: 'swipe $dx');
      }
      expect(c.read(homeCardsProvider).single.pinned, isTrue);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('stay all day, from just after midnight to just before',
        (tester) async {
      final c = await open(tester, marks: [pinned], now: at(0, 1));
      expect(card('pin'), findsOneWidget);
      clock(c).set(at(23, 59));
      await tester.pump();
      expect(card('pin'), findsOneWidget);
      clock(c).set(at(0, 0, 22));
      await tester.pump();
      expect(card('pin'), findsNothing, reason: 'the next day it is not on the 22nd');
    });
  });

  group('"Once in the morning" cards', () {
    testWidgets('appear at their time, not before', (tester) async {
      final c = await open(tester, marks: [morning], now: at(6, 29));
      expect(card('morn'), findsNothing);
      clock(c).set(at(6, 30));
      await tester.pump();
      expect(card('morn'), findsOneWidget);
      expect(find.text('On Home from 6:30 AM'), findsOneWidget);
    });

    testWidgets('can be swiped away, from either side', (tester) async {
      for (final dx in [-600.0, 600.0]) {
        final c = await open(tester, marks: [morning]);
        expect(find.byType(Dismissible), findsOneWidget);
        expect(find.text('Swipe to dismiss for today'), findsOneWidget);
        await swipe(tester, 'morn', dx: dx);
        expect(card('morn'), findsNothing, reason: 'swipe $dx');
        expect(c.read(homeCardsProvider), isEmpty);
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('a swipe says "Done for today" and offers Undo', (tester) async {
      final c = await open(tester, marks: [morning]);
      await swipe(tester, 'morn');
      expect(find.text('Done for today: Sunrise prayer'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(card('morn'), findsOneWidget, reason: 'brought back');
      expect(c.read(homeCardsProvider).length, 1);
    });

    testWidgets('only for that day: it is back tomorrow', (tester) async {
      final daily = morning.copyWith(repeat: RepeatRule.daily);
      final c = await open(tester, marks: [daily]);
      await swipe(tester, 'morn');
      expect(card('morn'), findsNothing);
      clock(c).set(at(23, 0));
      await tester.pump();
      expect(card('morn'), findsNothing, reason: 'still done later that day');
      clock(c).set(at(8, 0, 22));
      await tester.pump();
      expect(card('morn'), findsOneWidget, reason: 'tomorrow it is back');
    });

    testWidgets('stays dismissed after the app is reopened', (tester) async {
      final c = await open(tester, marks: [morning]);
      await swipe(tester, 'morn');
      expect(c.read(homeDismissalsProvider).length, 1);
      await tester.pumpWidget(const SizedBox());

      final again = ProviderContainer(overrides: calendarOverrides(now: at(9)));
      addTearDown(again.dispose);
      await pumpScreen(tester, again, const HomeScreen());
      expect(card('morn'), findsNothing);
      expect(find.byKey(const ValueKey('home-empty')), findsOneWidget);
    });

    testWidgets('dismissing one leaves the others', (tester) async {
      await open(tester, marks: [
        morning,
        morning.copyWith(label: 'Evening prayer'),
      ].asMap().entries.map((e) => CalendarMark.fromMap({...e.value.toMap(), 'id': 'm${e.key}'})!).toList());
      expect(find.byType(Dismissible), findsNWidgets(2));
      await swipe(tester, 'm0');
      expect(card('m0'), findsNothing);
      expect(card('m1'), findsOneWidget);
    });
  });

  group('the list', () {
    testWidgets('pinned cards first, then morning cards by time',
        (tester) async {
      await open(tester, now: at(12), marks: [
        markOn(DateTime(2026, 9, 21), id: 'late', label: 'Late', home: HomeMode.morning, homeMinutes: 9 * 60),
        markOn(DateTime(2026, 9, 21), id: 'early', label: 'Early', home: HomeMode.morning, homeMinutes: 6 * 60),
        markOn(DateTime(2026, 9, 21), id: 'pin', label: 'Pinned', home: HomeMode.allDay),
      ]);
      double y(String id) => tester.getTopLeft(card(id)).dy;
      expect(y('pin'), lessThan(y('early')));
      expect(y('early'), lessThan(y('late')));
    });

    testWidgets('a mark edited to "Don\'t show" leaves Home', (tester) async {
      final c = await open(tester, marks: [pinned]);
      expect(card('pin'), findsOneWidget);
      await c.read(calendarMarksProvider.notifier).save(pinned.copyWith(homeMode: HomeMode.none));
      await tester.pump();
      expect(card('pin'), findsNothing);
    });

    testWidgets('a deleted mark leaves Home', (tester) async {
      final c = await open(tester, marks: [pinned]);
      await c.read(calendarMarksProvider.notifier).delete('pin');
      await tester.pump();
      expect(card('pin'), findsNothing);
      expect(find.byKey(const ValueKey('home-empty')), findsOneWidget);
    });

    testWidgets('tapping a card opens that mark in the editor', (tester) async {
      await open(tester, marks: [pinned]);
      await tester.tap(card('pin'));
      await tester.pumpAndSettle();
      expect(find.text('Edit mark'), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const ValueKey('label-field'))).controller!.text,
          'Ekadashi fast');
    });

    testWidgets('works in the dark theme too', (tester) async {
      phoneScreen(tester, height: 1600);
      final c = await calendarContainer(marks: [pinned, morning], now: at(8));
      await pumpScreen(tester, c, const HomeScreen(), brightness: Brightness.dark);
      expect(tester.takeException(), isNull);
      final stripe = tester.widget<Container>(
          find.descendant(of: card('pin'), matching: find.byKey(const ValueKey('mark-stripe'))));
      expect(stripe.color, MarkPalette.base(MarkType.cautious, Brightness.dark));
    });

    testWidgets('the clock turning midnight rolls the day over', (tester) async {
      final c = await open(tester, marks: [pinned], now: at(23, 58));
      expect(find.text('Monday, September 21, 2026'), findsOneWidget);
      clock(c).set(at(0, 1, 22));
      await tester.pump();
      expect(find.text('Tuesday, September 22, 2026'), findsOneWidget);
    });
  });
}
