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
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('desktop-dashboard')), findsOneWidget);
    expect(find.byKey(const Key('mobile-dashboard')), findsNothing);
    expect(find.text('Read'), findsWidgets);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
  });

  testWidgets('renders the compact dashboard on a phone', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mobile-dashboard')), findsOneWidget);
    expect(find.byKey(const Key('desktop-dashboard')), findsNothing);
    expect(find.byTooltip('Add habit'), findsOneWidget);
    expect(find.text('Read'), findsWidgets);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.byKey(const Key('mobile-statistics')), findsOneWidget);
    expect(find.text('CURRENT\nSTREAK'), findsOneWidget);
    expect(find.text('LONGEST\nSTREAK'), findsOneWidget);
    expect(find.text('DAYS\nPLANTED'), findsOneWidget);
    expect(find.byKey(const Key('contribution-calendar')), findsOneWidget);
    expect(
      find.byKey(const Key('calendar-horizontal-scroll')),
      findsOneWidget,
    );
    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Wed'), findsOneWidget);
    expect(find.text('Fri'), findsOneWidget);
    expect(find.text('Empty'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(
      find.text('Tap a day to plant it. Tap again to clear it.'),
      findsOneWidget,
    );

    final calendarScroll = tester.widget<SingleChildScrollView>(
      find.byKey(const Key('calendar-horizontal-scroll')),
    );

    expect(calendarScroll.controller, isNotNull);
    expect(
      calendarScroll.controller!.offset,
      closeTo(
        calendarScroll.controller!.position.maxScrollExtent,
        0.1,
      ),
    );

    expect(find.byTooltip('Habit actions'), findsOneWidget);

    await tester.tap(find.byTooltip('Habit actions'));
    await tester.pumpAndSettle();

    expect(find.text('Edit habit'), findsOneWidget);
    expect(find.text('Delete habit'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a habit from the mobile bottom sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Add habit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habit-form-sheet')), findsOneWidget);
    expect(find.byKey(const Key('habit-form-dialog')), findsNothing);

    await tester.tap(find.byKey(const Key('habit-form-save')));
    await tester.pump();
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('habit-name-field')), 'Write');
    await tester.tap(find.byKey(const Key('habit-form-save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habit-form-sheet')), findsNothing);
    expect(find.text('Write'), findsWidgets);
  });

  testWidgets('edits a habit from the mobile bottom sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Habit actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit habit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habit-form-sheet')), findsOneWidget);
    expect(find.byKey(const Key('habit-form-dialog')), findsNothing);
    final nameField = tester.widget<EditableText>(find.byType(EditableText));
    expect(nameField.controller.text, 'Read');

    await tester.enterText(find.byKey(const Key('habit-name-field')), 'Books');
    await tester.tap(find.byKey(const Key('habit-form-save')));
    await tester.pumpAndSettle();

    expect(find.text('Books'), findsWidgets);
  });

  testWidgets('adapts compact statistics to large text', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(() {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      return tester.binding.setSurfaceSize(null);
    });

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('mobile-statistics')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates a new habit from the sidebar', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _pumpPlotApp(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('New habit'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('habit-form-dialog')), findsOneWidget);
    expect(find.byKey(const Key('habit-form-sheet')), findsNothing);
    expect(find.text('New habit'), findsWidgets);

    await tester.enterText(find.byType(EditableText), 'Write');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Write'), findsWidgets);
  });

  testWidgets('loads a created habit after app remount', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
      overrides: [
        appDatabaseProvider.overrideWithValue(appDatabase),
      ],
      child: const PlotApp(),
    ),
  );
}
