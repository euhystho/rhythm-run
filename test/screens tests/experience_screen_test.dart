import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/experience_screen_4.dart';
import 'package:rhythmrun/screens/duration_screen_5.dart';

void main() {
  testWidgets('ExperienceLevelPage displays experience level options and navigates on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ExperienceLevelPage(),
      ),
    );

    expect(find.text('How experienced are you as a runner?'), findsOneWidget);

    expect(find.text('Beginner'), findsOneWidget);
    expect(find.text('Intermediate'), findsOneWidget);
    expect(find.text('Advanced'), findsOneWidget);

    await tester.tap(find.text('Beginner'));
    await tester.pumpAndSettle();

    expect(find.byType(DurationPage), findsOneWidget);
  });
}
