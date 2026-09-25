import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../application/sadhana_session_provider.dart';
import '../application/voice_training_provider.dart';
import '../data/mantra.dart';
import '../services/pcm_input.dart';
import '../voice/match_model.dart';
import '../voice/voice_trainer.dart';
import 'widgets/script_text.dart';
import 'widgets/voice_widgets.dart';
import '../../../l10n/l10n.dart';
import '../../../l10n/labels.dart';

/// Opens the training screen. Pauses a running session first: the microphone
/// can only serve one listener. With [addMore] it goes straight into recording
/// more samples to add to the existing training.
Future<void> openVoiceTraining(BuildContext context, Mantra mantra,
    {bool addMore = false}) {
  ProviderScope.containerOf(context, listen: false)
      .read(sadhanaSessionProvider.notifier)
      .pause();
  return Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => VoiceTrainingScreen(mantra: mantra, addMore: addMore),
  ));
}

/// "Train your own mantra": record the mantra 3 to 7 times; each recording is
/// reduced to MFCC feature templates (audio is discarded) and saved to Hive.
///
/// A trained mantra can be topped up ("Add more samples", appended to the
/// existing ones), replaced ("Re-train") or wiped ("Clear training").
class VoiceTrainingScreen extends ConsumerStatefulWidget {
  const VoiceTrainingScreen({
    super.key,
    required this.mantra,
    this.addMore = false,
  });

  final Mantra mantra;
  final bool addMore;

  @override
  ConsumerState<VoiceTrainingScreen> createState() =>
      _VoiceTrainingScreenState();
}

