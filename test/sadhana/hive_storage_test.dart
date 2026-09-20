import 'dart:io';

import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/data/mantra.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/voice/dtw.dart';
import 'package:advance_calendar/features/sadhana/voice/mfcc.dart';
import 'package:advance_calendar/features/sadhana/application/sadhana_session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';

import 'synth.dart';

/// Exercises the real Hive-backed stores (plain test: no fake-async zone).
void main() {
  test('settings, session and custom mantras survive closing and reopening Hive',
      () async {
    final dir = await Directory.systemTemp.createTemp('sadho_hive_');
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    Hive.init(dir.path);
    await AppStorage.openBoxes();

    const session = SadhanaState(
      sankalp: 'Health',
      targetType: TargetType.time,
      targetSeconds: 900,
      perMode: {CountMode.voice: ModeProgress(count: 42)},
      rhythmSeconds: 5400,
      mode: CountMode.voice,
    );
    await AppStorage.settings.put('sadhana.session', session.toMap());
    await AppStorage.settings.put('themeMode', 'dark');
    final mantra = Mantra(
      id: 'custom_1',
      title: 'Test',
      script: 'ੴ',
      transliteration: 'Ik Onkar',
      tradition: 'Sikh',
      defaultCount: 7,
      isCustom: true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
    );
    await AppStorage.customMantras.put(mantra.id, mantra.toMap());

    await Hive.close();
    await AppStorage.openBoxes();

    final loaded = SadhanaState.fromMap(
        AppStorage.settings.get('sadhana.session') as Map);
    expect(loaded.sankalp, 'Health');
    expect(loaded.targetType, TargetType.time);
    expect(loaded.targetSeconds, 900);
    expect(loaded.count, 42);
    expect(loaded.rhythmSeconds, 5400);
    expect(loaded.mode, CountMode.voice);
    expect(AppStorage.settings.get('themeMode'), 'dark');

    final m = Mantra.fromMap(AppStorage.customMantras.values.single as Map);
    expect(m.title, 'Test');
    expect(m.script, 'ੴ');
    expect(m.defaultCount, 7);
    expect(m.createdAt, mantra.createdAt);
  });

  test('Combined/Separate choice and per-mode counts survive closing Hive',
      () async {
    final dir = await Directory.systemTemp.createTemp('sadho_hive_scope_');
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    Hive.init(dir.path);
    await AppStorage.openBoxes();

    const session = SadhanaState(
      mode: CountMode.voice,
      scope: CountScope.separate,
      perMode: {
        CountMode.tap: ModeProgress(count: 12),
        CountMode.voice: ModeProgress(count: 34, elapsedSeconds: 56),
        CountMode.mala: ModeProgress(count: 7),
      },
    );
    await AppStorage.settings.put('sadhana.session', session.toMap());

    await Hive.close();
    await AppStorage.openBoxes();

    final loaded = SadhanaState.fromMap(
        AppStorage.settings.get('sadhana.session') as Map);
    expect(loaded.scope, CountScope.separate);
    expect(loaded.mode, CountMode.voice);
    expect(loaded.count, 34);
    expect(loaded.elapsedSeconds, 56);
    expect(loaded.perMode[CountMode.tap]!.count, 12);
    expect(loaded.perMode[CountMode.mala]!.count, 7);
    expect(loaded.perMode.containsKey(CountMode.rhythm), isFalse);
    // Every mode's count is kept in either scope, so switching is lossless
    // even across a relaunch.
    expect(loaded.totalProgress.count, 12 + 34 + 7);
    expect(loaded.copyWith(scope: CountScope.combined).count, 53);
  });

  test('edits to built-in mantras survive closing and reopening Hive',
      () async {
    final dir = await Directory.systemTemp.createTemp('sadho_hive_edit_');
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    Hive.init(dir.path);
    await AppStorage.openBoxes();

    final c1 = ProviderContainer();
    await c1.read(mantraLibraryProvider.notifier).update(
          'seed_waheguru',
          title: 'Waheguru Ji',
          script: 'ਵਾਹਿਗੁਰੂ',
          transliteration: 'Waheguru',
          tradition: 'Gurmukhi · Sikh',
          defaultCount: 21,
        );
    final custom = await c1.read(mantraLibraryProvider.notifier).add(
          title: 'Mine',
          script: '',
          transliteration: '',
          tradition: 'Other',
          defaultCount: 5,
        );
    await c1.read(mantraLibraryProvider.notifier).update(custom.id,
        title: 'Mine v2',
        script: '',
        transliteration: '',
        tradition: 'Other',
        defaultCount: 6);
    c1.dispose();

    await Hive.close();
    await AppStorage.openBoxes();

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    final library = c2.read(mantraLibraryProvider);
    final w = library.firstWhere((m) => m.id == 'seed_waheguru');
    expect(w.title, 'Waheguru Ji');
    expect(w.defaultCount, 21);
    expect(w.isEdited, isTrue);
    expect(library.last.title, 'Mine v2');
    expect(library.last.defaultCount, 6);

    await c2.read(mantraLibraryProvider.notifier).resetToDefault('seed_waheguru');
    await Hive.close();
    await AppStorage.openBoxes();
    final c3 = ProviderContainer();
    addTearDown(c3.dispose);
    final reset =
        c3.read(mantraLibraryProvider).firstWhere((m) => m.id == 'seed_waheguru');
    expect(reset.title, 'Waheguru');
    expect(reset.isEdited, isFalse);
  });

  test('trained voice templates survive closing and reopening Hive',
      () async {
    final dir = await Directory.systemTemp.createTemp('sadho_hive_voice_');
    addTearDown(() async {
      await Hive.close();
      await dir.delete(recursive: true);
    });

    Hive.init(dir.path);
    await AppStorage.openBoxes();

    final ex = MfccExtractor();
    final templates = [
      for (var k = 1; k <= 4; k++)
        ex.extract(concat([
          silence(100),
          synthMantra(mantraA, seed: k, tempo: 0.9 + k * 0.05),
          silence(100),
        ])),
    ];
    final c1 = ProviderContainer();
    await c1
        .read(voiceTrainingProvider.notifier)
        .save('seed_waheguru', templates);
    await c1
        .read(voiceTrainingProvider.notifier)
        .save('seed_gayatri', templates.sublist(0, 3));
    await c1.read(voiceTrainingProvider.notifier).clear('seed_gayatri');
    c1.read(voiceSensitivityProvider.notifier).set(0.8);
    c1.dispose();

    await Hive.close();
    await AppStorage.openBoxes();

    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    final trained = c2.read(voiceTrainingProvider);
    expect(trained.keys, ['seed_waheguru'], reason: 'the cleared one stays cleared');
    final loaded = trained['seed_waheguru']!;
    expect(loaded.isUsable, isTrue);
    expect(loaded.sampleCount, 4);
    for (var i = 0; i < 4; i++) {
      expect(loaded.templates[i].frames, templates[i].frames);
      expect(dtwDistance(loaded.templates[i], templates[i]), lessThan(1e-4));
    }
    // What was stored can still count the mantra.
    final again = ex.extract(concat([
      silence(100),
      synthMantra(mantraA, seed: 77),
      silence(100),
    ]));
    expect(loaded.toModel().evaluate(again, 0.5).matched, isTrue);
    expect(c2.read(voiceSensitivityProvider), 0.8);
  });
}
