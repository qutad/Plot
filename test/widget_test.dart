import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plot/main.dart' as app;

void main() {
  testWidgets('renders the Plot dashboard shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    app.main();
    await tester.pumpAndSettle();

    expect(find.text('plot - habit calendars'), findsOneWidget);
    expect(find.text('Read'), findsWidgets);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
  });
}
