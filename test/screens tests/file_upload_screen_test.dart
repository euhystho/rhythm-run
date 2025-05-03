import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/file_upload_screen_2.dart';

void main() {
  testWidgets('LocalSongsUploadPage displays text and button correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LocalSongsUploadPage(),
    ));

    expect(find.text('Import Songs'), findsOneWidget);

    expect(find.text('Select Music Files'), findsOneWidget);
    expect(find.text('Choose local audio files to import'), findsOneWidget);

    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.text('Choose Files'), findsOneWidget);
  });

  testWidgets('LocalSongsUploadPage disables button and shows loading indicator after tap', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: LocalSongsUploadPage(),
    ));

    final chooseFilesButton = find.byType(ElevatedButton).first;
    expect(chooseFilesButton, findsOneWidget);

    await tester.tap(chooseFilesButton);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
  });
}
