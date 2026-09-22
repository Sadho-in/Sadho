import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/home/application/tradition_provider.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/home/presentation/home_screen.dart';
import 'package:advance_calendar/features/onboarding/application/onboarding_provider.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false); // no network in tests

  Future<ProfileRig> open(WidgetTester tester,
      {ProfileRig? rig, Locale deviceLocale = const Locale('en')}) async {
    final r = rig ??
        profileRig(extra: [
          devicePlatformLocaleProvider.overrideWithValue(deviceLocale),
        ]);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
        container: r.container, child: const SadhoApp()));
    await tester.pump();
    return r;
  }

  testWidgets('first launch shows onboarding, not the app shell',
      (tester) async {
    await open(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(AppShell), findsNothing);
  });

  testWidgets("the phone's language is preselected when it is one of the nine",
      (tester) async {
    final rig = await open(tester, deviceLocale: const Locale('pa'));
    // Preselected in the UI; not yet saved until the user actually confirms.
    final group =
        tester.widget<RadioGroup<String>>(find.byType(RadioGroup<String>));
    expect(group.groupValue, 'pa');
    expect(rig.container.read(languageProvider), 'en');

    // Continuing without touching the language radio still saves the guess.
    await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
    await tester.pumpAndSettle();
    expect(rig.container.read(languageProvider), 'pa');
  });

  testWidgets(
      'an unsupported phone language falls back to English, not a crash',
      (tester) async {
    final rig = await open(tester, deviceLocale: const Locale('fr'));
    expect(rig.container.read(languageProvider), 'en');
  });

  testWidgets('picking a language previews it immediately', (tester) async {
    final rig = await open(tester);
    expect(rig.container.read(languageProvider), 'en');
    await tester.tap(find.byKey(const ValueKey('onboarding-lang-hi')));
    await tester.pump();
    expect(rig.container.read(languageProvider), 'hi');
  });

  testWidgets(
      'Continue saves the language and tradition, completes onboarding, '
      'and the app shell appears', (tester) async {
    final rig = await open(tester);
    await tester.tap(find.byKey(const ValueKey('onboarding-lang-pa')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('onboarding-tradition-sikh')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
    await tester.pumpAndSettle();

    expect(rig.container.read(languageProvider), 'pa');
    expect(rig.container.read(traditionProvider), Tradition.sikh);
    expect(rig.container.read(onboardingCompleteProvider), isTrue);
    expect(AppStorage.settings.get('onboarding.done'), isTrue);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('a completed onboarding never shows again', (tester) async {
    await open(tester,
        rig: profileRig(saved: {'onboarding.done': true}));
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(AppShell), findsOneWidget);
  });
}
