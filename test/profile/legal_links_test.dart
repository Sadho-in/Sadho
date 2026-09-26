import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/constants/app_constants.dart';
import 'package:advance_calendar/core/links.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/onboarding/application/onboarding_provider.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/profile/presentation/widgets/about_card.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:advance_calendar/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../sadhana/test_support.dart' show FakeLinks;
import 'profile_support.dart';

/// P6-3: the legal links in Profile > About, the licences page, and the
/// first-launch notice.
void main() {
  late FakeLinks links;

  setUp(() => links = FakeLinks());

  Future<ProviderContainer> pumpAbout(WidgetTester tester) async {
    final rig = profileRig(extra: [linkLauncherProvider.overrideWithValue(links)]);
    phoneScreen(tester, height: 2400);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: rig.container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: AboutCard())),
      ),
    ));
    return rig.container;
  }

  group('Profile > About', () {
    for (final (key, url) in [
      ('about-privacy', 'https://sadho.in/privacy'),
      ('about-terms', 'https://sadho.in/terms'),
      ('about-contact', 'https://sadho.in/contact'),
      ('about-delete-data', 'https://sadho.in/delete-data'),
    ]) {
      testWidgets('$key opens $url in the browser', (tester) async {
        await pumpAbout(tester);
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pump();
        expect(links.opened, [Uri.parse(url)]);
      });
    }

    testWidgets('the links are labelled', (tester) async {
      await pumpAbout(tester);
      for (final t in [
        'Privacy policy',
        'Terms of use',
        'Contact & grievance',
        'Delete your data',
        'Open-source licences',
      ]) {
        expect(find.text(t), findsOneWidget);
      }
    });

    testWidgets('a link that cannot open says so', (tester) async {
      links.succeeds = false;
      await pumpAbout(tester);
      await tester.tap(find.byKey(const ValueKey('about-terms')));
      await tester.pump();
      expect(find.text('Could not open https://sadho.in/terms'), findsOneWidget);
    });

    testWidgets('Open-source licences: the licence page with name, version, logo',
        (tester) async {
      await pumpAbout(tester);
      await tester.tap(find.byKey(const ValueKey('about-licenses')));
      await tester.pumpAndSettle();
      expect(find.byType(LicensePage), findsOneWidget);
      final page = tester.widget<LicensePage>(find.byType(LicensePage));
      expect(page.applicationName, AppConstants.appName);
      expect(page.applicationVersion, AppConstants.version);
      expect(page.applicationIcon, isNotNull);
    });
  });

  group('first-launch notice', () {
    Future<ProfileRig> launch(WidgetTester tester, {ProfileRig? rig}) async {
      final r = rig ??
          profileRig(extra: [linkLauncherProvider.overrideWithValue(links)]);
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: r.container, child: const SadhoApp()));
      await tester.pump();
      return r;
    }

    final notice = find.byKey(const ValueKey('onboarding-legal-notice'));

    testWidgets('shows under Continue, and records when it was shown',
        (tester) async {
      final rig = await launch(tester);
      expect(notice, findsOneWidget);
      expect(find.textContaining('stay on this phone'), findsOneWidget);
      expect(
          tester.getTopLeft(notice).dy,
          greaterThan(tester
              .getTopLeft(find.byKey(const ValueKey('onboarding-continue')))
              .dy));
      expect(LegalNotice.shownAt, rig.clock.call());
      expect(LegalNotice.acceptedAt, isNull);
    });

    testWidgets('both names are links to the right pages', (tester) async {
      await launch(tester);
      await tester.tapOnText(find.textRange.ofSubstring('Terms of use'));
      await tester.pump();
      await tester.tapOnText(find.textRange.ofSubstring('Privacy policy'));
      await tester.pump();
      expect(links.opened,
          [Uri.parse('https://sadho.in/terms'), Uri.parse('https://sadho.in/privacy')]);
    });

    testWidgets('translated as a whole, links included (Hindi)', (tester) async {
      final rig = await launch(tester);
      await tester.tap(find.byKey(const ValueKey('onboarding-lang-hi')));
      await tester.pump();
      expect(find.textContaining('इसी फ़ोन पर'), findsOneWidget);
      await tester.tapOnText(find.textRange.ofSubstring('उपयोग की शर्तें'));
      await tester.pump();
      expect(links.opened.single, AppConstants.termsUrl);
      expect(rig.container.read(onboardingCompleteProvider), isFalse);
    });

    testWidgets('Continue records the acceptance; never shown again',
        (tester) async {
      final rig = await launch(tester);
      await tester.tap(find.byKey(const ValueKey('onboarding-continue')));
      await tester.pump();
      expect(LegalNotice.acceptedAt, isNotNull);
      final shown = LegalNotice.shownAt;
      expect(find.byType(AppShell), findsOneWidget);
      expect(notice, findsNothing);
      // Relaunch (same phone data): straight into the app.
      await tester.pumpWidget(const SizedBox());
      final again = profileRig(
          resetStorage: false,
          scheduler: rig.scheduler,
          extra: [linkLauncherProvider.overrideWithValue(links)]);
      await launch(tester, rig: again);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(notice, findsNothing);
      expect(LegalNotice.shownAt, shown, reason: 'first showing is kept');
      expect(AppStorage.settings.get(LegalNotice.shownAtKey), isA<int>());
    });
  });

  test('Android can open https links from the app (package visibility)', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('<data android:scheme="https"/>'));
    expect(File('pubspec.yaml').readAsStringSync(), contains('url_launcher:'));
  });
}
