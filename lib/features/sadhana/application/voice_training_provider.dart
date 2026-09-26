import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../services/pcm_input.dart';
import '../voice/match_model.dart';
import '../voice/mfcc.dart';

/// What "training" a mantra's voice leaves behind: 3-5 MFCC templates.
///
/// Only feature numbers are stored (a few KB per recording). The audio is
/// never kept, so nothing here can be played back or leave the device.
///
/// Since P5.1 each mantra can have one set per microphone ([VoiceInput]): the
/// phone's own microphone and a headset sound very different, so a training
/// made with earphones barely matches on the phone mic. Trainings saved before
/// that have no input recorded ([VoiceInput.unknown]) and are still used.
class VoiceTraining {
  VoiceTraining({
    required this.mantraId,
    required List<MfccSequence> templates,
    required this.trainedAt,
    this.calibratedThreshold,
    this.input = VoiceInput.unknown,
  }) : templates = List.unmodifiable(templates);

  final String mantraId;

  /// The microphone these recordings were made with.
  final VoiceInput input;
  final List<MfccSequence> templates;
  final DateTime trainedAt;

  /// Set by the "chant it 11 times" calibration; null until then (and after
  /// the recordings change).
  final double? calibratedThreshold;

  bool get isCalibrated => calibratedThreshold != null;

  int get sampleCount => templates.length;

  /// Enough recordings for Voice to count with.
  bool get isUsable => templates.length >= minTrainingSamples;

  /// How many more recordings could still be added ("Add more samples").
  int get roomForMore => maxTrainingSamples - templates.length;

  MatchModel toModel() =>
      MatchModel(templates, calibratedThreshold: calibratedThreshold);

  VoiceTraining withCalibration(double? threshold) => VoiceTraining(
        mantraId: mantraId,
        templates: templates,
        trainedAt: trainedAt,
        calibratedThreshold: threshold,
        input: input,
      );

  Map<String, dynamic> toMap() => {
        'v': 1,
        if (input != VoiceInput.unknown) 'input': input.name,
        'dims': mfccDims,
        'trainedAt': trainedAt.millisecondsSinceEpoch,
        'templates': [for (final t in templates) t.toBytes()],
        if (calibratedThreshold != null) 'threshold': calibratedThreshold,
      };

