import 'package:flutter_test/flutter_test.dart';
import 'package:plot/features/habits/domain/habit.dart';
import 'package:plot/widgets/contribution_calendar.dart';

void main() {
  test('calendar exposes 52 complete weeks ending today without futures', () {
    final today = DateTime(2026, 7, 15);
    final days = ContributionCalendar.daysEndingOn(today);

    expect(days, hasLength(Habit.daysInLast52Weeks));
    expect(days.first, Habit.startOfLast52Weeks(today));
    expect(days.last, today);
    expect(days.where((day) => day.isAfter(today)), isEmpty);
    expect(days.toSet(), hasLength(Habit.daysInLast52Weeks));
  });
}
