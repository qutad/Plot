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
  final String? selectedHabitId;

  Habit? get selectedHabit {
    for (final habit in habits) {
      if (habit.id == selectedHabitId) {
        return habit;
      }
    }
    return null;
  }
}

class HabitsController extends AsyncNotifier<HabitsState> {
  Future<void> _toggleQueue = Future<void>.value();

  @override
  Future<HabitsState> build() async {
    final repository = ref.watch(habitsRepositoryProvider);
    final habits = await repository.loadHabits();
    final initialized = await repository.areStarterHabitsInitialized();

    if (habits.isNotEmpty) {
      if (!initialized) {
        await repository.markStarterHabitsInitialized();
      }

      return HabitsState(
        habits: habits,
        selectedHabitId: habits.first.id,
      );
    }

    if (initialized) {
      return const HabitsState(
        habits: [],
        selectedHabitId: null,
      );
    }

    final starterHabits = _starterHabits();

    for (final habit in starterHabits) {
      await repository.insertHabit(habit);

      for (final day in habit.plantedDays) {
        await repository.toggleHabitEntry(habitId: habit.id, day: day);
      }
    }

    await repository.markStarterHabitsInitialized();

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
    final selectedHabitId = current.selectedHabitId;

    if (selectedHabitId == null) {
      return;
    }

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
      HabitsState(habits: habits, selectedHabitId: selectedHabitId),
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

  Future<void> togglePlantedDay(DateTime day, {DateTime? today}) {
    final current = state.requireValue;
    final selectedHabitId = current.selectedHabitId;

    if (selectedHabitId == null) {
      return Future<void>.value();
    }

    final date = Habit.civilDate(day);
    final currentDay = Habit.civilDate(today ?? DateTime.now());

    if (date.isAfter(currentDay)) {
      return Future<void>.error(
        ArgumentError.value(day, 'day', 'Cannot toggle a future date'),
      );
    }

    final operation = _toggleQueue.then(
      (_) => _togglePlantedDay(selectedHabitId, date),
    );
    _toggleQueue = operation.catchError((Object _) {});
    return operation;
  }

  Future<void> _togglePlantedDay(String habitId, DateTime date) async {
    final current = state.requireValue;

    if (!current.habits.any((habit) => habit.id == habitId)) {
      return;
    }

    final repository = ref.read(habitsRepositoryProvider);

    await repository.toggleHabitEntry(
      habitId: habitId,
      day: date,
    );

    final habits = [
      for (final habit in current.habits)
        if (habit.id == habitId)
          habit.copyWith(
            plantedDays: habit.plantedDays.contains(date)
                ? ({...habit.plantedDays}..remove(date))
                : {...habit.plantedDays, date},
          )
        else
          habit,
    ];

    state = AsyncData(
      HabitsState(
        habits: habits,
        selectedHabitId: current.selectedHabitId,
      ),
    );
  }

  Future<void> deleteSelectedHabit() async {
    final current = state.requireValue;
    final habitId = current.selectedHabitId;

    if (habitId == null) {
      return;
    }

    final repository = ref.read(habitsRepositoryProvider);

    await repository.deleteHabit(habitId);

    final habits = [
      for (final habit in current.habits)
        if (habit.id != habitId) habit,
    ];

    if (habits.isEmpty) {
      state = const AsyncData(
        HabitsState(
          habits: [],
          selectedHabitId: null,
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
    final today = Habit.civilDate(DateTime.now());

    return [
      Habit(
        id: 'read',
        name: 'Read',
        color: const Color(0xFFE3B567),
        plantedDays: {Habit.addCivilDays(today, -1), today},
      ),
      Habit(
        id: 'stretch',
        name: 'Stretch',
        color: const Color(0xFF69AC9A),
        plantedDays: {Habit.addCivilDays(today, -4)},
      ),
    ];
  }
}
