import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'a11y_support.dart';

/// The tap-target check itself: a small button is still reported; a normal
/// button cut off by a scroll view's edge (only a sliver showing) is not.
void main() {
  testWidgets('a fully visible 30×30 button is reported', (tester) async {
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1; // as the audits run
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Semantics(
            button: true,
            label: 'Go',
            onTap: () {},
            child: const SizedBox(width: 30, height: 30),
          ),
        ),
      ),
    ));
    expect(tapTargetProblems(tester), contains('"Go" is 30.0×30.0'));
    handle.dispose();
  });

  testWidgets('a 48-high button half scrolled out of view is not', (tester) async {
    final handle = tester.ensureSemantics();
    tester.view.physicalSize = const Size(400, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 300,
          child: ListView(
            children: [
              const SizedBox(height: 297),
              SizedBox(
                height: 48,
                child: TextButton(onPressed: () {}, child: const Text('Delete')),
              ),
            ],
          ),
        ),
      ),
    ));
    expect(tapTargetProblems(tester), isEmpty);
    handle.dispose();
  });
}
