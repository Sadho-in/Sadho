import 'dart:io';

import 'package:advance_calendar/core/licenses.dart';
import 'package:advance_calendar/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// P6-2: Fraunces and Karla are bundled; nothing fetches fonts at runtime;
/// the fonts' OFL licences are on the licences page.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String read(String path) => File(path).readAsStringSync();
  const weights = [300, 400, 500, 600, 700, 800];

  test('every weight of both families is bundled, as a real TrueType file', () {
    final pubspec = read('pubspec.yaml');
    for (final family in ['Fraunces', 'Karla']) {
      expect(pubspec, contains('- family: $family'));
      for (final w in weights) {
        final path = 'assets/fonts/$family-$w.ttf';
        expect(pubspec, contains('- asset: $path\n          weight: $w'));
        final bytes = File(path).readAsBytesSync();
        expect(ByteData.sublistView(bytes).getUint32(0), 0x00010000,
            reason: '$path is a TrueType font');
      }
    }
  });

  test('every font weight the app asks for is one that is bundled', () {
    final used = <int>{400, 500}; // Material's own defaults
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in RegExp(r'FontWeight\.w(\d00)').allMatches(f.readAsStringSync())) {
        used.add(int.parse(m.group(1)!));
      }
    }
    expect(weights.toSet().containsAll(used), isTrue, reason: 'used: $used');
  });

  test('no runtime font fetching: google_fonts is gone', () {
    expect(read('pubspec.yaml'), isNot(contains('google_fonts')));
    expect(read('pubspec.lock'), isNot(contains('google_fonts')));
    for (final dir in ['lib', 'test', 'integration_test']) {
      for (final f in Directory(dir).listSync(recursive: true).whereType<File>()) {
        if (f.path.endsWith('.dart')) {
          // (Split so that this file does not find itself.)
          expect(f.readAsStringSync(), isNot(contains('package:' 'google_fonts')),
              reason: f.path);
        }
      }
    }
  });

  test('the theme uses them: Fraunces for headings, Karla for the rest', () {
    for (final theme in [AppTheme.light, AppTheme.dark]) {
      final t = theme.textTheme;
      expect(t.headlineSmall!.fontFamily, 'Fraunces');
      expect(t.displayLarge!.fontFamily, 'Fraunces');
      expect(t.titleLarge!.fontFamily, 'Fraunces');
      expect(t.bodyMedium!.fontFamily, 'Karla');
      expect(t.titleMedium!.fontFamily, 'Karla');
      expect(t.labelLarge!.fontFamily, 'Karla');
    }
  });

  test('the fonts OFL licences are registered for the licences page', () async {
    registerFontLicenses();
    registerFontLicenses(); // twice is harmless
    final entries = await LicenseRegistry.licenses.toList();
    String textOf(String package) => entries
        .where((e) => e.packages.contains(package))
        .expand((e) => e.paragraphs)
        .map((p) => p.text)
        .join('\n');
    for (final package in ['Fraunces', 'Karla', 'Noto Sans Devanagari', 'Noto Sans Tamil']) {
      expect(textOf(package), contains('SIL Open Font License'), reason: package);
    }
    expect(entries.where((e) => e.packages.contains('Karla')), hasLength(1));
    // The licence texts are bundled assets.
    for (final path in bundledFontLicenses.keys) {
      expect(read('pubspec.yaml'), contains('- $path'));
      expect(read(path), contains('SIL OPEN FONT LICENSE'));
    }
  });
}
