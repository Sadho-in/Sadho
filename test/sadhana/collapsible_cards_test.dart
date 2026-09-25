import 'dart:convert';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/features/sadhana/application/collapsed_cards_provider.dart';
import 'package:advance_calendar/features/sadhana/application/completion_settings_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/data/ringtone.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/counter_section.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mantra_card.dart';
import 'package:advance_calendar/features/sadhana/presentation/widgets/mode_section.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout_audit/audit_harness.dart';

/// P4.3-6: Target, Completion and Sankalp open and close from their header,
/// remember it across restarts, and show a one-line summary when closed.
void main() {
  setUpAll(setUpLayoutAudit);

  Finder key(String k) => find.byKey(ValueKey(k));

  Future<ProfileRig> open(WidgetTester tester,
      {Map<String, Object?> saved = const {}, bool fresh = true}) async {
    final rig = profileRig(
        saved: {'onboarding.done': true, ...saved}, resetStorage: fresh);
    await openAuditApp(tester, rig: rig, height: 3000);
    await selectTab(tester, rig, ShellTab.sadhana);
    return rig;
  }

  String summary(WidgetTester tester, String id) =>
      tester.widget<Text>(key('summary-$id')).data!;

  test('every card is open until closed; toggling saves it', () {
    final rig = profileRig();
    final c = rig.container.read(collapsedCardsProvider.notifier);
    for (final id in SadhanaCard.all) {
      expect(c.isOpen(id), isTrue, reason: id);
    }
    c.toggle(SadhanaCard.completion);
    expect(c.isOpen(SadhanaCard.completion), isFalse);
    expect(AppStorage.settings.get('sadhana.collapsedCards'), ['completion']);
    c.toggle(SadhanaCard.completion);
    expect(c.isOpen(SadhanaCard.completion), isTrue);
    expect(AppStorage.settings.get('sadhana.collapsedCards'), isEmpty);
  });

  test('unknown or broken saved values are ignored', () {
    final rig = profileRig(saved: {
      'sadhana.collapsedCards': ['target', 'nonsense', 3],
    });
    expect(rig.container.read(collapsedCardsProvider), {'target'});
    final rig2 = profileRig(saved: {'sadhana.collapsedCards': 'target'});
    expect(rig2.container.read(collapsedCardsProvider), isEmpty);
  });

  testWidgets('open by default: each card shows its content and no summary',
      (tester) async {
    await open(tester);
    for (final id in SadhanaCard.all) {
      expect(key('summary-$id'), findsNothing, reason: id);
    }
    expect(key('keep-screen-on'), findsOneWidget);
    expect(find.byType(SegmentedButton<TargetType>), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);
  });

  testWidgets('tapping a header closes the card to a one-line summary; again '
      'opens it', (tester) async {
    final rig = await open(tester);
    await tester.tap(key('toggle-target'));
    await settle(tester);
    expect(find.byType(SegmentedButton<TargetType>), findsNothing);
    expect(summary(tester, 'target'), ' · 108');
    final text = tester.widget<Text>(key('summary-target'));
    expect(text.maxLines, 1);
    await tester.tap(key('toggle-target'));
    await settle(tester);
    expect(find.byType(SegmentedButton<TargetType>), findsOneWidget);
    expect(key('summary-target'), findsNothing);
    expect(rig.container.read(collapsedCardsProvider), isEmpty);
  });

  testWidgets('the summaries: time target, completion, sankalp', (tester) async {
    final rig = await open(tester, saved: {
      'sadhana.collapsedCards': ['completion', 'sankalp', 'target'],
    });
    final s = rig.container.read(sadhanaSessionProvider.notifier)
      ..setTargetType(TargetType.time)
      ..setTargetSeconds(90 * 60);
    await settle(tester);
    expect(summary(tester, 'target'), ' · 1 h 30 min');
    expect(summary(tester, 'sankalp'), ' · Not set');
    s.setSankalp('May this japa bring peace\nto all beings everywhere');
    final completion = rig.container.read(completionSettingsProvider.notifier)
      ..setVibrationEnabled(true)
      ..setRingtoneEnabled(true)
      ..setRingtone(Ringtone.values.first);
    await settle(tester);
    expect(summary(tester, 'sankalp'), ' · May this japa bring peace');
    expect(summary(tester, 'completion'),
        ' · Vibration on, ${Ringtone.values.first.label}');
    completion
      ..setVibrationEnabled(false)
      ..setRingtoneEnabled(false);
    await settle(tester);
    expect(summary(tester, 'completion'), ' · Vibration off, Sound off');
  });

  testWidgets('a closed card stays closed after a restart', (tester) async {
    await open(tester);
    await tester.tap(key('toggle-completion'));
    await settle(tester);
    expect(key('keep-screen-on'), findsNothing);
    // Reopen the app on the same phone.
    await tester.pumpWidget(const SizedBox());
    await open(tester, fresh: false);
    expect(key('keep-screen-on'), findsNothing);
    expect(key('summary-completion'), findsOneWidget);
    expect(key('summary-target'), findsNothing);
  });

  testWidgets('the top group does not collapse or move', (tester) async {
    await open(tester);
    Rect at(Type t) => tester.getRect(find.byType(t));
    final before = [
      at(MantraCard),
      at(CounterSection),
      at(ModeSection),
    ];
    for (final id in SadhanaCard.all) {
      await tester.tap(key('toggle-$id'));
      await settle(tester);
    }
    expect([at(MantraCard), at(CounterSection), at(ModeSection)], before);
    expect(key('toggle-mantra'), findsNothing);
  });

  testWidgets('the header is a button with a spoken label and expanded state',
      (tester) async {
    final handle = tester.ensureSemantics();
    await open(tester);
    expect(
        tester.getSemantics(key('toggle-target')),
        matchesSemantics(
            label: 'Collapse Target',
            isButton: true,
            hasExpandedState: true,
            isExpanded: true,
            hasTapAction: true));
    await tester.tap(key('toggle-target'));
    await settle(tester);
    expect(
        tester.getSemantics(key('toggle-target')),
        matchesSemantics(
            label: 'Expand Target',
            isButton: true,
            hasExpandedState: true,
            isExpanded: false,
            hasTapAction: true));
    expect(tester.getSize(key('toggle-target')).height,
        greaterThanOrEqualTo(48));
    handle.dispose();
  });

  test('is in the backup, and Delete account opens every card again', () async {
    final rig = profileRig();
    rig.container.read(collapsedCardsProvider.notifier).toggle('sankalp');
    expect(exportBackup(now: rig.clock.now), contains('sadhana.collapsedCards'));
    await AppStorage.clearAll();
    final after = profileRig(resetStorage: false);
    expect(after.container.read(collapsedCardsProvider), isEmpty);
    expect(jsonDecode(exportBackup(now: rig.clock.now)), isA<Map>());
  });
}
