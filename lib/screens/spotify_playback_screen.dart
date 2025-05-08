import 'package:flutter/material.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import '../data/services/music/spotify_interface.dart';
import '../data/types/song.dart';

class SpotifyPlaybackScreen extends StatefulWidget {
  final Playlist playlist;
  final SpotifyAPI spotifyApi;

  const SpotifyPlaybackScreen({
    super.key,
    required this.playlist,
    required this.spotifyApi,
  });

  @override
  State<SpotifyPlaybackScreen> createState() => _SpotifyPlaybackScreenState();
}

class _SpotifyPlaybackScreenState extends State<SpotifyPlaybackScreen> {
  bool _loading = false;
  bool _isShuffling = false; // Track shuffle state

  @override
  void initState() {
    super.initState();
    _initializeSpotify();
  }

  Future<void> _initializeSpotify() async {
    setState(() => _loading = true);
    try {
      await widget.spotifyApi.initSpotify();
      if (widget.playlist.tracks.isNotEmpty) {
        for (final song in widget.playlist.tracks) {
          final streamableSong = await widget.spotifyApi.searchSpotifyForSong(song);
          if (streamableSong != null) {
            await widget.spotifyApi.setMusicQueue(streamableSong);
          }
        }
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Now Playing',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _loading
            ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
            : StreamBuilder<PlayerState>(
                stream: SpotifySdk.subscribePlayerState(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error connecting to Spotify',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    );
                  }

                  final playerState = snapshot.data;
                  final track = playerState?.track;

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (track != null) ...[
                          Container(
                            width: double.infinity,
                            height: 300,
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: FutureBuilder(
                                future: SpotifySdk.getImage(
                                  imageUri: track.imageUri,
                                  dimension: ImageDimension.large,
                                ),
                                builder: (context, imageSnapshot) {
                                  if (imageSnapshot.hasData) {
                                    return Image.memory(
                                      imageSnapshot.data!,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(
                                    child: Icon(Icons.music_note, size: 100),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            track.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.artist.name ?? 'Unknown Artist',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          LinearProgressIndicator(
                            value: playerState!.playbackPosition / track.duration,
                            backgroundColor: colorScheme.surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.shuffle,
                                  color: playerState.playbackOptions.isShuffling
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                                onPressed: () async {
                                  // Toggle the shuffle state
                                  _isShuffling = !_isShuffling;
                                  await widget.spotifyApi.shuffleSongs(_isShuffling);
                                  setState(() {}); // Update the UI
                                },
                                iconSize: 28,
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_previous),
                                onPressed: () async {
                                  await widget.spotifyApi.skipToPrevious();
                                },
                                iconSize: 40,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    playerState.isPaused
                                        ? Icons.play_arrow
                                        : Icons.pause,
                                    color: colorScheme.onPrimary,
                                  ),
                                  onPressed: widget.spotifyApi.togglePlayback,
                                  iconSize: 48,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.skip_next),
                                onPressed: () async {
                                  await widget.spotifyApi.skipSong();
                                },
                                iconSize: 40,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.repeat,
                                  color: playerState.playbackOptions.repeatMode !=
                                          RepeatMode.off
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                                onPressed: () => widget.spotifyApi.repeatSongs(
                                  playerState.playbackOptions.repeatMode ==
                                          RepeatMode.off
                                      ? RepeatMode.context
                                      : RepeatMode.off,
                                ),
                                iconSize: 28,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}