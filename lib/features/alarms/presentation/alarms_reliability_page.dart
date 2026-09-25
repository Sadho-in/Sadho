import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/l10n.dart';
import '../../sadhana/application/completion_settings_provider.dart';
import '../../sadhana/services/dnd_driver.dart';
import '../application/alarm_health_provider.dart';
import '../services/alarm_health.dart';

Future<void> openAlarmsReliability(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const AlarmsReliabilityPage(),
    ));

/// "Alarms & reliability": what the phone must allow for alarms to ring on
/// time with the screen off, each with a live status and a Fix button that
/// opens the exact settings page. Rechecked on return from the settings.
class AlarmsReliabilityPage extends ConsumerStatefulWidget {
  const AlarmsReliabilityPage({super.key});

  @override
  ConsumerState<AlarmsReliabilityPage> createState() =>
      _AlarmsReliabilityPageState();
}

class _AlarmsReliabilityPageState extends ConsumerState<AlarmsReliabilityPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Always a fresh look when the page opens.
    Future.microtask(_refresh);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Back from the phone's settings.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    if (!mounted) return;
    ref.invalidate(dndAccessProvider);
    await ref.read(alarmHealthStatusProvider.notifier).refresh();
  }

  Future<void> _fix(Future<void> Function(AlarmHealth) fix) async {
    await fix(ref.read(alarmHealthProvider));
    await _refresh(); // a dialog answered in place (no trip to settings)
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final status = ref.watch(alarmHealthStatusProvider).value;
    // Do Not Disturb access matters only while quiet mode is switched on.
    final quiet = ref.watch(
            completionSettingsProvider.select((c) => c.quietDuringSession)) &&
        ref.read(dndDriverProvider).isSupported;
    final dndOk = quiet ? ref.watch(dndAccessProvider).value : null;
    return Scaffold(
      appBar: AppBar(title: Text(l.alarmsReliabilityTitle)),
      body: status == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                Text(l.alarmsReliabilityIntro,
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 12),
                _HealthRow(
                  id: 'notifications',
                  icon: Icons.notifications_active_outlined,
                  title: l.healthNotificationsTitle,
                  body: l.healthNotificationsBody,
                  ok: status.notifications,
                  onFix: () => _fix((h) => h.fixNotifications()),
                ),
                if (status.android) ...[
                  _HealthRow(
                    id: 'exact',
                    icon: Icons.alarm_on,
                    title: l.healthExactTitle,
                    body: l.healthExactBody,
                    ok: status.exactAlarms,
                    onFix: () => _fix((h) => h.fixExactAlarms()),
                  ),
                  _HealthRow(
                    id: 'fullscreen',
                    icon: Icons.screen_lock_portrait_outlined,
                    title: l.healthFullScreenTitle,
                    body: l.healthFullScreenBody,
                    ok: status.fullScreen,
                    onFix: () => _fix((h) => h.fixFullScreen()),
                  ),
                  _HealthRow(
                    id: 'battery',
                    icon: Icons.battery_charging_full,
                    title: l.healthBatteryTitle,
                    body: status.samsung
                        ? '${l.healthBatteryBody}\n${l.healthBatterySamsungHint}'
                        : l.healthBatteryBody,
                    ok: status.battery,
                    onFix: () => _fix((h) => h.fixBattery()),
                  ),
                ],
                if (quiet)
                  _HealthRow(
                    id: 'dnd',
                    icon: Icons.do_not_disturb_on_outlined,
                    title: l.healthDndTitle,
                    body: l.healthDndBody,
                    ok: dndOk ?? true,
                    onFix: () async {
                      await ref.read(dndDriverProvider).openAccessSettings();
                      await _refresh();
                    },
                  ),
              ],
            ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
    required this.ok,
    required this.onFix,
  });

  final String id;
  final IconData icon;
  final String title;
  final String body;
  final bool ok;
  final VoidCallback onFix;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // A green that reads at 7:1 or more on every palette's card, light or
    // dark (shade 700 was about 4:1).
    final color = ok ? okGreen(theme.brightness) : scheme.error;
    return Card(
      key: ValueKey('health-$id'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(ok ? Icons.check_circle : Icons.error_outline,
                        size: 18, color: color),
                    const SizedBox(width: 6),
                    // Wraps within the card when it is long.
                    Flexible(
                      child: Text(
                        ok ? l.healthOk : l.healthNeedsAttention,
                        key: ValueKey('health-$id-status'),
                        style:
                            theme.textTheme.labelLarge?.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                OutlinedButton(
                  key: ValueKey('health-$id-fix'),
                  onPressed: onFix,
                  child: Text(l.healthFix),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The Profile entry: the overall status, opening the page.
class AlarmsReliabilityCard extends ConsumerWidget {
  const AlarmsReliabilityCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final status = ref.watch(alarmHealthStatusProvider).value;
    final ok = status?.allOk ?? true;
    return Card(
      child: ListTile(
        key: const ValueKey('alarms-reliability-entry'),
        leading: Icon(ok ? Icons.alarm_on : Icons.alarm_off,
            color: ok ? null : Theme.of(context).colorScheme.error),
        title: Text(l.alarmsReliabilityTitle),
        subtitle: Text(ok ? l.alarmsReliabilityAllOk : l.alarmsReliabilityAttention),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openAlarmsReliability(context),
      ),
    );
  }
}

/// The "OK" green of a health row, for [brightness].
Color okGreen(Brightness brightness) => brightness == Brightness.dark
    ? const Color(0xFF8FD694)
    : const Color(0xFF14521A);

/// Whether Sadho may change Do Not Disturb (quiet mode). Re-read whenever the
/// page is refreshed (on return from the phone's settings).
final dndAccessProvider = FutureProvider.autoDispose<bool>(
    (ref) => ref.read(dndDriverProvider).hasAccess());
