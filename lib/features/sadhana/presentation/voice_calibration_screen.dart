import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../application/sadhana_session_provider.dart';
import '../application/voice_training_provider.dart';
import '../data/mantra.dart';
import '../services/pcm_input.dart';
import '../voice/calibration.dart';
import '../voice/match_model.dart';
import 'widgets/voice_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';

/// Opens the calibration for [mantra] (which must be trained). Pauses a
/// running session first: the microphone serves one listener at a time.
Future<void> openVoiceCalibration(BuildContext context, Mantra mantra) {
  ProviderScope.containerOf(context, listen: false)
      .read(sadhanaSessionProvider.notifier)
      .pause();
  return Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => VoiceCalibrationScreen(mantra: mantra),
  ));
}

/// "Chant your mantra 11 times now": a moment of room sound, then the
/// repetitions, each shown as it is heard; then the threshold that counts
/// them and not the room is saved with the training. Offline; no audio kept.
class VoiceCalibrationScreen extends ConsumerStatefulWidget {
  const VoiceCalibrationScreen({super.key, required this.mantra});

  final Mantra mantra;

  @override
  ConsumerState<VoiceCalibrationScreen> createState() =>
      _VoiceCalibrationScreenState();
}

class _VoiceCalibrationScreenState extends ConsumerState<VoiceCalibrationScreen>
    with WidgetsBindingObserver {
  VoiceCalibrator? _calibrator;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final training = ref.read(voiceTrainingProvider)[widget.mantra.id];
    if (training != null && training.isUsable) {
      _calibrator = VoiceCalibrator(
        input: ref.read(pcmInputProvider),
        // Measured against the recordings alone, not an older calibration.
        model: training.withCalibration(null).toModel(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _calibrator?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _calibrator?.stop();
  }

  Future<void> _start() async {
    ref.read(sadhanaSessionProvider.notifier).pause();
    await _calibrator?.start();
  }

  Future<void> _save() async {
    final t = _calibrator?.threshold;
    if (t == null) return;
    await ref
        .read(voiceTrainingProvider.notifier)
        .setCalibration(widget.mantra.id, t);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text(context.l10n.calibrationSaved(widget.mantra.title))));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final c = _calibrator;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(l.calibrateTitle,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            const BetaBadge(),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: c == null
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(l.voiceCountsOnlyTrained(widget.mantra.title,
                      minTrainingSamples, maxTrainingSamples)),
                )
              : ListenableBuilder(
                  listenable: c,
                  builder: (context, _) => ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      Text(widget.mantra.title,
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(l.calibrateIntro(c.reps),
                          style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 16),
                      _Stage(
                        calibrator: c,
                        onStart: _start,
                        onStop: c.stop,
                        onSave: _save,
                        onLater: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({
    required this.calibrator,
    required this.onStart,
    required this.onStop,
    required this.onSave,
    required this.onLater,
  });

  final VoiceCalibrator calibrator;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onSave;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final c = calibrator;
    final heard = c.heard.length;

    final (String headline, String? sub) = switch (c.phase) {
      CalibrationPhase.idle => (l.calibrateChantNow(c.reps), null),
      CalibrationPhase.starting => (l.openingMicrophone, null),
      CalibrationPhase.quiet => (l.stayQuiet, l.listeningToRoom),
      CalibrationPhase.chanting => (
          l.calibrateChantNow(c.reps),
          l.calibrateHeard(heard, c.reps),
        ),
      CalibrationPhase.done => (l.calibrateDone, l.calibrateDoneBody(c.reps)),
      CalibrationPhase.error => (
          l.cannotUseMicrophone,
          c.error == null ? null : sadhanaEngineMessage(l, c.error!),
        ),
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              liveRegion: true,
              child: Column(
                children: [
                  Text(headline,
                      key: const ValueKey('calibration-headline'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge),
                  if (sub != null) ...[
                    const SizedBox(height: 6),
                    Text(sub,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: c.phase == CalibrationPhase.error
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        )),
                  ],
                  if (c.ignored > 0 && c.phase == CalibrationPhase.chanting) ...[
                    const SizedBox(height: 6),
                    Text(l.calibrateSkipped(c.ignored),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // One dot per repetition: filled once heard.
            Semantics(
              label: l.calibrateHeard(heard, c.reps),
              excludeSemantics: true,
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < c.reps; i++)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      child: Container(
                        key: ValueKey('calibration-dot-$i'),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < heard ? scheme.primary : Colors.transparent,
                          border: Border.all(
                              color: i < heard ? scheme.primary : scheme.outline,
                              width: 2),
                        ),
                        child: i < heard
                            ? Icon(Icons.check, size: 11, color: scheme.onPrimary)
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            if (c.listening) ...[
              const SizedBox(height: 12),
              InputLevelBar(
                  key: const ValueKey('calibration-level'), level: c.level),
            ],
            const SizedBox(height: 16),
            if (c.phase == CalibrationPhase.idle ||
                c.phase == CalibrationPhase.error)
              FilledButton.icon(
                key: const ValueKey('calibration-start'),
                onPressed: onStart,
                icon: const Icon(Icons.mic),
                label: Text(c.phase == CalibrationPhase.error
                    ? l.tryAgain
                    : l.calibrateStart),
              ),
            if (c.phase == CalibrationPhase.error &&
                c.startResult == VoiceStartResult.permanentlyDenied)
              TextButton(
                  onPressed: openAppSettings, child: Text(l.openSettingsAction)),
            if (c.listening)
              OutlinedButton(onPressed: onStop, child: Text(l.stop)),
            if (c.phase == CalibrationPhase.done) ...[
              FilledButton.icon(
                key: const ValueKey('calibration-save'),
                onPressed: c.threshold == null ? null : onSave,
                icon: const Icon(Icons.check),
                label: Text(l.calibrateSave),
              ),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: onStart, child: Text(l.tryAgain)),
            ],
            if (c.phase != CalibrationPhase.done)
              Align(
                alignment: Alignment.center,
                child: TextButton(onPressed: onLater, child: Text(l.later)),
              ),
          ],
        ),
      ),
    );
  }
}
