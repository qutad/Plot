import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plot/core/theme/plot_theme.dart';
import 'package:plot/features/habits/domain/habit.dart';

class ContributionCalendar extends StatelessWidget {
  const ContributionCalendar({
    required this.habit,
    required this.onToggleDay,
    super.key,
  });

  static const _weeks = 52;
  static const _cellSize = 16.0;
  static const _cellGap = 6.0;

  final Habit habit;
  final Future<void> Function(DateTime day) onToggleDay;

  @override
  Widget build(BuildContext context) {
    final days = _calendarDays();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: PlotTheme.surface,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MonthLabels(days: days),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var week = 0; week < _weeks; week++) ...[
                  Column(
                    children: [
                      for (
                        var weekday = 0;
                        weekday < DateTime.daysPerWeek;
                        weekday++
                      )
                        _CalendarCell(
                          day: days[(week * DateTime.daysPerWeek) + weekday],
                          color: habit.color,
                          planted: habit.plantedDays.contains(
                            days[(week * DateTime.daysPerWeek) + weekday],
                          ),
                          onTap: onToggleDay,
                        ),
                    ],
                  ),
                  const SizedBox(width: _cellGap),
                ],
              ],
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 1030),
                Text(
                  'Less',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 8),
                for (final opacity in const [0.08, 0.25, 0.45, 0.7, 1.0]) ...[
                  _LegendCell(color: habit.color.withValues(alpha: opacity)),
                  const SizedBox(width: 6),
                ],
                Text(
                  'More',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime> _calendarDays() {
    final today = DateUtils.dateOnly(DateTime.now());
    final end = today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
    final start = end.subtract(
      const Duration(days: (_weeks * DateTime.daysPerWeek) - 1),
    );

    return [
      for (var index = 0; index < _weeks * DateTime.daysPerWeek; index++)
        start.add(Duration(days: index)),
    ];
  }
}

class _MonthLabels extends StatelessWidget {
  const _MonthLabels({required this.days});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  final List<DateTime> days;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var week = 0; week < ContributionCalendar._weeks; week++)
          SizedBox(
            width:
                ContributionCalendar._cellSize + ContributionCalendar._cellGap,
            child: Text(
              _labelForWeek(week),
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }

  String _labelForWeek(int week) {
    final day = days[week * DateTime.daysPerWeek];
    final previous = week == 0 ? null : days[(week - 1) * DateTime.daysPerWeek];

    if (previous == null || day.month != previous.month) {
      return _months[day.month - 1];
    }

    return '';
  }
}

class _CalendarCell extends StatelessWidget {
  const _CalendarCell({
    required this.day,
    required this.color,
    required this.planted,
    required this.onTap,
  });

  final DateTime day;
  final Color color;
  final bool planted;
  final Future<void> Function(DateTime day) onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ContributionCalendar._cellGap),
      child: Tooltip(
        message: '${day.month}/${day.day}/${day.year}',
        child: InkWell(
          onTap: () => unawaited(onTap(day)),
          borderRadius: BorderRadius.circular(4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: ContributionCalendar._cellSize,
            height: ContributionCalendar._cellSize,
            decoration: BoxDecoration(
              color: planted ? color : const Color(0xFF1B271F),
              border: Border.all(
                color: PlotTheme.border.withValues(alpha: 0.65),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendCell extends StatelessWidget {
  const _LegendCell({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const SizedBox.square(dimension: 14),
    );
  }
}
