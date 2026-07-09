import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plot/core/database/app_database.dart' as db;
import 'package:plot/features/habits/domain/habit.dart' as domain;

final appDatabaseProvider = Provider<db.AppDatabase>((ref) {
  final database = db.AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  return HabitsRepository(ref.watch(appDatabaseProvider));
});

class HabitsRepository {
  const HabitsRepository(this._database);

  final db.AppDatabase _database;

  Future<List<domain.Habit>> loadHabits() async {
    final habitRows = await _database.select(_database.habits).get();
    final entryRows = await _database.select(_database.habitEntries).get();

    habitRows.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return [
      for (final habit in habitRows)
        domain.Habit(
          id: habit.id,
          name: habit.name,
          color: Color(habit.colorValue),
          plantedDays: {
            for (final entry in entryRows)
              if (entry.habitId == habit.id)
                DateUtils.dateOnly(entry.plantedOn),
          },
        ),
    ];
  }

  Future<void> insertHabit(domain.Habit habit) {
    return _database
        .into(_database.habits)
        .insert(
          db.HabitsCompanion.insert(
            id: habit.id,
            name: habit.name,
            colorValue: habit.color.toARGB32(),
            createdAt: DateTime.now(),
          ),
        );
  }

  Future<void> updateHabit(domain.Habit habit) {
    return (_database.update(
      _database.habits,
    )..where((row) => row.id.equals(habit.id))).write(
      db.HabitsCompanion(
        name: Value(habit.name),
        colorValue: Value(habit.color.toARGB32()),
      ),
    );
  }

  Future<void> deleteHabit(String habitId) async {
    await (_database.delete(_database.habitEntries,)
      ..where((row) => row.habitId.equals(habitId)))
      .go();

    await (_database.delete(_database.habits,)
      ..where((row) => row.id.equals(habitId)))
      .go();
  }

  Future<void> toggleHabitEntry({
    required String habitId,
    required DateTime day,
  }) async {
    final date = DateUtils.dateOnly(day);

    final existing =
        await (_database.select(_database.habitEntries)..where(
              (row) => row.habitId.equals(habitId) & row.plantedOn.equals(date),
            ))
            .getSingleOrNull();

    if (existing == null) {
      await _database
          .into(_database.habitEntries)
          .insert(
            db.HabitEntriesCompanion.insert(
              habitId: habitId,
              plantedOn: date,
            ),
          );
      return;
    }

    await (_database.delete(_database.habitEntries)..where(
          (row) => row.habitId.equals(habitId) & row.plantedOn.equals(date),
        ))
        .go();
  }
}
