import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/theme/palettes.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:advance_calendar/features/calendar/services/reminder_scheduler.dart';
import 'package:advance_calendar/features/profile/application/daily_reminder_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';

/// The real app root (`SadhoApp`): what the palette and the Light / Dark /
/// System choice do to the whole app.
void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false); // no network in tests

  Future<ProfileRig> open(WidgetTester tester, {ProfileRig? rig}) async {
    final r = rig ?? profileRig(saved: {'onboarding.done': true});
    phoneScreen(tester, height: 915);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: r.container, child: const SadhoApp()));
    await tester.pump();
    return r;
  }

  ColorScheme scheme(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme;

  testWidgets('launches on Marigold in the light theme', (tester) async {
    await open(tester);
    expect(scheme(tester).primary, defaultPalette.light.primary);
    expect(scheme(tester).surface, defaultPalette.light.surface);
    expect(scheme(tester).brightness, Brightness.light);
  });

  testWidgets('choosing a palette recolours the whole app at once', (tester) async {
    final rig = await open(tester);
    for (final p in sadhoPalettes) {
      rig.container.read(paletteProvider.notifier).set(p);
      await tester.pumpAndSettle();
      expect(scheme(tester).primary, p.light.primary, reason: p.name);
      expect(scheme(tester).surface, p.light.surface, reason: p.name);
      expect(scheme(tester).secondary, p.light.secondary, reason: p.name);
    }
  });

  testWidgets('Dark mode uses the dark colours of the chosen palette', (tester) async {
    final rig = await open(tester);
    rig.container.read(paletteProvider.notifier).set(sadhoPalettes[2]); // Tulsi
    rig.container.read(themeModeProvider.notifier).set(ThemeMode.dark);
    await tester.pumpAndSettle();
    expect(scheme(tester).brightness, Brightness.dark);
    expect(scheme(tester).primary, sadhoPalettes[2].dark.primary);
    expect(scheme(tester).surface, sadhoPalettes[2].dark.surface);
    rig.container.read(themeModeProvider.notifier).set(ThemeMode.light);
    await tester.pumpAndSettle();
    expect(scheme(tester).primary, sadhoPalettes[2].light.primary);
  });

  testWidgets('the palette saved last time is used on launch', (tester) async {
    await open(
        tester,
        rig: profileRig(saved: {
          'themePalette': 'lotus',
          'themeMode': 'dark',
          'onboarding.done': true,
        }));
    expect(scheme(tester).primary, sadhoPalettes[4].dark.primary);
    expect(scheme(tester).brightness, Brightness.dark);
  });

  testWidgets('the top-bar toggle still flips light and dark', (tester) async {
    final rig = await open(tester);
    await tester.tap(find.byTooltip('Switch to dark theme'));
    await tester.pumpAndSettle();
    expect(rig.container.read(themeModeProvider), ThemeMode.dark);
    expect(scheme(tester).brightness, Brightness.dark);
  });

  testWidgets('a daily reminder that is on is scheduled at launch, before '
      'Profile is ever opened', (tester) async {
    final rig = await open(
      tester,
      rig: profileRig(saved: {
        'profile.dailyReminder': const DailyReminder(enabled: true, minutes: 7 * 60).toMap(),
        'onboarding.done': true,
      }),
    );
    await tester.pump();
    final a = rig.scheduler.alerts[dailyReminderGroup]!.single;
    expect(a.repeatsDaily, isTrue);
    expect((a.when.hour, a.when.minute), (7, 0));
  });
}
