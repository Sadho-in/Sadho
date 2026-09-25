import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:advance_calendar/features/sadhana/application/selected_mantra_provider.dart';
import 'package:advance_calendar/features/sadhana/data/mantra.dart';
import 'package:advance_calendar/features/sadhana/data/seed_mantras.dart';
import 'package:advance_calendar/features/sadhana/presentation/mantra_library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_support.dart';

void main() {
  setUp(resetStorage);

  ProviderContainer makeContainer() {
    final c = ProviderContainer(overrides: testOverrides());
    addTearDown(c.dispose);
    return c;
  }

  MantraLibraryNotifier lib(ProviderContainer c) =>
      c.read(mantraLibraryProvider.notifier);
  List<String> titles(ProviderContainer c) =>
      c.read(mantraLibraryProvider).map((m) => m.title).toList();

  Future<Mantra> editSeed(
    ProviderContainer c,
    String id, {
    String? title,
    String? script,
    String? transliteration,
    String? tradition,
    int? defaultCount,
  }) {
    final m = c.read(mantraLibraryProvider).firstWhere((m) => m.id == id);
    return lib(c).update(
      id,
      title: title ?? m.title,
      script: script ?? m.script,
      transliteration: transliteration ?? m.transliteration,
      tradition: tradition ?? m.tradition,
      defaultCount: defaultCount ?? m.defaultCount,
    );
  }

  group('editing a built-in mantra (stored as an override)', () {
    test('changes what the library shows, keeps its id and position',
        () async {
      final c = makeContainer();
      final saved = await lib(c).update(
        'seed_waheguru',
        title: '  Waheguru Ji  ',
        script: 'ਵਾਹਿਗੁਰੂ ਜੀ',
        transliteration: 'Waheguru Ji',
        tradition: 'Gurmukhi',
        defaultCount: 21,
      );
      expect(saved.id, 'seed_waheguru');
      expect(saved.title, 'Waheguru Ji', reason: 'trimmed');
      expect(saved.isEdited, isTrue);
      expect(saved.isCustom, isFalse, reason: 'still a built-in');

      final library = c.read(mantraLibraryProvider);
      expect(library.length, 4, reason: 'an edit never adds an entry');
      expect(library[2].id, 'seed_waheguru', reason: 'same place in the list');
      expect(library[2].script, 'ਵਾਹਿਗੁਰੂ ਜੀ');
      expect(library[2].transliteration, 'Waheguru Ji');
      expect(library[2].tradition, 'Gurmukhi');
      expect(library[2].defaultCount, 21);
    });

    test('other mantras are untouched', () async {
      final c = makeContainer();
      await editSeed(c, 'seed_waheguru', title: 'Edited');
      final byId = {for (final m in c.read(mantraLibraryProvider)) m.id: m};
      for (final seed in seedMantras.where((m) => m.id != 'seed_waheguru')) {
        expect(byId[seed.id]!.title, seed.title);
        expect(byId[seed.id]!.isEdited, isFalse);
      }
    });

    test('is saved to Hive as an override and survives a relaunch', () async {
      final c = makeContainer();
      await editSeed(c, 'seed_mool_mantar', title: 'Mool Mantra', defaultCount: 5);

      expect(AppStorage.mantraOverrides.get('seed_mool_mantar'),
          {'title': 'Mool Mantra', 'defaultCount': 5},
          reason: 'only the fields that differ from the built-in are stored');
      expect(AppStorage.customMantras.values, isEmpty,
          reason: 'never copied into the custom-mantra box');

      final again = makeContainer();
      final m = again
          .read(mantraLibraryProvider)
          .firstWhere((m) => m.id == 'seed_mool_mantar');
      expect(m.title, 'Mool Mantra');
      expect(m.defaultCount, 5);
      expect(m.script, seedMantras[3].script, reason: 'untouched field');
      expect(m.isEdited, isTrue);
    });

    test('editing a field back to the default clears the override', () async {
      final c = makeContainer();
      await editSeed(c, 'seed_gayatri', defaultCount: 27);
      expect(AppStorage.mantraOverrides.get('seed_gayatri'), isNotNull);
      final back = await editSeed(c, 'seed_gayatri', defaultCount: 108);
      expect(back.isEdited, isFalse);
      expect(AppStorage.mantraOverrides.get('seed_gayatri'), isNull);
    });

    test('clearing an optional field is a real edit (blank script)', () async {
      final c = makeContainer();
      final m = await editSeed(c, 'seed_gayatri', script: '');
      expect(m.script, '');
      expect(m.isEdited, isTrue);
      final again = makeContainer();
      expect(
          again
              .read(mantraLibraryProvider)
              .firstWhere((m) => m.id == 'seed_gayatri')
              .script,
          '');
    });

    test('Reset to default restores the built-in text and removes the override',
        () async {
      final c = makeContainer();
      await editSeed(c, 'seed_om_namah_shivaya',
          title: 'Shiv Mantra', tradition: 'Other', defaultCount: 9);
      final reset = await lib(c).resetToDefault('seed_om_namah_shivaya');
      expect(reset.title, 'Om Namah Shivaya');
      expect(reset.tradition, 'Sanskrit · Hindu');
      expect(reset.defaultCount, 108);
      expect(reset.isEdited, isFalse);
      expect(AppStorage.mantraOverrides.get('seed_om_namah_shivaya'), isNull);
      expect(titles(c).first, 'Om Namah Shivaya');
    });

    test('Reset on an unedited built-in is harmless', () async {
      final c = makeContainer();
      final m = await lib(c).resetToDefault('seed_waheguru');
      expect(m.title, 'Waheguru');
      expect(m.isEdited, isFalse);
    });

    test('the selected mantra follows an edit; the running target does not',
        () async {
      final c = makeContainer();
      c.read(sadhanaSessionProvider.notifier)
        ..setTargetCount(50)
        ..increment();
      expect(c.read(selectedMantraProvider).id, 'seed_om_namah_shivaya');

      await editSeed(c, 'seed_om_namah_shivaya',
          title: 'Om Namah Shivay', defaultCount: 21);
      expect(c.read(selectedMantraProvider).title, 'Om Namah Shivay');
      final s = c.read(sadhanaSessionProvider);
      expect(s.mantraId, 'seed_om_namah_shivaya');
      expect(s.targetCount, 50, reason: 'default count is for the next pick');
      expect(s.count, 1, reason: 'an edit never resets a session');
    });

    test('search matches the edited text, not the old', () async {
      final c = makeContainer();
      await editSeed(c, 'seed_waheguru', transliteration: 'Vahiguru');
      final library = c.read(mantraLibraryProvider);
      expect(library.where((m) => m.matches('vahiguru')).length, 1);
    });

    test('unknown id is rejected', () {
      final c = makeContainer();
      expect(
        () => lib(c).update('nope',
            title: 'x',
            script: '',
            transliteration: '',
            tradition: '',
            defaultCount: 1),
        throwsArgumentError,
      );
    });

    test('malformed saved overrides are ignored field by field', () {
      AppStorage.mantraOverrides.put('seed_gayatri', 'garbage');
      AppStorage.mantraOverrides.put('seed_waheguru', {
        'title': '   ', // blank title would hide the mantra
        'defaultCount': '21', // wrong type
        'script': 42, // wrong type
        'tradition': 'Punjabi', // this one is fine
      });
      AppStorage.mantraOverrides.put('seed_mool_mantar', {'defaultCount': 0});
      AppStorage.mantraOverrides.put('seed_removed_in_a_later_release',
          {'title': 'ghost'});
      final c = makeContainer();
      final library = c.read(mantraLibraryProvider);
      expect(library.length, 4, reason: 'no ghost entry for a removed seed');
      expect(library[1].isEdited, isFalse);
      expect(library[2].title, 'Waheguru');
      expect(library[2].defaultCount, 108);
      expect(library[2].script, seedMantras[2].script);
      expect(library[2].tradition, 'Punjabi');
      expect(library[2].isEdited, isTrue);
      expect(library[3].defaultCount, 11);
      expect(library[3].isEdited, isFalse);
    });
  });

  group('editing a custom mantra', () {
    Future<String> addCustom(ProviderContainer c) async => (await lib(c).add(
          title: 'Hanuman Chalisa',
          script: 'श्री हनुमान चालीसा',
          transliteration: 'Shri Hanuman Chalisa',
          tradition: 'Awadhi · Hindu',
          defaultCount: 40,
        ))
            .id;

    test('updates every field in place, keeping id, order and custom-ness',
        () async {
      final c = makeContainer();
      final firstId = await addCustom(c);
      final secondId = (await lib(c).add(
              title: 'Second',
              script: '',
              transliteration: '',
              tradition: '',
              defaultCount: 3))
          .id;
      final createdAt =
          c.read(mantraLibraryProvider).firstWhere((m) => m.id == firstId).createdAt;

      final saved = await lib(c).update(
        firstId,
        title: 'Hanuman Chalisa Path',
        script: 'हनुमान चालीसा',
        transliteration: 'Hanuman Chalisa',
        tradition: 'Hindu',
        defaultCount: 11,
      );
      expect(saved.id, firstId);
      expect(saved.isCustom, isTrue);
      expect(saved.isEdited, isFalse, reason: 'that flag is for built-ins');
      expect(saved.createdAt, createdAt);

      final library = c.read(mantraLibraryProvider);
      expect(library.length, 6);
      expect(library[4].id, firstId, reason: 'still before the newer one');
      expect(library[5].id, secondId);
      expect(library[4].title, 'Hanuman Chalisa Path');
      expect(library[4].script, 'हनुमान चालीसा');
      expect(library[4].defaultCount, 11);
      expect(AppStorage.mantraOverrides.values, isEmpty,
          reason: 'custom edits are not overrides');
    });

    test('persists across a relaunch, and delete still works', () async {
      final c = makeContainer();
      final id = await addCustom(c);
      await lib(c).update(id,
          title: 'Renamed',
          script: '',
          transliteration: '',
          tradition: 'Other',
          defaultCount: 7);

      final again = makeContainer();
      final m = again.read(mantraLibraryProvider).last;
      expect(m.id, id);
      expect(m.title, 'Renamed');
      expect(m.script, '');
      expect(m.defaultCount, 7);

      await lib(again).remove(id);
      expect(again.read(mantraLibraryProvider).length, 4);
    });
  });

  group('library screen: Edit action', () {
    late ProviderContainer container;

    Future<void> openLibrary(WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      container = makeContainer();
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MantraLibraryScreen()),
      ));
      await tester.pumpAndSettle();
    }

    Finder tile(String title) => find.widgetWithText(Card, title).first;
    Finder inTile(String title, Finder f) =>
        find.descendant(of: tile(title), matching: f);
    Finder field(String label) => find.widgetWithText(TextFormField, label);
    String valueOf(WidgetTester t, String label) =>
        t.widget<TextFormField>(field(label)).controller!.text;

    Future<void> openEdit(WidgetTester tester, String title) async {
      await tester.tap(inTile(title, find.byTooltip('Edit')));
      await tester.pumpAndSettle();
    }

    testWidgets('every row has Edit; only custom rows have Delete',
        (tester) async {
      await openLibrary(tester);
      expect(find.byTooltip('Edit'), findsNWidgets(4), reason: 'all seeded');
      expect(find.byTooltip('Delete'), findsNothing);

      await lib(container).add(
          title: 'Mine',
          script: '',
          transliteration: '',
          tradition: 'Other',
          defaultCount: 9);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Edit'), findsNWidgets(5));
      expect(find.byTooltip('Delete'), findsOneWidget);
      expect(inTile('Mine', find.byTooltip('Delete')), findsOneWidget);
    });

    testWidgets('the form opens pre-filled with every field', (tester) async {
      await openLibrary(tester);
      await openEdit(tester, 'Mool Mantar');
      expect(find.text('Edit mantra'), findsOneWidget);
      expect(valueOf(tester, 'Title *'), 'Mool Mantar');
      expect(valueOf(tester, 'Script text'), _mool.script);
      expect(valueOf(tester, 'Transliteration'), _mool.transliteration);
      expect(valueOf(tester, 'Tradition / language'), 'Gurbani · Sikh');
      expect(valueOf(tester, 'Default count *'), '11');
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('saving an edit to a built-in updates the row and Hive',
        (tester) async {
      await openLibrary(tester);
      expect(inTile('Waheguru', find.text('Edited')), findsNothing);
      await openEdit(tester, 'Waheguru');

      await tester.enterText(field('Title *'), 'Waheguru Ji');
      await tester.enterText(field('Script text'), 'ਵਾਹਿਗੁਰੂ ਜੀ');
      await tester.enterText(field('Transliteration'), 'Waheguru Ji');
      await tester.enterText(field('Tradition / language'), 'Punjabi');
      await tester.enterText(field('Default count *'), '21');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Edit mantra'), findsNothing, reason: 'form closed');
      expect(find.text('Saved “Waheguru Ji”'), findsOneWidget);
      expect(tile('Waheguru Ji'), findsOneWidget);
      expect(find.text('ਵਾਹਿਗੁਰੂ ਜੀ'), findsOneWidget);
      expect(find.text('21 counts'), findsOneWidget);
      expect(inTile('Waheguru Ji', find.text('Edited')), findsOneWidget);
      expect(AppStorage.mantraOverrides.get('seed_waheguru'), {
        'title': 'Waheguru Ji',
        'script': 'ਵਾਹਿਗੁਰੂ ਜੀ',
        'transliteration': 'Waheguru Ji',
        'tradition': 'Punjabi',
        'defaultCount': 21,
      });
      expect(find.byTooltip('Delete'), findsNothing,
          reason: 'built-ins still cannot be deleted');
    });

    testWidgets('Reset to default only appears for an edited built-in, and '
        'restores it after confirming', (tester) async {
      await openLibrary(tester);
      await openEdit(tester, 'Gayatri Mantra');
      expect(find.text('Reset to default'), findsNothing,
          reason: 'nothing to reset yet');
      await tester.enterText(field('Default count *'), '27');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('27 counts'), findsOneWidget);

      await openEdit(tester, 'Gayatri Mantra');
      expect(find.text('Reset to default'), findsOneWidget);

      // Cancelling the confirmation keeps the edit.
      await tester.tap(find.text('Reset to default'));
      await tester.pumpAndSettle();
      expect(find.text('Reset to default?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.text('Edit mantra'), findsOneWidget);
      expect(AppStorage.mantraOverrides.get('seed_gayatri'), isNotNull);

      await tester.tap(find.text('Reset to default'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Reset'));
      await tester.pumpAndSettle();

      expect(find.text('Edit mantra'), findsNothing);
      expect(find.text('Restored “Gayatri Mantra” to its default'),
          findsOneWidget);
      expect(find.text('27 counts'), findsNothing);
      expect(inTile('Gayatri Mantra', find.text('Edited')), findsNothing);
      expect(AppStorage.mantraOverrides.get('seed_gayatri'), isNull);
    });

    testWidgets('editing a custom mantra keeps Delete and has no Reset',
        (tester) async {
      await openLibrary(tester);
      await lib(container).add(
          title: 'Mine',
          script: '',
          transliteration: '',
          tradition: 'Other',
          defaultCount: 9);
      await tester.pumpAndSettle();

      await openEdit(tester, 'Mine');
      expect(valueOf(tester, 'Title *'), 'Mine');
      expect(valueOf(tester, 'Default count *'), '9');
      expect(find.text('Reset to default'), findsNothing);
      await tester.enterText(field('Title *'), 'Mine Renamed');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(tile('Mine Renamed'), findsOneWidget);
      expect(find.text('Mine'), findsNothing);
      expect(inTile('Mine Renamed', find.byTooltip('Delete')), findsOneWidget);
      expect(inTile('Mine Renamed', find.text('Edited')), findsNothing);
      expect(container.read(mantraLibraryProvider).length, 5);
    });

    testWidgets('validation blocks a bad edit and saves nothing',
        (tester) async {
      await openLibrary(tester);
      await openEdit(tester, 'Waheguru');
      await tester.enterText(field('Title *'), '   ');
      await tester.enterText(field('Default count *'), '0');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a title'), findsOneWidget);
      expect(find.text('Enter a number, 1 or more'), findsOneWidget);
      expect(find.text('Edit mantra'), findsOneWidget, reason: 'stays open');
      expect(AppStorage.mantraOverrides.get('seed_waheguru'), isNull);

      await tester.enterText(field('Title *'), 'Waheguru');
      await tester.enterText(field('Default count *'), '10000000');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.text('That is too large'), findsOneWidget);
    });

    testWidgets('saving without changing anything does not mark it Edited',
        (tester) async {
      await openLibrary(tester);
      await openEdit(tester, 'Waheguru');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(inTile('Waheguru', find.text('Edited')), findsNothing);
      expect(AppStorage.mantraOverrides.values, isEmpty);
    });

    testWidgets('Add still opens an empty form', (tester) async {
      await openLibrary(tester);
      await tester.tap(find.text('Add mantra'));
      await tester.pumpAndSettle();
      expect(find.text('Add a mantra'), findsOneWidget);
      expect(valueOf(tester, 'Title *'), '');
      expect(valueOf(tester, 'Default count *'), '108');
      expect(find.text('Save to library'), findsOneWidget);
      expect(find.text('Reset to default'), findsNothing);

      await tester.enterText(field('Title *'), 'Brand New');
      await tester.tap(find.text('Save to library'));
      await tester.pumpAndSettle();
      expect(find.text('Added “Brand New”'), findsOneWidget);
      expect(tile('Brand New'), findsOneWidget);
    });

    testWidgets('tapping a row body still picks it (Edit does not)',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      container = makeContainer();
      Object? picked;
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async => picked = await Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (_) => const MantraLibraryScreen())),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await openEdit(tester, 'Waheguru');
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(find.byType(MantraLibraryScreen), findsOneWidget,
          reason: 'editing does not close the library');
      expect(picked, isNull);

      await tester.tap(find.text('Mool Mantar'));
      await tester.pumpAndSettle();
      expect(find.byType(MantraLibraryScreen), findsNothing);
      expect((picked as dynamic).id, 'seed_mool_mantar');
    });
  });
}

/// The built-in Mool Mantar (its text changed in P4.3-8: the full Mool Mantar).
final _mool = seedMantras.firstWhere((m) => m.id == 'seed_mool_mantar');
