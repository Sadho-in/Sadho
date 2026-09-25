import 'package:advance_calendar/core/storage/app_storage.dart';
import 'package:advance_calendar/features/sadhana/application/mantra_library_provider.dart';
import 'package:advance_calendar/features/sadhana/application/voice_training_provider.dart';
import 'package:advance_calendar/features/sadhana/data/seed_mantras.dart';
import 'package:flutter_test/flutter_test.dart';

import '../profile/profile_support.dart';
import 'test_support.dart' show seedTrainedVoice;

/// P4.3-8: the built-in mantras' texts: the full Mool Mantar, and every
/// script text written in its own script only.
void main() {
  const fullMool =
      'ੴ ਸਤਿ ਨਾਮੁ ਕਰਤਾ ਪੁਰਖੁ ਨਿਰਭਉ ਨਿਰਵੈਰੁ ਅਕਾਲ ਮੂਰਤਿ ਅਜੂਨੀ ਸੈਭੰ ਗੁਰ ਪ੍ਰਸਾਦਿ ॥';
  const fullMoolLatin = 'Ik Onkar Sat Naam Karta Purakh Nirbhau Nirvair '
      'Akaal Moorat Ajooni Saibhang Gur Prasad';

  // Unicode blocks.
  bool devanagari(int c) => c >= 0x0900 && c <= 0x097F;
  bool gurmukhi(int c) => c >= 0x0A00 && c <= 0x0A7F;
  // Allowed in any script text: spaces and punctuation, including the
  // danda and double danda (U+0964/U+0965), which Gurmukhi shares with
  // Devanagari.
  bool neutral(int c) =>
      c == 0x20 ||
      c == 0x0964 ||
      c == 0x0965 ||
      ',.;:!?-–—()\'"'.codeUnits.contains(c);

  const scriptOf = {
    'seed_om_namah_shivaya': 'Devanagari',
    'seed_gayatri': 'Devanagari',
    'seed_waheguru': 'Gurmukhi',
    'seed_mool_mantar': 'Gurmukhi',
  };

  test('the Mool Mantar is the full Mool Mantar', () {
    final m = seedMantras.firstWhere((m) => m.id == 'seed_mool_mantar');
    expect(m.script, fullMool);
    expect(m.transliteration, fullMoolLatin);
    expect(m.title, 'Mool Mantar');
  });

  test('every built-in mantra says which script it is in', () {
    expect(seedMantras.map((m) => m.id).toSet(), scriptOf.keys.toSet());
  });

  for (final m in seedMantras) {
    test('${m.title}: the script text is ${scriptOf[m.id]} only, plus spaces '
        'and punctuation', () {
      final own = scriptOf[m.id] == 'Gurmukhi' ? gurmukhi : devanagari;
      final wrong = [
        for (final r in m.script.runes)
          if (!own(r) && !neutral(r))
            'U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')} '
                '(${String.fromCharCode(r)})',
      ];
      expect(wrong, isEmpty);
      // And it has some of its own script (not only punctuation).
      expect(m.script.runes.where(own), isNotEmpty);
    });
  }

  test('the check catches a mixed script (and accepts ਵਾਹਿਗੁਰੂ)', () {
    bool clean(String s) => s.runes.every((r) => gurmukhi(r) || neutral(r));
    expect(clean('ਵਾਹਿਗੁਰੂ'), isTrue);
    expect(clean('ੴ ਸਤਿ ਨਾਮੁ ॥'), isTrue);
    expect(clean('ੴ सत नाम'), isFalse, reason: 'Devanagari inside Gurmukhi');
    expect(clean('ੴ Sat Naam'), isFalse, reason: 'Latin inside Gurmukhi');
  });

  test('a user\'s own edit of the script text still wins', () {
    AppStorage.useMemoryForTests();
    AppStorage.mantraOverrides.put('seed_mool_mantar', {'script': 'ੴ ਸਤਿ ਨਾਮੁ'});
    final rig = profileRig(resetStorage: false);
    final m = rig.container
        .read(mantraLibraryProvider)
        .firstWhere((m) => m.id == 'seed_mool_mantar');
    expect(m.script, 'ੴ ਸਤਿ ਨਾਮੁ');
    expect(m.isEdited, isTrue);
    // Only the script was edited: the rest follows the new built-in text.
    expect(m.transliteration, fullMoolLatin);
  });

  test('an edit of the title only picks up the full text', () {
    AppStorage.useMemoryForTests();
    AppStorage.mantraOverrides.put('seed_mool_mantar', {'title': 'Mool Mantra'});
    final rig = profileRig(resetStorage: false);
    final m = rig.container
        .read(mantraLibraryProvider)
        .firstWhere((m) => m.id == 'seed_mool_mantar');
    expect(m.title, 'Mool Mantra');
    expect(m.script, fullMool);
  });

  test('voice training for the Mool Mantar stays linked', () {
    AppStorage.useMemoryForTests();
    seedTrainedVoice('seed_mool_mantar');
    final rig = profileRig(resetStorage: false);
    expect(
        rig.container
            .read(voiceTrainingProvider.notifier)
            .isTrained('seed_mool_mantar'),
        isTrue);
  });
}
