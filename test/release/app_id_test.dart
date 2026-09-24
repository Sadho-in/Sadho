import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The app ID can never change once the app is in the stores (a new ID is a
/// new app). These pin it, and the display name, everywhere they live.
void main() {
  String read(String path) => File(path).readAsStringSync();
  const id = 'in.sadho.app';

  test('Android applicationId and namespace', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('applicationId = "$id"'));
    expect(gradle, contains('namespace = "$id"'));
  });

  test('MainActivity lives in the matching Kotlin package', () {
    final f = File('android/app/src/main/kotlin/in/sadho/app/MainActivity.kt');
    expect(f.existsSync(), isTrue);
    expect(f.readAsStringSync(), startsWith('package `in`.sadho.app\n'));
    expect(Directory('android/app/src/main/kotlin/com').existsSync(), isFalse);
  });

  test('iOS bundle identifier', () {
    final ids = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
        .allMatches(read('ios/Runner.xcodeproj/project.pbxproj'))
        .map((m) => m.group(1))
        .toSet();
    expect(ids, {id, '$id.RunnerTests'});
  });

  test('the name on the phone is "Sadho"', () {
    expect(read('android/app/src/main/AndroidManifest.xml'),
        contains('android:label="Sadho"'));
    final plist = read('ios/Runner/Info.plist');
    for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
      expect(plist, contains('<key>$key</key>\n\t<string>Sadho</string>'), reason: key);
    }
  });

  test('nothing still says com.example', () {
    for (final path in [
      'android/app/build.gradle.kts',
      'android/app/src/main/AndroidManifest.xml',
      'ios/Runner.xcodeproj/project.pbxproj',
      'ios/Runner/Info.plist',
    ]) {
      expect(read(path), isNot(contains('com.example')), reason: path);
    }
  });
}
