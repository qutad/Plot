import 'package:flutter/material.dart';
import 'package:plot/core/theme/plot_theme.dart';
import 'package:plot/features/habits/domain/habit.dart';

class ContributionCalendar extends StatefulWidget {
  const ContributionCalendar({
    required this.habit,
    required this.onToggleDay,
    this.compact = false,
    this.today,
    super.key,
  });

  static const _weeks = 52;
  static const _cellSize = 12.0;
  static const _cellGap = 4.0;
  static const _monthHeaderHeight = 24.0;

  final Habit habit;
  final Future<void> Function(DateTime day) onToggleDay;
  final bool compact;
  final DateTime? today;

  static List<DateTime> daysEndingOn(DateTime today) {
    final end = Habit.civilDate(today);
    final start = Habit.startOfLast52Weeks(end);

    return [
      for (var index = 0; index < Habit.daysInLast52Weeks; index++)
        Habit.addCivilDays(start, index),
    ];
  }

  @override
  State<ContributionCalendar> createState() => _ContributionCalendarState();
}

class _ContributionCalendarState extends State<ContributionCalendar> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.compact) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLatest();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.jumpTo(
      _scrollController.position.maxScrollExtent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = Habit.civilDate(widget.today ?? DateTime.now());
    final days = ContributionCalendar.daysEndingOn(today);

    return Container(
      key: const Key('contribution-calendar'),
      width: double.infinity,
      padding: EdgeInsets.all(widget.compact ? 14 : 22),
      decoration: BoxDecoration(
        color: PlotTheme.surface,
        border: Border.all(color: PlotTheme.border),
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.compact) ...[
                _WeekdayLabels(firstDay: days.first),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: SingleChildScrollView(
                  key: const Key('calendar-horizontal-scroll'),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MonthLabels(days: days),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (
                            var week = 0;
                            week < ContributionCalendar._weeks;
                            week++
                          ) ...[
                            Column(
                              children: [
                                for (
                                  var weekday = 0;
                                  weekday < DateTime.daysPerWeek;
                                  weekday++
                                )
                                  _CalendarCell(
                                    day:
                                        days[(week * DateTime.daysPerWeek) +
                                            weekday],
                                    color: widget.habit.color,
                                    planted: widget.habit.plantedDays.contains(
                                      days[(week * DateTime.daysPerWeek) +
                                          weekday],
                                    ),
                                    enabled:
                                        !days[(week * DateTime.daysPerWeek) +
                                                weekday]
                                            .isAfter(today),
                                    onTap: widget.onToggleDay,
                                  ),
                              ],
                            ),
                            const SizedBox(
                              width: ContributionCalendar._cellGap,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: widget.compact ? 20 : 26),
          Align(
            alignment: Alignment.centerRight,
            child: _CalendarLegend(color: widget.habit.color),
          ),
        ],
      ),
    );
  }
}

class _WeekdayLabels extends StatelessWidget {
  const _WeekdayLabels({required this.firstDay});

  final DateTime firstDay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: ContributionCalendar._monthHeaderHeight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var weekday = 0; weekday < DateTime.daysPerWeek; weekday++)
            SizedBox(
              width: 26,
              height:
                  ContributionCalendar._cellSize +
                  ContributionCalendar._cellGap,
              child: _labelForRow(weekday).isNotEmpty
                  ? Text(
                      _labelForRow(weekday),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PlotTheme.muted,
                        fontFamily: PlotTheme.monoFont,
                        fontSize: 9,
                      ),
                    )
                  : null,
            ),
        ],
      ),
    );
  }

  String _labelForRow(int row) {
    const labels = ['', 'Mon', '', 'Wed', '', 'Fri', '', ''];
    return labels[Habit.addCivilDays(firstDay, row).weekday];
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
                fontFamily: PlotTheme.monoFont,
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

class _CalendarCell extends StatefulWidget {
  const _CalendarCell({
    required this.day,
    required this.color,
    required this.planted,
    required this.enabled,
    required this.onTap,
  });

  final DateTime day;
  final Color color;
  final bool planted;
  final bool enabled;
  final Future<void> Function(DateTime day) onTap;

  @override
  State<_CalendarCell> createState() => _CalendarCellState();
}

class _CalendarCellState extends State<_CalendarCell> {
  bool _hovered = false;
  bool _updating = false;

  Future<void> _toggleDay() async {
    if (!widget.enabled || _updating) {
      return;
    }

    setState(() {
      _updating = true;
    });

    try {
      await widget.onTap(widget.day);
    } finally {
      if (mounted) {
        setState(() {
          _updating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: ContributionCalendar._cellGap,
      ),
      child: Semantics(
        button: widget.enabled,
        enabled: widget.enabled,
        selected: widget.planted,
        onTap: widget.enabled && !_updating ? _toggleDay : null,
        label:
            '${_formattedDate(widget.day)}, '
            '${widget.planted ? 'planted' : 'not planted'}'
            '${widget.enabled ? '' : ', unavailable future date'}',
        child: Tooltip(
          ignorePointer: true,
          richMessage: TextSpan(
            style: const TextStyle(
              color: PlotTheme.text,
              fontFamily: PlotTheme.monoFont,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            children: [
              TextSpan(text: _formattedDate(widget.day)),
              TextSpan(
                text: ' - ${widget.planted ? 'planted' : 'not planted'}',
                style: const TextStyle(
                  color: PlotTheme.muted,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: PlotTheme.surfaceRaised,
            border: Border.all(color: PlotTheme.border),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          margin: const EdgeInsets.all(8),
          verticalOffset: 14,
          child: ExcludeSemantics(
            child: InkWell(
              onTap: widget.enabled && !_updating ? _toggleDay : null,
              onHover: widget.enabled
                  ? (hovered) {
                      setState(() {
                        _hovered = hovered;
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(4),
              child: AnimatedScale(
                scale: _hovered ? 1.5 : 1,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: widget.enabled ? 1 : 0.3,
                  duration: const Duration(milliseconds: 140),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: ContributionCalendar._cellSize,
                    height: ContributionCalendar._cellSize,
                    decoration: BoxDecoration(
                      color: widget.planted
                          ? widget.color
                          : const Color(0xFF1B271F),
                      border: Border.all(
                        color: PlotTheme.border.withValues(alpha: 0.65),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formattedDate(DateTime date) {
    const weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    const months = [
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

    return '${weekdays[date.weekday - 1]}, '
        '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: PlotTheme.muted,
      fontFamily: PlotTheme.monoFont,
      fontSize: 10,
    );

    return Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 7,
      runSpacing: 6,
      children: [
        Text('Empty', style: textStyle),
        const _LegendCell(color: Color(0xFF1B271F)),
        _LegendCell(color: color),
        Text('Completed', style: textStyle),
      ],
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
