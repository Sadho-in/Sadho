import 'package:advance_calendar/app.dart';
import 'package:advance_calendar/core/theme/theme_provider.dart';
import 'package:advance_calendar/features/shell/language_provider.dart';
import 'package:advance_calendar/features/shell/presentation/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../profile/profile_support.dart';

export '../profile/profile_support.dart';

/// Layout audit: every screen, in the real app theme, in each of the nine
/// languages, on a small phone (360×640), at the default text size and a
/// large one (1.6), light and dark. Any FlutterError (a RenderFlex overflow,
/// a layout exception) during build, layout or while scrolling the screen
/// through is a failure.
///
/// Setup is shared: a screen is opened once, then every combination is shown
/// on it by switching the language, text size and theme in place (exactly
/// what the user does from the top bar and the phone's settings), so the
/// audit stays fast.

const auditLocales = ['en', 'hi', 'pa', 'mr', 'bn', 'gu', 'ta', 'te', 'kn'];
const auditScales = [1.0, 1.6];
const auditBrightnesses = [Brightness.light, Brightness.dark];
const auditWidth = 360.0;
const auditHeight = 640.0;

/// One language × text size × theme.
class AuditCombo {
  const AuditCombo(this.locale, this.scale, this.brightness);

  final String locale;
  final double scale;
  final Brightness brightness;

  @override
  String toString() => '$locale@${scale}x/${brightness.name}';
}

List<AuditCombo> auditCombos({
  List<String> locales = auditLocales,
  List<double> scales = auditScales,
  List<Brightness> brightnesses = auditBrightnesses,
}) =>
    [
      for (final l in locales)
        for (final s in scales)
          for (final b in brightnesses) AuditCombo(l, s, b),
    ];

/// The bundled Noto fonts (so Indic text is measured with its real shapes,
/// not one test-font box per code point) and no runtime font fetching.
/// Call from `setUpAll`.
Future<void> setUpLayoutAudit() async {
  GoogleFonts.config.allowRuntimeFetching = false; // no network in tests
  if (_fontsLoaded) return;
  const families = {
    'NotoSansDevanagari': 'assets/fonts/NotoSansDevanagari-VF.ttf',
    'NotoSansGurmukhi': 'assets/fonts/NotoSansGurmukhi-VF.ttf',
    'NotoSansBengali': 'assets/fonts/NotoSansBengali-VF.ttf',
    'NotoSansGujarati': 'assets/fonts/NotoSansGujarati-VF.ttf',
    'NotoSansTamil': 'assets/fonts/NotoSansTamil-VF.ttf',
    'NotoSansTelugu': 'assets/fonts/NotoSansTelugu-VF.ttf',
    'NotoSansKannada': 'assets/fonts/NotoSansKannada-VF.ttf',
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key)..addFont(rootBundle.load(e.value));
    await loader.load();
  }
  _fontsLoaded = true;
}

bool _fontsLoaded = false;

