import 'package:flutter/material.dart';
import 'dart:async';

import 'package:music_kit/music_kit.dart';

class AppleMusicPage extends StatefulWidget {
  const AppleMusicPage({super.key});

  @override
  _AppleMusicPageState createState() => _AppleMusicPageState();
}

class _AppleMusicPageState extends State<AppleMusicPage> {
  final _musicKitPlugin = MusicKit();
  MusicAuthorizationStatus _status = MusicAuthorizationStatusNotDetermined();
  String? _developerToken = String?.fromEnvironment('APPL_MUSIC_DEV_TOKEN');
  String _userToken = '';
  String _countryCode = '';

  MusicSubscription _musicSubsciption = const MusicSubscription();
  late StreamSubscription<MusicSubscription>
      _musicSubscriptionStreamSubscription;

  MusicPlayerState? _playerState;
  late StreamSubscription<MusicPlayerState> _playerStateStreamSubscription;

  MusicPlayerQueue? _playerQueue;
  late StreamSubscription<MusicPlayerQueue> _playerQueueStreamSubscription;

  @override
  void initState() {
    super.initState();
    initPlatformState();

    _musicSubscriptionStreamSubscription =
        _musicKitPlugin.onSubscriptionUpdated.listen((event) {
      setState(() {
        _musicSubsciption = event;
      });
    });

    _playerStateStreamSubscription =
        _musicKitPlugin.onMusicPlayerStateChanged.listen((event) {
      setState(() {
        _playerState = event;
      });
    });

    _playerQueueStreamSubscription =
        _musicKitPlugin.onPlayerQueueChanged.listen((event) {
      setState(() {
        _playerQueue = event;
      });
    });
  }

  @override
  void dispose() {
    _musicSubscriptionStreamSubscription.cancel();
    _playerStateStreamSubscription.cancel();
    _playerQueueStreamSubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    final status = await _musicKitPlugin.authorizationStatus;

    switch (status) {
      case MusicAuthorizationStatusInitial() ||
            MusicAuthorizationStatusDenied() ||
            MusicAuthorizationStatusNotDetermined() ||
            MusicAuthorizationStatusRestricted():
        return;
      case MusicAuthorizationStatusAuthorized():
        {}
    }

    final developerToken = await _musicKitPlugin.requestDeveloperToken();

    if (_musicSubsciption.canBecomeSubscriber == true) return;

    final userToken = await _musicKitPlugin.requestUserToken(developerToken);

    final countryCode = await _musicKitPlugin.currentCountryCode;

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _status = status;
      _developerToken = developerToken;
      _userToken = userToken;
      _countryCode = countryCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text(
                'DeveloperToken: $_developerToken\n',
                maxLines: 3,
              ),
              Text(
                'UserToken: $_userToken\n',
                maxLines: 3,
              ),
              Text('Status: ${_status.toString()}\n'),
              Text('CountryCode: $_countryCode\n'),
              Text('Subscription: ${_musicSubsciption.toString()}\n'),
              Text('PlayerState: ${_playerState?.playbackStatus.toString()}'),
              Text('PlayerQueue: ${_playerQueue?.currentEntry?.title}'),
              TextButton(
                  onPressed: () async {
                    _musicKitPlugin
                        .setShuffleMode(MusicPlayerShuffleMode.songs);
                    _musicKitPlugin.musicPlayerState
                        .then((value) => debugPrint(value.shuffleMode.name));
                  },
                  child: const Text('Shuffle')),
              TextButton(
                  onPressed: () async {
                    final status =
                        await _musicKitPlugin.requestAuthorizationStatus();
                    setState(() {
                      _status = status;
                    });
                  },
                  child: const Text('Request authorization')),
            ],
          ),
        ),
      ),
    );
  }
}