import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/l10n.dart';
import '../../../../l10n/labels.dart';
import '../../application/calendar_marks_provider.dart';
import '../../data/calendar_mark.dart';
import '../../services/reminder_scheduler.dart';
import 'mark_format.dart';
import 'mark_palette.dart';

/// Opens the editor for [date]. Pass [markId] to edit a specific mark (for
/// example from a Home card); otherwise a date with marks lets you pick one
/// or add another, and an empty date starts a new mark.
Future<void> showMarkEditor(
  BuildContext context, {
  required DateTime date,
  String? markId,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => MarkEditorSheet(date: dateOnly(date), markId: markId),
    );

/// Create, edit or delete a mark on one date.
class MarkEditorSheet extends ConsumerStatefulWidget {
  const MarkEditorSheet({super.key, required this.date, this.markId});

  final DateTime date;
  final String? markId;

  @override
  ConsumerState<MarkEditorSheet> createState() => _MarkEditorSheetState();
}

class _MarkEditorSheetState extends ConsumerState<MarkEditorSheet> {
  final _label = TextEditingController();
  final _details = TextEditingController();

  /// The mark being edited; null while creating a new one.
  String? _editingId;
  DateTime? _editingStart;

  MarkType _type = MarkType.good;
  String? _emoji;
  ReminderMode _reminder = ReminderMode.none;
  List<int> _times = [];
  RepeatRule _repeat = RepeatRule.once;
  HomeMode _home = HomeMode.none;
  int _homeMinutes = defaultHomeMinutes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final marks = ref.read(calendarMarksProvider.notifier);
    final start = widget.markId != null
        ? marks.byId(widget.markId!)
        : marks.marksOn(widget.date).firstOrNull;
    _load(start);
  }

  @override
  void dispose() {
    _label.dispose();
    _details.dispose();
    super.dispose();
  }

  /// Fills the form from [m], or resets it for a new mark.
  void _load(CalendarMark? m) {
    _editingId = m?.id;
    _editingStart = m?.date;
    _type = m?.type ?? MarkType.good;
    _emoji = m?.emoji;
    _label.text = m?.label ?? '';
    _details.text = m?.details ?? '';
    _reminder = m?.reminderMode ?? ReminderMode.none;
    _times = [...?m?.reminderTimes];
    _repeat = m?.repeat ?? RepeatRule.once;
    _home = m?.homeMode ?? HomeMode.none;
    _homeMinutes = m?.homeMinutes ?? defaultHomeMinutes;
  }

  Future<int?> _pickTime(int initial) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    );
    return t == null ? null : t.hour * 60 + t.minute;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_reminder == ReminderMode.several && _times.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(context.l10n.markEditorNoTimeWarning),
        ));
      return;
    }
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final l = context.l10n;
    final notifier = ref.read(calendarMarksProvider.notifier);

    final wantsReminder = _reminder != ReminderMode.none;
    var allowed = true;
    if (wantsReminder) {
      allowed = await ref.read(reminderSchedulerProvider).requestPermission();
    }

    final times = _reminder == ReminderMode.none
        ? const <int>[]
        : (_reminder == ReminderMode.once
            ? [(_times.isEmpty ? defaultReminderMinutes : _times.first)]
            : normalizeTimes(_times));
    await notifier.save(CalendarMark(
      id: _editingId ?? notifier.newId(),
      date: _editingStart ?? widget.date,
      type: _type,
      emoji: _emoji,
      label: _label.text.trim(),
      details: _details.text.trim(),
      reminderMode: _reminder,
      reminderTimes: times,
      repeat: _repeat,
      homeMode: _home,
      homeMinutes: _homeMinutes,
    ));
    // The mark is saved either way. But if the system back button (or
    // anything else) already closed this sheet while we were awaiting above,
    // there is nothing left of this route to pop — the Navigator's next entry
    // underneath may not even be a page that expects a pop right now. Only
    // finish the UI side of Save if the sheet (and its BuildContext) are
    // still there.
    if (!mounted) return;
    navigator.pop();
    if (wantsReminder && !allowed) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(l.notificationsOffWarning),
          duration: const Duration(seconds: 7),
        ));
    }
  }

  Future<void> _delete() async {
    final id = _editingId;
    if (id == null) return;
    final l = context.l10n;
    final repeats = _repeat != RepeatRule.once;
    final title = _label.text.trim().isEmpty
        ? l.deleteMarkFallbackTitle
        : '“${_label.text.trim()}”';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.deleteMarkQuestion),
        content: Text(repeats
            ? l.deleteMarkRepeatsBody(title)
            : l.deleteMarkBody(title)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.actionDelete)),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final navigator = Navigator.of(context);
    await ref.read(calendarMarksProvider.notifier).delete(id);
    // As in _save(): only pop if the sheet (and this route) are still here.
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final b = theme.brightness;
    final l = context.l10n;
    final marks = ref.watch(calendarMarksProvider);
    final onDate = [
      for (final m in marks)
        if (m.occursOn(widget.date)) m,
    ];
    final heading = _editingStart != null && _repeat != RepeatRule.once
        ? formatShortDate(context, _editingStart!)
        : formatShortDate(context, widget.date);

    Widget section(String title, Widget child, {String? hint}) => Padding(
          padding: const EdgeInsets.only(top: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleSmall),
              if (hint != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(hint,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant)),
                ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        );

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_editingId == null ? l.newMark : l.editMark,
                style: theme.textTheme.titleLarge),
            Text(
              MaterialLocalizations.of(context).formatFullDate(widget.date),
              key: const ValueKey('editor-date'),
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (_editingId != null && _repeat != RepeatRule.once)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.repeatFromNotice(repeatSummary(context, _repeat), heading),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ),

            // Several marks can share a date: pick one, or add another.
            if (onDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final m in onDate)
                      ChoiceChip(
                        key: ValueKey('existing-${m.id}'),
                        label: Text(
                            '${m.emoji ?? ''} ${m.titleIn(l)}'.trim(),
                            overflow: TextOverflow.ellipsis),
                        selected: _editingId == m.id,
                        onSelected: (_) => setState(() => _load(m)),
                      ),
                    ChoiceChip(
                      key: const ValueKey('new-mark'),
                      avatar: const Icon(Icons.add, size: 18),
                      label: Text(l.newMark),
                      selected: _editingId == null,
                      onSelected: (_) => setState(() => _load(null)),
                    ),
                  ],
                ),
              ),

            section(
              l.markTypeSectionTitle,
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final t in MarkType.values)
                    ChoiceChip(
                      key: ValueKey('type-${t.name}'),
                      avatar: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: MarkPalette.base(t, b),
                          border: Border.all(
                              color: MarkPalette.outline(t, b), width: 1.5),
                        ),
                      ),
                      label: Text(t.localized(l)),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
            ),

            section(
              l.iconSectionTitle,
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    key: const ValueKey('emoji-none'),
                    label: Text(l.iconNone),
                    selected: _emoji == null,
                    onSelected: (_) => setState(() => _emoji = null),
                  ),
                  for (final e in markEmojis)
                    Tooltip(
                      message: emojiName(l, e),
                      child: ChoiceChip(
                        key: ValueKey('emoji-$e'),
                        showCheckmark: false,
                        label: Text(e, style: const TextStyle(fontSize: 20)),
                        selected: _emoji == e,
                        onSelected: (_) => setState(() => _emoji = e),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            TextField(
              key: const ValueKey('label-field'),
              controller: _label,
              maxLength: maxLabelLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.labelFieldLabel),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const ValueKey('details-field'),
              controller: _details,
              maxLength: maxDetailsLength,
              minLines: 2,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.detailsFieldLabel,
                alignLabelWithHint: true,
              ),
            ),

            section(
              l.remindMeAtSectionTitle,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final r in ReminderMode.values)
                        ChoiceChip(
                          key: ValueKey('reminder-${r.name}'),
                          label: Text(r.localized(l)),
                          selected: _reminder == r,
                          onSelected: (_) => setState(() {
                            _reminder = r;
                            if (r == ReminderMode.once && _times.isEmpty) {
                              _times = [defaultReminderMinutes];
                            }
                          }),
                        ),
                    ],
                  ),
                  if (_reminder == ReminderMode.once)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        key: const ValueKey('reminder-time-once'),
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(formatMinutes(
                            context,
                            _times.isEmpty
                                ? defaultReminderMinutes
                                : _times.first)),
                        onPressed: () async {
                          final t = await _pickTime(_times.isEmpty
                              ? defaultReminderMinutes
                              : _times.first);
                          if (t != null) setState(() => _times = [t]);
                        },
                      ),
                    ),
                  if (_reminder == ReminderMode.several)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (final t in normalizeTimes(_times))
                            InputChip(
                              key: ValueKey('reminder-time-$t'),
                              label: Text(formatMinutes(context, t)),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              deleteButtonTooltipMessage:
                                  l.removeTimeTooltip(formatMinutes(context, t)),
                              onDeleted: () => setState(
                                  () => _times = [..._times]..remove(t)),
                            ),
                          if (_times.length < maxReminderTimes)
                            ActionChip(
                              key: const ValueKey('add-time'),
                              avatar: const Icon(Icons.add, size: 18),
                              label: Text(l.addTime),
                              onPressed: () async {
                                final last = _times.isEmpty
                                    ? defaultReminderMinutes
                                    : normalizeTimes(_times).last;
                                final t = await _pickTime(
                                    (last + 60) % (24 * 60));
                                if (t != null) {
                                  setState(() =>
                                      _times = normalizeTimes([..._times, t]));
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            section(
              l.repeatSectionTitle,
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final r in RepeatRule.values)
                    ChoiceChip(
                      key: ValueKey('repeat-${r.name}'),
                      label: Text(r.localized(l)),
                      selected: _repeat == r,
                      onSelected: (_) => setState(() => _repeat = r),
                    ),
                ],
              ),
            ),

            section(
              l.onHomeScreenSectionTitle,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final h in HomeMode.values)
                        ChoiceChip(
                          key: ValueKey('home-${h.name}'),
                          label: Text(h.localized(l)),
                          selected: _home == h,
                          onSelected: (_) => setState(() => _home = h),
                        ),
                    ],
                  ),
                  if (_home == HomeMode.morning)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: OutlinedButton.icon(
                        key: const ValueKey('home-time'),
                        icon: const Icon(Icons.wb_sunny_outlined, size: 18),
                        label: Text(
                            l.showFromTime(formatMinutes(context, _homeMinutes))),
                        onPressed: () async {
                          final t = await _pickTime(_homeMinutes);
                          if (t != null) setState(() => _homeMinutes = t);
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      switch (_home) {
                        HomeMode.none => l.homeModeNoneExplain,
                        HomeMode.morning => l.homeModeMorningExplain,
                        HomeMode.allDay => l.homeModeAllDayExplain,
                      },
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),
            Row(
              children: [
                if (_editingId != null)
                  TextButton.icon(
                    key: const ValueKey('delete-mark'),
                    onPressed: _delete,
                    icon: Icon(Icons.delete_outline, color: scheme.error),
                    label: Text(l.actionDelete,
                        style: TextStyle(color: scheme.error)),
                  ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.actionCancel),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const ValueKey('save-mark'),
                  onPressed: _saving ? null : _save,
                  child: Text(l.actionSave),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
