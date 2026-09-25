import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../l10n/l10n.dart';
import '../application/calendar_marks_provider.dart';
import '../application/mark_style_provider.dart';
import '../application/now_provider.dart';
import '../data/calendar_mark.dart';
import 'widgets/mark_card.dart';
import 'widgets/mark_day_cell.dart';
import 'widgets/mark_editor_sheet.dart';
import 'widgets/mark_format.dart';
import 'widgets/mark_style_picker.dart';

/// Calendar tab: a month grid (previous / next month) where you mark dates as
/// Good, Cautious or Neutral, with an icon, a label, notes, reminders, a repeat
/// and an optional card on the Home tab. Everything is saved on the phone.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focused = dateOnly(ref.read(nowProvider));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l10n;
    final marks = ref.watch(calendarMarksProvider);
    final style = ref.watch(markStyleProvider);
    final now = ref.watch(nowProvider);
    final today = dateOnly(now);
    final inMonth = marksInMonth(marks, _focused);
    final monthName = MaterialLocalizations.of(context).formatMonthYear(_focused);

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: const ValueKey('go-today'),
                        onPressed: () => setState(() => _focused = today),
                        icon: const Icon(Icons.today, size: 18),
                        label: Text(l.today),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                    TableCalendar<void>(
                      // Month title and weekday names in the app's language.
                      locale: Localizations.localeOf(context).toString(),
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100, 12, 31),
                      focusedDay: _focused,
                      currentDay: now,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      availableGestures: AvailableGestures.horizontalSwipe,
                      rowHeight: MarkDayCell.rowHeight(context),
                      daysOfWeekHeight: 22,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      onPageChanged: (d) => setState(() => _focused = d),
                      onDaySelected: (selected, focused) {
                        setState(() => _focused = focused);
                        showMarkEditor(context, date: selected);
                      },
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: theme.textTheme.titleLarge!,
                        leftChevronIcon: Icon(Icons.chevron_left,
                            semanticLabel: l.previousMonth,
                            color: scheme.onSurface),
                        rightChevronIcon: Icon(Icons.chevron_right,
                            semanticLabel: l.nextMonth,
                            color: scheme.onSurface),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: theme.textTheme.labelMedium!
                            .copyWith(color: scheme.onSurfaceVariant),
                        weekendStyle: theme.textTheme.labelMedium!
                            .copyWith(color: scheme.onSurfaceVariant),
                      ),
                      calendarStyle:
                          const CalendarStyle(outsideDaysVisible: false),
                      calendarBuilders: CalendarBuilders(
                        // One renderer for every date (weekends and today
                        // included), so marks always look the same.
                        prioritizedBuilder: (context, day, focusedDay) =>
                            MarkDayCell(
                          day: day,
                          marks: marksOnDay(marks, day),
                          style: style,
                          isToday: isSameDay(day, now),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const MarkLegend(),
            const SizedBox(height: 12),
            const MarkStylePicker(),
            const SizedBox(height: 20),
            Text(l.marksInMonth(monthName), style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (inMonth.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l.noMarksInMonth(monthName),
                  key: const ValueKey('no-marks'),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              )
            else
              for (final e in inMonth)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: MarkCard(
                    key: ValueKey('month-card-${e.mark.id}'),
                    mark: e.mark,
                    dateLabel: formatShortDate(context, e.first),
                    onTap: () => showMarkEditor(context,
                        date: e.first, markId: e.mark.id),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
