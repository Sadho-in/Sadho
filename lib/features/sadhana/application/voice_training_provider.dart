import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/app_storage.dart';
import '../voice/match_model.dart';
import '../voice/mfcc.dart';

/// What "training" a mantra's voice leaves behind: 3-5 MFCC templates.
///
/// Only feature numbers are stored (a few KB per recording). The audio is
/// never kept, so nothing here can be played back or leave the device.
class VoiceTraining {
  VoiceTraining({
    required this.mantraId,
    required List<MfccSequence> templates,
    required this.trainedAt,
  }) : templates = List.unmodifiable(templates);

  final String mantraId;
  final List<MfccSequence> templates;
  final DateTime trainedAt;

  int get sampleCount => templates.length;

  /// Enough recordings for Voice to count with.
  bool get isUsable => templates.length >= minTrainingSamples;

  /// How many more recordings could still be added ("Add more samples").
  int get roomForMore => maxTrainingSamples - templates.length;

  MatchModel toModel() => MatchModel(templates);

  Map<String, dynamic> toMap() => {
        'v': 1,
        'dims': mfccDims,
        'trainedAt': trainedAt.millisecondsSinceEpoch,
        'templates': [for (final t in templates) t.toBytes()],
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
    return VoiceTraining(
      mantraId: mantraId,
      templates: templates,
      trainedAt: at is int
          ? DateTime.fromMillisecondsSinceEpoch(at)
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

/// Trained voices for every mantra, keyed by mantra id.
class VoiceTrainingNotifier extends Notifier<Map<String, VoiceTraining>> {
  @override
  Map<String, VoiceTraining> build() {
    // The box exposes values only, so each record carries its mantra id.
    final out = <String, VoiceTraining>{};
    for (final v in AppStorage.voiceTemplates.values) {
      if (v is! Map || v['mantraId'] is! String) continue;
      final id = v['mantraId'] as String;
      final t = VoiceTraining.fromMap(id, v);
      if (t != null) out[id] = t;
    }
    return out;
  }

  /// Saves (replacing) the templates for [mantraId].
  Future<VoiceTraining> save(String mantraId, List<MfccSequence> templates) async {
    // Never more than the maximum (keep the newest if given too many).
    final capped = templates.length > maxTrainingSamples
        ? templates.sublist(templates.length - maxTrainingSamples)
        : templates;
    final training = VoiceTraining(
      mantraId: mantraId,
      templates: capped,
      trainedAt: DateTime.now(),
    );
    await AppStorage.voiceTemplates
        .put(mantraId, {'mantraId': mantraId, ...training.toMap()});
    state = {...state, mantraId: training};
    return training;
  }

  /// Forgets the training for [mantraId] ("Clear training").
  Future<void> clear(String mantraId) async {
    await AppStorage.voiceTemplates.delete(mantraId);
    state = {...state}..remove(mantraId);
  }

  bool isTrained(String mantraId) => state[mantraId]?.isUsable ?? false;
}

final voiceTrainingProvider =
    NotifierProvider<VoiceTrainingNotifier, Map<String, VoiceTraining>>(
  VoiceTrainingNotifier.new,
);

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
