import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rhythmrun/screens/temp_playlist_screen_spotify.dart';
import 'package:rhythmrun/utils/theme.dart';
import 'data/services/music/spotify_interface.dart';
import 'data/types/song.dart';

// Main App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  runApp(
    ChangeNotifierProvider(
      create: (_) => SpotifyAPIAuth()..loadTokens(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify SpotifyPlaylist Importer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<int> selectedIndices = {};
  List<SpotifyPlaylist>? playlists;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _loadPlaylists() async {
    final authProvider = Provider.of<SpotifyAPIAuth>(context, listen: false);
    if (authProvider.isAuthenticated) {
      setState(() {
        isLoading = true;
      });
      try {
        final loaded = await fetchPlaylists(
          authProvider.accessToken!,
          authProvider,
        );
        setState(() {
          playlists = loaded;
        });
      } catch (e) {
        setState(() {
          playlists = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _importSelectedPlaylists() async {
    final authProvider = Provider.of<SpotifyAPIAuth>(context, listen: false);
    setState(() {
      isLoading = true;
    });
    try {
      // Fetch tracks for each selected playlist and store in the playlist
      for (final i in selectedIndices) {
        final playlist = playlists![i];
        final tracks = await fetchTracks(
          authProvider.accessToken!,
          playlist.id,
          authProvider,
        );
        playlist.setTracks(tracks);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing playlists: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
      // TODO: Add the BPM Analysis step here?
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TempPlaylistSpotifyPage(
            importedSongs: selectedIndices
                .expand((index) => playlists![index].tracks ?? [])
                .cast<StreamableSong>()
                .toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<SpotifyAPIAuth>(context);

    Widget connectCard = Padding(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          try {
            await authProvider.authenticate();
            await _loadPlaylists();
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.spotify,
                  color: RhythmRunTheme.spotifyGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect with Spotify',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Import your playlists from Spotify',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Import Spotify Playlists',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Show connectCard only if not authenticated, or playlists are not loaded or empty
            if (!authProvider.isAuthenticated ||
                playlists == null ||
                playlists!.isEmpty)
              connectCard,
            if (authProvider.isAuthenticated && playlists != null) ...[
              if (playlists!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select playlists to import',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              Expanded(
                child:
                    isLoading
                        ? Center(
                          child: SpinKitFadingCircle(
                            color: Theme.of(context).colorScheme.primary,
                            size: 40,
                          ),
                        )
                        : (playlists == null
                            ? const SizedBox.shrink()
                            : playlists!.isEmpty
                            ? Center(child: Text('No playlists found'))
                            : ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: playlists!.length,
                              itemBuilder: (context, index) {
                                final playlist = playlists![index];
                                final isSelected = selectedIndices.contains(
                                  index,
                                );
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                      border:
                                          isSelected
                                              ? Border.all(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                width: 2,
                                              )
                                              : null,
                                    ),
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            playlist.imageURL.isNotEmpty
                                                ? Image.network(
                                                  playlist.imageURL,
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                )
                                                : Container(
                                                  width: 50,
                                                  height: 50,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.music_note),
                                                ),
                                      ),
                                      title: Text(
                                        playlist.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${playlist.trackCount} songs',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                        ),
                                      ),
                                      trailing: Checkbox(
                                        value: isSelected,
                                        onChanged: (checked) {
                                          setState(() {
                                            if (checked == true) {
                                              selectedIndices.add(index);
                                            } else {
                                              selectedIndices.remove(index);
                                            }
                                          });
                                        },
                                        activeColor: Color(0xFF1DB954),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            selectedIndices.remove(index);
                                          } else {
                                            selectedIndices.add(index);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                );
                              },
                            )),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed:
                        selectedIndices.isNotEmpty
                            ? _importSelectedPlaylists
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Continue',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ], // end if authenticated and playlists != null
          ],
        ),
      ),
    );
  }
}
