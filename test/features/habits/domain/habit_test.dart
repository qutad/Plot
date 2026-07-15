import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plot/features/habits/domain/habit.dart';

void main() {
  test('last 52 weeks contains exactly 364 days ending today', () {
    final today = DateTime(2026, 7, 15);
    final start = Habit.startOfLast52Weeks(today);
    final habit = Habit(
      id: 'read',
      name: 'Read',
      color: Colors.green,
      plantedDays: {
        Habit.addCivilDays(start, -1),
        start,
        today,
        Habit.addCivilDays(today, 1),
      },
    );

    expect(Habit.daysInLast52Weeks, 364);
    expect(Habit.addCivilDays(start, Habit.daysInLast52Weeks - 1), today);
    expect(habit.daysPlantedInLast52Weeks(today: today), 2);
  });

  test('civil day stepping crosses daylight-saving calendar dates', () {
    final day = DateTime(2026, 3, 8);

    expect(Habit.addCivilDays(day, 1), DateTime(2026, 3, 9));
    expect(Habit.addCivilDays(day, -1), DateTime(2026, 3, 7));
  });
}
