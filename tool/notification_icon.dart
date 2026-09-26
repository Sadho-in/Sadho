// Generates the Android notification small icon (res/drawable-*/ic_stat_sadho.png)
// from assets/branding/notification-icon.png (a white silhouette on a
// transparent background). Run from the project root:
//
//   dart run tool/notification_icon.dart
//
// Android draws a small icon from its alpha only, so the output is pure white
// with the logo's alpha, at the standard 24 dp sizes.
import 'dart:io';

import 'package:image/image.dart' as img;

const source = 'assets/branding/notification-icon.png';
const name = 'ic_stat_sadho';

/// Density folder -> pixel size of a 24 dp icon.
const sizes = {
  'drawable-mdpi': 24,
  'drawable-hdpi': 36,
  'drawable-xhdpi': 48,
  'drawable-xxhdpi': 72,
  'drawable-xxxhdpi': 96,
};

void main() {
  final decoded = img.decodePng(File(source).readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Could not read $source');
    exit(1);
  }
  final rgba = decoded.convert(numChannels: 4);
  for (final e in sizes.entries) {
    final out = img.copyResize(rgba,
        width: e.value, height: e.value, interpolation: img.Interpolation.average);
    for (final p in out) {
      p
        ..r = 255
        ..g = 255
        ..b = 255;
    }
    final dir = Directory('android/app/src/main/res/${e.key}')
      ..createSync(recursive: true);
    File('${dir.path}/$name.png').writeAsBytesSync(img.encodePng(out));
    stdout.writeln('${dir.path}/$name.png (${e.value}px)');
  }
}
