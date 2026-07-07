import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot/features/habits/domain/habit.dart';

final habitsControllerProvider =
    NotifierProvider<HabitsController, HabitsState>(
      HabitsController.new,
    );

class HabitsState {
  const HabitsState({required this.habits, required this.selectedHabitId});

  final List<Habit> habits;
  final String selectedHabitId;

  Habit get selectedHabit {
    return habits.firstWhere((habit) => habit.id == selectedHabitId);
  }
}

class HabitsController extends Notifier<HabitsState> {
  @override
  HabitsState build() {
    final today = DateUtils.dateOnly(DateTime.now());

    return HabitsState(
      selectedHabitId: 'read',
      habits: [
        Habit(
          id: 'read',
          name: 'Read',
          color: const Color(0xFFE3B567),
          plantedDays: {today.subtract(const Duration(days: 1)), today},
        ),
        Habit(
          id: 'stretch',
          name: 'Stretch',
          color: const Color(0xFF69AC9A),
          plantedDays: {today.subtract(const Duration(days: 4))},
        ),
      ],
    );
  }

  void selectHabit(String id) {
    state = HabitsState(habits: state.habits, selectedHabitId: id);
  }

  void updateSelectedHabit({required String name, required Color color}) {
    final habits = [
      for (final habit in state.habits)
        if (habit.id == state.selectedHabitId)
          habit.copyWith(name: name, color: color)
        else
          habit,
    ];

    state = HabitsState(habits: habits, selectedHabitId: state.selectedHabitId);
  }

  void togglePlantedDay(DateTime day) {
    final date = DateUtils.dateOnly(day);
    final habits = [
      for (final habit in state.habits)
        if (habit.id == state.selectedHabitId)
          habit.copyWith(
            plantedDays: habit.plantedDays.contains(date)
                ? ({...habit.plantedDays}..remove(date))
                : {...habit.plantedDays, date},
          )
        else
          habit,
    ];

    state = HabitsState(habits: habits, selectedHabitId: state.selectedHabitId);
  }
}
