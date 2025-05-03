import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/file_upload_screen_2.dart';
import 'package:rhythmrun/apple_music_test.dart';
import 'package:rhythmrun/spotify_test.dart';
import 'package:rhythmrun/main.dart';

void main() {
  testWidgets('WelcomePageWidget displays text and buttons correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomePageWidget(),
      ),
    );

    expect(find.text('Welcome to RhythmRun!'), findsOneWidget);

    expect(
      find.text('Choose your music listening preference to continue'),
      findsOneWidget,
    );

    expect(find.text('Import with Spotify'), findsOneWidget);
    expect(find.text('Import with Apple Music'), findsOneWidget);
    expect(find.text('Import with Local Music'), findsOneWidget);
  });

  testWidgets('Tapping Spotify button navigates to SpotifyTest screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomePageWidget(),
      ),
    );

    await tester.tap(find.text('Import with Spotify'));
    await tester.pumpAndSettle();

    expect(find.byType(SpotifyTest), findsOneWidget);
  });

  testWidgets('Tapping Apple Music button navigates to AppleMusicPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomePageWidget(),
      ),
    );

    await tester.tap(find.text('Import with Apple Music'));
    await tester.pumpAndSettle();

    expect(find.byType(AppleMusicPage), findsOneWidget);
  });

  testWidgets('Tapping Local Music button navigates to LocalSongsUploadPage', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: WelcomePageWidget(),
      ),
    );

    await tester.tap(find.text('Import with Local Music'));
    await tester.pumpAndSettle();

    expect(find.byType(LocalSongsUploadPage), findsOneWidget);
  });
}
