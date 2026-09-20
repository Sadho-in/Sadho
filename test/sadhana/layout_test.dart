import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/count_scope_control.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mantra_card.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_status.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/progress_ring.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/rhythm_pace_editor.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/sankalp_field.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/target_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/completion_settings_card.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/voice_panel.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

/// Phone screens (logical px), smallest to large. The test font draws every
/// glyph as a full-width square, so these are pessimistic for text width.
const _phones = <(String, Size)>[
  ('small 360x640', Size(360, 640)),
  ('common 360x740', Size(360, 740)),
  ('tall 390x844', Size(390, 844)),
  ('large 411x915', Size(411, 915)),
];

void main() {
  late ProviderContainer container;

  setUp(() {
    resetStorage();
    seedTrainedVoice();
  });

  Future<void> openShell(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    container = ProviderContainer(overrides: testOverrides());
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: AppShell()),
    ));
    await tester.pump();
  }

  SadhanaSessionNotifier notifier() =>
      container.read(sadhanaSessionProvider.notifier);

  /// The bottom of the visible body: the top of the navigation bar.
  double fold(WidgetTester tester) =>
      tester.getTopLeft(find.byType(NavigationBar)).dy;

  Rect rect(WidgetTester tester, Finder f) => tester.getRect(f.first);

  group('above the fold (no scrolling, whole app chrome included)', () {
    for (final (name, size) in _phones) {
      for (final mode in [CountMode.tap, CountMode.rhythm, CountMode.voice]) {
        testWidgets('$name, ${mode.name} mode: everything required fits',
            (tester) async {
          await openShell(tester, size);
          notifier().setMode(mode);
          await tester.pumpAndSettle();
          final bottom = fold(tester);

          void fits(String what, Finder f) {
            expect(f, findsWidgets, reason: what);
            final r = rect(tester, f);
            expect(r.bottom, lessThanOrEqualTo(bottom + 0.5),
                reason: '$what ends at ${r.bottom}, fold is at $bottom');
            expect(r.top, greaterThanOrEqualTo(kToolbarHeight - 0.5),
                reason: '$what is not under the app bar');
            expect(r.left, greaterThanOrEqualTo(0), reason: what);
            expect(r.right, lessThanOrEqualTo(size.width + 0.5), reason: what);
          }

          fits('1. mantra card', find.byType(MantraCard));
          fits('   its Library button', find.text('Library'));
          fits('2. Count toggle', find.byType(CountScopeControl));
          fits('3. progress ring', find.byType(ProgressRing));
          fits('4. Reset', find.byTooltip('Reset'));
          fits('   − undo', find.byTooltip('Remove one'));
          fits('   + count', find.byTooltip('Add one'));
          fits('   Focus', find.byTooltip('Focus mode'));
          if (mode != CountMode.tap) {
            fits('5. Start button', find.text('Start'));
          }
          fits('   mode status line', find.byType(ModeStatusLine));
        });
      }
    }

    testWidgets('a time target in Tap mode also fits with its Start button',
        (tester) async {
      await openShell(tester, _phones.first.$2);
      notifier().setTargetType(TargetType.time);
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      expect(rect(tester, find.text('Start')).bottom,
          lessThanOrEqualTo(fold(tester)));
    });

    testWidgets('a running session (Pause) and Resume also fit', (tester) async {
      await openShell(tester, _phones.first.$2);
      notifier()
        ..setMode(CountMode.rhythm)
        ..increment()
        ..toggleRunning();
      await tester.pump();
      expect(find.text('Pause'), findsOneWidget);
      expect(rect(tester, find.text('Pause')).bottom,
          lessThanOrEqualTo(fold(tester)));
      notifier().toggleRunning();
      await tester.pump();
      expect(find.text('Resume'), findsOneWidget);
      expect(rect(tester, find.text('Resume')).bottom,
          lessThanOrEqualTo(fold(tester)));
    });

    testWidgets('a long mantra (Gayatri) does not push anything off screen',
        (tester) async {
      await openShell(tester, _phones.first.$2);
      notifier().selectMantra('seed_gayatri', 108);
      notifier().setMode(CountMode.rhythm);
      await tester.pumpAndSettle();
      expect(find.text('Start'), findsOneWidget);
      expect(rect(tester, find.text('Start')).bottom,
          lessThanOrEqualTo(fold(tester)));
      expect(tester.takeException(), isNull);
    });

    testWidgets('a running Voice session with a result line still fits',
        (tester) async {
      await openShell(tester, _phones.first.$2);
      notifier()
        ..setMode(CountMode.voice)
        ..toggleRunning();
      await tester.pump();
      await tester.pump();
      // No live result yet; the status stays one line.
      expect(rect(tester, find.byType(ModeStatusLine)).bottom,
          lessThanOrEqualTo(fold(tester)));
      notifier().pause();
    });
  });

  group('the order on the screen', () {
    testWidgets('mantra card, then the toggle, then the ring, then the actions, '
        'then Start', (tester) async {
      await openShell(tester, _phones[1].$2);
      notifier().setMode(CountMode.rhythm);
      await tester.pumpAndSettle();
      final card = rect(tester, find.byType(MantraCard));
      final toggle = rect(tester, find.byType(CountScopeControl));
      final ring = rect(tester, find.byType(ProgressRing));
      final actions = rect(tester, find.byTooltip('Add one'));
      final start = rect(tester, find.text('Start'));
      expect(card.bottom, lessThanOrEqualTo(toggle.top), reason: 'card > toggle');
      expect(toggle.bottom, lessThanOrEqualTo(ring.top), reason: 'toggle > ring');
      expect(ring.bottom, lessThanOrEqualTo(actions.top + 0.5),
          reason: 'actions are directly under the ring');
      expect(actions.bottom, lessThanOrEqualTo(start.top + 0.5),
          reason: 'Start is under the actions');
    });

    testWidgets('the four action controls are ONE row, left to right: Reset, '
        '−, +, Focus', (tester) async {
      for (final (_, size) in _phones) {
        await openShell(tester, size);
        final r = [
          for (final t in ['Reset', 'Remove one', 'Add one', 'Focus mode'])
            rect(tester, find.byTooltip(t)),
        ];
        final centreY = r.map((e) => e.center.dy).toList();
        for (final y in centreY) {
          expect(y, closeTo(centreY.first, 1.0), reason: 'same line at $size');
        }
        for (var i = 1; i < r.length; i++) {
          expect(r[i].left, greaterThanOrEqualTo(r[i - 1].right - 0.5),
              reason: 'in order and not overlapping at $size');
        }
      }
    });

    testWidgets('the ring shrinks on a short phone and grows on a tall one',
        (tester) async {
      await openShell(tester, _phones.first.$2);
      final small = rect(tester, find.byType(ProgressRing)).height;
      await openShell(tester, _phones.last.$2);
      final big = rect(tester, find.byType(ProgressRing)).height;
      expect(small, lessThan(big));
      expect(small, greaterThanOrEqualTo(120));
      expect(big, lessThanOrEqualTo(240));
    });
  });

  group('compact pieces are actually small', () {
    testWidgets('the mantra card is a small card, not a big padded one',
        (tester) async {
      await openShell(tester, _phones[1].$2);
      final card = rect(tester, find.byType(MantraCard));
      expect(card.height, lessThan(125), reason: 'was ~200 before');
      final bigRing = rect(tester, find.byType(ProgressRing)).height;
      expect(card.height, lessThan(bigRing));
    });

    testWidgets('the mantra card shows the name, script, transliteration, '
        'tradition, trained tag and Library', (tester) async {
      await openShell(tester, _phones[3].$2);
      notifier().selectMantra('seed_om_namah_shivaya', 108);
      await tester.pump();
      final card = find.byType(MantraCard);
      Finder inCard(Finder f) => find.descendant(of: card, matching: f);
      expect(inCard(find.text('Om Namah Shivaya')), findsWidgets,
          reason: 'name (and its identical transliteration is not repeated)');
      expect(inCard(find.text('ॐ नमः शिवाय')), findsOneWidget);
      expect(inCard(find.text('Sanskrit · Hindu')), findsOneWidget);
      expect(inCard(find.text('Voice trained')), findsOneWidget);
      expect(inCard(find.text('Library')), findsOneWidget);
    });

    testWidgets('the transliteration shows when it differs from the name',
        (tester) async {
      await openShell(tester, _phones[3].$2);
      notifier().selectMantra('seed_mool_mantar', 11);
      await tester.pump();
      expect(find.descendant(of: find.byType(MantraCard), matching: find.text('Ik Onkar Sat Naam')),
          findsOneWidget);
      expect(find.descendant(of: find.byType(MantraCard), matching: find.text('Voice not trained')),
          findsOneWidget);
    });

    testWidgets('the Count toggle is one slim line', (tester) async {
      await openShell(tester, _phones[1].$2);
      expect(rect(tester, find.byType(CountScopeControl)).height, lessThan(44));
    });

    testWidgets('the Library button opens the library', (tester) async {
      await openShell(tester, _phones[1].$2);
      await tester.tap(find.text('Library'));
      await tester.pumpAndSettle();
      expect(find.text('Mantra library'), findsOneWidget);
    });
  });

  group('everything else is below, in the scroll area', () {
    testWidgets('mode selector, target, vibration, ringtone and sankalp all '
        'come after the top group, and scroll into view', (tester) async {
      await openShell(tester, _phones.first.$2);
      notifier().setMode(CountMode.rhythm);
      await tester.pumpAndSettle();
      final startBottom = rect(tester, find.text('Start')).bottom;
      final fold0 = fold(tester);
      for (final f in [
        find.byType(ModeSection),
        find.byType(TargetSection),
        find.byType(CompletionSettingsCard),
        find.byType(SankalpField),
      ]) {
        // Not built yet (far below), or laid out after the Start button.
        if (f.evaluate().isNotEmpty) {
          expect(rect(tester, f).top, greaterThanOrEqualTo(startBottom - 0.5),
              reason: 'below the top group');
        }
      }
      expect(find.byType(SankalpField), findsNothing,
          reason: 'the last card is far below the fold, not even built');
      expect(fold0, greaterThan(startBottom));
      // ... and each can be scrolled to.
      for (final t in ['Counting mode', 'Target', 'Completion', 'Sankalp']) {
        await tester.scrollUntilVisible(find.text(t), 200,
            scrollable: find.byType(Scrollable).first);
        expect(find.text(t), findsOneWidget, reason: t);
      }
      expect(find.text('Vibration'), findsOneWidget);
      expect(find.text('Ringtone'), findsOneWidget);
    });

    testWidgets('the order below: mode, target, vibration/ringtone, sankalp',
        (tester) async {
      await openShell(tester, _phones[3].$2);
      tester.view.physicalSize = const Size(411, 3000);
      await tester.pumpAndSettle();
      double top(Finder f) => tester.getTopLeft(f.first).dy;
      final order = [
        top(find.byType(ModeSection)),
        top(find.byType(TargetSection)),
        top(find.byType(CompletionSettingsCard)),
        top(find.byType(SankalpField)),
      ];
      expect(order, [...order]..sort());
    });

    testWidgets('the Count toggle is no longer inside the mode card',
        (tester) async {
      await openShell(tester, _phones[3].$2);
      tester.view.physicalSize = const Size(411, 3000);
      await tester.pumpAndSettle();
      expect(
          find.descendant(
              of: find.byType(ModeSection),
              matching: find.byType(CountScopeControl)),
          findsNothing);
      expect(find.byType(CountScopeControl), findsOneWidget);
    });
  });

  group('the mode selector: four round icon buttons in ONE row', () {
    Future<void> tall(WidgetTester tester) async {
      await openShell(tester, _phones[3].$2);
      tester.view.physicalSize = const Size(411, 3000);
      await tester.pumpAndSettle();
    }

    testWidgets('Tap, Voice, Rhythm and Mala, all four, in one line',
        (tester) async {
      await tall(tester);
      final labels = ['Tap', 'Voice', 'Rhythm', 'Mala'];
      final r = [
        for (final l in labels)
          tester.getRect(find.descendant(
              of: find.byType(ModeSection), matching: find.text(l))),
      ];
      expect(r.length, 4);
      for (final e in r) {
        expect(e.center.dy, closeTo(r.first.center.dy, 1.0),
            reason: 'all four labels on one line');
      }
      for (var i = 1; i < r.length; i++) {
        expect(r[i].left, greaterThan(r[i - 1].right - 0.5),
            reason: 'left to right, no wrapping onto a second row');
      }
    });

    testWidgets('each button is a circle', (tester) async {
      await tall(tester);
      final circles = find.descendant(
        of: find.byType(ModeSection),
        matching: find.byWidgetPredicate((w) =>
            w is AnimatedContainer &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle),
      );
      expect(circles, findsNWidgets(4));
      for (final e in circles.evaluate()) {
        final size = tester.getSize(find.byWidget(e.widget));
        expect(size.width, size.height, reason: 'round, not oval');
      }
    });

    testWidgets('the chosen mode is highlighted and tapping selects it',
        (tester) async {
      await tall(tester);
      for (final (label, mode) in [
        ('Rhythm', CountMode.rhythm),
        ('Mala', CountMode.mala),
        ('Voice', CountMode.voice),
        ('Tap', CountMode.tap),
      ]) {
        await tester.tap(find.descendant(
            of: find.byType(ModeSection), matching: find.text(label)));
        await tester.pumpAndSettle();
        expect(container.read(sadhanaSessionProvider).mode, mode);
      }
    });

    testWidgets('Voice carries a Beta tag', (tester) async {
      await tall(tester);
      expect(
          find.descendant(
              of: find.byType(ModeSection), matching: find.text('BETA')),
          findsOneWidget);
    });

    testWidgets('the buttons are labelled for screen readers', (tester) async {
      await tall(tester);
      final handle = tester.ensureSemantics();
      for (final l in ['Tap mode', 'Voice mode', 'Rhythm mode', 'Mala mode']) {
        expect(find.bySemanticsLabel(l), findsWidgets, reason: l);
      }
      handle.dispose();
    });
  });

  group('each mode\'s own settings show only for that mode', () {
    Future<void> tall(WidgetTester tester) async {
      await openShell(tester, _phones[3].$2);
      tester.view.physicalSize = const Size(411, 3000);
      await tester.pumpAndSettle();
    }

    testWidgets('Rhythm pace: only under Rhythm; never "every 2s" elsewhere',
        (tester) async {
      await tall(tester);
      for (final mode in CountMode.values) {
        notifier().setMode(mode);
        await tester.pumpAndSettle();
        final shown = find.byType(RhythmPaceEditor).evaluate().isNotEmpty;
        expect(shown, mode == CountMode.rhythm, reason: mode.name);
        if (mode != CountMode.rhythm) {
          expect(find.textContaining('every 2s'), findsNothing,
              reason: 'no pace text anywhere under ${mode.name}');
          expect(find.textContaining('Pace:'), findsNothing);
          expect(find.textContaining('Rhythm pace'), findsNothing);
        } else {
          expect(find.textContaining('every 2s'), findsWidgets);
        }
      }
    });

    testWidgets('Voice panel: only under Voice', (tester) async {
      await tall(tester);
      for (final mode in CountMode.values) {
        notifier().setMode(mode);
        await tester.pumpAndSettle();
        final shown = find.byType(VoicePanel).evaluate().isNotEmpty;
        expect(shown, mode == CountMode.voice, reason: mode.name);
        expect(find.text('Sensitivity').evaluate().isNotEmpty,
            mode == CountMode.voice,
            reason: 'the slider belongs to the Voice panel');
      }
    });

    testWidgets('the Voice panel has trained status, Train/Re-train/Clear, '
        'Sensitivity and Beta', (tester) async {
      await tall(tester);
      notifier().setMode(CountMode.voice);
      await tester.pumpAndSettle();
      final panel = find.byType(VoicePanel);
      Finder inPanel(Finder f) => find.descendant(of: panel, matching: f);
      expect(inPanel(find.text('Voice trained')), findsOneWidget);
      expect(inPanel(find.text('Add more samples')), findsOneWidget);
      expect(inPanel(find.text('Re-train')), findsOneWidget);
      expect(inPanel(find.text('Clear training')), findsOneWidget);
      expect(inPanel(find.text('Sensitivity')), findsOneWidget);
      expect(inPanel(find.text('Strict')), findsOneWidget);
      expect(inPanel(find.text('Lenient')), findsOneWidget);
      expect(inPanel(find.text('BETA')), findsOneWidget);
    });

    testWidgets('an untrained mantra: Train voice, and no Re-train/Clear',
        (tester) async {
      await tall(tester);
      notifier().selectMantra('seed_gayatri', 108);
      notifier().setMode(CountMode.voice);
      await tester.pumpAndSettle();
      final panel = find.byType(VoicePanel);
      Finder inPanel(Finder f) => find.descendant(of: panel, matching: f);
      expect(inPanel(find.text('Voice not trained')), findsOneWidget);
      expect(inPanel(find.text('Train voice')), findsOneWidget);
      expect(inPanel(find.text('Add more samples')), findsNothing);
      expect(inPanel(find.text('Re-train')), findsNothing);
      expect(inPanel(find.text('Clear training')), findsNothing);
    });

    testWidgets('the panel hides "Add more samples" once 7 are saved',
        (tester) async {
      seedTrainedVoice('seed_om_namah_shivaya', 7);
      await tall(tester);
      notifier().setMode(CountMode.voice);
      await tester.pumpAndSettle();
      expect(find.text('Add more samples'), findsNothing);
      expect(find.text('Re-train'), findsOneWidget);
    });
  });
}