/// A small phone screen (360×640 logical px).
void auditScreen(WidgetTester tester,
    {double width = auditWidth, double height = auditHeight}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// The real app (`SadhoApp`, past onboarding unless [saved] says otherwise)
/// on a small phone. Returns the rig so the test can navigate.
Future<ProfileRig> openAuditApp(
  WidgetTester tester, {
  Map<String, Object?> saved = const {},
  List<Override> extra = const [],
  ProfileRig? rig,
  double height = auditHeight,
}) async {
  final r = rig ??
      profileRig(saved: {'onboarding.done': true, ...saved}, extra: extra);
  auditScreen(tester, height: height);
  await tester.pumpWidget(UncontrolledProviderScope(
      container: r.container, child: const SadhoApp()));
  await settle(tester);
  return r;
}

/// Switches the Home/Sadhana/Calendar/Clock tab.
Future<void> selectTab(WidgetTester tester, ProfileRig rig, ShellTab tab) async {
  rig.container.read(shellTabProvider.notifier).select(tab);
  await settle(tester);
}

/// The app's root navigator (for pushing a page or showing a dialog the way
/// the app does).
BuildContext appContext(WidgetTester tester) =>
    tester.element(find.byType(AppShell, skipOffstage: false));

/// Lets animations finish without waiting on the clocks that tick forever
/// (big clock, timer, stopwatch), which `pumpAndSettle` would.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Shows every combination on whatever is on screen now (switching language,
/// text size and theme in place) and returns one line per failure.
Future<List<String>> auditOpenScreen(
  WidgetTester tester,
  ProfileRig rig, {
  List<AuditCombo>? combos,
  bool scroll = true,
}) =>
    collectLayoutFailures(tester, combos ?? auditCombos(), (c) async {
      rig.container.read(languageProvider.notifier).set(c.locale);
      rig.container.read(themeModeProvider.notifier).set(
          c.brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light);
    }, scroll: scroll);

/// Runs [show] for each combination (after setting its text size), lets it
/// build and lay out, scrolls every scrollable on screen through to its end
/// (so lazily built rows are laid out too) and back, and records every
/// exception that surfaced.
Future<List<String>> collectLayoutFailures(
  WidgetTester tester,
  List<AuditCombo> combos,
  Future<void> Function(AuditCombo combo) show, {
  bool scroll = true,
}) async {
  final failures = <String>[];
  // Every error as it is reported (the binding would keep only a summary once
  // there is more than one, and print pages per overflow). They are all
  // reported through the returned list instead.
  final reported = <FlutterErrorDetails>[];
  final original = FlutterError.onError;
  FlutterError.onError = reported.add;
  void check(AuditCombo c, String when) {
    final e = tester.takeException();
    if (e == null && reported.isEmpty) return;
    final lines = {
      for (final d in reported) _firstLine(d.exceptionAsString()),
      if (reported.isEmpty) _firstLine(e!),
    };
    reported.clear();
    for (final line in lines) {
      failures.add('$c $when: $line');
    }
  }

  try {
    await _runCombos(tester, combos, show, check, scroll);
  } finally {
    FlutterError.onError = original;
  }
  return failures;
}

Future<void> _runCombos(
  WidgetTester tester,
  List<AuditCombo> combos,
  Future<void> Function(AuditCombo combo) show,
  void Function(AuditCombo c, String when) check,
  bool scroll,
) async {
  check(combos.first, 'before the audit');
  for (final c in combos) {
    tester.platformDispatcher.textScaleFactorTestValue = c.scale;
    await show(c);
    // An overflowing box reports itself only once in its life; a reassemble
    // (what hot reload does) re-arms that, so each combination is judged on
    // its own and not hidden behind an earlier one on the same box.
    // Not awaited: it completes on the next frame, which only pump makes.
    tester.binding.reassembleApplication();
    await settle(tester);
    check(c, 'on show');
    if (scroll) {
      await _scrollThrough(tester);
      check(c, 'while scrolling');
    }
  }
}

/// Fails the test with the whole list, one line per combination.
void expectNoLayoutFailures(List<String> failures, String screen) {
  expect(failures, isEmpty,
      reason: '$screen had ${failures.length} layout failure(s):\n'
          '${failures.join('\n')}');
}

/// Opens-and-audits in one call: the usual shape of an audit test.
Future<void> auditApp(
  WidgetTester tester,
  String screen,
  Future<void> Function(ProfileRig rig) open, {
  Map<String, Object?> saved = const {},
  List<Override> extra = const [],
  List<AuditCombo>? combos,
  bool scroll = true,
}) async {
  final rig = await openAuditApp(tester, saved: saved, extra: extra);
  await open(rig);
  final failures = <String>[];
  final e = tester.takeException();
  if (e != null) failures.add('opening: ${_firstLine(e)}');
  failures.addAll(
      await auditOpenScreen(tester, rig, combos: combos, scroll: scroll));
  expectNoLayoutFailures(failures, screen);
}

Future<void> _scrollThrough(WidgetTester tester) async {
  final positions = [
    for (final s in tester.stateList<ScrollableState>(find.byType(Scrollable)))
      if (s.mounted) s.position,
  ];
  for (final p in positions) {
    if (!p.hasContentDimensions || p.maxScrollExtent <= p.minScrollExtent) {
      continue;
    }
    // A pager (the calendar month) would change page: leave it where it is.
    if (p.axis == Axis.horizontal && p.maxScrollExtent > 100000) continue;
    final start = p.pixels;
    final step = p.viewportDimension * 0.8;
    var at = p.minScrollExtent;
    var guard = 0;
    while (at < p.maxScrollExtent && guard++ < 60) {
      at = (at + step).clamp(p.minScrollExtent, p.maxScrollExtent);
      p.jumpTo(at);
      await tester.pump();
      if (!p.hasContentDimensions) break;
    }
    if (p.hasContentDimensions) p.jumpTo(start);
    await tester.pump();
  }
}

String _firstLine(Object e) {
  final s = e.toString().trim().split('\n');
  // An overflow's first line names only the widget; the second says by how
  // much, which is what tells the cases apart.
  return s.take(2).join(' ').replaceAll(RegExp(r'\s+'), ' ');
}
