import 'package:hive_flutter/hive_flutter.dart';

import 'kv_store.dart';

/// Local persistence (Phase 1: Hive only).
///
/// TODO(phase-2): sync these stores with Supabase once a backend exists.
class AppStorage {
  AppStorage._();

  static const settingsBoxName = 'settings';
  static const customMantrasBoxName = 'custom_mantras';
  static const mantraOverridesBoxName = 'mantra_overrides';
  static const voiceTemplatesBoxName = 'voice_templates';
  static const calendarMarksBoxName = 'calendar_marks';

  static late KvStore _settings;
  static late KvStore _customMantras;
  static late KvStore _mantraOverrides;
  static late KvStore _voiceTemplates;
  static late KvStore _calendarMarks;

  /// Initialises Hive for Flutter and opens every box the app uses.
  static Future<void> init() async {
    await Hive.initFlutter();
    await openBoxes();
  }

  /// Opens the Hive boxes only. Tests call `Hive.init(dir)` first.
  static Future<void> openBoxes() async {
    _settings = HiveKvStore(await Hive.openBox(settingsBoxName));
    _customMantras = HiveKvStore(await Hive.openBox(customMantrasBoxName));
    _mantraOverrides =
        HiveKvStore(await Hive.openBox(mantraOverridesBoxName));
    _voiceTemplates = HiveKvStore(await Hive.openBox(voiceTemplatesBoxName));
    _calendarMarks = HiveKvStore(await Hive.openBox(calendarMarksBoxName));
  }

  /// Swaps in empty in-memory stores. For tests only.
  static void useMemoryForTests() {
    _settings = MemoryKvStore();
    _customMantras = MemoryKvStore();
    _mantraOverrides = MemoryKvStore();
    _voiceTemplates = MemoryKvStore();
    _calendarMarks = MemoryKvStore();
  }

  /// Every store by box name (backup, restore and "delete everything").
  static Map<String, KvStore> get all => {
        settingsBoxName: _settings,
        customMantrasBoxName: _customMantras,
        mantraOverridesBoxName: _mantraOverrides,
        voiceTemplatesBoxName: _voiceTemplates,
        calendarMarksBoxName: _calendarMarks,
      };

  /// Erases everything the app has saved on this phone.
  static Future<void> clearAll() async {
    for (final store in all.values) {
      await store.clear();
    }
  }

  /// Key/value app + sadhana settings and the in-progress session.
  static KvStore get settings => _settings;

  /// User-added mantras, keyed by mantra id.
  static KvStore get customMantras => _customMantras;

  /// The user's edits to built-in mantras, keyed by seed id. Each value holds
  /// only the fields that differ from the built-in text.
  static KvStore get mantraOverrides => _mantraOverrides;

  /// Voice-training feature templates (MFCC numbers, never audio), keyed by
  /// mantra id.
  static KvStore get voiceTemplates => _voiceTemplates;

  /// Calendar marks, keyed by mark id.
  static KvStore get calendarMarks => _calendarMarks;
}
