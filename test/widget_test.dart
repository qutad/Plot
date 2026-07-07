import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plot/app/plot_app.dart';

void main() {
  testWidgets('renders the Plot dashboard shell', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1000));

    await tester.pumpWidget(
      const ProviderScope(
        child: PlotApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Read'), findsWidgets);
    expect(find.text('Stretch'), findsOneWidget);
    expect(find.text('New habit'), findsOneWidget);
  });
}
