import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_text_scale_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mantra_card.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/progress_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';
import 'package:advance_calendar/features/sadhana/data/seed_mantras.dart';

void main() {
  late FakeVoice voice;

  setUp(() {
    resetStorage();
    seedTrainedVoice();
    voice = FakeVoice();
  });

  const key = 'sadhana.mantraTextScale';
  // The sizes the card scales from (what a real Theme resolves to).
  const base = Typography.englishLike2021;

  ProviderContainer make() {
    final c = ProviderContainer(overrides: testOverrides(voice: voice));
    addTearDown(c.dispose);
    return c;
  }

  double scaleOf(ProviderContainer c) => c.read(mantraTextScaleProvider);
  MantraTextScaleNotifier sizer(ProviderContainer c) =>
      c.read(mantraTextScaleProvider.notifier);

  group('the setting', () {
    test('defaults to a comfortably large size: bigger than the base 1.0', () {
      final c = make();
      expect(scaleOf(c), defaultMantraTextScale);
      expect(defaultMantraTextScale, greaterThan(1.0));
      expect(defaultMantraTextScale, greaterThanOrEqualTo(1.2));
    });

    test('ranges from 0.8x to 2.0x', () {
      expect(minMantraTextScale, 0.8);
      expect(maxMantraTextScale, 2.0);
      expect(mantraTextScaleStep, 0.1);
    });

    test('A+ and A- move by one step', () {
      final c = make();
      sizer(c).larger();
      expect(scaleOf(c), closeTo(1.4, 1e-9));
      sizer(c).smaller();
      sizer(c).smaller();
      expect(scaleOf(c), closeTo(1.2, 1e-9));
    });

    test('stops at 2.0x and at 0.8x, exactly, however often it is pressed', () {
      final c = make();
      for (var i = 0; i < 30; i++) {
        sizer(c).larger();
      }
      expect(scaleOf(c), 2.0);
      for (var i = 0; i < 30; i++) {
        sizer(c).smaller();
      }
      expect(scaleOf(c), 0.8);
    });

    test('the whole range is reachable in steps, with no floating-point drift',
        () {
      final c = make();
      for (var i = 0; i < 7; i++) {
        sizer(c).larger(); // 1.3 -> 2.0 in seven steps
      }
      expect(scaleOf(c), 2.0);
      for (var i = 0; i < 12; i++) {
        sizer(c).smaller(); // 2.0 -> 0.8 in twelve steps
      }
      expect(scaleOf(c), 0.8);
    });

    test('set() clamps to the range and snaps to 0.05', () {
      final c = make();
      sizer(c).set(2.6);
      expect(scaleOf(c), 2.0);
      sizer(c).set(0.1);
      expect(scaleOf(c), 0.8);
      sizer(c).set(-3);
      expect(scaleOf(c), 0.8);
      sizer(c).set(1.37);
      expect(scaleOf(c), 1.35);
      sizer(c).set(1.0);
      expect(scaleOf(c), 1.0);
    });

    test('ignores a value that is not a number', () {
      final c = make();
      sizer(c).set(1.6);
      sizer(c).set(double.nan);
      sizer(c).set(double.infinity);
      expect(scaleOf(c), 1.6);
    });

    test('reset returns to the default', () {
      final c = make();
      sizer(c).set(1.9);
      sizer(c).reset();
      expect(scaleOf(c), defaultMantraTextScale);
    });

    test('is saved in Hive and restored on relaunch', () {
      final c = make();
      expect(AppStorage.settings.get(key), isNull, reason: 'nothing until changed');
      sizer(c).set(1.7);
      expect(AppStorage.settings.get(key), 1.7);
      expect(scaleOf(make()), 1.7);
      sizer(c).larger();
      expect(AppStorage.settings.get(key), closeTo(1.8, 1e-9));
      expect(scaleOf(make()), closeTo(1.8, 1e-9));
    });

    test('a live pinch is not written until it ends', () {
      final c = make();
      sizer(c).set(1.5, persist: false);
      sizer(c).set(1.6, persist: false);
      expect(scaleOf(c), 1.6, reason: 'live');
      expect(AppStorage.settings.get(key), isNull, reason: 'not saved yet');
      sizer(c).commit();
      expect(AppStorage.settings.get(key), 1.6);
    });

    test('a damaged saved value falls back or is clamped', () {
      for (final (saved, expected) in <(Object?, double)>[
        ('huge', defaultMantraTextScale),
        (null, defaultMantraTextScale),
        (double.nan, defaultMantraTextScale),
        (double.infinity, defaultMantraTextScale),
        (99.0, 2.0),
        (-4, 0.8),
        (1.4, 1.4),
        (2, 2.0),
      ]) {
        AppStorage.settings.put(key, saved);
        expect(scaleOf(make()), expected, reason: '$saved');
      }
    });

    test('scaledMantraStyle multiplies the size and keeps the rest', () {
      final s = scaledMantraStyle(
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.5),
          1.5);
      expect(s!.fontSize, 24);
      expect(s.fontWeight, FontWeight.w700);
      expect(s.height, 1.5);
      expect(scaledMantraStyle(null, 2), isNull);
      expect(scaledMantraStyle(const TextStyle(), 2)!.fontSize, 28,
          reason: 'no size given: 14 is assumed');
    });
  });

  group('the mantra card', () {
    Future<ProviderContainer> pumpCard(
      WidgetTester tester, {
      String mantra = 'seed_mool_mantar', // script, name and a different transliteration
      double width = 360,
    }) async {
      tester.view.physicalSize = Size(width, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).selectMantra(mantra, 11);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MantraCard())),
        ),
      ));
      await tester.pump();
      return c;
    }

    // Mool Mantar: script / name / transliteration.
    Finder script() => find.text(_mool.script);
    Finder name() => find.text('Mool Mantar');
    Finder translit() => find.text(_mool.transliteration);
    double size(WidgetTester t, Finder f) => t.widget<Text>(f).style!.fontSize!;

    testWidgets('the default text is bigger than the old base size',
        (tester) async {
      await pumpCard(tester);
      expect(size(tester, script()), base.titleMedium!.fontSize! * 1.3);
      expect(size(tester, name()), base.titleSmall!.fontSize! * 1.3);
      expect(size(tester, translit()), base.bodySmall!.fontSize! * 1.3);
      expect(size(tester, script()), greaterThan(base.titleMedium!.fontSize!));
      expect(size(tester, name()), greaterThan(base.titleSmall!.fontSize!));
      expect(size(tester, translit()), greaterThan(base.bodySmall!.fontSize!));
    });

    testWidgets('has a small A− / A+ stepper', (tester) async {
      await pumpCard(tester);
      expect(find.text('A−'), findsOneWidget);
      expect(find.text('A+'), findsOneWidget);
      expect(find.byTooltip('Smaller mantra text'), findsOneWidget);
      expect(find.byTooltip('Larger mantra text'), findsOneWidget);
    });

    testWidgets('A+ grows script, name and transliteration together; A− '
        'shrinks them', (tester) async {
      final c = await pumpCard(tester);
      final before = [size(tester, script()), size(tester, name()), size(tester, translit())];
      await tester.tap(find.text('A+'));
      await tester.pump();
      final bigger = [size(tester, script()), size(tester, name()), size(tester, translit())];
      for (var i = 0; i < 3; i++) {
        expect(bigger[i], greaterThan(before[i]));
        expect(bigger[i] / before[i], closeTo(1.4 / 1.3, 1e-9),
            reason: 'all three scale by the same factor');
      }
      expect(scaleOf(c), closeTo(1.4, 1e-9));

      await tester.tap(find.text('A−'));
      await tester.tap(find.text('A−'));
      await tester.pump();
      final smaller = [size(tester, script()), size(tester, name()), size(tester, translit())];
      for (var i = 0; i < 3; i++) {
        expect(smaller[i], lessThan(before[i]));
      }
      expect(scaleOf(c), closeTo(1.2, 1e-9));
    });

    testWidgets('the text is exactly base x scale at every step', (tester) async {
      final c = await pumpCard(tester);
      for (var i = 0; i < 12; i++) {
        final s = scaleOf(c);
        expect(size(tester, script()), closeTo(base.titleMedium!.fontSize! * s, 1e-9));
        expect(size(tester, name()), closeTo(base.titleSmall!.fontSize! * s, 1e-9));
        await tester.tap(find.text('A+'));
        await tester.pump();
      }
    });

    testWidgets('spans about 0.8x to 2.0x, and the buttons stop at the ends',
        (tester) async {
      final c = await pumpCard(tester);
      TextButton button(String label) => tester.widget<TextButton>(
          find.ancestor(of: find.text(label), matching: find.byType(TextButton)));
      for (var i = 0; i < 10; i++) {
        await tester.tap(find.text('A+'));
        await tester.pump();
      }
      expect(scaleOf(c), 2.0);
      expect(button('A+').onPressed, isNull, reason: 'A+ is off at 2.0x');
      expect(button('A−').onPressed, isNotNull);
      expect(size(tester, script()), closeTo(base.titleMedium!.fontSize! * 2.0, 1e-9));

      for (var i = 0; i < 20; i++) {
        await tester.tap(find.text('A−'));
        await tester.pump();
      }
      expect(scaleOf(c), 0.8);
      expect(button('A−').onPressed, isNull, reason: 'A− is off at 0.8x');
      expect(button('A+').onPressed, isNotNull);
      expect(size(tester, script()), closeTo(base.titleMedium!.fontSize! * 0.8, 1e-9));
    });

    testWidgets('tapping A+ at the largest size (or A− at the smallest) does '
        'not open the Library', (tester) async {
      final c = await pumpCard(tester);
      c.read(mantraTextScaleProvider.notifier).set(2.0);
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('A+'));
        await tester.pump();
      }
      expect(find.text('Mantra library'), findsNothing,
          reason: 'a disabled A+ must not fall through to the card');
      expect(scaleOf(c), 2.0);

      c.read(mantraTextScaleProvider.notifier).set(0.8);
      await tester.pump();
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('A−'));
        await tester.pump();
      }
      expect(find.text('Mantra library'), findsNothing);
      expect(scaleOf(c), 0.8);
    });

    testWidgets('the chosen size is saved and shown again after a relaunch',
        (tester) async {
      await pumpCard(tester);
      await tester.tap(find.text('A+'));
      await tester.tap(find.text('A+'));
      await tester.pump();
      expect(AppStorage.settings.get(key), closeTo(1.5, 1e-9));

      await tester.pumpWidget(const SizedBox());
      final again = make();
      again.read(sadhanaSessionProvider.notifier).selectMantra('seed_mool_mantar', 11);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: again,
        child: const MaterialApp(home: Scaffold(body: SingleChildScrollView(child: MantraCard()))),
      ));
      await tester.pump();
      expect(size(tester, script()), closeTo(base.titleMedium!.fontSize! * 1.5, 1e-9));
    });

    testWidgets('the size is per app, not per mantra', (tester) async {
      final c = await pumpCard(tester);
      await tester.tap(find.text('A+'));
      await tester.pump();
      final chosen = size(tester, name());
      c.read(sadhanaSessionProvider.notifier).selectMantra('seed_waheguru', 108);
      await tester.pump();
      expect(size(tester, find.text('Waheguru')), closeTo(chosen, 1e-9));
    });

    testWidgets('the tags and the Library button do not scale', (tester) async {
      await pumpCard(tester);
      double tag() => tester.widget<Text>(find.text('Gurbani · Sikh')).style!.fontSize!;
      final before = tag();
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.text('A+'));
        await tester.pump();
      }
      expect(tag(), before);
      expect(find.text('Library'), findsOneWidget);
    });
  });

  group('the card grows to fit; nothing is cut off', () {
    Future<ProviderContainer> pumpCard(WidgetTester tester, String mantra,
        {double width = 360}) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).selectMantra(mantra, 108);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MantraCard())),
        ),
      ));
      await tester.pump();
      return c;
    }

    testWidgets('a bigger size makes a taller card, every step', (tester) async {
      final c = await pumpCard(tester, 'seed_gayatri');
      var last = 0.0;
      for (final s in [0.8, 1.0, 1.3, 1.6, 2.0]) {
        sizer(c).set(s);
        await tester.pump();
        final h = tester.getSize(find.byType(MantraCard)).height;
        expect(h, greaterThan(last), reason: 'at ${s}x');
        last = h;
      }
    });

    for (final id in ['seed_om_namah_shivaya', 'seed_gayatri', 'seed_waheguru', 'seed_mool_mantar']) {
      for (final width in [320.0, 360.0, 411.0]) {
        testWidgets('$id at $width dp wide: no overflow at any size',
            (tester) async {
          final c = await pumpCard(tester, id, width: width);
          for (final s in [0.8, 1.3, 2.0]) {
            sizer(c).set(s);
            await tester.pump();
            expect(tester.takeException(), isNull, reason: '$id at ${s}x');
          }
        });
      }
    }

    testWidgets('the text wraps to more lines instead of being truncated',
        (tester) async {
      final c = await pumpCard(tester, 'seed_gayatri');
      sizer(c).set(2.0);
      await tester.pump();
      // The mantra's own text (script, name, transliteration): never limited.
      for (final f in [
        find.textContaining('ॐ भूर्भुवः'),
        find.text('Gayatri Mantra'),
        find.textContaining('Om Bhur Bhuvah'),
      ]) {
        final t = tester.widget<Text>(f);
        expect(t.maxLines, isNull, reason: '"${t.data}" is never line-limited');
        expect(t.overflow, isNot(TextOverflow.ellipsis),
            reason: '"${t.data}" is never cut with an ellipsis');
      }
      final script = tester.getSize(find.textContaining('ॐ भूर्भुवः'));
      expect(script.width, lessThanOrEqualTo(360));
      expect(script.height, greaterThan(100), reason: 'many lines, all shown');
    });

    testWidgets('the whole verse is present at the largest size', (tester) async {
      final c = await pumpCard(tester, 'seed_gayatri');
      sizer(c).set(2.0);
      await tester.pump();
      expect(find.textContaining('प्रचोदयात्'), findsOneWidget,
          reason: 'the end of the verse is not cut off');
    });

    testWidgets('the card contains its content: it is at least as tall as the text',
        (tester) async {
      final c = await pumpCard(tester, 'seed_gayatri');
      sizer(c).set(2.0);
      await tester.pump();
      final card = tester.getSize(find.byType(MantraCard)).height;
      final text = tester.getSize(find.textContaining('ॐ भूर्भुवः')).height +
          tester.getSize(find.text('Gayatri Mantra')).height;
      expect(card, greaterThan(text));
    });

    testWidgets('the controls stay usable at the largest size', (tester) async {
      final c = await pumpCard(tester, 'seed_gayatri');
      sizer(c).set(2.0);
      await tester.pump();
      expect(find.text('A−'), findsOneWidget);
      await tester.tap(find.text('A−'));
      await tester.pump();
      expect(scaleOf(c), closeTo(1.9, 1e-9));
      expect(find.text('Library'), findsOneWidget);
    });
  });

  group('pinch to zoom', () {
    Future<ProviderContainer> pumpCard(WidgetTester tester) async {
      tester.view.physicalSize = const Size(411, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: MantraCard())),
        ),
      ));
      await tester.pump();
      return c;
    }

    /// Two fingers on the card, [from] apart, moved to [to] apart.
    Future<(TestGesture, TestGesture)> pinch(
        WidgetTester tester, double from, double to,
        {bool lift = false}) async {
      final centre = tester.getCenter(find.byType(MantraCard));
      final a = await tester.startGesture(centre - Offset(from / 2, 0), pointer: 1);
      final b = await tester.startGesture(centre + Offset(from / 2, 0), pointer: 2);
      await a.moveTo(centre - Offset(to / 2, 0));
      await b.moveTo(centre + Offset(to / 2, 0));
      await tester.pump();
      if (lift) {
        await a.up();
        await b.up();
        await tester.pump();
      }
      return (a, b);
    }

    testWidgets('spreading two fingers makes the text bigger', (tester) async {
      final c = await pumpCard(tester);
      await pinch(tester, 80, 120, lift: true); // x1.5 of 1.3
      expect(scaleOf(c), closeTo(1.95, 1e-9));
    });

    testWidgets('pinching in makes it smaller', (tester) async {
      final c = await pumpCard(tester);
      await pinch(tester, 120, 80, lift: true); // x0.667 of 1.3
      expect(scaleOf(c), closeTo(0.85, 1e-9));
    });

    testWidgets('it follows the fingers live and is clamped at both ends',
        (tester) async {
      final c = await pumpCard(tester);
      final (a, b) = await pinch(tester, 60, 400);
      expect(scaleOf(c), 2.0, reason: 'a huge spread stops at 2.0x');
      await a.up();
      await b.up();
      await tester.pump();
      await pinch(tester, 400, 20, lift: true);
      expect(scaleOf(c), 0.8, reason: 'a tiny pinch stops at 0.8x');
    });

    testWidgets('the text on the card really changes while pinching',
        (tester) async {
      await pumpCard(tester);
      double title() => tester.widget<Text>(find.text('Om Namah Shivaya')).style!.fontSize!;
      final before = title();
      final (a, b) = await pinch(tester, 80, 130);
      expect(title(), greaterThan(before));
      await a.up();
      await b.up();
    });

    testWidgets('the size is saved when the fingers lift, not on every frame',
        (tester) async {
      final c = await pumpCard(tester);
      final (a, b) = await pinch(tester, 80, 120);
      expect(scaleOf(c), closeTo(1.95, 1e-9));
      expect(AppStorage.settings.get(key), isNull, reason: 'still pinching');
      await a.up();
      await b.up();
      await tester.pump();
      expect(AppStorage.settings.get(key), closeTo(1.95, 1e-9));
    });

    testWidgets('lifting one finger ends the pinch and saves', (tester) async {
      final c = await pumpCard(tester);
      final (a, b) = await pinch(tester, 80, 100);
      await a.up();
      await tester.pump();
      expect(AppStorage.settings.get(key), isNotNull);
      final saved = scaleOf(c);
      // The remaining finger moving does nothing.
      await b.moveBy(const Offset(50, 0));
      await tester.pump();
      expect(scaleOf(c), saved);
      await b.up();
    });

    testWidgets('one finger never changes the size, and a tap still opens the '
        'library', (tester) async {
      final c = await pumpCard(tester);
      final start = scaleOf(c);
      final g = await tester.startGesture(tester.getCenter(find.byType(MantraCard)));
      await g.moveBy(const Offset(120, 0));
      await g.moveBy(const Offset(-200, 0));
      await g.up();
      await tester.pump();
      expect(scaleOf(c), start);
      expect(AppStorage.settings.get(key), isNull);

      await tester.tap(find.text('Om Namah Shivaya'));
      await tester.pumpAndSettle();
      expect(find.text('Mantra library'), findsOneWidget,
          reason: 'a plain tap on the card is unchanged');
    });

    testWidgets('a pinch away from the card does nothing', (tester) async {
      final c = await pumpCard(tester);
      final away = Offset(200, 1200);
      final a = await tester.startGesture(away - const Offset(40, 0), pointer: 1);
      final b = await tester.startGesture(away + const Offset(40, 0), pointer: 2);
      await a.moveBy(const Offset(-60, 0));
      await b.moveBy(const Offset(60, 0));
      await tester.pump();
      expect(scaleOf(c), defaultMantraTextScale);
      await a.up();
      await b.up();
    });

    testWidgets('a second pinch starts from the size you have then',
        (tester) async {
      final c = await pumpCard(tester);
      await pinch(tester, 80, 120, lift: true); // 1.95
      await pinch(tester, 120, 60, lift: true); // x0.5 of 1.95
      expect(scaleOf(c), closeTo(1.0, 0.051));
    });
  });

  group('the Sadhana screen makes room for the card', () {
    Future<ProviderContainer> pumpScreen(
        WidgetTester tester, double width, double height,
        {String mantra = 'seed_mool_mantar'}) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).selectMantra(mantra, 11);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: const MaterialApp(home: Scaffold(body: SadhanaScreen())),
      ));
      await tester.pump();
      await tester.pump();
      return c;
    }

    double ringHeight(WidgetTester t) => t.getSize(find.byType(ProgressRing)).height;

    // Om Namah Shivaya: since P4.3-8 the Mool Mantar is the full Mool Mantar,
    // whose card at the largest size is taller than this whole screen (see
    // "the full Mool Mantar at the largest size" below).
    testWidgets('bigger text: taller card, smaller ring', (tester) async {
      final c = await pumpScreen(tester, 360, 800,
          mantra: 'seed_om_namah_shivaya');
      sizer(c).set(0.8);
      await tester.pump();
      await tester.pump();
      final smallText = ringHeight(tester);
      final smallCard = tester.getSize(find.byType(MantraCard)).height;

      sizer(c).set(2.0);
      await tester.pump();
      await tester.pump();
      final bigCard = tester.getSize(find.byType(MantraCard)).height;
      final bigRing = ringHeight(tester);

      expect(bigCard, greaterThan(smallCard));
      expect(bigRing, lessThan(smallText), reason: 'the ring made room');
      expect(bigRing, greaterThanOrEqualTo(120), reason: 'but never below its minimum');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a smaller card gives the ring its room back', (tester) async {
      final c = await pumpScreen(tester, 360, 800,
          mantra: 'seed_om_namah_shivaya');
      sizer(c).set(2.0);
      await tester.pump();
      await tester.pump();
      final big = ringHeight(tester);
      sizer(c).set(0.8);
      await tester.pump();
      await tester.pump();
      expect(ringHeight(tester), greaterThan(big));
    });

    testWidgets('the full Mool Mantar at the largest size: nothing overflows, '
        'the ring keeps its minimum and is a scroll away', (tester) async {
      final c = await pumpScreen(tester, 360, 800);
      sizer(c).set(2.0);
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(find.text(_mool.script), findsOneWidget, reason: 'never cut');
      final ring = find.byType(ProgressRing);
      await tester.scrollUntilVisible(ring, 200,
          scrollable: find.byType(Scrollable).first);
      await tester.pump();
      expect(tester.getSize(ring).height, greaterThanOrEqualTo(120));
    });

    testWidgets('the ring never overflows or vanishes at any size or phone',
        (tester) async {
      for (final (w, h) in [(320.0, 568.0), (360.0, 640.0), (411.0, 915.0)]) {
        final c = await pumpScreen(tester, w, h, mantra: 'seed_waheguru');
        for (final s in [0.8, 1.3, 2.0]) {
          sizer(c).set(s);
          await tester.pump();
          await tester.pump();
          expect(tester.takeException(), isNull, reason: '${w}x$h at ${s}x');
          expect(ringHeight(tester), inInclusiveRange(120, 240));
        }
        await tester.pumpWidget(const SizedBox());
      }
    });

    testWidgets('with a very tall card the page scrolls (one finger on the '
        'card still scrolls it)', (tester) async {
      final c = await pumpScreen(tester, 360, 640, mantra: 'seed_gayatri');
      sizer(c).set(2.0);
      await tester.pump();
      await tester.pump();
      final card = find.byType(MantraCard);
      final before = tester.getTopLeft(card).dy;
      // A finger on the visible part of the card (its centre is off-screen).
      await tester.dragFrom(const Offset(180, 300), const Offset(0, -200));
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(card).dy, lessThan(before - 100),
          reason: 'the page moved up under the finger');
      expect(scaleOf(c), 2.0, reason: 'and the drag did not change the text size');
    });

    testWidgets('the card is measured again when the mantra changes',
        (tester) async {
      final c = await pumpScreen(tester, 360, 800, mantra: 'seed_waheguru');
      final short = ringHeight(tester);
      c.read(sadhanaSessionProvider.notifier).selectMantra('seed_gayatri', 108);
      await tester.pump();
      await tester.pump();
      await tester.pump();
      // The long verse makes a tall card, so the ring (if built) is smaller.
      await tester.scrollUntilVisible(find.byType(ProgressRing), 100,
          scrollable: find.byType(Scrollable).first);
      expect(ringHeight(tester), lessThan(short));
    });
  });

  group('Focus mode uses the same size', () {
    Future<ProviderContainer> openFocus(WidgetTester tester,
        {String mantra = 'seed_mool_mantar', double width = 411, double height = 915}) async {
      tester.view.physicalSize = Size(width, height);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).selectMantra(mantra, 11);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => openFocusMode(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return c;
    }

    double focusSize(WidgetTester t, String text) =>
        t.widget<Text>(find.text(text)).style!.fontSize!;

    testWidgets('script, name and transliteration are drawn at base x scale',
        (tester) async {
      await openFocus(tester);
      final s = defaultMantraTextScale;
      expect(focusSize(tester, _mool.script), closeTo(base.headlineMedium!.fontSize! * s, 1e-9));
      expect(focusSize(tester, 'Mool Mantar'), closeTo(base.titleMedium!.fontSize! * s, 1e-9));
      expect(focusSize(tester, _mool.transliteration), closeTo(base.bodyMedium!.fontSize! * s, 1e-9));
    });

    testWidgets('a size chosen on the card is what Focus shows', (tester) async {
      tester.view.physicalSize = const Size(411, 915);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final c = make();
      c.read(sadhanaSessionProvider.notifier).selectMantra('seed_mool_mantar', 11);
      c.read(mantraTextScaleProvider.notifier).set(1.8);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: c,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(onPressed: () => openFocusMode(context), child: const Text('open')),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(focusSize(tester, 'Mool Mantar'), closeTo(base.titleMedium!.fontSize! * 1.8, 1e-9));
    });

    testWidgets('a saved size is used when Focus opens after a relaunch',
        (tester) async {
      AppStorage.settings.put(key, 1.6);
      await openFocus(tester);
      expect(focusSize(tester, 'Mool Mantar'), closeTo(base.titleMedium!.fontSize! * 1.6, 1e-9));
    });

    testWidgets('bigger size, bigger text in Focus (within the space)',
        (tester) async {
      final c = await openFocus(tester);
      final before = focusSize(tester, 'Mool Mantar');
      c.read(mantraTextScaleProvider.notifier).set(2.0);
      await tester.pump();
      expect(focusSize(tester, 'Mool Mantar'), greaterThan(before));
    });

    testWidgets('a long verse wraps to the screen and fits, at every size',
        (tester) async {
      final c = await openFocus(tester,
          mantra: 'seed_gayatri', width: 360, height: 640);
      for (final s in [0.8, 1.3, 2.0]) {
        c.read(mantraTextScaleProvider.notifier).set(s);
        await tester.pump();
        expect(tester.takeException(), isNull, reason: '${s}x');
        final verse = tester.getRect(find.textContaining('ॐ भूर्भुवः'));
        expect(verse.left, greaterThanOrEqualTo(0), reason: '${s}x');
        expect(verse.right, lessThanOrEqualTo(360), reason: '${s}x: within the screen');
      }
    });

    testWidgets('Focus still counts taps and shows the controls at 2.0x',
        (tester) async {
      final c = await openFocus(tester);
      c.read(mantraTextScaleProvider.notifier).set(2.0);
      await tester.pump();
      expect(find.text('Hold to exit'), findsOneWidget);
      await tester.tapAt(const Offset(60, 500));
      await tester.pump();
      expect(c.read(sadhanaSessionProvider).count, 1);
    });
  });
}

/// The built-in Mool Mantar (its text changed in P4.3-8: the full Mool Mantar).
final _mool = seedMantras.firstWhere((m) => m.id == 'seed_mool_mantar');
