import 'package:flutter/material.dart';

import 'widgets/completion_settings_card.dart';
import 'widgets/count_scope_control.dart';
import 'widgets/counter_section.dart';
import 'widgets/mantra_card.dart';
import 'widgets/mode_section.dart';
import 'widgets/sankalp_field.dart';
import 'widgets/target_section.dart';

/// Height the fixed parts of the top group take (mantra card, Count toggle,
/// action row, Start button, status line and their gaps). What is left of the
/// screen goes to the ring.
const _topGroupChrome = 348.0;
const _minRing = 120.0;
const _maxRing = 240.0;

/// Sadhana tab: Japa & Paath counter.
///
/// ABOVE THE FOLD (no scrolling needed on a typical phone): a compact mantra
/// card, the Combined | Separate toggle, the progress ring, one row of
/// Reset / − / + / Focus, and the Start / Pause / Resume button.
/// BELOW (scrolls): mode selector (with the Rhythm pace or the Voice panel of
/// the chosen mode), target, vibration and ringtone, and the sankalp.
///
/// TODO(later-phase): OCR scan-to-add mantras, session history / streaks, and
/// Supabase sync.
class SadhanaScreen extends StatelessWidget {
  const SadhanaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      // Shrink the ring on short screens so the whole top group stays visible.
      final ring = (box.maxHeight - _topGroupChrome).clamp(_minRing, _maxRing);
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
            children: [
              const MantraCard(),
              const SizedBox(height: 6),
              const CountScopeControl(compact: true),
              const SizedBox(height: 6),
              CounterSection(ringSize: ring),
              const SizedBox(height: 20),
              const ModeSection(),
              const SizedBox(height: 12),
              const TargetSection(),
              const SizedBox(height: 12),
              const CompletionSettingsCard(),
              const SizedBox(height: 12),
              const SankalpField(),
            ],
          ),
        ),
      );
    });
  }
}
