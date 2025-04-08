import 'spotify_api.dart';
import 'apple_music.dart';

class MusicAuth {
  final SpotifyAPI _spotifyAPI;
  final AppleMusicAPI _appleMusicAPI;
  String _authStatus = 'unauthenticated';
  bool _subStatus = false;

  MusicAuth(this._spotifyAPI, this._appleMusicAPI);

  // Facade methods for authentication
  Future<String> getAuthStatus() async {
    // Logic to determine current authentication (e.g., based on user preference or token)
    // Placeholder: Assume Spotify by default if authenticated
    if (_subStatus) {
      _authStatus = 'spotify'; // Could be 'apple' based on logic
    }
    print('Auth Status: $_authStatus');
    return _authStatus;
  }

  Future<bool> getSubStatus(String authStatus) async {
    // Delegate to appropriate API for subscription check
    if (authStatus == 'spotify') {
      _subStatus = await _spotifyAPI.checkSubscription();
    } else if (authStatus == 'apple') {
      _subStatus = await _appleMusicAPI.checkSubscription();
    }
    print('Subscription Status: $_subStatus');
    return _subStatus;
  }
}