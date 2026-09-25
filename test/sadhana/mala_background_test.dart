import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/session_notice_provider.dart';
import 'package:advance_calendar/features/sadhana/services/mala_background_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// P5-2 / P5-3: a Mala session on Android counts through the native
/// background service (screen on or off). It is the ONLY Mala counter while
/// it runs, starts only for a running Mala session, stops in every stop path,
/// catches up on return and relaunch, and rings at the target exactly once:
/// in the app when it is on screen, from the service when it is not.
void main() {
  late FakeFeedback feedback;
  late FakeVolume volume;
  late FakeMalaService mala;

  setUp(() {
    resetStorage();
    feedback = FakeFeedback();
    volume = FakeVolume();
    mala = FakeMalaService();
  });

  ProviderContainer make() {
    final c = ProviderContainer(
      overrides: testOverrides(feedback: feedback, volume: volume, mala: mala),
    );
    addTearDown(c.dispose);
    return c;
  }

  SadhanaSessionNotifier n(ProviderContainer c) =>
      c.read(sadhanaSessionProvider.notifier);
  SadhanaState s(ProviderContainer c) => c.read(sadhanaSessionProvider);
  int malaCount(ProviderContainer c) => s(c).progressOf(CountMode.mala).count;

  /// Mala selected, target [target], Start pressed.
  /// [flush] lets the start complete (a widget test passes `tester.pump`).
  Future<ProviderContainer> startMala(
      {int target = 108,
      ProviderContainer? c,
      Future<void> Function()? flush}) async {
    final container = c ?? make();
    n(container)
      ..setTargetCount(target)
      ..setMode(CountMode.mala)
      ..toggleRunning();
    await (flush ?? pumpEventQueue)();
    return container;
  }

  group('starts only for a running Mala session', () {
    test('choosing Mala does not start it; Start does', () async {
      final c = make();
      n(c).setMode(CountMode.mala);
      await pumpEventQueue();
      expect(mala.starts, 0);
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(mala.starts, 1);
      expect(mala.running, isTrue);
      expect(s(c).inputActive, isTrue);
      expect(s(c).malaScreenOff, isTrue);
    });

    test('no other mode ever starts it', () async {
      final c = make();
      for (final mode in [CountMode.tap, CountMode.rhythm]) {
        n(c)
          ..setMode(mode)
          ..toggleRunning();
        await pumpEventQueue();
        n(c).pause();
      }
      expect(mala.starts, 0);
    });

    test('it is the ONLY Mala counter: the in-app key listener stays off',
        () async {
      final c = await startMala();
      expect(volume.starts, 0);
      volume.press();
      expect(malaCount(c), 0);
      mala.press();
      mala.press();
      expect(malaCount(c), 2);
    });

    test('the service is sent the count, the other modes and the target',
        () async {
      final c = make();
      n(c)
        ..tap()
        ..tap()
        ..tap(); // Tap 3 (Combined)
      await startMala(target: 27, c: c);
      expect(mala.config!.count, 0);
      expect(mala.config!.base, 3);
      expect(mala.config!.target, 27);
      expect(mala.config!.text.title, contains('{count}'));
      expect(mala.config!.ring.channelId, startsWith('sadhana_alarm_'));
    });
  });

  group('counts land in the Mala bucket', () {
    test('Combined: Mala adds to the shared total', () async {
      final c = make();
      n(c)
        ..tap()
        ..tap();
      await startMala(c: c);
      for (var i = 0; i < 5; i++) {
        mala.press();
      }
      expect(malaCount(c), 5);
      expect(s(c).progressOf(CountMode.tap).count, 2);
      expect(s(c).count, 7);
    });

    test('Separate: Mala counts toward its own target', () async {
      final c = make();
      n(c)
        ..setCountScope(CountScope.separate)
        ..tap()
        ..tap();
      await startMala(target: 3, c: c);
      expect(mala.config!.base, 0);
      mala
        ..press()
        ..press()
        ..press();
      expect(malaCount(c), 3);
      expect(s(c).completed, isTrue);
      expect(s(c).progressOf(CountMode.tap).count, 2);
    });

    test('+ and − in the app are sent to the service', () async {
      final c = await startMala();
      mala.press();
      n(c).increment();
      await pumpEventQueue();
      expect(mala.count, 2);
      n(c).decrement();
      await pumpEventQueue();
      expect(mala.count, 1);
      mala.press();
      expect(malaCount(c), 2);
    });
  });

  group('stops in every stop path', () {
    test('Pause', () async {
      final c = await startMala();
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(mala.stops, 1);
      expect(mala.running, isFalse);
      expect(s(c).malaScreenOff, isFalse);
    });

    test('Reset', () async {
      final c = await startMala();
      mala.press();
      n(c).reset();
      await pumpEventQueue();
      expect(mala.stops, 1);
      expect(malaCount(c), 0);
    });

    test('another mode', () async {
      final c = await startMala();
      n(c).setMode(CountMode.tap);
      await pumpEventQueue();
      expect(mala.stops, 1);
    });

    test('another mantra', () async {
      final c = await startMala();
      n(c).selectMantra('seed_waheguru', 108);
      await pumpEventQueue();
      expect(mala.stops, 1);
    });

    test('Pause from the app, then Start again: a fresh start', () async {
      final c = await startMala();
      mala.press();
      n(c).toggleRunning();
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(mala.starts, 2);
      expect(mala.config!.count, 1);
      expect(mala.running, isTrue);
    });

    test('the app closing its session (dispose)', () async {
      final c = ProviderContainer(
          overrides: testOverrides(feedback: feedback, volume: volume, mala: mala));
      await startMala(c: c);
      c.dispose();
      expect(mala.stops, 1);
      expect(mala.hasListener, isFalse);
    });
  });

  group('notification actions', () {
    test('Pause and Resume from the notification update the app', () async {
      final c = await startMala();
      mala.press();
      mala.notificationPause();
      await pumpEventQueue();
      expect(s(c).running, isFalse);
      // It stays paused in its notification (with Resume): not stopped.
      expect(mala.stops, 0);
      expect(mala.status, MalaServiceStatus.paused);
      mala.notificationResume();
      await pumpEventQueue();
      expect(s(c).running, isTrue);
      expect(mala.starts, 1);
      mala.press();
      expect(malaCount(c), 2);
    });

    test('Stop from the notification pauses the session, count kept', () async {
      final c = await startMala();
      mala
        ..press()
        ..press();
      mala.notificationStop();
      await pumpEventQueue();
      expect(s(c).running, isFalse);
      expect(malaCount(c), 2);
      expect(mala.stops, 1); // only its own
      // Start again: a new service session from the kept count.
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(mala.starts, 2);
      expect(mala.config!.count, 2);
    });

    test('paused from the notification, then Reset in the app: stopped',
        () async {
      final c = await startMala();
      mala.press();
      mala.notificationPause();
      await pumpEventQueue();
      n(c).reset();
      await pumpEventQueue();
      expect(mala.stops, 1);
      expect(mala.status, MalaServiceStatus.stopped);
    });

    test('paused from the notification, then Start in the app resumes it',
        () async {
      final c = await startMala();
      mala.notificationPause();
      await pumpEventQueue();
      n(c).toggleRunning();
      await pumpEventQueue();
      expect(mala.running, isTrue);
      expect(s(c).running, isTrue);
    });
  });

  group('fallback: the service cannot start', () {
    test('the in-app key listener counts instead, with one notice', () async {
      mala.startOk = false;
      final c = await startMala();
      expect(mala.starts, 1);
      expect(volume.starts, 1);
      expect(s(c).inputActive, isTrue);
      expect(s(c).malaScreenOff, isFalse);
      expect(c.read(sessionNoticeProvider)?.message,
          contains('Screen-off counting could not start'));
      volume.press();
      expect(malaCount(c), 1);
      // Pause and start again: no second notice.
      final notice = c.read(sessionNoticeProvider);
      n(c)
        ..toggleRunning()
        ..toggleRunning();
      await pumpEventQueue();
      expect(volume.starts, 2);
      expect(identical(c.read(sessionNoticeProvider), notice), isTrue);
      expect(AppStorage.settings.get(SadhanaSessionNotifier.malaFallbackNoticeKey),
          isTrue);
    });

    test('no service on this phone: the listener, silently', () async {
      mala.supported = false;
      final c = await startMala();
      expect(mala.starts, 0);
      expect(volume.starts, 1);
      expect(c.read(sessionNoticeProvider), isNull);
    });
  });

  group('milestone buzz', () {
    test('in the app when it is on screen', () async {
      await startMala(target: 300);
      for (var i = 0; i < 108; i++) {
        mala.press();
      }
      expect(feedback.milestones, 1);
      expect(mala.nativeMilestones, 0);
    });

    test('from the service (native vibration) in the background', () async {
      await startMala(target: 300);
      mala.appInForeground = false;
      for (var i = 0; i < 108; i++) {
        mala.press();
      }
      expect(feedback.milestones, 0);
      expect(mala.nativeMilestones, 1);
    });
  });

  group('the target', () {
    test('on screen: the in-app alert only, once', () async {
      final c = await startMala(target: 3);
      mala
        ..press()
        ..press()
        ..press();
      expect(s(c).completed, isTrue);
      expect(s(c).running, isFalse);
      expect(feedback.completions, 1);
      expect(mala.nativeRings, 0);
    });

    test('after the target a press only ticks, and the count stays', () async {
      final c = await startMala(target: 2);
      mala
        ..press()
        ..press();
      // The service stays on for the tick (the keys never change the volume).
      expect(mala.running, isTrue);
      mala
        ..press()
        ..press();
      expect(malaCount(c), 2);
      expect(feedback.acknowledgements, 2);
      expect(feedback.completions, 1);
      mala.appInForeground = false;
      mala.press();
      expect(mala.nativeTicks, 1);
      expect(feedback.acknowledgements, 2);
      // Reset then stops it.
      n(c).reset();
      await pumpEventQueue();
      expect(mala.running, isFalse);
    });

    test('raising the target after it was reached stops the service',
        () async {
      final c = await startMala(target: 2);
      mala
        ..press()
        ..press();
      n(c).setTargetCount(108);
      await pumpEventQueue();
      expect(mala.running, isFalse);
      expect(s(c).running, isFalse);
      expect(malaCount(c), 2);
    });

    testWidgets('in the background: the service rings, the app stays quiet',
        (tester) async {
      final c = await startMala(target: 3, flush: tester.pump);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      mala.appInForeground = false;
      mala
        ..press()
        ..press()
        ..press();
      await tester.pump();
      expect(mala.nativeRings, 1);
      expect(feedback.completions, 0);
      expect(s(c).completed, isTrue);
      // Back in the app: still quiet, and the alarm is taken off.
      mala.appInForeground = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(feedback.completions, 0);
      expect(mala.dismissals, 1);
    });

    test('a time target never finishes on a count', () async {
      final c = make();
      n(c)
        ..setMode(CountMode.mala)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(600)
        ..toggleRunning();
      await pumpEventQueue();
      expect(mala.config!.target, greaterThan(1000000));
      expect(mala.config!.text.title, isNot(contains('{target}')));
      for (var i = 0; i < 5; i++) {
        mala.press();
      }
      expect(malaCount(c), 5);
      expect(s(c).completed, isFalse);
      n(c).pause();
    });
  });

  group('catch-up', () {
    testWidgets('on return: counts made while the app was away', (tester) async {
      final c = await startMala(flush: tester.pump);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      mala.appInForeground = false;
      mala.pressWhileDetached(12); // events missed
      expect(malaCount(c), 0);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(malaCount(c), 12);
      expect(s(c).running, isTrue);
    });

    test('on relaunch: takes over the still-running service', () async {
      final first = ProviderContainer(
          overrides: testOverrides(feedback: feedback, volume: volume, mala: mala));
      await startMala(c: first);
      mala.press();
      // The app is killed (its engine gone); the service counts on.
      mala.appKilled();
      first.dispose();
      mala.pressWhileDetached(40);
      final second = make();
      s(second); // relaunch
      await pumpEventQueue();
      expect(malaCount(second), 41);
      expect(s(second).running, isTrue);
      expect(mala.starts, 1, reason: 'taken over, not restarted');
      mala.press();
      expect(malaCount(second), 42);
    });

    test('on relaunch: capped at the target', () async {
      final first = ProviderContainer(
          overrides: testOverrides(feedback: feedback, volume: volume, mala: mala));
      await startMala(target: 108, c: first);
      mala.appKilled();
      first.dispose();
      mala.pressWhileDetached(10);
      mala.count = 500; // more than the target, however that happened
      final second = make();
      s(second);
      await pumpEventQueue();
      expect(malaCount(second), 108);
      expect(s(second).completed, isTrue);
    });

    test('on relaunch after the service rang: quiet; if it did not: rings once',
        () async {
      for (final rang in [true, false]) {
        resetStorage();
        feedback = FakeFeedback();
        mala = FakeMalaService();
        final first = ProviderContainer(
            overrides: testOverrides(feedback: feedback, volume: volume, mala: mala));
        await startMala(target: 5, c: first);
        mala.appInForeground = !rang;
        mala.appKilled();
        first.dispose();
        mala.pressWhileDetached(5);
        expect(mala.rang, rang);
        final second = make();
        s(second);
        await pumpEventQueue();
        expect(s(second).completed, isTrue);
        expect(feedback.completions, rang ? 0 : 1, reason: 'rang: $rang');
      }
    });

    test('on relaunch after the service was stopped: the final count, paused',
        () async {
      final first = ProviderContainer(
          overrides: testOverrides(feedback: feedback, volume: volume, mala: mala));
      await startMala(c: first);
      mala.appKilled();
      first.dispose();
      mala.pressWhileDetached(7);
      mala.status = MalaServiceStatus.stopped; // Stop in its notification
      final second = make();
      s(second);
      await pumpEventQueue();
      expect(malaCount(second), 7);
      expect(s(second).running, isFalse);
      expect(AppStorage.settings.get('sadhana.session')['malaSession'], isNull);
    });

    test('a stale service state from another session is ignored', () async {
      mala
        ..sessionId = 'someone-else'
        ..count = 99;
      AppStorage.settings.put('sadhana.session', {
        'mode': 'mala',
        'malaSession': 'mine',
      });
      final c = make();
      s(c);
      await pumpEventQueue();
      expect(malaCount(c), 0);
    });
  });
}
