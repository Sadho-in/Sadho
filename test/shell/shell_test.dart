import 'package:advance_calendar/features/calendar/presentation/calendar_screen.dart';
import 'package:advance_calendar/features/clock/presentation/clock_screen.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/profile/application/profile_provider.dart';
import 'package:advance_calendar/features/sadhana/presentation/sadhana_screen.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';

void main() {
  Finder key(String k) => find.byKey(ValueKey(k));

  Future<ProfileRig> open(WidgetTester tester, {ProfileRig? rig}) async {
    final r = rig ?? profileRig();
    await pumpProfile(tester, r, const AppShell(), height: 915, page: true);
    return r;
  }

  Finder navLabel(String l) =>
      find.descendant(of: find.byType(NavigationBar), matching: find.text(l));

  group('the bottom navigation', () {
    testWidgets('reads Home · Sadhana · Calendar · Clock, left to right',
        (tester) async {
      await open(tester);
      final labels = [
        for (final d in tester.widgetList<NavigationDestination>(find.byType(NavigationDestination)))
          d.label,
      ];
      expect(labels, ['Home', 'Sadhana', 'Calendar', 'Clock']);
      double x(String l) => tester.getCenter(navLabel(l)).dx;
      expect(x('Home'), lessThan(x('Sadhana')));
      expect(x('Sadhana'), lessThan(x('Calendar')));
      expect(x('Calendar'), lessThan(x('Clock')));
    });

    testWidgets('the tab list itself is in that order, Home first', (tester) async {
      expect([for (final t in ShellTab.values) t.label],
          ['Home', 'Sadhana', 'Calendar', 'Clock']);
      expect(ShellTab.home.index, 0);
    });

    testWidgets('Home is leftmost and is what opens on launch', (tester) async {
      await open(tester);
      expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SadhanaScreen), findsNothing);
      expect(find.byType(CalendarScreen), findsNothing);
      expect(find.byType(ClockScreen), findsNothing);
      expect(key('home-greeting'), findsOneWidget);
    });

    testWidgets('each tab shows its own screen', (tester) async {
      await open(tester);
      for (final (label, type) in <(String, Type)>[
        ('Sadhana', SadhanaScreen),
        ('Calendar', CalendarScreen),
        ('Clock', ClockScreen),
        ('Home', HomeScreen),
      ]) {
        await tester.tap(navLabel(label));
        await tester.pumpAndSettle();
        expect(find.byType(type), findsOneWidget, reason: label);
        for (final other in [HomeScreen, SadhanaScreen, CalendarScreen, ClockScreen]) {
          if (other != type) expect(find.byType(other), findsNothing, reason: '$label hides $other');
        }
      }
    });

    testWidgets('a fresh launch is on Home again, whatever tab was used last',
        (tester) async {
      final rig = await open(tester);
      await tester.tap(navLabel('Clock'));
      await tester.pumpAndSettle();
      expect(rig.container.read(shellTabProvider), ShellTab.clock);
      await tester.pumpWidget(const SizedBox());
      await open(tester); // new container: a new launch
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Sadhana keeps its state while you look at other tabs',
        (tester) async {
      await open(tester);
      await tester.tap(navLabel('Sadhana'));
      await tester.pumpAndSettle();
      final before = tester.state(find.byType(SadhanaScreen));
      await tester.tap(navLabel('Home'));
      await tester.pumpAndSettle();
      await tester.tap(navLabel('Sadhana'));
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(SadhanaScreen)), same(before));
    });
  });

  group('the top bar', () {
    testWidgets('has language, theme toggle and a profile avatar', (tester) async {
      await open(tester);
      expect(find.byTooltip('Language'), findsOneWidget);
      expect(find.byTooltip('Profile'), findsOneWidget);
      expect(find.byTooltip(RegExp('Switch to (light|dark) theme')), findsOneWidget);
    });

    testWidgets('the avatar shows a person until you have a name, then your initial',
        (tester) async {
      final rig = await open(tester);
      expect(key('avatar-initial'), findsNothing);
      expect(find.descendant(of: find.byTooltip('Profile'), matching: find.byIcon(Icons.person)),
          findsOneWidget);
      rig.container.read(profileProvider.notifier).save(name: 'asha', email: '');
      await tester.pump();
      expect(tester.widget<Text>(key('avatar-initial')).data, 'A');
    });

    testWidgets('the avatar opens the Profile page, and back returns to the app',
        (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
      expect(key('profile-completion'), findsOneWidget);
      expect(find.text('Your details'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('a name saved in Profile shows in the Home greeting and avatar',
        (tester) async {
      await open(tester);
      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.enterText(key('profile-name'), 'Asha Kaur');
      await tester.pump();
      await tester.tap(key('profile-save'));
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(tester.widget<Text>(key('home-greeting')).data, 'Good morning, Asha');
      expect(tester.widget<Text>(key('avatar-initial')).data, 'A');
    });
  });
}
