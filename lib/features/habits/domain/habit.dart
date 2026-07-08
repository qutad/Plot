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
    final today = DateUtils.dateOnly(DateTime.now());
    final startDay = normalizedDays.contains(today)
        ? today
        : today.subtract(const Duration(days: 1));

    var streak = 0;
    var cursor = startDay;

    while (normalizedDays.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
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
      final expectedNext = previous.add(const Duration(days: 1));

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
    final today = DateUtils.dateOnly(DateTime.now());
    final start = today.subtract(const Duration(days: 364));

    return _normalizedPlantedDays.where((day) {
      return !day.isBefore(start) && !day.isAfter(today);
    }).length;
  }

  Set<DateTime> get _normalizedPlantedDays {
    return {
      for (final day in plantedDays) DateUtils.dateOnly(day),
    };
  }
}
