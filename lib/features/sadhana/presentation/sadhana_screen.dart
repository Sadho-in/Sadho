import 'package:flutter/material.dart';

import 'widgets/completion_settings_card.dart';
import 'widgets/count_scope_control.dart';
import 'widgets/counter_section.dart';
import 'widgets/mantra_card.dart';
import 'widgets/mode_section.dart';
import 'widgets/sankalp_field.dart';
import 'widgets/target_section.dart';

/// Height the fixed parts of the top group take, NOT counting the mantra card
/// (the Count toggle, action row, Start button, status line and their gaps).
/// What is left of the screen, after the card, goes to the ring.
const _topGroupChrome = 250.0;

/// The card's height before it has been measured (default text size).
const _assumedCardHeight = 120.0;
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
/// The mantra card grows with the text size the user chose; the ring gives up
/// height to it (down to a minimum), and past that the page just scrolls, so
/// nothing ever overflows.
///
/// TODO(later-phase): OCR scan-to-add mantras, session history / streaks, and
/// Supabase sync.
class SadhanaScreen extends StatefulWidget {
  const SadhanaScreen({super.key});

  @override
  State<SadhanaScreen> createState() => _SadhanaScreenState();
}

class _SadhanaScreenState extends State<SadhanaScreen> {
  final _cardKey = GlobalKey();
  double _cardHeight = _assumedCardHeight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureCard());
  }

  /// Reads the card's real height (it changes with the text size, the mantra
  /// and the screen width) and re-fits the ring.
  void _measureCard() {
    if (!mounted) return;
    final box = _cardKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    if ((box.size.height - _cardHeight).abs() > 0.5) {
      setState(() => _cardHeight = box.size.height);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      // Shrink the ring so the whole top group stays visible, whatever the
      // size of the card.
      final ring =
          (box.maxHeight - _topGroupChrome - _cardHeight).clamp(_minRing, _maxRing);
      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
            children: [
              NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (_) {
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _measureCard());
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: MantraCard(key: _cardKey),
                ),
              ),
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
