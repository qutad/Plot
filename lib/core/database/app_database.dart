import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Habits extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorValue => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class HabitEntries extends Table {
  TextColumn get habitId => text().references(Habits, #id)();
  DateTimeColumn get plantedOn => dateTime()();
  IntColumn get intensity => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {habitId, plantedOn};
}

@DriftDatabase(tables: [Habits, HabitEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documents = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(documents.path, 'plot.sqlite'));

    return NativeDatabase.createInBackground(dbFile);
  });
}
