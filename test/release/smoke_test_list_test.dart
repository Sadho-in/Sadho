import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// P5.1-9: the README keeps a short phone smoke test covering the flows that
/// must never break.
void main() {
  final readme = File('README.md').readAsStringSync();

  String section() {
    final start = readme.indexOf('## Phone smoke test (after every build)');
    expect(start, isNot(-1));
    final end = readme.indexOf('\n## ', start + 5);
    return readme.substring(start, end == -1 ? readme.length : end);
  }

  test('10 to 12 numbered steps', () {
    final steps = RegExp(r'^\d+\. ', multiLine: true).allMatches(section());
    expect(steps.length, inInclusiveRange(10, 12));
  });

  test('covers the core flows', () {
    final s = section().toLowerCase();
    for (final flow in [
      'tap count',
      'rhythm, phone locked',
      'mala, screen off',
      'clock timer, locked',
      'calendar reminder',
      'voice on the phone mic',
      'language',
      'backup',
      'stop',
    ]) {
      expect(s, contains(flow), reason: flow);
    }
  });
}
