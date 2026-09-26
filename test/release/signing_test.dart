import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// P6-5: release signing through a git-ignored android/key.properties. The key
/// and its passwords never enter the repository.
void main() {
  String read(String path) => File(path).readAsStringSync();

  Future<bool> ignored(String path) async =>
      (await Process.run('git', ['check-ignore', '-q', path])).exitCode == 0;

  test('.gitignore covers key.properties and every keystore', () async {
    final gitignore = read('.gitignore');
    for (final pattern in ['android/key.properties', '*.jks', '*.keystore']) {
      expect(gitignore, contains(pattern));
    }
    for (final path in [
      'android/key.properties',
      'upload.jks',
      'android/app/sadho-upload.jks',
      'release.keystore',
      'android/app/debug.keystore',
    ]) {
      expect(await ignored(path), isTrue, reason: '$path must be git-ignored');
    }
  });

  test('no key file or key.properties is tracked', () async {
    final tracked = (await Process.run('git', ['ls-files'])).stdout as String;
    for (final line in tracked.split('\n')) {
      expect(line, isNot(endsWith('key.properties')));
      expect(line, isNot(endsWith('.jks')));
      expect(line, isNot(endsWith('.keystore')));
    }
  });

  test('build.gradle.kts signs release with key.properties, else warns', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('rootProject.file("key.properties")'));
    for (final key in ['storePassword', 'keyPassword', 'keyAlias', 'storeFile']) {
      expect(gradle, contains('getProperty("$key")'));
    }
    expect(gradle, contains('create("release")'));
    expect(gradle, contains('signingConfigs.getByName("release")'));
    // The fallback keeps `flutter run --release` working, loudly.
    expect(gradle, contains('signingConfigs.getByName("debug")'));
    expect(gradle, contains('release build is NOT upload-signed'));
    // No secret is ever written in the build file.
    expect(gradle, isNot(contains(RegExp(r'Password\s*=\s*"'))));
    // The permanent app id stays.
    expect(gradle, contains('applicationId = "in.sadho.app"'));
  });

  test('the ringtone and notification-icon keep rules are still there', () {
    final keep = read('android/app/src/main/res/raw/keep.xml');
    for (final r in ['@raw/temple_bell', '@raw/singing_bowl', '@raw/soft_chime',
        '@raw/deep_gong', '@drawable/ic_stat_sadho']) {
      expect(keep, contains(r));
    }
  });

  test('if key.properties exists here, it names the upload key and nothing else',
      () {
    final f = File('android/key.properties');
    if (!f.existsSync()) return; // e.g. on another machine: nothing to check
    final keys = {
      for (final line in f.readAsLinesSync())
        if (line.contains('=')) line.substring(0, line.indexOf('=')),
    };
    expect(keys, {'storePassword', 'keyPassword', 'keyAlias', 'storeFile'});
    expect(f.readAsStringSync(), contains('keyAlias=upload'));
  });

  test('README explains releasing', () {
    final readme = read('README.md');
    for (final s in ['## Releasing', 'flutter build appbundle --release',
        'build/app/outputs/bundle/release/app-release.aab', 'Play App Signing',
        '1.0.0+1', 'git-ignored']) {
      expect(readme, contains(s));
    }
    expect(read('pubspec.yaml'), contains(RegExp(r'^version: 1\.0\.0\+1$', multiLine: true)));
  });
}
