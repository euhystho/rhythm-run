import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/intensity_screen_6.dart';
import 'package:rhythmrun/screens/temp_playlist_screen_7.dart';

void main() {
  testWidgets('IntensityPage displays intensity options and navigates on tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: IntensityPage(),
      ),
    );

    expect(find.text('How intense do you want your workout to be?'), findsOneWidget);

    expect(find.text('Low'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('High'), findsOneWidget);

    await tester.tap(find.text('Low'));
    await tester.pumpAndSettle();

    expect(find.byType(TempPlaylistPage), findsOneWidget);
  });
}
