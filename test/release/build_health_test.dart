import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// P6-6: the SDK levels Google Play needs, and the dependency decisions.
void main() {
  String read(String path) => File(path).readAsStringSync();

  int flutterDefault(String name) {
    final root = Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.path;
    final ext = File(
            '$root/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt')
        .readAsStringSync();
    return int.parse(
        RegExp('val $name: Int = (\\d+)').firstMatch(ext)!.group(1)!);
  }

  test('targetSdk is 36 or more (Google Play, new apps from 31 Aug 2026)', () {
    final gradle = read('android/app/build.gradle.kts');
    expect(gradle, contains('targetSdk = flutter.targetSdkVersion'));
    expect(gradle, contains('compileSdk = flutter.compileSdkVersion'));
    expect(gradle, contains('minSdk = flutter.minSdkVersion'));
    expect(flutterDefault('targetSdkVersion'), greaterThanOrEqualTo(36));
    expect(flutterDefault('compileSdkVersion'), greaterThanOrEqualTo(36));
    expect(flutterDefault('minSdkVersion'), 24,
        reason: 'the launcher-icon config and README say 24');
  });

  test('permission_handler stays on 12.x (13.x needs compileSdk 37)', () {
    final pubspec = read('pubspec.yaml');
    expect(pubspec, contains('permission_handler: ^12.'));
    expect(pubspec, contains('compileSdk 37'));
  });

  test('flutter_volume_controller is still needed (the Mala fallback)', () {
    final lock = read('pubspec.lock');
    expect(lock, contains('volume_button_listener'));
    expect(lock, contains('flutter_volume_controller'));
    expect(read('pubspec.yaml'), isNot(contains('flutter_volume_controller')),
        reason: 'only a transitive dependency');
  });

  test('the Kotlin Gradle Plugin situation is documented where it is set', () {
    expect(read('android/gradle.properties'), contains('android.builtInKotlin'));
    expect(read('README.md'), contains('## Build health'));
  });

  test('P5.1-8: built-in Kotlin is on (plugins skip the old Kotlin plugin)', () {
    expect(read('android/gradle.properties'),
        contains(RegExp(r'^android\.builtInKotlin=true$', multiLine: true)));
    final app = read('android/app/build.gradle.kts');
    expect(app, isNot(contains('kotlin-android')),
        reason: 'the app itself never applies the old plugin');
  });
}
