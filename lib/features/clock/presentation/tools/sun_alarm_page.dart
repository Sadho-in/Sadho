import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../calendar/application/now_provider.dart';
import '../../application/location_provider.dart';
import '../../application/sun_alarm_provider.dart';
import '../../data/sun_alarm.dart';
import '../../services/location_service.dart';

/// Full-screen sun-based alarm: follow sunrise or sunset, with a quick or a
/// custom offset. The alarm time is worked out from where you are, every day.
class SunAlarmPage extends ConsumerStatefulWidget {
  const SunAlarmPage({super.key});

  @override
  ConsumerState<SunAlarmPage> createState() => _SunAlarmPageState();
}

class _SunAlarmPageState extends ConsumerState<SunAlarmPage> {
  late bool _customOpen;
  late bool _after;
  late final TextEditingController _minutes;

  @override
  void initState() {
    super.initState();
    final s = ref.read(sunAlarmProvider);
    _customOpen = !s.isPreset;
    _after = s.offsetMinutes > 0;
    _minutes = TextEditingController(text: '${s.offsetMinutes.abs()}');
  }

  @override
  void dispose() {
    _minutes.dispose();
    super.dispose();
  }

  Future<void> _toggle(bool on) async {
    final allowed = await ref.read(sunAlarmProvider.notifier).setEnabled(on);
    if (!mounted || !on || allowed) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('Allow notifications in Settings so the alarm can ring.'),
      ));
  }

  void _applyCustom() {
    final m = int.tryParse(_minutes.text.trim());
    if (m == null) return;
    final clamped = m.clamp(0, maxOffsetMinutes);
    ref
        .read(sunAlarmProvider.notifier)
        .setOffset(_after ? clamped : -clamped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final s = ref.watch(sunAlarmProvider);
    final notifier = ref.read(sunAlarmProvider.notifier);
    final where = ref.watch(locationProvider);
    final now = ref.watch(nowProvider);
    final upcoming = ref.watch(upcomingSunAlarmsProvider);
    final time = DateFormat.jm();
    final p = where.point;
    final today = DateTime(now.year, now.month, now.day);
    final rise = sunEventOn(SunEventKind.sunrise, today, p.lat, p.lon);
    final set = sunEventOn(SunEventKind.sunset, today, p.lat, p.lon);
    final next = upcoming.isEmpty ? null : upcoming.first;
    final kind = s.event;

    return Scaffold(
      appBar: AppBar(title: const Text('Sun-based alarm')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                // ---- the computed alarm --------------------------------
                Card(
                  color: scheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          s.enabled ? 'Alarm rings at' : 'Alarm would ring at',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            next == null ? '—' : time.format(next.alarm),
                            key: const ValueKey('sun-alarm-time'),
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: scheme.onPrimaryContainer,
                              fontWeight: FontWeight.w400,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          next == null
                              ? 'No ${kind.label.toLowerCase()} to follow here right now.'
                              : '${_dayName(next.alarm, today)} · '
                                  '${kind.label} ${time.format(next.event)} · '
                                  '${offsetLabel(s.offsetMinutes, kind).toLowerCase()}',
                          key: const ValueKey('sun-alarm-detail'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SwitchListTile(
                  key: const ValueKey('sun-alarm-switch'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: const Text('Alarm on'),
                  subtitle: const Text('Recalculated every day as the sun moves'),
                  value: s.enabled,
                  onChanged: _toggle,
                ),
                const SizedBox(height: 8),
                // ---- sunrise ⟷ sunset ------------------------------------
                SegmentedButton<SunEventKind>(
                  key: const ValueKey('sun-event'),
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: SunEventKind.sunrise,
                      icon: Icon(Icons.wb_twilight),
                      label: Text('Sunrise'),
                    ),
                    ButtonSegment(
                      value: SunEventKind.sunset,
                      icon: Icon(Icons.nights_stay_outlined),
                      label: Text('Sunset'),
                    ),
                  ],
                  selected: {kind},
                  onSelectionChanged: (v) => notifier.setEvent(v.first),
                ),
                const SizedBox(height: 8),
                Text(
                  'Today here: sunrise ${rise == null ? '—' : time.format(rise)}'
                  ' · sunset ${set == null ? '—' : time.format(set)}',
                  key: const ValueKey('sun-today'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                // ---- offset ------------------------------------------------
                Text('When', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final m in presetOffsets)
                      ChoiceChip(
                        key: ValueKey('offset-$m'),
                        label: Text(offsetLabel(m, kind)),
                        selected: !_customOpen && s.offsetMinutes == m,
                        onSelected: (_) {
                          setState(() => _customOpen = false);
                          notifier.setOffset(m);
                        },
                      ),
                    ChoiceChip(
                      key: const ValueKey('offset-custom'),
                      avatar: const Icon(Icons.tune, size: 18),
                      label: const Text('Custom'),
                      selected: _customOpen,
                      onSelected: (_) => setState(() {
                        _customOpen = true;
                        _minutes.text = '${s.offsetMinutes.abs()}';
                        _after = s.offsetMinutes > 0;
                      }),
                    ),
                  ],
                ),
                if (_customOpen) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: TextField(
                          key: const ValueKey('custom-minutes'),
                          controller: _minutes,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Minutes',
                            border: OutlineInputBorder(),
                            helperText: 'Up to 1440',
                          ),
                          onChanged: (_) => _applyCustom(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: SegmentedButton<bool>(
                            key: const ValueKey('custom-direction'),
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment(value: false, label: Text('Before')),
                              ButtonSegment(value: true, label: Text('After')),
                            ],
                            selected: {_after},
                            onSelectionChanged: (v) {
                              setState(() => _after = v.first);
                              _applyCustom();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                // ---- where ---------------------------------------------
                Card(
                  child: ListTile(
                    leading: Icon(
                      p.source == LocationSource.fallback
                          ? Icons.location_off_outlined
                          : Icons.my_location,
                    ),
                    title: Text(where.summary, key: const ValueKey('sun-where')),
                    subtitle: Text(
                      '${p.lat.toStringAsFixed(2)}°, ${p.lon.toStringAsFixed(2)}°'
                      '${where.failed ? ' · could not read your position' : ''}',
                    ),
                    trailing: where.busy
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : TextButton(
                            key: const ValueKey('use-location'),
                            onPressed: where.access == LocationAccess.deniedForever
                                ? ref.read(locationProvider.notifier).openSettings
                                : () => ref
                                    .read(locationProvider.notifier)
                                    .refresh(ask: true),
                            child: Text(
                              where.access == LocationAccess.deniedForever
                                  ? 'Settings'
                                  : 'Use my location',
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _dayName(DateTime t, DateTime today) {
    final d = DateTime(t.year, t.month, t.day);
    final diff = d.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    return DateFormat('EEE d MMM').format(t);
  }
}
