import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'audit_harness.dart';

/// The audit harness itself: it covers the whole matrix, really applies each
/// combination, and catches an overflow.
void main() {
  setUpAll(setUpLayoutAudit);

  test('the matrix is 9 languages × 2 text sizes × light and dark', () {
    final combos = auditCombos();
    expect(combos, hasLength(36));
    expect(combos.map((c) => c.locale).toSet(), auditLocales.toSet());
    expect(combos.map((c) => c.scale).toSet(), {1.0, 1.6});
    expect(combos.map((c) => c.brightness).toSet(),
        {Brightness.light, Brightness.dark});
  });

  testWidgets('each combination is applied to the real app in place',
      (tester) async {
    final rig = await openAuditApp(tester);
    final seen = <String>[];
    final failures = await collectLayoutFailures(tester, auditCombos(),
        (c) async {
      // What auditOpenScreen does, plus a look at what it produced.
      await auditOpenScreen(tester, rig, combos: [c], scroll: false);
      final context = appContext(tester);
      seen.add('${Localizations.localeOf(context).languageCode}'
          '@${MediaQuery.textScalerOf(context).scale(10) / 10}x/'
          '${Theme.of(context).brightness.name}');
    });
    expect(failures, isEmpty);
    expect(seen, [for (final c in auditCombos()) c.toString()]);
    expect(tester.view.physicalSize, const Size(360, 640));
  });

  testWidgets('an overflow is caught and named, in every combination',
      (tester) async {
    auditScreen(tester);
    Future<void> show(AuditCombo c) => tester.pumpWidget(MaterialApp(
          locale: Locale(c.locale),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Row(children: [Text('A label far too long for one row')]),
          ),
        ));
    final failures = await collectLayoutFailures(
        tester, auditCombos(locales: ['en', 'pa']), show);
    expect(failures, hasLength(8));
    expect(failures.first, contains('en@1.0x/light'));
    expect(failures.first, contains('overflowed'));
  });

  testWidgets('a well-behaved layout passes', (tester) async {
    auditScreen(tester);
    final failures = await collectLayoutFailures(
        tester,
        auditCombos(locales: ['en', 'ta']),
        (c) => tester.pumpWidget(const MaterialApp(
              home: Scaffold(
                body: Row(children: [
                  Expanded(child: Text('A label far too long for one row')),
                ]),
              ),
            )));
    expect(failures, isEmpty);
  });

  testWidgets('rows built lazily further down a list are laid out too',
      (tester) async {
    auditScreen(tester);
    final failures = await collectLayoutFailures(
        tester,
        auditCombos(locales: ['en'], brightnesses: [Brightness.light]),
        (c) => tester.pumpWidget(MaterialApp(
              home: Scaffold(
                body: ListView(children: [
                  for (var i = 0; i < 40; i++) const SizedBox(height: 60),
                  const Row(children: [Text('An overflow far below the fold')]),
                ]),
              ),
            )));
    expect(failures, isNotEmpty);
  });
}
