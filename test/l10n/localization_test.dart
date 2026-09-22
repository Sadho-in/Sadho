import 'dart:convert';
import 'dart:io';

import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/core/theme/app_theme.dart';
import 'package:advance_calendar/core/theme/palettes.dart';
import 'package:advance_calendar/features/home/application/tradition_provider.dart';
import 'package:advance_calendar/features/home/data/tradition.dart';
import 'package:advance_calendar/features/onboarding/application/onboarding_provider.dart';
import 'package:advance_calendar/features/onboarding/presentation/onboarding_screen.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:advance_calendar/l10n/app_localizations.dart';
import 'package:advance_calendar/l10n/fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';

/// The eight translated languages (English is the template, not a translation).
const _translatedCodes = ['hi', 'pa', 'mr', 'bn', 'gu', 'ta', 'te', 'kn'];

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false); // no network in tests

  group('every supported locale loads with no missing-key errors', () {
    test('app_<code>.arb has a non-empty value for every app_en.arb key', () {
      final en = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
          as Map<String, dynamic>;
      final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
      // Sanity check on the check itself: this is the whole translatable
      // surface, not some accidentally-empty subset.
      expect(enKeys.length, greaterThan(500));

      for (final code in _translatedCodes) {
        final file = File('lib/l10n/app_$code.arb');
        expect(file.existsSync(), isTrue, reason: 'app_$code.arb should exist');
        final doc = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        expect(doc['@@locale'], code);
        for (final key in enKeys) {
          expect(doc.containsKey(key), isTrue, reason: '$code is missing "$key"');
          final value = doc[key];
          expect(value, isA<String>(), reason: '$code.$key should be a string');
          expect((value as String).trim(), isNotEmpty,
              reason: '$code.$key should not be empty');
        }
      }
    });

    test('AppLocalizations.supportedLocales lists all nine languages', () {
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      expect(codes, {'en', ..._translatedCodes});
    });

    test('lookupAppLocalizations resolves every supported locale and every '
        'ICU shape it carries (plain, placeholder, plural) without throwing',
        () {
      for (final locale in AppLocalizations.supportedLocales) {
        final l = lookupAppLocalizations(locale);
        expect(l.navHome, isNotEmpty, reason: locale.languageCode);
        // A placeholder string.
        expect(l.paceErrorTooFast('2s'), contains('2s'), reason: locale.languageCode);
        // An ICU plural, both branches.
        expect(l.activePlanCount(1), isNotEmpty, reason: locale.languageCode);
        expect(l.activePlanCount(2), isNotEmpty, reason: locale.languageCode);
        // A select (nested inside a plural placeholder body).
        expect(l.dayCellMarkedSuffix(1, 'good'), contains('good'),
            reason: locale.languageCode);
      }
    });

    testWidgets(
        'AppLocalizations.of(context) resolves for every supported locale '
        'inside a real widget tree, with no exception', (tester) async {
      for (final locale in AppLocalizations.supportedLocales) {
        await tester.pumpWidget(MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Text(AppLocalizations.of(context).navHome),
          ),
        ));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: locale.languageCode);
        expect(find.byType(Text), findsOneWidget, reason: locale.languageCode);
      }
    });
  });

  group('the chosen language persists across a restart', () {
    for (final code in ['ta', 'pa', 'kn']) {
      test('$code is still selected after the app reopens', () {
        AppStorage.useMemoryForTests();
        final first = ProviderContainer();
        addTearDown(first.dispose);
        first.read(languageProvider.notifier).set(code);
        expect(first.read(languageProvider), code);

        // A fresh container over the SAME storage: exactly what a relaunch is
        // elsewhere in this test suite (e.g. calendar_state_test.dart).
        final second = ProviderContainer();
        addTearDown(second.dispose);
        expect(second.read(languageProvider), code);
        expect(AppStorage.settings.get('language'), code);
      });
    }
  });

  group('Gurmukhi and Tamil render with their own script, not tofu boxes', () {
    // Real device rendering of a bundled font can't be inspected from a
    // headless widget test (flutter test does not rasterise custom fonts), so
    // this checks the two things that actually decide whether a phone shows
    // tofu: the font file is present and loadable, and the theme wires the
    // right Noto family in as a fallback for that language's UI text.
    for (final case_ in [
      (code: 'pa', family: ScriptFonts.gurmukhi, asset: 'assets/fonts/NotoSansGurmukhi-VF.ttf'),
      (code: 'ta', family: ScriptFonts.tamil, asset: 'assets/fonts/NotoSansTamil-VF.ttf'),
    ]) {
      test('${case_.code}: the bundled font file exists and is a real font', () {
        final file = File(case_.asset);
        expect(file.existsSync(), isTrue, reason: case_.asset);
        final bytes = file.readAsBytesSync();
        // A TrueType/OpenType file starts with one of these 4-byte tags.
        const magics = [
          [0x00, 0x01, 0x00, 0x00], // TrueType
          [0x4F, 0x54, 0x54, 0x4F], // 'OTTO' (CFF-flavoured OpenType)
          [0x74, 0x72, 0x75, 0x65], // 'true'
        ];
        bool matches(List<int> magic) =>
            bytes.length >= 4 && List.generate(4, (i) => bytes[i] == magic[i]).every((b) => b);
        final isSfnt = magics.any(matches);
        expect(isSfnt, isTrue, reason: '${case_.asset} is not a valid font file');
        expect(bytes.length, greaterThan(10000), reason: 'suspiciously small for a Noto font');
      });

      testWidgets('${case_.code}: AppTheme.build wires ${case_.family} in as '
          'a font-family fallback for this language, and real UI text picks '
          'it up', (tester) async {
        // The exact theme construction app.dart uses once a language is
        // chosen (SadhoApp.build: AppTheme.build(palette, brightness,
        // locale.languageCode)) - this is the wiring a real phone relies on
        // to show Gurmukhi/Tamil glyphs instead of tofu.
        final theme = AppTheme.build(defaultPalette, Brightness.light, case_.code);
        final l = lookupAppLocalizations(Locale(case_.code));
        await tester.pumpWidget(MaterialApp(
          theme: theme,
          home: Scaffold(body: Text(l.navHome)), // real translated UI text
        ));
        await tester.pump();

        final paragraphs = tester.renderObjectList<RenderParagraph>(find.byType(RichText));
        final usesScriptFont = paragraphs.any(
          (p) => (p.text.style?.fontFamilyFallback ?? const <String>[]).contains(case_.family),
        );
        expect(usesScriptFont, isTrue,
            reason:
                'no visible text used ${case_.family} as a fallback for ${case_.code}');
      });
    }
  });

  group('onboarding shows once, then never again', () {
    testWidgets('first launch: onboarding, not the app shell', (tester) async {
      final rig = profileRig();
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: rig.container, child: const SadhoApp()));
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.byType(AppShell), findsNothing);
    });

    testWidgets(
        'completing it, then reopening the app (a fresh container over the '
        'same storage), goes straight to the app shell — every time',
        (tester) async {
      AppStorage.useMemoryForTests();
      final first = profileRig();
      phoneScreen(tester, height: 2400);
      await tester.pumpWidget(UncontrolledProviderScope(
          container: first.container, child: const SadhoApp()));
      await tester.pump();
      expect(find.byType(OnboardingScreen), findsOneWidget);

      first.container.read(languageProvider.notifier).set('en');
      first.container.read(traditionProvider.notifier).set(Tradition.hindu);
      first.container.read(onboardingCompleteProvider.notifier).complete();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);

      // Reopen twice more, each a brand new container over the same Hive
      // storage (exactly what relaunching the app is, elsewhere in this
      // suite) — onboarding must stay gone every time, not just once.
      for (var i = 0; i < 2; i++) {
        final again = profileRig(resetStorage: false);
        await tester.pumpWidget(UncontrolledProviderScope(
            container: again.container, child: const SadhoApp()));
        await tester.pump();
        expect(find.byType(OnboardingScreen), findsNothing, reason: 'relaunch $i');
        expect(find.byType(AppShell), findsOneWidget, reason: 'relaunch $i');
      }
    });

    testWidgets('clearing the phone\'s data (Delete account) brings it back',
        (tester) async {
      AppStorage.useMemoryForTests();
      ProviderContainer container() {
        final c = ProviderContainer();
        addTearDown(c.dispose);
        return c;
      }

      final c1 = container();
      c1.read(onboardingCompleteProvider.notifier).complete();
      expect(c1.read(onboardingCompleteProvider), isTrue);

      // What Profile's danger zone does on "Delete account".
      await AppStorage.clearAll();

      final c2 = container();
      expect(c2.read(onboardingCompleteProvider), isFalse);
    });
  });
}
