import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rhythmrun/data/services/music/spotify_interface.dart';
import 'package:rhythmrun/screens/auth/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'screens/file_upload_screen_2.dart';
// import 'apple_music_test.dart';
import 'spotify_playlist.dart';

// Welcome Page
class WelcomePageWidget extends StatelessWidget {
  const WelcomePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.primary,
            ],
            stops: const [0, 1],
            begin: AlignmentDirectional(0, 1),
            end: AlignmentDirectional(0, -1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Title
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: ResponsiveText(
                    text: 'Welcome to RhythmRun!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: ResponsiveText(
                    text: 'Choose your music listening preference to continue',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

                // Spotify Button
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement Spotify Authentication
                      print('Spotify Authentication');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()
                        ),
                      );
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.spotify,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                    label: const Text('Import with Spotify'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RhythmRunTheme.spotifyGreen,
                    ),
                  ),
                ),

                // // Apple Music Button
                // Padding(
                //   padding: const EdgeInsets.only(bottom: 10),
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       // TODO: Implement Apple Music Authentication
                //       print('Apple Music Authentication');
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => AppleMusicPage(),
                //         ),
                //       );
                //     },
                //     icon: Icon(
                //       Icons.apple,
                //       color: Theme.of(context).colorScheme.onSurface,
                //       size: 24,
                //     ),
                //     label: const Text('Import with Apple Music'),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: RhythmRunTheme.appleMusicRed,
                //     ),
                //   ),
                // ),

                // Create Local Account Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocalSongsUploadPage(),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  label: const Text('Import with Local Music'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                // Sign In Row
                Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          // Implement Accounts
                          print('Sign into Existing Account');
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AuthGate()),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor:
                                Theme.of(context).colorScheme.secondary,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
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
  }
}

// Main App
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/.env');

  // Fetch Supabase URL and Key from the environment
  final String supabaseURL =
      dotenv.env['SUPABASE_URL'] ?? String.fromEnvironment('SUPABASE_URL');
  final String supabaseKey =
      dotenv.env['SUPABASE_ANON_KEY'] ??
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Initialize Supabase
  await Supabase.initialize(anonKey: supabaseKey, url: supabaseURL);

  runApp(
    ChangeNotifierProvider(
      create: (_) => SpotifyAPIAuth()..loadTokens(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Toggle the Debug Banner on the side :)
      debugShowCheckedModeBanner: false,
      title: 'RhythmRun',
      theme: RhythmRunTheme.lightTheme,
      darkTheme: RhythmRunTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const WelcomePageWidget(),
    );
  }
}
