import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/duration_screen_5.dart';
import 'package:rhythmrun/screens/intensity_screen_6.dart';

void main() {
  testWidgets('DurationPage displays duration options and navigates on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: DurationPage(),
      ),
    );

    expect(find.text('Approximately how long do you want your workout to be?'), findsOneWidget);

    expect(find.text('Short: 10-15 minutes'), findsOneWidget);
    expect(find.text('Medium: 15-20 minutes'), findsOneWidget);
    expect(find.text('Long: 20-25 minutes'), findsOneWidget);

    await tester.tap(find.text('Short: 10-15 minutes'));
    await tester.pumpAndSettle();

    expect(find.byType(IntensityPage), findsOneWidget);
  });
}
