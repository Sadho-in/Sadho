import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/selected_mantra_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/focus_mode_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/mantra_library_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/voice_training_screen.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mantra_form_sheet.dart';
import 'package:advance_calendar/features/sadhana/services/feedback_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sadhana/test_support.dart' show FakeFeedback, seedTrainedVoice;
import 'audit_harness.dart';

/// P4.3-2b: the Sadhana tab and everything it opens, in every language, text
/// size and theme.
void main() {
  setUpAll(setUpLayoutAudit);

  SadhanaSessionNotifier session(ProfileRig rig) =>
      rig.container.read(sadhanaSessionProvider.notifier);

  Future<void> openSadhana(WidgetTester tester, ProfileRig rig) =>
      selectTab(tester, rig, ShellTab.sadhana);

  // Every counting mode, with a count target (Combined) and a time target
  // (Separate).
  for (final mode in CountMode.values) {
    for (final (target, scope) in [
      (TargetType.count, CountScope.combined),
      (TargetType.time, CountScope.separate),
    ]) {
      testWidgets('Sadhana: ${mode.name}, ${target.name} target, ${scope.name}',
          (tester) async {
        await auditApp(tester, 'Sadhana ${mode.name}/${target.name}/${scope.name}',
            (rig) async {
          await openSadhana(tester, rig);
          session(rig)
            ..setMode(mode)
            ..setCountScope(scope)
            ..setTargetType(target);
          if (target == TargetType.time) session(rig).setTargetSeconds(90 * 60);
          await settle(tester);
        }, prepare: seedTrainedVoice);
      });
    }
  }

  testWidgets('Sadhana: Voice panel, mantra not trained', (tester) async {
    await auditApp(tester, 'Voice panel (untrained)', (rig) async {
      await openSadhana(tester, rig);
      session(rig).setMode(CountMode.voice);
      await settle(tester);
    });
  });

  testWidgets('Sadhana: counting, with the Stop button showing', (tester) async {
    await auditApp(tester, 'Sadhana running + Stop', (rig) async {
      await openSadhana(tester, rig);
      session(rig)
        ..increment()
        ..increment()
        ..toggleRunning();
      final feedback = rig.container.read(feedbackServiceProvider) as FakeFeedback;
      feedback.alerting.value = true;
      await settle(tester);
      expect(find.byKey(const ValueKey('stop-alert')), findsOneWidget);
    });
  });

  testWidgets('Sadhana: Focus mode', (tester) async {
    await auditApp(tester, 'Focus mode', (rig) async {
      await openSadhana(tester, rig);
      session(rig).increment();
      openFocusMode(appContext(tester));
      await settle(tester);
      expect(find.byType(FocusModeScreen), findsOneWidget);
    });
  });

  testWidgets('Sadhana: mantra library', (tester) async {
    await auditApp(tester, 'Mantra library', (rig) async {
      Navigator.of(appContext(tester)).push(MaterialPageRoute<void>(
          builder: (_) => const MantraLibraryScreen()));
      await settle(tester);
    }, prepare: seedTrainedVoice);
  });

  testWidgets('Sadhana: add-mantra form', (tester) async {
    await auditApp(tester, 'Mantra form (add)', (rig) async {
      Navigator.of(appContext(tester)).push(MaterialPageRoute<void>(
          builder: (_) => const MantraLibraryScreen()));
      await settle(tester);
      await tester.tap(find.byType(FloatingActionButton));
      await settle(tester);
      expect(find.byType(MantraFormSheet), findsOneWidget);
    });
  });

  testWidgets('Sadhana: edit-mantra form (built-in)', (tester) async {
    await auditApp(tester, 'Mantra form (edit)', (rig) async {
      final mantra = rig.container.read(selectedMantraProvider);
      showModalBottomSheet<void>(
          context: appContext(tester),
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => MantraFormSheet(editing: mantra));
      await settle(tester);
    });
  });

  for (final trained in [false, true]) {
    testWidgets('Sadhana: Voice training (${trained ? 'trained' : 'new'})',
        (tester) async {
      await auditApp(tester, 'Voice training', (rig) async {
        final mantra = rig.container.read(selectedMantraProvider);
        openVoiceTraining(appContext(tester), mantra);
        await settle(tester);
        expect(find.byType(VoiceTrainingScreen), findsOneWidget);
      }, prepare: trained ? seedTrainedVoice : null);
    });
  }

  for (final scope in CountScope.values) {
    testWidgets('Sadhana: Reset dialog (${scope.name})', (tester) async {
      await auditApp(tester, 'Reset dialog', (rig) async {
        await openSadhana(tester, rig);
        session(rig)
          ..setCountScope(scope)
          ..increment();
        await settle(tester);
        await tester.tap(find.byTooltip('Reset'));
        await settle(tester);
        expect(find.byType(AlertDialog), findsOneWidget);
      });
    });
  }
}
