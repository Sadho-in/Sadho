import 'dart:convert';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/timer_provider.dart';
import 'package:advance_calendar/features/clock/data/timer_presets.dart';
import 'package:advance_calendar/features/clock/presentation/tools/timer_page.dart';
import 'package:advance_calendar/features/clock/services/location_service.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:advance_calendar/l10n/labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clock_ui_support.dart';

/// P4.3-4: a Custom length (1 s to 24 h) for the Sadhana & vrat timer. It
/// runs exactly like a preset and the last one is remembered.
void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  group('formatShortDuration', () {
    test('shows only the parts that are not zero', () {
      expect(formatShortDuration(en, 17 * 60), '17 min');
      expect(formatShortDuration(en, 3600 + 30), '1 h 30 s');
      expect(formatShortDuration(en, 24 * 3600), '24 h');
      expect(formatShortDuration(en, 1), '1 s');
      expect(formatShortDuration(en, 2 * 3600 + 5 * 60 + 9), '2 h 5 min 9 s');
    });
  });

  group('the timer', () {
    late FakeClock clock;
    late FakeScheduler scheduler;
    late FakeFeedback feedback;

    setUp(() {
      clock = FakeClock(DateTime(2026, 9, 21, 8, 0));
      scheduler = FakeScheduler();
      feedback = FakeFeedback();
    });

    ProviderContainer make({bool fresh = true}) => clockContainer(
          clock: clock,
          scheduler: scheduler,
          feedback: feedback,
          location: FakeLocationService(state: LocationAccess.denied),
          resetStorage: fresh,
        );

    test('accepts 1 s to 24 h, and nothing else', () {
      final c = make();
      final n = c.read(timerProvider.notifier);
      for (final bad in [0, -5, 24 * 3600 + 1]) {
        expect(n.selectCustom(bad), isFalse, reason: '$bad');
        expect(c.read(timerProvider).presetId, isNot(customTimerId));
      }
      for (final ok in [1, 17 * 60, 24 * 3600]) {
        expect(n.selectCustom(ok), isTrue, reason: '$ok');
        final t = c.read(timerProvider);
        expect(t.presetId, customTimerId);
        expect(t.totalSeconds, ok);
        expect(t.remainingSeconds, ok);
        expect(t.phase, TimerPhase.idle);
      }
    });

    test('a custom run counts down, rings through the completion feedback '
        'and schedules the alarm notification, like a preset', () async {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectCustom(17 * 60);
      n.start();
      await Future<void>.delayed(Duration.zero);
      final alerts = scheduler.alerts[timerGroup]!;
      expect(alerts, hasLength(1));
      expect(alerts.single.when, clock.now.add(const Duration(minutes: 17)));
      expect(alerts.single.title, en.timerFinishedTitle(en.customTimerName));

      clock.advance(const Duration(minutes: 10));
      expect(c.read(timerProvider).remainingAt(clock.now), 7 * 60);
      clock.advance(const Duration(minutes: 7));
      n.tick();
      await Future<void>.delayed(Duration.zero);
      expect(c.read(timerProvider).phase, TimerPhase.finished);
      expect(feedback.completions, 1);
      expect(scheduler.alerts[timerGroup] ?? const [], isEmpty,
          reason: 'one ring, not two');

      // Reset / start again go back to the custom length.
      n.reset();
      expect(c.read(timerProvider).remainingSeconds, 17 * 60);
      expect(c.read(timerProvider).presetId, customTimerId);
    });

    test('cannot change the length while running', () {
      final c = make();
      final n = c.read(timerProvider.notifier)..selectCustom(60);
      n.start();
      expect(n.selectCustom(120), isFalse);
      expect(c.read(timerProvider).totalSeconds, 60);
      expect(c.read(lastCustomTimerProvider), 60);
    });

    test('the last custom length and a running custom timer survive a '
        'restart', () {
      final c = make();
      c.read(timerProvider.notifier)
        ..selectCustom(17 * 60 + 5)
        ..start();
      c.dispose();
      final again = make(fresh: false);
      expect(again.read(lastCustomTimerProvider), 17 * 60 + 5);
      expect(again.read(timerProvider).presetId, customTimerId);
      expect(again.read(timerProvider).running, isTrue);
    });

    test('a nonsense saved length is ignored', () {
      AppStorage.useMemoryForTests();
      AppStorage.settings.put('clock.timer.custom', 0);
      final c = make(fresh: false);
      expect(c.read(lastCustomTimerProvider), isNull);
    });

    test('is in the backup (the whole settings box)', () {
      final c = make();
      c.read(timerProvider.notifier).selectCustom(42);
      final json = jsonDecode(exportBackup(now: clock.now)) as Map;
      expect(jsonEncode(json), contains('clock.timer.custom'));
    });
  });

  group('the Custom chip and picker', () {
    Future<void> openPicker(WidgetTester tester) async {
      await tester.tap(byKey('preset-custom'));
      await tester.pumpAndSettle();
    }

    Future<void> enter(WidgetTester tester, int h, int m, int s) async {
      await tester.enterText(byKey('custom-h'), '$h');
      await tester.enterText(byKey('custom-m'), '$m');
      await tester.enterText(byKey('custom-s'), '$s');
      await tester.pump();
    }

    bool okEnabled(WidgetTester tester) =>
        tester.widget<ButtonStyleButton>(byKey('custom-ok')).onPressed != null;

    testWidgets('says "Custom" until a length is chosen, then shows it',
        (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      expect(find.text('Custom'), findsOneWidget);
      await openPicker(tester);
      await enter(tester, 0, 17, 0);
      await tester.tap(byKey('custom-ok'));
      await tester.pumpAndSettle();
      expect(find.text('Custom · 17 min'), findsOneWidget);
      expect(rig.container.read(timerProvider).presetId, customTimerId);
      expect(textOf(tester, 'timer-remaining'), '17:00');
      expect(textOf(tester, 'timer-label'), 'Custom timer');
    });

    testWidgets('the chip shows the remembered length after a restart',
        (tester) async {
      await pumpClock(tester, const TimerPage(),
          saved: {'clock.timer.custom': 3600 + 30});
      expect(find.text('Custom · 1 h 30 s'), findsOneWidget);
      await openPicker(tester);
      expect(tester.widget<TextField>(byKey('custom-h')).controller!.text, '1');
      expect(tester.widget<TextField>(byKey('custom-m')).controller!.text, '0');
      expect(tester.widget<TextField>(byKey('custom-s')).controller!.text, '30');
    });

    testWidgets('no zero, nothing over 24 h, no 60 minutes or seconds',
        (tester) async {
      await pumpClock(tester, const TimerPage());
      await openPicker(tester);
      for (final (h, m, s, ok) in [
        (0, 0, 0, false),
        (0, 0, 1, true),
        (24, 0, 0, true),
        (24, 0, 1, false),
        (25, 0, 0, false),
        (0, 60, 0, false),
        (0, 0, 60, false),
        (23, 59, 59, true),
      ]) {
        await enter(tester, h, m, s);
        expect(okEnabled(tester), ok, reason: '$h:$m:$s');
      }
    });

    testWidgets('Cancel changes nothing', (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      await openPicker(tester);
      await enter(tester, 1, 0, 0);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(rig.container.read(timerProvider).presetId, 'aarti');
      expect(rig.container.read(lastCustomTimerProvider), isNull);
    });

    testWidgets('Start runs the custom countdown; the chip is locked while it '
        'runs', (tester) async {
      final rig = await pumpClock(tester, const TimerPage());
      await openPicker(tester);
      await enter(tester, 0, 0, 45);
      await tester.tap(byKey('custom-ok'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('timer-toggle'));
      await tester.pump();
      await passTime(tester, rig, const Duration(seconds: 15));
      expect(textOf(tester, 'timer-remaining'), '00:30');
      expect(tester.widget<ChoiceChip>(byKey('preset-custom')).onSelected,
          isNull);
      await passTime(tester, rig, const Duration(seconds: 31));
      expect(rig.container.read(timerProvider).phase, TimerPhase.finished);
      expect(rig.feedback.completions, 1);
    });
  });
}
