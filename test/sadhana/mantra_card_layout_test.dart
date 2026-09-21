import 'package:advance_calendar/features/sadhana/application/mantra_text_scale_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mantra_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// The card's right edge: A− / A+ in the TOP-RIGHT corner, Library in the
/// BOTTOM-RIGHT corner, with a gap between them.
void main() {
  setUp(() {
    resetStorage();
    seedTrainedVoice();
  });

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    String mantra = 'seed_mool_mantar',
    double width = 360,
    double scale = 1.3,
    Brightness brightness = Brightness.light,
  }) async {
    tester.view.physicalSize = Size(width, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final c = ProviderContainer(overrides: testOverrides());
    addTearDown(c.dispose);
    c.read(sadhanaSessionProvider.notifier).selectMantra(mantra, 11);
    c.read(mantraTextScaleProvider.notifier).set(scale);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: const Scaffold(body: SingleChildScrollView(child: MantraCard())),
      ),
    ));
    await tester.pump();
    return c;
  }

  Rect card(WidgetTester t) => t.getRect(find.byType(Card).first);
  Rect sizeButtons(WidgetTester t) => t.getRect(key('mantra-size-controls'));
  Rect library(WidgetTester t) => t.getRect(key('mantra-library-button'));
  Rect a(WidgetTester t, String label) => t.getRect(find.text(label));

  void expectLayout(WidgetTester t, {String reason = ''}) {
    final c = card(t), sz = sizeButtons(t), lib = library(t);
    // Top-right: the size buttons sit at the card's top edge and right edge.
    expect(sz.top - c.top, lessThanOrEqualTo(14), reason: 'A−/A+ at the top. $reason');
    expect(c.right - sz.right, lessThanOrEqualTo(14), reason: 'A−/A+ at the right. $reason');
    // Bottom-right: Library sits at the card's bottom edge and right edge.
    expect(c.bottom - lib.bottom, lessThanOrEqualTo(14), reason: 'Library at the bottom. $reason');
    expect(c.right - lib.right, lessThanOrEqualTo(14), reason: 'Library at the right. $reason');
    // Same right edge (within the buttons' own padding).
    expect((sz.right - lib.right).abs(), lessThanOrEqualTo(10), reason: 'one right edge. $reason');
    // Library is NOT directly under A+: a real gap between them.
    expect(lib.top - sz.bottom, greaterThanOrEqualTo(12), reason: 'a gap. $reason');
    // Nothing overlaps.
    expect(sz.overlaps(lib), isFalse, reason: reason);
  }

  testWidgets('A− and A+ at the top-right, Library at the bottom-right',
      (tester) async {
    await pump(tester);
    expectLayout(tester);
    // A− is left of A+, both in the size control.
    expect(a(tester, 'A−').right, lessThan(a(tester, 'A+').left));
    expect(a(tester, 'A+').right, lessThanOrEqualTo(sizeButtons(tester).right));
    // Library is the lowest thing on the right, A± the highest.
    expect(sizeButtons(tester).center.dy, lessThan(card(tester).center.dy));
    expect(library(tester).center.dy, greaterThan(card(tester).center.dy));
  });

  testWidgets('both are on the right of the mantra text', (tester) async {
    await pump(tester);
    final text = tester.getRect(find.text('Mool Mantar'));
    expect(sizeButtons(tester).left, greaterThan(text.right - 1));
    expect(library(tester).left, greaterThan(text.right - 1));
  });

  testWidgets('Library is not directly under A+, at every text size',
      (tester) async {
    final c = await pump(tester);
    for (var s = 0.8; s <= 2.001; s += 0.1) {
      c.read(mantraTextScaleProvider.notifier).set(s);
      await tester.pump();
      expectLayout(tester, reason: 'scale ${s.toStringAsFixed(1)}');
    }
  });

  for (final w in [320.0, 360.0, 411.0, 600.0]) {
    testWidgets('holds at ${w.toInt()} px wide, with a short and a long mantra',
        (tester) async {
      for (final id in ['seed_waheguru', 'seed_gayatri']) {
        await pump(tester, mantra: id, width: w);
        expectLayout(tester, reason: '$id at $w');
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('a short card still keeps the two apart', (tester) async {
    // Waheguru at the smallest size: the least text there can be.
    await pump(tester, mantra: 'seed_waheguru', scale: 0.8);
    expectLayout(tester);
    expect(card(tester).height, greaterThan(70));
  });

  testWidgets('the card gets taller with the text; the buttons stay in the corners',
      (tester) async {
    final c = await pump(tester, mantra: 'seed_gayatri', scale: 0.8);
    final small = card(tester).height;
    c.read(mantraTextScaleProvider.notifier).set(2.0);
    await tester.pump();
    expect(card(tester).height, greaterThan(small));
    expectLayout(tester);
    // Library moved down with the card's bottom edge.
    expect(card(tester).bottom - library(tester).bottom, lessThanOrEqualTo(14));
  });

  testWidgets('dark theme too', (tester) async {
    await pump(tester, brightness: Brightness.dark);
    expectLayout(tester);
  });

  group('the buttons still work where they now are', () {
    testWidgets('A+ and A− still change the size', (tester) async {
      final c = await pump(tester, scale: 1.3);
      await tester.tap(find.text('A+'));
      await tester.pump();
      expect(c.read(mantraTextScaleProvider), closeTo(1.4, 1e-9));
      await tester.tap(find.text('A−'));
      await tester.tap(find.text('A−'));
      await tester.pump();
      expect(c.read(mantraTextScaleProvider), closeTo(1.2, 1e-9));
    });

    testWidgets('Library (bottom-right) opens the mantra library', (tester) async {
      await pump(tester);
      await tester.tap(key('mantra-library-button'));
      await tester.pumpAndSettle();
      expect(find.text('Mantra library'), findsOneWidget);
    });

    testWidgets('the rest of the card still opens the library', (tester) async {
      await pump(tester);
      await tester.tap(find.text('Mool Mantar'));
      await tester.pumpAndSettle();
      expect(find.text('Mantra library'), findsOneWidget);
    });

    testWidgets('the gap between the two is not a button: it does not eat taps '
        'meant for the card', (tester) async {
      await pump(tester);
      final sz = sizeButtons(tester), lib = library(tester);
      final gap = Offset(sz.center.dx, (sz.bottom + lib.top) / 2);
      await tester.tapAt(gap);
      await tester.pumpAndSettle();
      expect(find.text('Mantra library'), findsOneWidget, reason: 'it is card area');
    });
  });
}
