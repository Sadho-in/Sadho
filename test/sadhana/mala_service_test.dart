import 'dart:io';

import 'package:advance_calendar/features/sadhana/services/mala_background_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// P5-1: the native Mala counting service's Dart side: the channel, the state
/// it reports and the settings it is sent. The Kotlin service itself is not
/// compiled by these tests; the checks on its source only pin the contract
/// (keys, manifest entries) the two sides share.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = MalaServiceConfig(
    sessionId: 's1',
    count: 3,
    base: 10,
    target: 108,
    vibration: true,
    milestoneEvery: 108,
    milestoneMs: 180,
    milestoneAmplitude: 150,
    ackMs: 60,
    ackAmplitude: 150,
    ring: MalaRing(
      channelId: 'sadhana_alarm_temple_bell_v',
      channelName: 'Sadhana alarm · Temple bell',
      channelDescription: 'desc',
      sound: 'temple_bell',
      vibrate: true,
      insistent: false,
      title: 'Mala complete',
      body: 'Target reached',
    ),
    text: MalaNotificationText(
      channel: 'Mala counter',
      title: 'Mala · {count} / {target}',
      running: 'Press a volume key',
      paused: 'Paused',
      done: 'Target reached',
      pause: 'Pause',
      resume: 'Resume',
      stop: 'Stop',
    ),
  );

  group('MalaServiceState', () {
    test('reads the saved state', () {
      final s = MalaServiceState.fromMap({
        'sessionId': 'abc',
        'count': 54,
        'base': 4,
        'target': 108,
        'status': 'running',
        'reached': false,
        'rang': false,
      });
      expect(s.sessionId, 'abc');
      expect(s.count, 54);
      expect(s.shown, 58);
      expect(s.status, MalaServiceStatus.running);
      expect(s.reached, isFalse);
    });

    test('garbage and missing values fall back safely', () {
      final s = MalaServiceState.fromMap({
        'sessionId': 7,
        'count': -3,
        'target': 0,
        'status': 'flying',
        'rang': 'yes',
      });
      expect(s.sessionId, isNull);
      expect(s.count, 0);
      expect(s.base, 0);
      expect(s.target, 1);
      expect(s.status, MalaServiceStatus.stopped);
      expect(s.rang, isFalse);
    });
  });

  test('an event carries its kind, the state and the app feedback', () {
    final e = MalaServiceEvent.fromMap({
      'event': 'count',
      'feedback': 'ring',
      'count': 108,
      'target': 108,
      'status': 'running',
      'reached': true,
    });
    expect(e.kind, 'count');
    expect(e.feedback, MalaAppFeedback.ring);
    expect(e.state.reached, isTrue);
    expect(MalaServiceEvent.fromMap({'event': 'paused'}).feedback,
        MalaAppFeedback.none);
  });

  test('every setting sent is one the Kotlin service stores', () {
    final kotlin = File(
            'android/app/src/main/kotlin/in/sadho/app/MalaCounterService.kt')
        .readAsStringSync();
    final declared = RegExp(r'const val K_[A-Z_]+ = "([A-Za-z]+)"')
        .allMatches(kotlin)
        .map((m) => m.group(1))
        .toSet();
    expect(config.toMap().keys.toSet().difference(declared), isEmpty);
    // And the state the app reads back uses the same names.
    for (final k in ['sessionId', 'count', 'base', 'target', 'status', 'reached', 'rang']) {
      expect(declared, contains(k));
    }
  });

  test('the manifest declares the specialUse service and its permissions', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE"'));
    expect(manifest, contains('android.permission.FOREGROUND_SERVICE_SPECIAL_USE'));
    expect(manifest, contains('android:name=".MalaCounterService"'));
    expect(manifest, contains('android:foregroundServiceType="specialUse"'));
    expect(manifest, contains('android.app.PROPERTY_SPECIAL_USE_FGS_SUBTYPE'));
    expect(
        manifest,
        contains('Counts mala repetitions from hardware volume-key presses '
            'while the screen is off, and rings when the user\'s target is '
            'reached (hands-free japa counter).'));
    final kotlin = File(
            'android/app/src/main/kotlin/in/sadho/app/MalaCounterService.kt')
        .readAsStringSync();
    // Remote volume, no audio: no silent-audio trick.
    expect(kotlin, contains('VOLUME_CONTROL_RELATIVE'));
    expect(kotlin, contains('setPlaybackToRemote'));
    expect(kotlin, isNot(contains('MediaPlayer')));
    expect(kotlin, isNot(contains('AudioTrack')));
  });

  group('AndroidMalaBackgroundService over the channel', () {
    const channel = MethodChannel('sadho/mala-test');
    late List<MethodCall> calls;
    Object? Function(MethodCall call)? answer;

    setUp(() {
      calls = [];
      answer = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        final a = answer?.call(call);
        if (a is Exception) throw a;
        return a;
      });
    });

    tearDown(() => TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null));

    test('start sends the whole config and reports success', () async {
      answer = (_) => true;
      final service = AndroidMalaBackgroundService(channel: channel);
      expect(await service.start(config), isTrue);
      expect(calls.single.method, 'start');
      final args = calls.single.arguments as Map;
      expect(args['count'], 3);
      expect(args['base'], 10);
      expect(args['alarmSound'], 'temple_bell');
      expect(args['textTitle'], 'Mala · {count} / {target}');
    });

    test('a start that fails or throws is false', () async {
      answer = (_) => false;
      final service = AndroidMalaBackgroundService(channel: channel);
      expect(await service.start(config), isFalse);
      answer = (_) => PlatformException(code: 'fgs');
      expect(await service.start(config), isFalse);
    });

    test('pause, resume, stop, update and dismissRing reach the service',
        () async {
      final service = AndroidMalaBackgroundService(channel: channel);
      await service.pause();
      await service.resume();
      await service.update(config);
      await service.dismissRing();
      await service.stop();
      expect(calls.map((c) => c.method),
          ['pause', 'resume', 'update', 'dismissRing', 'stop']);
    });

    test('a missing service is survived', () async {
      final service = AndroidMalaBackgroundService(
          channel: const MethodChannel('sadho/nothing-here'));
      await service.stop();
      expect(await service.currentState(), isNull);
      expect(await service.start(config), isFalse);
    });

    test('currentState parses the saved state', () async {
      answer = (_) => {'sessionId': 's1', 'count': 7, 'target': 27, 'status': 'paused'};
      final service = AndroidMalaBackgroundService(channel: channel);
      final s = await service.currentState();
      expect(s!.count, 7);
      expect(s.status, MalaServiceStatus.paused);
    });

    test('events from the service reach every listener until cancelled',
        () async {
      final service = AndroidMalaBackgroundService(channel: channel);
      final seen = <MalaServiceEvent>[];
      final cancel = service.listen(seen.add);
      Future<void> send(Map<String, Object?> m) =>
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .handlePlatformMessage(
                  channel.name,
                  channel.codec.encodeMethodCall(MethodCall('event', m)),
                  (_) {});
      await send({'event': 'count', 'count': 1, 'status': 'running'});
      await send({'event': 'stopped', 'count': 1, 'status': 'stopped'});
      expect(seen.map((e) => e.kind), ['count', 'stopped']);
      cancel();
      await send({'event': 'count', 'count': 2});
      expect(seen, hasLength(2));
    });
  });

  test('the default (tests, iOS, desktop) is unsupported and inert', () async {
    const service = UnsupportedMalaBackgroundService();
    expect(service.isSupported, isFalse);
    expect(await service.start(config), isFalse);
    expect(await service.currentState(), isNull);
    service.listen((_) {})();
  });
}
