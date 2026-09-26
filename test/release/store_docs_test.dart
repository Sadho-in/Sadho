import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// P6-4: the store paperwork drafts exist, keep Play's limits, and say what
/// the app really does.
void main() {
  String read(String name) => File('docs/store/$name').readAsStringSync();

  List<String> textBlocks(String md) => RegExp(r'```text\n(.*?)\n```', dotAll: true)
      .allMatches(md)
      .map((m) => m.group(1)!)
      .toList();

  group('listing.md', () {
    final listing = read('listing.md');
    final blocks = textBlocks(listing);

    test('short description: at most 80 characters, alarm first', () {
      final short = blocks[0];
      expect(short.runes.length, lessThanOrEqualTo(80));
      expect(short.toLowerCase(), startsWith('sun-based alarm clock'));
      expect(short.toLowerCase(), contains('reminders'));
    });

    test('full description: at most 4000 characters, alarms/timers/reminders core',
        () {
      final full = blocks[1];
      expect(full.runes.length, lessThanOrEqualTo(4000));
      final lower = full.toLowerCase();
      for (final core in ['alarm clock', 'sun-based alarm', 'timer', 'reminders']) {
        expect(lower, contains(core));
      }
      // The alarm clock comes before the counter.
      expect(lower.indexOf('alarm clock'), lessThan(lower.indexOf('japa')));
      expect(lower, contains('no account, no ads'));
    });

    test('eight screenshots are listed', () {
      final section = listing.split('## Screenshots').last;
      expect(RegExp(r'^\d\. \*\*', multiLine: true).allMatches(section).length, 8);
    });
  });

  test('data-safety.md: nothing collected, every permission explained', () {
    final ds = read('data-safety.md');
    expect(ds, contains('Does your app collect or share any of the required user data types? | **No**'));
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final permissions = RegExp(r'android\.permission\.([A-Z_]+)')
        .allMatches(manifest)
        .map((m) => m.group(1)!)
        .toSet()
      ..removeAll({'VIBRATE', 'WAKE_LOCK', 'SCHEDULE_EXACT_ALARM'});
    for (final p in permissions) {
      expect(ds, contains(p), reason: '$p is not explained');
    }
    expect(ds, contains('[CHECK]'), reason: 'uncertain answers are marked');
  });

  test('declarations.md: exact alarm, full screen, specialUse, each with a video',
      () {
    final d = read('declarations.md');
    for (final heading in ['USE_EXACT_ALARM', 'USE_FULL_SCREEN_INTENT',
        'FOREGROUND_SERVICE_SPECIAL_USE', 'ACCESS_NOTIFICATION_POLICY']) {
      expect(d, contains(heading));
    }
    expect('**Demo video script (30 s):**'.allMatches(d).length, 3);
    // The specialUse text matches the manifest subtype word for word.
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    final subtype = RegExp(r'PROPERTY_SPECIAL_USE_FGS_SUBTYPE"\s*android:value="([^"]+)"')
        .firstMatch(manifest)!
        .group(1)!
        .replaceAll('&apos;', "'");
    expect(d.replaceAll('\n', ' '), contains(subtype));
  });

  test('content-rating.md: all-ages answers', () {
    final c = read('content-rating.md');
    expect(c, contains('IARC 3+'));
    for (final topic in ['Violence', 'Gambling', 'interact or communicate', 'location']) {
      expect(c, contains(topic));
    }
  });
}
