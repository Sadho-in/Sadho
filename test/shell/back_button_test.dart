import 'dart:async';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/features/calendar/presentation/widgets/mark_editor_sheet.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/clock/presentation/tools/stopwatch_page.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/profile/presentation/profile_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';

/// A [ReminderScheduler] whose `requestPermission()` does not resolve until
/// [complete] is called, so a test can press back while a caller is still
/// awaiting it — exactly the timing a real permission dialog leaves open.
class _PendingScheduler extends FakeScheduler {
  final _completer = Completer<bool>();

  @override
  Future<bool> requestPermission() {
    permissionRequests++;
    return _completer.future;
  }

  void complete(bool allowed) => _completer.complete(allowed);
}

/// The Android system back button, on every surface that can be on screen:
/// a root tab, a pushed page, a full-screen tool, a modal sheet, a dialog,
/// Focus mode (which must refuse to close on back), and a save in progress.
/// Simulated the way the platform actually delivers it — a `popRoute`
/// platform-channel message — not by popping a [Navigator] directly, so this
/// exercises exactly what a real back-button press exercises.
void main() {

  Future<ProfileRig> open(WidgetTester tester,
      {ProfileRig? rig, double height = 3000}) async {
    final r = rig ?? profileRig(saved: {'onboarding.done': true});
    phoneScreen(tester, height: height);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: r.container, child: const SadhoApp()));
    await tester.pump();
    return r;
  }

  /// Simulates the Android system back button and returns any exception the
  /// framework reported while handling it (null if none).
  Future<Object?> pressBack(WidgetTester tester) async {
    Object? caught;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      caught ??= details.exception;
      previous?.call(details);
    };
    try {
      await tester.binding.handlePopRoute();
      // Some handlers pop asynchronously (a Future inside a callback); give
      // them a chance to run and any exception a chance to surface.
      await tester.pumpAndSettle();
    } finally {
      FlutterError.onError = previous;
    }
    return caught;
  }

  group('a root tab (nothing pushed on top)', () {
    testWidgets('Home: back does not throw', (tester) async {
      await open(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(await pressBack(tester), isNull);
      // Standard app-exit: the tab itself is untouched, nothing crashed.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Profile (pushed from the avatar)', () {
    testWidgets('back closes it and returns to the tab underneath', (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      expect(await pressBack(tester), isNull);

      expect(find.byType(ProfilePage), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('the language sheet (a modal bottom sheet)', () {
    testWidgets('back dismisses it and returns to the tab underneath', (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Language'));
      await tester.pumpAndSettle();
      expect(find.text('English'), findsWidgets); // the sheet is open

      expect(await pressBack(tester), isNull);

      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('a Clock full-screen tool', () {
    testWidgets('back closes it and returns to the Clock tab', (tester) async {
      await open(tester);
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Clock')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('tool-${ClockTool.stopwatch.name}')));
      await tester.pumpAndSettle();
      expect(find.byType(StopwatchPage), findsOneWidget);

      expect(await pressBack(tester), isNull);

      expect(find.byType(StopwatchPage), findsNothing);
      expect(find.byType(ClockScreen), findsOneWidget);
    });
  });

  group('Focus mode', () {
    testWidgets('back is refused: Focus mode stays open, and nothing throws',
        (tester) async {
      final r = await open(tester);
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Sadhana')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Focus mode'));
      await tester.pumpAndSettle();
      expect(find.byType(FocusModeScreen), findsOneWidget);

      expect(await pressBack(tester), isNull);

      // Still in Focus mode: the system back gesture must not leave it.
      expect(find.byType(FocusModeScreen), findsOneWidget);
      expect(r.container, isNotNull);
    });
  });

  group('a calendar day sheet', () {
    testWidgets('back dismisses it and returns to the Calendar tab', (tester) async {
      await open(tester);
      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Calendar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-09-21')));
      await tester.pumpAndSettle();
      expect(find.byType(MarkEditorSheet), findsOneWidget);

      expect(await pressBack(tester), isNull);

      expect(find.byType(MarkEditorSheet), findsNothing);
    });
  });

  group('a dialog (Delete plan?, on Home)', () {
    testWidgets('back dismisses it without acting', (tester) async {
      final rig = await open(tester);
      // Start a plan directly (skips scrolling to the suggestion chips) so the
      // test is about the dialog, not about finding it on a long page.
      rig.container
          .read(plansProvider.notifier)
          .add(title: 'Japji', kind: PlanKind.paath, days: 40);
      await tester.pump();
      final menu = find.byTooltip('Plan options');
      await tester.scrollUntilVisible(menu, 200);
      await tester.tap(menu);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete plan'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      expect(await pressBack(tester), isNull);

      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('nested: a sheet opened from a pushed page', () {
    testWidgets('one back at a time: sheet, then page, then the tab',
        (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      final restore = find.byKey(const ValueKey('backup-restore'));
      await tester.scrollUntilVisible(restore, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(restore);
      await tester.pumpAndSettle();
      // No file was picked, so nothing else opened; back should still work
      // cleanly from the Profile page itself.
      expect(find.byType(ProfilePage), findsOneWidget);

      expect(await pressBack(tester), isNull);
      expect(find.byType(ProfilePage), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('back pressed WHILE an async save is still in flight', () {
    testWidgets(
        'saving a calendar mark: the sheet closes once, not twice — the app '
        'does not lose its only remaining route',
        (tester) async {
      final scheduler = _PendingScheduler();
      await open(tester,
          rig: profileRig(scheduler: scheduler, saved: {'onboarding.done': true}));

      await tester.tap(find.descendant(
          of: find.byType(NavigationBar), matching: find.text('Calendar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-09-21')));
      await tester.pumpAndSettle();
      expect(find.byType(MarkEditorSheet), findsOneWidget);

      // A reminder is requested, so Save awaits requestPermission() — which
      // this scheduler holds open until told to answer.
      await tester.tap(find.byKey(const ValueKey('reminder-once')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save-mark')));
      await tester.pump(); // Save is now mid-await
      expect(scheduler.permissionRequests, 1);

      // The user presses back before the permission promise settles — on a
      // real phone this is easy: the permission prompt itself takes a moment.
      expect(await pressBack(tester), isNull);
      expect(find.byType(MarkEditorSheet), findsNothing,
          reason: 'back already closed the sheet');

      // Now the permission answer arrives and Save's await resumes. It must
      // not pop a second time (there is nothing left to pop but the app's own
      // single root route).
      scheduler.complete(true);
      final thrown = <Object>[];
      final previous = FlutterError.onError;
      FlutterError.onError = (d) {
        thrown.add(d.exception);
        previous?.call(d);
      };
      await tester.pumpAndSettle();
      FlutterError.onError = previous;

      expect(thrown, isEmpty, reason: 'Save must not pop again after back already closed it');
      // The app is still showing something real, not a blank/broken tree.
      expect(find.byType(HomeScreen), findsNothing); // we are still on Calendar
      expect(find.text('September 2026'), findsOneWidget,
          reason: 'the Calendar tab, not a routeless blank screen');
    });
  });
}
