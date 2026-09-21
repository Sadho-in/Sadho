import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/home/application/plans_provider.dart';
import 'package:advance_calendar/features/home/application/tradition_provider.dart';
import 'package:advance_calendar/features/home/data/plan.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/profile/application/account_service.dart';
import 'package:advance_calendar/features/profile/application/daily_reminder_provider.dart';
import 'package:advance_calendar/features/profile/application/profile_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'profile_support.dart';

void main() {
  group('name and email', () {
    test('an email is optional, but if there it must look like one', () {
      expect(validateEmail(''), isNull);
      expect(validateEmail('   '), isNull);
      for (final ok in ['a@b.co', 'asha.k@example.com', 'x+tag@mail.example.org', ' a@b.io ']) {
        expect(validateEmail(ok), isNull, reason: ok);
      }
      for (final bad in ['asha', 'asha@', '@example.com', 'a b@c.com', 'a@b', 'a@b.c', 'a@@b.com', 'a@b..']) {
        expect(validateEmail(bad), isNotNull, reason: bad);
      }
    });

    test('a name has a length limit', () {
      expect(validateName('A' * maxNameLength), isNull);
      expect(validateName('A' * (maxNameLength + 1)), isNotNull);
      expect(validateName(''), isNull);
    });

    test('initial and first name', () {
      const p = UserProfile(name: '  asha kaur ', email: '');
      expect(p.initial, 'A');
      expect(p.firstName, 'asha');
      expect(const UserProfile().initial, '');
      expect(const UserProfile().firstName, '');
      expect(const UserProfile(name: 'ਗੁਰਪ੍ਰੀਤ').initial, 'ਗ');
      expect(const UserProfile(name: '   ').hasName, isFalse);
    });

    test('saving stores it and it comes back next launch', () {
      final rig = profileRig();
      final n = rig.container.read(profileProvider.notifier);
      expect(n.save(name: '  Asha Kaur ', email: ' asha@example.com '), isTrue);
      expect(rig.container.read(profileProvider).name, 'Asha Kaur');
      expect(rig.container.read(profileProvider).email, 'asha@example.com');
      final again = profileRig(saved: {'profile': AppStorage.settings.get('profile')});
      expect(again.container.read(profileProvider).name, 'Asha Kaur');
    });

    test('an invalid email or name is not saved', () {
      final rig = profileRig();
      final n = rig.container.read(profileProvider.notifier);
      expect(n.save(name: 'Asha', email: 'not-an-email'), isFalse);
      expect(n.save(name: 'A' * 80, email: ''), isFalse);
      expect(rig.container.read(profileProvider).name, '');
      expect(AppStorage.settings.get('profile'), isNull);
    });

    test('damaged saved data starts empty', () {
      for (final junk in [null, 'x', 5, {'name': 3, 'email': []}]) {
        final rig = profileRig(saved: {'profile': junk});
        expect(rig.container.read(profileProvider).name, '');
        expect(rig.container.read(profileProvider).email, '');
      }
    });
  });

  group('profile completion', () {
    test('starts at 0% with five steps', () {
      final c = profileRig().container.read(profileCompletionProvider);
      expect(c.percent, 0);
      expect(c.steps.length, 5);
      expect(c.complete, isFalse);
      expect([for (final s in c.steps) s.id],
          ['name', 'email', 'tradition', 'reminder', 'plan']);
    });

    test('each step is worth a fifth', () {
      final rig = profileRig();
      final c = rig.container;
      int pct() => c.read(profileCompletionProvider).percent;

      c.read(profileProvider.notifier).save(name: 'Asha', email: '');
      expect(pct(), 20);
      c.read(profileProvider.notifier).save(name: 'Asha', email: 'a@b.co');
      expect(pct(), 40);
      c.read(traditionProvider.notifier).set(Tradition.hindu);
      expect(pct(), 60, reason: 'choosing the default tradition counts too');
      c.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 40);
      expect(pct(), 80);
    });

    test('the reminder counts once it is on', () async {
      final rig = profileRig();
      await rig.container.read(dailyReminderProvider.notifier).setEnabled(true);
      final c = rig.container.read(profileCompletionProvider);
      expect(c.steps.firstWhere((s) => s.id == 'reminder').done, isTrue);
      await rig.container.read(dailyReminderProvider.notifier).setEnabled(false);
      expect(rig.container.read(profileCompletionProvider).steps
          .firstWhere((s) => s.id == 'reminder').done, isFalse);
    });

    test('100% when all five are done, and the missing list is empty', () async {
      final rig = profileRig();
      final c = rig.container;
      c.read(profileProvider.notifier).save(name: 'Asha', email: 'a@b.co');
      c.read(traditionProvider.notifier).set(Tradition.sikh);
      c.read(plansProvider.notifier).add(title: 'Japji', kind: PlanKind.paath, days: 40);
      await c.read(dailyReminderProvider.notifier).setEnabled(true);
      final done = c.read(profileCompletionProvider);
      expect((done.percent, done.complete), (100, true));
      expect(done.missing, isEmpty);
    });

    test('an email with a typo does not count', () {
      final c = profileRig().container;
      // Saved directly, as an old version might have stored it.
      AppStorage.settings.put('profile', {'name': 'Asha', 'email': 'nonsense'});
      c.invalidate(profileProvider);
      final steps = c.read(profileCompletionProvider).steps;
      expect(steps.firstWhere((s) => s.id == 'email').done, isFalse);
    });

    test('deleting the last plan takes the step back', () {
      final c = profileRig().container;
      final p = c.read(plansProvider.notifier).add(title: 'X', kind: PlanKind.mantra, days: 7)!;
      expect(c.read(profileCompletionProvider).percent, 20);
      c.read(plansProvider.notifier).remove(p.id);
      expect(c.read(profileCompletionProvider).percent, 0);
    });
  });

  group('the daily reminder', () {
    test('when is the next time: today if still ahead, else tomorrow', () {
      final now = DateTime(2026, 9, 22, 7, 0);
      expect(nextOccurrence(now, 6 * 60 + 30), DateTime(2026, 9, 23, 6, 30));
      expect(nextOccurrence(now, 7 * 60), DateTime(2026, 9, 23, 7, 0),
          reason: 'exactly now has passed');
      expect(nextOccurrence(now, 7 * 60 + 1), DateTime(2026, 9, 22, 7, 1));
      expect(nextOccurrence(DateTime(2026, 12, 31, 23, 0), 5 * 60), DateTime(2027, 1, 1, 5, 0));
    });

    test('off to begin with, 6:00 AM', () {
      final r = profileRig().container.read(dailyReminderProvider);
      expect((r.enabled, r.minutes, r.hour, r.minute), (false, 360, 6, 0));
    });

    test('nothing is scheduled while it is off', () async {
      final rig = profileRig();
      rig.container.read(dailyReminderProvider);
      await pumpEventQueue();
      expect(rig.scheduler.alerts[dailyReminderGroup] ?? const [], isEmpty);
    });

    test('turning it on asks for permission and schedules ONE repeating gentle '
        'notification at the chosen time', () async {
      final rig = profileRig(now: DateTime(2026, 9, 22, 8, 0));
      final n = rig.container.read(dailyReminderProvider.notifier);
      n.setTime(6 * 60 + 45);
      final allowed = await n.setEnabled(true);
      await pumpEventQueue();
      expect(allowed, isTrue);
      expect(rig.scheduler.permissionRequests, 1);
      final a = rig.scheduler.alerts[dailyReminderGroup]!;
      expect(a.length, 1);
      expect(a.single.when, DateTime(2026, 9, 23, 6, 45));
      expect(a.single.repeatsDaily, isTrue);
      expect(a.single.gentle, isTrue);
      expect(a.single.title, contains('sadhana'));
    });

    test('changing the time moves it', () async {
      final rig = profileRig(now: DateTime(2026, 9, 22, 8, 0));
      final n = rig.container.read(dailyReminderProvider.notifier);
      await n.setEnabled(true);
      n.setTime(20 * 60);
      await pumpEventQueue();
      expect(rig.scheduler.alerts[dailyReminderGroup]!.single.when,
          DateTime(2026, 9, 22, 20, 0));
    });

    test('turning it off cancels it', () async {
      final rig = profileRig();
      final n = rig.container.read(dailyReminderProvider.notifier);
      await n.setEnabled(true);
      await n.setEnabled(false);
      await pumpEventQueue();
      expect(rig.scheduler.alerts[dailyReminderGroup], isEmpty);
    });

    test('refused permission is reported, and the choice still saved', () async {
      final rig = profileRig(scheduler: FakeScheduler(permission: false));
      final allowed =
          await rig.container.read(dailyReminderProvider.notifier).setEnabled(true);
      expect(allowed, isFalse);
      expect(rig.container.read(dailyReminderProvider).enabled, isTrue);
    });

    test('settings survive a restart, and it is scheduled again on start', () async {
      final rig = profileRig();
      final n = rig.container.read(dailyReminderProvider.notifier);
      await n.setEnabled(true);
      n.setTime(5 * 60 + 15);
      final saved = AppStorage.settings.get('profile.dailyReminder');

      final again = profileRig(saved: {'profile.dailyReminder': saved});
      final r = again.container.read(dailyReminderProvider);
      expect((r.enabled, r.hour, r.minute), (true, 5, 15));
      await pumpEventQueue();
      expect(again.scheduler.alerts[dailyReminderGroup], hasLength(1));
    });

    test('damaged or out-of-range saved data falls back to the default', () {
      for (final junk in [
        null,
        'x',
        {'enabled': true, 'minutes': 99999},
        {'enabled': true, 'minutes': -5},
        {'enabled': true, 'minutes': 'noon'},
      ]) {
        final r = profileRig(saved: {'profile.dailyReminder': junk})
            .container
            .read(dailyReminderProvider);
        expect(r.minutes, DailyReminder.defaultMinutes, reason: '$junk');
      }
    });

    test('it has its own notification group, so nothing else is disturbed', () async {
      final rig = profileRig();
      await rig.container.read(dailyReminderProvider.notifier).setEnabled(true);
      await pumpEventQueue();
      expect(rig.scheduler.alertReplacements.toSet(), {dailyReminderGroup});
      expect(alertGroups, contains(dailyReminderGroup),
          reason: 'calendar refreshes leave it alone');
    });
  });

  group('deleting the account', () {
    test('signing out with no account says so and changes nothing', () async {
      final rig = profileRig();
      await AppStorage.settings.put('language', 'pa');
      final hadAccount =
          await LocalAccountService(rig.scheduler).signOut();
      expect(hadAccount, isFalse);
      expect(AppStorage.settings.get('language'), 'pa');
    });

    test('deleting erases every box and cancels every notification', () async {
      final rig = profileRig();
      await AppStorage.settings.put('language', 'pa');
      await AppStorage.settings.put('profile', {'name': 'Asha', 'email': ''});
      await AppStorage.calendarMarks.put('m1', {'id': 'm1'});
      await AppStorage.customMantras.put('c1', {'t': 1});
      await AppStorage.mantraOverrides.put('g', {'t': 1});
      await AppStorage.voiceTemplates.put('c1', {'t': 1});

      await LocalAccountService(rig.scheduler).deleteAccount();

      for (final e in snapshot().entries) {
        expect(e.value, isEmpty, reason: e.key);
      }
      expect(rig.scheduler.alertReplacements.toSet(), alertGroups);
      for (final g in alertGroups) {
        expect(rig.scheduler.alerts[g], isEmpty, reason: g);
      }
      expect(rig.scheduler.rescheduledAll, [isEmpty],
          reason: 'calendar reminders are cleared too');
    });
  });
}
