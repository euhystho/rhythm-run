import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/loading_screen_3.dart';

void main() {
  testWidgets('LoadingPage displays loading text and spinner', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LoadingPage(),
    ));

    expect(find.text('Analyzing BPM...'), findsOneWidget);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