class _VoiceTrainingScreenState extends ConsumerState<VoiceTrainingScreen>
    with WidgetsBindingObserver {
  late VoiceTrainer _trainer;

  /// This session adds to the saved recordings instead of replacing them.
  bool _append = false;
  VoiceStartResult? _lastStart;

  VoiceTraining? get _saved =>
      ref.read(voiceTrainingProvider)[widget.mantra.id];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _trainer = VoiceTrainer(input: ref.read(pcmInputProvider));
    if (widget.addMore && (_saved?.roomForMore ?? 0) > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _begin(append: true);
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _trainer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The OS takes the microphone away in the background.
    if (state == AppLifecycleState.paused) _trainer.stop();
  }

  /// Starts (or restarts) a recording session, appending to what is saved or
  /// replacing it.
  Future<void> _begin({bool? append}) async {
    ref.read(sadhanaSessionProvider.notifier).pause();
    final wantAppend = append ?? _append;
    final saved = _saved;
    final old = _trainer;
    await old.stop();
    old.dispose();
    if (!mounted) return;
    setState(() {
      _append = wantAppend && saved != null;
      _trainer = VoiceTrainer(
        input: ref.read(pcmInputProvider),
        existing: _append ? saved!.templates : const [],
      );
    });
    final r = await _trainer.start();
    if (mounted) setState(() => _lastStart = r);
  }

  /// Keep recording in the current session (after Stop).
  Future<void> _resume() async {
    final r = await _trainer.start();
    if (mounted) setState(() => _lastStart = r);
  }

  Future<void> _save() async {
    if (!_trainer.canSave) return;
    final samples = _trainer.samples;
    final added = _trainer.added;
    final appended = _append;
    await _trainer.stop();
    await ref
        .read(voiceTrainingProvider.notifier)
        .save(widget.mantra.id, samples);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(appended
            ? context.l10n.addedRecordingsTo(added, widget.mantra.title, samples.length)
            : context.l10n.voiceTrainedFor(widget.mantra.title, samples.length)),
      ));
    Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    if (await confirmClearTraining(context, ref, widget.mantra)) {
      _trainer.clear();
      setState(() => _append = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mantra = widget.mantra;
    final training = ref.watch(voiceTrainingProvider)[mantra.id];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // An app-bar title is one line; the screen says it again below.
            Flexible(
              child: Text(context.l10n.trainVoice,
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
          child: ListenableBuilder(
            listenable: _trainer,
            builder: (context, _) {
              final t = _trainer;
              // Nothing being recorded: show what is saved and its actions.
              final showSaved =
                  training != null && t.phase == TrainerPhase.idle && t.added == 0;
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  _MantraHeader(mantra: mantra),
                  const SizedBox(height: 16),
                  if (showSaved)
                    _TrainedCard(
                      l10n: context.l10n,
                      training: training,
                      onAddMore: () => _begin(append: true),
                      onRetrain: () => _begin(append: false),
                      onClear: _clear,
                    )
                  else
                    _Stage(
                      l10n: context.l10n,
                      trainer: t,
                      appending: _append,
                      savedCount: training?.sampleCount ?? 0,
                      onBegin: () => _begin(append: _append),
                      onResume: _resume,
                      onSave: _save,
                      onStop: t.stop,
                      onUndo: t.discardLast,
                      onStartOver: () {
                        t.clear();
                        _begin(append: _append);
                      },
                      showSettings:
                          _lastStart == VoiceStartResult.permanentlyDenied,
                    ),
                  const SizedBox(height: 16),
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: VoiceSensitivitySlider(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.voiceBetaNoteTraining(maxTrainingSamples),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MantraHeader extends StatelessWidget {
  const _MantraHeader({required this.mantra});
  final Mantra mantra;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(mantra.title, style: theme.textTheme.titleLarge),
            if (mantra.script.isNotEmpty) ...[
              const SizedBox(height: 6),
              ScriptText(mantra.script,
                  style: theme.textTheme.titleMedium, maxLines: 3),
            ],
            const SizedBox(height: 8),
            VoiceTrainedTag(mantra.id),
          ],
        ),
      ),
    );
  }
}

/// A trained mantra at rest: what is saved, and the three things to do with it.
class _TrainedCard extends StatelessWidget {
  const _TrainedCard({
    required this.l10n,
    required this.training,
    required this.onAddMore,
    required this.onRetrain,
    required this.onClear,
  });

  final AppLocalizations l10n;
  final VoiceTraining training;
  final VoidCallback onAddMore;
  final VoidCallback onRetrain;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final room = training.roomForMore;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.trainedRecordingsCount(training.sampleCount),
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              !training.isUsable
                  ? l10n.tooFewRecordings
                  : (room > 0
                      ? l10n.canCountAddMore(room)
                      : l10n.canCountAtMax(maxTrainingSamples)),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: room > 0 ? onAddMore : null,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addMoreSamples),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRetrain,
              icon: const Icon(Icons.mic, size: 18),
              label: Text(l10n.retrain),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l10n.clearTraining),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The interactive part: instructions, level meter, progress dots, buttons.
class _Stage extends StatelessWidget {
  const _Stage({
    required this.l10n,
    required this.trainer,
    required this.appending,
    required this.savedCount,
    required this.onBegin,
    required this.onResume,
    required this.onSave,
    required this.onStop,
    required this.onUndo,
    required this.onStartOver,
    required this.showSettings,
  });

  final AppLocalizations l10n;
  final VoiceTrainer trainer;
  final bool appending;
  final int savedCount;
  final VoidCallback onBegin;
  final VoidCallback onResume;
  final VoidCallback onSave;
  final VoidCallback onStop;
  final VoidCallback onUndo;
  final VoidCallback onStartOver;
  final bool showSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = trainer;
    final paused = t.phase == TrainerPhase.idle && t.added > 0;

    final (String headline, String? sub) = switch (t.phase) {
      TrainerPhase.idle when paused => (
          l10n.pausedHeadline,
          l10n.pausedSub(t.recorded),
        ),
      TrainerPhase.idle => (
          l10n.trainYourOwnMantra,
          l10n.recordInstructions(
              minTrainingSamples, maxTrainingSamples, recommendedTrainingSamples),
        ),
      TrainerPhase.starting => (l10n.openingMicrophone, null),
      TrainerPhase.calibrating => (l10n.stayQuiet, l10n.listeningToRoom),
      TrainerPhase.waiting => (
          l10n.sayYourMantra,
          l10n.recordingXofY(t.currentIndex, t.maximum),
        ),
      TrainerPhase.complete => (
          l10n.allRecordingsCaptured(t.recorded),
          l10n.saveToStartCounting,
        ),
      TrainerPhase.error => (
          l10n.cannotUseMicrophone,
          t.message == null ? null : sadhanaEngineMessage(l10n, t.message!),
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
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge),
                  if (sub != null) ...[
                    const SizedBox(height: 6),
                    Text(sub,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: t.phase == TrainerPhase.error
                              ? scheme.error
                              : scheme.onSurfaceVariant,
                        )),
                  ],
                  if (t.phase == TrainerPhase.waiting) ...[
                    const SizedBox(height: 6),
                    Text(
                      t.message != null
                          ? sadhanaEngineMessage(l10n, t.message!)
                          : (t.canSave
                              ? l10n.canSaveNowHint
                              : l10n.minAreEnough(minTrainingSamples)),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: t.message != null
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (appending && t.phase != TrainerPhase.error) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.addingToSaved(savedCount),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (t.listening || t.recorded > 0) ...[
              _Dots(
                recorded: t.recorded,
                saved: appending ? savedCount : 0,
                maximum: t.maximum,
                minimum: t.minimum,
              ),
              const SizedBox(height: 12),
            ],
            if (t.listening) ...[
              LinearProgressIndicator(
                value: t.phase == TrainerPhase.calibrating ? null : t.level,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 16),
            ],
            if (t.phase == TrainerPhase.error ||
                (t.phase == TrainerPhase.idle && !paused))
              FilledButton.icon(
                onPressed: onBegin,
                icon: const Icon(Icons.mic),
                label: Text(
                    t.phase == TrainerPhase.error ? l10n.tryAgain : l10n.startRecording),
              ),
            if (t.phase == TrainerPhase.error && showSettings)
              TextButton(
                  onPressed: openAppSettings,
                  child: Text(l10n.openSettingsAction)),
            if (t.listening || t.phase == TrainerPhase.complete || paused) ...[
              FilledButton.icon(
                onPressed: t.canSave ? onSave : null,
                icon: const Icon(Icons.check),
                label: Text(t.canSave
                    ? l10n.saveNRecordings(t.recorded)
                    : (t.recorded < t.minimum
                        ? l10n.recordMoreToSave(t.minimum - t.recorded)
                        // Enough already saved; only something new is missing.
                        : l10n.recordSampleToSave)),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                children: [
                  if (t.added > 0)
                    TextButton.icon(
                      onPressed: onUndo,
                      icon: const Icon(Icons.undo, size: 18),
                      label: Text(l10n.undoLast),
                    ),
                  if (t.listening)
                    TextButton(onPressed: onStop, child: Text(l10n.stop)),
                  if (paused && t.remaining > 0)
                    TextButton(
                        onPressed: onResume,
                        child: Text(l10n.continueRecording)),
                  if (t.phase == TrainerPhase.complete || paused)
                    TextButton(
                        onPressed: onStartOver, child: Text(l10n.startOver)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One dot per possible recording. Saved recordings are solid, this session's
/// filled with a tick, and the first [minimum] carry the stronger outline.
class _Dots extends StatelessWidget {
  const _Dots({
    required this.recorded,
    required this.saved,
    required this.maximum,
    required this.minimum,
  });

  final int recorded;
  final int saved;
  final int maximum;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.recordedOfMax(recorded, maximum),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          for (var i = 0; i < maximum; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < saved
                      ? scheme.secondary
                      : (i < recorded ? scheme.primary : Colors.transparent),
                  border: Border.all(
                    color: i < recorded
                        ? (i < saved ? scheme.secondary : scheme.primary)
                        : (i < minimum ? scheme.outline : scheme.outlineVariant),
                    width: 2,
                  ),
                ),
                child: i >= saved && i < recorded
                    ? Icon(Icons.check, size: 11, color: scheme.onPrimary)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
