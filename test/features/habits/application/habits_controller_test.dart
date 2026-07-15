import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plot/core/database/app_database.dart' show AppDatabase;
import 'package:plot/features/habits/application/habits_controller.dart';
import 'package:plot/features/habits/data/habits_repository.dart';
import 'package:plot/features/habits/domain/habit.dart';

void main() {
  test('serializes rapid toggles without losing a different day', () async {
    final context = await _controllerContext();
    addTearDown(context.dispose);
    final controller = context.container.read(
      habitsControllerProvider.notifier,
    );

    final first = DateTime(2026, 7, 14);
    final second = DateTime(2026, 7, 15);
    await Future.wait([
      controller.togglePlantedDay(first, today: second),
      controller.togglePlantedDay(second, today: second),
    ]);

    final plantedDays = context.container
        .read(habitsControllerProvider)
        .requireValue
        .selectedHabit!
        .plantedDays;
    expect(plantedDays, containsAll(<DateTime>[first, second]));
  });

  test('rejects a future toggle at the controller boundary', () async {
    final context = await _controllerContext();
    addTearDown(context.dispose);
    final controller = context.container.read(
      habitsControllerProvider.notifier,
    );

    await expectLater(
      controller.togglePlantedDay(
        DateTime(2026, 7, 16),
        today: DateTime(2026, 7, 15),
      ),
      throwsArgumentError,
    );

    expect(
      context.container
          .read(habitsControllerProvider)
          .requireValue
          .selectedHabit!
          .plantedDays,
      isEmpty,
    );
  });
}

Future<_ControllerContext> _controllerContext() async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final repository = HabitsRepository(database);
  await repository.insertHabit(
    const Habit(
      id: 'read',
      name: 'Read',
      color: Colors.green,
      plantedDays: <DateTime>{},
    ),
  );
  await repository.markStarterHabitsInitialized();

  final container = ProviderContainer(
    overrides: [appDatabaseProvider.overrideWithValue(database)],
  );
  await container.read(habitsControllerProvider.future);
  return _ControllerContext(container, database);
}

class _ControllerContext {
  const _ControllerContext(this.container, this.database);

  final ProviderContainer container;
  final AppDatabase database;

  Future<void> dispose() async {
    container.dispose();
    await database.close();
  }
}
