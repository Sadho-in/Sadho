import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/alarms/services/alarm_ring.dart';
import 'package:advance_calendar/features/calendar/services/local_notifications_scheduler.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/application/clock_source.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/services/mala_background_service.dart';
import 'package:advance_calendar/features/shell/application/alarm_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import '../sadhana/test_support.dart';

/// P5.1-1: ONE loud alarm ring for every alarm-style finish. Scheduled alarms
/// (the Sadhana Time/Rhythm alarm, the Clock timer, the sun alarm) are handed
/// to the native ring (AlarmManager.setAlarmClock -> AlarmRingService) with the
/// ringtone and repeat settings; the Mala service rings through the same code.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bell = AlarmStyle(
    sound: 'temple_bell',
    soundLabel: 'Temple bell',
    vibrate: true,
    insistent: false,
  );

  group('what a native alarm rings with', () {
    test('a Sadhana alarm: its ringtone, vibration and repeat settings', () {
      final a = nativeAlarmFor(
        ScheduledAlert(
          id: 7,
          when: DateTime(2026, 9, 26, 6, 30),
          title: 'Sadhana time complete',
          body: 'Your session time is up',
          style: const AlarmStyle(
            sound: 'deep_gong',
            soundLabel: 'Deep gong',
            vibrate: false,
            insistent: true,
            soundRepeat: RingRepeat.repeat,
            vibrationRepeat: RingRepeat.until,
          ),
        ),
        stopLabel: 'Stop',
      );
      expect(a.sound, 'deep_gong');
      expect(a.vibrate, isFalse);
      expect(a.soundRepeat, RingRepeat.repeat);
      expect(a.vibrationRepeat, RingRepeat.until);
      final m = a.toMap();
      expect(m['at'], DateTime(2026, 9, 26, 6, 30).millisecondsSinceEpoch);
      expect(m['title'], 'Sadhana time complete');
      expect(m['stopLabel'], 'Stop');
      expect(m['daily'], isFalse);
    });

    test('the Clock timer and sun alarm: the alarm tone, until stopped', () {
      final a = nativeAlarmFor(
        ScheduledAlert(
            id: 1, when: DateTime(2026, 9, 26), title: 'Timer', body: 'Up'),
        stopLabel: 'Stop',
      );
      expect(a.sound, ringDefaultSound);
      expect(a.vibrate, isTrue);
      expect(a.soundRepeat, RingRepeat.until);
      expect(a.vibrationRepeat, RingRepeat.until);
    });

    test('repeat defaults follow "insistent"; explicit settings win', () {
      expect(bell.soundRepeat, RingRepeat.once);
      expect(bell.vibrationRepeat, RingRepeat.once);
      const loud = AlarmStyle(
          sound: null, soundLabel: '', vibrate: true, insistent: true);
      expect(loud.soundRepeat, RingRepeat.until);
      const three = AlarmStyle(
          sound: 'temple_bell',
          soundLabel: '',
          vibrate: true,
          insistent: false,
          soundRepeat: RingRepeat.repeat);
      expect(three.soundRepeat, RingRepeat.repeat);
      expect(three == bell, isFalse, reason: 'a new repeat re-sets the alarm');
    });
  });

  group('the scheduler hands alarms to the native ring', () {
    late FakeAlarmRing ring;
    late LocalNotificationsScheduler scheduler;

    setUp(() {
      resetStorage();
      ring = FakeAlarmRing();
      scheduler = LocalNotificationsScheduler(
          plugin: FlutterLocalNotificationsPlugin(), ring: ring);
    });

    test('alarm-style alerts are rung natively, gentle ones are not', () async {
      await scheduler.replaceAlerts(timerGroup, [
        ScheduledAlert(
            id: 1, when: DateTime(2026, 9, 26, 7), title: 'Timer', body: 'Up'),
        ScheduledAlert(
            id: 2,
            when: DateTime(2026, 9, 26, 8),
            title: 'Gentle',
            body: '',
            gentle: true),
      ]);
      expect(ring.groups[timerGroup]!.map((a) => a.id), [1]);
      expect(ring.groups[timerGroup]!.single.stopLabel, 'Stop');
      expect(ring.channelNames?.sadhana, 'Sadhana alarm');
    });

    test('an empty list cancels the group', () async {
      await scheduler.replaceAlerts(sadhanaTimerGroup, const []);
      expect(ring.groups[sadhanaTimerGroup], isEmpty);
    });

    test('the Sadhana alarm carries its style', () async {
      await scheduler.replaceAlerts(sadhanaTimerGroup, [
        ScheduledAlert(
            id: 3,
            when: DateTime(2026, 9, 26, 7),
            title: 'Done',
            body: '',
            style: bell),
      ]);
      final a = ring.groups[sadhanaTimerGroup]!.single;
      expect(a.sound, 'temple_bell');
      expect(a.soundRepeat, RingRepeat.once);
    });

    test('no native ring (iOS): nothing is sent to it', () async {
      ring.supported = false;
      await scheduler.replaceAlerts(timerGroup, [
        ScheduledAlert(id: 1, when: DateTime(2026, 9, 26), title: 'T', body: ''),
      ]);
      expect(ring.groups, isEmpty);
    });

    test('opening the app silences a ring of that group only while unlocked',
        () async {
      ring.ring(sadhanaTimerGroup);
      ring.locked = true;
      await scheduler.dismissShown(sadhanaTimerGroup);
      expect(ring.state.ringing, isTrue, reason: 'the alarm screen decides');
      ring.locked = false;
      await scheduler.dismissShown(sadhanaTimerGroup);
      expect(ring.state.ringing, isFalse);
      expect(ring.state.unacknowledged, isTrue,
          reason: 'silenced, but the Stop control stays until pressed');
      await scheduler.dismissShown('some-calendar-mark');
      expect(ring.silenced, isNot(contains('some-calendar-mark')));
    });
  });

  group('the Sadhana alarm and the Mala ring follow the repeat settings', () {
    setUp(resetStorage);

    test('Time target: "Repeat" sound, "Until stopped" vibration', () async {
      final scheduler = FakeScheduler();
      final c = ProviderContainer(overrides: [
        ...testOverrides(),
        clockNowProvider.overrideWithValue(() => DateTime(2026, 9, 26, 6)),
        reminderSchedulerProvider.overrideWithValue(scheduler),
      ]);
      addTearDown(c.dispose);
      c.read(completionSettingsProvider.notifier)
        ..setSoundRepeat(SoundRepeat.repeat)
        ..setVibrationRepeat(VibrationRepeat.untilStopped);
      c.read(sadhanaSessionProvider.notifier)
        ..setTargetType(TargetType.time)
        ..setTargetSeconds(60)
        ..setMode(CountMode.rhythm)
        ..toggleRunning();
      await pumpEventQueue();
      final style = scheduler.alerts[sadhanaTimerGroup]!.single.style!;
      expect(style.soundRepeat, RingRepeat.repeat);
      expect(style.vibrationRepeat, RingRepeat.until);
    });

    test('Mala: the service is told the repeat settings', () {
      const config = MalaServiceConfig(
        sessionId: 's',
        count: 0,
        base: 0,
        target: 108,
        vibration: true,
        milestoneEvery: 108,
        milestoneMs: 200,
        milestoneAmplitude: 150,
        ackMs: 60,
        ackAmplitude: 150,
        ring: MalaRing(
          channelId: 'c',
          channelName: 'n',
          channelDescription: 'd',
          sound: 'temple_bell',
          vibrate: true,
          insistent: false,
          title: 't',
          body: 'b',
          soundRepeat: RingRepeat.once,
          vibrationRepeat: RingRepeat.until,
        ),
        text: MalaNotificationText(
          channel: 'c',
          title: 't',
          running: 'r',
          paused: 'p',
          done: 'd',
          pause: 'P',
          resume: 'R',
          stop: 'S',
        ),
      );
      final m = config.toMap();
      expect(m['alarmSoundRepeat'], RingRepeat.once);
      expect(m['alarmVibrationRepeat'], RingRepeat.until);
    });
  });

  testWidgets('Stop on the lock-screen alarm screen stops the native ring',
      (tester) async {
    final ring = FakeAlarmRing()..ring(sadhanaTimerGroup);
    final lock = FakeLockScreen(locked: true, launch: sadhanaTimerGroup);
    final rig = profileRig(
        saved: {'onboarding.done': true},
        lockScreen: lock,
        extra: [alarmRingProvider.overrideWithValue(ring)]);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: rig.container, child: const SadhoApp()));
    await tester.pump();
    await tester.pump();
    expect(rig.container.read(alarmScreenProvider), sadhanaTimerGroup);
    await tester.tap(find.byKey(const ValueKey('alarm-stop')));
    await tester.pump();
    expect(ring.stops, 1);
    expect(ring.state.ringing, isFalse);
    expect(ring.state.unacknowledged, isFalse);
  });

  group('native code (read as text: analyze/test do not compile Kotlin)', () {
    final dir = 'android/app/src/main/kotlin/in/sadho/app';
    String read(String f) => File('$dir/$f').readAsStringSync();

    test('the ring plays on the ALARM stream with an alarm vibration', () {
      final ringer = read('AlarmRinger.kt');
      expect(ringer, contains('AudioAttributes.USAGE_ALARM'));
      expect(ringer, contains('VibrationAttributes.USAGE_ALARM'));
      expect(ringer, contains('longArrayOf(0, 800, 400)'));
      expect(ringer, contains('MIN_ONCE_MS = 5_000L'));
      expect(ringer, contains('MAX_RING_MS = 5 * 60 * 1000L'));
      expect(ringer, contains('PARTIAL_WAKE_LOCK'));
      expect(ringer, contains('ACTION_USER_PRESENT'));
    });

    test('new _v2 channels; the old ones are deleted', () {
      final ringer = read('AlarmRinger.kt');
      expect(ringer, contains('"sadhana_alarm_v2"'));
      expect(ringer, contains('"alarms_timers_v2"'));
      expect(ringer, contains('deleteNotificationChannel'));
    });

    test('scheduled with setAlarmClock; Mala rings through the same code', () {
      expect(read('AlarmScheduler.kt'), contains('setAlarmClock'));
      final mala = read('MalaCounterService.kt');
      expect(mala, contains('AlarmRinger.start('));
      expect(mala, isNot(contains('FLAG_INSISTENT')));
    });

    test('the ring service is systemExempted, with its permission', () {
      final manifest =
          File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
      expect(manifest, contains('FOREGROUND_SERVICE_SYSTEM_EXEMPTED'));
      expect(manifest, contains('android:name=".AlarmRingService"'));
      expect(manifest, contains('android:foregroundServiceType="systemExempted"'));
      expect(read('AlarmRingService.kt'),
          contains('FOREGROUND_SERVICE_TYPE_SYSTEM_EXEMPTED'));
    });
  });
}
