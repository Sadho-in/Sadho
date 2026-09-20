import 'mantra.dart';

/// Built-in library. These live in code (not Hive) so they can be improved in
/// later releases without migrating user data.
const seedMantras = <Mantra>[
  Mantra(
    id: 'seed_om_namah_shivaya',
    title: 'Om Namah Shivaya',
    script: 'ॐ नमः शिवाय',
    transliteration: 'Om Namah Shivaya',
    tradition: 'Sanskrit · Hindu',
    defaultCount: 108,
  ),
  Mantra(
    id: 'seed_gayatri',
    title: 'Gayatri Mantra',
    script:
        'ॐ भूर्भुवः स्वः तत्सवितुर्वरेण्यं भर्गो देवस्य धीमहि धियो यो नः प्रचोदयात्',
    transliteration:
        'Om Bhur Bhuvah Svah, Tat Savitur Varenyam, Bhargo Devasya Dhimahi, Dhiyo Yo Nah Prachodayat',
    tradition: 'Sanskrit · Hindu',
    defaultCount: 108,
  ),
  Mantra(
    id: 'seed_waheguru',
    title: 'Waheguru',
    script: 'ਵਾਹਿਗੁਰੂ',
    transliteration: 'Waheguru',
    tradition: 'Gurmukhi · Sikh',
    defaultCount: 108,
  ),
  Mantra(
    id: 'seed_mool_mantar',
    title: 'Mool Mantar',
    script: 'ੴ ਸਤਿ ਨਾਮੁ',
    transliteration: 'Ik Onkar Sat Naam',
    tradition: 'Gurbani · Sikh',
    defaultCount: 11,
  ),
];