  /// Null if [m] is not readable; damaged templates inside it are skipped.
  static VoiceTraining? fromMap(String mantraId, Object? m) {
    if (m is! Map) return null;
    final raw = m['templates'];
    final dims = m['dims'] is int ? m['dims'] as int : mfccDims;
    if (raw is! List || dims != mfccDims) return null;
    final templates = <MfccSequence>[
      for (final b in raw)
        if (b is Uint8List) ?MfccSequence.fromBytes(b, dims: dims),
    ];
    if (templates.isEmpty) return null;
    final at = m['trainedAt'];
    final thr = m['threshold'];
    return VoiceTraining(
      input: VoiceInput.values.firstWhere((i) => i.name == m['input'],
          orElse: () => VoiceInput.unknown),
      calibratedThreshold:
          thr is num && thr.isFinite && thr > 0 ? thr.toDouble() : null,
      mantraId: mantraId,
      templates: templates,
      trainedAt: at is int
          ? DateTime.fromMillisecondsSinceEpoch(at)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Storage key of [mantraId]'s set for [input] (the plain id for trainings
/// made before inputs were told apart).
String voiceTrainingKey(String mantraId, VoiceInput input) =>
    input == VoiceInput.unknown ? mantraId : '$mantraId@${input.name}';

/// Trained voices for every mantra, keyed by mantra id: for each mantra, the
/// set that fits the microphone in use now ([currentInput]): its own set if
/// there is one, else one of unknown input (older trainings), else the other
/// microphone's (better than nothing; the Voice panel says to train again).
class VoiceTrainingNotifier extends Notifier<Map<String, VoiceTraining>> {
  /// Every stored set: mantra id -> input -> training.
  final _all = <String, Map<VoiceInput, VoiceTraining>>{};

  VoiceInput _current = VoiceInput.unknown;

  /// The microphone in use now (as last detected).
  VoiceInput get currentInput => _current;

  @override
  Map<String, VoiceTraining> build() {
    _all.clear();
    // The box exposes values only, so each record carries its mantra id.
    for (final v in AppStorage.voiceTemplates.values) {
      if (v is! Map || v['mantraId'] is! String) continue;
      final id = v['mantraId'] as String;
      final t = VoiceTraining.fromMap(id, v);
      if (t != null) (_all[id] ??= {})[t.input] = t;
    }
    return _pick();
  }

  Map<String, VoiceTraining> _pick() => {
        for (final e in _all.entries) e.key: ?_best(e.value),
      };

  VoiceTraining? _best(Map<VoiceInput, VoiceTraining> sets) =>
      sets[_current] ??
      sets[VoiceInput.unknown] ??
      (sets.values.isEmpty ? null : sets.values.first);

  /// Every set stored for [mantraId], by input.
  Map<VoiceInput, VoiceTraining> setsFor(String mantraId) =>
      Map.unmodifiable(_all[mantraId] ?? const {});

  /// The microphone changed (earphones plugged in or out): pick the matching
  /// sets.
  void setCurrentInput(VoiceInput input) {
    if (input == _current) return;
    _current = input;
    state = _pick();
  }

  /// Asks the phone which microphone is in use now.
  Future<VoiceInput> refreshInput() async {
    VoiceInput input;
    try {
      input = await ref.read(pcmInputProvider).currentInput();
    } catch (_) {
      input = VoiceInput.unknown;
    }
    if (ref.mounted && input != VoiceInput.unknown) setCurrentInput(input);
    return input;
  }

  /// Saves (replacing) the templates for [mantraId] and [input] (by default
  /// the microphone in use now). [fromUnknown]: these extend an older set of
  /// unknown input ("Add more samples"), which now becomes this input's set.
  Future<VoiceTraining> save(String mantraId, List<MfccSequence> templates,
      {VoiceInput? input, bool fromUnknown = false}) async {
    // Never more than the maximum (keep the newest if given too many).
    final capped = templates.length > maxTrainingSamples
        ? templates.sublist(templates.length - maxTrainingSamples)
        : templates;
    final training = VoiceTraining(
      mantraId: mantraId,
      templates: capped,
      trainedAt: DateTime.now(),
      input: input ?? _current,
    );
    if (fromUnknown && training.input != VoiceInput.unknown) {
      await AppStorage.voiceTemplates
          .delete(voiceTrainingKey(mantraId, VoiceInput.unknown));
      _all[mantraId]?.remove(VoiceInput.unknown);
    }
    await _store(training);
    return training;
  }

  Future<void> _store(VoiceTraining t) async {
    await AppStorage.voiceTemplates.put(
        voiceTrainingKey(t.mantraId, t.input), {'mantraId': t.mantraId, ...t.toMap()});
    (_all[t.mantraId] ??= {})[t.input] = t;
    state = _pick();
  }

  /// Stores the calibrated threshold for [mantraId]'s set in use (null
  /// forgets it).
  Future<void> setCalibration(String mantraId, double? threshold) async {
    final t = state[mantraId];
    if (t == null) return;
    await _store(t.withCalibration(threshold));
  }

  /// Forgets every training for [mantraId] ("Clear training").
  Future<void> clear(String mantraId) async {
    for (final input in VoiceInput.values) {
      await AppStorage.voiceTemplates.delete(voiceTrainingKey(mantraId, input));
    }
    _all.remove(mantraId);
    state = _pick();
  }

  bool isTrained(String mantraId) => state[mantraId]?.isUsable ?? false;
}

final voiceTrainingProvider =
    NotifierProvider<VoiceTrainingNotifier, Map<String, VoiceTraining>>(
  VoiceTrainingNotifier.new,
);

/// The mantra's training in use was made with a DIFFERENT microphone than
/// the one in use now (the Voice panel suggests training again); null if it
/// fits, or its input is unknown.
final trainedWithOtherInputProvider = Provider.family<VoiceInput?, String>((ref, id) {
  final t = ref.watch(voiceTrainingProvider)[id];
  final now = ref.read(voiceTrainingProvider.notifier).currentInput;
  if (t == null || t.input == VoiceInput.unknown || now == VoiceInput.unknown) {
    return null;
  }
  return t.input == now ? null : t.input;
});

/// Whether one mantra has a usable trained voice.
final mantraTrainedProvider = Provider.family<bool, String>(
  (ref, mantraId) =>
      ref.watch(voiceTrainingProvider.select((m) => m[mantraId]?.isUsable ?? false)),
);

/// The Strict ↔ Lenient slider (0 = Strict, 1 = Lenient), saved with settings.
class VoiceSensitivityNotifier extends Notifier<double> {
  static const _key = 'voice.sensitivity';

  @override
  double build() {
    final v = AppStorage.settings.get(_key);
    return v is num && v.isFinite
        ? v.toDouble().clamp(0.0, 1.0)
        : defaultVoiceSensitivity;
  }

  void set(double value) {
    if (!value.isFinite) return;
    state = value.clamp(0.0, 1.0);
    AppStorage.settings.put(_key, state);
  }
}

final voiceSensitivityProvider =
    NotifierProvider<VoiceSensitivityNotifier, double>(
  VoiceSensitivityNotifier.new,
);
