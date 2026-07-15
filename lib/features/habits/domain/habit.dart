import 'package:flutter/material.dart';

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.color,
    required this.plantedDays,
  });

  final String id;
  final String name;
  final Color color;
  final Set<DateTime> plantedDays;

  static const int daysInLast52Weeks = 52 * DateTime.daysPerWeek;

  static DateTime civilDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime addCivilDays(DateTime date, int days) {
    return DateTime(date.year, date.month, date.day + days);
  }

  static DateTime startOfLast52Weeks(DateTime today) {
    return addCivilDays(civilDate(today), -(daysInLast52Weeks - 1));
  }

  Habit copyWith({String? name, Color? color, Set<DateTime>? plantedDays}) {
    return Habit(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      plantedDays: plantedDays ?? this.plantedDays,
    );
  }

  int get currentStreak {
    final normalizedDays = _normalizedPlantedDays;
    final today = civilDate(DateTime.now());
    final startDay = normalizedDays.contains(today)
        ? today
        : addCivilDays(today, -1);

    var streak = 0;
    var cursor = startDay;

    while (normalizedDays.contains(cursor)) {
      streak++;
      cursor = addCivilDays(cursor, -1);
    }

    return streak;
  }

  int get longestStreak {
    final sortedDays = _normalizedPlantedDays.toList()..sort();

    if (sortedDays.isEmpty) {
      return 0;
    }

    var longest = 1;
    var current = 1;

    for (var index = 1; index < sortedDays.length; index++) {
      final previous = sortedDays[index - 1];
      final currentDay = sortedDays[index];
      final expectedNext = addCivilDays(previous, 1);

      if (currentDay == expectedNext) {
        current++;
      } else {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  int get daysPlantedLast52Weeks {
    return daysPlantedInLast52Weeks();
  }

  int daysPlantedInLast52Weeks({DateTime? today}) {
    final end = civilDate(today ?? DateTime.now());
    final start = startOfLast52Weeks(end);

    return _normalizedPlantedDays.where((day) {
      return !day.isBefore(start) && !day.isAfter(end);
    }).length;
  }

  Set<DateTime> get _normalizedPlantedDays {
    return {
      for (final day in plantedDays) civilDate(day),
    };
  }
}
