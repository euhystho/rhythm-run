import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:spotify_sdk/models/connection_status.dart';
import 'package:spotify_sdk/models/image_uri.dart';
import 'package:spotify_sdk/models/player_context.dart';
import 'package:spotify_sdk/models/player_state.dart';
import 'package:spotify_sdk/spotify_sdk.dart';
import 'widgets/sized_icon_button.dart';

/// A [StatefulWidget] which uses:
/// * [spotify_sdk](https://pub.dev/packages/spotify_sdk)
/// to connect to Spotify and use controls.
class SpotifyTest extends StatefulWidget {
  const SpotifyTest({super.key});

  @override
  SpotifyTestState createState() => SpotifyTestState();
}

class SpotifyTestState extends State<SpotifyTest> {
  bool _loading = false;
  bool _connected = false;
  final Logger _logger = Logger(
    //filter: CustomLogFilter(), // custom logfilter can be used to have logs in release mode
    printer: PrettyPrinter(
      methodCount: 2, // number of method calls to be displayed
      errorMethodCount: 8, // number of method calls if stacktrace is provided
      lineLength: 120, // width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
    ),
  );

  late ImageUri? currentTrackImageUri;
  final List<String> _playerQueue = [];

  @override
  void initState() {
    super.initState();
    _initSpotify();
  }

