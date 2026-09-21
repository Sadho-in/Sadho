import 'dart:convert';
import 'dart:typed_data';

import 'package:advance_calendar/core/constants/app_constants.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> doc({
  Object? format = backupFormat,
  Object? version = backupVersion,
  Object? boxes,
}) =>
    {
      'format': format,
      'version': version,
      'exportedAt': '2026-09-22T08:00:00.000',
      'boxes': boxes ?? {AppStorage.settingsBoxName: {'language': 'hi'}},
    };

void main() {
  setUp(AppStorage.useMemoryForTests);

  Future<void> fillEverything() async {
    await AppStorage.settings.put('language', 'pa');
    await AppStorage.settings.put('profile', {'name': 'Asha', 'email': 'asha@example.com'});
    await AppStorage.settings.put('home.plans', [
      {'id': 'p1', 'title': 'Japji', 'days': 40, 'done': ['2026-09-01', '2026-09-02']},
    ]);
    await AppStorage.calendarMarks.put('m1', {'id': 'm1', 'label': 'Ekadashi', 'date': '2026-09-25'});
    await AppStorage.customMantras.put('c1', {'title': 'My mantra', 'count': 108});
    await AppStorage.mantraOverrides.put('gayatri', {'title': 'Gayatri (edited)'});
    await AppStorage.voiceTemplates.put('c1', {
      'dims': 13,
      'templates': [
        Uint8List.fromList([0, 1, 2, 250, 255]),
        Uint8List.fromList([9, 8, 7]),
      ],
    });
  }

  test('a backup names its format, version, app and date', () {
    final j = jsonDecode(exportBackup(now: DateTime(2026, 9, 22, 8))) as Map;
    expect(j['format'], 'sadho-backup');
    expect(j['version'], 1);
    expect(j['app'], 'Sadho');
    expect(j['appVersion'], AppConstants.version);
    expect(j['exportedAt'], startsWith('2026-09-22T08:00'));
    expect((j['boxes'] as Map).keys.toSet(), AppStorage.all.keys.toSet());
  });

  test('the file name carries the date', () {
    expect(backupFileName(DateTime(2026, 9, 2)), 'sadho-backup-2026-09-02.json');
    expect(backupFileName(DateTime(2027, 12, 31)), 'sadho-backup-2027-12-31.json');
  });

  test('every box round-trips, voice training bytes included', () async {
    await fillEverything();
    final before = _snapshot();
    final text = exportBackup();

    AppStorage.useMemoryForTests(); // a new phone
    expect(_snapshot().values.every((b) => b.isEmpty), isTrue);

    final contents = parseBackup(text);
    await applyBackup(contents);
    expect(_snapshot(), before);
    // Bytes came back as bytes, not as text.
    final t = AppStorage.voiceTemplates.get('c1') as Map;
    expect((t['templates'] as List).first, isA<Uint8List>());
    expect((t['templates'] as List).first, [0, 1, 2, 250, 255]);
    expect(contents.itemCount, 7);
  });

  test('restoring replaces what was there, it does not merge', () async {
    await fillEverything();
    final text = exportBackup();
    await AppStorage.settings.put('language', 'en');
    await AppStorage.settings.put('extra-setting', 1);
    await AppStorage.calendarMarks.put('m2', {'id': 'm2'});

    await applyBackup(parseBackup(text));
    expect(AppStorage.settings.get('language'), 'pa');
    expect(AppStorage.settings.get('extra-setting'), isNull);
    expect(AppStorage.calendarMarks.get('m2'), isNull);
    expect(AppStorage.calendarMarks.get('m1'), isNotNull);
  });

  test('a box the backup does not mention is left alone', () async {
    await AppStorage.calendarMarks.put('keep', {'id': 'keep'});
    await applyBackup(parseBackup(jsonEncode(doc())));
    expect(AppStorage.settings.get('language'), 'hi');
    expect(AppStorage.calendarMarks.get('keep'), isNotNull);
  });

  test('a box this version does not know is ignored', () {
    final c = parseBackup(jsonEncode(doc(boxes: {
      'settings': {'a': 1},
      'quantum_flux': {'b': 2},
    })));
    expect(c.boxes.keys, ['settings']);
  });

  test('numbers that JSON cannot hold are saved as empty, not as a crash', () async {
    await AppStorage.settings.put('bad', double.nan);
    await AppStorage.settings.put('ok', 1.5);
    final c = parseBackup(exportBackup());
    expect(c.boxes['settings']!['bad'], isNull);
    expect(c.boxes['settings']!['ok'], 1.5);
  });

  group('a file that is not a usable backup is refused, with a plain message', () {
    void refuses(String text, String message, {String? why}) {
      expect(
          () => parseBackup(text),
          throwsA(isA<BackupException>()
              .having((e) => e.message, 'message', contains(message))),
          reason: why);
    }

    test('not JSON at all', () {
      refuses('hello there', 'not a Sadho backup');
      refuses('', 'not a Sadho backup');
      refuses('{"format": ', 'not a Sadho backup');
    });

    test('JSON that is not ours', () {
      refuses('[1,2,3]', 'not a Sadho backup');
      refuses('"text"', 'not a Sadho backup');
      refuses(jsonEncode({'hello': 'world'}), 'not a Sadho backup');
      refuses(jsonEncode(doc(format: 'other-app-backup')), 'not a Sadho backup');
    });

    test('a bad version', () {
      refuses(jsonEncode(doc(version: 'one')), 'damaged');
      refuses(jsonEncode(doc(version: 0)), 'damaged');
      refuses(jsonEncode(doc(version: null)), 'damaged');
    });

    test('from a newer Sadho', () {
      refuses(jsonEncode(doc(version: backupVersion + 1)), 'newer version');
    });

    test('damaged contents', () {
      refuses(jsonEncode(doc(boxes: 'nope')), 'damaged');
      refuses(jsonEncode(doc(boxes: {'settings': 'nope'})), 'damaged');
      refuses(
          jsonEncode(doc(boxes: {
            'settings': {'x': {'__b64': '***not base64***'}},
          })),
          'damaged');
    });

    test('a valid shell with none of our data in it', () {
      refuses(jsonEncode(doc(boxes: <String, dynamic>{})), 'no Sadho data');
      refuses(jsonEncode(doc(boxes: {'other': {'a': 1}})), 'no Sadho data');
    });

    test('refusing changes nothing on the phone', () async {
      await fillEverything();
      final before = _snapshot();
      for (final bad in ['junk', jsonEncode(doc(version: 9))]) {
        try {
          parseBackup(bad);
        } on BackupException {
          // expected
        }
      }
      expect(_snapshot(), before);
    });
  });

  test('a backup from the same phone can be read twice', () async {
    await fillEverything();
    final text = exportBackup();
    await applyBackup(parseBackup(text));
    await applyBackup(parseBackup(text));
    expect(AppStorage.settings.get('language'), 'pa');
  });
}

Map<String, Map<String, dynamic>> _snapshot() => {
      for (final e in AppStorage.all.entries)
        e.key: {for (final k in e.value.keys) k: e.value.get(k)},
    };
