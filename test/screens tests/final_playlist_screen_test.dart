import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/final_playlist_screen_8.dart';

void main() {
  testWidgets('FinalPlaylistPage displays text and buttons correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    expect(find.text('Final Playlist'), findsOneWidget);

    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.skip_next), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous), findsOneWidget);
    expect(find.byIcon(Icons.shuffle), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
  });

  testWidgets('Tapping play toggles isPlaying', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<FinalPlaylistPageState>(find.byType(FinalPlaylistPage));
    expect(state.isPlaying, false);

    await tester.tap(find.byIcon(Icons.play_arrow));
    await tester.pump();

    expect(state.isPlaying, true);
    expect(find.byIcon(Icons.pause), findsOneWidget);
  });

  testWidgets('Tapping shuffle toggles isShuffling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<FinalPlaylistPageState>(find.byType(FinalPlaylistPage));
    expect(state.isShuffling, false);

    await tester.tap(find.byIcon(Icons.shuffle));
    await tester.pump();

    expect(state.isShuffling, true);
    expect(find.byIcon(Icons.shuffle_on), findsOneWidget);
  });

  testWidgets('Tapping loop toggles isLooping', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<FinalPlaylistPageState>(find.byType(FinalPlaylistPage));
    expect(state.isLooping, false);

    await tester.tap(find.byIcon(Icons.repeat));
    await tester.pump();

    expect(state.isLooping, true);
    expect(find.byIcon(Icons.repeat_one), findsOneWidget);
  });

  testWidgets('Tapping skip next updates currentSongIndex', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<FinalPlaylistPageState>(find.byType(FinalPlaylistPage));
    final initialIndex = state.currentSongIndex;

    await tester.tap(find.byIcon(Icons.skip_next));
    await tester.pumpAndSettle();

    expect(state.currentSongIndex, (initialIndex + 1) % state.songList.tracks.length);
  });

  testWidgets('Tapping skip previous updates currentSongIndex', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: FinalPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<FinalPlaylistPageState>(find.byType(FinalPlaylistPage));
    state.setState(() {
      state.currentSongIndex = 2;
    });
    await tester.pump();

    await tester.tap(find.byIcon(Icons.skip_previous));
    await tester.pumpAndSettle();

    expect(state.currentSongIndex, 1);
  });
}
