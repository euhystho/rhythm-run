import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rhythmrun/data/services/authentication.dart';
import 'package:rhythmrun/screens/auth/register_screen.dart';
import 'package:rhythmrun/utils/theme.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({super.key});

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  bool _obscurePassword = true;

  // get the authentication service
  final authService = Authentication();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //login button pressed
  void login(BuildContext context) async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmail(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AuthApiException ? e.message : "Error: $e"),
        ),
      );
    }
  }

  void loginWithGoogle(BuildContext context) async {
    try {
      await authService.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void loginWithApple(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        await authService.signInWithAppleForAndroid();
      } else if (Platform.isIOS) {
        await authService.signInWithAppleForIOS();
      }
    } on SignInWithAppleAuthorizationException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Authentication cancelled with Apple")),
      );
    } on AuthApiException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }
  }

  void loginWithSpotify(BuildContext context) async {
    try {
      await authService.signInWithSpotify();
    } on AuthException catch (e) {
      if (e.statusCode == 'provider_email_needs_verification') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please verify the email address associated with your Spotify account before signing in",
            ),
          ),
        );
      } else if (e.statusCode == "over_email_send_rate_limit") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please wait before trying again")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Authentication error occured: ${e.message}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome Back!")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            // Password
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 12),
            // Login Button
            ElevatedButton(
              onPressed: () => login(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Text("Login"),
            ),
            const SizedBox(height: 12),

            // Sign-Up Button
            GestureDetector(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  ),
              child: const Center(
                child: Text("Don't have an account? Sign Up"),
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () => loginWithGoogle(context),
              icon: FaIcon(
                FontAwesomeIcons.google,
                color: Colors.white,
                size: 24,
              ),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Colors.white
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => loginWithApple(context),
              icon: FaIcon(
                FontAwesomeIcons.apple,
                color: Theme.of(context).colorScheme.onSurface,
                size: 24,
              ),
              label: const Text('Sign in with Apple'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
              ),
            ),
            // ElevatedButton.icon(
            //   onPressed: () => loginWithSpotify(context),
            //   icon: FaIcon(
            //     FontAwesomeIcons.spotify,
            //     color: Theme.of(context).colorScheme.onSurface,
            //     size: 24,
            //   ),
            //   label: const Text('Sign in with Spotify'),
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: RhythmRunTheme.spotifyGreen,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

Future<void> main() async {
  runApp(const MyApp());
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
      home: LoginScreenPage(),
    );
  }
}
