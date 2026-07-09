import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot/features/habits/data/habits_repository.dart';
import 'package:plot/features/habits/domain/habit.dart';

final habitsControllerProvider =
    AsyncNotifierProvider<HabitsController, HabitsState>(
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

class HabitsController extends AsyncNotifier<HabitsState> {
  @override
  Future<HabitsState> build() async {
    final repository = ref.watch(habitsRepositoryProvider);
    final habits = await repository.loadHabits();

    if (habits.isNotEmpty) {
      return HabitsState(habits: habits, selectedHabitId: habits.first.id);
    }

    final starterHabits = _starterHabits();

    for (final habit in starterHabits) {
      await repository.insertHabit(habit);

      for (final day in habit.plantedDays) {
        await repository.toggleHabitEntry(habitId: habit.id, day: day);
      }
    }

    return HabitsState(
      habits: starterHabits,
      selectedHabitId: starterHabits.first.id,
    );
  }

  void selectHabit(String id) {
    final current = state.requireValue;
    state = AsyncData(HabitsState(habits: current.habits, selectedHabitId: id));
  }

  Future<void> updateSelectedHabit({
    required String name,
    required Color color,
  }) async {
    final current = state.requireValue;
    final repository = ref.read(habitsRepositoryProvider);
    final habits = [
      for (final habit in current.habits)
        if (habit.id == current.selectedHabitId)
          habit.copyWith(name: name, color: color)
        else
          habit,
    ];
    final updatedHabit = habits.firstWhere(
      (habit) => habit.id == current.selectedHabitId,
    );

    await repository.updateHabit(updatedHabit);

    state = AsyncData(
      HabitsState(habits: habits, selectedHabitId: current.selectedHabitId),
    );
  }

  Future<void> addHabit({required String name, required Color color}) async {
    final current = state.requireValue;
    final repository = ref.read(habitsRepositoryProvider);
    final slug = name.toLowerCase().replaceAll(' ', '-');
    final id = '$slug-${DateTime.now().microsecondsSinceEpoch}';
    final habit = Habit(
      id: id,
      name: name,
      color: color,
      plantedDays: const <DateTime>{},
    );

    await repository.insertHabit(habit);

    state = AsyncData(
      HabitsState(
        habits: [...current.habits, habit],
        selectedHabitId: habit.id,
      ),
    );
  }

  Future<void> togglePlantedDay(DateTime day) async {
    final current = state.requireValue;
    final repository = ref.read(habitsRepositoryProvider);
    final date = DateUtils.dateOnly(day);

    await repository.toggleHabitEntry(
      habitId: current.selectedHabitId,
      day: date,
    );

    final habits = [
      for (final habit in current.habits)
        if (habit.id == current.selectedHabitId)
          habit.copyWith(
            plantedDays: habit.plantedDays.contains(date)
                ? ({...habit.plantedDays}..remove(date))
                : {...habit.plantedDays, date},
          )
        else
          habit,
    ];

    state = AsyncData(
      HabitsState(habits: habits, selectedHabitId: current.selectedHabitId),
    );
  }

  Future<void> deleteSelectedHabit() async {
    final current = state.requireValue;
    final repository = ref.read(habitsRepositoryProvider);
    final habitId = current.selectedHabitId;

    await repository.deleteHabit(habitId);

    final habits = [
      for (final habit in current.habits)
        if (habit.id != habitId) habit,
    ];

    if (habits.isEmpty) {
      final starterHabits = _starterHabits();

      for (final habit in starterHabits) {
        await repository.insertHabit(habit);

        for (final day in habit.plantedDays) {
          await repository.toggleHabitEntry(habitId: habit.id, day: day);
        }
      }

      state = AsyncData(
        HabitsState(
          habits: starterHabits,
          selectedHabitId: starterHabits.first.id,
        ),
      );
      return;
    }

    state = AsyncData(
      HabitsState(
        habits: habits,
        selectedHabitId: habits.first.id,
      ),
    );
  }

  List<Habit> _starterHabits() {
    final today = DateUtils.dateOnly(DateTime.now());

    return [
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
    ];
  }
}