  Future<void> _initSpotify() async {
    try {
      await connectToSpotifyRemote();
      await getAccessToken();
    } catch (e) {
      setStatus('Failed to initialize Spotify', message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectionStatus>(
      stream: SpotifySdk.subscribeConnectionStatus(),
      builder: (context, snapshot) {
        _connected = false;
        var data = snapshot.data;
        if (data != null) {
          _connected = data.connected;
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('SpotifySdk Example'),
            actions: [
              if (_connected)
                IconButton(
                  onPressed: disconnect,
                  icon: const Icon(Icons.exit_to_app),
                )
            ],
          ),
          body: _sampleFlowWidget(context),
          bottomNavigationBar: _connected ? _buildBottomBar(context) : null,
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          SizedIconButton(
            width: 50,
            icon: Icons.queue_music,
            onPressed: queue,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.playlist_play,
            onPressed: play,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.repeat,
            onPressed: toggleRepeat,
          ),
          SizedIconButton(
            width: 50,
            icon: Icons.shuffle,
            onPressed: toggleShuffle,
          ),
          SizedIconButton(
            width: 50,
            onPressed: addToLibrary,
            icon: Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _sampleFlowWidget(BuildContext context2) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton(
                  onPressed: connectToSpotifyRemote,
                  child: const Icon(Icons.settings_remote),
                ),
                TextButton(
                  onPressed: getAccessToken,
                  child: const Text('get auth token '),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Player State',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _connected
                ? _buildPlayerStateWidget()
                : const Center(
                    child: Text('Not connected'),
                  ),
            const Divider(),
            Text(
              'Player Context',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            _connected
                ? _buildPlayerContextWidget()
                : const Center(
                    child: Text('Not connected'),
                  ),
            const Divider(),
            Text(
              'Player Api',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                  onPressed: seekTo,
                  child: const Text('seek to 20000ms'),
                ),
                ElevatedButton(
                  onPressed: seekToRelative,
                  child: const Text('seek to relative 20000ms'),
                ),
              ],
            ),
            const Divider(),
            Text(
              'Connect Api',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: switchToLocalDevice,
                  child: const Text('switch to local device'),
                ),
              ],
            ),
          ],
        ),
        _loading
            ? Container(
                color: Colors.black12,
                child: const Center(child: CircularProgressIndicator()))
            : const SizedBox(),
      ],
    );
  }

  Widget _buildPlayerStateWidget() {
    return StreamBuilder<PlayerState>(
      stream: SpotifySdk.subscribePlayerState(),
      builder: (BuildContext context, AsyncSnapshot<PlayerState> snapshot) {
        var track = snapshot.data?.track;
        currentTrackImageUri = track?.imageUri;
        var playerState = snapshot.data;

        if (playerState == null || track == null) {
          return Center(
            child: Container(),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_previous,
                  onPressed: skipPrevious,
                ),
                playerState.isPaused
                    ? SizedIconButton(
                        width: 50,
                        icon: Icons.play_arrow,
                        onPressed: resume,
                      )
                    : SizedIconButton(
                        width: 50,
                        icon: Icons.pause,
                        onPressed: pause,
                      ),
                SizedIconButton(
                  width: 50,
                  icon: Icons.skip_next,
                  onPressed: skipNext,
                ),
              ],
            ),
            track.isPodcast
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        child: const SizedBox(
                          width: 50,
                          child: Text("x0.5"),
                        ),
                        onPressed: () => setPlaybackSpeed(
                            PodcastPlaybackSpeed.playbackSpeed_50),
                      ),
                      TextButton(
                        child: const SizedBox(
                          width: 50,
                          child: Text("x1"),
                        ),
                        onPressed: () => setPlaybackSpeed(
                            PodcastPlaybackSpeed.playbackSpeed_100),
                      ),
                      TextButton(
                        child: const SizedBox(
                          width: 50,
                          child: Text("x1.5"),
                        ),
                        onPressed: () => setPlaybackSpeed(
                            PodcastPlaybackSpeed.playbackSpeed_150),
                      ),
                      TextButton(
                        child: const SizedBox(
                          width: 50,
                          child: Text("x3.0"),
                        ),
                        onPressed: () => setPlaybackSpeed(
                            PodcastPlaybackSpeed.playbackSpeed_300),
                      ),
                    ],
                  )
                : Container(),
            Text(
              'Track',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              '${track.name} by ${track.artist.name} from the album ${track.album.name}',
              maxLines: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Playback',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Playback speed: ${playerState.playbackSpeed}'),
                Text(
                    'Progress: ${playerState.playbackPosition}ms/${track.duration}ms'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Paused: ${playerState.isPaused}'),
                Text('Shuffling: ${playerState.playbackOptions.isShuffling}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Is episode: ${track.isEpisode}'),
                Text('Is podcast: ${track.isPodcast}'),
              ],
            ),
            Row(
              children: [
                Text('RepeatMode: ${playerState.playbackOptions.repeatMode}'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Repeat Mode:',
                    ),
                    DropdownButton<RepeatMode>(
                      value: RepeatMode
                          .values[playerState.playbackOptions.repeatMode.index],
                      items: const [
                        DropdownMenuItem(
                          value: RepeatMode.off,
                          child: Text('off'),
                        ),
                        DropdownMenuItem(
                          value: RepeatMode.track,
                          child: Text('track'),
                        ),
                        DropdownMenuItem(
                          value: RepeatMode.context,
                          child: Text('context'),
                        ),
                      ],
                      onChanged: (repeatMode) => setRepeatMode(repeatMode!),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('Switch shuffle: '),
                    Switch.adaptive(
                      value: playerState.playbackOptions.isShuffling,
                      onChanged: (bool shuffle) => setShuffle(
                        shuffle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            _connected
                ? Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                    child: spotifyImageWidget(track.imageUri),
                  )
                : const Text('Connect to see an image...'),
            Text(
              track.imageUri.raw,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlayerContextWidget() {
    return StreamBuilder<PlayerContext>(
      stream: SpotifySdk.subscribePlayerContext(),
      initialData: PlayerContext('', '', '', ''),
      builder: (BuildContext context, AsyncSnapshot<PlayerContext> snapshot) {
        var playerContext = snapshot.data;
        if (playerContext == null) {
          return const Center(
            child: Text('Not connected'),
          );
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Title',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(playerContext.title),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Subtitle',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(playerContext.subtitle),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(playerContext.type),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Uri',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            Text(
              playerContext.uri,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      },
    );
  }

  Widget spotifyImageWidget(ImageUri image) {
    return FutureBuilder(
        future: SpotifySdk.getImage(
          imageUri: image,
          dimension: ImageDimension.large,
        ),
        builder: (BuildContext context, AsyncSnapshot<Uint8List?> snapshot) {
          if (snapshot.hasData) {
            return Image.memory(snapshot.data!);
          } else if (snapshot.hasError) {
            setStatus(snapshot.error.toString());
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Error getting image')),
            );
          } else {
            return SizedBox(
              width: ImageDimension.large.value.toDouble(),
              height: ImageDimension.large.value.toDouble(),
              child: const Center(child: Text('Getting image...')),
            );
          }
        });
  }

  Future<void> disconnect() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.disconnect();
      setStatus(result ? 'disconnect successful' : 'disconnect failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<void> connectToSpotifyRemote() async {
    try {
      setState(() {
        _loading = true;
      });
      var result = await SpotifySdk.connectToSpotifyRemote(
          clientId: const String.fromEnvironment('SPOT_CLIENT_ID'),
          redirectUrl: const String.fromEnvironment('REDIRECT_URL'));
      setStatus(result
          ? 'connect to spotify successful'
          : 'connect to spotify failed');
      setState(() {
        _loading = false;
      });
    } on PlatformException catch (e) {
      setState(() {
        _loading = false;
      });
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setState(() {
        _loading = false;
      });
      setStatus('not implemented');
    }
  }

  Future<String> getAccessToken() async {
    try {
      var authenticationToken = await SpotifySdk.getAccessToken(
          clientId: const String.fromEnvironment('SPOT_CLIENT_ID'),
          redirectUrl: const String.fromEnvironment('REDIRECT_URL'),
          scope: 'app-remote-control, '
              'user-modify-playback-state, '
              'playlist-read-private, '
              'playlist-modify-public,user-read-currently-playing');
      setStatus('Got a token: $authenticationToken');
      return authenticationToken;
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
      return Future.error('$e.code: $e.message');
    } on MissingPluginException {
      setStatus('not implemented');
      return Future.error('not implemented');
    }
  }

  Future getPlayerState() async {
    try {
      return await SpotifySdk.getPlayerState();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> updateQueue(String trackUri) async {
    setState(() {
      _playerQueue.add(trackUri);
    });
    await queue();
  }

  Future<void> queue() async {
    try {
      if (_playerQueue.isNotEmpty) {
        await SpotifySdk.queue(spotifyUri: _playerQueue.last);
      }
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> toggleRepeat() async {
    try {
      await SpotifySdk.toggleRepeat();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setRepeatMode(RepeatMode repeatMode) async {
    try {
      await SpotifySdk.setRepeatMode(
        repeatMode: repeatMode,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setShuffle(bool shuffle) async {
    try {
      await SpotifySdk.setShuffle(
        shuffle: shuffle,
      );
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> toggleShuffle() async {
    try {
      await SpotifySdk.toggleShuffle();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> setPlaybackSpeed(
      PodcastPlaybackSpeed podcastPlaybackSpeed) async {
    try {
      await SpotifySdk.setPodcastPlaybackSpeed(
          podcastPlaybackSpeed: podcastPlaybackSpeed);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> play() async {
    try {
      await SpotifySdk.play(spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> pause() async {
    try {
      await SpotifySdk.pause();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> resume() async {
    try {
      await SpotifySdk.resume();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipNext() async {
    try {
      await SpotifySdk.skipNext();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> skipPrevious() async {
    try {
      await SpotifySdk.skipPrevious();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> seekTo() async {
    try {
      await SpotifySdk.seekTo(positionedMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> seekToRelative() async {
    try {
      await SpotifySdk.seekToRelativePosition(relativeMilliseconds: 20000);
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> switchToLocalDevice() async {
    try {
      await SpotifySdk.switchToLocalDevice();
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  Future<void> addToLibrary() async {
    try {
      await SpotifySdk.addToLibrary(
          spotifyUri: 'spotify:track:58kNJana4w5BIjlZE2wq5m');
    } on PlatformException catch (e) {
      setStatus(e.code, message: e.message);
    } on MissingPluginException {
      setStatus('not implemented');
    }
  }

  void setStatus(String code, {String? message}) {
    var text = message ?? '';
    _logger.i('$code$text');
  }
}