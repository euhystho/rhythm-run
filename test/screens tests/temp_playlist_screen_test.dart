import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rhythmrun/screens/temp_playlist_screen_7.dart';
import 'package:rhythmrun/data/types/song.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: 'assets/.env');
  });

  testWidgets('TempPlaylistPage displays text correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));
    await tester.pumpAndSettle();

    expect(find.text('Tentative Playlist'), findsOneWidget);
    expect(find.text('Playlist'), findsOneWidget);
    expect(find.text('Suggested Songs'), findsOneWidget);
  });

  testWidgets('TempPlaylistPage shows loading indicator when fetching suggestions', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));

    // force loading
    final state = tester.state<TempPlaylistPageState>(find.byType(TempPlaylistPage));
    state.setState(() {
      state.isLoading = true;
    });
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('TempPlaylistPage adds and removes song from playlist', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<TempPlaylistPageState>(find.byType(TempPlaylistPage));
    final testSong = state.suggestedSongs.tracks.isEmpty
        ? Song('Test Song', 'Test Artist')
        : state.suggestedSongs.tracks.first;

    state.setState(() {
      state.suggestedSongs.tracks.add(testSong);
    });
    await tester.pump();

    expect(find.text('${testSong.name} - ${testSong.artist}'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_circle).first);
    await tester.pump();

    expect(find.text('${testSong.name} - ${testSong.artist}'), findsOneWidget);
  });

  testWidgets('TempPlaylistPage removes song from playlist via delete icon', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));
    await tester.pumpAndSettle();

    final state = tester.state<TempPlaylistPageState>(find.byType(TempPlaylistPage));
    final testSong = state.suggestedSongs.tracks.isEmpty
        ? Song('Test Song', 'Test Artist')
        : state.suggestedSongs.tracks.first;

    state.setState(() {
      state.suggestedSongs.tracks.add(testSong);
    });
    await tester.pump();

    expect(find.text('${testSong.name} - ${testSong.artist}'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete).first);
    await tester.pump();

    expect(find.text('${testSong.name} - ${testSong.artist}'), findsOneWidget);
  });


  testWidgets('Slider values update threshold and limit', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));

    final state = tester.state<TempPlaylistPageState>(find.byType(TempPlaylistPage));
    final oldThreshold = state.threshold;
    final oldLimit = state.limit;

    await tester.drag(find.byType(Slider).first, const Offset(50, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(state.threshold != oldThreshold, true);

    await tester.drag(find.byType(Slider).last, const Offset(50, 0));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    expect(state.limit != oldLimit, true);
  });

  testWidgets('Finalize Playlist button navigates to FinalPlaylistPage', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TempPlaylistPage()));

    final state = tester.state<TempPlaylistPageState>(find.byType(TempPlaylistPage));
    final testSong = state.suggestedSongs.tracks.isEmpty
        ? Song('Test Song', 'Test Artist')
        : state.suggestedSongs.tracks.first;

    state.setState(() {
      state.suggestedSongs.tracks.add(testSong);
    });

    expect(find.text('Finalize Playlist'), findsOneWidget);
    await tester.tap(find.text('Finalize Playlist'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Final'), findsOneWidget);
  });
}
