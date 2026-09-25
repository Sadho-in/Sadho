import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/clock/data/clock_tool.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/notepad/application/notes_provider.dart';
import 'package:advance_calendar/features/notepad/data/note.dart';
import 'package:advance_calendar/features/notepad/presentation/note_editor_page.dart';
import 'package:advance_calendar/features/notepad/presentation/notepad_page.dart';
import 'package:advance_calendar/features/profile/application/backup_service.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../layout_audit/audit_harness.dart';

/// P4.3-7: the Notepad (a Clock tool): notes newest first, search, add, edit
/// (saved as you type), delete (asks first); offline in Hive, in the backup,
/// erased by Delete account.
void main() {
  setUpAll(setUpLayoutAudit);

  final en = lookupAppLocalizations(const Locale('en'));
  Finder key(String k) => find.byKey(ValueKey(k));

  group('Note', () {
    test('heading: the title, else the first line, else "Empty note"', () {
      final t = DateTime(2026, 9, 21);
      Note n(String title, String text) =>
          Note(id: 'x', title: title, text: text, created: t, edited: t);
      expect(n('Shopping', 'ghee\nflowers').headingIn(en), 'Shopping');
      expect(n('Shopping', 'ghee\nflowers').snippet, 'ghee\nflowers');
      expect(n('', 'ghee\nflowers').headingIn(en), 'ghee');
      expect(n('', 'ghee\nflowers').snippet, 'flowers');
      expect(n(' ', ' ').headingIn(en), 'Empty note');
      expect(n(' ', '\n').isEmpty, isTrue);
    });

    test('search looks in title and text, any case', () {
      final t = DateTime(2026, 9, 21);
      final n = Note(
          id: 'x', title: 'Aarti list', text: 'Om Jai Jagdish', created: t, edited: t);
      expect(n.matches(''), isTrue);
      expect(n.matches('aarti'), isTrue);
      expect(n.matches('JAGDISH'), isTrue);
      expect(n.matches('havan'), isFalse);
    });

    test('round-trips through a map; rejects junk', () {
      final t = DateTime(2026, 9, 21, 7, 30);
      final n = Note(
          id: 'n1', title: 'T', text: 'x', created: t, edited: t.add(const Duration(minutes: 5)));
      final back = Note.fromMap(n.toMap())!;
      expect(back.toMap(), n.toMap());
      expect(Note.fromMap('nope'), isNull);
      expect(Note.fromMap({'id': '', 'created': 1}), isNull);
      expect(Note.fromMap({'id': 'a'}), isNull);
    });
  });

  group('the notes', () {
    test('saved as written, newest first, deleted, and still there after a '
        'restart', () async {
      final rig = profileRig();
      final notes = rig.container.read(notesProvider.notifier);
      final a = notes.save(notes.draft(), title: 'First', text: 'one');
      rig.clock.advance(const Duration(minutes: 1));
      final b = notes.save(notes.draft(), title: '', text: 'second note');
      expect([for (final n in rig.container.read(notesProvider)) n.id],
          [b.id, a.id]);
      // Editing keeps its place (newest = written most recently) and marks
      // the edit time.
      rig.clock.advance(const Duration(minutes: 1));
      final a2 = notes.save(a, title: 'First', text: 'one, edited');
      expect(a2.created, a.created);
      expect(a2.edited, rig.clock.now);
      expect(rig.container.read(notesProvider).last.text, 'one, edited');

      final again = profileRig(resetStorage: false);
      expect(again.container.read(notesProvider).map((n) => n.text),
          ['second note', 'one, edited']);

      await notes.delete(b.id);
      expect(AppStorage.notes.keys, [a.id]);
    });

    test('are in the backup, come back on restore, and Delete account erases '
        'them', () async {
      final rig = profileRig();
      final notes = rig.container.read(notesProvider.notifier);
      notes.save(notes.draft(), title: 'Keep me', text: 'safe');
      final file = exportBackup(now: rig.clock.now);
      expect(file, contains('Keep me'));

      await AppStorage.clearAll();
      expect(AppStorage.notes.keys, isEmpty);
      expect(profileRig(resetStorage: false).container.read(notesProvider),
          isEmpty);

      await applyBackup(parseBackup(file));
      final restored = profileRig(resetStorage: false);
      expect(restored.container.read(notesProvider).single.title, 'Keep me');
    });
  });

  group('the screens', () {
    Future<ProfileRig> openNotepad(WidgetTester tester) async {
      final rig = await openAuditApp(tester, height: 1200);
      await selectTab(tester, rig, ShellTab.clock);
      await tester.tap(await reveal(tester, key('tool-notepad')));
      await settle(tester);
      expect(find.byType(NotepadPage), findsOneWidget);
      return rig;
    }

    Future<void> back(WidgetTester tester) async {
      await tester.pageBack();
      await settle(tester);
    }

    testWidgets('the Clock tab lists the Notepad; empty, it says how to start',
        (tester) async {
      await openNotepad(tester);
      expect(ClockTool.values.last, ClockTool.notepad);
      expect(key('notes-empty'), findsOneWidget);
      expect(find.text(en.notesEmpty), findsOneWidget);
      expect(key('notes-search'), findsNothing, reason: 'nothing to search');
    });

    testWidgets('+ writes a note, saved as you type (no Save button)',
        (tester) async {
      final rig = await openNotepad(tester);
      await tester.tap(key('note-add'));
      await settle(tester);
      expect(find.byType(NoteEditorPage), findsOneWidget);
      await tester.enterText(key('note-title'), 'Havan');
      await tester.enterText(key('note-text'), 'Samagri\nGhee');
      await settle(tester);
      // Already stored while the editor is still open.
      final stored = rig.container.read(notesProvider).single;
      expect((stored.title, stored.text), ('Havan', 'Samagri\nGhee'));
      expect(AppStorage.notes.keys, [stored.id]);
      expect(find.textContaining('Created'), findsOneWidget);
      await back(tester);
      expect(find.text('Havan'), findsOneWidget);
      expect(find.text('Samagri\nGhee'), findsOneWidget);
    });

    testWidgets('editing changes the note and its edited time', (tester) async {
      final rig = await openNotepad(tester);
      final notes = rig.container.read(notesProvider.notifier);
      final n = notes.save(notes.draft(), title: 'Jaap', text: '108');
      await settle(tester);
      await tester.tap(key('note-${n.id}'));
      await settle(tester);
      rig.clock.advance(const Duration(hours: 2));
      await tester.enterText(key('note-text'), '1008');
      await settle(tester);
      final after = rig.container.read(notesProvider).single;
      expect(after.text, '1008');
      expect(after.edited, rig.clock.now);
      expect(tester.widget<Text>(key('note-times')).data, contains('Edited'));
    });

    testWidgets('an empty new note is not kept', (tester) async {
      final rig = await openNotepad(tester);
      await tester.tap(key('note-add'));
      await settle(tester);
      await tester.enterText(key('note-text'), 'x');
      await tester.enterText(key('note-text'), '');
      await settle(tester);
      await back(tester);
      expect(rig.container.read(notesProvider), isEmpty);
      expect(AppStorage.notes.keys, isEmpty);
    });

    testWidgets('delete asks first: Cancel keeps it, Delete removes it',
        (tester) async {
      final rig = await openNotepad(tester);
      final notes = rig.container.read(notesProvider.notifier);
      final n = notes.save(notes.draft(), title: 'Old', text: 'list');
      await settle(tester);
      await tester.tap(key('note-delete-${n.id}'));
      await settle(tester);
      expect(key('note-delete-dialog'), findsOneWidget);
      await tester.tap(key('note-delete-no'));
      await settle(tester);
      expect(rig.container.read(notesProvider), hasLength(1));
      await tester.tap(key('note-delete-${n.id}'));
      await settle(tester);
      await tester.tap(key('note-delete-yes'));
      await settle(tester);
      expect(rig.container.read(notesProvider), isEmpty);
      expect(key('notes-empty'), findsOneWidget);
    });

    testWidgets('delete from inside the note also asks, then closes it',
        (tester) async {
      final rig = await openNotepad(tester);
      final notes = rig.container.read(notesProvider.notifier);
      final n = notes.save(notes.draft(), title: 'Old', text: 'list');
      await settle(tester);
      await tester.tap(key('note-${n.id}'));
      await settle(tester);
      await tester.tap(key('note-delete'));
      await settle(tester);
      await tester.tap(key('note-delete-yes'));
      await settle(tester);
      expect(find.byType(NoteEditorPage), findsNothing);
      expect(rig.container.read(notesProvider), isEmpty);
    });

    testWidgets('search narrows the list, and says when nothing matches',
        (tester) async {
      final rig = await openNotepad(tester);
      final notes = rig.container.read(notesProvider.notifier);
      notes.save(notes.draft(), title: 'Aarti', text: 'evening');
      notes.save(notes.draft(), title: 'Havan', text: 'Sunday morning');
      await settle(tester);
      await tester.enterText(key('notes-search'), 'MORNING');
      await settle(tester);
      expect(find.text('Havan'), findsOneWidget);
      expect(find.text('Aarti'), findsNothing);
      await tester.enterText(key('notes-search'), 'zzz');
      await settle(tester);
      expect(find.text(en.notesNoMatch('zzz')), findsOneWidget);
      await tester.tap(key('notes-search-clear'));
      await settle(tester);
      expect(find.text('Aarti'), findsOneWidget);
      expect(find.text('Havan'), findsOneWidget);
    });

    testWidgets('opened straight from openClockTool too', (tester) async {
      await openAuditApp(tester);
      openClockTool(appContext(tester), ClockTool.notepad);
      await settle(tester);
      expect(find.byType(NotepadPage), findsOneWidget);
    });
  });
}
