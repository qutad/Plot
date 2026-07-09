import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plot/app/plot_app.dart';
import 'package:plot/core/database/app_database.dart';
import 'package:plot/features/habits/data/habits_repository.dart';

void main() {
  testWidgets('renders the Plot dashboard shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsWidgets);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
  });

  testWidgets('creates a new habit from the sidebar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();

    expect(find.text('New habit'), findsWidgets);

    await tester.enterText(find.byType(EditableText), 'Write');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Write'), findsWidgets);
  });

  testWidgets('loads a created habit after app remount', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await _pumpPlotApp(tester, database: database);
    await tester.pumpAndSettle();

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText), 'Journal');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await _pumpPlotApp(tester, database: database);
    await tester.pumpAndSettle();

    expect(find.text('Journal'), findsWidgets);
  });
}

Future<void> _pumpPlotApp(
  WidgetTester tester, {
  AppDatabase? database,
}) async {
  final appDatabase =
      database ?? AppDatabase.forTesting(NativeDatabase.memory());

  if (database == null) {
    addTearDown(appDatabase.close);
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(appDatabase)],
      child: const PlotApp(),
    ),
  );
}
